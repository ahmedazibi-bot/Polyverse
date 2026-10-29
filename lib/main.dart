import 'package:flutter/material.dart';

void main() {
  runApp(const PolyHydroApp());
}

class PolyHydroApp extends StatelessWidget {
  const PolyHydroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyHydro - ENSH M1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const PolyHydroHome(),
    );
  }
}

class PolyHydroHome extends StatefulWidget {
  const PolyHydroHome({super.key});

  @override
  State<PolyHydroHome> createState() => _PolyHydroHomeState();
}

class _PolyHydroHomeState extends State<PolyHydroHome> {
  // 0: مرحلة المراجعة (Revision - حتى 30 نوفمبر)
  // 1: مرحلة الامتحانات (Exams - من 30 نوفمبر إلى 30 ديسمبر)
  int selectedPhase = 0;
  int currentTab = 0;

  // نظام النقاط ورتب الأداء مع تطبيق العقوبات التلقائية
  int scorePoints = 300;

  String get rankLabel {
    if (scorePoints < 150) return 'Level 0: Penalty Active ⚠️ (عقوبة التخلف النشطة)';
    if (scorePoints < 400) return 'Level 1: Junior Hydraulic Engineer 💧';
    if (scorePoints < 750) return 'Level 2: Advanced Flow Specialist 🛠️';
    return 'Level 3: Master Legend Hydraulic 🚀';
  }

  // تتبع مهام المراجعة اليومية
  final Map<String, bool> revTasks = {
    'hyd': false,
    'mmc': false,
    'mech': false,
    'other': false,
  };

  // أنابيب تقدم الفصول (Modules Tubes)
  int hydChapters = 0; // من 7
  int mmcChapters = 0; // من 5
  int mechChapters = 0; // من 5
  int otherChapters = 0; // من 4

