/// Русское склонение: 1 заметка / 2 заметки / 5 заметок.
String pluralize(int count, String one, String few, String many) {
  final mod100 = count % 100;
  if (mod100 >= 11 && mod100 <= 14) return many;

  final mod10 = count % 10;
  if (mod10 == 1) return one;
  if (mod10 >= 2 && mod10 <= 4) return few;
  return many;
}
