/// Style of quotes to use for string serialization.
enum QuoteStyle {
  /// Prefer single quotes: `'value'`.
  preferSingleQuote,

  /// Prefer double quotes: `"value"`.
  preferDoubleQuote,
}

/// The literal value representing an empty string.
enum EmptyStringLiteral {
  singleQuote("''"),
  doubleQuote('""'),
  ;

  final String literal;

  const EmptyStringLiteral(this.literal);
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

  /// The literal value representing an empty string when serialized.
  final EmptyStringLiteral emptyStringLiteral;

  const YamlWriterConfig({
    this.indentSize = 2,
    this.forceQuotedString = false,
    this.quoteStyle = QuoteStyle.preferSingleQuote,
    this.emptyStringLiteral = EmptyStringLiteral.singleQuote,
  });
}
