#!/bin/bash -ue
tr '[:lower:]' '[:upper:]' < 'c_w_005.txt' > 'upper_c_w_005.txt'
cat 'upper_c_w_005.txt'
printf '\n'
