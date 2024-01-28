import json
import requests
import os

# Defining hardcoded variables:
access_token = os.environ.get('access_token')
nabuCasaApiUrl = os.environ.get('nabuCasaApiUrl')
stair_door = "binary_sensor.stair_door_contact"
barn_door = "binary_sensor.barn_door_contact"
sensor_urls = [stair_door, barn_door]
def fetch_sensor_data(sensor_url, access_token=access_token):
    try:
        response = requests.get(nabuCasaApiUrl + sensor_url, headers={
            'Authorization': f'Bearer {access_token}'
        })

        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"There was a problem fetching the sensor data: {e}")

def door_open_test(sensor_urls=sensor_urls, access_token=access_token):
    states = []
    for item in sensor_urls:
        data = fetch_sensor_data(item, access_token)
        if data:
            state = data.get('state')
            states.append(state)

    if all(state == 'on' for state in states):
        message = 'YES'
    elif all(state == 'off' for state in states):
        message = 'NO, THEY ARE BOTH CLOSED'
    elif any(state == 'off' for state in states):
        message = 'NO, AT LEAST ONE IS CLOSED'
    else:
        message = 'THE SENSORS ARE DOWN, STAND BY'

    return {
        'statusCode': 200,
        'body': json.dumps({'message': message}),
        'headers': {
            'Content-Type': 'application/json'
        }
    }

# Lambda handler function
def lambda_handler(event, context):

    # Call your function
    response = door_open_test()

    return response

print(door_open_test())