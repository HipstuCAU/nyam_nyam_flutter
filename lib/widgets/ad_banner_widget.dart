import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  static const testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _AdaptiveBanner(
        width: constraints.maxWidth.truncate(),
        orientation: MediaQuery.orientationOf(context),
        adUnitId: kReleaseMode
            ? dotenv.env['RELEASE_BANNER_AD_ID'] ?? ''
            : testAdUnitId,
      ),
    );
  }
}

class _AdaptiveBanner extends StatefulWidget {
  const _AdaptiveBanner({
    required this.width,
    required this.orientation,
    required this.adUnitId,
  });

  final int width;
  final Orientation orientation;
  final String adUnitId;

  @override
  State<_AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends State<_AdaptiveBanner> {
  BannerAd? _banner;
  bool _isLoaded = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _AdaptiveBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.width != oldWidget.width ||
        widget.orientation != oldWidget.orientation ||
        widget.adUnitId != oldWidget.adUnitId) {
      _load();
    }
  }

  void _disposeAfterFrame(Ad ad) {
    // Let AdWidget unmount before removing the native ad's registration.
    WidgetsBinding.instance.addPostFrameCallback((_) => ad.dispose());
  }

  Future<void> _load() async {
    final request = ++_request;
    final previous = _banner;
    _banner = null;
    _isLoaded = false;
    if (previous != null) _disposeAfterFrame(previous);
    if (widget.width <= 0 || widget.adUnitId.isEmpty) return;

    try {
      final size =
          await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
            widget.orientation,
            widget.width,
          );
      if (!mounted || request != _request || size == null) return;

      final banner = BannerAd(
        size: size,
        adUnitId: widget.adUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted || !identical(ad, _banner)) return;
            setState(() => _isLoaded = true);
            if (kDebugMode) {
              debugPrint('Banner loaded: ${size.width}x${size.height}');
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (!mounted || !identical(ad, _banner)) return;
            setState(() {
              _banner = null;
              _isLoaded = false;
            });
            _disposeAfterFrame(ad);
            if (kDebugMode) debugPrint('Banner load failed: ${error.code}');
          },
        ),
      );
      _banner = banner;
      await banner.load();
    } on PlatformException catch (error) {
      if (!mounted || request != _request) return;
      final failed = _banner;
      _banner = null;
      failed?.dispose();
      if (kDebugMode) debugPrint('Banner request failed: ${error.code}');
    }
  }

  @override
  void dispose() {
    _request++;
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (!_isLoaded || banner == null) return const SizedBox.shrink();
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(key: ObjectKey(banner), ad: banner),
    );
  }
}
