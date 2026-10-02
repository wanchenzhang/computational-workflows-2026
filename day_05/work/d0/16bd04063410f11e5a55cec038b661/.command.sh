#!/bin/bash -ue
tr '[:lower:]' '[:upper:]' < 'c_w_003.txt' > 'upper_c_w_003.txt'
cat 'upper_c_w_003.txt'
printf '\n'
