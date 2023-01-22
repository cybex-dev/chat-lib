import 'chat_entry.dart';

abstract class ChatDataItem<E> extends ChatEntry {
  final E payload;

  const ChatDataItem({
    required this.payload,
    required super.dateTime,
  });
}