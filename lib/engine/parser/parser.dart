import '../diagnostics/diagnostic.dart';
import '../lexer/lexer.dart';
import '../lexer/source_span.dart';
import '../lexer/token.dart';
import '../variables/engine_value.dart';
import '../variables/variable_store.dart';
import 'ast.dart';
import 'directive_registry.dart';
import 'expression.dart';
import 'expression_parser.dart';
import 'token_reader.dart';

/// Recursive-descent parser for the *Between* story language.
///
/// Design rules that keep the language forgiving for writers:
///  * Unknown directives never break the parse — they become generic
///    [CommandStatement]s and are resolved by the command registry at runtime.
///  * Bare words in argument position are **strings** (`@typing ethan 4`),
///    while bare words inside conditions are **variables** (`@if trust > 3`).
///  * A blank line closes a `@choice` block, matching the existing scripts.
class Parser extends TokenReader with ExpressionParsing {
  Parser(
    super.tokens, {
    required this.sourceName,
    DirectiveRegistry? registry,
    super.diagnostics,
  }) : registry = registry ?? DirectiveRegistry.shared;

  factory Parser.fromSource(
    String source, {
    String sourceName = '<memory>',
    DirectiveRegistry? registry,
  }) {
    final Lexer lexer = Lexer(source, sourceName: sourceName);
    final List<Token> tokens = lexer.tokenize();
    final Parser parser = Parser(
      tokens,
      sourceName: sourceName,
      registry: registry,
    );
    parser.diagnostics.addAll(lexer.diagnostics.all);
    return parser;
  }

  final String sourceName;
  final DirectiveRegistry registry;

  static const String implicitEntryLabel = '__start';

  late ScriptNode _script;
  LabelNode? _currentLabel;

  ScriptNode parse() {
    _script = ScriptNode(sourceName: sourceName);
    while (!isAtEnd) {
      skipNewlines();
      if (isAtEnd) break;

      if (check(TokenType.labelMarker)) {
        _parseLabelDeclaration();
        continue;
      }

      final int before = position;
      final Statement? statement = _parseStatement();
      if (statement != null) {
        _target.statements.add(statement);
      } else if (position == before) {
        advance(); // never stall
      }
    }
    return _script;
  }

  LabelNode get _target {
    if (_currentLabel != null) return _currentLabel!;
    final LabelNode implicit = LabelNode(
      name: implicitEntryLabel,
      span: SourceSpan(source: sourceName, line: 1, column: 1),
    );
    _script.labels.add(implicit);
    _currentLabel = implicit;
    return implicit;
  }

  void _parseLabelDeclaration() {
    final Token marker = advance(); // ::
    final StringBuffer name = StringBuffer();
    if (check(TokenType.string)) {
      name.write(advance().lexeme);
    } else {
      while (!atLineEnd &&
          (check(TokenType.identifier) ||
              check(TokenType.number) ||
              check(TokenType.at))) {
        final Token token = advance();
        if (token.type == TokenType.at) continue;
        name.write(token.lexeme);
      }
    }
    final String labelName = name.toString().trim();
    if (labelName.isEmpty) {
      diagnostics.error('Label declaration is missing a name.', marker.span);
      skipToLineEnd();
      return;
    }
    if (_script.labelNamed(labelName) != null) {
      diagnostics.warn('Duplicate label "$labelName".', marker.span);
    }
    final LabelNode label = LabelNode(name: labelName, span: marker.span);
    _script.labels.add(label);
    _currentLabel = label;
    skipToLineEnd();
  }

  // ── Statements ──────────────────────────────────────────────────────────

