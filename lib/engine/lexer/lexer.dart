import '../diagnostics/diagnostic.dart';
import 'source_span.dart';
import 'token.dart';

/// Converts raw DSL text into a flat [Token] stream.
///
/// The language is line oriented, so newlines are emitted as real tokens; the
/// parser uses them as statement terminators. Comments (`#`, `//`) and blank
/// runs are collapsed by the parser, not here, because a blank line is
/// meaningful inside a `@choice` block (it closes it).
class Lexer {
  Lexer(this.source, {this.sourceName = '<memory>'});

  final String source;
  final String sourceName;

  final List<Token> _tokens = <Token>[];
  final DiagnosticBag diagnostics = DiagnosticBag();

  int _offset = 0;
  int _line = 1;
  int _column = 1;

  static const int _tab = 0x09;
  static const int _lf = 0x0A;
  static const int _cr = 0x0D;
  static const int _space = 0x20;

  List<Token> tokenize() {
    while (!_isAtEnd) {
      _scanToken();
    }
    // Guarantee a trailing newline so the parser can always flush a statement.
    if (_tokens.isNotEmpty && _tokens.last.type != TokenType.newline) {
      _add(TokenType.newline, '\n', _span(0));
    }
    _add(TokenType.eof, '', _span(0));
    return _tokens;
  }

  bool get _isAtEnd => _offset >= source.length;

  int get _current => _isAtEnd ? 0 : source.codeUnitAt(_offset);

  int _peek([int ahead = 1]) {
    final int index = _offset + ahead;
    if (index >= source.length) return 0;
    return source.codeUnitAt(index);
  }

  SourceSpan _span(int length) => SourceSpan(
    source: sourceName,
    line: _line,
    column: _column,
    length: length,
  );

  void _advance([int count = 1]) {
    for (int i = 0; i < count && !_isAtEnd; i++) {
      if (source.codeUnitAt(_offset) == _lf) {
        _line++;
        _column = 1;
      } else {
        _column++;
      }
      _offset++;
    }
  }

  void _add(TokenType type, String lexeme, SourceSpan span, [Object? value]) {
    _tokens.add(Token(type: type, lexeme: lexeme, span: span, value: value));
  }

