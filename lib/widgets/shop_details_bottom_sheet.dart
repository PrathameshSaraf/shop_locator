import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/shop_model.dart';

class ShopDetailsBottomSheet extends StatelessWidget {
  final Shop shop;

  const ShopDetailsBottomSheet({super.key, required this.shop});

  Future<void> _launchMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${shop.lat},${shop.lng}',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      //  height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Name and Rating
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0047AB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Color(0xFF0047AB),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (shop.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${shop.rating} (${shop.userRatingsTotal ?? 0})',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (shop.openNow != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: shop.openNow!
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shop.openNow! ? 'Open' : 'Closed',
                      style: TextStyle(
                        color: shop.openNow! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildInfoRow(
              Icons.phone,
              'Mobile',
              shop.phoneNumber ?? 'Not Available',
              isLink: shop.phoneNumber != null,
              onTap: shop.phoneNumber != null
                  ? () => launchUrl(Uri.parse('tel:${shop.phoneNumber}'))
                  : null,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, 'Address', shop.address),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Hours',
              shop.openNow != null
                  ? (shop.openNow! ? 'Open Now' : 'Closed')
                  : 'Hours not available',
            ),

            const SizedBox(height: 24),

            // Services
            if (shop.types.isNotEmpty) ...[
              const Text(
                'Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: shop.types.map((type) {
                  return Chip(
                    label: Text(
                      type.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: Colors.grey[100],
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Photos
            if (shop.photoRefs.isNotEmpty) ...[
              const Text(
                'Photos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shop.photoRefs.length,
                  itemBuilder: (context, index) {
                    final photoUrl =
                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${shop.photoRefs[index]}&key=AIzaSyCmgUnE0Iq7janf4NCyBaGLlpQ5KRonysA';
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Navigate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchMaps,
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0047AB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLink ? const Color(0xFF0047AB) : Colors.black87,
                    fontWeight: isLink ? FontWeight.bold : FontWeight.normal,
                    decoration: isLink
                        ? TextDecoration.underline
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
