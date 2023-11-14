import requests

# Defining hardcoded variables:
access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmMDY0NTZhNjY1YzE0ZDUxOTI0MDVlOWFiNWI2Y2RmMCIsImlhdCI6MTY5OTk2ODUwNCwiZXhwIjoyMDE1MzI4NTA0fQ.khiLbCiMJIzQ9l-cR0Rjha4uKye5aJs3FtGc9lv6xIg"
nabuCasaApiUrl="https://gzin1lgtcbl5sn9776jejbqgbum6ds2f.ui.nabu.casa/api/states/"
stair_door = "binary_sensor.stair_door_opening"
# barn_door = "binary_sensor.barn_door_opening"

def fetch_sensor_data(sensor_url, access_token=access_token):
    try:
        response = requests.get(nabuCasaApiUrl + sensor_url, headers={
            'Authorization': f'Bearer {access_token}'
        })

        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"There was a problem fetching the sensor data: {e}")

# Example usage
def door_open_test(sensor_url=list, access_token=access_token):
    states = []
    for item in sensor_url:
        data = fetch_sensor_data(item, access_token)
        state = data['state']
        states.append(state)

    if all(state == 'on' for state in states):
        return 'YES'
    elif any(state == 'off' for state in states):
        return 'NO, AT LEAST ONE IS CLOSED'
    else:
        return 'NO, THEY ARE BOTH CLOSED'
    
print(door_open_test([stair_door], access_token))