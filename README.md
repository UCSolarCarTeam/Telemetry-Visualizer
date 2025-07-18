# Telemetry-Visualizer

This repository contains a Grafana Dashboard for visualizing telemetry data using MQTT.

## Prerequisites

- Docker installed on your machine.
- An MQTT broker running (e.g., Eclipse Mosquitto). Detailed setup instructions for the MQTT broker can be found in the [Helios-Telemetry](https://github.com/UCSolarCarTeam/Helios-Telemetry), running only the aedes server.
- An MQTT client to publish telemetry data to the broker. Additional setup instructions for the MQTT client can be found in the [Helios-Mqtt-Webserver-Test](https://github.com/UCSolarCarTeam/Helios-Mqtt-Webserver-Test).

## Instructions

1. **Clone the Repository**:

   ```bash
   git clone [repository-url]
   ```

1. **Navigate to the Directory**:

   ```bash
   cd Telemetry-Visualizer
   ```

1. **Start the Docker Container**:

   ```bash
    docker run -d --name telemetry-visualizer -p 3000:3000 grafana/grafana-enterprise

    ```

1. **Start the MQTT Broker**:
   If you haven't already, start your MQTT broker (e.g., Eclipse Mosquitto) using Docker or any other method. Ensure it is running on port 1883. Configure the usernae and password as needed. If you are using Docker, you can run the following command to start Mosquitto:

   ```bash

   Example command to run Mosquitto:
   ```bash
   docker run -d --name mosquitto -p 1883:1883 eclipse-mosquitto
   ```

    If you are using a different MQTT broker, ensure it is accessible at `host.docker.internal:1883`.
    1. **Start the MQTT Client**:
    If you have an MQTT client set up, start it to publish telemetry data to the broker. Ensure it is configured to connect to `host.docker.internal:1883` with the appropriate credentials.

1. **Access Grafana**:
   Open your web browser and go to `http://localhost:3000`. The default login credentials are:
    - **Username**: admin  
    - **Password**: admin
1. **Add Data Source**:
    - Navigate to **Configuration** > **Data Sources**.
    - Click on **Add data source**.
    - Select **MQTT**.
1. **Configure MQTT Data Source**:
    - **Name**: MQTT
    - **Server URL**: host.docker.internal:1883
    - **Username**: [your-username]
    - **Password**: [your-password]
1. **Save & Test**:
    - Click on **Save & Test** to ensure the connection is successful.
1. **Import Dashboard**:
    - Navigate to **Dashboards** > **Manage**.
    - Click on **Import**.
    - Upload the JSON file for the dashboard or paste the JSON content directly.
1. **Select Data Source**:
    - When prompted, select the MQTT data source you configured earlier.
1. **View Dashboard**:
    - Navigate to the dashboard you imported to view the telemetry data.

### Helpful Commands

Use the following commands to interact with the MQTT broker and visualize data:

```bash
docker run -it --rm eclipse-mosquitto mosquitto_sub   -h 10.0.0.63 -p 1883   -u [ username ] -P [password]   -t packet
```
