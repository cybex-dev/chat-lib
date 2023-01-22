import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:collection/collection.dart';

import '../controller/controller.dart';
import '../models/models.dart';
import '../extensions/extensions.dart';

typedef ChatItemBuilder<E> = Widget Function(int index, E entry);

typedef ScrollPositionBuilder = Widget Function(ScrollStatus scrollPosition);

class Chat<E, R, C> extends StatefulWidget {
  final Iterable<ChatDataItem> chatEntries;
  final ChatItemBuilder<ChatMessageEntry<E, R>> messageBuilder;
  final ChatController controller;
  final ChatItemBuilder<ChatDateEntry>? dateBuilder;
  final ChatItemBuilder<ChatCallEntry<C>>? callEntryBuilder;

  final ScrollPositionBuilder? unreadBuilder;
  final ScrollPositionBuilder? scrollToEndBuilder;

  final WidgetBuilder? typingWidgetBuilder;

  final GestureTapCallback? onSubmitted;

  const Chat({
    super.key,
    required this.chatEntries,
    required this.messageBuilder,
    required this.controller,
    this.dateBuilder,
    this.callEntryBuilder,
    this.typingWidgetBuilder,
    this.unreadBuilder,
    this.onSubmitted,
    this.scrollToEndBuilder,
  });

  @override
  State<Chat<E, R, C>> createState() => _ChatState<E, R, C>();
}

class _ChatState<E, R, C> extends State<Chat<E, R, C>> {
  late final ChatController _controller;
  ScrollStatus _scrollPosition = ScrollStatus.start;

  final Map<DateTime, List<ChatEntry>> _entries = {};

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.onScrollChanged.addListener(_onScrollUpdated);
    _scrollPosition = _controller.scrollPosition;
    _updateEntries();
    SchedulerBinding.instance.scheduleFrameCallback((_) => _controller.scrollToEnd());
  }

  void _updateEntries() {
    _entries.clear();
    for (var e in widget.chatEntries) {
      final dayDate = DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day);
      _entries.update(
        dayDate,
            (v) => v.addWith(e).sortedBy((element) => element.dateTime),
        ifAbsent: () => [ChatDateEntry(dateTime: dayDate), e],
      );
    }
    _controller.updateItems(_entries.entries.sortedBy((element) => element.key).map((e) => e.value).flattened);
  }

  void _onScrollUpdated() {
    print("Scroll updated: ${_controller.scrollPosition}");
    setState(() {
      _scrollPosition = _controller.scrollPosition;
    });
  }

  @override
  void didUpdateWidget(covariant Chat<E, R, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatEntries != widget.chatEntries) {
      _updateEntries();
      if(_controller.scrollPosition == ScrollStatus.end) {
        SchedulerBinding.instance.scheduleFrameCallback((_) => _controller.scrollToEnd());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initialScrollIndex = (widget.typingWidgetBuilder != null) ? _controller.items.length : _controller.items.length - 1;

    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.bottomCenter,
      children: [
        // Messages builder
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
              child: Scrollbar(
                controller: _controller.scrollController,
                interactive: true,
                thickness: 6,
                child: ListView.separated(
                  cacheExtent: _controller.scrollController.positions.isEmpty ? null : _controller.scrollController.position.viewportDimension,
                  addAutomaticKeepAlives: true,
                  controller: _controller.scrollController,
                  physics: const ClampingScrollPhysics(),
                  itemCount: initialScrollIndex + 1,
                  itemBuilder: (context, index) {
                    if (index == initialScrollIndex) {
                      return widget.typingWidgetBuilder!(context);
                    }

                    final item = _controller.items[index];
                    if (item is ChatMessageEntry<E, R>) {
                      return widget.messageBuilder(index, item);
                    } else if (item is ChatDateEntry) {
                      return widget.dateBuilder?.call(index, item) ?? const SizedBox.shrink();
                    } else if (item is ChatDateEntry) {
                      final entry = item as ChatCallEntry<C>;
                      return widget.callEntryBuilder?.call(index, entry) ?? const SizedBox.shrink();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                ),
              ),
            );
          },
        ),

        // unread Builder
        if (widget.unreadBuilder != null)
          SizedBox(
            width: double.maxFinite,
            height: 50,
            // color: Colors.green,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.unreadBuilder!(_scrollPosition),
              ],
            ),
          ),

        // scrollToEnd builder
        if (widget.scrollToEndBuilder != null)
          SizedBox(
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.scrollToEndBuilder!(_scrollPosition),
              ],
            ),
          )
      ],
    );
  }
}
