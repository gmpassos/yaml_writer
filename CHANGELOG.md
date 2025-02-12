## 2.1.0

- Refactored string quoting: enhanced the handling of unquoted strings.
- Resolved an issue where empty strings were not supported when using unquoted strings.
- Introduced `YamlWriter.config()` as a new constructor, along with the `YamlWriterConfig` class.

## 2.0.1

- Remove unnecessary trailing spaces from keys with values declared on a new line.

- test: ^1.25.8
- coverage: ^1.10.0

## 2.0.0

- Internals are reworked: now package is relying on a tree-like structure to improve maintainability and scalability.
- Fixed `indentSize` validation (only values >=1 are allowed).
- Resolved https://github.com/gmpassos/yaml_writer/issues/6:
```yaml
# BEFORE:
field:
  - 
    - 5
    - 2
  - 
    a: 3
    b: 6

# AFTER:
field:
  - - 5
    - 2
  - a: 3
    b: 6
```
- Update min Dart SDK version constraint from `2.12.0` to `3.0.0`
- Update `lints: ^2.0.1` to `lints: ^3.0.0`

BREAKING CHANGES:
- `YAMLWriter` renamed to `YamlWriter` ([Effective Dart reference](https://dart.dev/effective-dart/style#do-capitalize-acronyms-and-abbreviations-longer-than-two-letters-like-words)).
- Deprecated `identSize` property is removed. Use `indentSize` instead.
- `toEncodable` property is removed. Use constructor parameter instead (`YamlWriter#toEncodable`).


## 1.0.3

- `YAMLWriter`:
  - Added `allowUnquotedStrings`.
  - Rename `identSize` to `indentSize`.
  - Deprecate `identSize` field.
- lints: ^2.0.1
- test: ^1.22.0
- dependency_validator: ^3.2.2
- coverage: ^1.6.1

## 1.0.2

- Fixed serialization of an empty `List` to `[]`
- Updated GitHub CI.
- lints: ^2.0.0
- test: ^1.17.12
- dependency_validator: ^3.2.0
- coverage: ^1.1.0

## 1.0.1

- Improve `pubspec.yaml` description.
- Improve README.

## 1.0.0

- Initial version.
