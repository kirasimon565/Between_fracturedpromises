import '../lexer/lexer.dart';
import '../lexer/source_span.dart';
import '../lexer/token.dart';
import '../variables/engine_value.dart';
import 'expression.dart';
import 'token_reader.dart';

/// Precedence-climbing expression parser mixed into the statement parser.
///
/// Grammar (lowest → highest):
///   or        := and ( ('||' | 'or') and )*
///   and       := equality ( ('&&' | 'and') equality )*
///   equality  := comparison ( ('==' | '!=') comparison )*
///   comparison:= additive ( ('>' | '>=' | '<' | '<=') additive )*
///   additive  := multiplicative ( ('+' | '-') multiplicative )*
///   multi     := unary ( ('*' | '/' | '%') unary )*
///   unary     := ('!' | 'not' | '-') unary | primary
///   primary   := number | string | list | call | variable | '(' or ')'
mixin ExpressionParsing on TokenReader {
  /// Sugar predicates: `flag x`, `item y`, `evidence z`, …
  static const Map<String, String> _predicateFunctions = <String, String>{
    'flag': 'has_flag',
    'item': 'has_item',
    'evidence': 'has_evidence',
    'objective': 'has_objective',
    'achievement': 'has_achievement',
    'app': 'has_app',
    'seen': 'has_seen',
    'visited': 'has_visited',
  };

  Expression parseExpression() => _parseOr();

  Expression _parseOr() {
    Expression left = _parseAnd();
    while (current.type == TokenType.logical &&
        (current.lexeme == '||' || current.lexeme == 'or')) {
      final Token op = advance();
      final Expression right = _parseAnd();
      left = BinaryExpression(op.lexeme, left, right, op.span);
    }
    return left;
  }

  Expression _parseAnd() {
    Expression left = _parseEquality();
    while (current.type == TokenType.logical &&
        (current.lexeme == '&&' || current.lexeme == 'and')) {
      final Token op = advance();
      final Expression right = _parseEquality();
      left = BinaryExpression(op.lexeme, left, right, op.span);
    }
    return left;
  }

  Expression _parseEquality() {
    Expression left = _parseComparison();
    while (current.type == TokenType.comparison &&
        (current.lexeme == '==' || current.lexeme == '!=')) {
      final Token op = advance();
      final Expression right = _parseComparison();
      left = BinaryExpression(op.lexeme, left, right, op.span);
    }
    // `is` / `equals` word forms.
    while (checkIdentifier('is') || checkIdentifier('equals')) {
      final Token op = advance();
      final Expression right = _parseComparison();
      left = BinaryExpression('==', left, right, op.span);
    }
    return left;
  }

  Expression _parseComparison() {
    Expression left = _parseAdditive();
    while (current.type == TokenType.comparison &&
        current.lexeme != '==' &&
        current.lexeme != '!=') {
      final Token op = advance();
      final Expression right = _parseAdditive();
      left = BinaryExpression(op.lexeme, left, right, op.span);
    }
    return left;
  }

  Expression _parseAdditive() {
    Expression left = _parseMultiplicative();
    while (current.type == TokenType.arithmetic &&
        (current.lexeme == '+' || current.lexeme == '-')) {
      final Token op = advance();
      final Expression right = _parseMultiplicative();
      left = BinaryExpression(op.lexeme, left, right, op.span);
    }
    return left;
  }

  Expression _parseMultiplicative() {
    Expression left = _parseUnary();
    while (current.type == TokenType.arithmetic &&
        (current.lexeme == '*' ||
            current.lexeme == '/' ||
            current.lexeme == '%')) {
      final Token op = advance();
      final Expression right = _parseUnary();
      left = BinaryExpression(op.lexeme, left, right, op.span);
    }
    return left;
  }

  Expression _parseUnary() {
    if ((current.type == TokenType.logical &&
            (current.lexeme == '!' || current.lexeme == 'not')) ||
        (current.type == TokenType.arithmetic && current.lexeme == '-')) {
      final Token op = advance();
      final Expression operand = _parseUnary();
      return UnaryExpression(
        op.lexeme == 'not' ? '!' : op.lexeme,
        operand,
        op.span,
      );
    }
    return _parsePrimary();
  }

  Expression _parsePrimary() {
    final Token token = current;
    switch (token.type) {
      case TokenType.number:
        advance();
        return LiteralExpression(
          EngineValue.of(token.value ?? num.tryParse(token.lexeme) ?? 0),
          token.span,
        );

      case TokenType.string:
        advance();
        return buildStringExpression(token.lexeme, token.span);

      case TokenType.lparen:
        advance();
        final Expression inner = parseExpression();
        if (!match(TokenType.rparen)) {
          diagnostics.warn('Missing closing ")".', current.span);
        }
        return inner;

      case TokenType.lbracket:
        advance();
        final List<Expression> items = <Expression>[];
        while (!check(TokenType.rbracket) && !atLineEnd) {
          items.add(parseExpression());
          if (!match(TokenType.comma)) break;
        }
        match(TokenType.rbracket);
        return ListExpression(items, token.span);

      case TokenType.at:
        // `@label` used as a value (e.g. `default @scene_x`).
        advance();
        if (check(TokenType.identifier)) {
          final Token name = advance();
          return LiteralExpression(EngineValue.string(name.lexeme), token.span);
        }
        return LiteralExpression(EngineValue.emptyString, token.span);

      case TokenType.identifier:
        return _parseIdentifierExpression(token);

      default:
        // Unexpected token — consume it so the parser always makes progress.
        advance();
        return LiteralExpression(EngineValue.nullValue, token.span);
    }
  }

  Expression _parseIdentifierExpression(Token token) {
    final String lower = token.lexeme.toLowerCase();

    // Literals.
    if (lower == 'true' || lower == 'yes' || lower == 'on') {
      advance();
      return LiteralExpression(EngineValue.trueValue, token.span);
    }
    if (lower == 'false' || lower == 'no' || lower == 'off') {
      advance();
      return LiteralExpression(EngineValue.falseValue, token.span);
    }
    if (lower == 'null' || lower == 'none' || lower == 'nil') {
      advance();
      return LiteralExpression(EngineValue.nullValue, token.span);
    }

    // Predicate sugar: `flag installed_makelove` → has_flag("installed_makelove")
    final String? predicate = _predicateFunctions[lower];
    if (predicate != null &&
        (peek().type == TokenType.identifier ||
            peek().type == TokenType.string)) {
      advance();
      final Token argument = advance();
      return CallExpression(predicate, <Expression>[
        LiteralExpression(EngineValue.string(argument.lexeme), argument.span),
      ], token.span);
    }

    advance();

    // Function call.
    if (check(TokenType.lparen)) {
      advance();
      final List<Expression> arguments = <Expression>[];
      while (!check(TokenType.rparen) && !atLineEnd) {
        arguments.add(parseExpression());
        if (!match(TokenType.comma)) break;
      }
      match(TokenType.rparen);
      return CallExpression(lower, arguments, token.span);
    }

    return VariableExpression(lower, token.span);
  }

  /// Turns `"Hello {player_name}, you have {crystals} crystals"` into an
  /// [InterpolatedStringExpression]. Plain strings stay literals.
  Expression buildStringExpression(String text, SourceSpan span) {
    if (!text.contains('{')) {
      return LiteralExpression(EngineValue.string(text), span);
    }
    final List<StringPart> parts = <StringPart>[];
    final StringBuffer literal = StringBuffer();
    int i = 0;
    while (i < text.length) {
      final String ch = text[i];
      if (ch == '{') {
        // `{{` escapes a literal brace.
        if (i + 1 < text.length && text[i + 1] == '{') {
          literal.write('{');
          i += 2;
          continue;
        }
        final int close = text.indexOf('}', i + 1);
        if (close == -1) {
          literal.write(ch);
          i++;
          continue;
        }
        final String inner = text.substring(i + 1, close).trim();
        if (literal.isNotEmpty) {
          parts.add(StringPart.text(literal.toString()));
          literal.clear();
        }
        parts.add(StringPart.expression(parseEmbeddedExpression(inner, span)));
        i = close + 1;
        continue;
      }
      literal.write(ch);
      i++;
    }
    if (literal.isNotEmpty) parts.add(StringPart.text(literal.toString()));
    if (parts.length == 1 && parts.first.isText) {
      return LiteralExpression(EngineValue.string(parts.first.text!), span);
    }
    return InterpolatedStringExpression(parts, span);
  }

  /// Parses a stand-alone expression source (used for interpolation).
  Expression parseEmbeddedExpression(String source, SourceSpan span) {
    if (source.isEmpty) {
      return LiteralExpression(EngineValue.emptyString, span);
    }
    final Lexer lexer = Lexer(source, sourceName: span.source);
    final List<Token> innerTokens = lexer.tokenize();
    final _EmbeddedExpressionParser parser = _EmbeddedExpressionParser(
      innerTokens,
    );
    final Expression expression = parser.parseExpression();
    diagnostics.addAll(parser.diagnostics.all);
    return expression;
  }
}

class _EmbeddedExpressionParser extends TokenReader with ExpressionParsing {
  _EmbeddedExpressionParser(super.tokens);
}
