import 'package:flutter/material.dart';
import 'package:vocabsimple/src/components/widgets/FunCard.dart';
import 'package:vocabsimple/src/components/homepage/vocabulary/voca_main.dart';

class FunctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60.0, right: 25.0, left: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Logo + Tên app + Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset("assets/images/LogoApp.png", width: 60, height: 60),
                  const SizedBox(width: 10),
                  Text("Vocabsimple",
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/images/avatar.png"),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text('Trang chủ',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),

          const SizedBox(height: 15),
          // Search bar + Notification
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Tìm kiếm',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Stack(
                children: [
                  const Icon(Icons.notifications_none, size: 27),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle),
                      child: const Text("2",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  )
                ],
              )
            ],
          ),

          const SizedBox(height: 40),

          // List of function (ví dụ: nút học từ vựng)
          FunCard(
            image: 'assets/images/vocabulary.png',
            title: 'Học từ vựng',
            subtitle: 'Theo chủ đề',
            color: Colors.blue.shade400,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VocaMainPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
