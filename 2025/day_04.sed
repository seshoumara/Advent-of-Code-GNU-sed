#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2025, day 04
	# https://adventofcode.com/2025/day/4
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	b read_file
	:continue_m
		x
		s:.*:0:
		x
	b part_1
	#b part_2
	:print_result
		x
		s/.*/Rolls of paper that can be accessed is: &/
		p
		x
b EOS

:read_file
	$ b continue_m
	$!N
b read_file

:gen_adjacent_chars
	s:([.@]):&<>:g
	s:^:;:
	s:^[^\n]+\n:&,:
#p
	:loop_UD_gac
		/[;,]$/b del_sep_2_gac
		#cell next to ; put as neigh. to cell next to ,
		s:;(.)[^\n]*\n.*,.<:&\1:
		#cell next to ; put as neigh. to cell next to the cell next to ,
		s:;(.)[^\n]*\n.*,.<[.@]*>.<:&\1:
		#cell next to ; put as neigh. to cell before the cell next to ,
		s:;(.)([^\n]*\n.*.<)([.@]*>,):;\1\2\1\3:
		
		#cell next to , put as neigh. to cell next to ;
		s:(;.<)([.@]*>[^\n]*\n.*,)(.):\1\3\2\3:
		#cell next to , put as neigh. to cell next to the cell next to ;
		s:(;.<[.@]*>.<)([.@]*>[^\n]*\n.*,)(.):\1\3\2\3:
		#cell next to , put as neigh. to cell before the cell before ;
#l
		s:(.<)([.@]*>;[^\n]*\n.*,)(.):\1\3\2\3:
#l
		#shift ; and , by one cell
		s:;(.<[.@]*>):\1;:
		s:,(.<[.@]*>):\1,:
		#if both are at end of their respective line (reset):
		/;\n(.*),\n/ {
			# move ; to next line after , changed to ,
			# move , at the beginning of its line, changed to ;
			s::\n;\1\n,:
		}
#=;p
	b loop_UD_gac
	:del_sep_2_gac
		s:[;,]::g
	s:^:#:
#p
	:loop_LR_gac
		/#$/ b del_sep_1_gac
		s:#(.)(<[.@]*>.<):&\1:
		s:>#(.):\1>#\1:
		s:#(.<[.@]*>):\1#:
		s:#\n:\n#:
#=;p
	b loop_LR_gac
	:del_sep_1_gac
		s:#$::g
p
b continue_p1

:part_1
	b gen_adjacent_chars
	:continue_p1
	s:^:#:
	:loop_p1
		/#$/ b print_result
		/#(\.<[.@]*>)/{
			s::\1#:
			s:#\n:\n#:
#=;p
			b loop_p1
		}
		#check how many @s are in the 8 neighbours of this pos!
		/#@/{
#=;p
			#delete .s in the list
			:delete_dots
				/#@<@*>/ b done_deleting_p1
				s:(#@<@*)\.:\1:
			b delete_dots
			:done_deleting_p1
#p
			/#@<@{0,3}>/{
				x
				s:.*:<INC>&#return_inc_result_p1<CNI>:
				b incr_pos
				:return_inc_result_p1
					s:<INC>([0-9]+)##return_inc_result_p1<CNI>:\1:
p
				x
			}
			s:#(@<@*>):\1#:
			s:#\n:\n#:
#p
		}
	b loop_p1
b EOS

:part_2
	#TODO
b EOS

:user_redirects
	/##return_inc_result_p1<CNI>/ b return_inc_result_p1
b EOS

:debug
        #test if GNU extensions are supported
        1v
b main


######################### MATH / UTILS #########################

