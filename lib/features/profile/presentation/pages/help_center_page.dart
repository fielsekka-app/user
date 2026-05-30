import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_right, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'مركز المساعدة',
          style: AppTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كيف يمكننا مساعدتك؟',
              style: AppTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // FAQ Items Card — all in one rounded card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const _FaqItem(
                    question: 'كيف يمكنني حجز رحلة؟',
                    answer:
                        'يمكنك حجز رحلة عن طريق اختيار نقطة الانطلاق والوصول من الصفحة الرئيسية، ثم اختيار الوقت المناسب وتأكيد الحجز.',
                    isFirst: true,
                  ),
                  _buildDivider(),
                  const _FaqItem(
                    question: 'كيف يمكنني شحن المحفظة؟',
                    answer:
                        'اذهب إلى صفحة المحفظة من الملف الشخصي، واضغط على زر "شحن الرصيد" واختر طريقة الدفع المناسبة.',
                  ),
                  _buildDivider(),
                  const _FaqItem(
                    question: 'ما هي طرق الدفع المتاحة؟',
                    answer:
                        'نقبل الدفع عن طريق البطاقات البنكية (Visa/Mastercard)، المحافظ الإلكترونية (Vodafone Cash, etc.)، و InstaPay.',
                  ),
                  _buildDivider(),
                  const _FaqItem(
                    question: 'كيف يمكنني إلغاء رحلة؟',
                    answer:
                        'يمكنك إلغاء الرحلة من صفحة "سجل الرحلات" قبل موعد الرحلة بساعة على الأقل.',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            CustomButton(
              onPressed: () {},
              text: 'تواصل مع الدعم الفني',
              icon: CupertinoIcons.phone_fill,
              backgroundColor: AppTheme.primaryColor,
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDivider() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade100,
        indent: 20,
        endIndent: 20,
      );
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isFirst;
  final bool isLast;

  const _FaqItem({
    required this.question,
    required this.answer,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _iconTurn = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(
          top: widget.isFirst ? 4 : 0,
          bottom: widget.isLast ? 4 : 0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question row
              Row(
                children: [
                  // Animated chevron — always grey, never primary color
                  RotationTransition(
                    turns: _iconTurn,
                    child: const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              // Answer — fade + size animation
              SizeTransition(
                sizeFactor: _fadeAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 28),
                    child: Text(
                      widget.answer,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
