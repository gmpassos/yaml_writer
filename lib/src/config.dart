enum QuoteStyle {
  preferUnquoted,
  preferSingleQuote,
  preferDoubleQuote,
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

  const YamlWriterConfig({
    this.indentSize = 2,
    this.quoteStyle = QuoteStyle.preferSingleQuote,
  });

}