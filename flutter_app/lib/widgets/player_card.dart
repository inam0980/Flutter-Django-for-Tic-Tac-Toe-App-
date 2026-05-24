import 'package:flutter/material.dart';

import '../models/user.dart';
import '../theme.dart';

/// Compact player card with avatar, name, and mark. Active player gets a
/// vibrant orange border + "YOUR TURN" banner overlay.
class PlayerCard extends StatelessWidget {
  final User? user;
  final String mark;
  final bool isTheirTurn;
  final String? fallbackLabel;
  final bool isYou;

  const PlayerCard({
    super.key,
    required this.user,
    required this.mark,
    required this.isTheirTurn,
    this.fallbackLabel,
    this.isYou = false,
  });

  @override
  Widget build(BuildContext context) {
    final isAI = user == null && (fallbackLabel?.startsWith('AI') ?? false);
    final label = isYou
        ? 'You'
        : (user?.username ?? (isAI ? 'AI' : (fallbackLabel ?? 'Opponent')));
    final markColor = mark == 'X' ? NeonColors.xMark : NeonColors.oMark;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: NeonColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isTheirTurn ? NeonColors.orange : NeonColors.bgElevated,
            width: isTheirTurn ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            _Avatar(isYou: isYou, isAI: isAI, mark: mark),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NeonColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  if (isTheirTurn)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('YOUR TURN',
                            style: TextStyle(
                              color: NeonColors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            )),
                        const SizedBox(width: 4),
                        Container(
                          width: 14,
                          height: 2,
                          color: NeonColors.orange,
                        ),
                      ],
                    )
                  else
                    Text(
                      mark,
                      style: TextStyle(
                        color: markColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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

class _Avatar extends StatelessWidget {
  final bool isYou;
  final bool isAI;
  final String mark;
  const _Avatar({required this.isYou, required this.isAI, required this.mark});

  @override
  Widget build(BuildContext context) {
    final markColor = mark == 'X' ? NeonColors.xMark : NeonColors.oMark;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: NeonColors.bgElevated,
        shape: BoxShape.circle,
        border: Border.all(color: markColor.withValues(alpha: 0.45), width: 1.4),
      ),
      child: Center(
        child: Icon(
          isAI
              ? Icons.smart_toy_outlined
              : (isYou ? Icons.person : Icons.person_outline),
          color: markColor,
          size: 22,
        ),
      ),
    );
  }
}
