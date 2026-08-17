import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import 'activity_detail_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<dynamic> _activities = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.listActivities(page: 1, pageSize: 20);
    setState(() {
      _activities = res['data']?['list'] ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('活动', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _activities.length,
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ActivityDetailPage(id: _activities[i]['id'] as int))),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: AppStyles.cardDecoration,
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 75,
                                decoration: BoxDecoration(color: const Color(0xFFFFE082), borderRadius: BorderRadius.circular(12)),
                                child: const FaIcon(FontAwesomeIcons.calendarDays, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_activities[i]['title']?.toString() ?? '活动', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text(_activities[i]['summary']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                    Text('${_activities[i]['viewCount'] ?? 0}次浏览', style: const TextStyle(fontSize: 12, color: AppStyles.primary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
