#!/bin/bash -ue
tr '[:lower:]' '[:upper:]' < 'c_w_004.txt' > 'upper_c_w_004.txt'
cat 'upper_c_w_004.txt'
printf '\n'