  void _scanToken() {
    final int c = _current;

    // Whitespace (not newline).
    if (c == _space || c == _tab || c == _cr) {
      _advance();
      return;
    }

    // Newline.
    if (c == _lf) {
      final SourceSpan span = _span(1);
      _advance();
      _add(TokenType.newline, '\n', span);
      return;
    }

    // Comments: `#…`, `//…`. A `#` inside a string is handled by _string().
    if (c == 0x23 /* # */ || (c == 0x2F /* / */ && _peek() == 0x2F)) {
      while (!_isAtEnd && _current != _lf) {
        _advance();
      }
      return;
    }

    // Block comment /* … */
    if (c == 0x2F && _peek() == 0x2A) {
      _advance(2);
      while (!_isAtEnd && !(_current == 0x2A && _peek() == 0x2F)) {
        _advance();
      }
      if (!_isAtEnd) _advance(2);
      return;
    }

    // Label marker `::`
    if (c == 0x3A && _peek() == 0x3A) {
      final SourceSpan span = _span(2);
      _advance(2);
      _add(TokenType.labelMarker, '::', span);
      return;
    }

    // Arrow `->`
    if (c == 0x2D /* - */ && _peek() == 0x3E /* > */ ) {
      final SourceSpan span = _span(2);
      _advance(2);
      _add(TokenType.arrow, '->', span);
      return;
    }

    // String literal.
    if (c == 0x22 /* " */ || c == 0x27 /* ' */ ) {
      _string(c);
      return;
    }

    // Number (also handles negative literals like `-3` when not an arrow).
    if (_isDigit(c) ||
        (c == 0x2D && _isDigit(_peek()) && _numberCanStartHere())) {
      _number();
      return;
    }

    // Identifier / keyword.
    if (_isIdentifierStart(c)) {
      _identifier();
      return;
    }

    // Operators and punctuation.
    switch (c) {
      case 0x40: // @
        final SourceSpan span = _span(1);
        _advance();
        _add(TokenType.at, '@', span);
        return;
      case 0x28: // (
        _single(TokenType.lparen, '(');
        return;
      case 0x29: // )
        _single(TokenType.rparen, ')');
        return;
      case 0x5B: // [
        _single(TokenType.lbracket, '[');
        return;
      case 0x5D: // ]
        _single(TokenType.rbracket, ']');
        return;
      case 0x7B: // {
        _single(TokenType.lbrace, '{');
        return;
      case 0x7D: // }
        _single(TokenType.rbrace, '}');
        return;
      case 0x2C: // ,
        _single(TokenType.comma, ',');
        return;
      case 0x3A: // :
        _single(TokenType.colon, ':');
        return;
      case 0x3D: // = or ==
        if (_peek() == 0x3D) {
          _double(TokenType.comparison, '==');
        } else {
          _single(TokenType.assign, '=');
        }
        return;
      case 0x21: // ! or !=
        if (_peek() == 0x3D) {
          _double(TokenType.comparison, '!=');
        } else {
          _single(TokenType.logical, '!');
        }
        return;
      case 0x3E: // > or >=
        if (_peek() == 0x3D) {
          _double(TokenType.comparison, '>=');
        } else {
          _single(TokenType.comparison, '>');
        }
        return;
      case 0x3C: // < or <=
        if (_peek() == 0x3D) {
          _double(TokenType.comparison, '<=');
        } else {
          _single(TokenType.comparison, '<');
        }
        return;
      case 0x26: // &&
        if (_peek() == 0x26) {
          _double(TokenType.logical, '&&');
        } else {
          _single(TokenType.logical, '&');
        }
        return;
      case 0x7C: // ||
        if (_peek() == 0x7C) {
          _double(TokenType.logical, '||');
        } else {
          _single(TokenType.logical, '|');
        }
        return;
      case 0x2B: // + or +=
        if (_peek() == 0x3D) {
          _double(TokenType.assign, '+=');
        } else {
          _single(TokenType.arithmetic, '+');
        }
        return;
      case 0x2D: // - or -=
        if (_peek() == 0x3D) {
          _double(TokenType.assign, '-=');
        } else {
          _single(TokenType.arithmetic, '-');
        }
        return;
      case 0x2A: // * or *=
        if (_peek() == 0x3D) {
          _double(TokenType.assign, '*=');
        } else {
          _single(TokenType.arithmetic, '*');
        }
        return;
      case 0x2F: // / or /=
        if (_peek() == 0x3D) {
          _double(TokenType.assign, '/=');
        } else {
          _single(TokenType.arithmetic, '/');
        }
        return;
      case 0x25: // % or %=
        if (_peek() == 0x3D) {
          _double(TokenType.assign, '%=');
        } else {
          _single(TokenType.arithmetic, '%');
        }
        return;
    }

    // Emoji markers: 💎 (U+1F48E), 🔒 (U+1F512), ⏱ (U+23F1), ⏳ (U+23F3).
    final String rune = _readRune();
    switch (rune) {
      case '\u{1F48E}':
      case '\u{1F48F}':
        _add(TokenType.gem, rune, _span(rune.length));
        return;
      case '\u{1F512}':
      case '\u{1F510}':
        _add(TokenType.lock, rune, _span(rune.length));
        return;
      case '\u{23F1}':
      case '\u{23F3}':
      case '\u{231B}':
        _add(TokenType.clock, rune, _span(rune.length));
        return;
    }

    // Anything else becomes part of a bare identifier run so that decorative
    // characters in scripts never hard-fail the parse.
    if (rune.trim().isEmpty) return;
    _add(TokenType.identifier, rune, _span(rune.length));
  }

  String _readRune() {
    final int c = _current;
    // Surrogate pair.
    if (c >= 0xD800 && c <= 0xDBFF && !_isAtEnd) {
      final String rune = source.substring(
        _offset,
        (_offset + 2).clamp(0, source.length),
      );
      _advance(2);
      return rune;
    }
    final String rune = String.fromCharCode(c);
    _advance();
    return rune;
  }

