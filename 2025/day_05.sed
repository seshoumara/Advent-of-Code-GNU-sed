#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2025, day 05
	# https://adventofcode.com/2025/day/5
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	x
	/-/{
		x
		b continue_m
	}
	x
	b get_all_intervals
	:continue_m
	#b part_1
	b part_2
	:print_result_m
		x
			s:.*;::
			s/.*/Total number of fresh ingredients: &/
			p
		x
		#needed to stop in part 2 after processing the ranges (skip the IDs)
		q
b EOS

:get_all_intervals
	N
	/\n$/ {
		h
		x
		s:\n:,:g
		s:$:;0:
		x
		b EOS
	}
b get_all_intervals

:part_1
p
	G
	s:\n:&#:
	:loop_p1
		#have we checked all intervals?
		/#;/{
			$! b EOS
			$ b print_result_m
		}
		s:^([0-9]+)\n#([^,]+),:\1\n<INR>\1 \2#return_inr_result_p1<RNI>,#:
		b in_range
		:return_inr_result_p1
			s:<INR>([01])##return_inr_result_p1<RNI>:\1:
		/\n0,/{
			s::\n:
			b loop_p1
		}
		#increment running total (we found a fresh ID)
		x
		s:;([0-9]+)$:;<INC>\1#return_incr_result_p1<CNI>:
		b incr_pos
		:return_incr_result_p1
			s:<INC>([0-9]+)##return_incr_result_p1<CNI>:\1:
		x
		$! b EOS
		$ b print_result_m
	b loop_p1
b EOS

:part_2
	G
	s:^.*\n(.*);.*:\1=:
	s:^:@:
	s:,:,#:
	:outer_loop_p2
p
		/@[^,]+,#=/ b clean_before_counting_p2
		:inner_loop_p2
			/#=/ b reset_p2
			#copy the range pair after =
			s:@([^,]+),.*#([^,]+),.*=:&\1,\2,:
			s:$:;:
			#a in c-d?
			s:=([0-9]+)-[0-9]+,([0-9]+-[0-9]+),;[01]*:&<INR>\1 \2#return_inr_result_1_p2<RNI>:
			b in_range
			:return_inr_result_1_p2
				s:<INR>([01])##return_inr_result_1_p2<RNI>:\1:
			#b in c-d?
			s:=[0-9]+-([0-9]+),([0-9]+-[0-9]+),;[01]*:&<INR>\1 \2#return_inr_result_2_p2<RNI>:
			b in_range
			:return_inr_result_2_p2
				s:<INR>([01])##return_inr_result_2_p2<RNI>:\1:
			#c in a-b?
			s:=([0-9]+-[0-9]+),([0-9]+)-[0-9]+,;[01]*:&<INR>\2 \1#return_inr_result_3_p2<RNI>:
			b in_range
			:return_inr_result_3_p2
				s:<INR>([01])##return_inr_result_3_p2<RNI>:\1:
			#d in a-b?
			s:=([0-9]+-[0-9]+),[0-9]+-([0-9]+),;[01]*:&<INR>\2 \1#return_inr_result_4_p2<RNI>:
			b in_range
			:return_inr_result_4_p2
				s:<INR>([01])##return_inr_result_4_p2<RNI>:\1:
			#no overlap? (3-5, 6-9)
			/;0000$/{
				s:=.*$:=:
				b shift_second_range_p2
			}
			#complete overlap? (3-5, 1-7)
			/;1100$/ {
				s:=.*$:=:
				s:#::
				#delete first interval -> (i++, reset)
				s:@[^,]+,:@:
				s:(@[^,]+,):&#:
				b outer_loop_p2
			}
			#partial overlap from left? (3-5, 1-4)
			/;1001$/{
				#need to shrink down the first interval: (d+1)-b = 5-5  -> (i*, reset)
				s:;.*$:;:
				s:-([0-9]+),;:&\1:
				s:;(.*)$:;<INC>\1#return_inc_result_pol_p2<CNI>:
				b incr_pos
				:return_inc_result_pol_p2
					s:<INC>([0-9]+)##return_inc_result_pol_p2<CNI>:\1:
				s:=[0-9]+-([0-9]+).*$:&-\1:
				#updated @ range to the new shrinked form
				s:@[^,]+(,.*)=.*;(.*):@\2\1=:
				s:#::
				s:(@[^,]+,):&#:
				b outer_loop_p2
			}
			#partial overlap from inside? (3-5, 3-4)
			/;1011$/{
				s:=.*$:=:
				#delete second interval -> (i, next)
				s:#[^,]+,:#:
				b inner_loop_p2
			}
			#partial overlap from the right? (3-5, 4-7)
			/;0110$/{
				#need to shrink down the second interval: (b+1)-d = 6-7  -> (i, next)
				s:;.*$:;:
				s:=[0-9]+-([0-9]+).*;:&\1:
				s:;(.*)$:;<INC>\1#return_inc_result_por_p2<CNI>:
				b incr_pos
				:return_inc_result_por_p2
					s:<INC>([0-9]+)##return_inc_result_por_p2<CNI>:\1:
				s:-([0-9]+)(,;.*$):&-\1:
				#update # range to the new shrinked form
				s:#[^,]+(,.*)=.*;(.*):#\2\1=:
				b shift_second_range_p2
			}
			:shift_second_range_p2
			s:=.*$:=:
			s:#([^,]+,):\1#:
		b inner_loop_p2
		:reset_p2
			s:#=:=:
			s:@([^,]+,):\1@:
			s:(@[^,]+,):&#:
	b outer_loop_p2
	:clean_before_counting_p2
		s:#=::
		s:@::
		s:^:@:
