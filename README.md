
  

# `gke-pubsub-websocket-adapter`

  

The `gke-pubsub-websocket-adapter` provides an easy way to distribute [Google Cloud Pub/Sub](https://cloud.google.com/pubsub) topic messages over

[WebSockets](https://en.wikipedia.org/wiki/WebSocket) so that they may be sent to web clients without using the `gcloud` SDK or Pub/Sub API.

  

## Synopsis

  

The `gke-pubsub-websocket-adapter` is a tool to create the support infrastructure necessary to operate a serverless, auto-scaling [Cloud Run](https://cloud.google.com/run) deployment that mirrors messages sent to a Pub/Sub topic to clients connecting through WebSockets.

  

## Requirements

  

To deploy `gke-pubsub-websocket-adapter` to your GCP project, you will need billing enabled

and the following permissions:

  

* Read access to the topic you'd like to mirror. The topic may reside

in a separate project provided that it is readable by the user or service account

`gke-pubsub-websocket-adapter` runs as.

* Pub/Sub subscription creation privileges in your own project

* Cloud Run instance

  

Out-of-the-box, `gke-pubsub-websocket-adapter` defaults to using the [NYC Taxi Rides public topic](https://github.com/googlecodelabs/cloud-dataflow-nyc-taxi-tycoon) that is available to all GCP users. Please note that this topic's message rate can go escalate to 2500 messages per second or more at times.

  

## Architecture

The `gke-pubsub-websocket-adapter` clusters are stateless and doesn't require persistent disks for the VMs in the cluster. A memory-mapped filesystem is specified within the image that is used for ephemeral POSIX-storage of the Pub/Sub topic messages. Storing a buffer of these messages locally has a few advantages:

  

* It decouples the subscription from client WebSocket connections, and multiplexes potentially many clients while only consuming a single subscription per VM.

* By using `tail -f` as the command piped to [`websocketd`](http://websocketd.com/), clients are served a cache of the last 10 messages published to the topic, even when there is no immediate message flow. This allows for UIs rendering message content to show meaningful data even during periods of low traffic.

  

The `gke-pubsub-websocket-adapter` exposed to web clients through a single endpoint that maps to an indivdual Pub/Sub topic and load balances across VMs in the cluster. The cluster is set to scale up and down automatically based upon the number of clients connected.

  
Currently, the `gke-pubsub-websocket-adapter` uses WebSockets in half-duplex and does not support the publishing of messages by clients over the same WebSocket connection.

  
  

## ![Architecture](architecture.svg "Architecture")

  

The `gke-pubsub-websocket-adapter`'s architecture consists of a number of underlying

components that work in concert to distribute Pub/Sub messages over WebSockets. These include:

  

### Runtime

  

*  [`websocketd`](http://websocketd.com/) CLI for serving websocket clients

*  [`pulltop`](https://github.com/GoogleCloudPlatform/pulltop) CLI for Pub/Sub subscription management

*  [Cloud Run ](https://cloud.google.com/run)

  

### Deployment

  

*  [Cloud Build](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/cloudbuild.yaml)

*  [Terraform](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/setup/main.tf)

  



  

### Authentication

  

The `gke-pubsub-websocket-adapter` runs under a Google service account called `dyson-sa`, which it uses to authenticate with Pub/Sub. If you are wanting to use a private Pub/Sub topic this service account will require access to the topic.

  
  

## Configuration

`deploy.sh` takes in 3 optional variables

 - `-p` which is the GCP Project ID you wish to deploy to, by default this will use the current project gcloud is set to.
 - `-t` the topic you wish to expose via the web socket. Note that the `dyson-sa@project-id.iam.gserviceaccount.com` will require access to that Pub/Sub topic.
 - `-c` the container registry where you wish to push the container image to. By default this will be `gcr.io/project-id/dyson:latest`

  
  

## Known issues and enhancements

  

* If you visit the cluster on the HTTP port instead of the WS/S port, you will be presented with the `websocketd` diagnostic page. Clicking on the checkbox will allow you to see the Pub/Sub messages coming through the WebSocket in the browser. This can be disabled by removing the `--devconsole` argument from the `websocketd` call in the [container setup's](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/container/exec.sh) `exec.sh` file.

## Disclaimers

  

_This is not an officially supported Google product._

  

The `gke-pubsub-websocket-adapter` is under active development. Interfaces and functionality may change at any time.

  

## License

  

This repository is licensed under the Apache 2 license (see [LICENSE](LICENSE.txt)).

  

Contributions are welcome. See [CONTRIBUTING](CONTRIBUTING.md) for more information.