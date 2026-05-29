import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../providers/auth_provider.dart';

class OtpPage extends ConsumerWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final digitSize = (screenWidth - 120) / 4; // 4 digits with spacing

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(backgroundColor: AppTheme.backgroundColor, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verification",
                style: AppTheme.textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 8),
              Text(
                "Enter the 4-digit code sent to your phone.",
                style: AppTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),
              const SizedBox(height: 48),
              // OTP Input Row with responsive sizing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => _buildOtpDigit(
                    context,
                    index,
                    digitSize.clamp(50.0, 70.0),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),
              CustomButton(
                text: "Verify",
                onPressed: () async {
                  // NOTE: Email should be passed from SignupPage via navigation
                  // For now using placeholder until we implement proper state management
                  final error = await ref
                      .read(authProvider.notifier)
                      .verifyOtp('1234', email);

                  if (error == null && context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  }
                },
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              Center(
                child: CupertinoButton(
                  onPressed: () {},
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigit(BuildContext context, int index, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CupertinoTextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.bold),
          decoration: const BoxDecoration(),
          onChanged: (value) {
            if (value.isNotEmpty) {
              FocusScope.of(context).nextFocus();
            }
          },
        ),
      ),
    );
  }
}
