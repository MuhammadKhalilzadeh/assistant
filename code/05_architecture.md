# Architecture Patterns for Flutter

This guide covers architectural patterns that help build scalable, maintainable, and testable Flutter applications.

---

## Clean Architecture

Clean Architecture separates concerns into distinct layers, each with clear responsibilities.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│            (Widgets, Screens, State Management)          │
├─────────────────────────────────────────────────────────┤
│                      Domain Layer                        │
│              (Entities, Use Cases, Interfaces)           │
├─────────────────────────────────────────────────────────┤
│                       Data Layer                         │
│         (Repositories, Data Sources, Models)             │
└─────────────────────────────────────────────────────────┘
```

### The Dependency Rule

Dependencies point inward. Outer layers know about inner layers, not vice versa.

- **Presentation** depends on **Domain**
- **Data** depends on **Domain**
- **Domain** depends on nothing

### Data Layer

Handles all data operations: API calls, database queries, caching.

```dart
// Data Source - raw data access
abstract class UserRemoteDataSource {
  Future<UserModel> getUser(int id);
  Future<List<UserModel>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient client;

  UserRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> getUser(int id) async {
    final response = await client.get('/users/$id');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await client.get('/users');
    return (response.data as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }
}

// Model - data representation with serialization
class UserModel {
  final int id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };

  // Convert to domain entity
  User toEntity() => User(id: id, name: name, email: email);
}

// Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> getUser(int id) async {
    try {
      final model = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(model);
      return model.toEntity();
    } catch (e) {
      final cached = await localDataSource.getCachedUser(id);
      if (cached != null) return cached.toEntity();
      rethrow;
    }
  }
}
```

### Domain Layer

Contains business logic, entities, and use case definitions.

```dart
// Entity - pure business object
class User {
  final int id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  bool get isValidEmail => email.contains('@');
}

// Repository Interface (contract)
abstract class UserRepository {
  Future<User> getUser(int id);
  Future<List<User>> getUsers();
  Future<void> updateUser(User user);
}

// Use Case - single business operation
class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<User> call(int userId) {
    return repository.getUser(userId);
  }
}

class UpdateUserProfileUseCase {
  final UserRepository userRepository;
  final NotificationService notificationService;

  UpdateUserProfileUseCase({
    required this.userRepository,
    required this.notificationService,
  });

  Future<void> call(User user) async {
    await userRepository.updateUser(user);
    await notificationService.sendProfileUpdatedNotification(user.id);
  }
}
```

### Presentation Layer

Handles UI and state management.

```dart
// State
abstract class UserState {}
class UserInitial extends UserState {}
class UserLoading extends UserState {}
class UserLoaded extends UserState {
  final User user;
  UserLoaded(this.user);
}
class UserError extends UserState {
  final String message;
  UserError(this.message);
}

// Cubit/Bloc
class UserCubit extends Cubit<UserState> {
  final GetUserUseCase getUserUseCase;

  UserCubit({required this.getUserUseCase}) : super(UserInitial());

