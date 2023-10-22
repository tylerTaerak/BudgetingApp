import 'package:budget_frontend/transactions.dart';
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

    if (bucketsJson == null)
    {
        return buckets;
    }

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
    List<Transaction> transactions;

    Bucket(this.name, this.type, this.currAmount, this.maxAmount, this.transactions);

    factory Bucket.fromJson(Map<String, dynamic> json) {

        if (json['type'] == 'spending') {
            return SpendingBucket(json['name'], json['currAmount'], json['maxAmount'], parseTransactions(json['transactions']));
        }
        if (json['type'] == 'savings') {
            return SavingsBucket(json['name'], json['currAmount'], json['maxAmount'], parseTransactions(json['transactions']));
        }
        return Bucket("Unknown",
        'unknown',
        0.00,
        0.00,
        <Transaction>[]
        );
    }
}

class SavingsBucket extends Bucket {
    SavingsBucket(String name, double current, double goal, List<Transaction> transactions)
    : super(name, "savings", current, goal, transactions);

    static void redistribute(SavingsBucket source, SavingsBucket dest, double transferAmt) {
        source.currAmount -= transferAmt;
        dest.currAmount += transferAmt;
    }
}

class SpendingBucket extends Bucket{
    SpendingBucket(String name, double amount, double max, List<Transaction> transactions)
    : super(name, "spending", amount, max, transactions);
}

class DetailedBucketWidget extends StatelessWidget {
    final Bucket bucket;

    const DetailedBucketWidget({super.key, required this.bucket});

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Text(bucket.name),
                LinearProgressIndicator(
                    value: bucket.currAmount / bucket.maxAmount,
                    color: Colors.purple,
                    backgroundColor: Colors.purple.withAlpha(50),
                ),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: bucket.transactions.length,
                    itemBuilder: (context, i) {
                        Transaction t = bucket.transactions[i];
                        return ListTile(
                            title: Text(
                              "${t.name}    ${t.date}    ${t.amount}  ${t.categories[0]}"
                            )
                        );
                    }
                )
            ],
        );
    }
}

class BucketWidget extends StatefulWidget {
    final List<Bucket> buckets;

    // a type is required when initializing a bucket widget (spending or savings)
    const BucketWidget({super.key, required this.buckets});

    @override
    State<BucketWidget> createState() => _BucketWidgetState();
}

class _BucketWidgetState extends State<BucketWidget> {

    @override
    void initState() {
        super.initState();
    }

    void _goToDetailedView(BuildContext context, Bucket bucket) {
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
                body: Center(
                    child: DetailedBucketWidget(bucket: bucket)
                )
            )
            )
        );
    }

    @override
    Widget build(BuildContext context) {
        return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget.buckets.length+1,
            itemBuilder: (context, i) {
                if (i.isOdd) {
                    return const Divider();
                }

                final index = i~/2;

                Bucket b = widget.buckets[index];
                return ListTile(
                    title: Hero(
                        tag: 'bucket-transition',
                        child: Text(b.name)
                    ),
                    subtitle: LinearProgressIndicator(
                        value: b.currAmount / b.maxAmount,
                        color: Colors.purple,
                        backgroundColor: Colors.purple.withAlpha(50)
                    ),
                    onTap: () => _goToDetailedView(context, b)
                );
            }
        );
    }
}

class NewBucketForm extends StatefulWidget
{
    final String type;
    const NewBucketForm({super.key, required this.type});
    static List<String> categories = <String>[];

    static Future<void> setCategories() async {
        final categoryInfo = await http.get(
            Uri.parse(
                'http://localhost:9090/budget/categories'
            )
        );

        Map<String, dynamic> categoryMap = jsonDecode(categoryInfo.body);

        NewBucketForm.categories = categoryMap.entries.map((entry) => entry.value.toString()).toList();
    }

    @override
    State<NewBucketForm> createState() => _NewBucketFormState();
}

class _NewBucketFormState extends State<NewBucketForm>
{
    final _formKey = GlobalKey<FormState>();
    String currentSelection = NewBucketForm.categories.first;
    double maxAmount = 0.0;

    @override
    Widget build(BuildContext context) {
        // Navigator will take care of back button
        return Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                    DropdownButtonFormField(
                        value: currentSelection,
                        items: NewBucketForm.categories.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem(
                                value: value,
                                child: Text(value)
                            );
                        }).toList(),
                        onChanged: (String? value) {
                            setState(() {
                                currentSelection = value!;
                            });
                        }
                    ),
                    TextFormField(
                        // form for bucket goal/max amount
                        keyboardType: TextInputType.number,
                        onChanged: (String? value) {
                            setState(() {
                                maxAmount = double.tryParse(value!) ?? maxAmount;
                            });
                        },
                        validator: (String? value) {
                            if (value == null || maxAmount == 0) {
                                return "invalid amount";
                            }
                            return null;
                        },
                        ),
                    ElevatedButton(
                        // submit form
                        onPressed: () {
                            if (_formKey.currentState!.validate()) {
                                http.post(
                                        Uri.parse('http://localhost:9090/budget/add_bucket'),
                                        headers: <String, String> {
                                        'Content-Type': 'application/json; charset=UTF-8'
                                        },
                                        body: jsonEncode(<String, String>{
                                                  "name": currentSelection,
                                                  "type": widget.type,
                                                  "maxAmount": maxAmount.toString(),
                                                  "currAmount": "0.0"
                                      }));
                                Navigator.pop(context);
                            }
                        },
                        child: const Text("Create New Bucket")
                        )
                    ]
                )
            );
    }
}
