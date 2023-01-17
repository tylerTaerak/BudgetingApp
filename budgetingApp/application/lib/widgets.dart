import 'package:flutter/material.dart';

/*
Wheel graphs are a compact way to display transaction information

They will be used to show money spent, money earned,
and/or expenditures vs. budget
*/
class WheelGraph extends StatelessWidget {
    const WheelGraph({super.key});

    @override
    Widget build(BuildContext context) {
        return Container();
    }
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

class _TransactionTableState
extends State<TransactionTable> {

    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Container();
    }
}

