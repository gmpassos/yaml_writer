/// Style of quotes to use for string serialization.
enum QuoteStyle {
  /// example: `'value'`.
  singleQuote("'"),

  /// example: `"value"`.
  doubleQuote('"'),;
  final String char;

  const QuoteStyle(this.char);
}

/// Configuration for [YamlWriter].
class YamlWriterConfig {
  /// The indentation size.
  /// Must be greater or equal to `1`.
  ///
  /// Defaults to `2`.
  final int indentSize;

  /// If `true`, it will allow unquoted strings.
  final QuoteStyle quoteStyle;

  /// If `true`, it will force quoting of strings.
  final bool forceQuotedString;

  const YamlWriterConfig({
    this.indentSize = 2,
    this.forceQuotedString = false,
    this.quoteStyle = QuoteStyle.singleQuote,
  });
}
