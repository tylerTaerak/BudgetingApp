import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plaid_flutter/plaid_flutter.dart';
import 'keys.dart';
import 'buckets.dart';
import 'balances.dart';
class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
    late Future<void> _infoFuture;
    int _pageIndex = 0;

    List<Widget> _pages = [
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink()
    ];

    @override
    void initState() {
        super.initState();

        _infoFuture = getInfoFromBackend();
        NewBucketForm.setCategories();

        PlaidLink.onSuccess(_onSuccessCallback);
        PlaidLink.onEvent(_onEventCallback);
        PlaidLink.onExit(_onExitCallback);
    }

    void _onSuccessCallback(String publicToken, LinkSuccessMetadata metadata) async {
      print("Link Success!");
      // make short notice saying the user has added an account
      // now that we have a public key, we can exchange it for an access token

      exchangePubKey(publicToken).then(
        (data){
            _infoFuture = getInfoFromBackend();
        }
      );
    }

    void _onEventCallback(String event, LinkEventMetadata metadata) {
      print("Redirecting...");
    }

    void _onExitCallback(LinkError? error, LinkExitMetadata metadata) {
      print("\n\nExiting Link.\n\n");
      // Here, we redirect to the home page

      if (error != null) {
        print("Exiting => error: ${error.description()}");
      }
    }

    Future<void> startLink() async {
      LinkKey key = await fetchLinkKey();

      LinkTokenConfiguration config = LinkTokenConfiguration(token: key.linkToken);

      PlaidLink.open(configuration: config);
    }

    Future<void> getInfoFromBackend() async {
        final backendInfo = await http.get(
            Uri.parse(
                'http://localhost:9090/budget/get_all_info'
            )
        );

        if (backendInfo.statusCode == 200){
            List<Balance> balances = parseBalances(backendInfo.body);
            List<Bucket> spending = parseBuckets(backendInfo.body, 'spending');
            List<Bucket> savings = parseBuckets(backendInfo.body, 'savings');

            setState(() {
                    _pages = [
                    BucketWidget(buckets: spending),
                    BucketWidget(buckets: savings),
                    BalanceWidget(balances: balances)
                    ];
                    });
        }

    }

    Widget _actionButton() {
        if (_pageIndex != 2)
        {
            return FloatingActionButton(
                    onPressed: (){
                        String bucketType;
                        if (_pageIndex == 0) {
                            bucketType = "spending";
                        } else {
                            bucketType = "savings";
                        }
                        // do stuff to add bucket
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (BuildContext context) => Scaffold(
                                body: Center(
                                    child: NewBucketForm(type: bucketType),
                                )
                            )
                            )
                        );
                    },
                    child: const Icon(Icons.add)
                    );
        }
        return Container();
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
                    actions: <Widget>[
                        IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: 'Add New Account',
                            onPressed: () {
                                startLink();
                            }
                        )
                    ]
                ),
                body: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: FutureBuilder(
                      future: _infoFuture,
                      builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done)
                          {
                              return _pages.elementAt(_pageIndex);
                          }
                          else if (snapshot.hasError)
                          {
                              return Text('${snapshot.error}');
                          }

                          return const CircularProgressIndicator();
                      }
                      ),
                ),
                floatingActionButton: _actionButton(),
                bottomNavigationBar: BottomNavigationBar(
                    items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                            icon: Icon(Icons.fastfood),
                            label: 'Spending'
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.home),
                            label: 'Savings'
                        ),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.money),
                            label: 'Accounts'
                        )
                    ],
                    currentIndex: _pageIndex,
                    onTap: _itemPressed,
                    ),
            )
        );
    }
}
