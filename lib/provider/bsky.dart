import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bluesky/bluesky.dart';

import 'shared_preferences.dart';

final activeSessionProvider =
    NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

class SessionNotifier extends Notifier<Session?> {
  @override
  build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sessionValue = prefs.getString("activeSession");
    Session? currentSession;
    if (sessionValue == null || sessionValue == "") {
      currentSession = null;
    } else {
      currentSession = Session.fromJson(jsonDecode(sessionValue));
    }
    listenSelf(
      (previous, next) {
        prefs.setString(
            "activeSession", next == null ? "" : jsonEncode(next.toJson()));
      },
    );
    return currentSession;
  }

  void addSession(Session session) {
    state = session;
  }

  void removeSession() {
    state = null;
  }
}

final blueskyProvider = Provider<Bluesky>((ref) {
  Session? session = ref.watch(activeSessionProvider);
  if (session == null) {}
  final bluesky = Bluesky.fromSession(session!);

  return bluesky;
});

final getfeedProvider = FutureProvider<Feed>((ref) async {
  final bluesky = ref.watch(blueskyProvider);
  final res = await bluesky.feed.getTimeline(limit: 100);

  return res.data;
});

final fetchFeedProvider = FutureProvider<List<FeedView>>((ref) async {
  final feeds = await ref.watch(getfeedProvider.future);
  final feedList = feeds.feed;
  // print(feedList.map((e) => e.toJson()));
  return feedList;
});

class FeedNotifier extends AsyncNotifier<List<FeedView>?> {
  Future<List<FeedView>?> fetchFollowingFeed() async {
    try {
      final feeds = await ref.watch(getfeedProvider.future);
      final feedList = feeds.feed;
      // print(feedList.map((e) => e.toJson()));
      return feedList;
    } on InvalidRequestException catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<List<FeedView>?> build() async {
    return fetchFollowingFeed();
  }

  Future<void> likePost(Post post) async {
    final bluesky = ref.read(blueskyProvider);

    if (post.isLiked) {
      state = await AsyncValue.guard(() async {
        await bluesky.repo.deleteRecord(uri: post.viewer.like!);
        return fetchFollowingFeed();
      });
    } else {
      state = await AsyncValue.guard(() async {
        await bluesky.feed.like(cid: post.cid, uri: post.uri);
        return fetchFollowingFeed();
      });
    }
  }
}

final feedProvider =
    AsyncNotifierProvider<FeedNotifier, List<FeedView>?>(() => FeedNotifier());

// final profileProvider = FutureProvider<ActorProfile>((ref) async {
//   final bluesky = ref.watch(blueskyProvider);
//   final profile = await bluesky.actor.getProfile(actor: bluesky.session!.did);
//   return profile.data;
// });

class ProfileNotifier extends AsyncNotifier<ActorProfile> {
  Future<ActorProfile> fetchProfile(String handle) async {
    final bluesky = ref.watch(blueskyProvider);
    final profile = await bluesky.actor.getProfile(actor: handle);
    return profile.data;
  }

  @override
  Future<ActorProfile> build() async {
    final bluesky = ref.watch(blueskyProvider);
    return fetchProfile(bluesky.session!.handle);
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, ActorProfile>(ProfileNotifier.new);
