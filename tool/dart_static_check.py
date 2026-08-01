#!/usr/bin/env python3
"""Offline static sanity checks for the Between Dart sources.

The sandbox has no Dart SDK, so this script approximates the parts of
`dart analyze` that catch the mistakes hand-written code actually makes:
unresolved imports, unknown top-level symbols, and member accesses on
locally-typed variables that the declaring class does not expose.
"""
from __future__ import annotations

import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')

# ---------------------------------------------------------------- utilities

def strip_code(src: str):
    """Return (code_with_strings_and_comments_blanked, ok)."""
    out = []
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        if c == '/' and i + 1 < n and src[i + 1] == '/':
            j = src.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i))
            i = j
            continue
        if c == '/' and i + 1 < n and src[i + 1] == '*':
            depth = 1
            j = i + 2
            while j < n and depth:
                if src.startswith('/*', j):
                    depth += 1
                    j += 2
                elif src.startswith('*/', j):
                    depth -= 1
                    j += 2
                else:
                    j += 1
            out.append(''.join(ch if ch == '\n' else ' ' for ch in src[i:j]))
            i = j
            continue
        if c in '\'"':
            raw = i > 0 and src[i - 1] == 'r'
            triple = src.startswith(c * 3, i)
            q = c * 3 if triple else c
            j = i + len(q)
            while j < n:
                if src[j] == '\\' and not raw:
                    j += 2
                    continue
                if src.startswith(q, j):
                    j += len(q)
                    break
                j += 1
            out.append(''.join(ch if ch == '\n' else ' ' for ch in src[i:j]))
            i = j
            continue
        out.append(c)
        i += 1
    return ''.join(out)


def dart_files():
    for base, _dirs, files in os.walk(LIB):
        for f in sorted(files):
            if f.endswith('.dart'):
                yield os.path.join(base, f)


# ------------------------------------------------------- declaration parsing

DECL_RE = re.compile(
    r'^(?:abstract\s+|base\s+|final\s+|interface\s+|sealed\s+|mixin\s+)*'
    r'(class|enum|mixin|extension|typedef)\s+([A-Za-z_$][\w$]*)',
    re.M)
TOPFN_RE = re.compile(
    r'^(?:final|const)\s+(?:[\w$<>,\s?\[\]]+\s+)?([a-z_$][\w$]*)\s*=', re.M)
TOPFN2_RE = re.compile(
    r'^(?:[A-Za-z_$][\w$<>,\s?\.\[\]]*?)\s+([a-z_$][\w$]*)\s*\([^;{]*\)\s*(?:async\s*)?\{', re.M)

IMPORT_RE = re.compile(r'''^\s*(import|export)\s+(['"])([^'"]+)\2([^;]*);''', re.M)


