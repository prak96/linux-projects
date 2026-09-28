#!/bin/bash

fio --name=nfs-sequential-read \
      --directory= /files/prod/griffindor/ \
       --size=1G \
       --rw=read \
       --bs=1M \
       --direct=1 \
       --iodepth=16 \
       --runtime=60 \
       --time_based