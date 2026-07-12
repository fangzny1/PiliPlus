import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/interest_tag.dart';

class InterestTagsPage extends StatefulWidget {
  const InterestTagsPage({super.key});

  @override
  State<InterestTagsPage> createState() => _InterestTagsPageState();
}

class _InterestTagsPageState extends State<InterestTagsPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tags = InterestTagManager.sortedTags;
    return Scaffold(
      appBar: AppBar(
        title: Text('兴趣标签 (${InterestTagManager.count})'),
        actions: [
          if (tags.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: '清空全部',
              onPressed: () {
                InterestTagManager.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: tags.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 56, color: cs.outline),
                  const SizedBox(height: 12),
                  Text('暂无兴趣标签',
                      style: TextStyle(color: cs.outline, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('在视频详情页菜单中添加',
                      style: TextStyle(color: cs.outline.withValues(alpha: 0.7))),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: tags.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = tags[index];
                return ListTile(
                  dense: true,
                  title: Text(entry.key, style: const TextStyle(fontSize: 14)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'x${entry.value}',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18, color: cs.outline),
                        onPressed: () => _editTag(context, entry.key),
                      ),
                      IconButton(
                        icon: Icon(Icons.close,
                            size: 18, color: cs.error.withValues(alpha: 0.7)),
                        onPressed: () {
                          InterestTagManager.removeTag(entry.key);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _editTag(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑标签'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '标签名',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              InterestTagManager.renameTag(oldName, controller.text);
              Get.back();
              setState(() {});
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
