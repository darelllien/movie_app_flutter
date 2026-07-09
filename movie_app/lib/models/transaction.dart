import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movie': movie.toMap(),
      'cinema': cinema.toMap(),
      'ticketCount': ticketCount,
      'pricePerTicket': pricePerTicket,
      'transactionDate': transactionDate.toIso8601String(),
      'seatNumbers': seatNumbers,
      'paymentMethod': paymentMethod,
      'isScanned': isScanned,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      movie: Movie.fromMap(map['movie']),
      cinema: Cinema.fromMap(map['cinema']),
      ticketCount: map['ticketCount'],
      pricePerTicket: map['pricePerTicket'],
      transactionDate: DateTime.parse(map['transactionDate']),
      seatNumbers: map['seatNumbers'],
      paymentMethod: map['paymentMethod'],
      isScanned: map['isScanned'] ?? false,
    );
  }
}

class TransactionState extends ChangeNotifier {
  static final TransactionState _instance = TransactionState._internal();
  factory TransactionState() {
    return _instance;
  }

  TransactionState._internal() {
    loadTransactions();
  }

  final List<TransactionModel> _history = [];

  List<TransactionModel> get history => _history;

  Future<void> saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(
        _history.map((tx) => tx.toMap()).toList(),
      );
      await prefs.setString('transaction_history', encodedData);
    } catch (e) {
      debugPrint("Gagal menyimpan transaksi: $e");
    }
  }

  Future<void> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encodedData = prefs.getString('transaction_history');

      if (encodedData != null) {
        final List<dynamic> decodedData = jsonDecode(encodedData);
        _history.clear();
        _history.addAll(
          decodedData.map((item) => TransactionModel.fromMap(item)).toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gagal memuat transaksi: $e");
    }
  }


  void addTransaction(TransactionModel transaction) {
    _history.insert(0, transaction);
    saveTransactions();
    notifyListeners();
  }

  void markAsScanned(String txId) {
    final index = _history.indexWhere((tx) => tx.id == txId);
    if (index != -1) {
      _history[index].isScanned = true;
      saveTransactions();
      notifyListeners();
    }
  }
}