  Statement? _parseStatement() {
    skipNewlines();
    if (isAtEnd || check(TokenType.labelMarker)) return null;

    if (!check(TokenType.at)) {
      // Stray content (usually a choice option that lost its `@choice`).
      diagnostics.warn(
        'Ignored unexpected "${current.lexeme}" outside of a directive.',
        current.span,
      );
      skipToLineEnd();
      return null;
    }

    final Token at = advance();
    if (!check(TokenType.identifier)) {
      diagnostics.error('Expected a directive name after "@".', at.span);
      skipToLineEnd();
      return null;
    }
    final Token nameToken = advance();
    final String name = registry.canonical(nameToken.lexeme);
    final SourceSpan span = at.span;

    switch (name) {
      case 'goto':
        return _parseGoto(span, isCall: false);
      case 'call':
        return _parseGoto(span, isCall: true);
      case 'return':
        _consumeLineEnd();
        return ReturnStatement(span);
      case 'end':
        return _parseHalt(span);
      case 'include':
        return _parseInclude(span);
      case 'label':
        return _parseInlineLabel(span);
      case 'if':
        return _parseIf(span);
      case 'switch':
        return _parseSwitch(span);
      case 'while':
        return _parseWhile(span);
      case 'repeat':
        return _parseRepeat(span);
      case 'for':
        return _parseFor(span);
      case 'break':
        _consumeLineEnd();
        return LoopControlStatement(true, span);
      case 'continue':
        _consumeLineEnd();
        return LoopControlStatement(false, span);
      case 'choice':
        return _parseChoice(span);
      case 'on':
        return _parseEventHandler(span);
      case 'chance':
        return _parseChance(span);
      case 'set':
        return _parseAssignment(span, AssignmentOperator.assign);
      case 'add':
        return _parseAssignment(span, AssignmentOperator.add);
      case 'subtract':
        return _parseAssignment(span, AssignmentOperator.subtract);
      case 'elseif':
      case 'else':
      case 'endif':
      case 'endswitch':
      case 'endwhile':
      case 'endrepeat':
      case 'endfor':
      case 'endchoice':
      case 'endon':
      case 'case':
      case 'default':
        diagnostics.warn('Unmatched "@$name".', span);
        skipToLineEnd();
        return null;
      default:
        return _parseGenericCommand(name, nameToken, span);
    }
  }

  Statement _parseGenericCommand(
    String name,
    Token nameToken,
    SourceSpan span,
  ) {
    final ArgumentList arguments = _parseArguments(name);
    if (!registry.isKnown(name)) {
      diagnostics.warn(
        'Unknown directive "@$name" — it will be dispatched dynamically.',
        span,
      );
    }
    final DirectiveSpec? spec = registry.lookup(name);
    if (spec != null && arguments.positional.length < spec.minPositional) {
      diagnostics.error(
        '@$name expects at least ${spec.minPositional} argument(s).',
        span,
      );
    }
    if (spec?.category == DirectiveCategory.metadata &&
        arguments.positional.isNotEmpty) {
      _script.metadata[name] = arguments.positional.first;
    }
    return CommandStatement(name: name, arguments: arguments, span: span);
  }

  Statement _parseGoto(SourceSpan span, {required bool isCall}) {
    final String target = _parseLabelReference();
    _consumeLineEnd();
    if (target.isEmpty) {
      diagnostics.error('@${isCall ? 'call' : 'goto'} needs a label.', span);
    }
    return GotoStatement(target: target, span: span, isCall: isCall);
  }

  Statement _parseHalt(SourceSpan span) {
    Expression? reason;
    if (!atLineEnd) reason = _parseArgumentValue();
    _consumeLineEnd();
    return HaltStatement(span, reason: reason);
  }

  Statement? _parseInclude(SourceSpan span) {
    final ArgumentList arguments = _parseArguments('include');
    final Expression? first = arguments.positionalAt(0);
    if (first is LiteralExpression) {
      _script.includes.add(first.value.asString);
    } else {
      diagnostics.error('@include expects a literal file name.', span);
    }
    return CommandStatement(name: 'include', arguments: arguments, span: span);
  }

