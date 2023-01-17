import 'package:flutter/material.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'keys.dart';

class LinkPage extends StatefulWidget {
  const LinkPage({super.key});

  @override
  State<LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage> {
  late LegacyLinkConfiguration _publicKeyConfiguration;
  late LinkTokenConfiguration _linkTokenConfiguration;

  @override
  void initState() {
    super.initState();

    _publicKeyConfiguration = LegacyLinkConfiguration(
      clientName: "Conley Budgeting",
      publicKey: "62cc51c3822fa60013f43a47",
      environment: LinkEnvironment.sandbox,
      products: <LinkProduct>[
        LinkProduct.auth,
        LinkProduct.transactions
      ],
      language: "en",
      countryCodes: ['US'],
      userLegalName: "John Appleseed",
      userEmailAddress: "jappleseed@youapp.com",
      userPhoneNumber: "+1 (512) 555-1234",
    );

    _linkTokenConfiguration = LinkTokenConfiguration(
      token: "GENERATED TOKEN",
    );

    PlaidLink.onSuccess(_onSuccessCallback);
    PlaidLink.onEvent(_onEventCallback);
    PlaidLink.onExit(_onExitCallback);
  }

  void _onSuccessCallback(String publicToken, LinkSuccessMetadata metadata) {
    print("Link Success!");
  }

  void _onEventCallback(String event, LinkEventMetadata metadata) {
    print("Redirecting...");
  }

  void _onExitCallback(LinkError? error, LinkExitMetadata metadata) {
    print("Exiting Link.");
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
              ElevatedButton(
                onPressed: () =>
                    PlaidLink.open(configuration: _publicKeyConfiguration),
                child: const Text("Open Plaid Link (Public Key)"),
              ),
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

