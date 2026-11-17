import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const OurDigitalSchoolApp());
}

// ============================================================================
// 1. إدارة اللغات (Localization Manager - AR / EN)
// ============================================================================
class AppStrings {
  static String lang = 'ar';

  static final Map<String, Map<String, String>> _values = {
    'ar': {
      'app_name': 'Our Digital School',
      'slogan': 'تعليم أفضل .. متابعة أسهل',
      'start_now': 'ابدأ الآن',
      'who_are_you': 'من أنت؟',
      'student': 'طالب',
      'teacher': 'مدرس',
      'confirm': 'تأكيد',
      'welcome_back': 'مرحباً بك مجدداً',
      'create_account': 'إنشاء حساب جديد',
      'have_account': 'لديك حساب بالفعل؟ تسجيل الدخول',
      'no_account': 'ليس لديك حساب؟ أنشئ حساباً جديداً',
      'full_name': 'الاسم الرباعي (كما في كشوف المدرسة)',
      'national_id': 'الرقم القومي (للمدرس)',
      'phone_or_code': 'رقم الهاتف أو كود المدرسة (للطالب)',
      'school_name': 'كود المدرسة التعريفي',
      'password': 'كلمة المرور',
      'login': 'تسجيل الدخول',
      'register': 'تسجيل الحساب',
      'pending_title': 'تم تسجيل حسابك بنجاح!',
      'pending_desc':
          'في انتظار رفع إدارة المدرسة لملفات الـ PDF الخاصة بالقوائم ليتم ربطك بفصلك وتفعيل كودك الدراسي تلقائياً.',
      'check_status': 'تحديث الحالة الآن',
      // الأقسام المشتركة والجديدة
      'class_chat': 'شات الفصل (الطلاب والمعلم)',
      'homework_lessons': 'الواجبات والدروس القادمة',
      'evaluations': 'دفتر وجدول التقييمات',
      'admin_chat': 'شات مع الإدارة',
      'notifications': 'الإشعارات',
      'profile': 'ملفي الشخصي',
      'logout': 'تسجيل الخروج',
      // المدرس
      'hello_teacher': 'أهلاً أستاذ',
      'take_attendance': 'تسجيل الغياب اليوم',
      'reports': 'التقارير والإحصائيات',
      'manage_classes': 'إدارة الفصول',
      'mark_all_present': 'حضور الجميع',
      'save_attendance': 'حفظ الغياب وإرساله',
      'add_homework': 'إضافة واجب / تنبيه درس قادم',
      'save_evaluations': 'حفظ درجات التقييم',
      // الطالب
      'hello_student': 'أهلاً يا',
      'attendance_log': 'سجل الحضور والغياب',
      'honor_roll': 'لوحة الشرف',
      'present': 'حضور',
      'absent': 'غياب',
      'type_message': 'اكتب رسالتك للفصل هنا...',
      'teacher_badge': 'معلم المادة',
    },
    'en': {
      'app_name': 'Our Digital School',
      'slogan': 'Better Education .. Easier Tracking',
      'start_now': 'Start Now',
      'who_are_you': 'Who are you?',
      'student': 'Student',
      'teacher': 'Teacher',
      'confirm': 'Confirm',
      'welcome_back': 'Welcome Back',
      'create_account': 'Create New Account',
      'have_account': 'Already have an account? Login',
      'no_account': 'New user? Create an account',
      'full_name': 'Full Name (As in school records)',
      'national_id': 'National ID (For Teachers)',
      'phone_or_code': 'Phone Number or School Code (For Students)',
      'school_name': 'School ID Code',
      'password': 'Password',
      'login': 'Login',
      'register': 'Register Account',
      'pending_title': 'Account Registered!',
      'pending_desc':
          'Waiting for school administration to upload PDF lists to automatically assign your class and student code.',
      'check_status': 'Check Status Now',
      'class_chat': 'Class Chat (Students & Teacher)',
      'homework_lessons': 'Homework & Next Lessons',
      'evaluations': 'Evaluations & Grades Ledger',
      'admin_chat': 'Admin Chat',
      'notifications': 'Notifications',
      'profile': 'My Profile',
      'logout': 'Logout',
      'hello_teacher': 'Hello Prof.',
      'take_attendance': 'Take Attendance',
      'reports': 'Reports & Stats',
      'manage_classes': 'Manage Classes',
      'mark_all_present': 'Mark All Present',
      'save_attendance': 'Save Attendance',
      'add_homework': 'Post Homework / Next Lesson Alert',
      'save_evaluations': 'Save Evaluation Grades',
      'hello_student': 'Hello,',
      'attendance_log': 'Attendance Log',
      'honor_roll': 'Honor Roll',
      'present': 'Present',
      'absent': 'Absent',
      'type_message': 'Type your message to class...',
      'teacher_badge': 'Teacher',
    }
  };

