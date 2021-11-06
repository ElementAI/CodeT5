#!/bin/bash

cd sh
export WORKDIR=/app
python run_exp.py --model_tag $1 --task $2 --sub_task $3 --model_dir /workspace/results/code_t5_finetune --summary_dir /workspace/results/tensorboard

cd -

