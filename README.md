
# Bosta iOS Task

This project is an iOS app built as part of the **Bosta iOS Task** assignment.  
It demonstrates clean architecture with **MVVM**, **Combine**, **UIKit**, and **Moya**, along with network requests, search functionality, and navigation.

---

##  Features
- **Profile Screen**
  - Displays a random user’s **name** and **address**.
  - Lists all albums belonging to that user.
  - Tapping on an album navigates to its details.

- **Album Details Screen**
  - Displays album photos in an **Instagram-like grid**.
  - Supports a **search bar** to filter photos by title in real-time.
  - Tapping a photo opens it in a **full-screen viewer** with zoom & share.

- **Error Handling**
  - Network/API errors show a user-friendly **alert with Retry option**.
  - Prevents silent failures.
 
- **Skeleton Loading**
  - While content is loading, **SkeletonView** placeholders are displayed instead of empty white screens, improving UX.

- **Bonus**
  - Photo viewer allows zoom and iOS share sheet.

-------------------
## warning ##
--------------------
*** URLs of photos (https://via.placeholder.com/...), Unfortunately, do not load in some regions (including Egypt and parts of the Middle East).
That’s why when you run the project, you may only see system placeholders instead of real images. ***


## Tech Stack
- **Language**: Swift 5.5
- **IDE**: Xcode 13.1
- **Minimum iOS**: iOS 13
- **Architecture**: MVVM
- **Dependencies**:
  - [Moya](https://github.com/Moya/Moya) – networking abstraction
  - [CombineMoya](https://github.com/Moya/Moya) – Combine publishers for Moya
  - [SDWebImage](https://github.com/SDWebImage/SDWebImage) – async image loading & caching
  - [SkeletonView](https://github.com/Juanpe/SkeletonView) – skeleton loading animations

All dependencies are integrated using **Swift Package Manager**.

---

