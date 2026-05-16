import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/http_screen.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.http: GoRoute(
    path: InterviewRoutes.http.path,
    builder: (context, state) => const HttpScreen(),
  ),
};
