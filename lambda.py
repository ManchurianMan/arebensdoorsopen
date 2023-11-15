import json
import requests

# Defining hardcoded variables:
access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmMDY0NTZhNjY1YzE0ZDUxOTI0MDVlOWFiNWI2Y2RmMCIsImlhdCI6MTY5OTk2ODUwNCwiZXhwIjoyMDE1MzI4NTA0fQ.khiLbCiMJIzQ9l-cR0Rjha4uKye5aJs3FtGc9lv6xIg"
nabuCasaApiUrl="https://gzin1lgtcbl5sn9776jejbqgbum6ds2f.ui.nabu.casa/api/states/"
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
    else:
        message = 'NO, AT LEAST ONE IS CLOSED'

    return {
        'statusCode': 200,
        'body': json.dumps({'message': message}),
        'headers': {
            'Content-Type': 'application/json'
        }
    }

# Lambda handler function
def lambda_handler(event, context):
    # Extract parameters from the event, if necessary
    # For example, if using query parameters:
    # sensor_urls = event['queryStringParameters']['sensor_urls'].split(',')

    # Call your function
    response = door_open_test()

    return response

print(door_open_test())