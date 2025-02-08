import 'package:bluesky/bluesky.dart' as bsky;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: bluesky.session!.handle == widget.handle
              ? null
              : IconButton.filledTonal(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back)),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton.filledTonal(
              onPressed: () {
                ref.read(activeSessionProvider.notifier).removeSession();
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: ref.watch(profileProvider(widget.handle)).when(
              data: (v) {
                bsky.ActorProfile profile = v.profileData;
                bsky.Feed feed = v.feedData;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 156,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(profile.banner!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundImage: CachedNetworkImageProvider(
                                    profile.avatar!,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(profile.displayName!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge),
                                      Text("@${profile.handle}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      Text(
                                          "${profile.followersCount} follower / ${profile.followsCount} following / ${profile.postsCount} posts",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium)
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(profile.description ?? ""),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: bluesky.session!.handle == widget.handle
                                  ? Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        FilledButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.edit),
                                            label: const Text("Edit")),
                                        IconButton.outlined(
                                            onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    content: ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight: 64,
                                                        minWidth: 64,
                                                        maxHeight: 128,
                                                        maxWidth: 128,
                                                      ),
                                                      child: QrImageView(
                                                          data:
                                                              "https://${bluesky.service}/${profile.handle}"),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {},
                                                          child: Text("Scan")),
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          child: Text("Close")),
                                                    ],
                                                  ),
                                                ),
                                            icon: const Icon(Icons.qr_code))
                                      ],
                                    )
                                  : Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        FilledButton.icon(
                                            onPressed: () {},
                                            icon: const Icon(Icons.add),
                                            label: const Text("Follow")),
                                        IconButton.outlined(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.message_outlined))
                                      ],
                                    ),
                            )
                          ],
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 512),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: feed.feed.length,
                          itemBuilder: (context, index) {
                            var feedview = feed.feed[index];
                            return Post(
                              post: feedview.post,
                              reason: feedview.reason,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => LinearProgressIndicator(),
            ));
  }
}
