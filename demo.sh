#!/bin/bash

while getopts c:t:p: flag
do
    case "${flag}" in
        c) container=${OPTARG};;
        t) topic=${OPTARG};;
        p) project=${OPTARG};;
    esac
done

if [[ ! -z "$project" ]]
then
    #export PROJECT_ID=$project
    echo $project
else
    echo "No project ID provided"
    #export PROJECT_ID=$(gcloud config get-value project)
fi