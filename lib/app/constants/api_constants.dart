import 'package:managerapp/app/constants/image_constants.dart';

class ArgumentConstant {
  static const onBoarding = "onBoarding";
  static const imageAiModel = "imageAiModel";
  static const isFirstTime = "isFirstTime";
  static const isFirstTimeCount = "isFirstTimeCount";
  static const isFirstTimeWelcome = "isFirstTimeWelcome";
  static const id = "id";
  static const historyList = "historyList";
  static const style = "style";
  static const imageCount = "imageCount";
  static const monthlyImageCount = "monthlyImageCount";
  static const weeklyImageCount = "weeklyImageCount";
  static const topupImageCount = "topupImageCount";
  static const activeSubscriptionType = "activeSubscriptionType";
  static const appLabel = "appLabel";
}

List<Map<String, dynamic>> mainStyleList = [
  {
    "label": "Cool images just from text prompts",
    "thumbnailFullUrl": ImageConstant.style1,
  },
  {
    "label": "Cartoonize Avatar of your image",
    "thumbnailFullUrl": ImageConstant.style2,
  },
  {
    "label": "Hairstyle and Hair Color changer",
    "thumbnailFullUrl": ImageConstant.style3,
  },
];
