extension ListAddWith<E> on List<E> {
  List<E> addWith(E e) {
    final list = toList();
    list.add(e);
    return list;
  }
}