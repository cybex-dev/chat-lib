import 'package:flutter/widgets.dart';
import 'package:collection/collection.dart';

import '../models/models.dart';

enum ScrollStatus {
  start,
  inbetween,
  end,
}

class ChatController {
  final List<ChatEntry> items = [];
  late final ValueNotifier<ScrollStatus> onScrollChanged;
  ScrollStatus _scrollPosition = ScrollStatus.start;
  late final ScrollController scrollController;

  ScrollStatus get scrollPosition => _scrollPosition;

  ChatController() {
    onScrollChanged = ValueNotifier<ScrollStatus>(_scrollPosition);
    scrollController = ScrollController();
    scrollController.addListener(_onItemScrollChange);
  }

  void dispose() {
    scrollController.removeListener(_onItemScrollChange);
    scrollController.dispose();
    onScrollChanged.dispose();
  }

  void _onItemScrollChange() {
    // print("Pixels: ${scrollController.position.pixels} min: ${scrollController.position.minScrollExtent} max: ${scrollController.position.maxScrollExtent}");

    ScrollStatus newStatus;
    if (!scrollController.position.atEdge) {
      newStatus = ScrollStatus.inbetween;
    } else {
      if (scrollController.position.pixels <= scrollController.position.minScrollExtent) {
        newStatus = ScrollStatus.start;
      } else {
        newStatus = ScrollStatus.end;
      }
    }

    if (newStatus == _scrollPosition) {
      return;
    }

    _scrollPosition = newStatus;
    onScrollChanged.value = _scrollPosition;
  }

  void scrollToEnd({bool animate = true, Duration duration = const Duration(milliseconds: 100)}) {
    if (!canScroll) {
      return;
    }
    if (animate) {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: duration, curve: Curves.easeInQuad);
    } else {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  void scrollToStart({bool animate = true, Duration duration = const Duration(milliseconds: 100)}) {
    if (canScroll) {
      return;
    }
    if (animate) {
      scrollController.animateTo(0, duration: duration, curve: Curves.easeInQuad);
    } else {
      scrollController.jumpTo(0);
    }
  }

  bool get canScroll => scrollController.positions.isNotEmpty;

  void updateItems(Iterable<ChatEntry> items) {
    this.items.clear();
    this.items.addAll(items);
  }
}