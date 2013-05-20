CSKeyboardControlView
=====================

Keyboard Control View for iPhone
================================
USAGES:

1. Copy CSKeyboardControlView folder, then Add to your Project.

2. Show Keyboard Control:
    - More convenient way: (recommend)
        [CSKeyboardControlView showWithObject:ID withCallbackForCancel:SELECTOR1 withCallbackForDo:SELECTOR2];
            . ID: container of the callback
            . SELECTOR1: cancel callback
            . SELECTOR2: perform action callback
    - Show it in an UIView: only if your View is Fullscreen, not recommend
        [CSKeyboardControlView showInView:VIEW withObject:ID withCallbackForCancel:SELECTOR1 withCallbackForDo:SELECTOR2];
            . VIEW: the view that contains Keyboard Control
            . ID: container of the callback
            . SELECTOR1: cancel callback
            . SELECTOR2: perform action callback

3. Dismiss Keyboard Control:
    - Keyboard will be disappeared automatically if you press on Cancel or Done button.
    - In case you want to dismiss the Keyboard Control without pressing those buttons, call this:
        [CSKeyboardControlView dismiss];

================================================================================
CREDITS:

- Done by Hector Zhao (Long Trieu)

================================================================================