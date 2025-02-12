import 'package:test/test.dart';
import 'package:yaml_writer/src/node.dart';

void main() {
  group('YAMLWriter', () {
    test("simple text", () {
      expect(StringNode.isValidUnquotedString("foo"), equals(true));
      expect(StringNode.isValidUnquotedString("FOO"), equals(true));
      expect(StringNode.isValidUnquotedString("foo-bar"), equals(true));
      expect(StringNode.isValidUnquotedString("foo bar"), equals(true));
    });

    test("number", () {
      expect(StringNode.isValidUnquotedString("1"), equals(false));
      expect(StringNode.isValidUnquotedString("1.5"), equals(false));
    });

    test("i18n", () {
      expect(StringNode.isValidUnquotedString("Hello"), equals(true));
      expect(StringNode.isValidUnquotedString("你好"), equals(true));
      expect(StringNode.isValidUnquotedString("こんにちは"), equals(true));
      expect(StringNode.isValidUnquotedString("Bonjour"), equals(true));
    });

    test("starting", () {
      // starting with a at sign is invalid
      expect(StringNode.isValidUnquotedString("@foo"), equals(false));
      // dollar sign is valid
      expect(StringNode.isValidUnquotedString(r"$ $ $"), equals(true));
      // slash is valid
      expect(StringNode.isValidUnquotedString(r"///"), equals(true));
    });

    // TODO: Add more edge cases
  });
}
