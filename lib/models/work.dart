import 'package:flutter/material.dart';

class Work {
  final String id;
  final String title;
  final String author; 
  final String category; 
  
  final Color baseColor;    
  final Color patternColor; 
  final Color spineColor;   
  
  final int completedSets;
  final String studyTime;
  final String difficulty; 

  Work({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.baseColor,
    required this.patternColor,
    required this.spineColor,
    this.completedSets = 0,
    this.studyTime = '5분',
    this.difficulty = '중',
  });
}