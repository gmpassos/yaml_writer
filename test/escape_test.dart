import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

String _parseYamlString(String text) {
  final result = loadYaml(text);
  return result as String;
}

void _check(YamlWriter writer, String text) {
  final written = writer.write(text);
  final parsedWritten = _parseYamlString(written);
  // print("-------------------");
  // print("Expected: $text");
  // print("Written: $written");
  // print("Parsed: $parsedWritten");
  expect(
    parsedWritten,
    equals(text),
  );
}

void main() {
  group('Escape characters', () {
    test("Check escape", () {
      void checkEscape(YamlWriter writer) {
        _check(writer, r'I have slash \ here');
        _check(writer, r'I have slash and double quote \" here');
        _check(
            writer, r"""I have both single quote ' and double quote " here""");
        _check(writer, "I have a table \t here");
      }

      checkEscape(YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.doubleQuote,
          forceQuotedString: true,
        ),
      ));

      checkEscape(YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      ));

      checkEscape(YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: false,
        ),
      ));

      checkEscape(YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.doubleQuote,
          forceQuotedString: false,
        ),
      ));
    });
  });
}
