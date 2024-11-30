import 'package:bluesky/bluesky.dart' as bsky;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/bsky.dart';
import 'component/post.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key, required this.handle});
  final String handle;
  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final bluesky = ref.watch(blueskyProvider);

    AsyncValue<bsky.ActorProfile> getProfile() {
      ref.read(profileProvider.notifier).fetchProfile(widget.handle);
      final profile = ref.watch(profileProvider);
      return profile;
    }

    Future<bsky.Feed> getFeed() async {
      final feed = await bluesky.feed.getAuthorFeed(actor: widget.handle);
      return feed.data;
    }

    const expandedHeight = 240.0;
    const collapsedHeight = 64.0;
    return Scaffold(
      appBar: getProfile().when(
        data: (data) => AppBar(
          title: Text(data.displayName ?? ""),
          actions: [
            if (GoRouterState.of(context).uri.path == '/profile/${data.handle}')
              IconButton(
                onPressed: () {
                  ref.read(activeSessionProvider.notifier).removeSession();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
              )
          ],
        ),
        error: (Object error, StackTrace stackTrace) => AppBar(),
        loading: () => AppBar(),
      ),
      body: getProfile().when(
          loading: () => const LinearProgressIndicator(),
          data: (snapshot) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: expandedHeight - collapsedHeight,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(snapshot.banner!),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: collapsedHeight - 48,
                        left: MediaQuery.of(context).size.width / 2 - 50,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const ShapeDecoration(
                            color: Colors.white,
                            shape: CircleBorder(),
                          ),
                          child: CircleAvatar(
                            foregroundImage: NetworkImage(snapshot.avatar!),
                            radius: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text(
                          snapshot.displayName!,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text("@${snapshot.handle}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text("@${snapshot.description}"),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextButton.icon(
                              icon: Text("${snapshot.followersCount}"),
                              onPressed: () {},
                              label: Text(
                                  "follower${snapshot.followersCount > 1 ? "s" : ""}"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextButton.icon(
                              icon: Text("${snapshot.followsCount}"),
                              onPressed: () {},
                              label: const Text("following"),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 0.6,
                      ),
                      FutureBuilder(
                        future: getFeed(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: snapshot.data?.feed.length,
                              itemBuilder: (context, index) {
                                var feed = snapshot.data?.feed[index];
                                return Post(
                                  post: feed!.post,
                                  reason: feed.reason,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            );
          },
          error: (Object error, StackTrace stackTrace) =>
              Center(child: Text(error.toString()))),
    );
  }
}
