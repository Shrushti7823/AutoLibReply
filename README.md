# 📚 AutoLibReply

The **Library Management System with Auto SMS** is a Flutter-based application designed to efficiently manage library operations. It provides separate dashboards for **Admin** and **Students**, enabling smooth book management, user interaction, and notifications.

This system reduces manual effort and improves communication by automating tasks like book issuing, returning, and tracking.

---

## Objectives
- Automate library management tasks  
- Provide role-based access (Admin & Student)  
- Manage books and users efficiently  
- Improve communication using notification system  

---

## Features

### Student Module
- View available books  
- Search books  
- Issue books  
- Return books  
- View issued books  

---

### Admin Module
- Add / Update / Delete books  
- Manage student records  
- View all issued books  
- Monitor system activity  

---

## Tech Stack

**Frontend:**
- Flutter (Dart)

**Backend:**
- Firebase Authentication  
- Cloud Firestore  

**Tools & IDE:**
- Android Studio  
- VS Code  
- Git & GitHub  

**Platforms:**
- Android  
- Web  

---

## Project Structure


lib/
│── main.dart

├── screens/
│ ├── login_page.dart
│ ├── home_page.dart
│ ├── admin_home.dart
│ ├── book_list.dart
│ ├── issue_book.dart

├── widgets/
│ ├── custom_button.dart
│ ├── drawer_menu.dart

├── services/
│ ├── auth_service.dart
│ ├── firestore_service.dart

├── models/
│ ├── user_model.dart
│ ├── book_model.dart

assets/
│── images/
│── icons/

android/
web/


---

## Installation & Setup

### 🔹 Clone Repository

git clone https://github.com/Shrushti7823/AutoLibReply.git


### 🔹 Navigate to Project

cd AutoLibReply


### 🔹 Install Dependencies

flutter pub get


### 🔹 Run Project

flutter run


---

## Firebase Setup

1. Go to Firebase Console  
2. Create a new project  
3. Enable:
   - Authentication  
   - Firestore Database  
4. Add Firebase configuration (`firebase_options.dart`)  
5. Connect Firebase to Flutter  


---

## Screenshots
- Login Page  
- Student Dashboard  
- Admin Dashboard  
- Book Management  

---

## Future Enhancements
- Role-based authentication using Firebase  
- Real SMS integration (Twilio API)  
- Fine calculation system  
- UI/UX improvements  
- Multi-language support  

---

## 👩‍💻 Author
**Shrushti Handge**

---
