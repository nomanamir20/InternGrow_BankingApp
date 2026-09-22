importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyAxBz6LDaQKGhU9HyN1PHKRjFCbXcl6F8s",
  authDomain: "interngrow-banking.firebaseapp.com",
  projectId: "interngrow-banking",
  storageBucket: "interngrow-banking.firebasestorage.app",
  messagingSenderId: "602055501209",
  appId: "1:602055501209:web:7d2a1ae4bfac6c0d9d5f08",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received:', payload);
});