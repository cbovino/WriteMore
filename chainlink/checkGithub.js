const startTime = 86400000 * 5; // 10 days ago
const username = "cbovino"; // GitHub username
const since = Date.now() - startTime; // Timestamp for start time

const url = `https://api.github.com/users/${username}/events/public`;

const response = await Functions.makeHttpRequest({
    url: url,
    headers: { "User-Agent": "Chainlink-Functions" }
});

if (!response.data || response.data.length === 0) {
    return Functions.encodeUint256(0); // No events found
}

const commitsByDay = new Set();

// Process events to check for daily commits
for (const event of response.data) {
    if (event.type === "PushEvent") {
        const eventDate = new Date(event.created_at);
        const dayTimestamp = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate()).getTime();
        commitsByDay.add(dayTimestamp);
    }
}

// Check for missing days
const currentDate = new Date();
for (let time = since; time <= currentDate.getTime(); time += 86400000) {
    const dayTimestamp = new Date(new Date(time).getFullYear(), new Date(time).getMonth(), new Date(time).getDate()).getTime();
    if (!commitsByDay.has(dayTimestamp)) {
        return Functions.encodeUint256(0); // Missing commit for a day
    }
}

return Functions.encodeUint256(1); 