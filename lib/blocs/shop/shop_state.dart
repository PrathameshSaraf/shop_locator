import 'package:equatable/equatable.dart';
import '../../models/shop_model.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<Shop> allShops;
  final List<Shop> filteredShops;
  final String? activeFilter;

  const ShopLoaded({
    required this.allShops,
    required this.filteredShops,
    this.activeFilter,
  });

  @override
  List<Object> get props => [allShops, filteredShops, activeFilter ?? ''];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object> get props => [message];
}