class Unit:
    def __init__(self, path, src):
        self.path = path
        self.rel = os.path.relpath(path, ROOT)
        self.raw = src
        self.code = strip_code(src)
        self.imports = []   # (kind, target_abs_or_pkg, show, hide, prefix)
        self.declares = set()
        self.members = {}   # class name -> set of member names
        self.supers = {}    # class name -> list of super/mixin/interface names
        self._parse()

    def _parse(self):
        for m in IMPORT_RE.finditer(self.raw):
            kind, _q, target, tail = m.group(1), m.group(2), m.group(3), m.group(4)
            shown = set()
            for grp in re.findall(r'\bshow\s+([A-Za-z_$][\w$,\s]*)', tail):
                shown |= {x.strip() for x in grp.split(',') if x.strip()}
            hidden = set()
            for grp in re.findall(r'\bhide\s+([A-Za-z_$][\w$,\s]*)', tail):
                hidden |= {x.strip() for x in grp.split(',') if x.strip()}
            prefix = None
            pm = re.search(r'\bas\s+([A-Za-z_$][\w$]*)', tail)
            if pm:
                prefix = pm.group(1)
            self.imports.append((kind, target, shown, hidden, prefix))

        for m in DECL_RE.finditer(self.code):
            self.declares.add(m.group(2))
        for m in TOPFN_RE.finditer(self.code):
            self.declares.add(m.group(1))
        for m in TOPFN2_RE.finditer(self.code):
            self.declares.add(m.group(1))

        # class bodies -> member names
        for m in re.finditer(
                r'^(?:abstract\s+|base\s+|final\s+|interface\s+|sealed\s+|mixin\s+)*'
                r'(?:class|mixin|extension|enum)\s+([A-Za-z_$][\w$]*)'
                r'[^{;]*?(\{)', self.code, re.M):
            name = m.group(1)
            start = m.end(2) - 1
            depth = 0
            i = start
            while i < len(self.code):
                if self.code[i] == '{':
                    depth += 1
                elif self.code[i] == '}':
                    depth -= 1
                    if depth == 0:
                        break
                i += 1
            body = self.code[start + 1:i]
            head = self.code[m.start():m.end(2)]
            sup = re.findall(r'[A-Za-z_$][\w$]*', re.sub(
                r'^.*?(?:extends|implements|with|on)\b', '',
                head, flags=re.S) if re.search(r'\b(extends|implements|with|on)\b', head) else '')
            self.supers[name] = [s for s in sup if s and s[0].isupper()]
            self.members[name] = self._member_names(body, name)

    @staticmethod
    def _member_names(body, cls):
        names = set()
        # fields:  final Type name;  / Type name = ...; / late final X y;
        for m in re.finditer(
                r'^\s*(?:static\s+|late\s+|final\s+|const\s+|covariant\s+)*'
                r'(?:[A-Za-z_$][\w$<>,\s?\.\[\]]*?\s+)?([a-z_$][\w$]*)\s*(?:=[^=]|;)',
                body, re.M):
            names.add(m.group(1))
        for m in re.finditer(r'\b([a-z_$][\w$]*)\s*\((?:[^()]|\([^()]*\))*\)\s*;', body):
            names.add(m.group(1))
        # methods / getters
        for m in re.finditer(r'\b([a-z_$][\w$]*)\s*\((?:[^()]|\([^()]*\))*\)\s*(?:async\*?\s*|sync\*\s*)?[{=]', body):
            names.add(m.group(1))
        for m in re.finditer(r'\bget\s+([a-z_$][\w$]*)', body):
            names.add(m.group(1))
        for m in re.finditer(r'\bset\s+([a-z_$][\w$]*)', body):
            names.add(m.group(1))
        for m in re.finditer(r'^\s*([a-z_$][\w$]*)\s*(?:\([^()]*\))?\s*[,;]', body, re.M):
            names.add(m.group(1))
        # enum values on the first line(s) of an enum body
        for m in re.finditer(r'^\s*([a-z_$][\w$]*)\s*[,;]\s*$', body, re.M):
            names.add(m.group(1))
        # constructor named params promoted to fields (this.x)
        for m in re.finditer(r'this\.([a-z_$][\w$]*)', body):
            names.add(m.group(1))
        return names


