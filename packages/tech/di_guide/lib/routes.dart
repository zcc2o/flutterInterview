import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/di_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.di: GoRoute(
    path: InterviewRoutes.di.path,
    builder: (context, state) => const DiScreen(),
  ),
};
