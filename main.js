accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmMDY0NTZhNjY1YzE0ZDUxOTI0MDVlOWFiNWI2Y2RmMCIsImlhdCI6MTY5OTk2ODUwNCwiZXhwIjoyMDE1MzI4NTA0fQ.khiLbCiMJIzQ9l-cR0Rjha4uKye5aJs3FtGc9lv6xIg"

nabuCasaUrl="https://gzin1lgtcbl5sn9776jejbqgbum6ds2f.ui.nabu.casa/lovelace/0"

async function fetchSensorData(sensorUrl) {
    try {
        const response = await fetch(sensorUrl);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (e) {
        console.error("There was a problem fetching the sensor data:", e);
    }
}

async function updateSensorDisplay(apiBaseUrl) {
    const sensor1Url = `${apiBaseUrl}/sensor1`;
    const sensor2Url = `${apiBaseUrl}/sensor2`;

    const sensor1Data = await fetchSensorData(sensor1Url);
    const sensor2Data = await fetchSensorData(sensor2Url);

    // Update your webpage with this data
    // Example: document.getElementById('sensor1').textContent = sensor1Data.state;
    // Example: document.getElementById('sensor2').textContent = sensor2Data.state;
}

// Call this function with the base URL of your API
updateSensorDisplay('https://your-api-gateway-url');