import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> _activities= [
    {
      'title': 'Presentasi Tugas Pemrograman Mobile',
      'date': 'Senin, 15 Juni 2026',
      'time': '09:00 WIB',
      'isDone': false
    },
    {
      'title': 'Bimbingan Proposal Skripsi/Tugas Akhir',
      'date': 'Rabu, 17 Juni 2026',
      'time': '13:30 WIB',
      'isDone': true
    },
    {
      'title': 'Pengumpulan Laporan Praktikum',
      'date': 'Jumat, 19 Juni 2026',
      'time': '23:59 WIB',
      'isDone': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('saved_activities');
    if (dataString != null) {
      setState(() {
        _activities = List<Map<String, dynamic>>.from(
          json.decode(dataString).map((x) => Map<String, dynamic>.from(x)),
        );
      });
    }
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('saved_activities', json.encode(_activities));
  }

  void _showAddActivityDialog() {
    final titleController = TextEditingController();
    final dateController = TextEditingController(text: 'Senin, 22 Juni 2026');
    final timeController = TextEditingController(text: '10:00 WIB');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Kegiatan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Nama Kegiatan / Agenda',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal & Hari',
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Jam (Cth: 10:00 WIB)',
                    prefixIcon: const Icon(Icons.access_time_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _activities.add({
                      'title': titleController.text,
                      'date': dateController.text,
                      'time': timeController.text,
                      'isDone': false,
                    });
                  });
                  _saveActivities();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kegiatan berhasil dijadwalkan & pengingat aktif! 🔔'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _activities.where((a) => a['isDone'] == true).length;
    double progress = _activities.isEmpty ? 0 : completedCount / _activities.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Daily Activity & Reminder',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4F46E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, Lutfi! 👋',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Berikut jadwal kegiatan dan pengingat aktifmu.',
                              style: TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selesai: $completedCount dari ${_activities.length} agenda',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      color: Colors.amber,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Daftar Kegiatan & Agenda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _activities.isEmpty
                  ? const Center(child: Text('Belum ada kegiatan terjadwal.'))
                  : ListView.builder(
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        final bool isDone = activity['isDone'] as bool;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CheckboxListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              activity['title'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: isDone
                                    ? Colors.grey
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded, size: 14, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity['date'] as String,
                                    style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity['time'] as String,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            secondary: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Hapus Agenda',
                              onPressed: () {
                                setState(() {
                                  _activities.removeAt(index);
                                });
                                _saveActivities();
                              },
                            ),
                            value: isDone,
                            activeColor: const Color(0xFF4F46E5),
                            onChanged: (bool? value) {
                              setState(() {
                                _activities[index]['isDone'] = value ?? false;
                              });
                              _saveActivities();
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: _showAddActivityDialog,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Tambah Agenda'),
      ),
    );
  }
}