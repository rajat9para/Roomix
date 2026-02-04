const admin = require('firebase-admin');
require('dotenv').config();

// Initialize Firebase Admin SDK
// Using environment variables instead of service account file
const firebaseConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID || 'roomix-28de2',
};

// Initialize without service account (for token verification only)
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: firebaseConfig.projectId,
  });
}

module.exports = admin;
