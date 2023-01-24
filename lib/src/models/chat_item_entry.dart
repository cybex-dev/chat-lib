import 'chat_data_item.dart';
import 'chat_entry.dart';

class ChatMessageEntry<E, R> extends ChatDataItem<E> {
  final Iterable<R>? imageAttachments;
  const ChatMessageEntry({
    required super.payload,
    required super.dateTime,
    this.imageAttachments,
  });
}

class ChatDateEntry extends ChatEntry {
  const ChatDateEntry({
    required super.dateTime,
  });
}

enum CallEntryType {
  declined,
  missed,
  started,
  ended,
}

class ChatCallEntry<E> extends ChatDataItem<E> {
  final CallEntryType type;

  const ChatCallEntry({
    required this.type,
    required super.payload,
    required super.dateTime,
  });
}