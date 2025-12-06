import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double lat;
  final double lng;

  const LocationLoaded(this.lat, this.lng);

  @override
  List<Object> get props => [lat, lng];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object> get props => [message];
}

class LocationPermissionDenied extends LocationState {}

class LocationPermissionDeniedForever extends LocationState {}
