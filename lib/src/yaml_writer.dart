import 'dart:convert';

import 'package:yaml_writer/src/node.dart';

import 'config.dart';
import 'yaml_context.dart';

@Deprecated('Use YamlWriter.')
typedef YAMLWriter = YamlWriter;

/// YAML Writer.
class YamlWriter extends Converter<Object?, String> {
  static dynamic _defaultToEncodable(dynamic object) => object.toJson();

  final YamlWriterConfig config;

  /// Used to convert objects to an encodable version.
  final Object? Function(dynamic object) toEncodable;

  const YamlWriter({
    this.config = const YamlWriterConfig(),
    this.toEncodable = _defaultToEncodable,
  });

  /// Converts [input] to an YAML document as [String].
  ///
  /// This implements `dart:convert` [Converter].
  ///
  /// - Calls [write].
  @override
  String convert(Object? input) => write(input);

  /// Writes [object] to an YAML document as [String].
  String write(Object? object) {
    final node = _parseNode(object);
    final context = YamlContext(
      config: config,
    );
    final yaml = node.toYaml(context);
    return '${yaml.join('\n')}\n';
  }

  Node _parseNode(Object? object) {
    if (object == null) {
      return NullNode();
    } else if (object is num) {
      return NumNode(object);
    } else if (object is bool) {
      return BoolNode(object);
    } else if (object is String) {
      return StringNode(object);
    } else if (object is List) {
      return ListNode(object.map(_parseNode).toList());
    } else if (object is Map) {
      return MapNode(object.map((k, v) => MapEntry(k, _parseNode(v))));
    } else {
      return _parseNode(toEncodable(object));
    }
  }
}
