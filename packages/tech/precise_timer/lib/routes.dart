import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/timer_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.timer: GoRoute(
    path: InterviewRoutes.timer.path,
    builder: (context, state) => const TimerScreen(),
  ),
};
