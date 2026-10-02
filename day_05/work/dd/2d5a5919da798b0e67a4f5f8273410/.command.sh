#!/bin/bash -ue
tr '[:lower:]' '[:upper:]' < 'c_w_008.txt' > 'upper_c_w_008.txt'
cat 'upper_c_w_008.txt'
printf '\n'
