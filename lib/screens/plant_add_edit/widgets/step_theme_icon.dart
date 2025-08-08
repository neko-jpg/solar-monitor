import 'package:flutter/material.dart';

class StepThemeIcon extends StatefulWidget {
  final TextEditingController nameC;
  final Color initialColor;
  final IconData initialIcon;
  final void Function(Color, IconData) onChanged;
  const StepThemeIcon({
    super.key,
    required this.nameC,
    required this.initialColor,
    required this.initialIcon,
    required this.onChanged,
  });

  @override
  State<StepThemeIcon> createState() => _StepThemeIconState();
}

class _StepThemeIconState extends State<StepThemeIcon> {
  late Color color = widget.initialColor;
  late IconData icon = widget.initialIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.nameC,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Theme Color',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              Colors.primaries.take(12).map((c) {
                final selected = color.value == c.value;
                return GestureDetector(
                  onTap: () {
                    setState(() => color = c);
                    widget.onChanged(color, icon);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border:
                          selected
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                    ),
                  ),
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        const Text('Icon', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              [
                Icons.wb_sunny_rounded,
                Icons.solar_power,
                Icons.bolt,
                Icons.energy_savings_leaf_rounded,
              ].map((ic) {
                final selected = icon == ic;
                return ChoiceChip(
                  label: Icon(
                    ic,
                    color: selected ? Colors.white : Colors.black54,
                  ),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => icon = ic);
                    widget.onChanged(color, icon);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}