  Statement? _parseInlineLabel(SourceSpan span) {
    final String name = _parseLabelReference();
    _consumeLineEnd();
    if (name.isEmpty) return null;
    final LabelNode label = LabelNode(name: name, span: span);
    _script.labels.add(label);
    _currentLabel = label;
    return null;
  }

  Statement _parseAssignment(SourceSpan span, AssignmentOperator fallback) {
    if (!check(TokenType.identifier)) {
      diagnostics.error('Expected a variable name.', current.span);
      skipToLineEnd();
      return CommandStatement(
        name: 'debug',
        arguments: ArgumentList.empty,
        span: span,
      );
    }
    final String target = advance().lexeme.toLowerCase();
    AssignmentOperator op = fallback;
    Expression value;

    if (check(TokenType.assign)) {
      op = assignmentOperatorFromLexeme(advance().lexeme);
      value = atLineEnd
          ? const LiteralExpression(EngineValue.trueValue, SourceSpan.unknown)
          : parseExpression();
    } else if (atLineEnd) {
      // `@set some_flag` → truthy assignment.
      value = const LiteralExpression(
        EngineValue.trueValue,
        SourceSpan.unknown,
      );
      op = AssignmentOperator.assign;
    } else {
      value = parseExpression();
    }

    _consumeLineEnd();
    return AssignmentStatement(
      target: target,
      operator: op,
      value: value,
      span: span,
      namespace: _namespaceFor(target),
    );
  }

  VariableNamespace _namespaceFor(String target) {
    if (target == 'crystals' || target == 'wallet.crystals') {
      return VariableNamespace.wallet;
    }
    if (target.startsWith('trust_') ||
        target.startsWith('love_') ||
        target.startsWith('friendship_')) {
      return VariableNamespace.relationship;
    }
    return VariableNamespace.variable;
  }

  Statement _parseIf(SourceSpan span) {
    final List<ConditionalBranch> branches = <ConditionalBranch>[];
    Expression condition = parseExpression();
    _consumeLineEnd();

    const Set<String> terminators = <String>{'elseif', 'else', 'endif', 'end'};
    List<Statement> body = _parseBlock(terminators);
    branches.add(ConditionalBranch(condition, body));

    List<Statement> elseBody = const <Statement>[];

    while (true) {
      final String? directive = _peekDirectiveName();
      if (directive == 'elseif') {
        _consumeDirective();
        condition = parseExpression();
        _consumeLineEnd();
        body = _parseBlock(terminators);
        branches.add(ConditionalBranch(condition, body));
        continue;
      }
      if (directive == 'else') {
        _consumeDirective();
        // `@else if <cond>` behaves like `@elseif`.
        if (checkIdentifier('if')) {
          advance();
          condition = parseExpression();
          _consumeLineEnd();
          body = _parseBlock(terminators);
          branches.add(ConditionalBranch(condition, body));
          continue;
        }
        _consumeLineEnd();
        elseBody = _parseBlock(<String>{'endif', 'end'});
        continue;
      }
      break;
    }

    _consumeTerminator(<String>{'endif', 'end'}, '@if', span);
    return IfStatement(branches: branches, span: span, elseBody: elseBody);
  }

  Statement _parseSwitch(SourceSpan span) {
    final Expression subject = parseExpression();
    _consumeLineEnd();

    final List<SwitchCase> cases = <SwitchCase>[];
    List<Statement> defaultBody = const <Statement>[];
    const Set<String> terminators = <String>{
      'case',
      'default',
      'endswitch',
      'end',
    };

    // Skip anything before the first @case.
    _parseBlock(terminators);

    while (true) {
      final String? directive = _peekDirectiveName();
      if (directive == 'case') {
        _consumeDirective();
        final Expression match = _parseArgumentValue();
        _consumeLineEnd();
        cases.add(SwitchCase(match, _parseBlock(terminators)));
        continue;
      }
      if (directive == 'default') {
        _consumeDirective();
        _consumeLineEnd();
        defaultBody = _parseBlock(<String>{'case', 'endswitch', 'end'});
        continue;
      }
      break;
    }

    _consumeTerminator(<String>{'endswitch', 'end'}, '@switch', span);
    return SwitchStatement(
      subject: subject,
      cases: cases,
      span: span,
      defaultBody: defaultBody,
    );
  }

