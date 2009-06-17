#!/bin/sh

cd datafilter
./run_batch
cd ..
cd divide
./run_batch
cd ..
cd visual
./run_batch
cd ..