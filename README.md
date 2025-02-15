# yaml_writer

[![pub package](https://img.shields.io/pub/v/yaml_writer.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/yaml_writer)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/yaml_writer)](https://app.codecov.io/gh/gmpassos/yaml_writer)
[![Dart CI](https://github.com/gmpassos/yaml_writer/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/gmpassos/yaml_writer/actions/workflows/dart.yml)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/yaml_writer?logo=git&logoColor=white)](https://github.com/gmpassos/yaml_writer/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/yaml_writer/latest?logo=git&logoColor=white)](https://github.com/gmpassos/yaml_writer/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/yaml_writer?logo=git&logoColor=white)](https://github.com/gmpassos/yaml_writer/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/yaml_writer?logo=github&logoColor=white)](https://github.com/gmpassos/yaml_writer/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/yaml_writer?logo=github&logoColor=white)](https://github.com/gmpassos/yaml_writer)
[![License](https://img.shields.io/github/license/gmpassos/yaml_writer?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/yaml_writer/blob/master/LICENSE)

A library to write YAML documents, supporting Object encoding and [dart:convert][dart_convert] [Converter][dart_converter].

[dart_convert]: https://api.dart.dev/stable/2.13.4/dart-convert/dart-convert-library.html
[dart_converter]: https://api.dart.dev/stable/2.13.4/dart-convert/Converter-class.html

## Usage

A simple usage example:

```dart
import 'package:yaml_writer/yaml_writer.dart';

void main() {
  final yamlWriter = YamlWriter();

  final yamlDoc = yamlWriter.write({
    'name': 'Joe',
    'ids': [10, 20, 30],
    'desc': 'This is\na multiline\ntext',
    'enabled': true,
  });

  print(yamlDoc);
}
```

OUTPUT:

```text
name: "Joe"
ids: 
  - 10
  - 20
  - 30
desc: |-
    This is
    a multiline
    text
enabled: true
```

## YAML Strings

The writer will try to encode strings using the best format depending on the text,
avoiding to escape `"` and using `|` for multiline texts.

## Encoding Objects

You can use `YAMLWriter.toEncodable` to convert an Object to an encodable version,
similar to what is done by [dart:convert][dart_convert] [JsonEncoder][json_encoder].

If `YAMLWriter.toEncodable` is not set, it will try to call `toJson()`.

[json_encoder]: https://api.dart.dev/stable/2.13.4/dart-convert/JsonEncoder-class.html

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/yaml_writer/issues


## Author

Graciliano M. Passos: [gmpassos@GitHub](https://github.com/gmpassos).

Liplum: [liplum@GitHub](https://github.com/liplum)


## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
