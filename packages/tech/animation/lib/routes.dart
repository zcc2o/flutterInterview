import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/animation_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.animation: GoRoute(
    path: InterviewRoutes.animation.path,
    builder: (context, state) => const AnimationScreen(),
  ),
};
