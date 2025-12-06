import 'package:equatable/equatable.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object> get props => [];
}

class FetchShops extends ShopEvent {
  final double lat;
  final double lng;

  const FetchShops(this.lat, this.lng);

  @override
  List<Object> get props => [lat, lng];
}

class SearchShops extends ShopEvent {
  final String query;

  const SearchShops(this.query);

  @override
  List<Object> get props => [query];
}

class FilterShops extends ShopEvent {
  final String category;

  const FilterShops(this.category);

  @override
  List<Object> get props => [category];
}
