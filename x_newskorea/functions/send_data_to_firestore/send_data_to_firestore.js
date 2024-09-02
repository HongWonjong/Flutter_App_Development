const admin = require('firebase-admin');

// Firebase 초기화
if (!admin.apps.length) {
    admin.initializeApp();
}

const db = admin.firestore();

// Firestore에 데이터를 저장하는 함수
async function sendPostsToFirestore(posts) {
    try {
        const batch = db.batch();

        posts.forEach(post => {
            const postRef = db.collection('community_posts').doc(post.id);
            batch.set(postRef, post);
        });

        await batch.commit();
        console.log('Posts have been saved to Firestore.');
    } catch (error) {
        console.error('Error saving posts to Firestore:', error.message);
        throw new Error('Failed to save posts to Firestore');
    }
}

module.exports = { sendPostsToFirestore };