  Future<void> loadUser(int id) async {
    emit(UserLoading());
    try {
      final user = await getUserUseCase(id);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}

// Screen
class UserScreen extends StatelessWidget {
  final int userId;

  const UserScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(
        getUserUseCase: context.read<GetUserUseCase>(),
      )..loadUser(userId),
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          return switch (state) {
            UserLoading() => const CircularProgressIndicator(),
            UserLoaded(:final user) => UserProfileView(user: user),
            UserError(:final message) => ErrorView(message: message),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
```

---

## Repository Pattern

Abstracts data sources behind a clean interface.

### Basic Repository

```dart
// Abstract repository
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<void> saveProduct(Product product);
  Future<void> deleteProduct(String id);
}

// Implementation with multiple data sources
class ProductRepositoryImpl implements ProductRepository {
  final ProductApiService api;
  final ProductLocalDatabase db;
  final ProductCache cache;

  ProductRepositoryImpl({
    required this.api,
    required this.db,
    required this.cache,
  });

  @override
  Future<List<Product>> getProducts() async {
    // Check cache first
    final cached = await cache.getProducts();
    if (cached != null) return cached;

    try {
      // Try remote
      final products = await api.fetchProducts();
      await cache.saveProducts(products);
      await db.saveProducts(products);
      return products;
    } catch (e) {
      // Fall back to local
      return db.getProducts();
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    final cached = await cache.getProduct(id);
    if (cached != null) return cached;

    final product = await api.fetchProduct(id);
    await cache.saveProduct(product);
    return product;
  }

  @override
  Future<void> saveProduct(Product product) async {
    await api.saveProduct(product);
    await cache.saveProduct(product);
    await db.saveProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) async {
    await api.deleteProduct(id);
    await cache.deleteProduct(id);
    await db.deleteProduct(id);
  }
}
```

### Repository with Error Handling

```dart
// Result type for error handling
sealed class Result<T> {}
class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}
class Failure<T> extends Result<T> {
  final AppException exception;
  Failure(this.exception);
}

// Repository with Result type
abstract class OrderRepository {
  Future<Result<List<Order>>> getOrders();
  Future<Result<Order>> createOrder(CreateOrderRequest request);
}

class OrderRepositoryImpl implements OrderRepository {
  final OrderApiService api;

  OrderRepositoryImpl(this.api);

  @override
  Future<Result<List<Order>>> getOrders() async {
    try {
      final orders = await api.fetchOrders();
      return Success(orders);
    } on NetworkException catch (e) {
      return Failure(AppException.network(e.message));
    } on ServerException catch (e) {
      return Failure(AppException.server(e.message));
    } catch (e) {
      return Failure(AppException.unknown(e.toString()));
    }
  }

  @override
  Future<Result<Order>> createOrder(CreateOrderRequest request) async {
    try {
      final order = await api.createOrder(request);
      return Success(order);
    } on ValidationException catch (e) {
      return Failure(AppException.validation(e.errors));
    } catch (e) {
      return Failure(AppException.unknown(e.toString()));
    }
  }
}
```

---

## Service Layer

Encapsulates complex business operations.

```dart
// Service for complex operations
class CheckoutService {
  final CartRepository cartRepository;
  final OrderRepository orderRepository;
  final PaymentService paymentService;
  final InventoryService inventoryService;
  final NotificationService notificationService;

  CheckoutService({
    required this.cartRepository,
    required this.orderRepository,
    required this.paymentService,
    required this.inventoryService,
    required this.notificationService,
  });

  Future<Order> checkout(String userId, PaymentMethod paymentMethod) async {
    // 1. Get cart
    final cart = await cartRepository.getCart(userId);
    if (cart.isEmpty) {
      throw EmptyCartException();
    }

    // 2. Validate inventory
    for (final item in cart.items) {
      final available = await inventoryService.checkAvailability(
        item.productId,
        item.quantity,
      );
      if (!available) {
        throw InsufficientInventoryException(item.productId);
      }
    }

    // 3. Process payment
    final paymentResult = await paymentService.processPayment(
      amount: cart.total,
      method: paymentMethod,
    );
    if (!paymentResult.success) {
      throw PaymentFailedException(paymentResult.error);
    }

    // 4. Create order
    final order = await orderRepository.createOrder(
      CreateOrderRequest(
        userId: userId,
        items: cart.items,
        paymentId: paymentResult.id,
      ),
    );

    // 5. Update inventory
    for (final item in cart.items) {
      await inventoryService.decreaseStock(item.productId, item.quantity);
    }

    // 6. Clear cart
    await cartRepository.clearCart(userId);

    // 7. Send notification
    await notificationService.sendOrderConfirmation(order);

    return order;
  }
}
```

### API Service Pattern

```dart
class ApiService {
  final Dio _dio;
  final AuthTokenProvider _tokenProvider;

  ApiService({
    required String baseUrl,
    required AuthTokenProvider tokenProvider,
  })  : _tokenProvider = tokenProvider,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenProvider.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _tokenProvider.clearToken();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return fromJson(response.data);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic) fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    return fromJson(response.data);
  }
}
```

---

## Folder Structure

### Feature-Based Organization

Organize by features for larger apps.

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── screens/
│   │       └── widgets/
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── services/
└── main.dart
```

### Layer-Based Organization

Simpler structure for smaller apps.

```
lib/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   ├── screens/
│   │   ├── auth/
│   │   ├── home/
│   │   └── profile/
│   └── widgets/
├── core/
│   ├── constants.dart
│   ├── theme.dart
│   └── utils.dart
└── main.dart
```

---

## Dependency Injection

### GetIt Setup

```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => SharedPreferences.getInstance());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Data Sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));

  // Blocs
  sl.registerFactory(
    () => UserBloc(
      getUser: sl(),
      updateUser: sl(),
    ),
  );
}

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

// Usage in widgets
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserBloc>()..add(LoadUser(userId)),
      child: const UserView(),
    );
  }
}
```

### Provider Setup

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: Config.apiUrl),
        ),

        // Repositories
        ProxyProvider<ApiService, UserRepository>(
          update: (_, api, __) => UserRepositoryImpl(api),
        ),

        // State Management
        ChangeNotifierProxyProvider<UserRepository, UserNotifier>(
          create: (_) => UserNotifier(),
          update: (_, repo, notifier) => notifier!..repository = repo,
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Summary

| Pattern | Use Case |
|---------|----------|
| **Clean Architecture** | Large apps requiring strict separation |
| **Repository Pattern** | Abstract data source access |
| **Service Layer** | Complex business operations |
| **Feature-based Folders** | Large apps with distinct features |
| **Layer-based Folders** | Smaller apps or prototypes |
| **Dependency Injection** | Managing object creation and lifecycles |

## Architecture Decision Checklist

- [ ] Clear separation between UI and business logic
- [ ] Data layer abstracted behind repositories
- [ ] Dependencies injected, not created inline
- [ ] Each layer only knows about adjacent layers
- [ ] Business logic is testable in isolation
- [ ] Navigation logic separate from widgets

## References

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://fluttersamples.com/)
- [GetIt Package](https://pub.dev/packages/get_it)
- [Injectable Package](https://pub.dev/packages/injectable)
