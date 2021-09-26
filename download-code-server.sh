#!/bin/bash
cd files/
curl -s https://api.github.com/repos/cdr/code-server/releases/latest \
| grep "code-server_3.12.0_amd64.deb" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
cd ..
