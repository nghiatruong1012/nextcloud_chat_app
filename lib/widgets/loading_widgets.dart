import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget ListLoading() {
  return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: Colors.grey.shade300,
                  width: 40,
                  height: 40,
                ),
              ),
              title: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
              subtitle: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
            ),
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: Colors.grey.shade300,
                  width: 40,
                  height: 40,
                ),
              ),
              title: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
              subtitle: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
            ),
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: Colors.grey.shade300,
                  width: 40,
                  height: 40,
                ),
              ),
              title: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
              subtitle: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
            ),
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: Colors.grey.shade300,
                  width: 40,
                  height: 40,
                ),
              ),
              title: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
              subtitle: Container(
                color: Colors.grey.shade300,
                width: double.maxFinite,
                height: 10,
              ),
            )
          ],
        ),
      ));
}
