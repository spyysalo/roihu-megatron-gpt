# Roihu Megatron-GPT

Scripts and information for training GPT-like models on the Roihu supercomputer using Megatron-LM.

## Quickstart

(run on roihu-gpu login node)

Check out this repo

```
git clone https://github.com/spyysalo/roihu-megatron-gpt.git
cd roihu-megatron-gpt
```

Edit `download_data.sh`, `prepare_venv.sh`, and `train-gpt.sh` and replace occurrences
of the string `project_2017850` with your account. You may also need to update `partition`
in `prepare_venv.sh` and `train-gpt.sh` if you're running this after the pilot period.

Download example data for testing into `/scratch/$ACCOUNT/preprocessed/wikipesto`,
where `$ACCOUNT` is your account.

```
./download_data.sh 
```

Prepare a venv with TransformerEngine, apex and Megatron Core in
`/scratch/$ACCOUNT/venv/python-pytorch-megatron`.
Note that this will run on a GPU node and will take some time to complete.
You can `tail -f logs/*` to watch progress.

```
sbatch prepare_venv.sh
```

Check out Megatron-LM

```
git clone https://github.com/nvidia/megatron-lm
```

Launch training

```
sbatch train-gpt.sh
```