  void _single(TokenType type, String lexeme) {
    final SourceSpan span = _span(1);
    _advance();
    _add(type, lexeme, span);
  }

  void _double(TokenType type, String lexeme) {
    final SourceSpan span = _span(2);
    _advance(2);
    _add(type, lexeme, span);
  }

  /// `_numberCanStartHere` prevents `x -1` from lexing as `x` `-1` when the
  /// previous token is a value (there it is a subtraction).
  bool _numberCanStartHere() {
    if (_tokens.isEmpty) return true;
    final Token last = _tokens.last;
    switch (last.type) {
      case TokenType.number:
      case TokenType.string:
      case TokenType.identifier:
      case TokenType.rparen:
        return false;
      default:
        return true;
    }
  }

  void _string(int quote) {
    final SourceSpan start = _span(0);
    _advance(); // opening quote
    final StringBuffer buffer = StringBuffer();
    while (!_isAtEnd && _current != quote) {
      if (_current == _lf) {
        diagnostics.error('Unterminated string literal.', start);
        break;
      }
      if (_current == 0x5C /* \ */ ) {
        _advance();
        switch (_current) {
          case 0x6E: // n
            buffer.write('\n');
            break;
          case 0x74: // t
            buffer.write('\t');
            break;
          case 0x72: // r
            buffer.write('\r');
            break;
          case 0x22:
            buffer.write('"');
            break;
          case 0x27:
            buffer.write("'");
            break;
          case 0x5C:
            buffer.write('\\');
            break;
          default:
            buffer.write(String.fromCharCode(_current));
        }
        _advance();
        continue;
      }
      buffer.write(String.fromCharCode(_current));
      _advance();
    }
    if (!_isAtEnd && _current == quote) {
      _advance(); // closing quote
    }
    final String text = buffer.toString();
    _add(TokenType.string, text, start.copyWith(length: text.length + 2), text);
  }

  void _number() {
    final SourceSpan start = _span(0);
    final StringBuffer buffer = StringBuffer();
    if (_current == 0x2D) {
      buffer.write('-');
      _advance();
    }
    while (_isDigit(_current)) {
      buffer.write(String.fromCharCode(_current));
      _advance();
    }
    if (_current == 0x2E /* . */ && _isDigit(_peek())) {
      buffer.write('.');
      _advance();
      while (_isDigit(_current)) {
        buffer.write(String.fromCharCode(_current));
        _advance();
      }
    }
    // A trailing `:` means this was a clock value such as `23:47`.
    if (_current == 0x3A && _isDigit(_peek())) {
      buffer.write(':');
      _advance();
      while (_isDigit(_current)) {
        buffer.write(String.fromCharCode(_current));
        _advance();
      }
      final String clock = buffer.toString();
      _add(TokenType.identifier, clock, start.copyWith(length: clock.length));
      return;
    }
    final String text = buffer.toString();
    _add(
      TokenType.number,
      text,
      start.copyWith(length: text.length),
      num.tryParse(text) ?? 0,
    );
  }

  void _identifier() {
    final SourceSpan start = _span(0);
    final StringBuffer buffer = StringBuffer();
    while (!_isAtEnd && _isIdentifierPart(_current)) {
      buffer.write(String.fromCharCode(_current));
      _advance();
    }
    final String text = buffer.toString();
    final String lower = text.toLowerCase();
    if (lower == 'and' || lower == 'or' || lower == 'not') {
      _add(TokenType.logical, lower, start.copyWith(length: text.length));
      return;
    }
    _add(TokenType.identifier, text, start.copyWith(length: text.length));
  }

  static bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

  static bool _isIdentifierStart(int c) =>
      (c >= 0x41 && c <= 0x5A) || // A-Z
      (c >= 0x61 && c <= 0x7A) || // a-z
      c == 0x5F || // _
      c == 0x24; // $

  static bool _isIdentifierPart(int c) =>
      _isIdentifierStart(c) ||
      _isDigit(c) ||
      c == 0x2E || // dotted paths: phone.battery
      c == 0x2D; // kebab ids inside bare words
}
