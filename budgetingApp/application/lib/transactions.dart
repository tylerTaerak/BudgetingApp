import 'package:flutter/material.dart';
import 'dart:convert';

class Transaction {
    final String name;
    final double amount;
    final String date;
    final List<dynamic> categories;

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
            categories: json['category']!
        );
    }
}

List<Transaction> parseTransactions(List<dynamic> transactionsResp) {
    List<Transaction> transactions = <Transaction>[];

    transactionsResp.forEach( (var tran) =>
        transactions.add(Transaction.fromJson(tran))
    );

    return transactions;
}

/*
This is the scrollable list of transactions from all
accounts. The actual list of transactions will also be used to calculate
money spent and money earned for other information displays

The actual list of transactions will be handled by the backend
*/
class TransactionTable extends StatefulWidget {
    final List<Transaction> transactions;

    const TransactionTable({super.key, required this.transactions});

    @override
    State<TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<TransactionTable> {

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.transactions.length+1,
        itemBuilder: (context, i) {
          if (i.isOdd) return const Divider();

          final index = i ~/ 2;
          Transaction t = widget.transactions[index];

          return ListTile(
            title: Text(
              "${t.name}    ${t.date}    ${t.amount}  ${t.categories[0]}"
            ),
          );
        },
      );
    }
}

