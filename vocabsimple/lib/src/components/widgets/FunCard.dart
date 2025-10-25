import 'package:flutter/material.dart';

class FunCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const FunCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 230,
        height: 320,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: onTap,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 45),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 21, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
