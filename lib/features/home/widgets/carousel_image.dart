import 'package:amazon_clone_tutorial/constants/global_variables.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselImage extends StatefulWidget {
  const CarouselImage({Key? key}) : super(key: key);

  @override
  State<CarouselImage> createState() => _CarouselImageState();
}

class _CarouselImageState extends State<CarouselImage> {
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          items: GlobalVariables.carouselImages.map(
            (i) {
              return Builder(
                builder: (BuildContext context) => Image.asset(
                  i,
                  fit: BoxFit.cover,
                  height: 200,
                ),
              );
            },
          ).toList(),
          options: CarouselOptions(
            viewportFraction: 1,
            height: 200,
            onPageChanged: (index, reason) {
              setState(() {
                activeIndex = index;
              });
            },
          ),
        ),
        Positioned(
          bottom: 8,
          child: AnimatedSmoothIndicator(
            activeIndex: activeIndex,
            count: GlobalVariables.carouselImages.length,
            effect: const WormEffect(
              dotWidth: 8,
              dotHeight: 8,
              activeDotColor: GlobalVariables.primaryColor,
              dotColor: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}
