#!/bin/bash -ue
tr '[:lower:]' '[:upper:]' < 'c_w_001.txt' > 'upper_c_w_001.txt'
cat 'upper_c_w_001.txt'
printf '\n'
