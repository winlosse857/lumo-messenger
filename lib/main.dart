import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LumoApp());
}

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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _cyan)),
          );
        }
        if (snapshot.hasData) return const HomeScreen();
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = true;
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      if (_isRegister) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await credential.user?.updateDisplayName(_nameController.text.trim());
        await credential.user?.reload();
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _error = _messageFor(error.code));
    } catch (_) {
      setState(() => _error = 'Не удалось выполнить действие. Попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот адрес электронной почты уже зарегистрирован.';
      case 'invalid-email':
        return 'Проверь адрес электронной почты.';
      case 'weak-password':
        return 'Пароль слишком простой. Выбери более надёжный.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Не удалось войти. Проверь почту и пароль.';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуй позже.';
      case 'network-request-failed':
        return 'Проверь подключение к интернету.';
      default:
        return 'Что-то пошло не так. Попробуй ещё раз.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: LumoMark(size: 76)),
                    const SizedBox(height: 22),
                    const Text(
                      'Lumo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegister ? 'Создай свой аккаунт' : 'С возвращением',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _muted, fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    if (_isRegister) ...[
                      _AuthField(
                        controller: _nameController,
                        label: 'Имя',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'Введи имя (минимум 2 символа).';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    _AuthField(
                      controller: _emailController,
                      label: 'Электронная почта',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                          return 'Введи корректный адрес почты.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _AuthField(
                      controller: _passwordController,
                      label: 'Пароль',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _hidePassword,
                      suffix: IconButton(
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Пароль должен содержать не менее 6 символов.';
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!, style: const TextStyle(color: Color(0xFFFF8585))),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegister ? 'Зарегистрироваться' : 'Войти'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(() {
                                _isRegister = !_isRegister;
                                _error = null;
                              }),
                      child: Text(
                        _isRegister
                            ? 'Уже есть аккаунт? Войти'
                            : 'Нет аккаунта? Зарегистрироваться',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorMaxLines: 2,
      ),
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
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            const ChatsPage(),
            const _PlaceholderPage(
              icon: Icons.people_alt_rounded,
              title: 'Контакты',
              subtitle: 'Здесь появятся твои контакты Lumo',
            ),
            const _PlaceholderPage(
              icon: Icons.settings_rounded,
              title: 'Настройки',
              subtitle: 'Настрой Lumo так, как тебе удобно',
            ),
            ProfilePage(user: user),
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName?.trim();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: _purple.withValues(alpha: 0.2),
              child: const Icon(Icons.person_rounded, size: 42, color: _cyan),
            ),
            const SizedBox(height: 18),
            Text(
              name == null || name.isEmpty ? 'Пользователь Lumo' : name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(user?.email ?? '', style: const TextStyle(color: _muted)),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Выйти из аккаунта'),
            ),
          ],
        ),
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
                      Text('Lumo', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                      Text('Твои люди. Твои разговоры.', style: TextStyle(color: _muted, fontSize: 12)),
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
            child: Text('СООБЩЕНИЯ', style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          ),
        ),
        const SliverFillRemaining(hasScrollBody: false, child: _EmptyChats()),
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
                boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.16), blurRadius: 36)],
              ),
              child: const Icon(Icons.forum_rounded, size: 42, color: _cyan),
            ),
            const SizedBox(height: 22),
            const Text('Пока здесь тихо', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.icon, required this.title, required this.subtitle});
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
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: _muted)),
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
        boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.28), blurRadius: 18, spreadRadius: 1)],
      ),
      child: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: size * 0.53),
    );
  }
}
