import 'package:yaml_writer/yaml_writer.dart';

void main() {
  final yamlWriter = YamlWriter.config();

  final yamlDoc = yamlWriter.write({
    'name': 'Joe',
    'ids': [10, 20, 30],
    'desc': 'This is\na multiline\ntext',
    'enabled': true,
  });

  print(yamlDoc);
}

//---------------------
// OUTPUT:
//---------------------
// name: Joe
// ids:
//   - 10
//   - 20
//   - 30
// desc: |-
//     This is
//     a multiline
//     text
// enabled: true
//
