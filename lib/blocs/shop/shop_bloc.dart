import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/shop_repository.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final ShopRepository shopRepository;

  ShopBloc({required this.shopRepository}) : super(ShopInitial()) {
    on<FetchShops>(_onFetchShops);
    on<SearchShops>(_onSearchShops);
    on<FilterShops>(_onFilterShops);
  }

  Future<void> _onFetchShops(FetchShops event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final shops = await shopRepository.fetchNearbyShops(event.lat, event.lng);
      emit(ShopLoaded(allShops: shops, filteredShops: shops));
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  void _onSearchShops(SearchShops event, Emitter<ShopState> emit) {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      final query = event.query.toLowerCase();
      final filtered = currentState.allShops.where((shop) {
        return shop.name.toLowerCase().contains(query);
      }).toList();
      emit(
        ShopLoaded(
          allShops: currentState.allShops,
          filteredShops: filtered,
          activeFilter: currentState.activeFilter,
        ),
      );
    }
  }

  void _onFilterShops(FilterShops event, Emitter<ShopState> emit) {
    if (state is ShopLoaded) {
      final currentState = state as ShopLoaded;
      final category = event.category.toLowerCase();

      if (category == 'all') {
        emit(
          ShopLoaded(
            allShops: currentState.allShops,
            filteredShops: currentState.allShops,
            activeFilter: null,
          ),
        );
        return;
      }

      final filtered = currentState.allShops.where((shop) {
        return shop.category == category;
      }).toList();

      emit(
        ShopLoaded(
          allShops: currentState.allShops,
          filteredShops: filtered,
          activeFilter: category,
        ),
      );
    }
  }
}
