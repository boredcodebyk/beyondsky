import 'package:bluesky/bluesky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/bsky.dart';
import '../provider/credential_store.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final identifierController = TextEditingController();
  final appPassController = TextEditingController();
  final serverAddressController = TextEditingController();
  bool isLoading = false;
  int host = 0;

  void login() async {
    setState(() => isLoading = true);
    if (isValidAppPassword(appPassController.text)) {
      try {
        var session = await createSession(
            identifier: identifierController.text,
            password: appPassController.text,
            service: switch (host) {
              0 => "bsky.social",
              1 => serverAddressController.text,
              _ => "bsky.social"
            });
        ref
            .read(storageServiceProvider)
            .addLogin(identifierController.text, appPassController.text);
        ref.read(activeSessionProvider.notifier).addSession(session.data);
        navigatorKey.currentContext!.go('/');
        setState(() => isLoading = false);
        print(session);
      } on UnauthorizedException catch (e) {
        setState(() => isLoading = false);
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.response.data.message),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(navigatorKey.currentContext!).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } on XRPCException catch (e) {
        setState(() => isLoading = false);
      } on Exception catch (e) {
        setState(() => isLoading = false);
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(navigatorKey.currentContext!).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        print(e.toString());
      }
    } else {
      setState(() => isLoading = false);
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Invalid App Password"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(navigatorKey.currentContext!).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    appPassController.dispose();
    serverAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: navigatorKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            title: Row(
              children: [
                const Text("Login"),
                if (isLoading) const CircularProgressIndicator()
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Hosting Provider"),
                  RadioListTile(
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: 0,
                    groupValue: host,
                    onChanged: (value) => setState(() => host = value!),
                    title: const Text("Bluesky Social"),
                  ),
                  RadioListTile(
                    controlAffinity: ListTileControlAffinity.trailing,
                    value: 1,
                    groupValue: host,
                    onChanged: (value) => setState(() => host = value!),
                    title: const Text("Custom"),
                  ),
                  if (host == 1)
                    TextField(
                      controller: serverAddressController,
                      decoration:
                          const InputDecoration(hintText: "Server Address"),
                    ),
                  const Text("Account"),
                  TextField(
                    controller: identifierController,
                    decoration:
                        const InputDecoration(hintText: "Username or Email"),
                  ),
                  TextField(
                    controller: appPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            onPressed: () => launchUrl(Uri.parse(
                                "https://bsky.app/settings/app-passwords")),
                            icon: const Icon(Icons.open_in_new)),
                        hintText: "App Password"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                            onPressed: () => login(),
                            child: const Text("Login")),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
