import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  final bool isRussian;
  final VoidCallback onComplete;

  const OnboardingPage({
    super.key,
    required this.isRussian,
    required this.onComplete,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _prefsKey = 'onboardingSeen';
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _markOnboardingAsSeen();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    widget.onComplete();
  }

  void _onSkip() {
    widget.onComplete();
  }

  List<_OnboardingStep> get _steps => [
        _OnboardingStep(
          icon: Icons.task_alt_outlined,
          title: widget.isRussian ? 'Добро пожаловать!' : 'Welcome!',
          text: widget.isRussian
              ? 'Организуйте свою жизнь с TodoList — приложением для управления задачами.'
              : 'Organize your life with TodoList — your task management companion.',
        ),
        _OnboardingStep(
          icon: Icons.app_registration_outlined,
          title: widget.isRussian ? 'Все задачи в одном месте' : 'All tasks in one place',
          text: widget.isRussian
              ? 'Добавляйте, редактируйте и отмечайте задачи за день, неделю и месяц.'
              : 'Add, edit, and complete tasks for today, this week, and beyond.',
        ),
        _OnboardingStep(
          icon: Icons.check_circle_outline,
          title: widget.isRussian ? 'Начните прямо сейчас' : 'Start right now',
          text: widget.isRussian
              ? 'Постройте привычку и доводите задачи до конца каждый день.'
              : 'Build a habit and finish your tasks every day.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = _steps;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _onSkip,
            child: Text(
              widget.isRussian ? 'Пропустить' : 'Skip',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final step = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            color: theme.colorScheme.primary,
                            size: 92,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          step.text,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 24 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1
                            ? (widget.isRussian ? 'Начать' : 'Get started')
                            : (widget.isRussian ? 'Далее' : 'Next'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String text;

  _OnboardingStep({
    required this.icon,
    required this.title,
    required this.text,
  });
}
