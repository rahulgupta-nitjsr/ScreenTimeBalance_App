import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit_category.dart';
import '../utils/theme.dart';
import '../widgets/zen_button.dart';
import '../widgets/zen_input_field.dart';
import '../widgets/glass_card.dart';

/// Dialog for editing a habit entry
/// 
/// **Product Learning:**
/// Dialogs should be focused and single-purpose. This dialog does ONE thing:
/// edit a single habit category's minutes. It doesn't try to edit everything
/// at once, which would be overwhelming.
class EditHabitDialog extends StatefulWidget {
  const EditHabitDialog({
    super.key,
    required this.category,
    required this.currentMinutes,
    required this.onSave,
    this.maxMinutes = 240,
  });

  final HabitCategory category;
  final int currentMinutes;
  final Function(int newMinutes, String? reason) onSave;
  final int maxMinutes;

  @override
  State<EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  late TextEditingController _minutesController;
  late TextEditingController _reasonController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(text: widget.currentMinutes.toString());
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newMinutes = int.parse(_minutesController.text);
    final reason = _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim();

    widget.onSave(newMinutes, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.category.primaryColor(context).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.category.icon,
                        color: widget.category.primaryColor(context),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit ${widget.category.label}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Current: ${widget.currentMinutes} minutes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceLG),

                // Minutes Input
                ZenInputField(
                  controller: _minutesController,
                  label: 'New Minutes',
                  hint: 'Enter minutes (0-${widget.maxMinutes})',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter minutes';
                    }
                    final minutes = int.tryParse(value);
                    if (minutes == null) {
                      return 'Please enter a valid number';
                    }
                    if (minutes < 0) {
                      return 'Minutes cannot be negative';
                    }
                    if (minutes > widget.maxMinutes) {
                      return 'Maximum is ${widget.maxMinutes} minutes';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppTheme.spaceMD),

                // Reason Input (Optional)
                ZenInputField(
                  controller: _reasonController,
                  label: 'Reason (Optional)',
                  hint: 'Why are you changing this?',
                ),

                const SizedBox(height: AppTheme.spaceMD),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spaceSM),
                      Expanded(
                        child: Text(
                          'Large changes (>30 min) require confirmation',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spaceLG),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMD),
                    Expanded(
                      child: ZenButton.primary(
                        _isSaving ? 'Saving...' : 'Save Changes',
                        onPressed: _isSaving ? null : _handleSave,
                        trailing: _isSaving ? null : const Icon(Icons.check),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation dialog for large changes
/// 
/// **Product Learning:**
/// This implements "confirmation bias prevention". Users often click through
/// warnings without reading. By showing the specific change in clear language,
/// we make them pause and think.
class ConfirmLargeChangeDialog extends StatelessWidget {
  const ConfirmLargeChangeDialog({
    super.key,
    required this.changeSummary,
    required this.onConfirm,
  });

  final String changeSummary;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
              ),

              const SizedBox(height: AppTheme.spaceLG),

              // Title
              const Text(
                'Confirm Large Change',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spaceMD),

              // Change Summary
              Text(
                changeSummary,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.spaceLG),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMD),
                  Expanded(
                    child: ZenButton.primary(
                      'Confirm',
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        onConfirm();
                      },
                      trailing: const Icon(Icons.check_circle_outline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

