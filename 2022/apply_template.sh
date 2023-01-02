#!/bin/bash

template_file="$1"
template_header_end="$2"
template_footer_begin="$3"

code_file="$4"
code_begin="$5"
code_end="$6"

AoC_year="$7"
AoC_day="$8"

(
	sed "$template_header_end"'q' "$template_file"\
| sed -r 's@(# Advent of Code, )YYYY(, day )DD@\1'"$AoC_year"'\2'"$AoC_day"'@'\
| sed -r 's@(# https://adventofcode.com/)YYYY(/day/)DD@\1'"$AoC_year"'\2'"$AoC_day"'@'
	sed -n "$code_begin"','"$code_end"'p' "$code_file"
	sed '1,'$[$template_footer_begin - 1]'d' "$template_file"
)
