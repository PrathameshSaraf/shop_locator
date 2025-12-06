import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitial()) {
    on<RequestLocationPermission>(_onRequestPermission);
    on<GetLocation>(_onGetLocation);
  }

  Future<void> _onRequestPermission(
    RequestLocationPermission event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(LocationPermissionDenied());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationPermissionDeniedForever());
        return;
      }

      // Permission granted, get location
      add(GetLocation());
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onGetLocation(
    GetLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      emit(LocationLoaded(position.latitude, position.longitude));
    } catch (e) {
      emit(LocationError("Failed to get location: $e"));
    }
  }
}
