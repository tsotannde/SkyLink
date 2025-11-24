const { setGlobalOptions } = require("firebase-functions");
const { onCall } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const fetch = require("node-fetch");

setGlobalOptions({ maxInstances: 10 });

// Request server IP + config
exports.requestIPAddress = onCall(async (data) => {
  logger.info("requestIPAddress called:", data);

  try {
    const input = data.data || data;
    const { publicKey, serverIP, serverPort = 5000 } = input;

    if (!serverIP || !publicKey) {
      throw new Error("Missing required parameters: serverIP or publicKey");
    }

    const serverUrl = `http://${serverIP}:${serverPort}/assign-ip`;
    logger.info(`Forwarding request to: ${serverUrl}`);

    const response = await fetch(serverUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ publicKey }),
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Server responded with ${response.status}: ${text}`);
    }

    // ✅ Fixed: match the Python server’s JSON keys
    const json = await response.json();
    const { assignedIP, serverPublicKey, port } = json;

    if (!assignedIP || !serverPublicKey || !port) {
      throw new Error("Missing required fields in server response");
    }

    logger.info("Successfully received from server:", json);

    // ✅ Return data in the correct structure for your app
    return {
      ip: assignedIP,
      serverPublicKey,
      port,
    };

  } catch (error) {
    logger.error("Error in requestIPAddress:", error);
    throw new Error(`Failed to request IP: ${error.message}`);
  }
});
