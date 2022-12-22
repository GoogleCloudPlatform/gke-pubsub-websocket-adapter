# gke-pubsub-websocket-adapter

## Description
The `gke-pubsub-websocket-adapter` provides an easy way to distribute [Google Cloud Pub/Sub](https://cloud.google.com/pubsub) topic messages over
[WebSockets](https://en.wikipedia.org/wiki/WebSocket) so that they may be sent to web clients without using the `gcloud` SDK or Pub/Sub API.

## Usage


### Fetch the package
`kpt pkg get https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter.git/gke-pubsub-websocket-adapter gke-pubsub-websocket-adapter`
Details: https://kpt.dev/reference/cli/pkg/get/

### View package content
`kpt pkg tree gke-pubsub-websocket-adapter`
Details: https://kpt.dev/reference/cli/pkg/tree/

### Apply the package
```
kpt live init gke-pubsub-websocket-adapter
kpt live apply gke-pubsub-websocket-adapter --reconcile-timeout=2m --output=table
```
Details: https://kpt.dev/reference/cli/live/
