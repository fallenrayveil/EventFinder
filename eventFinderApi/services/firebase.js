const { initializeApp } = require("firebase/app");
const { getAuth, createUserWithEmailAndPassword,signInWithEmailAndPassword } = require("firebase/auth");
const admin = require('firebase-admin')


const serviceAccount = require('../credentials.json')

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDmpMUz3LxAKgQcH4nO_j_ncqRSy-JM8To",
  authDomain: "eventfinderapi-e9c06.firebaseapp.com",
  projectId: "eventfinderapi-e9c06",
  storageBucket: "eventfinderapi-e9c06.appspot.com",
  messagingSenderId: "608064013504",
  appId: "1:608064013504:web:3734f828b2f3b4281a9925",
  measurementId: "G-849XNDG85E"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = admin.firestore();

const createUser = async ( {email, password}) => {
  try {
    console.log(email)
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    return user;
  } catch (error) {
    throw new Error(`Error creating user: ${error.message}`);
  }
};

const loginWithEmail = async ({email,password})=>{
  try {
    // const user = await admin.auth().getUserByEmail(email);
    // const token = await admin.auth().createCustomToken(user.uid);
    const userCredential = await signInWithEmailAndPassword(auth, email,password)


    return userCredential
  } catch (error) {
    throw new Error(`Eror login with email: ${error.message} `)
  }
 
}
module.exports = { createUser,loginWithEmail,db };