  Statement _parseWhile(SourceSpan span) {
    final Expression condition = parseExpression();
    _consumeLineEnd();
    final List<Statement> body = _parseBlock(<String>{'endwhile', 'end'});
    _consumeTerminator(<String>{'endwhile', 'end'}, '@while', span);
    return WhileStatement(condition: condition, body: body, span: span);
  }

  Statement _parseRepeat(SourceSpan span) {
    final Expression count = parseExpression();
    _consumeLineEnd();
    final List<Statement> body = _parseBlock(<String>{'endrepeat', 'end'});
    _consumeTerminator(<String>{'endrepeat', 'end'}, '@repeat', span);
    return RepeatStatement(count: count, body: body, span: span);
  }

  Statement _parseFor(SourceSpan span) {
    String variable = 'item';
    if (check(TokenType.identifier)) {
      variable = advance().lexeme.toLowerCase();
    }
    if (checkIdentifier('in')) advance();
    final Expression iterable = parseExpression();
    _consumeLineEnd();
    final List<Statement> body = _parseBlock(<String>{'endfor', 'end'});
    _consumeTerminator(<String>{'endfor', 'end'}, '@for', span);
    return ForStatement(
      variable: variable,
      iterable: iterable,
      body: body,
      span: span,
    );
  }

  /// `@chance 30 -> @label` or a `@chance 30 … @end` block.
  Statement _parseChance(SourceSpan span) {
    final Expression probability = _parseArgumentValue();
    final Expression condition = BinaryExpression(
      '<=',
      CallExpression('random', <Expression>[
        const LiteralExpression(EngineValue.zero, SourceSpan.unknown),
        const LiteralExpression(EngineValue.number(100), SourceSpan.unknown),
      ], span),
      probability,
      span,
    );

    if (check(TokenType.arrow)) {
      advance();
      final String target = _parseLabelReference();
      _consumeLineEnd();
      return IfStatement(
        branches: <ConditionalBranch>[
          ConditionalBranch(condition, <Statement>[
            GotoStatement(target: target, span: span),
          ]),
        ],
        span: span,
      );
    }

    _consumeLineEnd();
    final List<Statement> body = _parseBlock(<String>{
      'endchance',
      'else',
      'end',
    });
    List<Statement> elseBody = const <Statement>[];
    if (_peekDirectiveName() == 'else') {
      _consumeDirective();
      _consumeLineEnd();
      elseBody = _parseBlock(<String>{'endchance', 'end'});
    }
    _consumeTerminator(<String>{'endchance', 'end'}, '@chance', span);
    return IfStatement(
      branches: <ConditionalBranch>[ConditionalBranch(condition, body)],
      span: span,
      elseBody: elseBody,
    );
  }

  Statement _parseEventHandler(SourceSpan span) {
    final Expression nameExpr = _parseArgumentValue();
    bool once = false;
    while (!atLineEnd) {
      if (checkIdentifier('once')) {
        advance();
        once = true;
        continue;
      }
      advance();
    }
    _consumeLineEnd();
    final List<Statement> body = _parseBlock(<String>{'endon', 'end'});
    _consumeTerminator(<String>{'endon', 'end'}, '@on', span);
    final String event = nameExpr is LiteralExpression
        ? nameExpr.value.asString
        : nameExpr.toString();
    return EventHandlerStatement(
      event: event,
      body: body,
      span: span,
      once: once,
    );
  }

  // ── Choice blocks ───────────────────────────────────────────────────────

