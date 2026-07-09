class SeatData {
  static const List<String> theaterRows = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
  ];

  static const int totalColumns = 15;

  static const List<String> defaultReservedSeats = [
    'C5',
    'C6',
    'D7',
    'D8',
    'E9',
    'E10',
    'F5',
    'F6',
  ];

  static bool isTeaterGangWay(int colIndex) {
    return colIndex == 3 || colIndex == 10;
  }
}
