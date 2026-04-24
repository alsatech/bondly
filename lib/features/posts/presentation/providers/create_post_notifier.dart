import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/feed/data/models/post.dart';
import '../../data/posts_repository.dart';
import '../../domain/post_create_failure.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

sealed class CreatePostState {
  const CreatePostState();
}

final class CreatePostInitial extends CreatePostState {
  const CreatePostInitial();
}

final class CreatePostSubmitting extends CreatePostState {
  const CreatePostSubmitting();
}

final class CreatePostSuccess extends CreatePostState {
  const CreatePostSuccess(this.post);
  final Post post;
}

final class CreatePostError extends CreatePostState {
  const CreatePostError(this.failure);
  final PostCreateFailure failure;
}

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository(dio: ref.watch(dioProvider));
});

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class CreatePostNotifier extends Notifier<CreatePostState> {
  @override
  CreatePostState build() => const CreatePostInitial();

  Future<void> submit({
    String? caption,
    required bool isPrivate,
    bool isEvent = false,
    bool isSale = false,
    String? musicName,
    String? musicArtist,
    String? locationName,
    String? locationArea,
    String? externalUrl,
    List<String> brandIds = const [],
    List<File> mediaFiles = const [],
    int? priceCents,
    String? productType,
    bool? isFree,
  }) async {
    state = const CreatePostSubmitting();

    try {
      final repo = ref.read(postsRepositoryProvider);
      final post = await repo.createPost(
        caption: caption,
        isPrivate: isPrivate,
        isEvent: isEvent,
        isSale: isSale,
        musicName: musicName,
        musicArtist: musicArtist,
        locationName: locationName,
        locationArea: locationArea,
        externalUrl: externalUrl,
        brandIds: brandIds,
        mediaFiles: mediaFiles,
        priceCents: priceCents,
        productType: productType,
        isFree: isFree,
      );
      state = CreatePostSuccess(post);
    } on PostCreateFailure catch (failure) {
      state = CreatePostError(failure);
    }
  }

  /// Resets to initial so the screen can be reused after an error.
  void reset() => state = const CreatePostInitial();
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final createPostNotifierProvider =
    NotifierProvider<CreatePostNotifier, CreatePostState>(
  CreatePostNotifier.new,
);
