import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LumoApp());
}

const bg = Color(0xFF090B14);
const surface = Color(0xFF131727);
const muted = Color(0xFF8992AC);
const cyan = Color(0xFF42D7FF);
const purple = Color(0xFF9470FF);

class LumoApp extends StatelessWidget {
  const LumoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Lumo', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark),
      useMaterial3: true),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator(color: cyan)));
      }
      return snap.hasData ? const HomeScreen() : const PhoneAuthScreen();
    },
  );
}

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});
  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phone = TextEditingController();
  final code = TextEditingController();
  String? verificationId, error, info;
  int? resendToken;
  bool codeSent = false, loading = false;

  @override
  void dispose() { phone.dispose(); code.dispose(); super.dispose(); }

  Future<void> sendCode() async {
    final number = phone.text.trim().replaceAll(' ', '');
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(number)) {
      setState(() => error = 'Введи номер в международном формате, например +4915112345678.');
      return;
    }
    setState(() { loading = true; error = null; info = null; });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: number,
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          try { await FirebaseAuth.instance.signInWithCredential(credential); }
          on FirebaseAuthException catch (e) {
            if (mounted) setState(() => error = messageFor(e.code));
          }
        },
        verificationFailed: (e) {
          if (mounted) setState(() { loading = false; error = messageFor(e.code); });
        },
        codeSent: (id, token) {
          if (mounted) setState(() {
            verificationId = id; resendToken = token; codeSent = true;
            loading = false; info = 'SMS-код отправлен.';
          });
        },
        codeAutoRetrievalTimeout: (id) => verificationId = id,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() { loading = false; error = messageFor(e.code); });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'Не удалось отправить SMS. Попробуй позже.'; });
    }
  }

  Future<void> verifyCode() async {
    if (verificationId == null || code.text.trim().length != 6) {
      setState(() => error = 'Введи шестизначный код из SMS.'); return;
    }
    setState(() { loading = true; error = null; });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: code.text.trim());
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      setState(() => error = messageFor(e.code));
    } catch (_) {
      setState(() => error = 'Не удалось подтвердить номер. Попробуй ещё раз.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String messageFor(String code) {
    switch (code) {
      case 'invalid-phone-number': return 'Проверь формат номера.';
      case 'invalid-verification-code': return 'Неверный SMS-код.';
      case 'session-expired': return 'Код устарел. Запроси новый.';
      case 'too-many-requests': return 'Слишком много попыток. Попробуй позже.';
      case 'quota-exceeded': return 'Лимит SMS временно исчерпан.';
      case 'operation-not-allowed': return 'В Firebase включи вход по номеру телефона.';
      case 'network-request-failed': return 'Проверь подключение к интернету.';
      default: return 'Не удалось выполнить действие. Попробуй ещё раз.';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Center(child: LumoMark(size: 76)),
          const SizedBox(height: 22),
          const Text('Lumo', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(codeSent ? 'Подтверди свой номер' : 'Вход и регистрация по номеру',
            textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 16)),
          const SizedBox(height: 30),
          if (!codeSent) TextField(
            controller: phone, keyboardType: TextInputType.phone,
            decoration: fieldDecoration('Номер телефона', Icons.phone_outlined, '+4915112345678'),
          ) else ...[
            Text('SMS отправлено на ${phone.text.trim()}',
              textAlign: TextAlign.center, style: const TextStyle(color: muted)),
            const SizedBox(height: 16),
            TextField(controller: code, keyboardType: TextInputType.number,
              maxLength: 6, decoration: fieldDecoration('Код из SMS', Icons.sms_outlined)),
            TextButton(onPressed: loading ? null : () => setState(() {
              codeSent = false; verificationId = null; code.clear(); error = null; info = null;
            }), child: const Text('Изменить номер')),
          ],
          if (info != null) Padding(padding: const EdgeInsets.only(top: 12),
            child: Text(info!, textAlign: TextAlign.center, style: const TextStyle(color: cyan))),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
            child: Text(error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFF8585)))),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: loading ? null : (codeSent ? verifyCode : sendCode),
            style: FilledButton.styleFrom(backgroundColor: purple, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: loading ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : Text(codeSent ? 'Подтвердить код' : 'Получить SMS-код')),
          if (codeSent) TextButton(onPressed: loading ? null : sendCode,
            child: const Text('Отправить код ещё раз')),
        ]),
      ),
    ))),
  );
}

