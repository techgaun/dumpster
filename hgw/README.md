# hub-gateway [![Build Status](https://semaphoreci.com/api/v1/projects/036b3d0f-b367-4b43-a323-d3f17c18da60/1289792/badge.svg)](https://semaphoreci.com/casaiq/hub-gateway)

> Cloud Gateway application for hub clients

Hub Gateway serves as a thin application on the cloud that Hub clients connect to.
It is a modular application that can be plugged into the main backend API in the future
if we stop using Heroku for main backend API.
Below are some of the capabilities and purposes of hub-gateway.

- ensure low bandwidth consumption for hubs
- translate data from hub to the format that our main backend API can understand
- forward the request/responses between hub and backend API
- handle compression and data minification

### Configuration

- Use `PORT` envvar to specify the PORT you want the hub gateway to be running on. Runs on 4000 by default.
- Use `WS_SERVER` envvar to specify custom websocket server. By default, it connects to staging websocket. Make sure to
    include trailing `websocket` on your configuration.
- Use `LOG_LEVEL` to override the default logging behavior.


### Hub Socket and Channel

- Pass the auth token as part of your websocket url via `t` parameter
