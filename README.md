# ct-program-export

This repo contains an automatic tool for extracting the Czech public TV program from the official website and importing it to to Google Cloud Platform environment.

It uses the xmlstarlet tool, which needs to be installed prior to setup.


## Prepare Google cloud project and command line utils

If you have already set up your GCP project, you can skip this section.

1. Prepare Google Cloud Project and enable billing. Remember project-id
2. Enable apis PUB/SUB, Compute, Dataflow
3. Create service account, download auth.json and remember service service-acount-email

Following steps are optional. You can skip them if you already use gcloud command line tools.

* Install gcloud (https://cloud.google.com/sdk/docs/#deb)
* Init gcloud command line. Run `gcloud init`
* Init bigquery commad line. Run `bq init`

## Get this repo from git
`git clone https://github.com/cvanca/ct-program-export.git`
