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

/// Food category chip (home horizontal list).
class HomeCategory {
  const HomeCategory({
    required this.id,
    required this.label,
    required this.emoji,
  });

  final String id;
  final String label;
  final String emoji;
}

/// Shop row for "Near me" (replace with Firestore + geolocation later).
class HomeNearShop {
  const HomeNearShop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.distanceKm,
    required this.rating,
    this.reviewCount = 0,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double distanceKm;
  final double rating;
  final int reviewCount;
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
  static const List<HomeCategory> categories = [
    HomeCategory(id: 'burger', label: 'Burger', emoji: '🍔'),
    HomeCategory(id: 'pizza', label: 'Pizza', emoji: '🍕'),
    HomeCategory(id: 'meat', label: 'Meat', emoji: '🥩'),
    HomeCategory(id: 'asian', label: 'Asian', emoji: '🍜'),
    HomeCategory(id: 'drinks', label: 'Drinks', emoji: '🥤'),
  ];

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

  static const List<HomeNearShop> nearMeShops = [
    HomeNearShop(
      id: '1',
      name: 'Spice Route Kitchen',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&q=80',
      distanceKm: 0.8,
      rating: 4.7,
      reviewCount: 214,
    ),
    HomeNearShop(
      id: '2',
      name: 'Urban Bites Café',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&q=80',
      distanceKm: 1.2,
      rating: 4.5,
      reviewCount: 98,
    ),
    HomeNearShop(
      id: '3',
      name: 'Coastal Grill',
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      distanceKm: 2.0,
      rating: 4.8,
      reviewCount: 412,
    ),
    HomeNearShop(
      id: '4',
      name: 'Noodle House',
      imageUrl:
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&q=80',
      distanceKm: 2.4,
      rating: 4.3,
      reviewCount: 156,
    ),
    HomeNearShop(
      id: '5',
      name: 'Garden Table',
      imageUrl:
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600&q=80',
      distanceKm: 3.1,
      rating: 4.6,
      reviewCount: 89,
    ),
  ];
}
