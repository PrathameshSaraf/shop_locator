import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/shop/shop_bloc.dart';
import '../blocs/shop/shop_event.dart';
import '../blocs/shop/shop_state.dart';
import '../models/shop_model.dart';
import '../widgets/shop_details_bottom_sheet.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double lng;

  const MapScreen({super.key, required this.lat, required this.lng});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  Map<String, BitmapDescriptor> _markerIcons = {};

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
    context.read<ShopBloc>().add(FetchShops(widget.lat, widget.lng));
  }

  Future<void> _loadMarkerIcons() async {
    final categories = [
      'store',
      'food',
      'health',
      'clothing',
      'electronics',
      'automotive',
      'services',
    ];
    for (final category in categories) {
      final iconData = _getCategoryIconData(category);
      final bitmap = await _createMarkerBitmap(iconData);
      _markerIcons[category] = bitmap;
    }
    // Default icon
    _markerIcons['default'] = await _createMarkerBitmap(Icons.place);

    if (!mounted) return;

    final state = context.read<ShopBloc>().state;
    if (state is ShopLoaded) {
      _updateMarkers(state.filteredShops);
    } else {
      setState(() {});
    }
  }

  Future<BitmapDescriptor> _createMarkerBitmap(IconData iconData) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final iconStr = String.fromCharCode(iconData.codePoint);

    textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 100.0,
        fontFamily: iconData.fontFamily,
        color: const Color(0xFF0047AB),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(100, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  IconData _getCategoryIconData(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'health':
        return Icons.local_hospital;
      case 'clothing':
        return Icons.checkroom;
      case 'electronics':
        return Icons.devices;
      case 'automotive':
        return Icons.directions_car;
      case 'services':
        return Icons.cleaning_services;
      case 'store':
        return Icons.store;
      default:
        return Icons.place;
    }
  }

  void _updateMarkers(List<Shop> shops) {
    setState(() {
      _markers = shops.map((shop) {
        final category = shop.category;
        final icon =
            _markerIcons[category] ??
            _markerIcons['default'] ??
            BitmapDescriptor.defaultMarker;

        return Marker(
          markerId: MarkerId(shop.id),
          position: LatLng(shop.lat, shop.lng),
          icon: icon,
          infoWindow: InfoWindow(title: shop.name),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              
              backgroundColor: Colors.transparent,
              builder: (context) => ShopDetailsBottomSheet(shop: shop),
            );
          },
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocListener<ShopBloc, ShopState>(
            listener: (context, state) {
              if (state is ShopLoaded) {
                _updateMarkers(state.filteredShops);
              } else if (state is ShopError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.lat, widget.lng),
                zoom: 14.4746,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(widget.lat, widget.lng),
                zoom: 14.4746,
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF0047AB),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<ShopBloc>().add(SearchShops(value));
        },
        decoration: InputDecoration(
          hintText: 'Search shops...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0047AB)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ShopBloc>().add(const SearchShops(''));
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = [
      'All',
      'Store',
      'Food',
      'Health',
      'Clothing',
      'Electronics',
      'Automotive',
      'Services',
    ];

    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        String activeFilter = 'All';
        if (state is ShopLoaded && state.activeFilter != null) {
          final current = state.activeFilter!;
          // Capitalize first letter for display matching
          activeFilter = current[0].toUpperCase() + current.substring(1);
          // Handle edge cases if needed, but simple capitalization should work for our set
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = activeFilter == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  avatar: category == 'All'
                      ? null
                      : Icon(
                          _getCategoryIconData(category),
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF0047AB),
                        ),
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<ShopBloc>().add(
                        FilterShops(category.toLowerCase()),
                      );
                    } else {
                      context.read<ShopBloc>().add(const FilterShops('all'));
                    }
                  },
                  selectedColor: const Color(0xFF0047AB),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
