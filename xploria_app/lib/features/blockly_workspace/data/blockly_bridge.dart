import 'dart:convert';

class BlocklyBridgeMessage {
  final String type;
  final String pythonCode;
  final String xmlData;

  BlocklyBridgeMessage({
    required this.type,
    required this.pythonCode,
    required this.xmlData,
  });

  factory BlocklyBridgeMessage.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return BlocklyBridgeMessage(
      type: json['type'] ?? '',
      pythonCode: json['pythonCode'] ?? '',
      xmlData: json['xmlData'] ?? '',
    );
  }
}
