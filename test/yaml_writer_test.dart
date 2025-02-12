import 'package:test/test.dart';
import 'package:yaml_writer/src/config.dart';
import 'package:yaml_writer/yaml_writer.dart';

void main() {
  group('YAMLWriter', () {
    setUp(() {
      print('---------------------------------------------');
    });

    test('unquoted string', () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          allowUnquotedStrings: true,
        ),
      );

      final tree = {
        'foo': {
          's1': 'Unquoted string with some@email and a /path/file.',
          's2': 'Unquoted \$string.',
          's3': '@Quoted string.',
          's4': '-Quoted string.',
          's5': 'Unquoted@string.',
          's6': 'Unquoted-string.',
        }
      };

      final yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo:
  s1: Unquoted string with some@email and a /path/file.
  s2: Unquoted $string.
  s3: '@Quoted string.'
  s4: '-Quoted string.'
  s5: Unquoted@string.
  s6: Unquoted-string.
'''));

      expect(yamlWriter.convert(tree), equals(yaml));

      final yamlWriterQuoted = YamlWriter(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.preferSingleQuote,
          allowUnquotedStrings: false,
        ),
      );

      final yaml2 = yamlWriterQuoted.write(tree);

      print(yaml2);

      expect(yaml2, equals(r'''
foo:
  s1: 'Unquoted string with some@email and a /path/file.'
  s2: 'Unquoted $string.'
  s3: '@Quoted string.'
  s4: '-Quoted string.'
  s5: 'Unquoted@string.'
  s6: 'Unquoted-string.'
'''));
    });

    test("empty string", () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.preferSingleQuote,
          allowUnquotedStrings: false,
        ),
      );

      final tree = {'foo': ""};

      final yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo: ''
'''));
    });

    test("numbers in unquoted string", () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.preferSingleQuote,
        ),
      );

      final tree = {
        'int-to-string': "123",
        'int': 123,
        'double-to-string': "0.18",
        'double': 0.18,
      };

      final yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
int-to-string: '123'
int: 123
double-to-string: '0.18'
double: 0.18
'''));
    });

    test('indent 1', () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          indentSize: 1,
          allowUnquotedStrings: false,
        ),
      );

      final tree = {
        'foo': {
          's1': 'Some string',
          'bar': {
            's2': 'Another string',
          }
        }
      };

      final yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo:
 s1: 'Some string'
 bar:
  s2: 'Another string'
'''));
    });

    test('indent 5', () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          indentSize: 5,
          allowUnquotedStrings: false,
        ),
      );

      final tree = {
        'foo': {
          's1': 'Some string',
        }
      };

      final yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo:
     s1: 'Some string'
'''));
    });

    test('list', () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          allowUnquotedStrings: false,
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

      print(yaml);

      expect(yaml, equals(r'''
- 1
- 10.2
- true
- 'x y z'
- null
- '"quote"'
- "it's"
- "\"mixed\"'s"
- |-
  l1
  l2
- false
- |
  l1
  l2
  l3
- 'end'
- " this string contains both single quote(') and double quote(\"). "
'''));

      expect(yamlWriter.convert(tree), equals(yaml));
    });

    test('empty list', () {
      final yamlWriter = YamlWriter(
          config: YamlWriterConfig(
        allowUnquotedStrings: false,
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

      print(yaml);

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
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          allowUnquotedStrings: false,
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

      print(yaml);

      expect(yaml, equals(r'''
a: 1
b: 10.2
c: true
d: 'x y z'
e: '"quote"'
f: "it's"
g: "\"mixed\"'s"
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
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          allowUnquotedStrings: false,
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

      print(yaml);

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
    final yamlWriter = YamlWriter(
      config: YamlWriterConfig(
        allowUnquotedStrings: false,
      ),
    );

    final tree = {
      'type': '_Foo',
      'obj': _Foo(id: 123, name: 'Joe'),
    };

    final yaml = yamlWriter.write(tree);

    print(yaml);

    expect(yaml, equals(r'''
type: '_Foo'
obj:
  id: 123
  name: 'Joe'
'''));

    final yamlWriter2 = YamlWriter(
      config: YamlWriterConfig(
        allowUnquotedStrings: false,
      ),
      toEncodable: (o) => o.name,
    );

    final yaml2 = yamlWriter2.write(tree);

    print(yaml2);

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
