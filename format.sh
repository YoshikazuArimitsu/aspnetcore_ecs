#!/bin/sh

# install
# $ ln -s -r ./format.sh ./.git/hooks/pre-commit

(cd Server && dotnet format)
(cd Infrastructure && terraform fmt)
