import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/application/chat_controller.dart';
import '../features/chat/data/models/chat_model.dart';
import '../common_ui_components/buttons/custom_icon_text_outlined_button.dart';
import '../common_ui_components/expandable_tile/custom_expandable_tile.dart';

class GlobalAppDrawer extends ConsumerWidget {
  const GlobalAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatHistoryProvider);
    final themeMode = ref.watch(themeModeProvider);

    final now = DateTime.now();

    List<ChatHistory> today(List<ChatHistory> list) => list.where((c) =>
    c.updatedOn.year == now.year &&
        c.updatedOn.month == now.month &&
        c.updatedOn.day == now.day &&
        !c.isArchived).toList();

    List<ChatHistory> last7(List<ChatHistory> list) => list.where((c) {
      final d = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      return c.updatedOn.isAfter(now.subtract(const Duration(days: 7))) &&
          c.updatedOn.isBefore(d) &&
          !c.isArchived;
    }).toList();

    List<ChatHistory> last30(List<ChatHistory> list) => list.where((c) =>
    c.updatedOn.isAfter(now.subtract(const Duration(days: 30))) &&
        !c.isArchived &&
        !today(list).contains(c) &&
        !last7(list).contains(c)).toList();

    final archived = chats.where((c) => c.isArchived).toList();

    void openChat(ChatHistory chat) async {
      Navigator.pop(context);
      await ref.read(chatControllerProvider.notifier).loadSession(chat.sessionId);
      if (ModalRoute.of(context)?.settings.name != '/chat') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/chat'),
            builder: (_) => const MainLayout(child: ChatScreen()),
          ),
        );
      }
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CustomIconTextOutlinedButton(
                      assetPath: 'assets/icons/icon-new-topic.svg',
                      text: 'New Chat',
                      onPressed: () async {
                        final sessionId = await ref
                            .read(chatControllerProvider.notifier)
                            .startNewChat();
                        await ref
                            .read(chatControllerProvider.notifier)
                            .loadSession(sessionId);
                        Navigator.pop(context);
                        if (ModalRoute.of(context)?.settings.name != '/chat') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: '/chat'),
                              builder: (_) =>
                              const MainLayout(child: ChatScreen()),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Chat History',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                  ),
                  CustomExpandableTile(
                      title: "Today's", items: today(chats), onTapItem: openChat),
                  CustomExpandableTile(
                      title: 'Last 7 days',
                      items: last7(chats),
                      onTapItem: openChat),
                  CustomExpandableTile(
                      title: 'Last 30 days',
                      items: last30(chats),
                      onTapItem: openChat),
                  CustomExpandableTile(
                      title: 'Archived Chats',
                      items: archived,
                      onTapItem: openChat),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),

                ],
              ),
            ),
            const Divider(),
            // THEME TOGGLE AT BOTTOM
            SwitchListTile(
              title: Text(
                "Dark Mode",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              secondary: Icon(
                Icons.brightness_6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).state =
                value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ],
        ),
      ),
    );
  }
}
