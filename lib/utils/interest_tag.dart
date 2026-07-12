import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/utils/storage.dart';

/// Manages user's interest tags with weight tracking.
/// Tags are stored as [tagName -> count] in local cache.
class InterestTagManager {
  InterestTagManager._();

  static const _storeKey = 'interest_tags';

  /// Returns all tags sorted by weight descending.
  static List<MapEntry<String, int>> get sortedTags {
    final entries = allTags.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Returns all tags as a map of name -> weight.
  static Map<String, int> get allTags {
    final raw = GStorage.localCache.get(_storeKey, defaultValue: <String, dynamic>{}) as Map;
    return raw.cast<String, int>();
  }

  /// Total number of unique tags.
  static int get count => allTags.length;

  /// Whether any tags exist.
  static bool get isEmpty => allTags.isEmpty;

  /// Add tags from a video. Each tag gets weight +1.
  static void addTags(List<String> tagNames) {
    if (tagNames.isEmpty) return;
    final current = allTags;
    for (final tag in tagNames) {
      if (tag.trim().isNotEmpty) {
        current[tag.trim()] = (current[tag.trim()] ?? 0) + 1;
      }
    }
    GStorage.localCache.put(_storeKey, current);
  }

  /// Remove a specific tag.
  static void removeTag(String tag) {
    final current = allTags;
    current.remove(tag);
    GStorage.localCache.put(_storeKey, current);
  }

  /// Rename a tag (preserve weight).
  static void renameTag(String oldName, String newName) {
    if (oldName == newName || newName.trim().isEmpty) return;
    final current = allTags;
    final weight = current.remove(oldName);
    if (weight != null) {
      current[newName.trim()] = (current[newName.trim()] ?? 0) + weight;
    }
    GStorage.localCache.put(_storeKey, current);
  }

  /// Manually set tag weight.
  static void setWeight(String tag, int weight) {
    final current = allTags;
    if (weight <= 0) {
      current.remove(tag);
    } else {
      current[tag] = weight;
    }
    GStorage.localCache.put(_storeKey, current);
  }

  /// Clear all tags.
  static void clear() {
    GStorage.localCache.put(_storeKey, <String, int>{});
  }

  /// Fetch tags from B站 API for a given BVID.
  /// Returns tag names (empty list on failure).
  static Future<List<String>> fetchTagsForBvid(String bvid) async {
    final res = await UserHttp.videoTags(bvid: bvid);
    if (res case Success(:final response)) {
      return (response ?? [])
          .map((t) => t.tagName ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
    }
    return [];
  }
}