  Statement _parseChoice(SourceSpan span) {
    final ArgumentList arguments = _parseArguments('choice');
    final List<ChoiceOptionNode> options = <ChoiceOptionNode>[];

    while (true) {
      final int lookahead = skipNewlinesFrom(position);
      if (!_isOptionStartAt(lookahead)) break;
      position = lookahead;
      final ChoiceOptionNode? option = _parseChoiceOption();
      if (option == null) break;
      options.add(option);
    }

    if (_peekDirectiveName() == 'endchoice') {
      _consumeDirective();
      _consumeLineEnd();
    }

    if (options.isEmpty) {
      diagnostics.error('@choice block has no options.', span);
    }

    final Expression? defaultExpr = arguments.namedOrNull('default');
    return ChoiceStatement(
      options: options,
      span: span,
      prompt: arguments.namedOrNull('prompt') ?? arguments.positionalAt(0),
      timeout: arguments.namedOrNull('timeout'),
      defaultTarget: defaultExpr is LiteralExpression
          ? defaultExpr.value.asString
          : null,
      shuffle: arguments.hasNamed('shuffle'),
      style: arguments.namedOrNull('style') is LiteralExpression
          ? (arguments.namedOrNull('style')! as LiteralExpression)
                .value
                .asString
          : null,
    );
  }

  bool _isOptionStartAt(int index) {
    if (index >= tokens.length) return false;
    final Token token = tokens[index];
    switch (token.type) {
      case TokenType.string:
      case TokenType.gem:
      case TokenType.lock:
      case TokenType.clock:
        return true;
      case TokenType.arithmetic:
        // Bullet style: `- "text" -> @label`
        return token.lexeme == '-' &&
            index + 1 < tokens.length &&
            tokens[index + 1].type == TokenType.string;
      case TokenType.at:
        return index + 1 < tokens.length &&
            tokens[index + 1].type == TokenType.identifier &&
            tokens[index + 1].lexeme.toLowerCase() == 'option';
      default:
        return false;
    }
  }

  ChoiceOptionNode? _parseChoiceOption() {
    final SourceSpan span = current.span;
    ChoiceOptionKind kind = ChoiceOptionKind.normal;

    if (match(TokenType.gem)) {
      kind = ChoiceOptionKind.premium;
    } else if (match(TokenType.lock)) {
      kind = ChoiceOptionKind.locked;
    } else if (match(TokenType.clock)) {
      // Decorative timed marker.
    } else if (check(TokenType.arithmetic) && current.lexeme == '-') {
      advance();
    } else if (check(TokenType.at)) {
      advance(); // @
      advance(); // option
    }

    // Some scripts stack markers, e.g. `💎🔒 "text"`.
    while (check(TokenType.gem) ||
        check(TokenType.lock) ||
        check(TokenType.clock)) {
      if (check(TokenType.gem)) kind = ChoiceOptionKind.premium;
      if (check(TokenType.lock) && kind == ChoiceOptionKind.normal) {
        kind = ChoiceOptionKind.locked;
      }
      advance();
    }

    Expression label;
    if (check(TokenType.string)) {
      final Token token = advance();
      label = buildStringExpression(token.lexeme, token.span);
    } else {
      final StringBuffer buffer = StringBuffer();
      while (!atLineEnd && !check(TokenType.arrow)) {
        buffer.write('${advance().lexeme} ');
      }
      label = LiteralExpression(
        EngineValue.string(buffer.toString().trim()),
        span,
      );
    }

    Expression? cost;
    Expression? condition;
    Expression? requirement;
    Expression? hint;
    String? id;
    bool once = false;

    void parseModifiers() {
      while (!atLineEnd && !check(TokenType.arrow)) {
        if (check(TokenType.lparen)) {
          advance();
          if (check(TokenType.number)) {
            final Token number = advance();
            cost = LiteralExpression(
              EngineValue.of(number.value ?? 0),
              number.span,
            );
          }
          while (!check(TokenType.rparen) && !atLineEnd) {
            advance(); // "crystals" / "💎" / etc.
          }
          match(TokenType.rparen);
          continue;
        }
        if (checkIdentifier('if') || checkIdentifier('when')) {
          advance();
          condition = parseExpression();
          continue;
        }
        if (checkIdentifier('requires') || checkIdentifier('unlocked')) {
          advance();
          requirement = parseExpression();
          continue;
        }
        if (checkIdentifier('cost') || checkIdentifier('crystals')) {
          advance();
          cost = _parseArgumentValue();
          continue;
        }
        if (checkIdentifier('hint') || checkIdentifier('locked')) {
          advance();
          hint = _parseArgumentValue();
          continue;
        }
        if (checkIdentifier('id')) {
          advance();
          final Expression value = _parseArgumentValue();
          id = value is LiteralExpression ? value.value.asString : null;
          continue;
        }
        if (checkIdentifier('once')) {
          advance();
          once = true;
          continue;
        }
        advance();
      }
    }

    parseModifiers();

    String target = '';
    if (match(TokenType.arrow)) {
      target = _parseLabelReference();
      parseModifiers();
    } else {
      diagnostics.error('Choice option is missing "-> @label".', span);
    }

    _consumeLineEnd();

    if (target.isEmpty) return null;

    return ChoiceOptionNode(
      label: label,
      target: target,
      span: span,
      kind: kind,
      cost: cost,
      condition: condition,
      requirement: requirement,
      hint: hint,
      once: once,
      id: id,
    );
  }