p
	:count_loop_p2
		/@$/ b print_result_m
		#swap ends (b-a) and call subtract
		s:@([0-9]+)-([0-9]+),:@<SUBp>\2 \1#return_subp_result_p2<pBUS>,:
		b sub_pos
		:return_subp_result_p2
			s:<SUBp>([0-9]+)##return_subp_result_p2<pBUS>:\1:
		#increment
		s:@([0-9]+),:@<INC>\1#return_inc_result_p2<CNI>,:
		b incr_pos
		:return_inc_result_p2
			s:<INC>([0-9]+)##return_inc_result_p2<CNI>:\1:
		#add result to running total from hold space
		x
		G
		s:\n.*@([0-9]+).*$: \1:
		s:;(.*)$:;<CADD>\1#return_cadd_result_p2<DDAC>:
		b custom_add
		:return_cadd_result_p2
			s:<CADD>([0-9]+)##return_cadd_result_p2<DDAC>:\1:
p
		x
		s:@[^,]+,:@:
	b count_loop_p2	
b EOS

:user_redirects
	/##return_incr_result_p1<CNI>/ b return_incr_result_p1
	/##return_inr_result_p1<RNI>/ b return_inr_result_p1
	
	/##return_inr_result_1_p2<RNI>/ b return_inr_result_1_p2
	/##return_inr_result_2_p2<RNI>/ b return_inr_result_2_p2
	/##return_inr_result_3_p2<RNI>/ b return_inr_result_3_p2
	/##return_inr_result_4_p2<RNI>/ b return_inr_result_4_p2
	/##return_inc_result_pol_p2<CNI>/ b return_inc_result_pol_p2
	/##return_inc_result_por_p2<CNI>/ b return_inc_result_por_p2
	/##return_subp_result_p2<pBUS>/ b return_subp_result_p2
	/##return_inc_result_p2<CNI>/ b return_inc_result_p2
	/##return_cadd_result_p2<DDAC>/ b return_cadd_result_p2
b EOS

:debug
        #test if GNU extensions are supported
        1v
b main

######################### MATH / UTILS #########################

