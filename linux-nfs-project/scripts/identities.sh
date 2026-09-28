#!/bin/bash

for usr in Harry
do
    sudo useradd "${usr}"
done

for grp in slytherin storage-admin
do
    sudo groupadd "${grp}"
done

for usr in Harry
do
    sudo usermod -aG storage-admin "${usr}"
done

for usr in Draco Tom Thodore Blaise Harry
do
    sudo usermod -aG slytherin "${usr}"
done