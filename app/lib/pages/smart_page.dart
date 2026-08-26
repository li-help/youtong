import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/app_styles.dart';
import '../widgets/app_page_route.dart';
import 'smart_result_page.dart';

class SmartPage extends StatefulWidget {
  /// 从首页「小宇宙计划」带入的初始年龄段（如 "2-3岁"），自动选中相近档位
  final String? initialAge;
  const SmartPage({super.key, this.initialAge});

  @override
  State<SmartPage> createState() => _SmartPageState();
}

class _SmartPageState extends State<SmartPage> {
  int? _selectedAge;
  double _height = 100;
  double _weight = 22;

  final List<Map<String, dynamic>> _ages = [
    {'label': '0-1岁', 'icon': FontAwesomeIcons.baby},
    {'label': '1-3岁', 'icon': FontAwesomeIcons.child},
    {'label': '3-6岁', 'icon': FontAwesomeIcons.childReaching},
    {'label': '6岁以上', 'icon': FontAwesomeIcons.school},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialAge != null) {
      // 根据带入的年龄段（如 "2-3岁"）匹配最接近的档位
      final lower = int.tryParse(widget.initialAge!.split('-').first) ?? 0;
      if (lower <= 1) _selectedAge = 0;
      else if (lower <= 3) _selectedAge = 1;
      else if (lower <= 6) _selectedAge = 2;
      else _selectedAge = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppStyles.bg, AppStyles.amberSoft],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.of(context).maybePop()),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppStyles.bg, AppStyles.primaryLight]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppStyles.primaryLight)),
                        child: const Text('宝宝档案', style: TextStyle(color: AppStyles.primary)),
                      ),
                      const SizedBox(height: 12),
                      const Text('智能推荐', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppStyles.primary)),
                      const Text('填写宝宝信息，获得更贴心的推荐', style: TextStyle(color: AppStyles.textSub)),
                    ],
                  ),
                ),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('宝宝年龄'),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _ages.length,
                        itemBuilder: (context, i) => GestureDetector(
                          onTap: () => setState(() => _selectedAge = i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedAge == i ? AppStyles.amberSoft : AppStyles.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _selectedAge == i ? AppStyles.primary : Colors.transparent, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(_ages[i]['icon'] as FaIconData, color: AppStyles.primary, size: 32),
                                Text(_ages[i]['label'] as String, style: const TextStyle(color: AppStyles.textSub)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('身高'),
                      Center(child: Text('${_height.toInt()} cm', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppStyles.primary))),
                      Slider(
                        value: _height,
                        min: 50,
                        max: 160,
                        activeColor: AppStyles.primary,
                        inactiveColor: const Color(0xFFFFE082),
                        onChanged: (v) => setState(() => _height = v),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('50cm', style: TextStyle(color: AppStyles.textLight)), Text('160cm', style: TextStyle(color: AppStyles.textLight))],
                      ),
                    ],
                  ),
                ),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('体重'),
                      Center(child: Text('${_weight.toInt()} kg', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppStyles.primary))),
                      Slider(
                        value: _weight,
                        min: 15,
                        max: 40,
                        activeColor: AppStyles.primary,
                        inactiveColor: const Color(0xFFFFE082),
                        onChanged: (v) => setState(() => _weight = v),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text('15kg', style: TextStyle(color: AppStyles.textLight)), Text('40kg', style: TextStyle(color: AppStyles.textLight))],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selectedAge == null
                        ? null
                        : () => Navigator.of(context).push(AppPageRoute(
                              builder: (_) => SmartResultPage(
                                age: _ages[_selectedAge!]['label'] as String,
                                height: _height.toInt(),
                                weight: _weight.toInt(),
                              ),
                            )),
                    style: AppStyles.primaryButton,
                    child: const Text('查看智能推荐'),
                  ),
                ),
                if (_selectedAge == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(child: Text('请先选择宝宝年龄', style: TextStyle(color: AppStyles.textLight))),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: child,
    );
  }

  Widget _label(String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppStyles.primaryLight, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppStyles.textMain)),
      ],
    );
  }
}