  // إحصائيات الامتحانات
  int hydExams = 0;
  int mmcExams = 0;
  int mechExams = 0;
  int otherExams = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedPhase == 0 ? 'PolyHydro: مرحلة المراجعة 📚' : 'PolyHydro: مرحلة الامتحانات 📝',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: selectedPhase == 0 ? Colors.indigo[900] : Colors.deepOrange[900],
        actions: [
          IconButton(
            icon: Icon(Icons.menu_book, color: selectedPhase == 0 ? Colors.cyanAccent : Colors.white38),
            tooltip: 'مرحلة المراجعة',
            onPressed: () => setState(() { selectedPhase = 0; currentTab = 0; }),
          ),
          IconButton(
            icon: Icon(Icons.assignment, color: selectedPhase == 1 ? Colors.amberAccent : Colors.white38),
            tooltip: 'مرحلة الامتحانات',
            onPressed: () => setState(() { selectedPhase = 1; currentTab = 0; }),
          ),
        ],
      ),
      body: selectedPhase == 0 ? buildRevisionBody() : buildExamsBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab,
        selectedItemColor: selectedPhase == 0 ? Colors.cyanAccent : Colors.amberAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => currentTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'العداد'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'المهام'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'التقدم'),
          BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'الرتب'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Dev-Info'),
        ],
      ),
    );
  }

  // ================= مرحلة المراجعة (Revision Phase) =================
  Widget buildRevisionBody() {
    switch (currentTab) {
      case 0:
        return buildTimerView('⏳ العداد الزمني لمرحلة المراجعة (حتى 30 نوفمبر)', Colors.indigo);
      case 1:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('📌 مهام المراجعة اليومية:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 10),
            buildCheckboxTile('فصل أو سلسلة: Hydraulique Générale', revTasks['hyd']!, (v) => updateRev('hyd', v)),
            buildCheckboxTile('فصل أو سلسلة: MMC', revTasks['mmc']!, (v) => updateRev('mmc', v)),
            buildCheckboxTile('فصل أو سلسلة: Mécanique Appliquée', revTasks['mech']!, (v) => updateRev('mech', v)),
            buildCheckboxTile('فصل أو سلسلة: إحدى المواد الأربع الأخرى', revTasks['other']!, (v) => updateRev('other', v)),
          ],
        );
      case 2:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('🧪 أنابيب تقدم المقررات (Modules Tubes):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 15),
            buildTubeCard('Hydraulique Générale', hydChapters, 7, Colors.blue, () => setState(() { if(hydChapters < 7) hydChapters++; })),
            buildTubeCard('MMC', mmcChapters, 5, Colors.orange, () => setState(() { if(mmcChapters < 5) mmcChapters++; })),
            buildTubeCard('Mécanique Appliquée', mechChapters, 5, Colors.green, () => setState(() { if(mechChapters < 5) mechChapters++; })),
            buildTubeCard('المواد الأخرى', otherChapters, 4, Colors.purple, () => setState(() { if(otherChapters < 4) otherChapters++; })),
          ],
        );
      case 3:
        return buildRankingView();
      case 4:
        return buildDevInfoView();
      default:
        return Container();
    }
  }

  void updateRev(String key, bool? val) {
    setState(() {
      revTasks[key] = val ?? false;
      scorePoints += (val == true ? 25 : -40); // تطبيق عقوبة فورية عند التخلف
    });
  }

  // ================= مرحلة الامتحانات (Exams Phase) =================
  Widget buildExamsBody() {
    switch (currentTab) {
      case 0:
        return buildTimerView('🚨 عداد مرحلة الامتحانات (30 نوف - 30 ديسمبر)', Colors.deepOrange);
      case 1:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('📝 مهام الامتحانات اليومية:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
            const SizedBox(height: 10),
            buildExamTaskCard('حل امتحان كامل: Hydraulique Générale', hydExams, () => setState(() { hydExams++; scorePoints += 35; })),
            buildExamTaskCard('حل امتحان كامل: MMC', mmcExams, () => setState(() { mmcExams++; scorePoints += 35; })),
            buildExamTaskCard('حل امتحان كامل: Mécanique Appliquée', mechExams, () => setState(() { mechExams++; scorePoints += 35; })),
            buildExamTaskCard('حل امتحان: مواد أخرى', otherExams, () => setState(() { otherExams++; scorePoints += 25; })),
          ],
        );
      case 2:
        int total = hydExams + mmcExams + mechExams + otherExams;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('📊 لوحة تحكم الامتحانات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
            const SizedBox(height: 15),
            Card(
              color: Colors.amber[900]?.withOpacity(0.3),
              child: ListTile(
                title: const Text('إجمالي الامتحانات المحلولة'),
                trailing: Text('$total امتحانات', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
              ),
            ),
            const Divider(height: 20),
            buildStatTile('Hydraulique Générale', '$hydExams امتحانات'),
            buildStatTile('MMC', '$mmcExams امتحانات'),
            buildStatTile('Mécanique Appliquée', '$mechExams امتحانات'),
            buildStatTile('المواد الأخرى', '$otherExams امتحانات'),
          ],
        );
      case 3:
        return buildRankingView();
      case 4:
        return buildDevInfoView();
      default:
        return Container();
    }
  }

  // ================= أدوات الواجهة المشتركة =================
  Widget buildTimerView(String title, Color col) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          color: col.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: col, width: 2)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: col), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                  child: const Text('العداد التنازلي نشط ⏱️', style: TextStyle(color: Colors.greenAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRankingView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎖️ الرتب ونظام العقوبات التلقائي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('النقاط الحالية: $scorePoints', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                  const SizedBox(height: 10),
                  Text(rankLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amberAccent), textAlign: TextAlign.center),
                  const Divider(height: 25),
                  const Text('⚠️ سياسة العقوبات: التخلف عن المهام يخصم نقاطاً مباشرة من رتبتك لهندسة انضباط صارم.', style: TextStyle(fontSize: 12, color: Colors.redAccent), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDevInfoView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.grey[900],
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('👨‍💻 Dev-Info (معلومات المطور)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
              Divider(height: 20),
              Text('• Name: AHMED AZIBI', style: TextStyle(fontSize: 15)),
              SizedBox(height: 8),
              Text('• Career: Hydraulic Engineering Student 1st Year M1 - ENSH', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• Role: APK Developer', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• GitHub: ahmedbot', style: TextStyle(fontSize: 14, color: Colors.amberAccent)),
              SizedBox(height: 8),
              Text('• Gmail: ahmed.azibi@ensh.dz', style: TextStyle(fontSize: 14, color: Colors.amberAccent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCheckboxTile(String title, bool val, Function(bool?) onChanged) {
    return Card(color: Colors.grey[900], child: CheckboxListTile(title: Text(title, style: const TextStyle(fontSize: 13)), value: val, onChanged: onChanged));
  }

  Widget buildTubeCard(String title, int count, int total, Color col, VoidCallback onAdd) {
    return Card(
      color: Colors.grey[900],
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: LinearProgressIndicator(value: count / total, color: col, backgroundColor: Colors.white12),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count/$total', style: TextStyle(color: col, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.cyanAccent), onPressed: onAdd),
          ],
        ),
      ),
    );
  }

  Widget buildExamTaskCard(String title, int count, VoidCallback onAdd) {
    return Card(
      color: Colors.grey[900],
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 13)),
        subtitle: Text('الامتحانات المحلولة: $count'),
        trailing: IconButton(icon: const Icon(Icons.add_task, color: Colors.greenAccent), onPressed: onAdd),
      ),
    );
  }

  Widget buildStatTile(String label, String val) {
    return Card(color: Colors.grey[900], child: ListTile(title: Text(label), trailing: Text(val, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))));
  }
}