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
      backgroundColor: theme.colorScheme.primaryContainer,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.28),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.16),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary.withValues(alpha: 0.24),
                    theme.colorScheme.surfaceVariant.withValues(alpha: 0.12),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isRussian ? 'Todolist' : 'Todolist',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isRussian ? 'Экран быстрого старта' : 'Quick start tour',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onBackground.withValues(alpha: 0.74),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _onSkip,
                        child: Text(
                          widget.isRussian ? 'Пропустить' : 'Skip',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(26),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withValues(alpha: 0.18),
                                    theme.colorScheme.primaryContainer.withValues(alpha: 0.07),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                                    blurRadius: 28,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.secondary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.28),
                                          blurRadius: 22,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      step.icon,
                                      color: Colors.white,
                                      size: 60,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    step.title,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    step.text,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onBackground.withValues(alpha: 0.72),
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6.0),
                            width: _currentPage == index ? 26 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: _currentPage == index
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.onBackground.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.onBackground,
                                  side: BorderSide(color: theme.colorScheme.onBackground.withValues(alpha: 0.18)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(widget.isRussian ? 'Назад' : 'Back'),
                              ),
                            ),
                          if (_currentPage > 0) const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                              ),
                              child: Text(
                                widget.isRussian ? 'Далее' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
