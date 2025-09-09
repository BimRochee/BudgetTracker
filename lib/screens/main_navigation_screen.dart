import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_provider.dart';
import '../theme/app_theme.dart';
import '../utils/error_handler.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'bills_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Dashboard',
      screen: const DashboardScreen(),
    ),
    NavigationItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Reports',
      screen: const ReportsScreen(),
    ),
    NavigationItem(
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
      label: 'Bills',
      screen: const BillsScreen(),
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      screen: const SettingsScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize animation controllers for each tab
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Initialize scale animations
    _scaleAnimations =
        _animationControllers
            .map(
              (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              ),
            )
            .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Animate the previous tab icon back to normal
      _animationControllers[_currentIndex].reverse();

      // Animate the new tab icon
      _animationControllers[index].forward();

      // Navigate to the new page with animation
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Animate all icons back to normal
            for (var controller in _animationControllers) {
              controller.reverse();
            }
            // Animate the current tab icon
            _animationControllers[index].forward();
          },
          children: _navigationItems.map((item) => item.screen).toList(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.deepPurple.withValues(alpha: 0.95),
              AppTheme.darkIndigo.withValues(alpha: 0.98),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  _navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == _currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabTapped(index),
                        child: AnimatedBuilder(
                          animation: _scaleAnimations[index],
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimations[index].value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppTheme.warmOrange.withValues(
                                            alpha: 0.2,
                                          )
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      isSelected
                                          ? Border.all(
                                            color: AppTheme.warmOrange
                                                .withValues(alpha: 0.5),
                                            width: 1,
                                          )
                                          : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        isSelected
                                            ? item.activeIcon
                                            : item.icon,
                                        key: ValueKey(isSelected),
                                        color:
                                            isSelected
                                                ? AppTheme.warmOrange
                                                : AppTheme.softPink,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? AppTheme.warmOrange
                                                : AppTheme.softPink,
                                        fontSize: 12,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                      ),
                                      child: Text(
                                        item.label,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton:
          _currentIndex == 0 ? _buildFloatingActionButton(context) : null,
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: AppTheme.warmOrange,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    ErrorHandler.logInfo('Add Expense Dialog opened');
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedWalletId = '';

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              final budgetProvider = Provider.of<BudgetProvider>(
                context,
                listen: false,
              );
              if (selectedWalletId.isEmpty &&
                  budgetProvider.wallets.isNotEmpty) {
                selectedWalletId = budgetProvider.wallets.first.id;
              }

              // Log wallet information for debugging
              ErrorHandler.logInfo(
                'Available wallets: ${budgetProvider.wallets.length}',
              );
              ErrorHandler.logInfo('Selected wallet ID: $selectedWalletId');

              return AlertDialog(
                backgroundColor: AppTheme.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  'Add Expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: AppTheme.softPink),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          labelStyle: TextStyle(color: AppTheme.softPink),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: AppTheme.softPink),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value:
                            selectedWalletId.isEmpty ? null : selectedWalletId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Pay with',
                          labelStyle: TextStyle(color: AppTheme.softPink),
                        ),
                        dropdownColor: AppTheme.deepPurple,
                        style: const TextStyle(color: Colors.white),
                        items:
                            budgetProvider.wallets.isEmpty
                                ? [
                                  const DropdownMenuItem(
                                    value: 'no_wallet',
                                    child: Text('No wallets available'),
                                  ),
                                ]
                                : budgetProvider.wallets.map((wallet) {
                                  return DropdownMenuItem(
                                    value: wallet.id,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getWalletIcon(wallet.icon),
                                          color: Color(
                                            int.parse(
                                              wallet.color.replaceFirst(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          ),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            wallet.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '₱${wallet.balance.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppTheme.softPink,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedWalletId = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.softPink),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final description = descriptionController.text;
                        final amount =
                            double.tryParse(amountController.text) ?? 0.0;
                        final category = categoryController.text;

                        ErrorHandler.logInfo(
                          'Add Expense Button pressed - Description: $description, Amount: $amount, Category: $category, WalletId: $selectedWalletId',
                        );

                        if (description.isNotEmpty &&
                            amount > 0 &&
                            category.isNotEmpty &&
                            selectedWalletId.isNotEmpty &&
                            selectedWalletId != 'no_wallet') {
                          await budgetProvider.addExpense(
                            description,
                            amount,
                            category,
                            selectedWalletId,
                          );
                          ErrorHandler.logInfo('Expense added successfully');
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } else {
                          String errorMessage =
                              'Add Expense validation failed - ';
                          if (description.isEmpty) {
                            errorMessage += 'Description required. ';
                          }
                          if (amount <= 0) {
                            errorMessage += 'Amount must be greater than 0. ';
                          }
                          if (category.isEmpty) {
                            errorMessage += 'Category required. ';
                          }
                          if (selectedWalletId.isEmpty ||
                              selectedWalletId == 'no_wallet') {
                            errorMessage += 'Please select a valid wallet.';
                          }

                          ErrorHandler.logWarning(errorMessage);
                        }
                      } catch (e, stackTrace) {
                        ErrorHandler.logError(
                          'Error adding expense',
                          e,
                          stackTrace,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warmOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  IconData _getWalletIcon(String iconName) {
    switch (iconName) {
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'savings':
        return Icons.savings;
      case 'money':
        return Icons.money;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.account_balance_wallet;
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}
