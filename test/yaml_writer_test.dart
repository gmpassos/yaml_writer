import 'package:test/test.dart';
import 'package:yaml_writer/yaml_writer.dart';

void main() {
  group('YAMLWriter', () {
    test('unquoted string', () {
      final yamlWriterUnquoted = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: false,
        ),
      );

      final tree = {
        'foo': {
          's1': 'Unquoted string with some@email and a /path/file.',
          's2': 'Unquoted \$string.',
          's3': '@Quoted string.',
          's4': '-Unquoted string.',
          's5': 'Unquoted@string.',
          's6': 'Unquoted-string.',
        }
      };

      expect(yamlWriterUnquoted.write(tree), equals(r'''
foo:
  s1: Unquoted string with some@email and a /path/file.
  s2: Unquoted $string.
  s3: '@Quoted string.'
  s4: -Unquoted string.
  s5: Unquoted@string.
  s6: Unquoted-string.
'''));

      final yamlWriterForceQuotedSingle = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );

      expect(yamlWriterForceQuotedSingle.write(tree), equals(r'''
foo:
  s1: 'Unquoted string with some@email and a /path/file.'
  s2: 'Unquoted $string.'
  s3: '@Quoted string.'
  s4: '-Unquoted string.'
  s5: 'Unquoted@string.'
  s6: 'Unquoted-string.'
'''));

      final yamlWriterForceQuotedDouble = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.doubleQuote,
          forceQuotedString: true,
        ),
      );

      expect(yamlWriterForceQuotedDouble.write(tree), equals(r'''
foo:
  s1: "Unquoted string with some@email and a /path/file."
  s2: "Unquoted $string."
  s3: "@Quoted string."
  s4: "-Unquoted string."
  s5: "Unquoted@string."
  s6: "Unquoted-string."
'''));
    });

    test("including both single and double quote", () {
      final writerSingleQuote = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );

      final tree = {
        "foo": {
          "s1": """Single quote ' and double quote " in string.""",
        }
      };

      expect(writerSingleQuote.write(tree), equals("""
foo:
  s1: 'Single quote '' and double quote " in string.'
"""));

      final writerDoubleQuote = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.doubleQuote,
          forceQuotedString: true,
        ),
      );

      expect(writerDoubleQuote.write(tree), equals("""
foo:
  s1: "Single quote ' and double quote \\" in string."
"""));
    });

    test("empty string", () {
      final singleQuote = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );
      expect(singleQuote.write({'foo': ""}), equals(r'''
foo: ''
'''));
      final doubleQuote = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.doubleQuote,
          forceQuotedString: true,
        ),
      );
      expect(doubleQuote.write({'foo': ''}), equals(r'''
foo: ""
'''));
    });

    test("numbers in unquoted string", () {
      final yamlWriter = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
        ),
      );

      final tree = {
        'int-in-string': "123",
        'int': 123,
        'double-in-string': ".18",
        'double-in-string2': "0.18",
        'double': .18,
      };

      final yaml = yamlWriter.write(tree);

      expect(yaml, equals(r'''
int-in-string: '123'
int: 123
double-in-string: '.18'
double-in-string2: '0.18'
double: 0.18
'''));
    });

    test('indent 1', () {
      final writer1 = YamlWriter.config(
        config: YamlWriterConfig(
          indentSize: 1,
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );
      expect(
          writer1.write({
            'foo': {
              's1': 'Some string',
              'bar': {
                's2': 'Another string',
              }
            }
          }),
          equals(r'''
foo:
 s1: 'Some string'
 bar:
  s2: 'Another string'
'''));

      final writer5 = YamlWriter.config(
        config: YamlWriterConfig(
          indentSize: 5,
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );

      expect(
          writer5.write({
            'foo': {
              's1': 'Some string',
            }
          }),
          equals(r'''
foo:
     s1: 'Some string'
'''));
    });

    test('list', () {
      final yamlWriter = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );

      final tree = [
        1,
        10.20,
        true,
        'x y z',
        null,
        '"quote"',
        "it's",
        '"mixed"\'s',
        'l1\nl2',
        false,
        'l1\nl2\nl3\n',
        'end',
        """ this string contains both single quote(') and double quote("). """,
      ];

      final yaml = yamlWriter.write(tree);

      expect(yaml, equals(r'''
- 1
- 10.2
- true
- 'x y z'
- null
- '"quote"'
- 'it''s'
- '"mixed"''s'
- |-
  l1
  l2
- false
- |
  l1
  l2
  l3
- 'end'
- ' this string contains both single quote('') and double quote("). '
'''));

      expect(yamlWriter.convert(tree), equals(yaml));
    });

    test('empty list', () {
      final yamlWriter = YamlWriter.config(
          config: YamlWriterConfig(
        forceQuotedString: true,
      ));

      final tree = {
        'emptyList': [],
        'objectWithEmptyList': {
          'emptyList': [],
        },
        'nestedList': [
          [],
          [5],
        ],
        'someValue': 5,
      };

      final yaml = yamlWriter.write(tree);

      expect(yaml, equals(r'''
emptyList: []
objectWithEmptyList:
  emptyList: []
nestedList:
  - []
  - - 5
someValue: 5
'''));

      expect(yamlWriter.convert(tree), equals(yaml));
    });

    test('map', () {
      final yamlWriter = YamlWriter.config(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.singleQuote,
          forceQuotedString: true,
        ),
      );

      final yaml = yamlWriter.write({
        'a': 1,
        'b': 10.20,
        'c': true,
        'd': 'x y z',
        'e': '"quote"',
        'f': "it's",
        'g': '"mixed"\'s',
        'h': 'l1\nl2',
        'i': false,
        'j': 'l1\nl2\nl3\n',
        'k': 'end',
        'l': {}
      });

      expect(yaml, equals(r'''
a: 1
b: 10.2
c: true
d: 'x y z'
e: '"quote"'
f: 'it''s'
g: '"mixed"''s'
h: |-
  l1
  l2
i: false
j: |
  l1
  l2
  l3
k: 'end'
l: {}
'''));
    });

    test('mixed', () {
      final yamlWriter = YamlWriter.config(
        config: YamlWriterConfig(
          forceQuotedString: true,
        ),
      );

      final yaml = yamlWriter.write({
        'a': [1, 2, 3],
        'b': [10.20, 30.40],
        'c': {'ok': true, 'error': false},
        'd': {'x': 1, 'y': 2},
        'e': [
          {'id': 1, 'n': 10},
          {'id': 2, 'n': 20}
        ],
        'f': ['l1\nl2\nl3', 'l10\nl20\n'],
        'g': {'f1': 'l1\nl2\nl3', 'f2': 'l10\nl20\n'},
        'h': {},
        'i': {
          "x": {},
          "y": [1, 2, 3]
        }
      });

      expect(yaml, equals('''
a:
  - 1
  - 2
  - 3
b:
  - 10.2
  - 30.4
c:
  ok: true
  error: false
d:
  x: 1
  y: 2
e:
  - id: 1
    n: 10
  - id: 2
    n: 20
f:
  - |-
    l1
    l2
    l3
  - |
    l10
    l20
g:
  f1: |-
    l1
    l2
    l3
  f2: |
    l10
    l20
h: {}
i:
  x: {}
  y:
    - 1
    - 2
    - 3
'''));
    });
  });

  test('object', () {
    final yamlWriter = YamlWriter.config(
      config: YamlWriterConfig(
        quoteStyle: QuoteStyle.singleQuote,
        forceQuotedString: true,
      ),
    );

    final tree = {
      'type': '_Foo',
      'obj': _Foo(id: 123, name: 'Joe'),
    };

    final yaml = yamlWriter.write(tree);

    expect(yaml, equals(r'''
type: '_Foo'
obj:
  id: 123
  name: 'Joe'
'''));

    final yamlWriter2 = YamlWriter.config(
      config: YamlWriterConfig(
        forceQuotedString: true,
        quoteStyle: QuoteStyle.singleQuote,
      ),
      toEncodable: (o) => o.name,
    );

    final yaml2 = yamlWriter2.write(tree);

    expect(yaml2, equals(r'''
type: '_Foo'
obj: 'Joe'
'''));
  });
}

class _Foo {
  int? id;
  String? name;

  _Foo({this.id, this.name});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
      };
}
