enum QuoteStyle {
  preferUnquoted,
  preferSingleQuote,
  preferDoubleQuote,
}

enum EmptyStringLiteral {
  singleQuote("''"),
  doubleQuote('""'),
  verticalBar('|'),
  greatThan('>'),
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
  final QuoteStyle quoteStyle;

  final EmptyStringLiteral emptyStringLiteral;

  const YamlWriterConfig({
    this.indentSize = 2,
    this.quoteStyle = QuoteStyle.preferSingleQuote,
    this.emptyStringLiteral = EmptyStringLiteral.singleQuote,
  });
}
