enum QuoteStyle {
  preferSingleQuote,
  preferDoubleQuote,
}

enum EmptyStringLiteral {
  singleQuote("''"),
  doubleQuote('""'),
  ;

  final String literal;

  const EmptyStringLiteral(this.literal);
}

class YamlWriterConfig {
  /// The indentation size.
  ///
  /// Must be greater or equal to `1`.
  ///
  /// Defaults to `2`.
  final int indentSize;

  /// If `true` it will allow unquoted strings.
  ///
  final QuoteStyle quoteStyle;

  /// If `true`, unquoted strings are preferred if it's capable
  final bool allowUnquotedStrings;

  final EmptyStringLiteral emptyStringLiteral;

  const YamlWriterConfig({
    this.indentSize = 2,
    this.allowUnquotedStrings = true,
    this.quoteStyle = QuoteStyle.preferSingleQuote,
    this.emptyStringLiteral = EmptyStringLiteral.singleQuote,
  });
}
