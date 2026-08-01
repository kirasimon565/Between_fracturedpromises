import '../diagnostics/diagnostic.dart';
import '../lexer/source_span.dart';
import '../lexer/token.dart';

/// Cursor over a token list, shared by the statement parser and the expression
/// parser (which is mixed into it).
abstract class TokenReader {
  TokenReader(this.tokens, {DiagnosticBag? diagnostics})
    : diagnostics = diagnostics ?? DiagnosticBag();

  final List<Token> tokens;
  final DiagnosticBag diagnostics;

  int position = 0;

  Token get current =>
      position < tokens.length ? tokens[position] : tokens.last;

  Token get previous => position > 0 ? tokens[position - 1] : tokens.first;

  Token peek([int ahead = 1]) {
    final int index = position + ahead;
    if (index >= tokens.length) return tokens.last;
    return tokens[index];
  }

  bool get isAtEnd => current.type == TokenType.eof;

  bool get atLineEnd =>
      current.type == TokenType.newline || current.type == TokenType.eof;

  SourceSpan get span => current.span;

  Token advance() {
    final Token token = current;
    if (!isAtEnd) position++;
    return token;
  }

  bool check(TokenType type) => current.type == type;

  bool checkNext(TokenType type) => peek().type == type;

  bool match(TokenType type) {
    if (!check(type)) return false;
    advance();
    return true;
  }

  bool matchIdentifier(String word) {
    if (current.type == TokenType.identifier &&
        current.lexeme.toLowerCase() == word.toLowerCase()) {
      advance();
      return true;
    }
    return false;
  }

  bool checkIdentifier(String word) =>
      current.type == TokenType.identifier &&
      current.lexeme.toLowerCase() == word.toLowerCase();

  Token? expect(TokenType type, String message) {
    if (check(type)) return advance();
    diagnostics.error(message, current.span);
    return null;
  }

  /// Consumes tokens up to and including the next newline.
  void skipToLineEnd() {
    while (!atLineEnd) {
      advance();
    }
    if (check(TokenType.newline)) advance();
  }

  /// Consumes a run of newlines.
  void skipNewlines() {
    while (check(TokenType.newline)) {
      advance();
    }
  }

  /// Index of the next non-newline token at or after [from].
  int skipNewlinesFrom(int from) {
    int index = from;
    while (index < tokens.length && tokens[index].type == TokenType.newline) {
      index++;
    }
    return index;
  }
}
