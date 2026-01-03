#!/usr/bin/bash

set -e

seq 0 999|xargs -I@ seq -f '@ %g' 0 999 > test_cases.bk
seq 0 999|xargs -I@ seq -f '@+%g' 0 999|bc > test_cases_add_expected.bk
