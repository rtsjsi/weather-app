import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_config.dart';
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

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors[0],
                  gradientColors[1],
                  gradientColors[0].withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    title: Text(
                      AppConfig.appName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search_rounded, color: Colors.white),
                        onPressed: () => _openSearch(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        onPressed: () =>
                            context.read<WeatherProvider>().refresh(),
                      ),
                    ],
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _buildBody(context, provider),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            key: const ValueKey('content'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CurrentWeatherCard(weather: provider.weather!),
              const SizedBox(height: 28),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    '☀️',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 80,
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Your weather, anywhere',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Allow location or search for a city to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Use my location'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading weather...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
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
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
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
  final trimmed = s.trim();
  final match = RegExp(r'^-?\d{1,3}\.?\d*\,\s*-?\d{1,3}\.?\d*$').hasMatch(trimmed);
  return match;
}

class _CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const _CurrentWeatherCard({required this.weather});

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
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        locationName,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Text(
                    weatherIconFromCode(weather.iconCode),
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${weather.temperature.round()}°',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                ),
                Text(
                  weather.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _DetailChip(
                      icon: Icons.thermostat_rounded,
                      label: 'Feels like ${weather.feelsLike.round()}°',
                    ),
                    _DetailChip(
                      icon: Icons.water_drop_rounded,
                      label: '${weather.humidity}%',
                    ),
                    _DetailChip(
                      icon: Icons.air_rounded,
                      label: '${weather.windSpeed.round()} m/s',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.white.withOpacity(0.95)),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
        ),
      ],
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
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '5-Day Forecast',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
          ),
        ),
        ...List.generate(forecast.length, (i) {
          return TweenAnimationBuilder<double>(
            key: ValueKey(forecast[i].date.toIso8601String()),
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (i * 80)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _ForecastTile(forecast: forecast[i]),
          );
        }),
      ],
    );
  }
}

class _ForecastTile extends StatelessWidget {
  final ForecastModel forecast;

  const _ForecastTile({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final dayName = _formatDay(forecast.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  weatherIconFromCode(forecast.iconCode),
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        forecast.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${forecast.tempMin.round()}° / ${forecast.tempMax.round()}°',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
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
