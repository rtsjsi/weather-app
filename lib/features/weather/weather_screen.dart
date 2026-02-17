import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/forecast_model.dart';
import '../../models/weather_model.dart';
import 'providers/weather_provider.dart';
import 'widgets/weather_icon.dart';
import '../search/search_screen.dart';

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
      appBar: AppBar(
        title: const Text('Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<WeatherProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return const _LoadingView();
          }
          if (provider.hasError && !provider.hasData) {
            return _ErrorView(
              message: provider.errorMessage ?? 'Something went wrong',
              onRetry: () => provider.loadWeatherForCurrentLocation(),
            );
          }
          if (provider.hasData) {
            return RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CurrentWeatherCard(weather: provider.weather!),
                    const SizedBox(height: 24),
                    _ForecastSection(forecast: provider.forecast),
                  ],
                ),
              ),
            );
          }
          return _InitialView(
            onGetStarted: () => provider.loadWeatherForCurrentLocation(),
          );
        },
      ),
    );
  }

  void _openSearch(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    // Weather is loaded in SearchScreen when user selects a location
  }
}

class _InitialView extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _InitialView({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🌤️',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Get weather for your location',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Allow location access or search for a city',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.my_location),
              label: const Text('Use my location'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading weather...'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const _CurrentWeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final locationName = weather.cityName.isNotEmpty
        ? '${weather.cityName}${weather.countryCode.isNotEmpty ? ', ${weather.countryCode}' : ''}'
        : 'Current location';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              locationName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              weatherIconFromCode(weather.iconCode),
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 8),
            Text(
              '${weather.temperature.round()}°',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              weather.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DetailChip(
                  icon: Icons.thermostat,
                  label: 'Feels like ${weather.feelsLike.round()}°',
                ),
                _DetailChip(
                  icon: Icons.water_drop,
                  label: '${weather.humidity}%',
                ),
                _DetailChip(
                  icon: Icons.air,
                  label: '${weather.windSpeed.round()} m/s',
                ),
              ],
            ),
          ],
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
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
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
        Text(
          '5-Day Forecast',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...forecast.map((f) => _ForecastTile(forecast: f)),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          weatherIconFromCode(forecast.iconCode),
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(dayName),
        subtitle: Text(forecast.description),
        trailing: Text(
          '${forecast.tempMin.round()}° / ${forecast.tempMax.round()}°',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
