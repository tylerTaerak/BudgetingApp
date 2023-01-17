import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Transaction {
    final String name;
    final double amount;
    final String date;
    final List<String> categories;

    Transaction({
        required this.name,
        required this.amount,
        required this.date,
        required this.categories,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) {
        return Transaction(
            name: json['name'],
            amount: json['amount'],
            date: json['date'],
            categories: json['category']
        );
    }
}

List<Transaction> parseTransactions(String httpResp) {
    final Map<String, dynamic> parsed = jsonDecode(httpResp);

    var transactionsJson = parsed['latest_transactions'];
    List<Transaction> transactions = <Transaction>[];

    transactionsJson.forEach( (var tran) => transactions.add(Transaction.fromJson(tran)));

    return transactions;
}

/*
This is the scrollable list of transactions from all
accounts. The actual list of transactions will also be used to calculate
money spent and money earned for other information displays

The actual list of transactions will be handled by the backend
*/
class TransactionTable extends StatefulWidget {
    const TransactionTable({super.key});

    @override
    State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {
    @override
    void initState() {
        super.initState();
    }

    Future<List<Transaction>> transactions() async {
        final response = await http.get(
        Uri.parse('http://localhost:9090/budget/transactions')
        );

        return parseTransactions(response.body);
    }

    @override
    Widget build(BuildContext context) {
        return Container();
    }
}

