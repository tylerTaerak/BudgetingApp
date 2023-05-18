import "dart:convert";
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

    var jsonBalances = parsed['balances']['accounts'];
    List<Balance> balances = <Balance>[];

    if (jsonBalances == null)
    {
        return balances;
    }

    jsonBalances.forEach((var bal) => {
        balances.add(Balance.fromJson(bal))
    });

    return balances;
}

class BalanceWidget extends StatefulWidget {
    final List<Balance> balances;

    const BalanceWidget({super.key, required this.balances});

    @override
    State<BalanceWidget> createState() => _BalanceWidgetState();
}

class _BalanceWidgetState extends State<BalanceWidget> {

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget.balances.length+1,
            itemBuilder: (context, i) {
                if (widget.balances.isEmpty)
                {
                    return const Text("Try adding some accounts!");
                }
              if (i.isOdd) return const Divider();

              final index = i ~/ 2;
              Balance b = widget.balances[index];

              return ListTile(
                title: Text(
                  "${b.name}    ${b.type}  ${b.balance}"
                ),
              );
            }
        );
    }
}
