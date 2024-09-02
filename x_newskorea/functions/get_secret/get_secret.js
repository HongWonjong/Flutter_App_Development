// secrets.js
const functions = require('firebase-functions');
const { SecretManagerServiceClient } = require('@google-cloud/secret-manager');
const logger = require('firebase-functions/logger');

async function accessSecret(projectId, secretId, versionId = 'latest') {
    const client = new SecretManagerServiceClient();
    const [version] = await client.accessSecretVersion({
        name: `projects/${projectId}/secrets/${secretId}/versions/latest`,

    });
    return version.payload.data.toString('utf-8');
}

async function getSecrets(projectId, secretIds) {
    const secrets = {};
    for (const secretId of secretIds) {
        try {
            secrets[secretId] = await accessSecret(projectId, secretId);
        } catch (error) {
            logger.error(`Failed to access secret ${secretId}:`, error.message);
        }
    }
    return secrets;
}

module.exports = { getSecrets };
