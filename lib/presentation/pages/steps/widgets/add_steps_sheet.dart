import 'package:assistant/presentation/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal bottom sheet for adding custom step counts
class AddStepsSheet extends StatefulWidget {
  final Function(int steps) onAdd;

  const AddStepsSheet({
    super.key,
    required this.onAdd,
  });

  static void show(BuildContext context, {required Function(int steps) onAdd}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStepsSheet(onAdd: onAdd),
    );
  }

  @override
  State<AddStepsSheet> createState() => _AddStepsSheetState();
}

class _AddStepsSheetState extends State<AddStepsSheet> {
  final TextEditingController _stepsController = TextEditingController();
  int _selectedPreset = 0;

  final List<int> _presets = [1000, 2000, 3000, 5000, 7500, 10000];

  @override
  void initState() {
    super.initState();
    _stepsController.text = '1000';
  }

  @override
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  void _submit() {
    final steps = int.tryParse(_stepsController.text) ?? 0;
    if (steps > 0) {
      widget.onAdd(steps);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.successColor,
            AppTheme.primaryColor,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_walk,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Steps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Log your walking activity',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              // Input field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _stepsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            final steps = int.tryParse(value) ?? 0;
                            _selectedPreset = _presets.indexOf(steps);
                          });
                        },
                      ),
                    ),
                    Text(
                      'steps',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Presets
              Text(
                'Quick Select',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _presets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final preset = entry.value;
                  final isSelected = _selectedPreset == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPreset = index;
                        _stepsController.text = preset.toString();
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _formatNumber(preset),
                        style: TextStyle(
                          color: isSelected
                              ? AppTheme.successColor
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 24),
                      const SizedBox(width: 8),
                      const Text(
                        'Add Steps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return number.toString();
  }
}
