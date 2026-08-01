#!/usr/bin/env python3
"""Lints the Between DSL against the engine that has to run it.

Checks performed:
  1. every `simple` directive in the registry has a command handler
  2. every registered handler name exists in the registry
  3. every named argument a handler reads is declared on its spec
  4. every directive used by a script is known
  5. every jump target (@goto/@call/@choice ->/@schedule/@on) has a label
  6. every asset a script references exists on disk
  7. every URL a script opens resolves in assets/data/websites.json
"""
from __future__ import annotations

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REG = os.path.join(ROOT, 'lib/engine/parser/directive_registry.dart')
CMDS = os.path.join(ROOT, 'lib/engine/commands')
STORY = os.path.join(ROOT, 'assets/story')
WEBSITES = os.path.join(ROOT, 'assets/data/websites.json')

problems: list[str] = []
notes: list[str] = []


def fail(msg):
    problems.append(msg)


# ------------------------------------------------------------------ registry
src = open(REG, encoding='utf-8').read()
src_nc = re.sub(r'//[^\n]*', '', src)

specs = {}          # canonical name -> dict
alias_to_canon = {}
for m in re.finditer(r"DirectiveSpec\(\s*'([a-z_0-9]+)'(.*?)\)\s*,\s*(?=DirectiveSpec|\]|//)",
                     src_nc, re.S):
    name, body = m.group(1), m.group(2)
    shape = 'simple'
    sm = re.search(r'shape:\s*DirectiveShape\.(\w+)', body)
    if sm:
        shape = sm.group(1)
    aliases = []
    am = re.search(r"aliases:\s*(?:const\s*)?<String>\[(.*?)\]", body, re.S)
    if am:
        aliases = re.findall(r"'([^']+)'", am.group(1))
    named = set()
    nm = re.search(r"named:\s*(?:const\s*)?<String>\{(.*?)\}", body, re.S)
    if nm:
        named = set(re.findall(r"'([^']+)'", nm.group(1)))
    specs[name] = {'shape': shape, 'aliases': aliases, 'named': named}
    alias_to_canon[name] = name
    for a in aliases:
        alias_to_canon[a] = name

if len(specs) < 100:
    fail(f'registry parse looks wrong: only {len(specs)} specs found')

# ------------------------------------------------------------------ handlers
handler_names = {}   # directive name -> handler function symbol
handler_body = {}    # handler function symbol -> source text
for fn in sorted(os.listdir(CMDS)):
    if not fn.endswith('.dart'):
        continue
    text = open(os.path.join(CMDS, fn), encoding='utf-8').read()
    for m in re.finditer(
            r"FunctionCommand\(\s*(?:const\s*)?<String>\[(.*?)\]\s*,\s*(\w+)\s*[,)]",
            text, re.S):
        names = re.findall(r"'([^']+)'", m.group(1))
        for n in names:
            handler_names[n] = m.group(2)
    for m in re.finditer(
            r"FunctionCommand\(\s*const\s*<String>\[\s*'([^']+)'\s*\]\s*,\s*(\w+)", text):
        handler_names[m.group(1)] = m.group(2)
    # capture each top-level handler function body
    for m in re.finditer(
            r"^(?:Future<CommandOutcome>|CommandOutcome|FutureOr<CommandOutcome>)\s+"
            r"(_\w+)\s*\([^)]*\)\s*(?:async\s*)?\{", text, re.M):
        start = text.index('{', m.start())
        depth, i = 0, start
        while i < len(text):
            if text[i] == '{':
                depth += 1
            elif text[i] == '}':
                depth -= 1
                if depth == 0:
                    break
            i += 1
        handler_body[m.group(1)] = text[start:i]

# 1. simple directives need a handler
STRUCTURAL_OK = {'label'}
for name, spec in specs.items():
    if spec['shape'] != 'simple':
        continue
    if name in handler_names or any(a in handler_names for a in spec['aliases']):
        continue
    fail(f'directive @{name} is `simple` but no command handler is registered')

# 2. handlers must be registered
for name in sorted(handler_names):
    if name not in alias_to_canon:
        fail(f'handler for @{name} has no DirectiveSpec')

# 3. named args a handler reads must be declared
NAMED_READ = re.compile(r"\bnamed(?:Str|StrOrNull|Num|Int|Bool|Duration)?\("
                        r"\s*'([a-z_0-9]+)'|\bhas\(\s*'([a-z_0-9]+)'")
