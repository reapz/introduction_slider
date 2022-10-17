library introduction_slider;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/widgets.dart';

// ignore: must_be_immutable
class IntroductionSlider extends StatefulWidget {
  /// Defines the appearance of the introduction slider items that are arrayed
  /// within the introduction slider.
  final List<IntroductionSliderItem> items;

  /// Determines the physics of a [Scrollable] widget.
  final ScrollPhysics? physics;

  /// The [Back] that is used to navigate to the previous page.
  final Back? back;

  /// The [Next] that is used to navigate to the next page.
  final Next? next;

  /// The [Done] that is used to navigate to the target page.
  final Done? done;

  final Widget? topRight;

  /// The [DotIndicator] that is used to indicate dots.
  final DotIndicator? dotIndicator;

  /// The two cardinal directions in two dimensions.
  final Axis scrollDirection;

  /// Show and hide app status/navigation bar on the introduction slider.
  final bool showStatusBar;

  /// Limit width of next, back and done buttons
  final double? buttonWidth;

  final EdgeInsets padding;

  /// The initial page index of the introduction slider.
  int initialPage;

  IntroductionSlider({
    Key? key,
    required this.items,
    this.showStatusBar = false,
    this.padding = EdgeInsets.zero,
    this.buttonWidth,
    this.initialPage = 0,
    this.physics,
    this.scrollDirection = Axis.horizontal,
    this.back,
    this.done,
    this.next,
    this.topRight,
    this.dotIndicator,
  })  : assert((initialPage <= items.length - 1) && (initialPage >= 0),
            "initialPage can't be less than 0 or greater than items length."),
        super(key: key);

  @override
  State<IntroductionSlider> createState() => _IntroductionSliderState();
}

class _IntroductionSliderState extends State<IntroductionSlider> {
  /// The [PageController] of the introduction slider.
  late PageController pageController;

  /// [hideStatusBar] is used to hide status bar on the introduction slider.
  hideStatusBar(bool value) {
    if (value == false) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.bottom,
          SystemUiOverlay.top,
        ],
      );
    }
  }

  @override
  void initState() {
    pageController = PageController(initialPage: widget.initialPage);
    hideStatusBar(widget.showStatusBar);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastIndex = widget.initialPage == widget.items.length - 1;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        PageView.builder(
          controller: pageController,
          itemCount: widget.items.length,
          physics: widget.physics,
          scrollDirection: widget.scrollDirection,
          onPageChanged: (index) => setState(() => widget.initialPage = index),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: widget.items[index].backgroundColor,
                gradient: widget.items[index].gradient,
              ),
              child: Padding(
                padding: widget.padding.copyWith(bottom: 80),
                child: widget.items[index].child,
              ),
            );
          },
        ),
        Positioned.fill(
          bottom: 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              padding: EdgeInsets.only(
                  left: widget.padding.left,
                  right: widget.padding.right,
                  bottom: widget.padding.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    child: _applyButtonSize(
                      TextButton(
                        onPressed: () => pageController.previousPage(
                          duration: widget.back!.animationDuration!,
                          curve: widget.back!.curve!,
                        ),
                        style: widget.back!.style,
                        child: widget.back!.child,
                      ),
                    ),
                    maintainSize: true,
                    maintainInteractivity: false,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: widget.initialPage > 0 && widget.back != null,
                  ),
                  widget.dotIndicator == null
                      ? const SizedBox()
                      : Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 5,
                          runSpacing: 5,
                          children: List.generate(
                            widget.items.length,
                            (index) => AnimatedContainer(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: index == widget.initialPage
                                    ? widget.dotIndicator?.selectedColor
                                    : widget.dotIndicator?.unselectedColor ??
                                        widget.dotIndicator?.selectedColor
                                            ?.withOpacity(0.5),
                              ),
                              height: widget.dotIndicator?.size,
                              width: index == widget.initialPage
                                  ? widget.dotIndicator!.size! * 2.5
                                  : widget.dotIndicator!.size,
                              duration: const Duration(milliseconds: 350),
                            ),
                          ),
                        ),
                  lastIndex
                      ? Visibility(
                          child: _applyButtonSize(
                            TextButton(
                              onPressed: () {
                                if (widget.done?.onPressed != null) {
                                  widget.done!.onPressed!.call();
                                } else if (widget.done?.home != null) {
                                  Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      transitionDuration:
                                          widget.done!.animationDuration!,
                                      transitionsBuilder: (context, animation,
                                          secondAnimation, child) {
                                        animation = CurvedAnimation(
                                          parent: animation,
                                          curve: widget.done!.curve!,
                                        );
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: widget.scrollDirection ==
                                                    Axis.vertical
                                                ? const Offset(0, 1.0)
                                                : const Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return widget.done!.home!;
                                      },
                                    ),
                                  );
                                }
                              },
                              style: widget.done?.style,
                              child: widget.done?.child ?? const SizedBox(),
                            ),
                          ),
                          maintainSize: true,
                          maintainInteractivity: false,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: widget.done != null,
                        )
                      : widget.next == null
                          ? const SizedBox()
                          : _applyButtonSize(
                              TextButton(
                                onPressed: () => pageController.nextPage(
                                  duration: widget.next!.animationDuration!,
                                  curve: widget.next!.curve!,
                                ),
                                style: widget.next!.style,
                                child: widget.next!.child,
                              ),
                            ),
                ],
              ),
            ),
          ),
        ),
        if (topRight != null)
          Positioned(
            right: widget.padding.right,
            top: widget.padding.top,
            child: topRight!,
          )
      ],
    );
  }

  Widget _applyButtonSize(Widget button) {
    if (widget.buttonWidth == null) return button;

    return Container(
      width: widget.buttonWidth!,
      child: button,
    );
  }
}
