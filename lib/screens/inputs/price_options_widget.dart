import 'package:flutter/material.dart';
import 'package:delta_mager_pro_mangement_app/logic/model/product_unit.dart';

class PriceOptionsWidget extends StatefulWidget {
  final List<PriceOption> initialPriceOptions;
  final Function(List<PriceOption>) onPriceOptionsChanged;

  const PriceOptionsWidget({
    super.key,
    required this.initialPriceOptions,
    required this.onPriceOptionsChanged,
  });

  @override
  State<PriceOptionsWidget> createState() => _PriceOptionsWidgetState();
}

class _PriceOptionsWidgetState extends State<PriceOptionsWidget> {
  late List<PriceOption> _options;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.initialPriceOptions);
  }

  void _addOption() {
    // Get the first visible unit as a fallback to avoid crash if 'piece' is not allowed
    final defaultUnit = ProductUnit.values.firstWhere(
      (u) => u.isVisible,
      orElse: () => ProductUnit.piece,
    );

    setState(() {
      _options.add(
        PriceOption(
          quantity: 1.0,
          unit: defaultUnit,
          price: 0.0,
          isDefault: _options.isEmpty,
        ),
      );
      widget.onPriceOptionsChanged(_options);
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      widget.onPriceOptionsChanged(_options);
    });
  }

  void _updateOption(int index, PriceOption newOpt) {
    setState(() {
      if (newOpt.isDefault) {
        for (int i = 0; i < _options.length; i++) {
          if (i != index) {
            _options[i] = _options[i].copyWith(isDefault: false);
          }
        }
      }
      _options[index] = newOpt;
      widget.onPriceOptionsChanged(_options);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'خيارات الأسعار',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('إضافة حجم'),
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _options.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final opt = _options[index];
            return _PriceOptionItem(
              option: opt,
              onChanged: (newOpt) => _updateOption(index, newOpt),
              onRemove: () => _removeOption(index),
            );
          },
        ),
      ],
    );
  }
}

class _PriceOptionItem extends StatefulWidget {
  final PriceOption option;
  final Function(PriceOption) onChanged;
  final VoidCallback onRemove;

  const _PriceOptionItem({
    required this.option,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_PriceOptionItem> createState() => _PriceOptionItemState();
}

class _PriceOptionItemState extends State<_PriceOptionItem> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _oldPriceController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: _formatNumber(widget.option.quantity),
    );
    _priceController = TextEditingController(
      text: _formatNumber(widget.option.price),
    );
    _oldPriceController = TextEditingController(
      text: _formatNumber(widget.option.oldPrice ?? 0),
    );
  }

  @override
  void didUpdateWidget(_PriceOptionItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers only if external change happened (e.g. from quick size chip)
    final newQuantityText = _formatNumber(widget.option.quantity);
    if (_quantityController.text != newQuantityText &&
        double.tryParse(_quantityController.text) != widget.option.quantity) {
      _quantityController.text = newQuantityText;
    }

    final newPriceText = _formatNumber(widget.option.price);
    if (_priceController.text != newPriceText &&
        double.tryParse(_priceController.text) != widget.option.price) {
      _priceController.text = newPriceText;
    }

    final newOldPriceText = _formatNumber(widget.option.oldPrice ?? 0);
    if (_oldPriceController.text != newOldPriceText &&
        double.tryParse(_oldPriceController.text) !=
            (widget.option.oldPrice ?? 0)) {
      _oldPriceController.text = newOldPriceText;
    }
  }

  String _formatNumber(double value) {
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final val = double.tryParse(v) ?? 0;
                      widget.onChanged(widget.option.copyWith(quantity: val));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<ProductUnit>(
                    value: widget.option.unit,
                    decoration: InputDecoration(
                      labelText: 'الوحدة',
                      border: OutlineInputBorder(),
                    ),
                    items: ProductUnit.values
                        .where((u) => u.isVisible || u == widget.option.unit)
                        .map(
                          (u) => DropdownMenuItem(
                            value: u,
                            child: Text(u.nameAr),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null)
                        widget.onChanged(widget.option.copyWith(unit: val));
                    },
                  ),
                ),
              ],
            ),
            if (widget.option.unit.quickSizes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.option.unit.quickSizes.map((qs) {
                  final isSelected = widget.option.quantity == qs.quantity;
                  return ActionChip(
                    avatar: Icon(
                      Icons.straighten,
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                    label: Text(
                      qs.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    backgroundColor: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    onPressed: () {
                      widget.onChanged(
                        widget.option.copyWith(quantity: qs.quantity),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر الحالي',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final val = double.tryParse(v) ?? 0;
                      widget.onChanged(widget.option.copyWith(price: val));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _oldPriceController,
                    decoration: const InputDecoration(
                      labelText: 'السعر القديم',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      widget.onChanged(widget.option.copyWith(oldPrice: val));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: widget.option.isDefault,
                      onChanged: (v) => widget.onChanged(
                        widget.option.copyWith(isDefault: v ?? false),
                      ),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const Text('السعر الافتراضي'),
                  ],
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
