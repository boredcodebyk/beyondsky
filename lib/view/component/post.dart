import 'package:bluesky/bluesky.dart' as bsky;
import 'package:bluesky_text/bluesky_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../provider/bsky.dart';

class Post extends ConsumerStatefulWidget {
  const Post({super.key, required this.post, this.reason});
  final bsky.Post post;
  final bsky.Reason? reason;
  @override
  ConsumerState<Post> createState() => _PostState();
}

class _PostState extends ConsumerState<Post> {
  Future<void> handleLike() async {
    ref.read(feedProvider.notifier).likePost(widget.post);
  }

  @override
  Widget build(BuildContext context) {
    var post = widget.post;
    var reason = widget.reason;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text(widget.reason.toString()),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (reason.data is bsky.ReasonRepost) ...[
                      const Icon(Icons.repeat),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                            "Reposted by ${(reason.data as bsky.ReasonRepost).by.handle == ref.watch(activeSessionProvider)?.handle ? "you" : (reason.data as bsky.ReasonRepost).by.displayName ?? (reason.data as bsky.ReasonRepost).by.handle}"),
                      )
                    ]
                  ],
                ),
              ),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: GoRouterState.of(context).uri.path ==
                      '/profile/${post.author.handle}'
                  ? null
                  : () => context.push('/profile/${post.author.handle}'),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              title: Text(post.author.displayName ?? ""),
              leading: CircleAvatar(
                foregroundImage: CachedNetworkImageProvider(
                  post.author.avatar ??
                      "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHVzZXIlMjBwcm9maWxlfGVufDB8fDB8fHww",
                ),
              ),
              subtitle: Text("@${post.author.handle}"),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                  BlueskyText(post.record.text, enableMarkdown: true).value),
            ),
            if (post.embed != null)
              Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: renderEmbed(post.embed!),
                // Image(image: Image(  "https://images.unsplash.com/photo-1579783483458-83d02161294e?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHVzZXIlMjBwcm9maWxlfGVufDB8fDB8fHww  ")),
              ),
            Padding(      
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () => handleLike(),
                          icon: Icon(post.isLiked
                              ? Icons.favorite
                              : Icons.favorite_outline)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(post.likeCount.toString()),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: Icon(post.isReposted
                              ? Icons.repeat_on
                              : Icons.repeat)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(post.repostCount.toString()),
                      ),
                      IconButton(
                          onPressed: post.isReplyDisabled ? null : () {},
                          icon: const Icon(Icons.comment_outlined)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(post.replyCount.toString()),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderEmbed(bsky.EmbedView embedView) {
    Widget handleImage(bsky.UEmbedViewImages images) {
      return images.data.images.length > 1
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 240,
              child: CarouselView(
                  scrollDirection: Axis.horizontal,
                  itemExtent: 300,
                  shrinkExtent: 200,
                  children: images.data.images
                      .map((e) => Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            child: CachedNetworkImage(
                              imageUrl: e.thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ))
                      .toList()),
            )
          : CachedNetworkImage(imageUrl: images.data.images.first.thumbnail);
    }

    Widget handleQuote(bsky.UEmbedViewRecord embedView) {
      if (embedView.data.record.data is bsky.UEmbedViewRecord) {
        return Card.outlined(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                title: Text((embedView.data.record.data
                            as bsky.UEmbedViewRecordViewRecord)
                        .data
                        .author
                        .displayName ??
                    ""),
                leading: CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    (embedView.data.record.data
                                as bsky.UEmbedViewRecordViewRecord)
                            .data
                            .author
                            .avatar ??
                        "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHVzZXIlMjBwcm9maWxlfGVufDB8fDB8fHww",
                  ),
                ),
                subtitle: Text(
                    "@${(embedView as bsky.UEmbedViewRecordViewRecord).data.author.handle}"),
              ),
            ],
          ),
        );
      } else if (embedView is bsky.UEmbedViewRecordWithMedia) {
        final embedRecordMedia = (embedView as bsky.UEmbedViewRecordViewRecord);
        return Card.outlined(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                title: Text(embedRecordMedia.data.author.displayName ?? ""),
                leading: CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    embedRecordMedia.data.author.avatar ??
                        "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHVzZXIlMjBwcm9maWxlfGVufDB8fDB8fHww",
                  ),
                ),
                subtitle: Text("@${embedRecordMedia.data.author.handle}"),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          const CircularProgressIndicator(),
          Text(embedView.toString())
        ],
      );
    }

    Widget handleQuoteWithMedia(bsky.UEmbedViewRecordWithMedia embedView) {
      return Card.outlined(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                title: Text((embedView.data.record.record
                            as bsky.UEmbedViewRecordViewRecord)
                        .data
                        .author
                        .displayName ??
                    ""),
                leading: CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(
                    (embedView.data.record.record
                                as bsky.UEmbedViewRecordViewRecord)
                            .data
                            .author
                            .avatar ??
                        "https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fHVzZXIlMjBwcm9maWxlfGVufDB8fDB8fHww",
                  ),
                ),
                subtitle: Text(
                    "@${(embedView.data.record.record as bsky.UEmbedViewRecordViewRecord).data.author.handle}"),
              ),
            ],
          ),
        ),
      );
    }

    Widget getEmbed() {
      if (embedView is bsky.UEmbedViewImages) {
        return handleImage(embedView);
      } else if (embedView is bsky.UEmbedViewRecord) {
        return handleQuote(embedView);
      } else if (embedView is bsky.UEmbedViewRecordWithMedia) {
        return handleQuoteWithMedia(embedView);
      }
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            Text(embedView.toString())
          ],
        ),
      );
    }

    return getEmbed();
  }
}
