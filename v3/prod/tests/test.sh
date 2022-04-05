#!/usr/bin/env bash

dirs=$(ls)

for d in $dirs
do
    cd d; terraform apply -auto-approve; terraform destroy -auto-approve; cat shoult_it_work.txt; cd ..
done
