import 'source_span.dart';

/// The complete token vocabulary of the *Between* story language.
enum TokenType {
  /// `::` — introduces a label declaration.
  labelMarker,

  /// `@` — introduces a directive (command) or a label reference.
  at,

  /// Bare word: `message`, `ethan`, `online`, `true`, …
  identifier,

  /// `"quoted text"` (supports `\"`, `\n`, `\t`, `\\` escapes).
  string,

  /// Numeric literal, integer or double.
  number,

  /// `->` — choice/branch arrow.
  arrow,

  /// `💎` — premium (crystal) choice marker.
  gem,

  /// `🔒` — locked choice marker.
  lock,

  /// `⏱` / `⏳` — timed choice marker.
  clock,

  /// `(`
  lparen,

  /// `)`
  rparen,

  /// `[`
  lbracket,

  /// `]`
  rbracket,

  /// `{`
  lbrace,

  /// `}`
  rbrace,

  /// `,`
  comma,

  /// `:`
  colon,

  /// `=` `+=` `-=` `*=` `/=` `%=`
  assign,

  /// `==` `!=` `>` `>=` `<` `<=`
  comparison,

  /// `+` `-` `*` `/` `%`
  arithmetic,

  /// `&&` `||` `!` and their word forms `and` `or` `not`
  logical,

  /// End of a logical line — significant, the DSL is line oriented.
  newline,

  /// End of file.
  eof,
}

/// A single lexical unit produced by [Lexer].
class Token {
  const Token({
    required this.type,
    required this.lexeme,
    required this.span,
    this.value,
  });

  final TokenType type;

  /// Raw text as it appeared in the source (for strings: the *decoded* text).
  final String lexeme;

  /// Pre-parsed literal value for numbers.
  final Object? value;

  final SourceSpan span;

  bool get isNewline => type == TokenType.newline;
  bool get isEof => type == TokenType.eof;

  bool isIdentifier(String name) =>
      type == TokenType.identifier &&
      lexeme.toLowerCase() == name.toLowerCase();

  @override
  String toString() => '${type.name}(${lexeme.replaceAll('\n', r'\n')})';
}
