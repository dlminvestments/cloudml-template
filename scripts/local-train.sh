#!/bin/bash

echo "Training local ML model"

MODEL_NAME=synth_regressor

PACKAGE_PATH=trainer
TRAIN_FILES=data/train-data.csv
VALID_FILES=data/valid-data.csv
MODEL_DIR=trained_models/${MODEL_NAME}

#remove model directory, if you don't want to resume training, or if you have changed the model structure
rm -r ${MODEL_DIR}


gcloud ml-engine local train \
        --module-name=trainer.task \
        --package-path=${PACKAGE_PATH} \
        -- \
        --train-files=${TRAIN_FILES} \
        --num-epochs=10 \
        --train-batch-size=500 \
        --eval-files=${VALID_FILES} \
        --eval-batch-size=500 \
        --learning-rate=0.001 \
        --hidden-units="128,40,40" \
        --layer-sizes-scale-factor=0.5 \
        --num-layers=3 \
        --job-dir=${MODEL_DIR} \
        --remove-model-dir=True


ls ${MODEL_DIR}/export/Servo
MODEL_LOCATION=${MODEL_DIR}/export/Servo/$(ls ${MODEL_DIR}/export/Servo | tail -1)
echo ${MODEL_LOCATION}
ls ${MODEL_LOCATION}

# invoke trained model to make prediction given new data instances
gcloud ml-engine local predict --model-dir=${MODEL_LOCATION} --json-instances=data/new-data.json