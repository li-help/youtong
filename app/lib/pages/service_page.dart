import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_network_image.dart';

class ServicePage extends StatefulWidget {
  final String title;
  const ServicePage({super.key, this.title = '优享服务'});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  List<dynamic> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService.listServices(page: 1, pageSize: 50);
      setState(() {
        _services = res['data']?['list'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.white, foregroundColor: AppStyles.textMain),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppStyles.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppStyles.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                itemBuilder: (ctx, i) {
                  final s = _services[i] as Map<String, dynamic>;
                  final cover = (s['cover'] ?? s['image'])?.toString();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: AppStyles.cardDecoration,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                          child: AppNetworkImage(url: cover, width: 110, height: 110, fit: BoxFit.cover),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name']?.toString() ?? '服务',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
                                const SizedBox(height: 6),
                                Text(s['description']?.toString() ?? '',
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, color: AppStyles.textSub)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    if (s['price'] != null)
                                      Text('¥${s['price']}', style: const TextStyle(fontSize: 17, color: AppStyles.primary, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppStyles.primary, borderRadius: BorderRadius.circular(20)),
                                      child: InkWell(
                                        onTap: () {
                                          if (s['phone'] != null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('联系电话：${s['phone']}')),
                                            );
                                          }
                                        },
                                        child: const Text('预约', style: TextStyle(color: Colors.white, fontSize: 13)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
