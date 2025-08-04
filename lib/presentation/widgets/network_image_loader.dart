
// Custom Network Image Widget with Loading and Error Handling
import 'package:flutter/material.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? radius;
  final Color? backgroundColor;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWithLoader({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius,
    this.backgroundColor,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingWidget(loadingProgress);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );

    if (radius != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildLoadingWidget(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD62A23)),
            ),
            SizedBox(height: 4),
            Flexible(
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey[400],
              size: 20,
            ),
            SizedBox(height: 2),
            Flexible(
              child: Text(
                'Failed to load',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.grey[400],
          size: 20,
        ),
      ),
    );
  }
}