for name, fnsym in sorted(handler_names.items()):
    body = handler_body.get(fnsym)
    if not body:
        continue
    canon = alias_to_canon.get(name)
    if canon is None:
        continue
    declared = specs[canon]['named']
    for m in NAMED_READ.finditer(body):
        key = m.group(1) or m.group(2)
        if key not in declared:
            fail(f'@{name} handler reads named arg "{key}" '
                 f'but the spec declares {sorted(declared) or "none"}')

# 3b. anything the parser handles itself must not be declared `simple`
parser_src = open(os.path.join(ROOT, 'lib/engine/parser/parser.dart'),
                  encoding='utf-8').read()
head = parser_src[parser_src.find('switch'):]
parser_cases = set(re.findall(r"case\s+'([a-z_0-9]+)'\s*:", head[:6000]))
for c in sorted(parser_cases):
    if c not in specs:
        fail(f'parser handles @{c} but the registry has no spec for it')
    elif specs[c]['shape'] == 'simple':
        fail(f'@{c} is parsed structurally but the registry marks it `simple`')

# ------------------------------------------------------------------- scripts
known = set(alias_to_canon)
label_re = re.compile(r'^\s*::\s*([A-Za-z_][\w]*)')
directive_re = re.compile(r'^\s*@([a-z_0-9]+)')

script_files = []
for base, _d, files in os.walk(STORY):
    for f in sorted(files):
        if f.endswith('.txt'):
            script_files.append(os.path.join(base, f))

websites = json.load(open(WEBSITES, encoding='utf-8'))
site_urls = set()
def collect(node):
    global site_urls
    if isinstance(node, dict):
        for k, v in node.items():
            if k in ('url', 'path', 'aliases'):
                if isinstance(v, str):
                    site_urls.add(v.lower())
                elif isinstance(v, list):
                    site_urls |= {str(x).lower() for x in v}
            collect(v)
    elif isinstance(node, list):
        for v in node:
            collect(v)
collect(websites)

for path in script_files:
    rel = os.path.relpath(path, ROOT)
    lines = open(path, encoding='utf-8').read().splitlines()
    labels, jumps, used, assets, urls = set(), [], set(), [], []
    for i, raw in enumerate(lines, 1):
        line = raw.split('#')[0] if raw.lstrip().startswith('#') else raw
        m = label_re.match(line)
        if m:
            if m.group(1) in labels:
                fail(f'{rel}:{i}: duplicate label :: {m.group(1)}')
            labels.add(m.group(1))
            continue
        m = directive_re.match(line)
        if not m:
            continue
        d = m.group(1)
        used.add(d)
        if d not in known:
            fail(f'{rel}:{i}: unknown directive @{d}')
        rest = line[m.end():]
        if d in ('goto', 'jump', 'call', 'gosub', 'schedule', 'on', 'after'):
            t = re.search(r'\b([A-Za-z_][\w]*)', rest)
            if t and d in ('goto', 'jump', 'call', 'gosub'):
                jumps.append((i, t.group(1)))
        for t in re.findall(r'->\s*([A-Za-z_][\w]*)', rest):
            jumps.append((i, t))
        for a in re.findall(r'"(assets/[^"]+)"', rest):
            assets.append((i, a))
        for u in re.findall(r'"((?:https?://|between://)[^"]+)"', rest):
            urls.append((i, u))
    for i, t in jumps:
        if t not in labels:
            fail(f'{rel}:{i}: jump to missing label "{t}"')
    for i, a in assets:
        if not os.path.exists(os.path.join(ROOT, a)):
            fail(f'{rel}:{i}: missing asset {a}')
    for i, u in urls:
        low = u.lower()
        if low.startswith('between://'):
            continue
        base = low.split('?')[0].rstrip('/')
        host = re.sub(r'^https?://', '', base).split('/')[0]
        if not any(base.endswith(s.rstrip('/')) or s.rstrip('/').endswith(base)
                   or host in s for s in site_urls):
            fail(f'{rel}:{i}: url {u} does not resolve in websites.json')
    notes.append(f'{rel}: {len(lines)} lines, {len(labels)} labels, '
                 f'{len(used)} distinct directives, {len(jumps)} jumps')

print(f'registry: {len(specs)} directives ({len(alias_to_canon)} names incl. aliases)')
print(f'handlers: {len(handler_names)} directive names bound')
for n in notes:
    print(n)
print()
for p in problems:
    print('FAIL ' + p)
print(f'{len(problems)} problems')
sys.exit(1 if problems else 0)