#1+I: <INR>3 3-5#label<RNI> -> <INR>1##label<RNI>
#1+I: <INR>5 3-5#label<RNI> -> <INR>1##label<RNI>
#1+I: <INR>7 3-5#label<RNI> -> <INR>0##label<RNI>
#1+I: <INR>1 3-5#label<RNI> -> <INR>0##label<RNI>
:in_range
	#duplicate input
	s:(<INR>)([^#]+)#:\1;\2,\2#:
	#call ge on nr and range start
	s:(<INR>)(;[^,]+),([0-9]+) ([0-9]+)-[0-9]+#:\1<GE>\3 \4#return_ge_result_inr<EG>\2#:
	b ge
	:return_ge_result_inr
		s:(<INR>)<GE>([01])##return_ge_result_inr<EG>:\1\2:
	#if ge is 0, exit w/ 0
	/<INR>0;/{
		s:(<INR>0);[^#]+#:\1##:
		b redirect
	}
	s:(<INR>)1;([0-9]+) [0-9]+-([0-9]+)#:\1<LE>\2 \3#return_le_result_inr<EL>#:
	b le
	:return_le_result_inr
		s:(<INR>)<LE>([01])##return_le_result_inr<EL>:\1\2:
	s:(<INR>[01]#):&#:
b redirect


#2: <LE>3 4#label<EL> -> <LE>1##label<EL>
#2: <LE>4 3#label<EL> -> <LE>0##label<EL>
#2: <LE>3 3#label<EL> -> <LE>1##label<EL>
:le
	#nrs are equal
	/<LE>([0-9]+) \1#/ {
		s:(<LE>)[^#]+#:\11##:
		b redirect
	}
	#call GE
	s:(<LE>)([^#]+):\1<GE>\2#return_ge_result_le<EG>:
	b ge
	:return_ge_result_le
		s:<GE>([01])##return_ge_result_le<EG>:\1:
	#invert the result
	/(<LE>)0#/{
		s::\11##:
		b redirect
	}
	/(<LE>)1#/{
		s::\10##:
		b redirect
	}
b redirect

#2: <GE>3 4#label<EG> -> <GE>0##label<EG>
#2: <GE>4 3#label<EG> -> <GE>1##label<EG>
#2: <GE>3 3#label<EG> -> <GE>1##label<EG>
:ge
	#nrs are equal
	/<GE>([0-9]+) \1#/ {
		s:(<GE>)[^#]+#:\11##:
		b redirect
	}
	s:<GE>:&@:
	s:<GE>@[0-9]+ :&%:
	:is_equal_length_loop_ge
		#nrs are of equal length, can't tell yet (need the table lookup algo)
		/(<GE>[0-9]+)@( [0-9]+)%#/ {
			s::\1\2#:
			b prep_table_lookup_ge
		}
		#1st nr is smaller
		/<GE>[0-9]+@ /{
			s:(<GE>)[^#]+#:\10##:
			b redirect
		}
		#2nd nr is smaller, 1st nr is greater
		/(<GE>)[0-9@]+ [0-9]+%#/ {
			s::\11##:
			b redirect
		}
		#shift separators
		s:(<GE>[0-9]*)@([0-9]):\1\2@:
		s:(<GE>[0-9 @]*)%([0-9]):\1\2%:
	b is_equal_length_loop_ge
	:prep_table_lookup_ge
		s:#[^<]+<EG>:,9876543210&:
		s:<GE>:&@:
		s:<GE>@[0-9]+ :&%:
	:table_lookup_loop_ge
		#current digit from 1st nr is the same as current digit from 2nd nr (not decided yet)
		/<GE>[0-9]*@([0-9])[0-9 ]*%\1/{
			#shift separators
			s:(<GE>[0-9]*)@([0-9]):\1\2@:
			s:(<GE>[0-9@ ]*)%([0-9]):\1\2%:
			b table_lookup_loop_ge
		}
		#1st nr is greater
		/<GE>[0-9]*@([0-9])[0-9 ]*%([0-9])[0-9]*,[0-9]*\1[0-9]*\2[0-9]*#/{
			s:(<GE>)[^#]+#:\11##:
			b redirect
		}
		#2nd nr is greater, 1st nr is smaller
		/<GE>[0-9]*@([0-9])[0-9 ]*%([0-9])[0-9]*,[0-9]*\2[0-9]*\1[0-9]*#/{
			s:(<GE>)[^#]+#:\10##:
			b redirect
		}
	b table_lookup_loop_ge
b redirect

#1+: <CADD>1 2 3#label<DDAC> -> <CADD>6##label<DDAC>
:custom_add
	s:(<CADD>[^#]+):& :
	s:<CADD>:&, 0@0;:
	b next_cadd
	:column_loop_cadd
		#exit condition
		/<CADD>[0-9]*, <[0-9]+ <[0-9]+@/ b cleanup_cadd
		#copy the column digits to the carry pos, separated by space
		#edge case: there could be no digit in that column (I got lucky)
		s:(<CADD>[0-9]*, [0-9]*)([0-9])(<[0-9]* [0-9<]+@):&\2 :
		s:(<CADD>[0-9]*, [0-9<]+ [0-9]*)([0-9])(<[0-9]*@):&\2 :
		#call add_pos on all nrs in carry pos
		s:(<CADD>[0-9]*, [0-9<]+ [0-9<]+@)([^;]+):\1<ADD>\2#return_add_result_cadd<DDA>:
		b add_pos
		:return_add_result_cadd
			s:(<CADD>[0-9]*, [0-9<]+ [0-9<]+@)<ADD>([0-9]+)##return_add_result_cadd<DDA>:\1\2:
		#if col sum is 2 digits, 1st digit is carry, 2nd digit is the result
		/(<CADD>)([0-9]*, [0-9<]+ [0-9<]+@)([0-9])([0-9])/{
			s::\1\4\2\3:
			b shift_cadd
		}
		/(<CADD>)([0-9]*, [0-9<]+ [0-9<]+@)([0-9])/s::\1\3\20:
		:shift_cadd
		#shift both of <, edge case: if < is at start of nr don't shift
		s:(<CADD>[0-9]*, [0-9]*)([0-9])<:\1<\2:
		s:(<CADD>[0-9]*, [0-9<]+ [0-9]*)([0-9])<:\1<\2:
	b column_loop_cadd
	:cleanup_cadd
		#check if carry from last col add is != 0, put it in front of sum
		s:(<CADD>)([0-9]*, [0-9<]+ [0-9<]+@)([1-9]):\1\3\20:
		#delete the nrs, move the sum into where nrs where
		s:(<CADD>)([0-9]+),[^@]+:\1, \2:
	:next_cadd
		/(<CADD>, [0-9]+)(@0;)#/b print_cadd
		s:(<CADD>, [0-9]+)(@0;)([0-9]+) :\1< \3<\2:
	b column_loop_cadd
	:print_cadd
		#cleanup and double the #
		s:(<CADD>), ([0-9]+)@0;:\1\2#:
b redirect


#the time complexity for bubble sort is n^2, which for 800 nrs the runtime is practically weeks!!
#Can this be optimized more?? A: yes, implement merge sort, but figure out how to do recursion in sed first!!
#2+ <SORT>2 100 2345 22#label<TROS> -> <SORT>2 22 100 2345##label<TROS>
:custom_sort
        /<SORT>[0-9]+#/b redirect
        s:<SORT>:&,:
        s:<SORT>[^#]*:& :
        :outer_loop_cs
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
		#unfortunately, this is also super super super slow on 10^9-10^12 !!!!

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

#this was put from a newer lib into this older lib, thus modified (ignore it for lib versioning)
	# be careful when copying methods between different versions of the lib!!!
#1-2: <SUBp>9 14#label<pBUS> -> <SUBp>-5##label<pBUS>
#1-2: <SUBp>14 9#label<pBUS> -> <SUBp>5##label<pBUS>
:sub_pos
    /<SUBp>[0-9]+#/b print_subp
    :loop_subp
        /<SUBp>((0 )|([0-9]+ 0))/{
            s:(<SUBp>)([0-9]+) 0:\1\2:
            s:(<SUBp>)0 ([0-9]+):\1-\2:
            b print_subp
        }
        s:(<SUBp>)([0-9]+):\1<DEC>\2#result_dp_subp_1<CED>:
        b decr_pos
        :result_dp_subp_1
            s:<DEC>([0-9]+)[^<]+<CED>:\1:
        s:(<SUBp>[0-9]+ )([0-9]+):\1<DEC>\2#result_dp_subp_2<CED>:
        b decr_pos
        :result_dp_subp_2
            s:<DEC>([0-9]+)[^<]+<CED>:\1:
    b loop_subp
    :print_subp
        s:#[^<]+<pBUS>:#&:
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

	/##result_dp_subp_1<CED>/b result_dp_subp_1
    	/##result_dp_subp_2<CED>/b result_dp_subp_2
	/##return_add_result_cadd<DDA>/ b return_add_result_cadd
	/##return_ge_result_le<EG>/ b return_ge_result_le
	/##return_ge_result_inr<EG>/ b return_ge_result_inr
	/##return_le_result_inr<EL>/ b return_le_result_inr
b continue_redirects


:EOS
	#End Of Script (mainly used to skip over remaining code, when needed)
