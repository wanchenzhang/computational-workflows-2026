#!/bin/bash -ue
printf '%s\n' 'Hello world!' | tr '[:lower:]' '[:upper:]' > uppercase.txt
