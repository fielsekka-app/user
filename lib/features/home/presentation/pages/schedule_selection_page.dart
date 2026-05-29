import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ios_components.dart';
import '../../../booking/presentation/pages/subscription_page.dart';

class ScheduleSelectionPage extends StatefulWidget {
  final String city;
  final String university;
  final String pickupPoint;

  const ScheduleSelectionPage({
    super.key,
    required this.city,
    required this.university,
    required this.pickupPoint,
  });

  @override
  State<ScheduleSelectionPage> createState() => _ScheduleSelectionPageState();
}

class _ScheduleSelectionPageState extends State<ScheduleSelectionPage> {
  String selectedType = 'departure'; // 'departure' or 'return'
  String? selectedTime;

  final schedules = {
    'departure': ['6:00 AM', '6:30 AM', '7:00 AM', '7:30 AM', '8:00 AM'],
    'return': ['2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'],
  };

  @override
  Widget build(BuildContext context) {
    final currentTimes = schedules[selectedType]!;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('اختار الميعاد'),
        backgroundColor: AppTheme.backgroundColor,
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Info Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IOSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(CupertinoIcons.building_2_fill, widget.city),
                    const SizedBox(height: 8),
                    _buildInfoRow(CupertinoIcons.book_fill, widget.university),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      CupertinoIcons.location_fill,
                      widget.pickupPoint,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),

            // Toggle Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<String>(
                  groupValue: selectedType,
                  children: const {
                    'departure': Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'ذهاب',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                        ),
                      ),
                    ),
                    'return': Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'عودة',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          decorationColor: Colors.transparent,
                        ),
                      ),
                    ),
                  },
                  onValueChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedType = value;
                        selectedTime = null;
                      });
                    }
                  },
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Times List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: currentTimes.length,
                itemBuilder: (context, index) {
                  final time = currentTimes[index];
                  final isSelected = selectedTime == time;

                  return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IOSListTile(
                          title: time,
                          leading: Icon(
                            CupertinoIcons.clock,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : CupertinoColors.systemGrey,
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  CupertinoIcons.check_mark,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                          showDivider: true,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 400 + (index * 50)))
                      .slideX();
                },
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IOSButton(
                text: 'كمل',
                onPressed: selectedTime != null
                    ? () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const SubscriptionPage(),
                          ),
                        );
                      }
                    : null,
                color: selectedTime != null
                    ? AppTheme.primaryColor
                    : CupertinoColors.systemGrey4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppTheme.textTheme.bodyMedium)),
      ],
    );
  }
}
