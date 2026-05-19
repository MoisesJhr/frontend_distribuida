import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  Timer? _timer;

  // Textos descriptivos para el carrusel
  final List<String> _descriptions = [
    'Organiza, clasifica y protege tus documentos con Inteligencia Artificial',
    'Optimiza tu flujo de trabajo con clasificaciones.',
    'Accede a tus archivos desde cualquier lugar',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPageIndex < _descriptions.length - 1) {
        _currentPageIndex++;
      } else {
        _currentPageIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPageIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Configuración de colores (estilo Vault.io)
  static const Color customDeepBlue = Color(0xFF030D64);
  static const Color brandColor = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        160,
        207,
        223,
      ), // Fondo azul claro para la parte superior
      body: SafeArea(
        bottom:
            false, // Permite que el contenedor blanco llegue al final de la pantalla
        child: Column(
          children: [
            // Ocupa el espacio superior disponible
            Expanded(flex: 3, child: _buildTopContent()),
            // Contenedor blanco con los botones
            _buildBottomActionCard(context),
          ],
        ),
      ),
    );
  }

  // --- Módulos de la Interfaz ---

  // Organiza la ilustración, título y carrusel
  Widget _buildTopContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          _buildHeroIllustration(),
          const SizedBox(height: 82),
          const Text(
            'Clasificador Inteligente',
            style: TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              color: customDeepBlue,
            ),
          ),
          const SizedBox(height: 16),
          _buildDescriptionCarousel(),
          const SizedBox(height: 16),
          _buildPageIndicator(),
          const Spacer(),
        ],
      ),
    );
  }

  // Placeholder para la ilustración central
  Widget _buildHeroIllustration() {
    return Center(
      child: SizedBox(
        height: 170,
        child: Image.asset('assets/images/folder.png', fit: BoxFit.contain),
      ),
    );
  }

  // Carrusel de texto con PageView
  Widget _buildDescriptionCarousel() {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _descriptions.length,
        onPageChanged: (index) => setState(() => _currentPageIndex = index),
        itemBuilder: (context, index) {
          return Text(
            _descriptions[index],
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 1, 1, 1),
              height: 1.5,
            ),
          );
        },
      ),
    );
  }

  // Indicador de puntos (dots) animado
  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(_descriptions.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPageIndex == index ? 12 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentPageIndex == index
                ? const Color.fromARGB(255, 7, 7, 7)
                : const Color.fromARGB(255, 140, 0, 247),
          ),
        );
      }),
    );
  }

  // Tarjeta blanca inferior con botones de acción
  Widget _buildBottomActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(45),
          topRight: Radius.circular(45),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón de Iniciar Sesión (Estilo bordeado)
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: brandColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: brandColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Iniciar sesión',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Botón de Registro (Estilo sólido)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Crear cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
