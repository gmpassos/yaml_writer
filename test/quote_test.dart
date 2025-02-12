import 'package:test/test.dart';
import 'package:yaml_writer/src/node.dart';

void main() {
  group('Unquoted', () {
    test("simple text", () {
      expect(StringNode.isValidUnquotedString("foo"), equals(true));
      expect(StringNode.isValidUnquotedString("FOO"), equals(true));
      expect(StringNode.isValidUnquotedString("foo-bar"), equals(true));
      expect(StringNode.isValidUnquotedString("foo bar"), equals(true));
    });

    test("numbers", () {
      // numbers are invalid because yaml would consider them as numbers other than strings
      expect(StringNode.isValidUnquotedString("1"), equals(false));
      expect(StringNode.isValidUnquotedString("1.5"), equals(false));
      expect(StringNode.isValidUnquotedString("-1"), equals(false));
      expect(StringNode.isValidUnquotedString("-1.5"), equals(false));
    });

    test("i18n", () {
      // Good for translated strings
      expect(StringNode.isValidUnquotedString("Hello"), equals(true));
      expect(StringNode.isValidUnquotedString("你好"), equals(true));
      expect(StringNode.isValidUnquotedString("こんにちは"), equals(true));
      expect(StringNode.isValidUnquotedString("Bonjour"), equals(true));
    });

    test("at sign", () {
      expect(StringNode.isValidUnquotedString("@foo"), equals(false));
      expect(StringNode.isValidUnquotedString("foo@bar"), equals(true));
      expect(StringNode.isValidUnquotedString("foo @ bar"), equals(true));
    });

    test("question mark", () {
      expect(StringNode.isValidUnquotedString("?foo"), equals(true));
    });

    test("dash", () {
      expect(StringNode.isValidUnquotedString("-foo"), equals(true));
      expect(StringNode.isValidUnquotedString("-"), equals(false));
      expect(StringNode.isValidUnquotedString("- "), equals(false));
      expect(StringNode.isValidUnquotedString("foo-"), equals(true));
      expect(StringNode.isValidUnquotedString("foo-bar"), equals(true));
    });

    test("brackets", () {
      expect(StringNode.isValidUnquotedString(r"["), equals(false));
      expect(StringNode.isValidUnquotedString(r"{"), equals(false));
      expect(StringNode.isValidUnquotedString(r">"), equals(false));
      expect(StringNode.isValidUnquotedString(r"[ "), equals(false));
      expect(StringNode.isValidUnquotedString(r"{ "), equals(false));
      expect(StringNode.isValidUnquotedString(r"> "), equals(false));
      expect(StringNode.isValidUnquotedString(r"foo["), equals(true));
      expect(StringNode.isValidUnquotedString(r"foo{"), equals(true));
      expect(StringNode.isValidUnquotedString(r"foo>"), equals(true));
    });

    test("whitespace", () {
      expect(StringNode.isValidUnquotedString(" "), equals(false));
      expect(StringNode.isValidUnquotedString(" foo"), equals(false));
      expect(StringNode.isValidUnquotedString("foo "), equals(false));
      expect(StringNode.isValidUnquotedString("foo\nbar"), equals(false));
      expect(StringNode.isValidUnquotedString("foo\rbar"), equals(false));
      expect(StringNode.isValidUnquotedString("foo\tbar"), equals(false));
    });

    test("star", () {
      expect(StringNode.isValidUnquotedString("*foo"), equals(false));
      expect(StringNode.isValidUnquotedString("*"), equals(false));
      expect(StringNode.isValidUnquotedString("foo*"), equals(true));
      expect(StringNode.isValidUnquotedString("foo*bar"), equals(true));
    });

    test("ampersand", () {
      expect(StringNode.isValidUnquotedString("&foo"), equals(false));
      expect(StringNode.isValidUnquotedString("&"), equals(false));
      expect(StringNode.isValidUnquotedString("foo&"), equals(true));
      expect(StringNode.isValidUnquotedString("foo&bar"), equals(true));
    });

    test("comma", () {
      expect(StringNode.isValidUnquotedString(",foo"), equals(false));
      expect(StringNode.isValidUnquotedString(","), equals(false));
      expect(StringNode.isValidUnquotedString("foo,"), equals(true));
      expect(StringNode.isValidUnquotedString("foo,bar"), equals(true));
    });

    test("colon", () {
      expect(StringNode.isValidUnquotedString(":foo"), equals(true));
      expect(StringNode.isValidUnquotedString(":"), equals(false));
      expect(StringNode.isValidUnquotedString(": "), equals(false));
      expect(StringNode.isValidUnquotedString("foo:"), equals(true));
      expect(StringNode.isValidUnquotedString("foo:bar"), equals(true));
      expect(StringNode.isValidUnquotedString("foo: "), equals(false));
      expect(StringNode.isValidUnquotedString("foo: bar"), equals(false));
    });

    test("pipe", () {
      expect(StringNode.isValidUnquotedString("|foo"), equals(false));
      expect(StringNode.isValidUnquotedString("|"), equals(false));
      expect(StringNode.isValidUnquotedString("| foo"), equals(false));
      expect(StringNode.isValidUnquotedString("foo|"), equals(true));
      expect(StringNode.isValidUnquotedString("foo |"), equals(true));
    });
  });
}
