import 'dart:math';
import 'dart:ui';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:secure_messaging_platform_flutter/mutations.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:secure_messaging_platform_flutter/queries.dart';

const apiUrl = const String.fromEnvironment("API_URL");
const apiKey = const String.fromEnvironment("API_KEY");

final HttpLink httpLink = HttpLink(
  apiUrl,
);
final AuthLink authLink =
    AuthLink(getToken: () => apiKey, headerKey: 'x-api-key');
final Link link = authLink.concat(httpLink);
ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    link: link,
    cache: GraphQLCache(),
  ),
);

final router = FluroRouter();

var homeHandler = Handler(handlerFunc: (context, parameters) {
  return HomePage();
});

var decryptHandler = Handler(
  handlerFunc: (context, parameters) {
    return DecryptMessagePage(messageId: parameters["id"]![0]);
  },
);

void main() {
  router.define('/', handler: homeHandler);
  router.define('/:id', handler: decryptHandler);

  runApp(GraphQLProvider(
    client: client,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: TextTheme(
            bodyText1: GoogleFonts.lato(color: Colors.white, fontSize: 24),
            headline3: GoogleFonts.lato(color: Colors.white),
            button: GoogleFonts.lato(),
            headline2: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      onGenerateRoute: router.generator,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Page(
      child: LayoutBuilder(
        builder: (buildContext, boxConstraints) {
          final horizontal = MediaQuery.of(context).size.width >= 1000;

          return Flex(
              direction: horizontal ? Axis.horizontal : Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: horizontal
                        ? const EdgeInsets.only(right: 10)
                        : const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _urlController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  "Share your encrypted message",
                                  style: Theme.of(context).textTheme.headline2,
                                ),
                              ),
                              Text(
                                "Make sure to send both the URL and the Password",
                                style: Theme.of(context).textTheme.bodyText1,
                              )
                            ]
                          : [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Text(
                                  "Send an encrypted message.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2
                                      ?.apply(
                                          fontSizeFactor: horizontal ? 1 : .7),
                                ),
                              ),
                              Text(
                                "Send any message safe and secure. Because your message is encrypted on your device, your private data can only be read by the intended recipient.",
                                style: Theme.of(context).textTheme.bodyText1,
                              )
                            ],
                    ),
                  ),
                ),
                _passwordController.text.isNotEmpty &&
                        _urlController.text.isNotEmpty
                    ? Flexible(
                        flex: 1,
                        child: Padding(
                            padding: horizontal
                                ? const EdgeInsets.only(left: 10)
                                : const EdgeInsets.only(top: 10),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white.withOpacity(.3)),
                                child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextField(
                                          decoration:
                                              InputDecoration(labelText: "Url"),
                                          controller: _urlController,
                                        ),
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: "Password",
                                          ),
                                          controller: _passwordController,
                                        )
                                      ],
                                    )))))
                    : Flexible(
                        flex: 1,
                        child: Padding(
                          padding: horizontal
                              ? const EdgeInsets.only(left: 10)
                              : const EdgeInsets.only(top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white.withOpacity(.3)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                        hintText: "Your Message"),
                                    minLines: 10,
                                    maxLines: null,
                                    controller: _controller,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Mutation(
                                      options: MutationOptions(
                                        document: gql(createMessage),
                                        onCompleted: (dynamic resultData) {
                                          final String id =
                                              resultData['createMessage']['id'];

                                          setState(() {
                                            _urlController.text =
                                                "${Uri.base}$id";
                                          });
                                        },
                                      ),
                                      builder: (runMutation, result) {
                                        return ElevatedButton(
                                            onPressed: () {
                                              final text = _controller.text;
                                              final iv = encrypt.IV
                                                  .fromSecureRandom(16);
                                              final key =
                                                  encrypt.Key.fromSecureRandom(
                                                      32);
                                              final encrypter =
                                                  encrypt.Encrypter(
                                                      encrypt.AES(key));
                                              final encrypted = encrypter
                                                  .encrypt(text, iv: iv);

                                              setState(() {
                                                _passwordController.text =
                                                    key.base64;
                                              });

                                              runMutation({
                                                "message": encrypted.base64,
                                                "iv": iv.base64
                                              });
                                            },
                                            child: Text("Encrypt Message"));
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
              ]);
        },
      ),
    );
  }
}

class DecryptMessagePage extends StatefulWidget {
  final String messageId;

  DecryptMessagePage({required this.messageId});

  @override
  _DecryptMessagePageState createState() => _DecryptMessagePageState();
}

class _DecryptMessagePageState extends State<DecryptMessagePage> {
  final _passwordController = TextEditingController();
  String? decryptedMessage;

  @override
  Widget build(BuildContext context) {
    return Page(
      child: LayoutBuilder(
        builder: (buildContext, boxConstraints) {
          final horizontal = MediaQuery.of(context).size.width >= 1000;

          return Flex(
              direction: horizontal ? Axis.horizontal : Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: horizontal
                        ? const EdgeInsets.only(right: 10)
                        : const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            decryptedMessage is String
                                ? "Your message"
                                : "Decrypt your message",
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        ),
                        if (decryptedMessage == null)
                          Text(
                            "Enter the password you received",
                            style: Theme.of(context).textTheme.bodyText1,
                          )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: horizontal
                        ? const EdgeInsets.only(left: 10)
                        : const EdgeInsets.only(top: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white.withOpacity(.3)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Query(
                          options: QueryOptions(
                              document: gql(getMessage),
                              variables: {"id": widget.messageId}),
                          builder: (result, {fetchMore, refetch}) {
                            final String? encryptedString =
                                result.data?['getMessage']["message"];
                            final String? storedIv =
                                result.data?["getMessage"]["iv"];

                            if (decryptedMessage is String) {
                              return Text(decryptedMessage as String);
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  decoration:
                                      InputDecoration(hintText: "Password"),
                                  controller: _passwordController,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        final iv = encrypt.IV
                                            .fromBase64(storedIv as String);
                                        final key = encrypt.Key.fromBase64(
                                            _passwordController.text);
                                        final encrypter =
                                            encrypt.Encrypter(encrypt.AES(key));

                                        setState(() {
                                          decryptedMessage = encrypter.decrypt(
                                              encrypt.Encrypted.fromBase64(
                                                  encryptedString as String),
                                              iv: iv);
                                        });
                                      },
                                      child: Text("Decrypt Message")),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ]);
        },
      ),
    );
  }
}

class Page extends StatelessWidget {
  final Widget child;

  Page({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromRGBO(117, 121, 255, 1),
            Color.fromRGBO(178, 36, 239, 1),
          ])),
          child: SingleChildScrollView(
            child: FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width >= 1000 ? .8 : .95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontal =
                          MediaQuery.of(context).size.width >= 1000;

                      return Padding(
                        padding: horizontal
                            ? EdgeInsets.only(top: 50, bottom: 80)
                            : EdgeInsets.only(top: 50, bottom: 50),
                        child: Center(
                          child: GestureDetector(
                            onTap: () =>
                                ModalRoute.of(context)?.settings.name == "/"
                                    ? null
                                    : router.navigateTo(context, "/"),
                            child: Text(
                              "Secure Messaging Platform",
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: child,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
