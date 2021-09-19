#!/bin/bash

TF_LOG=trace

cd ./pre-migration
./build.sh 
cd ../post-migration
./migration.sh