  // ── Blocks & helpers ────────────────────────────────────────────────────

  List<Statement> _parseBlock(Set<String> terminators) {
    final List<Statement> statements = <Statement>[];
    while (true) {
      skipNewlines();
      if (isAtEnd || check(TokenType.labelMarker)) break;
      final String? directive = _peekDirectiveName();
      if (directive != null && terminators.contains(directive)) break;

      final int before = position;
      final Statement? statement = _parseStatement();
      if (statement != null) {
        statements.add(statement);
      } else if (position == before) {
        advance();
      }
    }
    return statements;
  }

  String? _peekDirectiveName() {
    if (!check(TokenType.at)) return null;
    final Token next = peek();
    if (next.type != TokenType.identifier) return null;
    return registry.canonical(next.lexeme);
  }

  void _consumeDirective() {
    advance(); // @
    advance(); // name
  }

  void _consumeTerminator(Set<String> names, String opener, SourceSpan span) {
    final String? directive = _peekDirectiveName();
    if (directive != null && names.contains(directive)) {
      _consumeDirective();
      _consumeLineEnd();
      return;
    }
    if (isAtEnd || check(TokenType.labelMarker)) {
      diagnostics.warn(
        '$opener block was closed implicitly (missing @${names.first}).',
        span,
      );
      return;
    }
    diagnostics.warn('Expected @${names.first} to close $opener.', span);
  }

  void _consumeLineEnd() {
    while (!atLineEnd) {
      advance();
    }
    if (check(TokenType.newline)) advance();
  }

  String _parseLabelReference() {
    match(TokenType.at);
    if (check(TokenType.string)) return advance().lexeme.trim();
    // Labels never contain whitespace, so a single token is always enough.
    if (check(TokenType.identifier) || check(TokenType.number)) {
      return advance().lexeme.trim();
    }
    return '';
  }

  // ── Arguments ───────────────────────────────────────────────────────────

