accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJmMDY0NTZhNjY1YzE0ZDUxOTI0MDVlOWFiNWI2Y2RmMCIsImlhdCI6MTY5OTk2ODUwNCwiZXhwIjoyMDE1MzI4NTA0fQ.khiLbCiMJIzQ9l-cR0Rjha4uKye5aJs3FtGc9lv6xIg"

nabuCasaApiUrl="https://gzin1lgtcbl5sn9776jejbqgbum6ds2f.ui.nabu.casa/api/states/"
import requests

def fetch_sensor_data(sensor_url, access_token):
    try:
        response = requests.get(nabuCasaApiUrl + sensor_url, headers={
            'Authorization': f'Bearer {access_token}'
        })

        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"There was a problem fetching the sensor data: {e}")

def update_sensor_display(api_base_url, access_token):
    sensor1_url = nabuCasaApiUrl + api_base_url
    sensor2_url = nabuCasaApiUrl + api_base_url

    sensor1_data = fetch_sensor_data(sensor1_url, access_token)
    sensor2_data = fetch_sensor_data(sensor2_url, access_token)

    # Process your sensor data here
    # For example, you can print it or handle it as needed
    print(sensor1_data)
    print(sensor2_data)

# Example usage
nabuCasaApiUrl = "https://example.com/api/"  # Replace with your actual API URL
access_token = "your_access_token"  # Replace with your actual access token
update_sensor_display('binary_sensor.stair_door_opening', access_token)
