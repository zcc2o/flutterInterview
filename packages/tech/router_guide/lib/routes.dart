import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/router_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.router: GoRoute(
    path: InterviewRoutes.router.path,
    builder: (context, state) => const RouterScreen(),
  ),
};
