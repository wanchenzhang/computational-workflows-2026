#!/bin/bash -ue
tr '[:lower:]' '[:upper:]' < 'c_w_002.txt' > 'upper_c_w_002.txt'
cat 'upper_c_w_002.txt'
printf '\n'
