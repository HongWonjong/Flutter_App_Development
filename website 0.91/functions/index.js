/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const {SecretManagerServiceClient} = require('@google-cloud/secret-manager');

const client = new SecretManagerServiceClient();
// 함수가 설치된 region을 firebase.json이 아니라 함수에 직접 삽입한다.
exports.getSecretValue = functions.region("asia-northeast3").https.onCall(async (data, context) => {
    const [version] = await client.accessSecretVersion({
        name: 'projects/432019525707/secrets/RECAPTCHA_TOKEN',
    });

    const payload = version.payload.data.toString('utf8');

    return { secretValue: payload };
});

exports.getSecretValue = functions.region("asia-northeast3").https.onCall(async (data, context) => {
    const [version] = await client.accessSecretVersion({
        name: 'projects/432019525707/secrets/firestore-chatgpt-bot-OPENAI_API_KEY',
    });

    const payload = version.payload.data.toString('utf8');

    return { gpt35SecretValue: payload };
});



