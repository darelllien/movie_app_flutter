import 'movie.dart';
import 'cinema.dart';

class TransactionModel {
  final String id;
  final Movie movie;
  final Cinema cinema;
  final int ticketCount;
  final int pricePerTicket;
  final DateTime transactionDate;
  final String seatNumbers;

  TransactionModel({
    required this.id,
    required this.movie,
    required this.cinema,
    required this.ticketCount,
    required this.pricePerTicket,
    required this.transactionDate,
    required this.seatNumbers,
  });

  int get totalPrice => ticketCount * pricePerTicket;
}

class TransactionState {
  static final TransactionState _instance = TransactionState._internal();
  factory TransactionState() {
    return _instance;
  }

  TransactionState._internal();

  final List<TransactionModel> _history = [];
  List<TransactionModel> get history => List.unmodifiable(_history);

  void addTransaction(TransactionModel transaction) {
    _history.insert(0, transaction);
  }
}
