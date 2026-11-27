import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../database_helper.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _activities = [];

  String _userId = '';
  String _userName = 'Pengguna';

  bool _loading = true;

  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF818CF8);

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  // =====================================================
  // 1. INISIALISASI AKUN DAN DASHBOARD
  // =====================================================

  Future<void> _initializeDashboard() async {
    final user = _authService.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    _userId = user.uid;
    _userName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email?.split('@').first ?? 'Pengguna';

    await _refreshActivities();
  }

  // =====================================================
  // 2. MENGAMBIL AGENDA BERDASARKAN UID
  // =====================================================

  Future<void> _refreshActivities() async {
    try {
      if (_userId.isEmpty) return;

      final data = await DatabaseHelper.instance.getActivities(_userId);

      if (!mounted) return;

      setState(() {
        _activities = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      _showMessage('Gagal memuat agenda: $e');
    }
  }

  // =====================================================
  // 3. MENAMBAHKAN AGENDA
  // =====================================================

  Future<void> _addNewActivity(
    String title,
    String date,
    String time,
    String category,
  ) async {
    await DatabaseHelper.instance.insertActivity(_userId, {
      'title': title,
      'date': date,
      'time': time,
      'category': category,
      'is_active': 0,
      'user_id': _userId,
    });

    await _refreshActivities();
  }

  // =====================================================
  // 4. MENGHAPUS AGENDA
  // =====================================================

  Future<void> _deleteActivity(int id) async {
    try {
      await DatabaseHelper.instance.deleteActivity(id, _userId);

      await _refreshActivities();

      if (!mounted) return;

      _showMessage('Agenda berhasil dihapus.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal menghapus agenda.');
    }
  }

  // =====================================================
  // 5. MENGUBAH STATUS AGENDA
  // =====================================================

  Future<void> _toggleActivity(int id, bool isDone) async {
    try {
      await DatabaseHelper.instance.updateActivity(id, isDone ? 1 : 0, _userId);

      await _refreshActivities();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal memperbarui status agenda.');
    }
  }

  // =====================================================
  // 6. DIALOG TAMBAH AGENDA
  // =====================================================

  void _showAddActivityDialog() {
    final titleController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    String selectedCategory = 'Pribadi';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              title: const Text(
                'Tambah Kegiatan Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kegiatan / Agenda',
                        prefixIcon: const Icon(Icons.title, color: primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Kegiatan',
                        hintText: 'Pilih tanggal',
                        prefixIcon: const Icon(
                          Icons.calendar_today,
                          color: primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (selectedDate != null) {
                          const days = [
                            'Senin',
                            'Selasa',
                            'Rabu',
                            'Kamis',
                            'Jumat',
                            'Sabtu',
                            'Minggu',
                          ];

                          const months = [
                            'Januari',
                            'Februari',
                            'Maret',
                            'April',
                            'Mei',
                            'Juni',
                            'Juli',
                            'Agustus',
                            'September',
                            'Oktober',
                            'November',
                            'Desember',
                          ];

                          final formatted =
                              '${days[selectedDate.weekday - 1]}, '
                              '${selectedDate.day} '
                              '${months[selectedDate.month - 1]} '
                              '${selectedDate.year}';

                          setDialogState(() {
                            dateController.text = formatted;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: timeController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Jam Kegiatan',
                        hintText: 'Pilih jam',
                        prefixIcon: const Icon(
                          Icons.access_time,
                          color: primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        final selectedTime = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.now(),
                        );

                        if (selectedTime != null) {
                          setDialogState(() {
                            timeController.text =
                                '${selectedTime.hour.toString().padLeft(2, '0')}:'
                                '${selectedTime.minute.toString().padLeft(2, '0')} WIB';
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Kategori Agenda',
                        prefixIcon: const Icon(Icons.category, color: primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      items: ['Kuliah', 'Tugas', 'Penting', 'Pribadi'].map((
                        category,
                      ) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),

                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    titleController.dispose();
                    dateController.dispose();
                    timeController.dispose();
                  },
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),

                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        dateController.text.isEmpty ||
                        timeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lengkapi semua data agenda.'),
                        ),
                      );
                      return;
                    }

                    final title = titleController.text.trim();
                    final date = dateController.text;
                    final time = timeController.text;

                    Navigator.pop(dialogContext);

                    try {
                      await _addNewActivity(
                        title,
                        date,
                        time,
                        selectedCategory,
                      );

                      if (!mounted) return;

                      _showMessage('Agenda berhasil disimpan!');
                    } catch (e) {
                      if (!mounted) return;

                      _showMessage('Gagal menyimpan agenda: $e');
                    } finally {
                      titleController.dispose();
                      dateController.dispose();
                      timeController.dispose();
                    }
                  },

                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // 7. WARNA KATEGORI
  // =====================================================

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Kuliah':
        return Colors.blue;
      case 'Tugas':
        return Colors.orange;
      case 'Penting':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  // =====================================================
  // 8. SNACKBAR
  // =====================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // =====================================================
  // 9. LOGOUT FIREBASE
  // =====================================================

  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal logout. Silakan coba lagi.');
    }
  }

  // =====================================================
  // 10. DASHBOARD UTAMA
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final completedCount = _activities
        .where((a) => (a['is_active'] ?? 0) == 1)
        .length;

    final progress = _activities.isEmpty
        ? 0.0
        : completedCount / _activities.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Daily Activity & Reminder',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primary,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : RefreshIndicator(
              onRefresh: _refreshActivities,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU SAPAAN DAN STATISTIK

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primary, secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, $_userName! 👋',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    const Text(
                                      'Berikut jadwal kegiatan dan pengingat aktifmu.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
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

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selesai: $completedCount dari ${_activities.length} agenda',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),

                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

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

                    // DAFTAR AGENDA
                    Expanded(
                      child: _activities.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 100),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_note_rounded,
                                        size: 65,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Belum ada kegiatan terjadwal.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _activities.length,

                              itemBuilder: (context, index) {
                                final activity = _activities[index];

                                final int id = activity['id'] as int;

                                final bool isDone =
                                    (activity['is_active'] ?? 0) == 1;

                                final String category =
                                    activity['category'] ?? 'Pribadi';

                                final String title = activity['title'] ?? '';

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

                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
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
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(
                                              category,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getCategoryColor(
                                                category,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_month_rounded,
                                            size: 14,
                                            color: primary,
                                          ),

                                          const SizedBox(width: 4),

                                          Expanded(
                                            child: Text(
                                              activity['date'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: Colors.grey,
                                          ),

                                          const SizedBox(width: 4),

                                          Text(
                                            activity['time'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    secondary: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'Hapus Agenda',
                                      onPressed: () {
                                        _deleteActivity(id);
                                      },
                                    ),

                                    value: isDone,

                                    activeColor: primary,

                                    onChanged: (value) {
                                      _toggleActivity(id, value ?? false);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        onPressed: _showAddActivityDialog,
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Tambah Agenda'),
      ),
    );
  }
}
