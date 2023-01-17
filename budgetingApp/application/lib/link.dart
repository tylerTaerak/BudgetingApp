import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'keys.dart';

class LinkPage extends StatefulWidget {
  const LinkPage({super.key});

  @override
  State<LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage> {
  late LinkTokenConfiguration _linkTokenConfiguration;

  @override
  void initState() {
    super.initState();

    PlaidLink.onSuccess(_onSuccessCallback);
    PlaidLink.onEvent(_onEventCallback);
    PlaidLink.onExit(_onExitCallback);
  }

  void _onSuccessCallback(String publicToken, LinkSuccessMetadata metadata) async {
    print("Link Success!");
    print(publicToken);

    // make short notice saying the user has added an account
    // now that we have a public key, we can exchange it for an access token

    await exchangePubKey(publicToken);
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

// this fully works now; need to disable web security on startup
  Future<void> startLink() async {
    LinkKey key = await fetchLinkKey();

    _linkTokenConfiguration = LinkTokenConfiguration(token: key.linkToken);

    PlaidLink.open(configuration: _linkTokenConfiguration);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.infinity,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () =>
                  startLink(),
                child: const Text("Start Plaid Link"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

