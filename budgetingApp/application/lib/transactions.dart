import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    late Future<List<Transaction>> _transactionFuture;
    late List<Transaction> _transactions;
    @override
    void initState() {
        super.initState();

        _transactionFuture = transactions();
    }

    Future<List<Transaction>> transactions() async {
        final response = await http.get(
        Uri.parse('http://localhost:9090/budget/transactions')
        );

        return parseTransactions(response.body);
    }

    // this part works just as intended; just need to add more info to ListTiles
    @override
    Widget build(BuildContext context) {
        return FutureBuilder<List<Transaction>> (
            future: _transactionFuture,
            builder: (context, snapshot) {
                if (snapshot.hasData) {
                    _transactions = snapshot.data!;

                    return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _transactions.length+1,
                    itemBuilder: (context, i) {
                      if (i.isOdd) return const Divider();

                      final index = i ~/ 2;
                      Transaction t = _transactions[index];

                      return ListTile(
                        title: Text(
                          "${t.name}    ${t.date}    ${t.amount}  ${t.categories[0]}"
                        ),
                      );
                    },
                  );
                }
                else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                }

                return const CircularProgressIndicator();
            }
        );
    }
}

