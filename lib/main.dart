import 'package:flutter/material.dart';
import 'dart:async';
import 'services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/ai_chat_sheet.dart';
import 'screens/contact_us_screen.dart';
import 'screens/settings_screen.dart';
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();
void main() {
  runApp(MyApp());
}

//  DATA
class AppData {
  static double balance = 11140.00;

  static List<Map<String, String>> transactions = [];
  

  //  إضافة فلوس
  static void add(double amount) {
    balance += amount;

    transactions.insert(0, {
      "title": "إضافة",
      "amount": "+$amount",
      "time": DateTime.now().toString(),
      
    });
    addNotification("تم إضافة $amount جنيه");
  }

  //  سحب فلوس
  static bool withdraw(double amount) {
    addNotification("تم سحب $amount جنيه");
    if (amount > balance) return false;

    balance -= amount;

    transactions.insert(0, {
      "title": "سحب",
      "amount": "-$amount",
      "time": DateTime.now().toString(),
    });

    return true;
  }

  //  تحويل
  
  static bool transfer(String phone, double amount) {
    if (amount > balance) return false;

    balance -= amount;

    transactions.insert(0, {
      "title": "تحويل إلى $phone",
      "amount": "-$amount",
      "time": DateTime.now().toString(),
      
    });
    addNotification("تم تحويل $amount إلى $phone");

    return true;
  }
  static List<Map<String, String>> notifications = [];

//  إضافة إشعار
static void addNotification(String msg) {
  notifications.insert(0, {
    "msg": msg,
    "time": DateTime.now().toString(),
  });
}
}
class AppNotifier {
  static void show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  static void lowBalance(BuildContext context) {
    if (AppData.balance < 100) {
      show(context, "⚠️ رصيدك أقل من 100 جنيه");
    }
  }
}

//  APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
  debugShowCheckedModeBanner: false,
  scaffoldMessengerKey: messengerKey,

  theme: ThemeData(
  scaffoldBackgroundColor: const Color(0xFF0B0F1A),
  canvasColor: const Color(0xFF0B0F1A),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  textTheme: GoogleFonts.cairoTextTheme(),
),

  home: SplashScreen(),
);
  }
}

//  SPLASH
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final loggedIn = prefs.getBool("logged_in") ?? false;

    await Future.delayed(
  const Duration(seconds: 2),
);

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFF0B0F1A),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 1200),
          tween: Tween<double>(
            begin: 0.6,
            end: 1,
          ),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: Image.asset(
            "assets/images/logo.png",
             width: 145,
            height: 145,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Cash Flow",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "System for Financial Cash Flow",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    ),
  ),
);
  }
}

// LOGIN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> doLogin() async {
    final emailText = email.text.trim();
    final passText = password.text.trim();

    if (emailText.isEmpty || passText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اكتب البريد الإلكتروني وكلمة المرور"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = await ApiService.login(
        email: emailText,
        password: passText,
      );
    
final prefs = await SharedPreferences.getInstance();
await prefs.setBool("logged_in", true);
await prefs.setString("user_id", user["id"].toString());
await prefs.setString("user_name", user["name"].toString());
await prefs.setString("user_email", user["email"].toString());
await prefs.setString("user_role", user["role"].toString());
await prefs.setString("phone", user["phone"]?.toString() ?? "");

if (!mounted) return;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const HomeScreen(),
  ),
);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: const Color(0xFF5EF2E3)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF111A2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF5EF2E3)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F1A),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5EF2E3),
                          Color(0xFF00B4FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 14),


                  const SizedBox(height: 22),
                  const Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "ادخل بيانات حسابك للمتابعة",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white),
                    decoration: fieldDecoration(
                      hint: "البريد الإلكتروني",
                      icon: Icons.email_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: password,
                    obscureText: hidePassword,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white),
                    decoration: fieldDecoration(
                      hint: "كلمة المرور",
                      icon: Icons.lock_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: loading ? null : doLogin,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5EF2E3),
                            Color(0xFF00B4FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: loading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "دخول",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

TextButton(
  onPressed: loading
      ? null
      : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
            ),
          );
        },
  child: const Text(
    "إنشاء حساب جديد",
    style: TextStyle(
      color: Color(0xFF5EF2E3),
      fontWeight: FontWeight.w800,
    ),
  ),
),

                  const SizedBox(height: 18),

                  const Text(
                    "لا يمكن الدخول إلا بحساب مسجل في النظام",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//   BOTTOM NAV

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  final PageController pageController =
      PageController();
     late final List<Widget> screens;

@override
void initState() {
  super.initState();

  screens = [
    HomeContent(
      onOpenNotifications: () {
        pageController.animateToPage(
          3,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );

        setState(() {
          currentIndex = 3;
        });
      },
    ),
    const TransactionsScreen(),
    const ClientScreen(),
    const NotificationsScreen(),
  ];
}

      @override

void dispose() {

  pageController.dispose();

  super.dispose();

}

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(

children: [

PageView(

controller: pageController,

onPageChanged: (index){

setState(() {

currentIndex = index;

});

},

children: screens,

),

],

),

floatingActionButtonLocation:
FloatingActionButtonLocation.endFloat,

floatingActionButton:

Padding(

padding: const EdgeInsets.only(
bottom: 12,
right: 5,
),

child:

GestureDetector(

onTap: () {

Navigator.push(

context,

MaterialPageRoute(

builder: (_) {

return const AIChatSheet();

},

),

);

},

child:

Container(

padding:

const EdgeInsets.symmetric(
horizontal: 16,
vertical: 12,
),

decoration:

BoxDecoration(

color:
const Color(0xFF111A2E),

borderRadius:
BorderRadius.circular(24),

boxShadow: [

BoxShadow(

color:
Colors.cyan.withOpacity(.25),

blurRadius: 18,

)

],

),

child:

const Row(

mainAxisSize:
MainAxisSize.min,

children: [

Icon(
Icons.auto_awesome,
color: Color(0xFF5EF2E3),
),

SizedBox(width: 8),

Text(

"Ask AI",

style: TextStyle(

color: Colors.white,

fontWeight:
FontWeight.bold,

),

)

],

),

),

),

),


      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0B0F1A),
        selectedItemColor: const Color(0xFF5EF2E3),
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        onTap: (index) {

  pageController.animateToPage(

    index,

    duration:
        const Duration(
      milliseconds: 250,
    ),

    curve:
        Curves.easeInOut,

  );

  setState(() {

    currentIndex = index;

  });

},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: "العمليات",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "العملاء",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: "الإشعارات",
          ),
        ],
      ),
    );
  }
}
//  HOME CONTENT 
class HomeContent extends StatefulWidget {
  final VoidCallback onOpenNotifications;

  const HomeContent({
    super.key,
    required this.onOpenNotifications,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool loading = true;
  Map<String, dynamic> summary = {};
  int unreadNotifications = 0;
  Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    ),
    (route) => false,
  );
}

  @override
void initState() {
  super.initState();
  loadSummary();
  loadUnreadNotificationsCount();
}

  Future<void> loadSummary() async {
    try {
      final data = await ApiService.getDashboardSummary();

      if (!mounted) return;

      setState(() {
        summary = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل تحميل بيانات الرئيسية"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> loadUnreadNotificationsCount() async {
  try {
    final data = await ApiService.getNotifications();

    final unread = data.where((item) {
      final readValue = (item["is_read"] ?? item["read"] ?? "0").toString();
      return readValue == "0" || readValue == "false";
    }).length;

    if (!mounted) return;

    setState(() {
      unreadNotifications = unread;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      unreadNotifications = 0;
    });
  }
}

  double parseNumber(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  int parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  String formatMoney(dynamic value) {
    final number = parseNumber(value);

    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    }

    return number.toStringAsFixed(2);
  }

  List<Map<String, dynamic>> get latestTransactions {
    final data = summary["latest_transactions"];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  List<Map<String, dynamic>> get inactiveClients {
    final data = summary["inactive_clients"];
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  String typeTitle(String type) {
    switch (type) {
      case "sale":
        return "بيع";
      case "purchase":
        return "شراء";
      case "receive":
        return "استلام";
      case "pay":
        return "دفع";
      default:
        return "عملية";
    }
  }

  IconData typeIcon(String type) {
    switch (type) {
      case "sale":
        return Icons.shopping_bag_rounded;
      case "purchase":
        return Icons.shopping_cart_rounded;
      case "receive":
        return Icons.call_received_rounded;
      case "pay":
        return Icons.call_made_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color typeColor(String type) {
    switch (type) {
      case "sale":
        return const Color(0xFF00B4FF);
      case "purchase":
        return const Color(0xFFFFD32A);
      case "receive":
        return const Color(0xFF42E695);
      case "pay":
        return const Color(0xFFFF7A9E);
      default:
        return const Color(0xFF5EF2E3);
    }
  }

  String cleanDate(dynamic value) {
    final text = (value ?? "").toString();
    if (text.isEmpty) return "غير معروف";
    if (text.length >= 16) return text.substring(0, 16);
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5EF2E3),
                ),
              )
            : RefreshIndicator(
                color: const Color(0xFF5EF2E3),
                backgroundColor: const Color(0xFF111A2E),
                onRefresh: loadSummary,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  children: [
                    buildHeader(),
                    const SizedBox(height: 18),
                   buildMainBalanceCard(),

const SizedBox(height: 12),

buildTopClientsMiniRow(),

const SizedBox(height: 20),

buildQuickStatsGrid(),
                    const SizedBox(height: 20),
                    buildTodaySection(),
                    const SizedBox(height: 20),
                    buildLatestTransactionsSection(),
                    const SizedBox(height: 20),
                    buildInactiveClientsSection(),
                    const SizedBox(height: 20),

                    buildContactUsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildHeader() {
  return Row(
    children: [
      InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onOpenNotifications,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF111A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Stack(
  clipBehavior: Clip.none,
  children: [
    const Center(
      child: Icon(
        Icons.notifications_none_rounded,
        color: Color(0xFF5EF2E3),
      ),
    ),

    if (unreadNotifications > 0)
      Positioned(
        right: 7,
        top: 7,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF111A2E),
              width: 1.5,
            ),
          ),
          constraints: const BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            unreadNotifications > 99
                ? "99+"
                : unreadNotifications.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
  ],
),
        ),
      ),
      const SizedBox(width: 10),

InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );

  },
  child: Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: const Color(0xFF111A2E),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.06),
      ),
    ),
    child: const Icon(
      Icons.settings_rounded,
      color: Color(0xFF5EF2E3),
    ),
  ),
),

      const SizedBox(width: 10),

