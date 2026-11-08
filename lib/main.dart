import 'package:flutter/material.dart';

void main() => runApp(const LumoApp());

const _background = Color(0xFF090B14);
const _surface = Color(0xFF131727);
const _muted = Color(0xFF8992AC);
const _cyan = Color(0xFF42D7FF);
const _purple = Color(0xFF9470FF);

class LumoApp extends StatelessWidget {
  const LumoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _purple,
          brightness: Brightness.dark,
          surface: _surface,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  static const _tabs = [
    _TabData('Чаты', Icons.chat_bubble_rounded),
    _TabData('Контакты', Icons.people_alt_rounded),
    _TabData('Настройки', Icons.settings_rounded),
    _TabData('Профиль', Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: const [
            ChatsPage(),
            _PlaceholderPage(
              icon: Icons.people_alt_rounded,
              title: 'Контакты',
              subtitle: 'Здесь появятся твои контакты Lumo',
            ),
            _PlaceholderPage(
              icon: Icons.settings_rounded,
              title: 'Настройки',
              subtitle: 'Настрой Lumo так, как тебе удобно',
            ),
            _PlaceholderPage(
              icon: Icons.person_rounded,
              title: 'Профиль',
              subtitle: 'Твой профиль появится здесь',
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 76,
        backgroundColor: const Color(0xFF101421),
        indicatorColor: _purple.withValues(alpha: 0.18),
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          for (var i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: Icon(_tabs[i].icon, color: _muted),
              selectedIcon: Icon(_tabs[i].icon, color: _cyan),
              label: _tabs[i].label,
            ),
        ],
      ),
    );
  }
}

class _TabData {
  const _TabData(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Row(
              children: [
                const LumoMark(size: 46),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lumo',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        'Твои люди. Твои разговоры.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Поиск',
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded, color: _cyan),
                ),
                IconButton(
                  tooltip: 'Новое сообщение',
                  onPressed: () {},
                  icon: const Icon(Icons.edit_square, color: _purple),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded, color: _muted),
                  SizedBox(width: 10),
                  Text('Поиск по чатам', style: TextStyle(color: _muted)),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, 8, 22, 12),
            child: Text(
              'СООБЩЕНИЯ',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: _EmptyChats(),
        ),
      ],
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 20, 36, 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _purple.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.16),
                    blurRadius: 36,
                  ),
                ],
              ),
              child: const Icon(
                Icons.forum_rounded,
                size: 42,
                color: _cyan,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Пока здесь тихо',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Когда начнёшь общаться, твои переписки появятся здесь.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_comment_rounded),
              label: const Text('Новое сообщение'),
              style: FilledButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 54, color: _cyan),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }
}

class LumoMark extends StatelessWidget {
  const LumoMark({super.key, this.size = 48});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cyan, _purple],
        ),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.28),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.chat_bubble_rounded,
        color: Colors.white,
        size: size * 0.53,
      ),
    );
  }
}
