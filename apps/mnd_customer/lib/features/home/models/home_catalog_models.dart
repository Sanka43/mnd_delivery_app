import 'package:flutter/material.dart';

/// App service entry (home top strip; replace with config / Firestore later).
enum HomeServiceId { rides, food, market, delivery }

class HomeService {
  const HomeService({
    required this.id,
    required this.label,
    required this.icon,
  });

  final HomeServiceId id;
  final String label;
  final IconData icon;
}

/// Mock product for best sellers (replace with Firestore later).
class HomeProduct {
  const HomeProduct({
    required this.name,
    required this.priceLabel,
    required this.imageUrl,
    required this.caloriesLabel,
    required this.prepTimeLabel,
  });

  final String name;
  final String priceLabel;
  final String imageUrl;
  final String caloriesLabel;
  final String prepTimeLabel;
}

/// Demo catalog — UI only.
abstract final class HomeMockCatalog {
  static const List<HomeService> services = [
    HomeService(
      id: HomeServiceId.rides,
      label: 'Rides',
      icon: Icons.local_taxi_rounded,
    ),
    HomeService(
      id: HomeServiceId.food,
      label: 'Food',
      icon: Icons.restaurant_rounded,
    ),
    HomeService(
      id: HomeServiceId.market,
      label: 'Market',
      icon: Icons.storefront_rounded,
    ),
    HomeService(
      id: HomeServiceId.delivery,
      label: 'Delivery',
      icon: Icons.local_shipping_rounded,
    ),
  ];

  static const List<HomeProduct> bestSellers = [
    HomeProduct(
      name: 'Melting Cheese Pizza',
      priceLabel: 'Rs 3,490',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&q=80',
      caloriesLabel: '44 Cal',
      prepTimeLabel: '20 min',
    ),
    HomeProduct(
      name: 'Cheese burger',
      priceLabel: 'Rs 1,290',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&q=80',
      caloriesLabel: '52 Cal',
      prepTimeLabel: '15 min',
    ),
    HomeProduct(
      name: 'Grilled Salmon',
      priceLabel: 'Rs 2,450',
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600&q=80',
      caloriesLabel: '38 Cal',
      prepTimeLabel: '25 min',
    ),
    HomeProduct(
      name: 'Fresh Sushi Set',
      priceLabel: 'Rs 3,100',
      imageUrl:
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=600&q=80',
      caloriesLabel: '41 Cal',
      prepTimeLabel: '18 min',
    ),
  ];
}
