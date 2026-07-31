import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:pnestaffapp/core/di/injection.config.dart';

/// The global service locator. Prefer constructor injection (via `@injectable`)
/// over reaching into this directly; use it only at composition roots (bootstrap,
/// `BlocProvider(create: (_) => getIt())`, background isolates).
final GetIt getIt = GetIt.instance;

/// Wires up every `@injectable` binding for the given [environment]
/// (`Flavor.name` — `dev` / `staging` / `prod`). Call once from `bootstrap`,
/// *after* the active [FlavorConfig] has been registered.
@InjectableInit()
Future<void> configureDependencies(String environment) async {
  await getIt.init(environment: environment);
}