  static String get(String key) => _values[lang]?[key] ?? key;
}

// ============================================================================
// 2. طبقة الاتصال بالسيرفر (Real API Service - No Mock Data)
// ============================================================================
class ApiService {
  // رابط السيرفر الخاص بك
  static const String baseUrl = 'https://api.ourdigitalschool.com/v1';

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // 1. تسجيل حساب جديد قبل نزول قوائم الـ PDF
  static Future> registerUser({
    required String role,
    required String fullName,
    required String identifier,
    required String schoolCode,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(null),
        body: jsonEncode({
          'role': role,
          'full_name': fullName,
          'identifier': identifier,
          'school_code': schoolCode,
          'password': password,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // 2. تسجيل الدخول
  static Future> loginUser({
    required String role,
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(null),
        body: jsonEncode({
          'role': role,
          'identifier': identifier,
          'password': password,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'تعذر الاتصال بالسيرفر'};
    }
  }

  // 3. جلب بيانات لوحة التحكم الحقيقية
  static Future?> fetchDashboard(String token, String role) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/$role/dashboard'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 4. جلب رسائل شات الفصل (الطلاب + المدرس)
  static Future<List<dynamic>> fetchClassChat(String token, String classId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/classes/$classId/chat'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) return jsonDecode(res.body)['messages'] ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  // 5. إرسال رسالة في شات الفصل (سواء من طالب أو مدرس)
  static Future<bool> sendClassMessage(String token, String classId, String text) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/classes/$classId/chat'),
        headers: _headers(token),
        body: jsonEncode({'message': text}),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 6. جلب الواجبات والدروس القادمة للفصل
  static Future<List<dynamic>> fetchHomeworkAndLessons(String token, String classId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/classes/$classId/homework'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) return jsonDecode(res.body)['items'] ?? [];
      return [];
    } catch (e) {
      return [];
    }
  }

  // 7. رفع واجب أو تنبيه درس قادم (خاص بالمدرس)
  static Future<bool> postHomeworkOrAlert({
    required String token,
    required String classId,
    required String title,
    required String details,
    required String dueDate,
    required bool isAttendanceAlert,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/classes/$classId/homework'),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'details': details,
          'due_date': dueDate,
          'is_attendance_alert': isAttendanceAlert,
        }),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 8. جلب دفتر وجدول التقييمات
  static Future> fetchEvaluations(String token, String classId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/classes/$classId/evaluations'),
        headers: _headers(token),
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
      return {'schedule': [], 'grades': []};
    } catch (e) {
      return {'schedule': [], 'grades': []};
    }
  }

  // 9. حفظ درجات التقييمات من المدرس
  static Future<bool> submitEvaluations(
      String token, String classId, String title, List> grades) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/classes/$classId/evaluations'),
        headers: _headers(token),
        body: jsonEncode({'evaluation_title': title, 'grades': grades}),
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 10. إرسال الغياب اليومي للفصل
  static Future<bool> submitAttendance(
      String token, String classId, List> records) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/teacher/attendance'),
        headers: _headers(token),
        body: jsonEncode({'class_id': classId, 'records': records}),
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// ============================================================================
// 3. التطبيق الرئيسي والثيم الموحد
// ============================================================================
class OurDigitalSchoolApp extends StatefulWidget {
  const OurDigitalSchoolApp({super.key});

  @override
  State<OurDigitalSchoolApp> createState() => _OurDigitalSchoolAppState();
}

class _OurDigitalSchoolAppState extends State<OurDigitalSchoolApp> {
  void _toggleLang() {
    setState(() {
      AppStrings.lang = AppStrings.lang == 'ar' ? 'en' : 'ar';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Our Digital School',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D2C54),
        scaffoldBackgroundColor: const Color(0xFFF3F6FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D2C54),
          primary: const Color(0xFF0D2C54),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D2C54),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: AppStrings.lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: WelcomeScreen(onLangToggle: _toggleLang),
    );
  }
}

// ============================================================================
// 4. شاشة الترحيب واختيار الصفة والمصادقة
// ============================================================================
class WelcomeScreen extends StatelessWidget {
  final VoidCallback onLangToggle;
  const WelcomeScreen({super.key, required this.onLangToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2C54),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topEnd,
                child: TextButton.icon(
                  onPressed: onLangToggle,
                  icon: const Icon(Icons.language, color: Colors.white),
                  label: Text(
                    AppStrings.lang == 'ar' ? 'English' : 'العربية',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_rounded, size: 95, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('app_name'),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.get('slogan'),
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D2C54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RoleSelectionScreen(onLangToggle: onLangToggle)),
                  ),
                  child: Text(
                    AppStrings.get('start_now'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatefulWidget {
  final VoidCallback onLangToggle;
  const RoleSelectionScreen({super.key, required this.onLangToggle});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('who_are_you'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _roleCard('student', AppStrings.get('student'), Icons.school_rounded),
            const SizedBox(height: 20),
            _roleCard('teacher', AppStrings.get('teacher'), Icons.co_present_rounded),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2C54),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthScreen(role: _selectedRole, onLangToggle: widget.onLangToggle),
                  ),
                ),
                child: Text(AppStrings.get('confirm'), style: const TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _roleCard(String role, String title, IconData icon) {
    final active = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0D2C54) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF0D2C54), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: active ? Colors.white : const Color(0xFF0D2C54)),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : const Color(0xFF0D2C54),
              ),
            ),
            const Spacer(),
            Icon(active ? Icons.check_circle : Icons.radio_button_off,
                color: active ? Colors.white : Colors.grey),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  final String role;
  final VoidCallback onLangToggle;
  const AuthScreen({super.key, required this.role, required this.onLangToggle});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final res = _isLogin
        ? await ApiService.loginUser(
            role: widget.role, identifier: _idCtrl.text.trim(), password: _passCtrl.text.trim())
        : await ApiService.registerUser(
            role: widget.role,
            fullName: _nameCtrl.text.trim(),
            identifier: _idCtrl.text.trim(),
            schoolCode: _schoolCtrl.text.trim(),
            password: _passCtrl.text.trim());

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (res['status'] == 'pending_pdf') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PendingApprovalScreen(
              token: res['token'] ?? '', role: widget.role, onLangToggle: widget.onLangToggle),
        ),
      );
    } else if (res['status'] == 'active') {
      final token = res['token'];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.role == 'teacher'
              ? TeacherDashboardScreen(token: token, onLangToggle: widget.onLangToggle)
              : StudentDashboardScreen(token: token, onLangToggle: widget.onLangToggle),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'خطأ في الاتصال بالسيرفر')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.role == 'teacher';
    return Scaffold(
      appBar: AppBar(title: Text(isTeacher ? AppStrings.get('teacher') : AppStrings.get('student'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_person_rounded, size: 75, color: Color(0xFF0D2C54)),
            const SizedBox(height: 16),
            Text(
              _isLogin ? AppStrings.get('welcome_back') : AppStrings.get('create_account'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.get('full_name'),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _idCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    isTeacher ? AppStrings.get('national_id') : AppStrings.get('phone_or_code'),
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            if (!_isLogin) ...[
              TextField(
                controller: _schoolCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.get('school_name'),
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppStrings.get('password'),
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2C54),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isLogin ? AppStrings.get('login') : AppStrings.get('register'),
                        style: const TextStyle(fontSize: 18)),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? AppStrings.get('no_account') : AppStrings.get('have_account')),
            )
          ],
        ),
      ),
    );
  }
}

