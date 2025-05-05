import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselImage extends StatefulWidget {
  const CarouselImage({Key? key}) : super(key: key);

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int activeIndex = 0; // Chỉ mục ảnh đang hiển thị

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thêm tiêu đề cho Carousel
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),

        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              items: GlobalVariables.carouselImages.map((imagePath) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12), // Bo góc ảnh
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            )
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              height: 220,
                              width: double.infinity,
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Ảnh ${activeIndex + 1}/${GlobalVariables.carouselImages.length}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              options: CarouselOptions(
                viewportFraction: 0.95, // Giảm bớt khoảng trống hai bên
                height: 220,
                autoPlay: true, // Tự động cuộn ảnh
                autoPlayInterval: Duration(seconds: 4),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                enlargeCenterPage: true, // Làm ảnh trung tâm lớn hơn
                onPageChanged: (index, reason) {
                  setState(() {
                    activeIndex = index;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 12,
              child: AnimatedSmoothIndicator(
                activeIndex: activeIndex,
                count: GlobalVariables.carouselImages.length,
                effect: const ExpandingDotsEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  activeDotColor: Colors.blueAccent,
                  dotColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