InkWell(
  borderRadius: BorderRadius.circular(16),
  onTap: logout,
  child: Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: const Color(0xFF111A2E),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: const Icon(
      Icons.logout_rounded,
      color: Colors.redAccent,
    ),
  ),
),
      const Spacer(),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "الرئيسية",
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "نظرة عامة على حركة المحل",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ],
  );
  
}
  Widget buildMainBalanceCard() {
    final totalBalance = summary["total_client_balance"] ?? 0;
    final clientsCount = parseInt(summary["total_clients"]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00D2FF),
            Color(0xFF0072FF),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0072FF).withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
         Row(
  children: [
    InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: showFinancialDetails,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_rounded,
              color: Colors.white,
              size: 13,
            ),
            SizedBox(width: 4),
            Text(
              "الموقف المالي",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    ),

    const Spacer(),

    const Icon(
      Icons.account_balance_wallet_rounded,
      color: Colors.white,
      size: 24,
    ),

    const SizedBox(width: 6),

    const Text(
  "أرصدة العملاء",
  style: TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  ),
),
  ],
),
          const SizedBox(height: 20),
          Text(
            "${formatMoney(totalBalance)} ج.م",
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$clientsCount عميل مسجل",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  void showFinancialDetails() {
  final sales =
      parseNumber(summary["total_sales"]);

  final purchases =
      parseNumber(summary["total_purchases"]);

  final received =
      parseNumber(summary["total_received"]);

  final paid =
      parseNumber(summary["total_paid"]);

  final cash = received - paid;

  final inventory =
      purchases - sales;

  final receivables = received;

  final liabilities = paid;

  final currentPosition =
      cash +
      inventory +
      receivables -
      liabilities;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF111A2E),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "تفاصيل الموقف المالي",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 28),

            financialRow(
              "النقدية",
              cash,
              Icons.attach_money_rounded,
              const Color(0xFF63FFB0),
            ),

            financialRow(
              "قيمة المخزون",
              inventory,
              Icons.inventory_2_rounded,
              const Color(0xFF59F3FF),
            ),

            financialRow(
              "المستحقات",
              receivables,
              Icons.group_add_rounded,
              const Color(0xFF63FFB0),
            ),

            financialRow(
              "الالتزامات",
              -liabilities,
              Icons.person_remove_alt_1_rounded,
              const Color(0xFFFF7D9C),
            ),

            const SizedBox(height: 18),

            Divider(
              color:
                  Colors.white.withOpacity(0.08),
            ),

            const SizedBox(height: 18),

            financialRow(
              "الموقف المالي الحالي",
              currentPosition,
              Icons.account_balance_wallet_rounded,
              Colors.white,
              isBig: true,
            ),

            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Widget financialRow(
  String title,
  double amount,
  IconData icon,
  Color color, {
  bool isBig = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isBig ? 15 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Text(
          "${amount.toStringAsFixed(0)} ج.م",
          style: TextStyle(
            color: color,
            fontSize: isBig ? 20 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}
Widget buildTopClientsMiniRow() {
  final topPaid =
      summary["top_paid_client"];

  final topDebt =
      summary["top_debt_client"];

  return Row(
    children: [
      Expanded(
        child: miniClientStatus(
          title: "الأكثر سدادًا",
          name:
              topPaid?["name"] ?? "-",
          amount: parseNumber(
            topPaid?["balance"],
          ),
          color: const Color(0xFF63FFB0),
        ),
      ),

      const SizedBox(width: 10),

      Expanded(
        child: miniClientStatus(
          title: "الأكثر مديونية",
          name:
              topDebt?["name"] ?? "-",
          amount: parseNumber(
            topDebt?["balance"],
          ),
          color: const Color(0xFFFF7D9C),
        ),
      ),
    ],
  );
}

Widget miniClientStatus({
  required String title,
  required String name,
  required double amount,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 10,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2E),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.white.withOpacity(0.05),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.end,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "${formatMoney(amount)} ج.م",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

  Widget buildQuickStatsGrid() {
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.25,
    children: [
      buildStatCard(
        title: "إجمالي المبيعات",
        value: "${formatMoney(summary["total_sales"])} ج.م",
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFF00B4FF),
        onTap: () {
          showHomeTransactionsByType(
            type: "sale",
            title: "تفاصيل المبيعات",
          );
        },
      ),
      buildStatCard(
        title: "إجمالي المشتريات",
        value: "${formatMoney(summary["total_purchases"])} ج.م",
        icon: Icons.shopping_cart_rounded,
        color: const Color(0xFFFFD32A),
        onTap: () {
          showHomeTransactionsByType(
            type: "purchase",
            title: "تفاصيل المشتريات",
          );
        },
      ),
      buildStatCard(
        title: "إجمالي المستلم",
        value: "${formatMoney(summary["total_received"])} ج.م",
        icon: Icons.call_received_rounded,
        color: const Color(0xFF42E695),
        onTap: () {
          showHomeTransactionsByType(
            type: "receive",
            title: "تفاصيل المستلم",
          );
        },
      ),
      buildStatCard(
        title: "إجمالي المدفوع",
        value: "${formatMoney(summary["total_paid"])} ج.م",
        icon: Icons.call_made_rounded,
        color: const Color(0xFFFF7A9E),
        onTap: () {
          showHomeTransactionsByType(
            type: "pay",
            title: "تفاصيل المدفوع",
          );
        },
      ),
    ],
  );
}

  Widget buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  VoidCallback? onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
void showHomeTransactionsByType({
  required String type,
  required String title,
}) {
  bool sheetLoading = true;
  List<Map<String, dynamic>> sheetTransactions = [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> loadSheetTransactions() async {
            try {
              final data = await ApiService.getTransactions();

              final filtered = data.where((item) {
                return (item["type"] ?? "").toString() == type;
              }).toList();

              if (!Navigator.of(sheetContext).mounted) return;

              setSheetState(() {
                sheetTransactions = filtered;
                sheetLoading = false;
              });
            } catch (e) {
              if (!Navigator.of(sheetContext).mounted) return;

              setSheetState(() {
                sheetLoading = false;
              });
            }
          }

          if (sheetLoading && sheetTransactions.isEmpty) {
            Future.microtask(loadSheetTransactions);
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.82,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${sheetTransactions.length} عملية",
                        style: const TextStyle(
                          color: Color(0xFF5EF2E3),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 18),

                      if (sheetLoading)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(
                            color: Color(0xFF5EF2E3),
                          ),
                        )
                      else if (sheetTransactions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172642),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "لا توجد عمليات",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        ...sheetTransactions.map((item) {
                          return buildHomeTransactionCard(item);
                        }),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
Widget buildHomeTransactionCard(Map<String, dynamic> item) {
  final type = (item["type"] ?? "").toString();
  final title = (item["title"] ?? "عملية").toString();
  final note = (item["note"] ?? "").toString();
  final amount = item["amount"] ?? "0";
  final createdAt = cleanDate(item["created_at"]);
  final color = typeColor(type);

  final partyType = (item["party_type"] ?? "").toString();
  final partyId = (item["party_id"] ?? "").toString();

  String partyText = "غير محدد";

  if (partyType == "client") {
    partyText = "عميل رقم $partyId";
  } else if (partyType == "supplier") {
    partyText = "مورد رقم $partyId";
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFF172642),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: color.withOpacity(0.25),
      ),
    ),
    child: Row(
      children: [
        Text(
          "${formatMoney(amount)} ج.م",
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                partyText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),

              if (note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 4),

              Text(
                createdAt,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            typeIcon(type),
            color: color,
            size: 21,
          ),
        ),
      ],
    ),
  );
}

  Widget buildTodaySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "ملخص اليوم",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          buildTodayRow(
            "مبيعات اليوم",
            summary["today_sales"],
            Icons.shopping_bag_rounded,
            const Color(0xFF00B4FF),
          ),
          buildTodayRow(
            "مشتريات اليوم",
            summary["today_purchases"],
            Icons.shopping_cart_rounded,
            const Color(0xFFFFD32A),
          ),
          buildTodayRow(
            "المستلم اليوم",
            summary["today_received"],
            Icons.call_received_rounded,
            const Color(0xFF42E695),
          ),
          buildTodayRow(
            "المدفوع اليوم",
            summary["today_paid"],
            Icons.call_made_rounded,
            const Color(0xFFFF7A9E),
          ),
        ],
      ),
    );
  }

  Widget buildTodayRow(
    String title,
    dynamic value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            "${formatMoney(value)} ج.م",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }

  Widget buildLatestTransactionsSection() {
    final list = latestTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "آخر العمليات",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          buildEmptyBox("لا توجد عمليات حديثة")
        else
          ...list.map((item) => buildTransactionMiniCard(item)),
      ],
    );
  }

  Widget buildTransactionMiniCard(Map<String, dynamic> item) {
    final type = (item["type"] ?? "").toString();
    final title = (item["title"] ?? "عملية").toString();
    final amount = item["amount"] ?? 0;
    final createdAt = cleanDate(item["created_at"]);
    final color = typeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(
            "${formatMoney(amount)} ج.م",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${typeTitle(type)} • $createdAt",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              typeIcon(type),
              color: color,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInactiveClientsSection() {
    final list = inactiveClients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          "عملاء يحتاجون متابعة",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          buildEmptyBox("لا يوجد عملاء يحتاجون متابعة")
        else
          ...list.map((client) => buildInactiveClientCard(client)),
      ],
    );
  }

  Widget buildInactiveClientCard(Map<String, dynamic> client) {
    final name = (client["name"] ?? "عميل").toString();
    final phone = (client["phone"] ?? "").toString();
    final balance = client["balance"] ?? 0;
    final days = parseInt(client["inactive_days"]);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD32A).withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Text(
            "$days يوم",
            style: const TextStyle(
              color: Color(0xFFFFD32A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone.isEmpty
                      ? "الرصيد: ${formatMoney(balance)} ج.م"
                      : "$phone • الرصيد: ${formatMoney(balance)} ج.م",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD32A).withOpacity(0.16),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFFD32A),
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
  Widget buildContactUsSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2E),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      children: [

        const Icon(
  Icons.support_agent_rounded,
  color: Color(0xFF5EF2E3),
  size: 42,
),

const SizedBox(height: 12),
const SizedBox(height: 10),

const Text(
  "إذا كان لديك اقتراح أو مشكلة",
  textAlign: TextAlign.center,
  style: TextStyle(
    color: Colors.white54,
  ),
),

const SizedBox(height: 20),
        const Text(
          "تواصل معنا",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ContactUsScreen(),
      ),
    );
  },

  child: const Text(
    "تواصل معنا",
  ),
),

      ],
    ),
  );
}
}
class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final phone = TextEditingController();
  final amount = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text("تحويل الأموال"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // 💳 كارت
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  // 📱 رقم المستلم
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                      labelText: "رقم المستلم",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF0D0D0D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  //  المبلغ
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
                      labelText: "المبلغ",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF0D0D0D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  //  زر التحويل
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              double v =
                                  double.tryParse(amount.text) ?? 0;

                              if (phone.text.isEmpty || v <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("ادخل بيانات صحيحة")),
                                );
                                return;
                              }

                              setState(() => loading = true);

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() => loading = false);

                                if (AppData.transfer(phone.text, v)) {
                                 AppNotifier.show(context, "...");
Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("تم التحويل بنجاح")),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("الرصيد غير كافي")),
                                  );
                                }
                              });
                            },
                      child: loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "تحويل الآن",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //  الرصيد الحالي
            Text(
              "رصيدك الحالي: ${AppData.balance} جنيه",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMoneyScreen extends StatefulWidget {
  @override
  _AddMoneyScreenState createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final amount = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text("إضافة رصيد"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            //  كارت
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  //  إدخال المبلغ
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
                      labelText: "أدخل المبلغ",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF0D0D0D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  //  مبالغ سريعة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      quick(50),
                      quick(100),
                      quick(200),
                    ],
                  ),

                  SizedBox(height: 20),

                  //  زر الإضافة
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              double v =
                                  double.tryParse(amount.text) ?? 0;

                              if (v <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("ادخل مبلغ صحيح")),
                                );
                                return;
                              }

                              setState(() => loading = true);

                              Future.delayed(Duration(seconds: 1), () {
                                AppData.add(v);

                                setState(() => loading = false);

                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("تمت الإضافة بنجاح")),
                                );
                              });
                            },
                      child: loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "إضافة الآن",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //  الرصيد الحالي
            Text(
              "رصيدك الحالي: ${AppData.balance} جنيه",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  //  زر سريع
  Widget quick(double value) {
    return GestureDetector(
      onTap: () {
        amount.text = value.toString();
      },

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$value",
          style: TextStyle(color: Colors.deepPurple),
        ),
      ),
    );
  }
}

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final amount = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text("سحب الأموال"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            //  كارت السحب
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  //  إدخال المبلغ
                  TextField(
                    controller: amount,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.money_off, color: Colors.grey),
                      labelText: "أدخل المبلغ",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF0D0D0D),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  //  مبالغ سريعة
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      quick(50),
                      quick(100),
                      quick(200),
                    ],
                  ),

                  SizedBox(height: 20),

                  //  زر السحب
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              double v =
                                  double.tryParse(amount.text) ?? 0;

                              if (v <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("ادخل مبلغ صحيح")),
                                );
                                return;
                              }

                              setState(() => loading = true);

                              Future.delayed(Duration(seconds: 1), () {
                                setState(() => loading = false);

                                if (AppData.withdraw(v)) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("تم السحب بنجاح")),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("الرصيد غير كافي")),
                                  );
                                }
                              });
                            },
                      child: loading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "سحب الآن",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //  الرصيد الحالي
            Text(
              "رصيدك الحالي: ${AppData.balance} جنيه",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  //  زر سريع
  Widget quick(double value) {
    return GestureDetector(
      onTap: () {
        amount.text = value.toString();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$value",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> transactions = [];

  bool loading = true;
  String selectedFilter = "all";

  final List<Map<String, dynamic>> filters = const [
    {
      "key": "all",
      "title": "الكل",
      "icon": Icons.apps_rounded,
    },
    {
      "key": "sale",
      "title": "بيع",
      "icon": Icons.shopping_bag_rounded,
    },
    {
      "key": "purchase",
      "title": "شراء",
      "icon": Icons.shopping_cart_rounded,
    },
    {
      "key": "receive",
      "title": "استلام",
      "icon": Icons.call_received_rounded,
    },
    {
      "key": "pay",
      "title": "دفع",
      "icon": Icons.call_made_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final data = await ApiService.getTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل تحميل العمليات من السيرفر"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (selectedFilter == "all") {
      return transactions;
    }

    return transactions.where((item) {
      return (item["type"] ?? "").toString() == selectedFilter;
    }).toList();
  }

  double parseAmount(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  String formatMoney(dynamic value) {
    final amount = parseAmount(value);

    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }

  String typeTitle(String type) {
    switch (type) {
      case "sale":
        return "بيع";
      case "purchase":
        return "شراء";
      case "receive":
        return "استلام أموال";
      case "pay":
        return "دفع أموال";
      default:
        return "عملية";
    }
  }

  IconData typeIcon(String type) {
    switch (type) {
      case "sale":
        return Icons.shopping_bag_rounded;
      case "purchase":
        return Icons.shopping_cart_rounded;
      case "receive":
        return Icons.call_received_rounded;
      case "pay":
        return Icons.call_made_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color typeColor(String type) {
    switch (type) {
      case "sale":
        return const Color(0xFF00B4FF);
      case "purchase":
        return const Color(0xFFFFD32A);
      case "receive":
        return const Color(0xFF42E695);
      case "pay":
        return const Color(0xFFFF7A9E);
      default:
        return const Color(0xFF5EF2E3);
    }
  }

  String cleanDate(dynamic value) {
    final text = (value ?? "").toString();

    if (text.isEmpty) return "غير معروف";

    // لو التاريخ بالشكل: 2026-05-17 06:44:23
    if (text.length >= 16) {
      return text.substring(0, 16);
    }

    return text;
  }

  double get totalSales {
    return transactions
        .where((item) => (item["type"] ?? "").toString() == "sale")
        .fold<double>(0, (sum, item) => sum + parseAmount(item["amount"]));
  }

  double get totalPurchases {
    return transactions
        .where((item) => (item["type"] ?? "").toString() == "purchase")
        .fold<double>(0, (sum, item) => sum + parseAmount(item["amount"]));
  }

  double get totalReceived {
    return transactions
        .where((item) => (item["type"] ?? "").toString() == "receive")
        .fold<double>(0, (sum, item) => sum + parseAmount(item["amount"]));
  }

  double get totalPaid {
    return transactions
        .where((item) => (item["type"] ?? "").toString() == "pay")
        .fold<double>(0, (sum, item) => sum + parseAmount(item["amount"]));
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredTransactions;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08111F),
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5EF2E3),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF5EF2E3),
                  backgroundColor: const Color(0xFF111A2E),
                  onRefresh: loadTransactions,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                    children: [
                      buildHeader(),
                      const SizedBox(height: 18),
                      buildQuickActions(),
                      const SizedBox(height: 18),
                      buildSummaryGrid(),
                      const SizedBox(height: 18),
                      buildFilterBar(),
                      const SizedBox(height: 14),
                      buildSectionTitle(list.length),
                      const SizedBox(height: 10),
                      if (list.isEmpty)
                        buildEmptyState()
                      else
                        ...list.map((item) => buildTransactionCard(item)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: const [
        Text(
          "العمليات",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "متابعة البيع والشراء والتحصيل والدفع",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        buildActionCard(
          title: "بيع",
          icon: Icons.shopping_bag_rounded,
          colors: const [Color(0xFF00D2FF), Color(0xFF0072FF)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SalesScreen()),
            ).then((_) => loadTransactions());
          },
        ),
        buildActionCard(
          title: "شراء",
          icon: Icons.shopping_cart_rounded,
          colors: const [Color(0xFFFFD32A), Color(0xFFFF9F1C)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PurchaseScreen()),
            ).then((_) => loadTransactions());
          },
        ),
        buildActionCard(
          title: "استلام أموال",
          icon: Icons.call_received_rounded,
          colors: const [Color(0xFF42E695), Color(0xFF3BB2B8)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReceiveMoneyScreen()),
            ).then((_) => loadTransactions());
          },
        ),
        buildActionCard(
          title: "دفع أموال",
          icon: Icons.call_made_rounded,
          colors: const [Color(0xFFFF7A9E), Color(0xFFFF4D6D)],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PayMoneyScreen()),
            ).then((_) => loadTransactions());
          },
        ),
      ],
    );
  }

  Widget buildActionCard({
  required String title,
  required IconData icon,
  required List<Color> colors,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.bottomLeft,
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        buildSummaryCard(
          title: "المبيعات",
          value: "${formatMoney(totalSales)} ج.م",
          icon: Icons.shopping_bag_rounded,
          color: const Color(0xFF00B4FF),
        ),
        buildSummaryCard(
          title: "المشتريات",
          value: "${formatMoney(totalPurchases)} ج.م",
          icon: Icons.shopping_cart_rounded,
          color: const Color(0xFFFFD32A),
        ),
        buildSummaryCard(
          title: "المستلم",
          value: "${formatMoney(totalReceived)} ج.م",
          icon: Icons.call_received_rounded,
          color: const Color(0xFF42E695),
        ),
        buildSummaryCard(
          title: "المدفوع",
          value: "${formatMoney(totalPaid)} ج.م",
          icon: Icons.call_made_rounded,
          color: const Color(0xFFFF7A9E),
        ),
      ],
    );
  }

  Widget buildSummaryCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF111A2E),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textDirection: TextDirection.rtl,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final item = filters[index];
          final key = item["key"].toString();
          final active = selectedFilter == key;
          final color = key == "all" ? const Color(0xFF5EF2E3) : typeColor(key);

          return InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              setState(() {
                selectedFilter = key;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? color.withOpacity(0.18) : const Color(0xFF111A2E),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: active ? color.withOpacity(0.7) : Colors.white10,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item["icon"] as IconData,
                    color: active ? color : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    item["title"].toString(),
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white54,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSectionTitle(int count) {
    return Row(
      children: [
        const Text(
          "آخر العمليات",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          "$count عملية",
          style: const TextStyle(
            color: Color(0xFF5EF2E3),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget buildTransactionCard(Map<String, dynamic> item) {
    final type = (item["type"] ?? "").toString();
    final title = (item["title"] ?? "عملية").toString();
    final note = (item["note"] ?? "").toString();
    final amount = item["amount"] ?? "0";
    final createdAt = cleanDate(item["created_at"]);
    final color = typeColor(type);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => showTransactionDetails(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                typeIcon(type),
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    note.isEmpty ? typeTitle(type) : note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    createdAt,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  typeTitle(type),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${formatMoney(amount)} ج.م",
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: const [
          Icon(Icons.receipt_long_rounded, color: Colors.white38, size: 42),
          SizedBox(height: 12),
          Text(
            "لا توجد عمليات",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "ابدأ بإضافة بيع أو شراء أو استلام أموال",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void showTransactionDetails(Map<String, dynamic> item) {
  final type = (item["type"] ?? "").toString();
  final title = (item["title"] ?? "عملية").toString();
  final note = (item["note"] ?? "").toString();
  final amount = item["amount"] ?? "0";
  final createdAt = cleanDate(item["created_at"]);
  final color = typeColor(type);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.82,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  CircleAvatar(
                    radius: 32,
                    backgroundColor: color.withOpacity(0.16),
                    child: Icon(
                      typeIcon(type),
                      color: color,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    typeTitle(type),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "المبلغ",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${formatMoney(amount)} ج.م",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: color,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  buildDetailsRow("نوع العملية", typeTitle(type)),
                  buildDetailsRow("التاريخ", createdAt),

                  if (note.isNotEmpty)
                    buildDetailsRow("ملاحظات", note),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget buildDetailsRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  int selectedTab = 0; // 0 العملاء - 1 الموردون

  final TextEditingController search = TextEditingController();

  List<Map<String, dynamic>> clients = [];
  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> inactiveClients = [];

  bool loading = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> loadClients() async {
  try {
    final allClients = await ApiService.getClients();

    final allSuppliers =
        await ApiService.getSuppliers();

    final inactive =
        await ApiService.getInactiveClients(
      days: 30,
    );

    if (!mounted) return;

    setState(() {
      clients = allClients;
      suppliers = allSuppliers;
      inactiveClients = inactive;
      loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "فشل تحميل البيانات من السيرفر",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  List<Map<String, dynamic>> get filteredClients {
  final q = query.trim().toLowerCase();

  final source =
      selectedTab == 0
          ? clients
          : suppliers;

  return source.where((item) {
    final name =
        (item["name"] ?? "")
            .toString()
            .toLowerCase();

    final phone =
        (item["phone"] ?? "")
            .toString()
            .toLowerCase();

    return name.contains(q) ||
        phone.contains(q);
  }).toList();
}

  bool isInactiveClient(Map<String, dynamic> client) {
    final id = (client["id"] ?? "").toString();

    return inactiveClients.any((item) {
      return (item["id"] ?? "").toString() == id;
    });
  }

  double parseAmount(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  String formatMoney(dynamic value) {
    final amount = parseAmount(value);

    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }

  Color balanceColor(dynamic value) {
    final amount = parseAmount(value);

    if (amount > 0) return Colors.redAccent;
    if (amount < 0) return Colors.greenAccent;

    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredClients;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08111F),
        floatingActionButton: FloatingActionButton(
  backgroundColor: const Color(0xFF5EF2E3),
  elevation: 0,
  onPressed: () {
    if (selectedTab == 0) {
      showAddClientSheet();
    } else {
      showAddSupplierSheet();
    }
  },
  child: const Icon(
    Icons.add,
    color: Color(0xFF08111F),
  ),
),
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5EF2E3),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadClients,
                  color: const Color(0xFF5EF2E3),
                  backgroundColor: const Color(0xFF111A2E),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                    children: [
                      buildHeader(),
                      const SizedBox(height: 18),
                      buildTabs(),
                      const SizedBox(height: 14),
                      buildSearch(),
                      const SizedBox(height: 14),
                      if (inactiveClients.isNotEmpty && selectedTab == 0)
                        buildInactiveAlert(),
                      if (inactiveClients.isNotEmpty && selectedTab == 0)
                        const SizedBox(height: 14),
                      buildSummaryCard(),
                      const SizedBox(height: 14),
                      if (list.isEmpty)
                        buildEmptyState()
                      else
                        ...list.map((client) => buildClientCard(client)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: const [
              Text(
                "العملاء والموردين",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "إدارة الحسابات والتنبيهات",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: buildTabButton(
              title: "العملاء",
              index: 0,
              icon: Icons.people_alt_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: buildTabButton(
              title: "الموردون",
              index: 1,
              icon: Icons.local_shipping_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTabButton({
    required String title,
    required int index,
    required IconData icon,
  }) {
    final active = selectedTab == index;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF24395F) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: active ? const Color(0xFF5EF2E3) : Colors.white54,
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white54,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSearch() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: search,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            query = value;
          });
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "بحث بالاسم أو الهاتف أو الحالة",
          hintStyle: TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.white54),
        ),
      ),
    );
  }

  Widget buildInactiveAlert() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: showInactiveClientsSheet,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF3A2D13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "${inactiveClients.length} عميل لم يتعامل منذ أكثر من 30 يوم",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget buildSummaryCard() {
    final totalClientsBalance = clients.fold<double>(
  0,
  (sum, item) =>
      sum + parseAmount(item["balance"]),
);

final totalSuppliersBalance = suppliers.fold<double>(
  0,
  (sum, item) =>
      sum + parseAmount(item["balance"]),
);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: buildMiniStat(
              title: selectedTab == 0
    ? "عدد العملاء"
    : "عدد الموردين",

value: selectedTab == 0
    ? clients.length.toString()
    : suppliers.length.toString(),
              color: const Color(0xFF5EF2E3),
            ),
          ),
          Container(width: 1, height: 42, color: Colors.white10),
          Expanded(
            child: buildMiniStat(
              title: selectedTab == 0
    ? "أرصدة العملاء"
    : "أرصدة الموردين",
              value: selectedTab == 0
    ? "${formatMoney(totalClientsBalance)} ج.م"
    : "${formatMoney(totalSuppliersBalance)} ج.م",

color: (selectedTab == 0
            ? totalClientsBalance
            : totalSuppliersBalance) >= 0
    ? Colors.redAccent
    : Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMiniStat({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget buildClientCard(Map<String, dynamic> client) {
    final name = (client["name"] ?? "بدون اسم").toString();
    final phone = (client["phone"] ?? "").toString();
    final status = (client["status"] ?? "").toString();
    final balance = client["balance"] ?? "0";
    final inactive = isInactiveClient(client);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => showClientDetails(client),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: inactive ? const Color(0xFF182139) : const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: inactive
                ? Colors.orange.withOpacity(0.45)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: inactive
                    ? Colors.orange.withOpacity(0.18)
                    : const Color(0xFF1E88E5).withOpacity(0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                inactive
                    ? Icons.warning_amber_rounded
                    : Icons.person_rounded,
                color: inactive ? Colors.orange : const Color(0xFF5EF2E3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    phone.isEmpty ? "لا يوجد رقم هاتف" : phone,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24395F),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Color(0xFF5EF2E3),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "الرصيد",
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Text(
                  "${formatMoney(balance)} ج.م",
                  style: TextStyle(
                    color: balanceColor(balance),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: const [
          Icon(Icons.search_off_rounded, color: Colors.white38, size: 42),
          SizedBox(height: 12),
          Text(
            "لا توجد نتائج",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "جرّب تغيير كلمة البحث أو أضف عميل جديد",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void showAddClientSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "إضافة عميل جديد",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 18),
                    buildSheetInput(
                      controller: nameController,
                      label: "اسم العميل",
                      icon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 12),
                    buildSheetInput(
                      controller: phoneController,
                      label: "رقم الهاتف",
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5EF2E3),
                          foregroundColor: const Color(0xFF08111F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: saving
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final phone = phoneController.text.trim();

                                if (name.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("اكتب اسم العميل"),
                                    ),
                                  );
                                  return;
                                }

                                setSheetState(() {
                                  saving = true;
                                });

                               final prefs =
    await SharedPreferences.getInstance();

final userId = int.parse(
  prefs.getString("user_id") ?? "0",
);

final ok = await ApiService.addClient(
  name: name,
  phone: phone,
);
print("ADD CLIENT RESULT = $ok");

                                if (!mounted) return;

                                if (ok) {
                                  Navigator.pop(sheetContext);
                                  await loadClients();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("تم إضافة العميل بنجاح"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  setSheetState(() {
                                    saving = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("فشل إضافة العميل"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        child: saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF08111F),
                                ),
                              )
                            : const Text(
                                "حفظ العميل",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  void showAddSupplierSheet() {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool saving = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(26),
      ),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "إضافة مورد جديد",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 18),

                  buildSheetInput(
                    controller: nameController,
                    label: "اسم المورد",
                    icon: Icons.person_rounded,
                  ),

                  const SizedBox(height: 12),

                  buildSheetInput(
                    controller: phoneController,
                    label: "رقم الهاتف",
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF5EF2E3),
                        foregroundColor:
                            const Color(0xFF08111F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              final name =
                                  nameController.text.trim();

                              final phone =
                                  phoneController.text.trim();

                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "اكتب اسم المورد",
                                    ),
                                  ),
                                );
                                return;
                              }

                              setSheetState(() {
                                saving = true;
                              });

                              try {
                                final ok =
                                    await ApiService
                                        .addSupplier(
                                  name: name,
                                  phone: phone,
                                );

                                if (!mounted) return;

                                if (ok) {
                                  Navigator.pop(
                                      sheetContext);

                                  await loadClients();

                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "تم إضافة المورد بنجاح",
                                      ),
                                      backgroundColor:
                                          Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "فشل إضافة المورد",
                                      ),
                                      backgroundColor:
                                          Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(
                                        context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "خطأ: $e",
                                    ),
                                    backgroundColor:
                                        Colors.red,
                                  ),
                                );
                              }

                              if (mounted) {
                                setSheetState(() {
                                  saving = false;
                                });
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "إضافة المورد",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  Widget buildSheetInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFF5EF2E3), size: 20),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  void showClientDetails(Map<String, dynamic> client) {
  final id = int.tryParse((client["id"] ?? "0").toString()) ?? 0;
  final name = (client["name"] ?? "بدون اسم").toString();
  final phone = (client["phone"] ?? "").toString();
  final status = (client["status"] ?? "").toString();
  final balance = client["balance"] ?? "0";
  final lastActivity = (client["last_activity"] ?? "").toString();
  final inactive = isInactiveClient(client);

  bool sheetLoading = true;
  List<Map<String, dynamic>> clientTransactions = [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> loadClientTransactions() async {
            try {
              final data = await ApiService.getTransactions();

              final filtered = data.where((item) {
                final partyType = (item["party_type"] ?? "").toString();
                final partyId =
                    int.tryParse((item["party_id"] ?? "0").toString()) ?? 0;

                return partyType == "client" && partyId == id;
              }).toList();

              if (!Navigator.of(sheetContext).mounted) return;

              setSheetState(() {
                clientTransactions = filtered;
                sheetLoading = false;
              });
            } catch (e) {
              if (!Navigator.of(sheetContext).mounted) return;

              setSheetState(() {
                sheetLoading = false;
              });
            }
          }

          if (sheetLoading && clientTransactions.isEmpty) {
            Future.microtask(loadClientTransactions);
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.82,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      const SizedBox(height: 18),

                      CircleAvatar(
                        radius: 30,
                        backgroundColor: inactive
                            ? Colors.orange.withOpacity(0.18)
                            : const Color(0xFF5EF2E3).withOpacity(0.18),
                        child: Icon(
                          inactive
                              ? Icons.warning_amber_rounded
                              : Icons.person_rounded,
                          color: inactive
                              ? Colors.orange
                              : const Color(0xFF5EF2E3),
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        name,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 6),

                      if (status.isNotEmpty)
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF5EF2E3)),
                        ),

                      const SizedBox(height: 18),

                      buildDetailsRow("الهاتف", phone.isEmpty ? "غير مسجل" : phone),
                      buildDetailsRow("الرصيد", "${formatMoney(balance)} ج.م"),
                      buildDetailsRow(
                        "آخر تعامل",
                        lastActivity.isEmpty ? "غير معروف" : lastActivity,
                      ),

                      if (inactive)
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "هذا العميل لم يتعامل منذ أكثر من 30 يوم",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 22),

                      Row(
                        children: [
                          const Text(
                            "سجل العمليات",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${clientTransactions.length} عملية",
                            style: const TextStyle(
                              color: Color(0xFF5EF2E3),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (sheetLoading)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Color(0xFF5EF2E3),
                          ),
                        )
                      else if (clientTransactions.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172642),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "لا توجد عمليات لهذا العميل",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        ...clientTransactions.map((item) {
                          final type = (item["type"] ?? "").toString();
                          final title = (item["title"] ?? "عملية").toString();
                          final note = (item["note"] ?? "").toString();
                          final amount = item["amount"] ?? "0";
                          final createdAt =
                              cleanClientDate(item["created_at"]);
                          final color = clientTransactionColor(type);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: const Color(0xFF172642),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    clientTransactionIcon(type),
                                    color: color,
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        note.isEmpty
                                            ? clientTransactionTitle(type)
                                            : note,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        createdAt,
                                        style: const TextStyle(
                                          color: Colors.white30,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      clientTransactionTitle(type),
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      "${formatMoney(amount)} ج.م",
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
String cleanClientDate(dynamic value) {
  final text = (value ?? "").toString();

  if (text.isEmpty) return "غير معروف";

  if (text.length >= 16) {
    return text.substring(0, 16);
  }

  return text;
}

String clientTransactionTitle(String type) {
  switch (type) {
    case "sale":
      return "بيع";
    case "receive":
      return "استلام أموال";
    case "pay":
      return "دفع أموال";
    case "purchase":
      return "شراء";
    default:
      return "عملية";
  }
}

IconData clientTransactionIcon(String type) {
  switch (type) {
    case "sale":
      return Icons.shopping_bag_rounded;
    case "receive":
      return Icons.call_received_rounded;
    case "pay":
      return Icons.call_made_rounded;
    case "purchase":
      return Icons.shopping_cart_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

Color clientTransactionColor(String type) {
  switch (type) {
    case "sale":
      return const Color(0xFF00B4FF);
    case "receive":
      return const Color(0xFF42E695);
    case "pay":
      return const Color(0xFFFF7A9E);
    case "purchase":
      return const Color(0xFFFFD32A);
    default:
      return const Color(0xFF5EF2E3);
  }
}

  Widget buildDetailsRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showInactiveClientsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "العملاء الراكدين",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                if (inactiveClients.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "لا توجد تنبيهات ركود حاليًا",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: inactiveClients.length,
                      itemBuilder: (_, index) {
                        final item = inactiveClients[index];
                        final name = (item["name"] ?? "").toString();
                        final days = (item["inactive_days"] ?? "").toString();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172642),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                "$days يوم",
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class ReceiveScreen extends StatelessWidget {
  final String myNumber = "01012345678"; // رقمك

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text("استلام الأموال"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            // كارت الاستلام
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  //  رقمك
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("رقم المحفظة",
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        myNumber,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  //  QR 
                  Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.qr_code,
                        size: 120, color: Colors.black),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "اعرض هذا الكود ليتم التحويل إليك",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            //   نسخ الرقم
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("تم نسخ الرقم")),
                  );
                },
                child: Text("نسخ رقم المحفظة"),
              ),
            ),

            SizedBox(height: 10),

            //  مشاركة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {},
                child: Text("مشاركة"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RechargeScreen extends StatefulWidget {
  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final phone = TextEditingController();
  final amount = TextEditingController();

  String selectedNetwork = "Vodafone";
  bool loading = false;

  final networks = ["Vodafone", "Orange", "Etisalat", "WE"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text("شحن رصيد"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView( 
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [

              //  الكارت
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    //  الشبكة
                    DropdownButtonFormField<String>(
                      value: selectedNetwork,
                      dropdownColor: Color(0xFF1A1A1A),
                      style: TextStyle(color: Colors.white),
                      decoration: inputStyle("الشبكة", Icons.network_cell),
                      items: networks
                          .map((n) => DropdownMenuItem(
                                value: n,
                                child: Text(n),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedNetwork = v!);
                      },
                    ),

                    SizedBox(height: 15),

                    //  رقم الهاتف
                    TextField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: Colors.white),
                      decoration: inputStyle("رقم الهاتف", Icons.phone),
                    ),

                    SizedBox(height: 15),

                    //  المبلغ
                    TextField(
                      controller: amount,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: inputStyle("المبلغ", Icons.attach_money),
                    ),

                    SizedBox(height: 15),

                    //  مبالغ سريعة
                    Wrap(
                      spacing: 10,
                      children: [
                        quick(10),
                        quick(20),
                        quick(50),
                        quick(100),
                      ],
                    ),

                    SizedBox(height: 20),

                    //  زر الشحن
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: loading
                            ? null
                            : () {
                                double v =
                                    double.tryParse(amount.text) ?? 0;

                                if (phone.text.isEmpty || v <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("ادخل بيانات صحيحة")),
                                  );
                                  return;
                                }

                                setState(() => loading = true);

                                Future.delayed(Duration(seconds: 1), () {
                                  setState(() => loading = false);

                                  if (AppData.withdraw(v)) {
                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("تم الشحن بنجاح")),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("الرصيد غير كافي")),
                                    );
                                  }
                                });
                              },
                        child: loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "شحن الآن",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              //  الرصيد
              Text(
                "رصيدك الحالي: ${AppData.balance} جنيه",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  تصميم موحد
  InputDecoration inputStyle(String text, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      labelText: text,
      labelStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Color(0xFF0D0D0D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  //  زر سريع
  Widget quick(double value) {
    return GestureDetector(
      onTap: () {
        amount.text = value.toString();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "$value",
          style: TextStyle(color: Colors.deepPurple),
        ),
      ),
    );
  }
}

class BillsScreen extends StatefulWidget {
  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final number = TextEditingController();

  String selectedType = "كهرباء";
  double billAmount = 0;
  bool loading = false;

  final types = ["كهرباء", "مياه", "غاز", "إنترنت"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),

      appBar: AppBar(
        title: Text("دفع الفواتير"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      body: SingleChildScrollView( 
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            children: [

              // 💳 الكارت
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    //  نوع الفاتورة
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      dropdownColor: Color(0xFF1A1A1A),
                      style: TextStyle(color: Colors.white),
                      decoration: inputStyle("نوع الفاتورة", Icons.category),
                      items: types
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedType = v!);
                      },
                    ),

                    SizedBox(height: 15),

                    //  رقم الفاتورة
                    TextField(
                      controller: number,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration:
                          inputStyle("رقم الفاتورة", Icons.confirmation_number),
                    ),

                    SizedBox(height: 15),

                    //  استعلام
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                        onPressed: () {
                          if (number.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("ادخل رقم الفاتورة")),
                            );
                            return;
                          }

                          setState(() {
                            billAmount = 100 + number.text.length * 10;
                          });
                        },
                        child: Text("استعلام"),
                      ),
                    ),

                    SizedBox(height: 15),

                    //  عرض الفاتورة
                    if (billAmount > 0)
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text("قيمة الفاتورة"),
                            Text("$billAmount جنيه"),
                          ],
                        ),
                      ),

                    SizedBox(height: 20),

                    //  دفع
                    if (billAmount > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: loading
                              ? null
                              : () {
                                  setState(() => loading = true);

                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() => loading = false);

                                    if (AppData.withdraw(billAmount)) {
                                      Navigator.pop(context);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("تم الدفع بنجاح")),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text("الرصيد غير كافي")),
                                      );
                                    }
                                  });
                                },
                          child: loading
                              ? CircularProgressIndicator(
                                  color: Colors.white)
                              : Text("دفع الآن"),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              //  الرصيد
              Text(
                "رصيدك الحالي: ${AppData.balance} جنيه",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  تصميم موحد
  InputDecoration inputStyle(String text, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      labelText: text,
      labelStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Color(0xFF0D0D0D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      final data = await ApiService.getNotifications();

      if (!mounted) return;

      setState(() {
        notifications = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل تحميل التنبيهات من السيرفر"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  int get unreadCount {
    return notifications.where((item) {
      return parseInt(item["is_read"]) == 0;
    }).length;
  }

  String cleanDate(dynamic value) {
    final text = (value ?? "").toString();
    if (text.isEmpty) return "غير معروف";
    if (text.length >= 16) return text.substring(0, 16);
    return text;
  }

  IconData typeIcon(String type) {
    switch (type) {
      case "warning":
        return Icons.warning_amber_rounded;
      case "success":
        return Icons.check_circle_rounded;
      case "money":
        return Icons.payments_rounded;
      case "stock":
        return Icons.inventory_2_rounded;
      case "client":
        return Icons.person_search_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color typeColor(String type) {
    switch (type) {
      case "warning":
        return const Color(0xFFFFD32A);
      case "success":
        return const Color(0xFF42E695);
      case "money":
        return const Color(0xFF00B4FF);
      case "stock":
        return const Color(0xFFFF7A9E);
      case "client":
        return const Color(0xFF5EF2E3);
      default:
        return const Color(0xFF8EA7FF);
    }
  }

  String typeTitle(String type) {
    switch (type) {
      case "warning":
        return "تحذير";
      case "success":
        return "نجاح";
      case "money":
        return "مالي";
      case "stock":
        return "مخزون";
      case "client":
        return "عميل";
      default:
        return "تنبيه";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F1A),
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5EF2E3),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF5EF2E3),
                  backgroundColor: const Color(0xFF111A2E),
                  onRefresh: loadNotifications,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                    children: [
                      buildHeader(),
                      const SizedBox(height: 18),
                      buildSummaryCard(),
                      const SizedBox(height: 18),
                      buildSectionTitle(),
                      const SizedBox(height: 10),
                      if (notifications.isEmpty)
                        buildEmptyState()
                      else
                        ...notifications.map((item) => buildNotificationCard(item)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF111A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF5EF2E3),
          ),
        ),
        const Spacer(),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "التنبيهات",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "متابعة التنبيهات المهمة للمحل",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5EF2E3),
            Color(0xFF00B4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.campaign_rounded,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "ملخص التنبيهات",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "لديك $unreadCount تنبيه غير مقروء من أصل ${notifications.length}",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle() {
    return Row(
      children: [
        Text(
          "${notifications.length} تنبيه",
          style: const TextStyle(
            color: Color(0xFF5EF2E3),
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        const Text(
          "آخر التنبيهات",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget buildNotificationCard(Map<String, dynamic> item) {
    final title = (item["title"] ?? "تنبيه").toString();
    final message = (item["message"] ?? "").toString();
    final type = (item["type"] ?? "info").toString();
    final readValue = (item["is_read"] ?? item["read"] ?? "0").toString();
    final isRead = readValue == "1" || readValue == "true";
    final createdAt = cleanDate(item["created_at"]);
    final color = typeColor(type);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
  final id = int.tryParse((item["id"] ?? "0").toString()) ?? 0;

  // نخليه مقروء في الشاشة فورًا
  setState(() {
    item["is_read"] = "1";
    item["read"] = "1";
  });

  if (id > 0) {
    try {
      final ok = await ApiService.markNotificationAsRead(id);

      debugPrint("markNotificationAsRead ok = $ok, id = $id");

      // بعد ما السيرفر يرد، حمل القائمة تاني
      if (mounted) {
        await loadNotifications();
      }
    } catch (e) {
      debugPrint("markNotificationAsRead error: $e");
    }
  }

  if (!mounted) return;
  showNotificationDetails(item);
},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead ? Colors.white.withOpacity(0.05) : color.withOpacity(0.45),
          ),
        ),
        child: Row(
          children: [
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message.isEmpty ? typeTitle(type) : message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    "$createdAt • ${typeTitle(type)}",
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                typeIcon(type),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: Colors.white38,
            size: 44,
          ),
          SizedBox(height: 12),
          Text(
            "لا توجد تنبيهات",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "أي تنبيه جديد سيظهر هنا تلقائيًا",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void showNotificationDetails(Map<String, dynamic> item) {
  final title = (item["title"] ?? "تنبيه").toString();
  final message = (item["body"] ?? item["message"] ?? "").toString();
  final type = (item["type"] ?? "info").toString();
  final createdAt = cleanDate(item["created_at"]);
  final color = typeColor(type);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF111A2E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.82,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const SizedBox(height: 18),

                  CircleAvatar(
                    radius: 32,
                    backgroundColor: color.withOpacity(0.16),
                    child: Icon(
                      typeIcon(type),
                      color: color,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    typeTitle(type),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF172642),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Text(
                      message.isEmpty ? "لا توجد تفاصيل إضافية" : message,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  buildDetailsRow("التاريخ", createdAt),
                  buildDetailsRow("النوع", typeTitle(type)),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget buildDetailsRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white54),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController itemName = TextEditingController();
  final TextEditingController quantity = TextEditingController(text: "1");
  final TextEditingController unitPrice = TextEditingController();
  final TextEditingController note = TextEditingController();

  List<Map<String, dynamic>> clients = [];

  Map<String, dynamic>? selectedClient;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  @override
  void dispose() {
    itemName.dispose();
    quantity.dispose();
    unitPrice.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> loadClients() async {
    try {
      final data = await ApiService.getClients();

      if (!mounted) return;

      setState(() {
        clients = data;
        selectedClient = data.isNotEmpty ? data.first : null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل تحميل العملاء"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(",", ".")) ?? 0;
  }

  double get total {
    final q = parseNumber(quantity.text);
    final p = parseNumber(unitPrice.text);
    return q * p;
  }

  String formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  Future<void> saveSale() async {
    final client = selectedClient;
    final product = itemName.text.trim();
    final q = parseNumber(quantity.text);
    final price = parseNumber(unitPrice.text);
    final amount = total;

    if (client == null) {
      showMsg("اختار العميل أولًا", error: true);
      return;
    }

    if (product.isEmpty) {
      showMsg("اكتب اسم الصنف", error: true);
      return;
    }

    if (q <= 0) {
      showMsg("اكتب كمية صحيحة", error: true);
      return;
    }

    if (price <= 0) {
      showMsg("اكتب سعر صحيح", error: true);
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final clientId = int.tryParse((client["id"] ?? "0").toString());

      final ok = await ApiService.addTransaction(
        type: "sale",
        partyType: "client",
        partyId: clientId,
        title: product,
        amount: amount,
        note:
            "بيع $product - الكمية: ${formatMoney(q)} - سعر الوحدة: ${formatMoney(price)}${note.text.trim().isEmpty ? "" : " - ${note.text.trim()}"}",
      );

      if (clientId != null && clientId > 0) {
        await ApiService.updateClientActivity(clientId);
      }

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      if (ok) {
        itemName.clear();
        quantity.text = "1";
        unitPrice.clear();
        note.clear();

        showMsg("تم حفظ عملية البيع بنجاح");

        await loadClients();
      } else {
        showMsg("فشل حفظ عملية البيع", error: true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMsg("حدث خطأ أثناء الاتصال بالسيرفر", error: true);
    }
  }

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08111F),
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5EF2E3),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  children: [
                    buildHeader(),
                    const SizedBox(height: 18),
                    buildClientSelector(),
                    const SizedBox(height: 14),
                    buildSaleForm(),
                    const SizedBox(height: 14),
                    buildTotalCard(),
                    const SizedBox(height: 18),
                    buildSaveButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: const [
        Text(
          "بيع",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "تسجيل عملية بيع وربطها بالعميل",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget buildClientSelector() {
    if (clients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Text(
          "لا يوجد عملاء. أضف عميل أولًا من صفحة العملاء.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          const Text(
            "العميل",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF172642),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: selectedClient,
                isExpanded: true,
                dropdownColor: const Color(0xFF172642),
                iconEnabledColor: const Color(0xFF5EF2E3),
                style: const TextStyle(color: Colors.white),
                items: clients.map((client) {
                  final name = (client["name"] ?? "بدون اسم").toString();
                  final phone = (client["phone"] ?? "").toString();

                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: client,
                    child: Text(
                      phone.isEmpty ? name : "$name - $phone",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClient = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaleForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          buildInput(
            controller: itemName,
            label: "اسم الصنف",
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildInput(
                  controller: quantity,
                  label: "الكمية",
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildInput(
                  controller: unitPrice,
                  label: "سعر الوحدة",
                  icon: Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildInput(
            controller: note,
            label: "ملاحظات اختيارية",
            icon: Icons.note_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFF5EF2E3), size: 20),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00B4FF),
            Color(0xFF006CFF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "إجمالي عملية البيع",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            "${formatMoney(total)} ج.م",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5EF2E3),
          foregroundColor: const Color(0xFF08111F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: saving ? null : saveSale,
        icon: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF08111F),
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          saving ? "جاري الحفظ..." : "حفظ عملية البيع",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final TextEditingController itemName = TextEditingController();
  final TextEditingController quantity = TextEditingController(text: "1");
  final TextEditingController unitPrice = TextEditingController();
  final TextEditingController supplierName = TextEditingController();
  final TextEditingController note = TextEditingController();
  List<Map<String, dynamic>> suppliers = [];
Map<String, dynamic>? selectedSupplier;

  bool saving = false;

  
  Future<void> loadSuppliers() async {
  final data = await ApiService.getSuppliers();

  if (!mounted) return;

  setState(() {
    suppliers = data;
    selectedSupplier =
        data.isNotEmpty ? data.first : null;
  });
}
@override
void initState() {
  super.initState();
  loadSuppliers();
}
@override
  void dispose() {
    itemName.dispose();
    quantity.dispose();
    unitPrice.dispose();
    supplierName.dispose();
    note.dispose();
    super.dispose();
  }

  double parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(",", ".")) ?? 0;
  }

  double get total {
    final q = parseNumber(quantity.text);
    final p = parseNumber(unitPrice.text);
    return q * p;
  }

  String formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  Future<void> savePurchase() async {
    final product = itemName.text.trim();
    final supplierData = selectedSupplier;

if (supplierData == null) {
  showMsg("اختار المورد أولاً", error: true);
  return;
}

final supplier =
    (supplierData["name"] ?? "مورد").toString();

final supplierId =
    int.tryParse((supplierData["id"] ?? "0").toString());
    final q = parseNumber(quantity.text);
    final price = parseNumber(unitPrice.text);
    final amount = total;

    if (product.isEmpty) {
      showMsg("اكتب اسم الصنف", error: true);
      return;
    }

    if (supplier.isEmpty) {
      showMsg("اكتب اسم المورد", error: true);
      return;
    }

    if (q <= 0) {
      showMsg("اكتب كمية صحيحة", error: true);
      return;
    }

    if (price <= 0) {
      showMsg("اكتب سعر صحيح", error: true);
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final ok = await ApiService.addTransaction(
        type: "purchase",
        partyType: "supplier",
        partyId: supplierId,
        title: product,
        amount: amount,
        note:
            "شراء $product - المورد: $supplier - الكمية: ${formatMoney(q)} - سعر الوحدة: ${formatMoney(price)}${note.text.trim().isEmpty ? "" : " - ${note.text.trim()}"}",
      );

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      if (ok) {
        itemName.clear();
        quantity.text = "1";
        unitPrice.clear();
        supplierName.clear();
        note.clear();

        showMsg("تم حفظ عملية الشراء بنجاح");
      } else {
        showMsg("فشل حفظ عملية الشراء", error: true);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMsg("حدث خطأ أثناء الاتصال بالسيرفر", error: true);
    }
  }

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08111F),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              buildHeader(),
              const SizedBox(height: 18),
              buildPurchaseForm(),
              const SizedBox(height: 14),
              buildTotalCard(),
              const SizedBox(height: 18),
              buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: const [
        Text(
          "شراء",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "تسجيل عملية شراء من مورد",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget buildPurchaseForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
  padding: const EdgeInsets.symmetric(horizontal: 14),
  decoration: BoxDecoration(
    color: const Color(0xFF172642),
    borderRadius: BorderRadius.circular(16),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<Map<String, dynamic>>(
      value: selectedSupplier,
      dropdownColor: const Color(0xFF172642),
      isExpanded: true,
      iconEnabledColor: const Color(0xFFFFC107),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      hint: const Text(
        "اختر المورد",
        style: TextStyle(color: Colors.white54),
      ),
      items: suppliers.map((supplier) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: supplier,
          child: Text(
            (supplier["name"] ?? "مورد").toString(),
            textDirection: TextDirection.rtl,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedSupplier = value;
        });
      },
    ),
  ),
),
          const SizedBox(height: 12),
          buildInput(
            controller: itemName,
            label: "اسم الصنف",
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildInput(
                  controller: quantity,
                  label: "الكمية",
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: buildInput(
                  controller: unitPrice,
                  label: "سعر الوحدة",
                  icon: Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          buildInput(
            controller: note,
            label: "ملاحظات اختيارية",
            icon: Icons.note_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFFFFD32A), size: 20),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFD32A),
            Color(0xFFFF9F1C),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shopping_cart_rounded,
            color: Color(0xFF08111F),
            size: 34,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "إجمالي عملية الشراء",
              style: TextStyle(
                color: Color(0xFF08111F),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            "${formatMoney(total)} ج.م",
            style: const TextStyle(
              color: Color(0xFF08111F),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD32A),
          foregroundColor: const Color(0xFF08111F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: saving ? null : savePurchase,
        icon: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF08111F),
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          saving ? "جاري الحفظ..." : "حفظ عملية الشراء",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
class ReceiveMoneyScreen extends StatefulWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  State<ReceiveMoneyScreen> createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();

  List<Map<String, dynamic>> clients = [];
  Map<String, dynamic>? selectedClient;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> loadClients() async {
    try {
      final data = await ApiService.getClients();

      if (!mounted) return;

      setState(() {
        clients = data;
        selectedClient = data.isNotEmpty ? data.first : null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMsg("فشل تحميل العملاء", error: true);
    }
  }

  double parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(",", ".")) ?? 0;
  }

  String formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  Future<void> saveReceiveMoney() async {
    final client = selectedClient;
    final value = parseNumber(amount.text);

    if (client == null) {
      showMsg("اختار العميل أولًا", error: true);
      return;
    }

    if (value <= 0) {
      showMsg("اكتب مبلغ صحيح", error: true);
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final clientId = int.tryParse((client["id"] ?? "0").toString());
      final clientName = (client["name"] ?? "عميل").toString();

      final ok = await ApiService.addTransaction(
        type: "receive",
        partyType: "client",
        partyId: clientId,
        title: "استلام أموال من $clientName",
        amount: value,
        note: note.text.trim(),
      );

      if (clientId != null && clientId > 0) {
        await ApiService.updateClientActivity(clientId);
      }

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      if (ok) {
  amount.clear();
  note.clear();

  if (!mounted) return;

  Navigator.pop(context, true);

  messengerKey.currentState?.showSnackBar(
    const SnackBar(
      content: Text("تم تسجيل استلام الأموال بنجاح"),
      backgroundColor: Colors.green,
    ),
  );
} else {
  showMsg("فشل تسجيل العملية", error: true);
}
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMsg("حدث خطأ أثناء الاتصال بالسيرفر", error: true);
    }
  }

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  double get currentBalance {
    final client = selectedClient;
    if (client == null) return 0;
    return double.tryParse((client["balance"] ?? "0").toString()) ?? 0;
  }

  double get amountValue => parseNumber(amount.text);

  double get balanceAfterReceive => currentBalance - amountValue;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08111F),
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5EF2E3),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
                  children: [
                    buildHeader(),
                    const SizedBox(height: 18),
                    buildClientSelector(),
                    const SizedBox(height: 14),
                    buildAmountForm(),
                    const SizedBox(height: 14),
                    buildBalancePreview(),
                    const SizedBox(height: 18),
                    buildSaveButton(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: const [
        Text(
          "استلام أموال",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "تسجيل تحصيل مبلغ من عميل",
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget buildClientSelector() {
    if (clients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Text(
          "لا يوجد عملاء. أضف عميل أولًا من صفحة العملاء.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          const Text(
            "العميل",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF172642),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: selectedClient,
                isExpanded: true,
                dropdownColor: const Color(0xFF172642),
                iconEnabledColor: const Color(0xFF5EF2E3),
                style: const TextStyle(color: Colors.white),
                items: clients.map((client) {
                  final name = (client["name"] ?? "بدون اسم").toString();
                  final phone = (client["phone"] ?? "").toString();

                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: client,
                    child: Text(
                      phone.isEmpty ? name : "$name - $phone",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClient = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAmountForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          buildInput(
            controller: amount,
            label: "المبلغ المستلم",
            icon: Icons.call_received_rounded,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          buildInput(
            controller: note,
            label: "ملاحظات اختيارية",
            icon: Icons.note_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFF42E695), size: 20),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget buildBalancePreview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF42E695),
            Color(0xFF3BB2B8),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF08111F),
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "معاينة الرصيد",
                  style: TextStyle(
                    color: Color(0xFF08111F),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          buildPreviewRow("الرصيد الحالي", currentBalance),
          buildPreviewRow("المبلغ المستلم", amountValue),
          const Divider(color: Color(0x5508111F)),
          buildPreviewRow("الرصيد بعد التحصيل", balanceAfterReceive, bold: true),
        ],
      ),
    );
  }

  Widget buildPreviewRow(String title, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF08111F),
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            "${formatMoney(value)} ج.م",
            style: TextStyle(
              color: const Color(0xFF08111F),
              fontSize: bold ? 20 : 15,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42E695),
          foregroundColor: const Color(0xFF08111F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: saving ? null : saveReceiveMoney,
        icon: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF08111F),
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          saving ? "جاري الحفظ..." : "حفظ استلام الأموال",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
class PayMoneyScreen extends StatefulWidget {
  const PayMoneyScreen({super.key});

  @override
  State<PayMoneyScreen> createState() => _PayMoneyScreenState();
}

class _PayMoneyScreenState extends State<PayMoneyScreen> {
  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();

  List<Map<String, dynamic>> suppliers = [];
Map<String, dynamic>? selectedSupplier;

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  Future<void> loadClients() async {
    try {
     final data = await ApiService.getSuppliers();

      if (!mounted) return;

      setState(() {
        suppliers = data;
selectedSupplier = data.isNotEmpty ? data.first : null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMsg("فشل تحميل العملاء", error: true);
    }
  }

  @override
  void dispose() {
    amount.dispose();
    note.dispose();
    super.dispose();
  }

  double parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(",", ".")) ?? 0;
  }

  String formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  double get amountValue => parseNumber(amount.text);

  Future<void> savePayMoney() async {
  final supplier = selectedSupplier;
  final value = amountValue;
  final notes = note.text.trim();

  if (supplier == null) {
  showMsg("اختار المورد أولاً", error: true);
  return;
}

  if (value <= 0) {
    showMsg("اكتب مبلغ صحيح", error: true);
    return;
  }

  setState(() {
    saving = true;
  });

  try {
    final supplierId =
    int.tryParse((supplier["id"] ?? "0").toString());

final supplierName =
    (supplier["name"] ?? "مورد").toString();

    final ok = await ApiService.addTransaction(
  type: "pay",
  partyType: "supplier",
  partyId: supplierId,
  title: "دفع أموال إلى $supplierName",
  amount: value,
  note: notes.isEmpty
      ? "دفع مبلغ إلى المورد $supplierName"
      : notes,
);

    // await ApiService.updateClientActivity(...)
   //  if (clientId != null && clientId > 0) {
    //   await ApiService.updateClientActivity(clientId);
   //  }

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    if (ok) {
      amount.clear();
      note.clear();

      if (!mounted) return;

      Navigator.pop(context, true);

      messengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text("تم تسجيل دفع الأموال بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showMsg("فشل تسجيل العملية", error: true);
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      saving = false;
    });

    showMsg(e.toString().replaceAll("Exception: ", ""), error: true);
  }
}

  void showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08111F),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
            children: [
              buildHeader(),
              const SizedBox(height: 18),
              buildPayForm(),
              const SizedBox(height: 14),
              buildAmountPreview(),
              const SizedBox(height: 18),
              buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF111A2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                "دفع أموال",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "تسجيل مبلغ مدفوع لمورد",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPayForm() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
  height: 56,
  padding: const EdgeInsets.symmetric(horizontal: 14),
  decoration: BoxDecoration(
    color: const Color(0xFF172642),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.05)),
  ),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<Map<String, dynamic>>(
      value: selectedSupplier,
      dropdownColor: const Color(0xFF172642),
      isExpanded: true,
      iconEnabledColor: const Color(0xFFFF7A9E),
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      hint: const Text(
  "اختار المورد",
),

items: suppliers.map((supplier) {
  return DropdownMenuItem<Map<String, dynamic>>(
    value: supplier,
    child: Text(
      (supplier["name"] ?? "مورد").toString(),
            textDirection: TextDirection.rtl,
          ),
        );
      }).toList(),
      onChanged: saving
          ? null
          : (value) {
              setState(() {
                selectedSupplier = value;
              });
            },
    ),
  ),
),
const SizedBox(height: 12),
          buildInput(
            controller: amount,
            label: "المبلغ المدفوع",
            icon: Icons.call_made_rounded,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          buildInput(
            controller: note,
            label: "ملاحظات اختيارية",
            icon: Icons.note_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF172642),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            icon,
            color: const Color(0xFFFF7A9E),
            size: 20,
          ),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget buildAmountPreview() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF7A9E),
            Color(0xFFFF4D6D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "إجمالي المبلغ المدفوع",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            "${formatMoney(amountValue)} ج.م",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7A9E),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: saving ? null : savePayMoney,
        icon: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_rounded),
        label: Text(
          saving ? "جاري الحفظ..." : "حفظ دفع الأموال",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;
  bool hidePassword = true;
  String role = "assistant";

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> doRegister() async {
    final nameText = name.text.trim();
    final phoneText = phone.text.trim();
    final emailText = email.text.trim();
    final passText = password.text.trim();

    if (nameText.isEmpty ||
        phoneText.isEmpty ||
        emailText.isEmpty ||
        passText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اكتب كل البيانات المطلوبة"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passText.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("كلمة المرور يجب ألا تقل عن 6 أرقام أو حروف"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
  final res = await ApiService.register(
    name: nameText,
    phone: phoneText,
    email: emailText,
    password: passText,
    role: role,
  );
     final data = Map<String, dynamic>.from(res["data"] ?? {});
final userId = int.tryParse((data["id"] ?? "0").toString()) ?? 0;
final userPhone = (data["phone"] ?? phoneText).toString();


if (!mounted) return;

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => VerifyOtpScreen(

userId: userId,

phone: emailText,

),
  ),
);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: const Color(0xFF5EF2E3)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF111A2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF5EF2E3)),
      ),
    );
  }

  Widget buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: role,
          dropdownColor: const Color(0xFF111A2E),
          iconEnabledColor: const Color(0xFF5EF2E3),
          isExpanded: true,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          items: const [
            DropdownMenuItem(
              value: "assistant",
              child: Text("مساعد"),
            ),
            DropdownMenuItem(
              value: "collector",
              child: Text("محصل"),
            ),
            DropdownMenuItem(
              value: "warehouse",
              child: Text("مخزن"),
            ),
            DropdownMenuItem(
              value: "owner",
              child: Text("مالك"),
            ),
          ],
          onChanged: loading
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    role = value;
                  });
                },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B0F1A),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "إنشاء حساب",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5EF2E3),
                        Color(0xFF00B4FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "حساب جديد",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "أدخل بيانات المستخدم الجديد",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),

                TextField(
                  controller: name,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldDecoration(
                    hint: "الاسم",
                    icon: Icons.person_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldDecoration(
                    hint: "رقم الهاتف",
                    icon: Icons.phone_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldDecoration(
                    hint: "البريد الإلكتروني",
                    icon: Icons.email_rounded,
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: password,
                  obscureText: hidePassword,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldDecoration(
                    hint: "كلمة المرور",
                    icon: Icons.lock_rounded,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                buildRoleDropdown(),

                const SizedBox(height: 24),

                InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: loading ? null : doRegister,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5EF2E3),
                          Color(0xFF00B4FF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: loading
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "إنشاء الحساب",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class VerifyOtpScreen extends StatefulWidget {
  final int userId;
  final String phone;
  final String? demoOtp;

  const VerifyOtpScreen({
    super.key,
    required this.userId,
    required this.phone,
    this.demoOtp,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final codeController = TextEditingController();
  bool loading = false;
  String? demoOtp;

  @override
  void initState() {
    super.initState();
    demoOtp = widget.demoOtp;
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> verify() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      showMsg("من فضلك أدخل كود التحقق");
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiService.verifyOtp(
        userId: widget.userId,
        code: code,
      );

      if (!mounted) return;

      showMsg(res["message"]?.toString() ?? "تم تفعيل الحساب");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      showMsg(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> resend() async {
    setState(() => loading = true);

    try {
      final res = await ApiService.resendOtp(userId: widget.userId);

      if (!mounted) return;

      setState(() {
        demoOtp = res["demo_otp"]?.toString();
      });

      showMsg(res["message"]?.toString() ?? "تم إرسال كود جديد");
    } catch (e) {
      if (!mounted) return;
      showMsg(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF07111F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF07111F),
          elevation: 0,
          title: const Text("تأكيد الحساب"),
          centerTitle: true,
        ),
       body: SafeArea(
  child: SingleChildScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: const EdgeInsets.all(18),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
                const SizedBox(height: 30),

                const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF4ECDC4),
                  size: 72,
                ),

                const SizedBox(height: 20),

                const Text(
                  "أدخل كود التحقق",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "تم إنشاء كود تحقق للرقم:\n${widget.phone}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 18),

                if (demoOtp != null && demoOtp!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111A2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4ECDC4).withOpacity(0.35),
                      ),
                    ),
                    child: Text(
                      "كود الديمو: $demoOtp",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 22),

                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "------",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      letterSpacing: 4,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF111A2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: loading ? null : verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4ECDC4),
                      foregroundColor: const Color(0xFF07111F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "تأكيد",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: loading ? null : resend,
                  child: const Text(
                    "إعادة إرسال الكود",
                    style: TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
