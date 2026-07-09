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
  final String paymentMethod;
  bool isScanned;

  TransactionModel({
    required this.id,
    required this.movie,
    required this.cinema,
    required this.ticketCount,
    required this.pricePerTicket,
    required this.transactionDate,
    required this.seatNumbers,
    required this.paymentMethod,
    this.isScanned = false,
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

  List<TransactionModel> get history => _history;

  void addTransaction(TransactionModel transaction) {
    _history.insert(0, transaction);
  }

  void markAsScanned(String txId) {
    final index = _history.indexWhere((tx) => tx.id == txId);
    if (index != -1) {
      _history[index].isScanned = true;
    }
  }
}
