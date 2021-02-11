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
    export PROJECT_ID=$project
elses
    export PROJECT_ID=$(gcloud config get-value project)
fi

gcloud services enable --project ${PROJECT_ID?} \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com\
    cloudbuild.googleapis.com \
    stackdriver.googleapis.com \
    run.googleapis.com
    
CLOUDBUILD_SA=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')@cloudbuild.gserviceaccount.com 

gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${CLOUDBUILD_SA} --role roles/iam.serviceAccountTokenCreator
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${CLOUDBUILD_SA} --role roles/iam.serviceAccountCreator
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${CLOUDBUILD_SA} --role roles/run.admin
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${CLOUDBUILD_SA} --role roles/resourcemanager.projectIamAdmin
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${CLOUDBUILD_SA} --role roles/storage.admin
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member serviceAccount:${CLOUDBUILD_SA} --role roles/iam.serviceAccountUser


if [[ ! -z "$container" ]] && [[ ! -z "$topic" ]]
then
    gcloud builds submit --config cloudbuild.yaml --substitutions=_CONTAINER_LOCATION=$container,_PUBSUB_TOPIC=$topic
elif [ -z "$container" ] && [[ ! -z "$topic" ]]
then
    gcloud builds submit --config cloudbuild.yaml --substitutions=_PUBSUB_TOPIC=$topic

elif [[ ! -z "$container" ]] && [ -z "$topic" ]
then
    gcloud builds submit --config cloudbuild.yaml --substitutions=_CONTAINER_LOCATION=$container

else
    gcloud builds submit --config cloudbuild.yaml 
fi