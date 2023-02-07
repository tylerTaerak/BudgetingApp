import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'buckets.dart';
import 'transactions.dart';
import 'balances.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    // here, put a future for the pages using
    // backend/get_all_info
    // Future<void> _info /// get all info, set parameters to be passed to other pages
    late Future<void> _info;
    int _pageIndex = 0;
    static const List<Widget> _pages = <Widget>[
        BucketWidget(type: "spending"),
        TransactionTable(),
        BalanceWidget(),
    ];

    @override
    void initState() {
        super.initState();

        _info = getInfoFromBackend();
    }

    Future<void> getInfoFromBackend() async {
        final backendInfo = await http.get(
            Uri.parse(
                'http://localhost:9090/budget/get_all_info'
            )
        );

        // set all info for various pieces of application
    }

    void _itemPressed(int index) {
        setState(() {
            _pageIndex = index;
                });
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                appBar: AppBar(
                    title: const Text("Conley Budgeting"),
                ),
                body: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _pages.elementAt(_pageIndex)
                ),
                bottomNavigationBar: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Home'
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.money),
                            label: 'Transactions'
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.link),
                            label: 'Link Accounts'
                        )
                    ],
                    currentIndex: _pageIndex,
                    onTap: _itemPressed,
                    ),
            )
        );
    }
}
