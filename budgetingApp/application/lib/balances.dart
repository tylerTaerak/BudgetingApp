import "dart:convert";
import "package:http/http.dart" as http;
import "package:flutter/material.dart";

class Balance {
    final String name;
    final String type;
    final double balance;

    const Balance({
        required this.name,
        required this.type,
        required this.balance,
    });

    // need different representations for bank accounts and credit accounts
    factory Balance.fromJson(Map<String, dynamic> json) {
        return Balance(
            name: json['name'],
            type: json['subtype'],
            balance: json['balances']['current']
        );
    }
}

List<Balance> parseBalances(String response) {
    final Map<String, dynamic> parsed = jsonDecode(response);

    var jsonBalances = parsed['accounts'];
    List<Balance> balances = <Balance>[];

    jsonBalances.forEach( (var bal) =>
        balances.add(Balance.fromJson(bal))
    );

    return balances;
}

// this is all working now (needs polishing later)
class BalanceWidget extends StatefulWidget {
    const BalanceWidget({super.key});

    @override
    State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {
    late Future<List<Balance>> _balanceFuture;
    late final List<Balance> _balances;

    @override
    void initState() {
        super.initState();

        _balanceFuture = getBalances();
    }

    Future<List<Balance>> getBalances() async {
        final response = await http.get(
        Uri.parse('http://localhost:9090/budget/balances')
        );

        return parseBalances(response.body);
    }

    @override
    Widget build(BuildContext context) {
        return FutureBuilder<List<Balance>>(
            future: _balanceFuture,
            builder: (context, snapshot) {
                if (snapshot.hasData) {
                    _balances = snapshot.data!;

                    return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _balances.length+1,
                    itemBuilder: (context, i) {
                      if (i.isOdd) return const Divider();

                      final index = i ~/ 2;
                      Balance b = _balances[index];

                      return ListTile(
                        title: Text(
                          "${b.name}    ${b.type}  ${b.balance}"
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
