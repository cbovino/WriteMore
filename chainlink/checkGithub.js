const axios = require("axios");

const username = "user"; // GitHub username
const since = Date.now() - 86400000; // Timestamp 24 hours ago

async function hasRecentCommits(username) {
    const username = "user"; // GitHub username
    const since = Date.now() - 86400000; // 24 hours ago timestamp
    
    const url = `https://api.github.com/users/${username}/events/public`;
    
    const response = await Functions.makeHttpRequest({
      url: url,
      headers: { "User-Agent": "Chainlink-Functions" }
    });
    
    if (!response.data || response.data.length === 0) {
      return Functions.encodeUint256(0); // No events found
    }
    
    // Check if there's a recent PushEvent (commit event)
    for (const event of response.data) {
      if (event.type === "PushEvent") {
        const eventTimestamp = new Date(event.created_at).getTime();
        if (eventTimestamp >= since) {
          return Functions.encodeUint256(1); // Commit found
        }
      }
    }
    
    return Functions.encodeUint256(0); // No recent commits found
    
}

// Call function
hasRecentCommits(username).then((result) => {
  console.log("Commit Check Result:", result);
});