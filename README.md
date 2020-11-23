# ct-program-export

This repo contains an automatic tool for extracting the Czech public TV program from the official website and importing it to BQ in the Google Cloud Platform environment.

It uses the xmlstarlet tool, which must be installed prior to setup.


## Prepare Google cloud project and command line utils

If you have already set up your GCP project, you can skip this section.

1. Prepare Google Cloud Project and enable billing. Remember project-id
2. Enable apis PUB/SUB, Compute, Dataflow
3. Create service account, download auth.json and remember service service-acount-email

Following steps are optional. You can skip them if you already use gcloud command line tools.

* Install gcloud (https://cloud.google.com/sdk/docs/#deb)
* Init gcloud command line. Run `gcloud init`
* Init bigquery commad line. Run `bq init`


## Install xmlstarlet

Make sure there is xmlstarlet installed on your GCP Debian machine.

`sudo apt-get xmlstarlet`


## Get this repo from git

`git clone https://github.com/cvanca/ct-program-export.git`

Create a folder in the filesystem, you wish to use for storing the files (e.g. within `/srv`) and copy the content of the repo.


## Use this template

This template will handle all available channel program of the Czech TV (ct1, ct2, ct24, ct4, ct5, ct6).
Edit `./ct_program_daily.sh`. Replace PROJECTID, BUCKETID, SERVICEACCOUNT, USERNAME and you can change ZONE and REGION if you wish.

In order to process the program data daily, set the `./ct_program_daily.sh` script in cron.
