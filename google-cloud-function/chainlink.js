const functions = require('@google-cloud/functions-framework');
const axios = require("axios");

functions.http('checkCommits', async (req, res) => {

    const startTime = 86400000 * Number(req.body.days); // Use Number directly instead of new Number
    const username = req.body.username;
    const since = Date.now() - startTime;
    const url = `https://api.github.com/users/${username}/events/public`; // Use template literals for better readability
    console.log(JSON.stringify(req.body), "body");
    let response;
    try {
        response = await axios.get(url);
    } catch (err){
        console.log(JSON.stringify(err));
    }
    
    if (!response || response.status !== 200 || !response.data || response.data.length === 0) {
        res.JSON({response: "Failed Response"});
    }

    const commitsByDay = new Set();
    for (const event of response.data) {
        if (event.type === 'PushEvent') {
            const eventDate = new Date(event.created_at);
            const dayTimestamp = new Date(eventDate.getFullYear(), eventDate.getMonth(), eventDate.getDate()).getTime();
            commitsByDay.add(dayTimestamp);
        }
    }

    const currentDate = new Date();
    for (let time = since; time <= currentDate.getTime(); time += 86400000) {
        const dayTimestamp = new Date(new Date(time).getFullYear(), new Date(time).getMonth(), new Date(time).getDate()).getTime();
        if (!commitsByDay.has(dayTimestamp)) {
            res.json({response: "No Commits"});
        }
    }

    res.json({response: "Commitment Complete"});
});