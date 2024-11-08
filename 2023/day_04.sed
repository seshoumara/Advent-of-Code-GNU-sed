#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2023, day 04
	# https://adventofcode.com/2023/day/4
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	#b scratchcard_points
	b scratchcard_copies
b EOS


:scratchcard_points
	#setup
	s/.*: +/>/
	s: +\| +:,:
	s:  +: :g
	s:$:;:
l
	#extract the matching winning numbers
	:loop
		s:>([0-9]+)\b(.*,.*)\b\1\b(.*;):>\1\2\1\3 \1:
		s:>([0-9]+[ ,]):\1>:
	/,>/!b loop
	s:.*; ?::
l
	/^$/!{
		#calculate the points (at least one matching winning number)
		s:[0-9]+:2:g
		s:^2:1:
		s:.*:<MULT>&#result_mpp_scp<TLUM>:
l
		b mult_pos
		:result_mpp_scp
			s:<MULT>([^#]+)[^<]+<TLUM>:\1:
	}
	#set 0 points if no matching winning numbers
	/^$/s:$:0:
l
	1h;1!H
	$b sum_values
b EOS


:scratchcard_copies
	#TODO
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
    /##result_mpp_scp<TLUM>/b result_mpp_scp
    /##result_ap_sv<DDA>/b result_ap_sv
Q 2


:debug
	#test if GNU extensions are supported
	1v
b main


######################### MATH LIB #########################

#1+: <SEQ>3-5,2-8,7-7#label<QES> -> <SEQ>3 4 5,2 3 4 5 6 7 8,7##label<QES>
:seq_pos
        s:<SEQ>:&,:
        b next_sp
        :loop_sp
                /,([0-9]+)<INC>\1#[^<]+<CNI>[^<]+<QES>/b next_sp
                b incr_pos
                :result_ip_sp
                        s:(<INC>)([0-9]+)#([^<]+<CNI>)([^,#]+)([^<]+<QES>):\1\2\3\4 \2\5:
        b loop_sp
        :next_sp
                s:,[0-9]+<INC>[^<]+<CNI>([^<]+<QES>):,\1:
                /,[0-9]+-[0-9]+[,#][^<]+<QES>/!b print_sp
                s:,([0-9]+)-([0-9]+)([,#][^<]+<QES>):,\2<INC>\1#result_ip_sp<CNI>\1\3:
        b loop_sp
        :print_sp
                s:(<SEQ>),([^#]+)(#[^<]+<QES>):\1\2#\3:
b redirect


#1+: <MULT>2 3 4#label<TLUM> -> <MULT>24##label<TLUM>
:mult_pos
        s:(<MULT>)([0-9]+#):\11 \2:
        :loop_mpp
                / ?\b0\b ([0-9]+)(#[^<]+<TLUM>)/{
                        s:(<MULT>)[^#]+:\1 0:
                        b print_mpp
                }
                s: ?([0-9]+) ([0-9]+)(#[^<]+<TLUM>):<ADD>\1 \2#result_ap_mpp<DDA>\3:
                s:(<ADD>)([0-9]+) ([^<]+<DDA>[^<]+<TLUM>):\1<SEQ>1-\2#result_sp_mpp<QES>\3:
                b seq_pos
                :result_sp_mpp
                        s:(<SEQ>)[0-9]+ ?([^#]*[^<]+<QES>)([0-9]+):\3 \1\2\3:
                /<SEQ>#/!b result_sp_mpp
                s: <SEQ>[^<]+<QES>[0-9]+::
                b add_pos
                :result_ap_mpp
                        s:<ADD>([^#]+)[^<]+<DDA>: \1:
        /<MULT>[0-9]+ /b loop_mpp
        :print_mpp
                s:(<MULT>) :\1:
                s:#[^<]+<TLUM>:#&:
b redirect


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
	/##result_sp_mpp<QES>/b result_sp_mpp
	/##result_ap_mpp<DDA>/b result_ap_mpp
	/##result_ip_sp<CNI>/b result_ip_sp
	/##result_dp_ap<CED>/b result_dp_ap
	/##result_ip_ap<CNI>/b result_ip_ap
b continue_redirects


:EOS
	#End Of Script (mainly used to skip over remaining code, when needed)
