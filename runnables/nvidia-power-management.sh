#!/bin/bash
sudo nvidia-smi -pm ENABLED
sudo nvidia-smi -pl 100
sudo nvidia-smi --lock-gpu-clocks=0,1695 --mode=1
sudo nvidia-smi --lock-memory-clocks=0,5001
