
# `gke-pubsub-websocket-adapter`

The `gke-pubsub-websocket-adapter` provides an easy way to distribute [Google Cloud Pub/Sub](https://cloud.google.com/pubsub) topic messages over
[WebSockets](https://en.wikipedia.org/wiki/WebSocket) so that they may be sent to web clients without using the `gcloud` SDK or Pub/Sub API.

## Synopsis

The `gke-pubsub-websocket-adapter` is a tool to create the support infrastructure necessary to operate a
load-balanced, autoscaled [GKE](https://cloud.google.com/kubernetes-engine) cluster that mirrors
messages sent to a Pub/Sub topic to clients connecting through WebSockets.

## Requirements

To deploy `gke-pubsub-websocket-adapter` to your GCP project, you will need billing enabled
and the following permissions:

* Read access to the topic you'd like to mirror. The topic may reside
  in a separate project provided that it is readable by the user or service account
  `gke-pubsub-websocket-adapter` runs as.
* Pub/Sub subscripton creation privileges in your own project
* A GKE cluster
* A front-end load balancer 

#### CLI Tools (For the example):
* KPT - [Installation Docs](https://kpt.dev/installation/kpt-cli)
* Skaffold - [Installation Docs](https://skaffold.dev/docs/install/)

Out-of-the-box, `gke-pubsub-websocket-adapter` defaults to using the [NYC Taxi Rides public
topic](https://github.com/googlecodelabs/cloud-dataflow-nyc-taxi-tycoon) that is available to all GCP users. Please note that this
topic's message rate can go escalate to 2500 messages per second or
more at times.

## Architecture
The `gke-pubsub-websocket-adapter` clusters are stateless and doesn't require persistent disks for
the VMs in the cluster. A memory-mapped filesystem is specified within
the image that is used for ephemeral POSIX-storage of the Pub/Sub
topic messages. Storing a buffer of these messages locally has a few
advantages:

* It decouples the subscription from client WebSocket connections, and
  multiplexes potentially many clients while only consuming a single
  subscription per VM.
* By using `tail -f` as the command piped to [`websocketd`](http://websocketd.com/), clients are
  served a cache of the last 10 messages published to the topic,
  even when there is no immediate message flow. This allows for UIs
  rendering message content to show meaningful data even during periods
  of low traffic.

The `gke-pubsub-websocket-adapter` exposed to web clients through a single endpoint that maps to
an indivdual Pub/Sub topic and load balances across VMs in the cluster. The cluster is set to scale up and down
automatically based upon the number of clients connected.

Currently, the `gke-pubsub-websocket-adapter` uses WebSockets in half-duplex and does not support
the publishing of messages by clients over the same WebSocket connection.


## ![Architecture](architecture.svg "Architecture")

The `gke-pubsub-websocket-adapter`'s architecture consists of a number of underlying
components that work in concert to distribute Pub/Sub messages over
WebSockets. These include:

### Runtime

* [`websocketd`](http://websocketd.com/) CLI for serving websocket clients
* [`pulltop`](https://github.com/GoogleCloudPlatform/pulltop) CLI for Pub/Sub subscription management
* [GKE](https://cloud.google.com/kubernetes-engine)

### Deployment

* [Cloud Build](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/cloudbuild.yaml)
* [Terraform](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/setup/main.tf)
* [kpt](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/kubernetes-manifests/Kptfile)
* [Skaffold](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/skaffold.yaml)

To deploy the `gke-pubsub-websocket-adapter` ensure you have set
`gcloud config set project my-project-id` to the project you wish to
deploy the `gke-pubsub-websocket-adapter` in.

First you will need to edit the `skaffold.yaml` config. 
Update the following configuration files:

skaffold.yaml
* `my-project-id` to your GCP Project ID
* `us-docker.pkg.dev/my-project-id/docker/` to the registry you wish to use, the terraform provided grants permissions for [Artifact Registry](https://cloud.google.com/artifact-registry).

kubernetes-manifests/setters.yaml
```
image-repo: us-docker.pkg.dev/my-project-id/repo-name/
project-id: my-project-id
```

After that you can run change directory to the example `cd examples/taxirides-realtime/` `sh deploy.sh` to deploy the infrastructure for sample deployment using the public [NYC Taxi Rides feed](https://github.com/GoogleCloudPlatform/nyc-taxirides-stream-feeder) `projects/pubsub-public-data/topics/taxirides-realtime"` Pub/Sub topic. 

Once the terraform deployment is complete, you will need to get the credentials for the GKE cluster.

```
gcloud container clusters get-credentials dyson-cluster --region us-central1 --project my-project-id
```

Now you can deploy the workload by running `skaffold run` from the root of the directory.

#### Clean up
To clean up all of the resources created run the following:
```
cd examples/taxirides-realtime/setup && gcloud builds submit --config destroy.yaml
```

### Authentication

The `gke-pubsub-websocket-adapter` uses [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) to authenticate with Pub/Sub under the Google service account called `dyson-sa`. If you are wanting to use a private Pub/Sub topic this service account will require access to the topic. 


## Configuration

[kpt](https://googlecontainertools.github.io/kpt/)  is used for setting config for the Kubernetes manifests.
[Skaffold](https://skaffold.dev/) is used to build, render and deploy the manifests.


For the default deployment, these variables are set for you in the `kubernetes-manifests/setters.yaml` file. Please modify these, and these will be rended as a part of the Skaffold pipeline.


## Known issues and enhancements

* If you visit the cluster on the HTTP port instead of the WS/S port,
  you will be presented with the `websocketd` diagnostic
  page. Clicking on the checkbox will allow you to see the Pub/Sub
  messages coming through the WebSocket in the browser. This can be disabled by removing the `--devconsole` argument from the `websocketd` call in the [container setup's](https://github.com/GoogleCloudPlatform/gke-pubsub-websocket-adapter/blob/main/container/exec.sh) `exec.sh` file.
  
* If you would like to secure your websockets with TLS to support _wss_ (_WebSocket_ Secure) you can follow [this documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs) or if you would like to leverage Google-managed certificates you can use the following [documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs).

## See also

## Disclaimers

_This is not an officially supported Google product._

The `gke-pubsub-websocket-adapter` is under active development. Interfaces and functionality may change at any time.

## License

This repository  is licensed under the Apache 2 license (see [LICENSE](LICENSE.txt)).

Contributions are welcome. See [CONTRIBUTING](CONTRIBUTING.md) for more information.