class PendingApprovalScreen extends StatelessWidget {
  final String token;
  final String role;
  final VoidCallback onLangToggle;
  const PendingApprovalScreen(
      {super.key, required this.token, required this.role, required this.onLangToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_bottom_rounded, size: 90, color: Color(0xFF0D2C54)),
            const SizedBox(height: 20),
            Text(AppStrings.get('pending_title'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(AppStrings.get('pending_desc'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2C54),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () async {
                final data = await ApiService.fetchDashboard(token, role);
                if (data != null && data['is_matched'] == true && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => role == 'teacher'
                          ? TeacherDashboardScreen(token: token, onLangToggle: onLangToggle)
                          : StudentDashboardScreen(token: token, onLangToggle: onLangToggle),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.sync),
              label: Text(AppStrings.get('check_status')),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 5. شاشة شات الفصل المشتركة (طلاب الفصل + المعلم)
// ============================================================================
class ClassChatScreen extends StatefulWidget {
  final String token;
  final String classId;
  final String className;
  final bool isTeacher;

  const ClassChatScreen({
    super.key,
    required this.token,
    required this.classId,
    required this.className,
    required this.isTeacher,
  });

  @override
  State<ClassChatScreen> createState() => _ClassChatScreenState();
}

class _ClassChatScreenState extends State<ClassChatScreen> {
  final _msgCtrl = TextEditingController();
  List<dynamic> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await ApiService.fetchClassChat(widget.token, widget.classId);
    if (mounted) {
      setState(() {
        _messages = msgs;
        _loading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final ok = await ApiService.sendClassMessage(widget.token, widget.classId, text);
    if (ok) _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(AppStrings.get('class_chat'), style: const TextStyle(fontSize: 16)),
            Text(widget.className, style: const TextStyle(fontSize: 12, color: Colors.amberAccent)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages)],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      final senderIsTeacher = m['sender_role'] == 'teacher';
                      final isMe = m['is_me'] == true;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                          decoration: BoxDecoration(
                            color: senderIsTeacher
                                ? const Color(0xFF0D2C54)
                                : (isMe ? Colors.blue.shade100 : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: senderIsTeacher
                                ? Border.all(color: Colors.amber, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    m['sender_name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: senderIsTeacher ? Colors.amberAccent : const Color(0xFF0D2C54),
                                    ),
                                  ),
                                  if (senderIsTeacher) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        AppStrings.get('teacher_badge'),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    )
                                  ]
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                m['message'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: senderIsTeacher ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m['time'] ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: senderIsTeacher ? Colors.white60 : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // شريط كتابة الرسالة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: AppStrings.get('type_message'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D2C54),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// 6. شاشة الواجبات والدروس القادمة والتنبيهات (Homework & Next Lessons)
// ============================================================================
class HomeworkAndLessonsScreen extends StatefulWidget {
  final String token;
  final String classId;
  final String className;
  final bool isTeacher;

  const HomeworkAndLessonsScreen({
    super.key,
    required this.token,
    required this.classId,
    required this.className,
    required this.isTeacher,
  });

  @override
  State<HomeworkAndLessonsScreen> createState() => _HomeworkAndLessonsScreenState();
}

class _HomeworkAndLessonsScreenState extends State<HomeworkAndLessonsScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await ApiService.fetchHomeworkAndLessons(widget.token, widget.classId);
    if (mounted) {
      setState(() {
        _items = data;
        _loading = false;
      });
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    bool isAlert = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(AppStrings.get('add_homework')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'عنوان الواجب أو الدرس القادم'),
                ),
                TextField(
                  controller: detailsCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'التفاصيل المطلوبة من الطلاب'),
                ),
                TextField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(labelText: 'تاريخ الحصة / التسليم'),
                ),
                CheckboxListTile(
                  title: const Text('تنبيه هام بعدم الغياب'),
                  value: isAlert,
                  onChanged: (v) => setModalState(() => isAlert = v ?? false),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final ok = await ApiService.postHomeworkOrAlert(
                  token: widget.token,
                  classId: widget.classId,
                  title: titleCtrl.text,
                  details: detailsCtrl.text,
                  dueDate: dateCtrl.text,
                  isAttendanceAlert: isAlert,
                );
                if (ok && context.mounted) {
                  Navigator.pop(ctx);
                  _loadItems();
                }
              },
              child: const Text('نشر للفصل'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${AppStrings.get('homework_lessons')} - ${widget.className}')),
      floatingActionButton: widget.isTeacher
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF0D2C54),
              foregroundColor: Colors.white,
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text('نشر جديد'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isAlert = item['is_attendance_alert'] == true;
                return Card(
                  color: isAlert ? Colors.amber.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isAlert ? const BorderSide(color: Colors.amber, width: 1.5) : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isAlert ? Icons.warning_amber_rounded : Icons.assignment_rounded,
                      color: isAlert ? Colors.orange.shade800 : const Color(0xFF0D2C54),
                      size: 34,
                    ),
                    title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(item['details'] ?? ''),
                        const SizedBox(height: 6),
                        Text('الموعد: ${item['due_date'] ?? ''}',
                            style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================================
// 7. شاشة دفتر وجدول التقييمات (Evaluations & Assessments Ledger)
// ============================================================================
class EvaluationsLedgerScreen extends StatefulWidget {
  final String token;
  final String classId;
  final String className;
  final bool isTeacher;
  final List students; // يستخدمها المدرس لرصد الدرجات

  const EvaluationsLedgerScreen({
    super.key,
    required this.token,
    required this.classId,
    required this.className,
    required this.isTeacher,
    this.students = const [],
  });

  @override
  State<EvaluationsLedgerScreen> createState() => _EvaluationsLedgerScreenState();
}

class _EvaluationsLedgerScreenState extends State<EvaluationsLedgerScreen> {
  Map<String, dynamic> _evalData = {'schedule': [], 'grades': []};
  final Map<String, TextEditingController> _gradeControllers = {};
  final _evalTitleCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    for (var s in widget.students) {
      _gradeControllers[s['id'].toString()] = TextEditingController();
    }
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    final data = await ApiService.fetchEvaluations(widget.token, widget.classId);
    if (mounted) {
      setState(() {
        _evalData = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = (_evalData['schedule'] as List?) ?? [];
    final grades = (_evalData['grades'] as List?) ?? [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.get('evaluations')),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(text: 'جدول التقييمات القادمة'),
              Tab(text: 'دفتر الدرجات المرصودة'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // التبويب الأول: جدول مواعيد التقييمات
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedule.length,
                    itemBuilder: (context, i) {
                      final row = schedule[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.event_note, color: Color(0xFF0D2C54)),
                          title: Text(row['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('الموضوع: ${row['topic'] ?? ''}'),
                          trailing: Chip(label: Text(row['date'] ?? '')),
                        ),
                      );
                    },
                  ),
                  // التبويب الثاني: دفتر التقييمات (رصد للمدرس / عرض للطالب)
                  widget.isTeacher ? _buildTeacherGradingView() : _buildStudentGradesView(grades),
                ],
              ),
      ),
    );
  }

  Widget _buildTeacherGradingView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _evalTitleCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم التقييم (مثلاً: تقييم الأسبوع الثالث)',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.students.length,
            itemBuilder: (context, index) {
              final st = widget.students[index];
              final id = st['id'].toString();
              return ListTile(
                title: Text(st['name'] ?? ''),
                subtitle: Text('كود: ${st['student_code'] ?? ''}'),
                trailing: SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _gradeControllers[id],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'الدرجة', border: OutlineInputBorder()),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2C54),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final payload = _gradeControllers.entries
                    .map((e) => {'student_id': e.key, 'score': e.value.text})
                    .toList();
                final ok = await ApiService.submitEvaluations(
                    widget.token, widget.classId, _evalTitleCtrl.text, payload);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ درجات التقييم في قاعدة البيانات')),
                  );
                }
              },
              child: Text(AppStrings.get('save_evaluations')),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStudentGradesView(List grades) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grades.length,
      itemBuilder: (context, i) {
        final g = grades[i];
        return Card(
          child: ListTile(
            title: Text(g['evaluation_title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(g['subject'] ?? ''),
            trailing: CircleAvatar(
              backgroundColor: const Color(0xFF0D2C54),
              child: Text('${g['score']}', style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 8. لوحة تحكم المدرس الشاملة (Teacher Dashboard)
// ============================================================================
class TeacherDashboardScreen extends StatefulWidget {
  final String token;
  final VoidCallback onLangToggle;
  const TeacherDashboardScreen({super.key, required this.token, required this.onLangToggle});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.fetchDashboard(widget.token, 'teacher');
    if (mounted) {
      setState(() {
        _data = res;
        _loading = false;
      });
    }
  }

  void _selectClassForAction(Function(Map<String, dynamic> cls) onSelected) {
    final classes = (_data?['classes'] as List?) ?? [];
    if (classes.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, i) {
          final cls = classes[i];
          return ListTile(
            leading: const Icon(Icons.class_, color: Color(0xFF0D2C54)),
            title: Text(cls['class_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('عدد الطلاب: ${cls['students_count'] ?? 0}'),
            onTap: () {
              Navigator.pop(ctx);
              onSelected(cls);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final name = _data?['name'] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.get('hello_teacher')} $name'),
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: widget.onLangToggle),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _tile(Icons.fact_check_rounded, AppStrings.get('take_attendance'), () {
            _selectClassForAction((cls) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TakeAttendanceScreen(
                      token: widget.token,
                      classId: cls['id'].toString(),
                      className: cls['class_name'] ?? '',
                      students: cls['students'] ?? [],
                    ),
                  ),
                ));
          }),
          _tile(Icons.forum_rounded, AppStrings.get('class_chat'), () {
            _selectClassForAction((cls) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassChatScreen(
                      token: widget.token,
                      classId: cls['id'].toString(),
                      className: cls['class_name'] ?? '',
                      isTeacher: true,
                    ),
                  ),
                ));
          }),
          _tile(Icons.assignment_add, AppStrings.get('homework_lessons'), () {
            _selectClassForAction((cls) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeworkAndLessonsScreen(
                      token: widget.token,
                      classId: cls['id'].toString(),
                      className: cls['class_name'] ?? '',
                      isTeacher: true,
                    ),
                  ),
                ));
          }),
          _tile(Icons.grading_rounded, AppStrings.get('evaluations'), () {
            _selectClassForAction((cls) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EvaluationsLedgerScreen(
                      token: widget.token,
                      classId: cls['id'].toString(),
                      className: cls['class_name'] ?? '',
                      isTeacher: true,
                      students: cls['students'] ?? [],
                    ),
                  ),
                ));
          }),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: const Color(0xFF0D2C54)),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class TakeAttendanceScreen extends StatefulWidget {
  final String token;
  final String classId;
  final String className;
  final List students;

  const TakeAttendanceScreen({
    super.key,
    required this.token,
    required this.classId,
    required this.className,
    required this.students,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final Map<String, bool> _map = {};

  @override
  void initState() {
    super.initState();
    for (var s in widget.students) {
      _map[s['id'].toString()] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${AppStrings.get('take_attendance')} - ${widget.className}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: () => setState(() {
                for (var k in _map.keys) {
                  _map[k] = true;
                }
              }),
              icon: const Icon(Icons.done_all),
              label: Text(AppStrings.get('mark_all_present')),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, i) {
                final s = widget.students[i];
                final id = s['id'].toString();
                return CheckboxListTile(
                  title: Text(s['name'] ?? ''),
                  subtitle: Text('كود: ${s['student_code'] ?? ''}'),
                  value: _map[id] ?? true,
                  onChanged: (v) => setState(() => _map[id] = v ?? false),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D2C54),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final recs = _map.entries
                      .map((e) => {'student_id': e.key, 'status': e.value ? 'present' : 'absent'})
                      .toList();
                  final ok = await ApiService.submitAttendance(widget.token, widget.classId, recs);
                  if (ok && context.mounted) Navigator.pop(context);
                },
                child: Text(AppStrings.get('save_attendance')),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ============================================================================
// 9. لوحة تحكم الطالب الشاملة (Student Dashboard)
// ============================================================================
class StudentDashboardScreen extends StatefulWidget {
  final String token;
  final VoidCallback onLangToggle;
  const StudentDashboardScreen({super.key, required this.token, required this.onLangToggle});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.fetchDashboard(widget.token, 'student');
    if (mounted) {
      setState(() {
        _data = res;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final name = _data?['name'] ?? '';
    final code = _data?['student_code'] ?? '';
    final classId = _data?['class_id']?.toString() ?? '';
    final className = _data?['class_name'] ?? '';
    final rate = _data?['attendance_percentage'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.get('hello_student')} $name'),
        actions: [
          IconButton(icon: const Icon(Icons.language), onPressed: widget.onLangToggle),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D2C54),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الفصل: $className',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('كود الدراسة: $code',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 15)),
                  ],
                ),
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text('$rate%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D2C54))),
                )
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _tile(Icons.forum_rounded, AppStrings.get('class_chat'), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassChatScreen(
                        token: widget.token,
                        classId: classId,
                        className: className,
                        isTeacher: false,
                      ),
                    ),
                  );
                }),
                _tile(Icons.assignment_rounded, AppStrings.get('homework_lessons'), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeworkAndLessonsScreen(
                        token: widget.token,
                        classId: classId,
                        className: className,
                        isTeacher: false,
                      ),
                    ),
                  );
                }),
                _tile(Icons.grading_rounded, AppStrings.get('evaluations'), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EvaluationsLedgerScreen(
                        token: widget.token,
                        classId: classId,
                        className: className,
                        isTeacher: false,
                      ),
                    ),
                  );
                }),
                _tile(Icons.emoji_events_rounded, AppStrings.get('honor_roll'), () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF0D2C54)),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
