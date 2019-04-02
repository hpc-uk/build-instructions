#!/bin/bash

module load wget

wget https://github.com/dealii/dealii/releases/download/v8.5.1/dealii-8.5.1.tar.gz -O dealii-8.5.1.tar.gz
wget http://www.dealii.org/8.5.1/external-libs/p4est-setup.sh
wget http://p4est.github.io/release/p4est-1.1.tar.gz
