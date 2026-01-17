import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// Shimmer loading effect for various UI components
class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardDark,
      highlightColor: AppColors.surfaceDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Movie card shimmer loader
class MovieCardShimmer extends StatelessWidget {
  final double width;
  final double height;

  const MovieCardShimmer({
    super.key,
    this.width = 120,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoader(
          width: width,
          height: height,
          borderRadius: 8,
        ),
        const SizedBox(height: 8),
        ShimmerLoader(
          width: width * 0.8,
          height: 14,
          borderRadius: 4,
        ),
        const SizedBox(height: 4),
        ShimmerLoader(
          width: width * 0.5,
          height: 12,
          borderRadius: 4,
        ),
      ],
    );
  }
}

/// Category section shimmer loader
class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ShimmerLoader(
            width: 150,
            height: 24,
            borderRadius: 4,
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: const MovieCardShimmer(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Featured carousel shimmer loader
class FeaturedShimmer extends StatelessWidget {
  const FeaturedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoader(
      width: double.infinity,
      height: 400,
      borderRadius: 0,
    );
  }
}