#1+: <CADD>1 2 3#label<DDAC> -> <CADD>6##label<DDAC>
:custom_add
	s:(<CADD>[^#]+):& :
	s:<CADD>:&, 0@0;:
	b next_cadd
	:column_loop_cadd
#=;p
		#exit condition
		/<CADD>[0-9]*, <[0-9]+ <[0-9]+@/ b cleanup_cadd
		#copy the column digits to the carry pos, separated by space
		#edge case: there could be no digit in that column (I got lucky)
		s:(<CADD>[0-9]*, [0-9]*)([0-9])(<[0-9]* [0-9<]+@):&\2 :
		s:(<CADD>[0-9]*, [0-9<]+ [0-9]*)([0-9])(<[0-9]*@):&\2 :
#p
		#call add_pos on all nrs in carry pos
		s:(<CADD>[0-9]*, [0-9<]+ [0-9<]+@)([^;]+):\1<ADD>\2#return_add_result_cadd<DDA>:
#p
		b add_pos
		:return_add_result_cadd
			s:(<CADD>[0-9]*, [0-9<]+ [0-9<]+@)<ADD>([0-9]+)##return_add_result_cadd<DDA>:\1\2:
		#if col sum is 2 digits, 1st digit is carry, 2nd digit is the result
#p
		/(<CADD>)([0-9]*, [0-9<]+ [0-9<]+@)([0-9])([0-9])/{
			s::\1\4\2\3:
			b shift_cadd
		}
		/(<CADD>)([0-9]*, [0-9<]+ [0-9<]+@)([0-9])/s::\1\3\20:
		:shift_cadd
		#shift both of <, edge case: if < is at start of nr don't shift
		s:(<CADD>[0-9]*, [0-9]*)([0-9])<:\1<\2:
		s:(<CADD>[0-9]*, [0-9<]+ [0-9]*)([0-9])<:\1<\2:
#p
	b column_loop_cadd
	:cleanup_cadd
		#check if carry from last col add is != 0, put it in front of sum
		s:(<CADD>)([0-9]*, [0-9<]+ [0-9<]+@)([1-9]):\1\3\20:
		#delete the nrs, move the sum into where nrs where
		s:(<CADD>)([0-9]+),[^@]+:\1, \2:
p
	:next_cadd
		/(<CADD>, [0-9]+)(@0;)#/b print
		s:(<CADD>, [0-9]+)(@0;)([0-9]+) :\1< \3<\2:
#p
	b column_loop_cadd
	:print
		#cleanup and double the #
		s:(<CADD>), ([0-9]+)@0;:\1\2#:
#p
b redirect

#the time complexity for bubble sort is n^2, which for 800 nrs the runtime is practically weeks!! Can this be optimized more??
#2+ <SORT>2 100 2345 22#label<TROS> -> <SORT>2 22 100 2345##label<TROS>
:custom_sort
        /<SORT>[0-9]+#/b redirect
        s:<SORT>:&,:
        s:<SORT>[^#]*:& :
        :outer_loop_cs
=
                :inner_loop_cs
                        /;([0-9]+) #[^<]+<TROS>/ b reset_cs
                        /,([0-9]+) #[^<]+<TROS>/ b print_cs
                        s:<SORT>[^#]*[,;]:&@:
                        s:(<SORT>[^#]*[,;]@[0-9]+) :\1 @:
                        :size_comp_loop_cs
                                s:(<SORT>[^@]+)@([0-9]):\1\2@:
                                s:(<SORT>[^#]+)@([0-9]):\1\2@:
                                /(<SORT>[^@]+)@ / {
                                        s:(<SORT>[^@]+)@:\1:
                                        s:(<SORT>[^@]+)@:\1:
                                        b shift_cs
                                }
                                /(<SORT>[^#]+)@ /{
                                        s:(<SORT>[^@]+)@:\1:
                                        s:(<SORT>[^@]+)@:\1:
                                        s:(<SORT>[^#]*[,;])([0-9]+) ([0-9]+):\1\3 \2:
                                        s:(<SORT>[^#]*),:\1;:
                                        b shift_cs
                                }
                        b size_comp_loop_cs
                        :shift_cs
                                s:(<SORT>[^#]*)([,;])([0-9]+) ([0-9]+):\1\3 \2\4:
                b inner_loop_cs
                :reset_cs
                        s:;([0-9]+ #[^<]+<TROS>):\1:
                        s:<SORT>:&,:
        b outer_loop_cs
        :print_cs
                s:,([0-9]+) (#[^<]+<TROS>):\1#\2:
b redirect


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



#NOTICE: generating all interval numbers at once is super super super slow. DON'T USE THIS FUNCTION!!!
#have your own loop which calls increment on start/current value, do something with it (DO NOT STORE IT) and continue the loop
#DOING THAT MAKES IT RELATIVELY INSTANT!!!
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
	/##return_add_result_cadd<DDA>/ b return_add_result_cadd
b continue_redirects


:EOS
	#End Of Script (mainly used to skip over remaining code, when needed)
