#!/bin/bash

fio --name=nfs-sequential-write \
    --directory=/files/prod/griffindor/ \
    --size=1G \
    --rw=write \
    --bs=1M \
    --direct=1 \
    --iodepth=16 \
    --runtime=60 \
    --time_based