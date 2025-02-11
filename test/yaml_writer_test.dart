import 'package:test/test.dart';
import 'package:yaml_writer/src/config.dart';
import 'package:yaml_writer/yaml_writer.dart';

void main() {
  group('YAMLWriter', () {
    setUp(() {
      print('---------------------------------------------');
    });

    test('unquoted string', () {
      var yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.preferUnquoted,
        ),
      );

      var tree = {
        'foo': {
          's1': 'Unquoted string with some@email and a /path/file.',
          's2': 'Quoted \$string.',
          's3': '@Quoted string.',
          's4': '-Quoted string.',
          's5': 'UnQuoted@string.',
          's6': 'UnQuoted-string.',
        }
      };

      var yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo:
  s1: Unquoted string with some@email and a /path/file.
  s2: 'Quoted $string.'
  s3: '@Quoted string.'
  s4: '-Quoted string.'
  s5: UnQuoted@string.
  s6: UnQuoted-string.
'''));

      expect(yamlWriter.convert(tree), equals(yaml));

      var yamlWriterQuoted = YamlWriter(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.preferSingleQuote,
        ),
      );

      var yaml2 = yamlWriterQuoted.write(tree);

      print(yaml2);

      expect(yaml2, equals(r'''
foo:
  s1: 'Unquoted string with some@email and a /path/file.'
  s2: 'Quoted $string.'
  s3: '@Quoted string.'
  s4: '-Quoted string.'
  s5: 'UnQuoted@string.'
  s6: 'UnQuoted-string.'
'''));
    });

    test("empty string", () {
      final yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          quoteStyle: QuoteStyle.preferSingleQuote,
        ),
      );

      final tree = {'foo': ""};

      final yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo: ''
'''));
    });

    test('indent 1', () {
      var yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          indentSize: 1,
        ),
      );

      var tree = {
        'foo': {
          's1': 'Some string',
          'bar': {
            's2': 'Another string',
          }
        }
      };

      var yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo:
 s1: 'Some string'
 bar:
  s2: 'Another string'
'''));
    });

    test('indent 5', () {
      var yamlWriter = YamlWriter(
        config: YamlWriterConfig(
          indentSize: 5,
        ),
      );

      var tree = {
        'foo': {
          's1': 'Some string',
        }
      };

      var yaml = yamlWriter.write(tree);

      print(yaml);

      expect(yaml, equals(r'''
foo:
     s1: 'Some string'
'''));
    });

    test('list', () {
      var yamlWriter = YamlWriter();

      var tree = [
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
      ];

      var yaml = yamlWriter.write(tree);

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
'''));

      expect(yamlWriter.convert(tree), equals(yaml));
    });

    test('empty list', () {
      var yamlWriter = YamlWriter();

      var tree = {
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

      var yaml = yamlWriter.write(tree);

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
      var yamlWriter = YamlWriter();

      var yaml = yamlWriter.write({
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
      var yamlWriter = YamlWriter();

      var yaml = yamlWriter.write({
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
    var yamlWriter = YamlWriter();

    var tree = {
      'type': '_Foo',
      'obj': _Foo(id: 123, name: 'Joe'),
    };

    var yaml = yamlWriter.write(tree);

    print(yaml);

    expect(yaml, equals(r'''
type: '_Foo'
obj:
  id: 123
  name: 'Joe'
'''));

    var yamlWriter2 = YamlWriter(
      toEncodable: (o) => o.name,
    );

    var yaml2 = yamlWriter2.write(tree);

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