InputDecoration fieldDecoration(String label, IconData icon, [String? hint]) => InputDecoration(
  labelText: label, hintText: hint, prefixIcon: Icon(icon, color: muted),
  filled: true, fillColor: surface,
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  static const tabs = [
    ( 'Чаты', Icons.chat_bubble_rounded ),
    ( 'Контакты', Icons.people_alt_rounded ),
    ( 'Настройки', Icons.settings_rounded ),
    ( 'Профиль', Icons.person_rounded ),
  ];
  @override
  Widget build(BuildContext context) {
    final pages = [
      const ChatsPage(),
      const PlaceholderPage(icon: Icons.people_alt_rounded, title: 'Контакты', subtitle: 'Здесь появятся твои контакты Lumo'),
      const PlaceholderPage(icon: Icons.settings_rounded, title: 'Настройки', subtitle: 'Настрой Lumo так, как тебе удобно'),
      ProfilePage(user: FirebaseAuth.instance.currentUser),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: selected, children: pages)),
      bottomNavigationBar: NavigationBar(height: 76, backgroundColor: const Color(0xFF101421),
        selectedIndex: selected, onDestinationSelected: (i) => setState(() => selected = i),
        destinations: [for (var i = 0; i < tabs.length; i++)
          NavigationDestination(icon: Icon(tabs[i].$2, color: muted),
            selectedIcon: Icon(tabs[i].$2, color: cyan), label: tabs[i].$1)]),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.user});
  final User? user;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircleAvatar(radius: 42, backgroundColor: Color(0x339470FF),
        child: Icon(Icons.person_rounded, size: 42, color: cyan)),
      const SizedBox(height: 18),
      const Text('Профиль Lumo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text(user?.phoneNumber ?? '', style: const TextStyle(color: muted)),
      const SizedBox(height: 26),
      OutlinedButton.icon(onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.logout_rounded), label: const Text('Выйти из аккаунта')),
    ]),
  ));
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(22,20,22,18),
      child: Row(children: [
        const LumoMark(size: 46), const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Lumo', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          Text('Твои люди. Твои разговоры.', style: TextStyle(color: muted, fontSize: 12)),
        ])),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded, color: cyan)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit_square, color: purple)),
      ]))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(22,4,22,14),
      child: Container(padding: const EdgeInsets.symmetric(horizontal:16,vertical:13),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18)),
        child: const Row(children: [Icon(Icons.search_rounded,color:muted), SizedBox(width:10),
          Text('Поиск по чатам',style:TextStyle(color:muted))])))),
    const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(22,8,22,12),
      child: Text('СООБЩЕНИЯ',style:TextStyle(color:muted,fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1.5)))),
    const SliverFillRemaining(hasScrollBody:false, child: Center(child: Padding(
      padding: EdgeInsets.all(36), child: Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        Icon(Icons.forum_rounded,size:64,color:cyan), SizedBox(height:22),
        Text('Пока здесь тихо',style:TextStyle(fontSize:20,fontWeight:FontWeight.w700)),
        SizedBox(height:8), Text('Когда начнёшь общаться, твои переписки появятся здесь.',
          textAlign:TextAlign.center,style:TextStyle(color:muted,height:1.5)),
      ])))),
  ]);
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key,required this.icon,required this.title,required this.subtitle});
  final IconData icon; final String title, subtitle;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    Icon(icon,size:54,color:cyan), const SizedBox(height:18),
    Text(title,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w700)),
    const SizedBox(height:8), Text(subtitle,textAlign:TextAlign.center,style:const TextStyle(color:muted)),
  ]));
}

class LumoMark extends StatelessWidget {
  const LumoMark({super.key,this.size=48});
  final double size;
  @override
  Widget build(BuildContext context) => Container(width:size,height:size,
    decoration:BoxDecoration(borderRadius:BorderRadius.circular(size*.32),
      gradient:const LinearGradient(colors:[cyan,purple]),
      boxShadow:[BoxShadow(color:purple.withValues(alpha:.28),blurRadius:18)]),
    child:Icon(Icons.chat_bubble_rounded,color:Colors.white,size:size*.53));
}
