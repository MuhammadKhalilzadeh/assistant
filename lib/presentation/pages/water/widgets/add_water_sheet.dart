import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:assistant/data/mock/models/water_log_model.dart';
import 'beverage_type_selector.dart';

/// Bottom sheet for adding custom water amounts with beverage type selection
class AddWaterSheet extends StatefulWidget {
  final Function(int amount, BeverageType type, String? note) onAdd;

  const AddWaterSheet({
    super.key,
    required this.onAdd,
  });

  /// Static method to show the sheet
  static Future<void> show(
    BuildContext context, {
    required Function(int amount, BeverageType type, String? note) onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWaterSheet(onAdd: onAdd),
    );
  }

  @override
  State<AddWaterSheet> createState() => _AddWaterSheetState();
}

class _AddWaterSheetState extends State<AddWaterSheet> {
  final TextEditingController _amountController = TextEditingController(text: '250');
  final TextEditingController _noteController = TextEditingController();
  BeverageType _selectedType = BeverageType.water;
  double _sliderValue = 250;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;
      _amountController.text = value.toInt().toString();
    });
  }

  void _onAmountChanged(String value) {
    final amount = int.tryParse(value) ?? 250;
    setState(() {
      _sliderValue = amount.clamp(0, 2000).toDouble();
    });
  }

  void _handleAdd() {
    final amount = int.tryParse(_amountController.text) ?? 250;
    if (amount > 0) {
      HapticFeedback.mediumImpact();
      widget.onAdd(
        amount,
        _selectedType,
        _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF06B6D4),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Center(
                        child: Text(
                          'Add Water',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Amount input
                      const Text(
                        'Amount (ml)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            suffixText: 'ml',
                            suffixStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 18,
                            ),
                          ),
                          onChanged: _onAmountChanged,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _sliderValue.clamp(0, 2000),
                          min: 0,
                          max: 2000,
                          divisions: 40,
                          label: '${_sliderValue.toInt()}ml',
                          onChanged: _onSliderChanged,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0ml',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '2000ml',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Beverage type
                      const Text(
                        'Beverage Type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BeverageTypeSelector(
                        selectedType: _selectedType,
                        onTypeSelected: (type) {
                          setState(() => _selectedType = type);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Note field
                      const Text(
                        'Note (optional)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: TextField(
                          controller: _noteController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            hintText: 'Add a note...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Add button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleAdd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Add Water',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
