import 'package:go_router/go_router.dart';
import 'package:interview_core/interview_core.dart';
import 'screens/state_screen.dart';
import 'screens/setstate_page.dart';
import 'screens/inherited_page.dart';
import 'screens/changenotifier_page.dart';
import 'screens/provider_page.dart';
import 'screens/riverpod_page.dart';
import 'screens/immutable_model_page.dart';
import 'screens/riverpod_improved_page.dart';

final routes = <InterviewRoutes, GoRoute>{
  InterviewRoutes.state: GoRoute(
    path: InterviewRoutes.state.path,
    builder: (context, state) => const StateScreen(),
    routes: [
      GoRoute(
        path: 'setstate',
        builder: (context, state) => const SetStatePage(),
      ),
      GoRoute(
        path: 'inherited',
        builder: (context, state) => const InheritedPage(),
      ),
      GoRoute(
        path: 'changenotifier',
        builder: (context, state) => const ChangeNotifierPage(),
      ),
      GoRoute(
        path: 'provider',
        builder: (context, state) => const ProviderPage(),
      ),
      GoRoute(
        path: 'riverpod',
        builder: (context, state) => const RiverpodPage(),
      ),
      GoRoute(
        path: 'immutable-model',
        builder: (context, state) => const ImmutableModelPage(),
      ),
      GoRoute(
        path: 'riverpod-improved',
        builder: (context, state) => const RiverpodImprovedPage(),
      ),
    ],
  ),
};