  ArgumentList _parseArguments(String directive) {
    final List<Expression> positional = <Expression>[];
    final Map<String, Expression> named = <String, Expression>{};
    final StringBuffer raw = StringBuffer();

    while (!atLineEnd) {
      if (check(TokenType.identifier)) {
        final String key = current.lexeme.toLowerCase();
        final bool isNamed = registry.isNamedParameter(directive, key);
        final Token next = peek();
        final bool hasValue =
            next.type == TokenType.string ||
            next.type == TokenType.number ||
            next.type == TokenType.identifier ||
            next.type == TokenType.at ||
            next.type == TokenType.lbracket ||
            next.type == TokenType.lparen;
        if (isNamed && hasValue) {
          raw.write('$key ');
          advance();
          final Expression value = _parseArgumentValue();
          named[key] = value;
          raw.write('${_rawOf(value)} ');
          continue;
        }
        if (isNamed && !hasValue) {
          // Boolean switch, e.g. `shuffle`.
          advance();
          named[key] = const LiteralExpression(
            EngineValue.trueValue,
            SourceSpan.unknown,
          );
          raw.write('$key ');
          continue;
        }
      }
      final int before = position;
      final Expression value = _parseArgumentValue();
      if (position == before) {
        advance();
        continue;
      }
      positional.add(value);
      raw.write('${_rawOf(value)} ');
    }

    _consumeLineEnd();
    return ArgumentList(
      positional: positional,
      named: named,
      raw: raw.toString().trim(),
    );
  }

  String _rawOf(Expression expression) => expression is LiteralExpression
      ? expression.value.asString
      : expression.toString();

  /// Parses ONE argument term.
  ///
  /// Bare identifiers become string literals here (character ids, app names,
  /// statuses). Use `$name` or `{name}` to read a variable, or wrap the term in
  /// parentheses for a full expression.
  Expression _parseArgumentValue() {
    final Token token = current;
    switch (token.type) {
      case TokenType.string:
        advance();
        return buildStringExpression(token.lexeme, token.span);

      case TokenType.number:
        advance();
        return LiteralExpression(
          EngineValue.of(token.value ?? num.tryParse(token.lexeme) ?? 0),
          token.span,
        );

      case TokenType.arithmetic:
        if (token.lexeme == '-' && peek().type == TokenType.number) {
          advance();
          final Token number = advance();
          return LiteralExpression(
            EngineValue.number(-(number.value as num? ?? 0)),
            token.span,
          );
        }
        advance();
        return LiteralExpression(EngineValue.string(token.lexeme), token.span);

      case TokenType.lparen:
        advance();
        final Expression inner = parseExpression();
        match(TokenType.rparen);
        return inner;

      case TokenType.lbracket:
        advance();
        final List<Expression> items = <Expression>[];
        while (!check(TokenType.rbracket) && !atLineEnd) {
          items.add(_parseArgumentValue());
          match(TokenType.comma);
        }
        match(TokenType.rbracket);
        return ListExpression(items, token.span);

      case TokenType.at:
        advance();
        if (check(TokenType.identifier) || check(TokenType.number)) {
          final Token name = advance();
          return LiteralExpression(EngineValue.string(name.lexeme), token.span);
        }
        return const LiteralExpression(
          EngineValue.emptyString,
          SourceSpan.unknown,
        );

      case TokenType.identifier:
        advance();
        final String lexeme = token.lexeme;
        if (lexeme.startsWith(r'$')) {
          return VariableExpression(
            lexeme.substring(1).toLowerCase(),
            token.span,
          );
        }
        final String lower = lexeme.toLowerCase();
        if (lower == 'true' || lower == 'yes') {
          return LiteralExpression(EngineValue.trueValue, token.span);
        }
        if (lower == 'false' || lower == 'no') {
          return LiteralExpression(EngineValue.falseValue, token.span);
        }
        return LiteralExpression(EngineValue.string(lexeme), token.span);

      default:
        advance();
        return LiteralExpression(EngineValue.string(token.lexeme), token.span);
    }
  }
}

/// Convenience helper used by the script loader and tests.
ScriptNode parseScript(
  String source, {
  String sourceName = '<memory>',
  DirectiveRegistry? registry,
  DiagnosticBag? into,
}) {
  final Parser parser = Parser.fromSource(
    source,
    sourceName: sourceName,
    registry: registry,
  );
  final ScriptNode script = parser.parse();
  into?.addAll(parser.diagnostics.all);
  return script;
}
