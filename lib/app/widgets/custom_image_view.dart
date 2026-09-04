import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/utils/size_utils.dart';
import '../theme/theme_helper.dart';

/// One image widget for every source the app uses — network, SVG, local file,
/// and bundled asset — so screens never branch on where an image comes from.
///
/// Network images are cached, which matters for users on metered connections.
class CustomImageView extends StatelessWidget {
  const CustomImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder = 'assets/images/img_placeholder.png',
  });

  final String? imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final String placeHolder;

  @override
  Widget build(BuildContext context) {
    final image = _buildCircleImage();
    return alignment != null
        ? Align(alignment: alignment!, child: image)
        : image;
  }

  Widget _buildCircleImage() {
    if (radius == null) return _buildImageWithBorder();
    return ClipRRect(borderRadius: radius!, child: _buildImageWithBorder());
  }

  Widget _buildImageWithBorder() {
    if (border == null) return _buildImageView();
    return Container(
      decoration: BoxDecoration(border: border, borderRadius: radius),
      child: _buildImageView(),
    );
  }

  Widget _buildImageView() {
    final path = imagePath;
    if (path == null || path.isEmpty) return _fallback();

    Widget child;
    switch (_sourceOf(path)) {
      case _ImageSource.svg:
        child = SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            path,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color == null
                ? null
                : ColorFilter.mode(color!, BlendMode.srcIn),
          ),
        );
      case _ImageSource.file:
        child = Image.file(
          File(path),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (_, _, _) => _fallback(),
        );
      case _ImageSource.network:
        child = CachedNetworkImage(
          imageUrl: path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          placeholder: (_, _) => _shimmerBox(),
          errorWidget: (_, _, _) => _fallback(),
        );
      case _ImageSource.asset:
        child = Image.asset(
          path,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
          errorBuilder: (_, _, _) => _fallback(),
        );
    }

    final padded = margin == null ? child : Padding(padding: margin!, child: child);
    return onTap == null
        ? padded
        : GestureDetector(onTap: onTap, child: padded);
  }

  Widget _shimmerBox() => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: appTheme.surfaceAlt,
          borderRadius: radius ?? BorderRadius.circular(8.h),
        ),
      );

  /// Shown when a path is empty, malformed, or fails to load. Never throws,
  /// so a bad image URL cannot take a screen down.
  Widget _fallback() => _shimmerBox();

  _ImageSource _sourceOf(String path) {
    if (path.endsWith('.svg')) return _ImageSource.svg;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return _ImageSource.network;
    }
    if (path.startsWith('file://') || path.startsWith('/')) {
      return _ImageSource.file;
    }
    return _ImageSource.asset;
  }
}

enum _ImageSource { svg, file, network, asset }
