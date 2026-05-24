import 'package:flutter/material.dart';
import '../theme.dart';

/// 3x3 grid that renders a 9-char board string and reports cell taps.
/// `interactive` disables taps (e.g. when it's not your turn or game is over).
class GameBoard extends StatelessWidget {
  final String board;
  final bool interactive;
  final ValueChanged<int>? onTap;
  final int? lastMovePosition;
  final int? hintPosition;

  const GameBoard({
    super.key,
    required this.board,
    this.interactive = true,
    this.onTap,
    this.lastMovePosition,
    this.hintPosition,
  });

  @override
  Widget build(BuildContext context) {
    assert(board.length == 9, 'board must be 9 chars');
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: NeonColors.bgSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: NeonColors.orange, width: 1.5),
        ),
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: 9,
          itemBuilder: (ctx, i) {
            final mark = board[i];
            final empty = mark == '.';
            final isLast = lastMovePosition == i;
            final isHint = hintPosition == i && empty;
            final markColor =
                mark == 'X' ? NeonColors.xMark : NeonColors.oMark;

            return Container(
              decoration: BoxDecoration(
                color: NeonColors.bgDeep,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isHint
                      ? NeonColors.orange
                      : (isLast
                          ? markColor.withValues(alpha: 0.6)
                          : NeonColors.bgElevated),
                  width: isHint ? 2 : 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  splashColor: NeonColors.orange.withValues(alpha: 0.25),
                  highlightColor: NeonColors.orange.withValues(alpha: 0.08),
                  onTap: (interactive && empty && onTap != null)
                      ? () => onTap!(i)
                      : null,
                  child: Center(
                    child: empty
                        ? (isHint
                            ? Text('?',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: NeonColors.orange
                                      .withValues(alpha: 0.55),
                                ))
                            : null)
                        : _MarkText(mark: mark, color: markColor),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MarkText extends StatelessWidget {
  final String mark;
  final Color color;
  const _MarkText({required this.mark, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      mark,
      style: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1.0,
        letterSpacing: -2,
      ),
    );
  }
}
