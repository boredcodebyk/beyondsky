import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../provider/bsky.dart';
import 'component/post.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    final feedList = ref.watch(feedProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar.large(
            title: const Text("Home"),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.tag)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text("Login")),
                  RefreshIndicator(
                    onRefresh: () => ref.refresh(feedProvider.future),
                    child: feedList.when(
                      data: (item) => item != null
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: item.length,
                              itemBuilder: (context, index) {
                                var feedview = item[index];
                                return Post(
                                  post: feedview.post,
                                  reason: feedview.reason,
                                );
                              },
                            )
                          : Text("login"),
                      error: (error, StackTrace stackTrace) {
                        return Center(child: Text(error.toString()));
                      },
                      loading: () => const LinearProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
