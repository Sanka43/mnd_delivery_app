import 'package:flutter/foundation.dart';

/// Shop shown in the Shop tab list (replace with API / Firestore later).
@immutable
class ShopListing {
  const ShopListing({
    required this.id,
    required this.name,
    required this.tagline,
    required this.imageUrl,
    required this.rating,
    required this.eta,
  });

  final String id;
  final String name;
  final String tagline;
  final String imageUrl;
  final String rating;
  final String eta;
}

/// A line on a shop’s menu.
@immutable
class ShopMenuItem {
  const ShopMenuItem({
    required this.name,
    required this.priceLabel,
    required this.imageUrl,
    this.detail,
  });

  final String name;
  final String priceLabel;
  final String imageUrl;
  final String? detail;
}

/// Demo shops + per-shop menus — UI only.
abstract final class ShopMockCatalog {
  static const List<ShopListing> shops = [
    ShopListing(
      id: 'freshmart',
      name: 'FreshMart Colombo',
      tagline: 'Groceries · Fresh produce · Daily essentials',
      rating: '4.8',
      eta: '22–35 min',
      imageUrl:
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80',
    ),
    ShopListing(
      id: 'city_pharmacy',
      name: 'City Pharmacy',
      tagline: 'Health · Wellness · Personal care',
      rating: '4.7',
      eta: '18–30 min',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&q=80',
    ),
    ShopListing(
      id: 'daily_needs',
      name: 'Daily Needs',
      tagline: 'Snacks · Home care · Utility picks',
      rating: '4.6',
      eta: '16–28 min',
      imageUrl:
          'https://images.unsplash.com/photo-1604719312566-de2e4a4d6b0b?w=600&q=80',
    ),
    ShopListing(
      id: 'green_basket',
      name: 'Green Basket',
      tagline: 'Organic greens · Fruits · Healthy pantry',
      rating: '4.9',
      eta: '20–32 min',
      imageUrl:
          'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=600&q=80',
    ),
  ];

  static List<ShopMenuItem> menuFor(String shopId) {
    switch (shopId) {
      case 'freshmart':
        return const [
          ShopMenuItem(
            name: 'Basmati Rice 5kg',
            priceLabel: 'Rs 2,890',
            imageUrl:
                'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&q=80',
            detail: 'Premium long-grain rice',
          ),
          ShopMenuItem(
            name: 'Fresh Milk 1L',
            priceLabel: 'Rs 420',
            imageUrl:
                'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=600&q=80',
            detail: 'Farm fresh, full cream',
          ),
          ShopMenuItem(
            name: 'Brown Eggs (10 Pack)',
            priceLabel: 'Rs 680',
            imageUrl:
                'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=600&q=80',
            detail: 'Protein-rich everyday eggs',
          ),
          ShopMenuItem(
            name: 'Mixed Vegetables 1kg',
            priceLabel: 'Rs 450',
            imageUrl:
                'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&q=80',
            detail: 'Seasonal fresh-cut mix',
          ),
        ];
      case 'city_pharmacy':
        return const [
          ShopMenuItem(
            name: 'Vitamin C (60 Tablets)',
            priceLabel: 'Rs 1,250',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&q=80',
            detail: 'Daily immune support',
          ),
          ShopMenuItem(
            name: 'Hand Sanitizer 500ml',
            priceLabel: 'Rs 590',
            imageUrl:
                'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=600&q=80',
            detail: 'Kills 99.9% germs',
          ),
          ShopMenuItem(
            name: 'Digital Thermometer',
            priceLabel: 'Rs 1,890',
            imageUrl:
                'https://images.unsplash.com/photo-1631549916766-749a846ff348?w=600&q=80',
            detail: 'Fast and accurate readings',
          ),
        ];
      case 'daily_needs':
        return const [
          ShopMenuItem(
            name: 'Chocolate Biscuits 200g',
            priceLabel: 'Rs 320',
            imageUrl:
                'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=600&q=80',
            detail: 'Crunchy tea-time treat',
          ),
          ShopMenuItem(
            name: 'Dishwashing Liquid 750ml',
            priceLabel: 'Rs 540',
            imageUrl:
                'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=600&q=80',
            detail: 'Lemon fresh grease-cut formula',
          ),
          ShopMenuItem(
            name: 'Paper Towels (6 Rolls)',
            priceLabel: 'Rs 890',
            imageUrl:
                'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600&q=80',
            detail: 'Soft and extra absorbent',
          ),
        ];
      case 'green_basket':
        return const [
          ShopMenuItem(
            name: 'Organic Spinach 250g',
            priceLabel: 'Rs 380',
            imageUrl:
                'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&q=80',
            detail: 'Pesticide-free leafy greens',
          ),
          ShopMenuItem(
            name: 'Avocado (Pack of 3)',
            priceLabel: 'Rs 920',
            imageUrl:
                'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&q=80',
            detail: 'Creamy, ripe and ready',
          ),
          ShopMenuItem(
            name: 'Cherry Tomatoes 500g',
            priceLabel: 'Rs 650',
            imageUrl:
                'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&q=80',
            detail: 'Sweet and juicy salad pick',
          ),
          ShopMenuItem(
            name: 'Cold-Pressed Coconut Oil 500ml',
            priceLabel: 'Rs 1,450',
            imageUrl:
                'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=600&q=80',
            detail: 'Pure, unrefined kitchen essential',
          ),
        ];
      default:
        return const [];
    }
  }
}
