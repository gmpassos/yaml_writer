/// Style of quotes to use for string serialization.
enum QuoteStyle {
  /// Example: `'value'`.
  singleQuote("'"),

  /// Example: `"value"`.
  doubleQuote('"');

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

  /// The quote to be used for quoting strings.
  /// Defaults to [QuoteStyle.doubleQuote], because single quotes are often used as apostrophes.
  final QuoteStyle quoteStyle;

  /// If `true`, it will force quoting of strings.
  /// If `false`, strings could be left unquoted if possible.
  final bool forceQuotedString;

  const YamlWriterConfig({
    this.indentSize = 2,
    this.quoteStyle = QuoteStyle.doubleQuote,
    this.forceQuotedString = false,
  });
}
