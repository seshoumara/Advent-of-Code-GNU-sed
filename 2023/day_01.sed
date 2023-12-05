#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2023, day 01
	# https://adventofcode.com/2023/day/1
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	b calibration_sum_numeric
	#b calibration_sum_alphanumeric
b EOS


:calibration_sum_numeric
    #remove letters
    s:[^0-9]::g
    #single digit edge-case: duplicate it to get the value
    s:^.$:&&:
    #remove characters in between, if any, then store to hold space
    s:^(.).*(.)$:\1\2:
l
    1h;1!H
    $b sum_values
b EOS


:calibration_sum_alphanumeric
    #find the first value and mark it
    s:((1)|(one)|(2)|(two)|(3)|(three)|(4)|(four)|(5)|(five)|(6)|(six)|(7)|(seven)|(8)|(eight)|(9)|(nine)):=&>:
    s:^[^=]*::
    #temporarily store it to hold space at the end of data from previously processed lines
    1h;1!H
    x
    s:>.*::
    x
    #reverse remaining characters, if any
    s:.*>:>:
    s:$:\n:
    :loop
        />\n/b end
        s:>(.)(.*\n)(.*):>\2\1\3:
    b loop
    :end
        s:>\n::
    #find the last value and mark it
    s:((1)|(eno)|(2)|(owt)|(3)|(eerht)|(4)|(ruof)|(5)|(evif)|(6)|(xis)|(7)|(neves)|(8)|(thgie)|(9)|(enin)):=&>:
    /=/!s:$:=>:
    s:^[^=]*=(.*)>.*:\1:
    #bring back the first value, then remove it from hold space
    x
    G;h
    s:\n=.*::
    x
    s:.*=::
    #add look-up tables, then convert to numeric only
    s:$:;one-1,two-2,three-3,four-4,five-5,six-6,seven-7,eight-8,nine-9:
    s:$:,eno-1,owt-2,eerht-3,ruof-4,evif-5,xis-6,neves-7,thgie-8,enin-9:
    s:^(.+)(\n.*\1-)(.):\3\2\3:
    s:\n(.+)(;.*\1-)(.):\n\3\2\3:
    s:;.*::
    s:\n::
    #single digit edge-case: duplicate it to get the value
    s:^.$:&&:
l
    1h;1!H
    $b sum_values
b EOS


:sum_values
    x
    s:\n: :g
    #prepare math lib call (jump to appropriate label)
    s:.*:<ADD>&#result_ap_sv<DDA>:
l
    b add_pos
    :result_ap_sv
        #extract and print sum
        s:^<ADD>([^#]+)[^<]+<DDA>:\1:p
b EOS


:user_redirects
    #jump from math lib back to hard-coded label
    #(the call jump, the code executed there and this return jump is how one can have reusable functions in sed)
    /##result_ap_sv<DDA>/b result_ap_sv
Q 2


:debug
	#test if GNU extensions are supported
	1v
b main


######################### MATH LIB #########################

#1+: <ADD>1 2 3#label<DDA> -> <ADD>6##label<DDA>
:add_pos
	s:(<ADD>)([0-9]+#):\10 \2:
	s: ?([0-9]+) ([0-9]+)(#[^<]+<DDA>):<DEC>\1#result_dp_ap<CED><INC>\2#result_ip_ap<CNI>\3:
	:loop_ap
		/<DEC>0/b next_ap
		b decr_pos
		:result_dp_ap
			s:#([^<]+<CED>):\1:
		b incr_pos
		:result_ip_ap
			s:#([^<]+<CNI>):\1:
	b loop_ap
	:next_ap
		/<ADD><DEC>/b print_ap
		s: ?([0-9]+)(<DEC>)0:\2\1:
	b loop_ap
	:print_ap
		s:<DEC>0#result_dp_ap<CED><INC>([0-9]+)#result_ip_ap<CNI>(#[^<]+<DDA>):\1#\2:
b redirect


#1: <DEC>10#label<CED> -> <DEC>9##label<CED>
:decr_pos
	:zeros
		s:0(@*)(#[^<]+<CED>):@\1\2:
	t zeros
	s:9(@*)(#[^<]+<CED>):8\1\2:;t print_dp
	s:8(@*)(#[^<]+<CED>):7\1\2:;t print_dp
	s:7(@*)(#[^<]+<CED>):6\1\2:;t print_dp
	s:6(@*)(#[^<]+<CED>):5\1\2:;t print_dp
	s:5(@*)(#[^<]+<CED>):4\1\2:;t print_dp
	s:4(@*)(#[^<]+<CED>):3\1\2:;t print_dp
	s:3(@*)(#[^<]+<CED>):2\1\2:;t print_dp
	s:2(@*)(#[^<]+<CED>):1\1\2:;t print_dp
	s:1(@*)(#[^<]+<CED>):0\1\2:;t print_dp
	:print_dp
		s:(<DEC>)0@:\1@:
		:loop_dp
			s:(<DEC>[^#]*)@:\19:
		/<DEC>[^#]*@/b loop_dp
		s:#[^<]+<CED>:#&:
b redirect


#1: <INC>9#label<CNI> -> <INC>10##label<CNI>
:incr_pos
	:nines
		s:9(@*)(#[^<]+<CNI>):@\1\2:
	t nines
	s:0(@*)(#[^<]+<CNI>):1\1\2:;t print_ip
	s:1(@*)(#[^<]+<CNI>):2\1\2:;t print_ip
	s:2(@*)(#[^<]+<CNI>):3\1\2:;t print_ip
	s:3(@*)(#[^<]+<CNI>):4\1\2:;t print_ip
	s:4(@*)(#[^<]+<CNI>):5\1\2:;t print_ip
	s:5(@*)(#[^<]+<CNI>):6\1\2:;t print_ip
	s:6(@*)(#[^<]+<CNI>):7\1\2:;t print_ip
	s:7(@*)(#[^<]+<CNI>):8\1\2:;t print_ip
	s:8(@*)(#[^<]+<CNI>):9\1\2:;t print_ip
	:print_ip
		s:(<INC>)@:\11@:
		:loop_ip
			s:(<INC>[^#]*)@:\10:
		/<INC>[^#]*@/b loop_ip
		s:#[^<]+<CNI>:#&:
b redirect


:redirect
	b library_redirects
	:continue_redirects
	b user_redirects


:library_redirects
	/##result_dp_ap<CED>/b result_dp_ap
	/##result_ip_ap<CNI>/b result_ip_ap
b continue_redirects


:EOS
	#End Of Script (mainly used to skip over remaining code, when needed)
