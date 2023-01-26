import 'package:flutter/material.dart';
/*
This file holds all of the code for the bucket system, which is really
just another name for saving/spending categories
*/


/*
How does a bucket work?

Savings: A savings bucket should have a goal to save up to, and the
bucket page will need to have the option to redistribute savings among
the buckets

Spending: Each month, we should budget, setting an amount
for various spending categories. These buckets keep track of spending
in the various categories, and should alert the user if they are close
or past the allowance for that category
*/

/*
Both savings and spending buckets are rendered in the same way,
so both should extend this class to be built the same way
*/

class Bucket {
    String name;
    double currAmount;
    double maxAmount;

    Bucket(this.name, this.currAmount, this.maxAmount);

    factory Bucket.fromJson(Map<String, dynamic> json) {
        return Bucket(json['name'],
        json['current'],
        json['maximum']
        );
    }
}

class SavingsBucket extends Bucket {
    SavingsBucket(String name, double current, double goal)
    : super(name, current, goal);

    static void redistribute(SavingsBucket source, SavingsBucket dest, double transferAmt) {
        source.currAmount -= transferAmt;
        dest.currAmount += transferAmt;
    }
}

class SpendingBucket extends Bucket{
    SpendingBucket(String name, double amount, double max)
    : super(name, amount, max);
}

class BucketWidget extends StatefulWidget {
    const BucketWidget({super.key});

    @override
    State<BucketWidget> createState() => _BucketWidgetState();
}

class _BucketWidgetState extends State<BucketWidget> {
    @override
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Container();
    }
}
