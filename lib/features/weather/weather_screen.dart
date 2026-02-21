import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/decorative_background.dart';
import '../../core/widgets/weather_stat_chip.dart';
import '../../models/forecast_model.dart';
import '../../models/weather_model.dart';
import '../search/search_screen.dart';
import 'providers/weather_provider.dart';
import 'widgets/weather_icon.dart';
import 'widgets/weather_mood.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadWeatherForCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          final mood = provider.hasData
              ? weatherMoodFromCode(provider.weather!.iconCode)
              : WeatherMood.partlyCloudy;
          final brightness = Theme.of(context).brightness;
          final gradientColors = gradientColorsForMood(mood, brightness);

          return Stack(
            children: [
              Positioned.fill(
                child: DecorativeBackground(gradientColors: gradientColors),
              ),
              SafeArea(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildAppBar(context),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _buildBody(context, provider),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text(
        AppConfig.appName,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
          fontSize: 22,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
          onPressed: () => _openSearch(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 26),
          onPressed: () => context.read<WeatherProvider>().refresh(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WeatherProvider provider) {
    if (provider.isLoading && !provider.hasData) {
      return const _LoadingView(key: ValueKey('loading'));
    }
    if (provider.hasError && !provider.hasData) {
      return _ErrorView(
        key: const ValueKey('error'),
        message: provider.errorMessage ?? 'Something went wrong',
        onRetry: () => provider.loadWeatherForCurrentLocation(),
      );
    }
    if (provider.hasData) {
      return RefreshIndicator(
        onRefresh: () => provider.refresh(),
        color: Colors.white,
        backgroundColor: Colors.black26,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            key: const ValueKey('content'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(weather: provider.weather!),
              const SizedBox(height: 24),
              _StatsRow(weather: provider.weather!),
              const SizedBox(height: 32),
              _ForecastSection(forecast: provider.forecast),
            ],
          ),
        ),
      );
    }
    return _InitialView(
      key: const ValueKey('initial'),
      onGetStarted: () => provider.loadWeatherForCurrentLocation(),
    );
  }

  Future<void> _openSearch(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }
}

class _InitialView extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _InitialView({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: Text('☀️', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your weather,\nanywhere',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enable location or search for a city',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.my_location_rounded, size: 22),
              label: const Text('Use my location'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.9)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading weather…',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: 48, color: Colors.white.withOpacity(0.95)),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _looksLikeCoordinates(String s) {
  if (s.isEmpty) return true;
  return RegExp(r'^-?\d{1,3}\.?\d*\,\s*-?\d{1,3}\.?\d*$').hasMatch(s.trim());
}

class _HeroSection extends StatelessWidget {
  final WeatherModel weather;

  const _HeroSection({required this.weather});

  @override
  Widget build(BuildContext context) {
    String locationName = weather.cityName.isNotEmpty
        ? '${weather.cityName}${weather.countryCode.isNotEmpty ? ', ${weather.countryCode}' : ''}'
        : '';
    if (locationName.isEmpty || _looksLikeCoordinates(locationName)) {
      locationName = 'Your location';
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 24 * (1 - value)), child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: Colors.white.withOpacity(0.95)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          locationName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Text(weatherIconFromCode(weather.iconCode), style: const TextStyle(fontSize: 88)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weather.temperature.round()}°',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        letterSpacing: -3,
                        fontSize: 64,
                      ),
                ),
                Text(
                  weather.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WeatherModel weather;

  const _StatsRow({required this.weather});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 12 * (1 - value)), child: child),
      ),
      child: Row(
        children: [
          Expanded(
            child: WeatherStatChip(
              icon: Icons.thermostat_rounded,
              label: '${weather.feelsLike.round()}°',
              iconColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: WeatherStatChip(
              icon: Icons.water_drop_rounded,
              label: '${weather.humidity}%',
              iconColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: WeatherStatChip(
              icon: Icons.air_rounded,
              label: '${weather.windSpeed.round()} m/s',
              iconColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastSection extends StatelessWidget {
  final List<ForecastModel> forecast;

  const _ForecastSection({required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            '5-Day Forecast',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
          ),
        ),
        ...List.generate(forecast.length, (i) {
          return TweenAnimationBuilder<double>(
            key: ValueKey(forecast[i].date.toIso8601String()),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 350 + (i * 60)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 14 * (1 - value)), child: child),
            ),
            child: _ForecastCard(forecast: forecast[i]),
          );
        }),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final ForecastModel forecast;

  const _ForecastCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final dayName = _formatDay(forecast.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Row(
              children: [
                Text(weatherIconFromCode(forecast.iconCode), style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        forecast.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${forecast.tempMin.round()}° / ${forecast.tempMax.round()}°',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
