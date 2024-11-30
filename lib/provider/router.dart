import 'package:bluesky/bluesky.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../view/views.dart';
import 'bsky.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNavigationBar(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchView(),
          ),
          GoRoute(
            path: '/notification',
            builder: (context, state) => const NotificationView(),
          ),
          GoRoute(
            path: '/profile/:handle',
            builder: (context, state) => ProfileView(
              handle: state.pathParameters['handle']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      )
    ],
    redirect: (context, state) {
      if (ref.read(activeSessionProvider) == null) {
        return '/login';
      } else {
        return null;
      }
    },
  );
  return router;
});

class ScaffoldWithNavigationBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavigationBar({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ScaffoldWithNavigationBar> createState() =>
      _ScaffoldWithNavigationBarState();
}

class _ScaffoldWithNavigationBarState
    extends ConsumerState<ScaffoldWithNavigationBar> {
  int selectedIndex = 0;

  void navigate(value, BuildContext context) {
    switch (value) {
      case 0:
        setState(() => selectedIndex = 0);
        context.go('/');
      case 1:
        setState(() => selectedIndex = 1);
        context.go('/search');
      case 2:
        setState(() => selectedIndex = 2);
        context.go('/notification');
      case 3:
        Session session = ref.read(activeSessionProvider)!;
        setState(() => selectedIndex = 3);
        context.go('/profile/${session.handle}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Session? session = ref.read(activeSessionProvider);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => navigate(value, context),
        destinations: [
          const NavigationDestination(
            label: "Home",
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
          ),
          const NavigationDestination(
            label: "Search",
            icon: Icon(Icons.search),
          ),
          const NavigationDestination(
            label: "Notification",
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
          ),
          NavigationDestination(
            label: "Profile ",
            icon: SizedBox(
              width: 24,
              height: 24,
              child: FutureBuilder(
                  future: ref
                      .watch(blueskyProvider)
                      .actor
                      .getProfile(actor: session!.handle),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Icon(Icons.person_2_outlined);
                    }
                    return CircleAvatar(
                      foregroundImage: CachedNetworkImageProvider(
                          snapshot.data!.data.avatar!),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