def main():
    units = {}
    for p in dart_files():
        with open(p, encoding='utf-8') as fh:
            units[os.path.abspath(p)] = Unit(p, fh.read())

    problems = []

    # ---- 1. relative imports resolve
    for path, u in units.items():
        for kind, target, *_ in u.imports:
            if target.startswith('dart:') or target.startswith('package:'):
                continue
            resolved = os.path.abspath(os.path.join(os.path.dirname(path), target))
            if resolved not in units:
                problems.append(f'{u.rel}: unresolved {kind} "{target}"')

    # ---- 2. export graph, then visible symbols per file
    def exported(path, seen=None):
        seen = seen or set()
        if path in seen:
            return set()
        seen.add(path)
        u = units[path]
        out = set(u.declares)
        for kind, target, shown, hidden, prefix in u.imports:
            if kind != 'export':
                continue
            if target.startswith(('dart:', 'package:')):
                continue
            r = os.path.abspath(os.path.join(os.path.dirname(path), target))
            if r in units:
                sub = exported(r, seen)
                if shown:
                    sub &= shown
                sub -= hidden
                out |= sub
        return out

    exports = {p: exported(p) for p in units}

    visible = {}
    for path, u in units.items():
        vis = set(u.declares)
        for kind, target, shown, hidden, prefix in u.imports:
            if kind != 'import' or prefix:
                continue
            if target.startswith(('dart:', 'package:')):
                continue
            r = os.path.abspath(os.path.join(os.path.dirname(path), target))
            if r in units:
                sub = exports[r]
                if shown:
                    sub = sub & shown
                sub -= hidden
                vis |= sub
        visible[path] = vis

    # ---- 3. project-declared symbols used but not visible
    all_project = set()
    for u in units.values():
        all_project |= u.declares
    project_types = {n for n in all_project if n[:1].isupper()}

    for path, u in units.items():
        used = set(re.findall(r'\b([A-Z][\w$]*)\b', u.code))
        for name in sorted(used & project_types):
            if name in visible[path]:
                continue
            # ignore names that also exist as a member/local
            problems.append(f'{u.rel}: uses "{name}" but it is not imported')

    # ---- 4. member access on locally typed variables
    class_members = {}
    for u in units.values():
        for cls, mem in u.members.items():
            class_members.setdefault(cls, set())
            class_members[cls] |= mem
    supers = {}
    for u in units.values():
        for cls, s in u.supers.items():
            supers.setdefault(cls, [])
            supers[cls] += s

    def all_members(cls, seen=None):
        seen = seen or set()
        if cls in seen or cls not in class_members:
            return set()
        seen.add(cls)
        out = set(class_members[cls])
        for s in supers.get(cls, []):
            out |= all_members(s, seen)
        return out

    subclassed = set()
    for lst in supers.values():
        subclassed |= set(lst)
    enums = set()
    for u in units.values():
        for m in re.finditer(r'^\s*enum\s+([A-Za-z_$][\w$]*)', u.code, re.M):
            enums.add(m.group(1))

    UNKNOWN_SUPER = {'Object'}
    OBJECT_MEMBERS = {
        'toString', 'hashCode', 'runtimeType', 'noSuchMethod', 'toJson',
        'copyWith', 'hash', 'call',
    }

    declared_var = re.compile(
        r'\b(?:final\s+|const\s+|late\s+)?([A-Z][\w$]*)(?:<[^;=()]*>)?\??\s+'
        r'([a-z_$][\w$]*)\s*=')

    for path, u in units.items():
        # only check types the project itself declares and fully controls
        for m in declared_var.finditer(u.code):
            cls, var = m.group(1), m.group(2)
            if cls not in class_members:
                continue
            if cls in subclassed:
                continue  # polymorphic base: `is`/`as` promotion is invisible here
            if cls in enums:
                continue  # enums get .name/.index/values from the language
            if any(cls in supers.get(cls, []) for _ in (0,)):
                pass
            known = all_members(cls) | OBJECT_MEMBERS
            # unresolved superclass -> skip, we cannot know the full surface
            chain_unknown = False
            stack = [cls]
            seen = set()
            while stack:
                c = stack.pop()
                if c in seen:
                    continue
                seen.add(c)
                for s in supers.get(c, []):
                    if s not in class_members and s not in UNKNOWN_SUPER:
                        chain_unknown = True
                    stack.append(s)
            if chain_unknown:
                continue
            scope_limit = 1200
            scope = u.code[m.end():m.end() + scope_limit]
            # Avoid false positives when the fixed-size window ends in the
            # middle of an identifier (for example `.currentSce` from
            # `.currentScene`). In that case the member regex below would see a
            # synthetic, non-existent member name.
            if len(scope) == scope_limit:
                scope = re.sub(r'[A-Za-z_$][\w$]*$', '', scope)
            nxt = re.search(r'\b[A-Z][\w$]*[?]?\s+' + re.escape(var) + r'\s*=', scope)
            if nxt:
                scope = scope[:nxt.start()]
            # `(?<![.\w])` keeps `state.variables.snapshot.entries` from being
            # read as the local named `snapshot`.
            for am in re.finditer(
                    r'(?<![.\w$])' + re.escape(var) + r'[!?]?\.([a-z_$][\w$]*)',
                    scope):
                mem = am.group(1)
                if mem not in known:
                    line = u.code[:m.end() + am.start()].count('\n') + 1
                    problems.append(
                        f'{u.rel}:{line}: {cls} has no member "{mem}" (via {var})')

    # ---- 5. balance checks
    for path, u in units.items():
        if u.code.count('{') != u.code.count('}'):
            problems.append(f'{u.rel}: unbalanced braces '
                            f'({u.code.count("{")} open, {u.code.count("}")} close)')
        if u.code.count('(') != u.code.count(')'):
            problems.append(f'{u.rel}: unbalanced parens')
        if u.code.count('[') != u.code.count(']'):
            problems.append(f'{u.rel}: unbalanced brackets')

    seen = set()
    uniq = [p for p in problems if not (p in seen or seen.add(p))]
    for p in uniq:
        print(p)
    print(f'\n{len(units)} files, {len(uniq)} findings')
    return 1 if uniq else 0


if __name__ == '__main__':
    sys.exit(main())
