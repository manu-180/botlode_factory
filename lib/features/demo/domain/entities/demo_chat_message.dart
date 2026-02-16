/// Entidad de dominio pura para un mensaje de chat.
/// No contiene lógica de serialización.
class DemoChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const DemoChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  DemoChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
  }) {
    return DemoChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemoChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
