import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
/*
This file holds all of the code for the bucket system, which is really
just another name for saving/spending categories
*/

List<Bucket> parseBuckets(String response, String type) {
    final Map<String, dynamic> json = jsonDecode(response);

    var bucketsJson = json['buckets'][type];
    List<Bucket> buckets = <Bucket>[];

    bucketsJson.forEach( (var bucket) => {
        buckets.add(Bucket.fromJson(bucket))
        });

    return buckets;
}


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

Future<void> addBuckets(Bucket b, String type) async {
    var bucketJson = jsonEncode(b);

    http.post(
        Uri.parse('http://localhost:9090/budget/add_bucket'),
        headers: <String, String> {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: bucketJson
    );
}

class Bucket {
    String name;
    String type;
    double currAmount;
    double maxAmount;

    Bucket(this.name, this.type, this.currAmount, this.maxAmount);

    factory Bucket.fromJson(Map<String, dynamic> json) {
        return Bucket(json['name'],
        json['type'],
        json['current'],
        json['maximum']
        );
    }
}

class SavingsBucket extends Bucket {
    SavingsBucket(String name, double current, double goal)
    : super(name, "savings", current, goal);

    static void redistribute(SavingsBucket source, SavingsBucket dest, double transferAmt) {
        source.currAmount -= transferAmt;
        dest.currAmount += transferAmt;
    }
}

class SpendingBucket extends Bucket{
    SpendingBucket(String name, double amount, double max)
    : super(name, "spending", amount, max);
}

class BucketWidget extends StatefulWidget {
    final String type;

    // a type is required when initializing a bucket widget (spending or savings)
    const BucketWidget({super.key, required this.type});

    @override
    State<BucketWidget> createState() => _BucketWidgetState();
}

class _BucketWidgetState extends State<BucketWidget> {
    late Future<List<Bucket>> _bucketFuture;
    List<Bucket> _buckets = <Bucket>[];

    @override
    void initState() {
        super.initState();

        _bucketFuture = getBuckets();

    }

    Future<List<Bucket>> getBuckets() async {
        final response = await http.get(
            Uri.parse('http://localhost:9090/budget/get_buckets')
        );

        return parseBuckets(response.body, widget.type);
    }

    @override
    Widget build(BuildContext context) {
        return FutureBuilder(
            future: _bucketFuture,
            builder: (context, snapshot) {
                if (snapshot.hasData) {
                    _buckets = snapshot.data!;

                    return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _buckets.length+1,
                        itemBuilder: (context, i) {
                            if (i.isOdd) {
                                return const Divider();
                            }

                            final index = i ~/ 2;

                            Bucket b = _buckets[index];
                            return ListTile(
                                title: Text(b.name),
                                subtitle: LinearProgressIndicator(
                                    value: b.maxAmount / b.currAmount,
                                    color: Colors.purple,
                                    backgroundColor: Colors.white,
                                )

                            );
                        }
                    );

                }
                return const CircularProgressIndicator();
            }
        );
    }
}
