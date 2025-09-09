import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';

class GoalCard extends StatefulWidget {
  final Goal goal;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onContribute,
    required this.onDelete,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.goal.progressPercentage,
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController.forward();
    if (widget.goal.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.goal.isCompleted ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: _getGoalGradient(),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.goal.isCompleted ? null : widget.onContribute,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildProgressSection(),
                      const SizedBox(height: 16),
                      _buildDetailsSection(),
                      if (!widget.goal.isCompleted) ...[
                        const SizedBox(height: 16),
                        _buildActionButtons(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.goal.isCompleted ? Icons.celebration : Icons.flag,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.goal.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.goal.isCompleted ? 'Completed!' : 'In Progress',
                style: TextStyle(
                  color:
                      widget.goal.isCompleted
                          ? AppTheme.warmOrange
                          : AppTheme.softPink,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!widget.goal.isCompleted)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppTheme.deepPurple,
            onSelected: (value) {
              if (value == 'delete') {
                widget.onDelete();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppTheme.roseRed),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
          ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '₱${widget.goal.currentAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '₱${widget.goal.targetAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.softPink,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.goal.isCompleted
                    ? AppTheme.warmOrange
                    : AppTheme.softPink,
              ),
              minHeight: 8,
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.goal.progressPercentage * 100).toStringAsFixed(1)}% Complete',
          style: const TextStyle(
            color: AppTheme.softPink,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: _buildDetailItem(
              'Daily Goal',
              '₱${widget.goal.dailyGoal.toStringAsFixed(2)}',
              Icons.trending_up,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: _buildDetailItem(
              'Days Left',
              '${widget.goal.daysRemaining}',
              Icons.schedule,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: _buildDetailItem(
              'Status',
              widget.goal.isOnTrack ? 'On Track' : 'Behind',
              widget.goal.isOnTrack ? Icons.check_circle : Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    Color statusColor = AppTheme.softPink;
    if (label == 'Status') {
      statusColor =
          widget.goal.isOnTrack ? AppTheme.warmOrange : AppTheme.roseRed;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: statusColor, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.softPink, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onContribute,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Contribute'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warmOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _getGoalGradient() {
    if (widget.goal.isCompleted) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.warmOrange, AppTheme.roseRed],
      );
    } else if (widget.goal.isOnTrack) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.deepPurple, AppTheme.wineRed],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.wineRed, AppTheme.roseRed],
      );
    }
  }
}
