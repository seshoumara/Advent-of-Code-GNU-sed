#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2022, day 04
	# https://adventofcode.com/2022/day/4
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	b total_subsets
	#b total_overlaps
b EOS


:total_subsets
	s:.*:<SEQ>&#result_sp_ts<QES>:p
	b seq_pos
	:result_sp_ts
		s:<SEQ>([^#]+)[^<]+<QES>:\1<SUBSET>\1#result_ssp_ts1<TESBUS>:p
	b subset_pos
	:result_ssp_ts1
		s:([^,]+),([^<]+)(<SUBSET>)([01])[^<]+(<TESBUS>):\3\2,\1#result_ssp_ts2\5\4:p
	b subset_pos
	:result_ssp_ts2
		s:<SUBSET>([01])[^<]+<TESBUS>:\1:p
	s:00:0:
	s:01:1:
	s:1.:1:
	H
	$b total_pairs
b EOS


:total_overlaps
	s:.*:<SEQ>&#result_sp_to<QES>:p
	b seq_pos
	:result_sp_to
		s:<SEQ>([^#]+)[^<]+<QES>:<INTERSECTION>\1#result_isp_to<NOITCESRETNI>:p
	b intersection_pos
	:result_isp_to
		s:<INTERSECTION>([01])[^<]+<NOITCESRETNI>:\1:
	H;p
	$b total_pairs
b EOS


:total_pairs
	x
	y:\n: :
	s:^ (.*):<ADD>\1#result_ap_tp<DDA>:p
	b add_pos
	:result_ap_tp
		s:^<ADD>([0-9]+)[^<]+<DDA>$:\1:p
b EOS


:user_redirects
	/##result_sp_ts<QES>/b result_sp_ts
	/##result_ssp_ts1<TESBUS>/b result_ssp_ts1
	/##result_ssp_ts2<TESBUS>/b result_ssp_ts2
	/##result_sp_to<QES>/b result_sp_to
	/##result_isp_to<NOITCESRETNI>/b result_isp_to
	/##result_ap_tp<DDA>/b result_ap_tp
b EOS


:debug
	#test if GNU extensions are supported
	1v
b main


######################### MATH / UTILS #########################

#2: <INTERSECTION>3 4 5,2 3 4 5 6 7 8#label<NOITCESRETNI> -> <INTERSECTION>1##label<NOITCESRETNI>
:intersection_pos
	s:(<INTERSECTION>)([^,]+):\1!\2 :
	:loop_isp
		/<INTERSECTION>[^!]+!,/{
			s:(<INTERSECTION>)[^#]+:\10:
			b print_isp
		}
		/<INTERSECTION>[^!]*!([0-9]+) [^,]*,[^#]*\b\1\b/{
			s:(<INTERSECTION>)[^#]+:\11:
			b print_isp
		}
		s:(<INTERSECTION>[^!]*)!([0-9]+ ):\1\2!:
	b loop_isp
	:print_isp
		s:#[^<]+<NOITCESRETNI>:#&:
b redirect


#2: <SUBSET>3 4 5,2 3 4 5 6 7 8#label<TESBUS> -> <SUBSET>1##label<TESBUS>
:subset_pos
	s:(<SUBSET>)([^,]+):\1!\2 :
	:loop_ssp
		/<SUBSET>[^!]+!,/{
			s:(<SUBSET>)[^#]+:\11:
			b print_ssp
		}
		/<SUBSET>[^!]*!([0-9]+) [^,]*,[^#]*\b\1\b/{
			s:(<SUBSET>[^!]*)!([0-9]+ ):\1\2!:
			b loop_ssp
		}
	s:(<SUBSET>)[^#]+:\10:
	:print_ssp
		s:#[^<]+<TESBUS>:#&:
b redirect


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


#1+: <MAX>1 2 3#label<XAM> -> <MAX>3##label<XAM>
:max_pos
	s:(<MAX>)([0-9]+#):\10 \2:
	s: ?([0-9]+) ([0-9]+)(#[^<]+<XAM>):A\1,\1B\2,\2M\2\3:
	:loop_mp
		/,0[BM][^<]+<XAM>/b next_mp
		s:,([0-9]+)(B[^<]+<XAM>):,<DEC>\1#result_dp_mp1<CED>\2:
		b decr_pos
		:result_dp_mp1
			s:,<DEC>([0-9]+)#[^<]+<CED>(B[^<]+<XAM>):,\1\2:
		s:,([0-9]+)(M[^<]+<XAM>):,<DEC>\1#result_dp_mp2<CED>\2:
		b decr_pos
		:result_dp_mp2
			s:,<DEC>([0-9]+)#[^<]+<CED>(M[^<]+<XAM>):,\1\2:
	b loop_mp
	:next_mp
		s:A([0-9]+),[1-9][0-9]*B[0-9]+,0M[0-9]+([^<]+<XAM>):A0,0B0,0M\1\2:
		/<MAX>A/b print_mp
		s:B[0-9]+,[0-9]+M([0-9]+)([^<]+<XAM>):B\1,\1M\1\2:
		s: ?([0-9]+)A[0-9]+,[0-9]+:A\1,\1:
	b loop_mp
	:print_mp
		s:A[0-9]+,[0-9]+B[0-9]+,[0-9]+M([0-9]+):\1:
		s:#[^<]+<XAM>:#&:
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
	/##result_dp_ap<CED>/b result_dp_ap
	/##result_dp_mp1<CED>/b result_dp_mp1
	/##result_dp_mp2<CED>/b result_dp_mp2
	/##result_ip_ap<CNI>/b result_ip_ap
	/##result_ip_sp<CNI>/b result_ip_sp
b continue_redirects


:EOS
	#End Of Script (mainly used to skip over remaining code, when needed)
