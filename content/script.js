document.addEventListener('DOMContentLoaded', function() {
    fetch('https://7fcx7ig8fa.execute-api.us-east-2.amazonaws.com/doorsv2/door') // Replace with your API URL
    .then(response => response.json())
    .then(data => {
        document.getElementById('api-data').innerText = data.message;
    })
    .catch(error => {
        console.error('Error fetching data: ', error);
        document.getElementById('api-data').innerText = 'Error loading data';
    });
});
