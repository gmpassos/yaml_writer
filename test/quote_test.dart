import 'package:test/test.dart';
import 'package:yaml_writer/src/node.dart';

void main() {
  group('Unquoted', () {
    test("simple text", () {
      expect(StringNode.isValidUnquotedString("foo"), isTrue);
      expect(StringNode.isValidUnquotedString("FOO"), isTrue);
      expect(StringNode.isValidUnquotedString("foo-bar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo bar"), isTrue);
    });

    test("numbers", () {
      // numbers are invalid because yaml would consider them as numbers other than strings
      expect(StringNode.isValidUnquotedString("1"), isFalse);
      expect(StringNode.isValidUnquotedString("1.5"), isFalse);
      expect(StringNode.isValidUnquotedString("-1"), isFalse);
      expect(StringNode.isValidUnquotedString("-1.5"), isFalse);
    });

    test("i18n", () {
      // Good for translated strings
      expect(StringNode.isValidUnquotedString("Hello"), isTrue);
      expect(StringNode.isValidUnquotedString("你好"), isTrue);
      expect(StringNode.isValidUnquotedString("こんにちは"), isTrue);
      expect(StringNode.isValidUnquotedString("Bonjour"), isTrue);
    });

    test("at sign", () {
      expect(StringNode.isValidUnquotedString("@foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo@bar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo @ bar"), isTrue);
    });

    test("question mark", () {
      expect(StringNode.isValidUnquotedString("?foo"), isTrue);
    });

    test("dash", () {
      expect(StringNode.isValidUnquotedString("-foo"), isTrue);
      expect(StringNode.isValidUnquotedString("-"), isFalse);
      expect(StringNode.isValidUnquotedString("- "), isFalse);
      expect(StringNode.isValidUnquotedString("foo-"), isTrue);
      expect(StringNode.isValidUnquotedString("foo-bar"), isTrue);
    });

    test("brackets", () {
      expect(StringNode.isValidUnquotedString("[foo"), isFalse);
      expect(StringNode.isValidUnquotedString("["), isFalse);
      expect(StringNode.isValidUnquotedString("[ foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo["), isTrue);
      expect(StringNode.isValidUnquotedString("foo ["), isTrue);

      expect(StringNode.isValidUnquotedString("{foo"), isFalse);
      expect(StringNode.isValidUnquotedString("{"), isFalse);
      expect(StringNode.isValidUnquotedString("{ foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo{"), isTrue);
      expect(StringNode.isValidUnquotedString("foo {"), isTrue);

      expect(StringNode.isValidUnquotedString(">foo"), isFalse);
      expect(StringNode.isValidUnquotedString(">"), isFalse);
      expect(StringNode.isValidUnquotedString("> foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo>"), isTrue);
      expect(StringNode.isValidUnquotedString("foo >"), isTrue);

      expect(StringNode.isValidUnquotedString(">-foo"), isFalse);
      expect(StringNode.isValidUnquotedString(">-"), isFalse);
      expect(StringNode.isValidUnquotedString(">- foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo>-"), isTrue);
      expect(StringNode.isValidUnquotedString("foo >-"), isTrue);
    });

    test("whitespace", () {
      expect(StringNode.isValidUnquotedString(" "), isFalse);
      expect(StringNode.isValidUnquotedString(" foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo "), isFalse);
      expect(StringNode.isValidUnquotedString("foo\nbar"), isFalse);
      expect(StringNode.isValidUnquotedString("foo\n"), isFalse);
      expect(StringNode.isValidUnquotedString("foo\rbar"), isFalse);
      expect(StringNode.isValidUnquotedString("foo\r"), isFalse);
      expect(StringNode.isValidUnquotedString("foo\tbar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo\t"), isFalse);
    });

    test("star", () {
      expect(StringNode.isValidUnquotedString("*foo"), isFalse);
      expect(StringNode.isValidUnquotedString("*"), isFalse);
      expect(StringNode.isValidUnquotedString("foo*"), isTrue);
      expect(StringNode.isValidUnquotedString("foo*bar"), isTrue);
    });

    test("ampersand", () {
      expect(StringNode.isValidUnquotedString("&foo"), isFalse);
      expect(StringNode.isValidUnquotedString("&"), isFalse);
      expect(StringNode.isValidUnquotedString("foo&"), isTrue);
      expect(StringNode.isValidUnquotedString("foo&bar"), isTrue);
    });

    test("comma", () {
      expect(StringNode.isValidUnquotedString(",foo"), isFalse);
      expect(StringNode.isValidUnquotedString(","), isFalse);
      expect(StringNode.isValidUnquotedString("foo,"), isTrue);
      expect(StringNode.isValidUnquotedString("foo,bar"), isTrue);
    });

    test("colon", () {
      expect(StringNode.isValidUnquotedString(":foo"), isTrue);
      expect(StringNode.isValidUnquotedString(":"), isFalse);
      expect(StringNode.isValidUnquotedString(": "), isFalse);
      expect(StringNode.isValidUnquotedString("foo:"), isFalse);
      expect(StringNode.isValidUnquotedString("foo:bar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo: "), isFalse);
      expect(StringNode.isValidUnquotedString("foo: bar"), isFalse);
    });

    test("pipe", () {
      expect(StringNode.isValidUnquotedString("|foo"), isFalse);
      expect(StringNode.isValidUnquotedString("|"), isFalse);
      expect(StringNode.isValidUnquotedString("| foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo|"), isTrue);
      expect(StringNode.isValidUnquotedString("foo |"), isTrue);

      expect(StringNode.isValidUnquotedString("|-foo"), isFalse);
      expect(StringNode.isValidUnquotedString("|-"), isFalse);
      expect(StringNode.isValidUnquotedString("|- foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo|-"), isTrue);
      expect(StringNode.isValidUnquotedString("foo |-"), isTrue);
    });

    test("hash", () {
      expect(StringNode.isValidUnquotedString("#"), isFalse);
      expect(StringNode.isValidUnquotedString("#foo"), isFalse);
      expect(StringNode.isValidUnquotedString("# foo"), isFalse);
      expect(StringNode.isValidUnquotedString("foo#"), isTrue);
      expect(StringNode.isValidUnquotedString("foo #"), isFalse);
      expect(StringNode.isValidUnquotedString("foo #bar"), isFalse);
      expect(StringNode.isValidUnquotedString("foo # bar"), isFalse);
      expect(StringNode.isValidUnquotedString("foo# bar"), isTrue);
    });

    test("percentage", () {
      expect(StringNode.isValidUnquotedString("%foo"), isFalse);
      expect(StringNode.isValidUnquotedString("%"), isFalse);
      expect(StringNode.isValidUnquotedString("foo%"), isTrue);
      expect(StringNode.isValidUnquotedString("foo%bar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo% bar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo % bar"), isTrue);
      expect(StringNode.isValidUnquotedString("foo %bar"), isTrue);
    });

    test("builtin literal", () {
      expect(StringNode.isValidUnquotedString("null"), isFalse);
      expect(StringNode.isValidUnquotedString("true"), isFalse);
      expect(StringNode.isValidUnquotedString("false"), isFalse);
      expect(StringNode.isValidUnquotedString("~"), isFalse);
    });
  });
}
