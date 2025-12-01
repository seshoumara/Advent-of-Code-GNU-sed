#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2024, day 01
	# https://adventofcode.com/2024/day/1
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


:main
    #test if GNU extensions are supported
	1v
    b parse_input
    :continue_main
        x;h
	b part1
	#b part2
b EOS

:parse_input
    1h;1!H
    x
    1s: +:,:
    1!s:^([^,]+),([^\n]+)\n([^ ]+) +(.*)$:\1 \3,\2 \4:
    x
    $b continue_main
b EOS

:part1
    s:^(.*)(,.*)$:<SORT>\1#result_sort_p1_1<TROS>\2:
    b sort
    :result_sort_p1_1
        s:<SORT>([^#]+)[^<]+<TROS>:\1:
    s:^(.*,)(.*)$:\1<SORT>\2#result_sort_p1_2<TROS>:
    b sort
    :result_sort_p1_2
        s:<SORT>([^#]+)[^<]+<TROS>:\1:
l;Q
    :loop_p1
        #pick pair
        #save subtraction (abs value)
        s:\n-:\n:
        H#saves the bla,bla too
    /^,$/!b loop_p1
    b sum_values
b EOS

:part2
    #TODO
    $b sum_values
b EOS

:sum_values
    x
    s:\n: :g
    s:.*:<ADD>&#result_a_sv<DDA>:
l
    b add
    :result_a_sv
        s:^<ADD>([^#]+)[^<]+<DDA>:\1:p
b EOS

#flag-dependent user callbacks
:user_redirects
    /##result_sort_p1_1<TROS>/b result_sort_p1_1
    /##result_sort_p1_2<TROS>/b result_sort_p1_2
    /##result_a_sv<DDA>/b result_a_sv
Q 2

######################### MATH LIB #########################

#1+: <SORT>9 14 0 -8 -16#label<TROS> -> <SORT>-16 -8 0 9 14##label<TROS>
:sort
    s:<SORT>:&, :
    :loop_sort
        /,#[^<]+<TROS>/b print_sort
        s:(<SORT>[^,]*, )([^#]+)(#[^<]+<TROS>):\1<MIN>\2#result_m_sort<NIM>\2\3:
        b min
        :result_m_sort
            s:, <MIN>(-?[0-9]+)[^<]+<NIM>: \1, :
        s: (-?[0-9]+)(,.*) \1\b([^<]+<TROS>): \1\2\3:
    b loop_sort
    :print_sort
        s:(<SORT>) ?:\1:
        s:,(#[^<]+<TROS>):#\1:
b redirect

#1-2: <SUB>14 9#label<BUS> -> <SUB>5##label<BUS>
#1-2: <SUB>-14 9#label<BUS> -> <SUB>-23##label<BUS>
#1-2: <SUB>0 -9#label<BUS> -> <SUB>9##label<BUS>
#1-2: <SUB>-14 -9#label<BUS> -> <SUB>-5##label<BUS>
:sub
	s:<SUB>-?[0-9]+:&;:
    b next_s
    :loop_s
        /(<SUB>)-([0-9]+) -([0-9]+);/{
            s::\1<SUBp>\3 \2#result_sp_s_1<pBUS>;:
            b sub_pos
            :result_sp_s_1
                s:<SUBp>(-?[0-9]+)[^<]+<pBUS>:\1:
            b next_s
        }
        /(<SUB>)-([0-9]+) ([0-9]+);/{
            s::\1<ADDp>\2 \3#result_ap_s_1<pDDA>;:
            b add_pos
            :result_ap_s_1
                s:<ADDp>([0-9]+)[^<]+<pDDA>:-\1:
            b next_s
        }
        /(<SUB>)([0-9]+) -([0-9]+);/{
            s::\1<ADDp>\2 \3#result_ap_s_2<pDDA>;:
            b add_pos
            :result_ap_s_2
                s:<ADDp>([0-9]+)[^<]+<pDDA>:\1:
            b next_s
        }
        s:(<SUB>)([0-9]+) ([0-9]+);:\1<SUBp>\2 \3#result_sp_s_2<pBUS>;:
        b sub_pos
        :result_sp_s_2
            s:<SUBp>(-?[0-9]+)[^<]+<pBUS>:\1:
    :next_s
        /;#[^<]+<BUS>/b print_s
        s:(<SUB>[^;]+);( -?[0-9]+):\1\2;:
    b loop_s
    :print_s
        s:;(#[^<]+<BUS>):#\1:
b redirect

#1+: <ADD>9 14 0 -8 -16#label<DDA> -> <ADD>-1##label<DDA>
:add
	s:<ADD>-?[0-9]+:&;:
    b next_a
    :loop_a
        /(<ADD>)-([0-9]+) -([0-9]+);/{
            s::\1<ADDp>\2 \3#result_ap_a_1<pDDA>;:
            b add_pos
            :result_ap_a_1
                s:<ADDp>([0-9]+)[^<]+<pDDA>:-\1:
            b next_a
        }
        /(<ADD>)-([0-9]+) ([0-9]+);/{
            s::\1<SUBp>\3 \2#result_sp_a_1<pBUS>;:
            b sub_pos
            :result_sp_a_1
                s:<SUBp>(-?[0-9]+)[^<]+<pBUS>:\1:
            b next_a
        }
        /(<ADD>)([0-9]+) -([0-9]+);/{
            s::\1<SUBp>\2 \3#result_sp_a_2<pBUS>;:
            b sub_pos
            :result_sp_a_2
                s:<SUBp>(-?[0-9]+)[^<]+<pBUS>:\1:
            b next_a
        }
        s:(<ADD>)([0-9]+) ([0-9]+);:\1<ADDp>\2 \3#result_ap_a_2<pDDA>;:
        b add_pos
        :result_ap_a_2
            s:<ADDp>([0-9]+)[^<]+<pDDA>:\1:
    :next_a
        /;#[^<]+<DDA>/b print_a
        s:(<ADD>[^;]+);( -?[0-9]+):\1\2;:
    b loop_a
    :print_a
        s:;(#[^<]+<DDA>):#\1:
b redirect

#1+: <MIN>110 34 0 -34 -110#label<NIM> -> <MIN>-110##label<NIM>
:min
    s:<MIN>-?[0-9]+:&;:
    b next_m
    :loop_m
        /(<MIN>)-([0-9]+) -([0-9]+);/{
            s::\1<MAXp>\2 \3#result_Mp_m<pXAM>;:
            b max_pos
            :result_Mp_m
                s:<MAXp>([0-9]+)[^<]+<pXAM>:-\1:
            b next_m
        }
        /(<MIN>)(-[0-9]+) ([0-9]+);/{
            s::\1\2;:
            b next_m
        }
        /(<MIN>)([0-9]+) (-[0-9]+);/{
            s::\1\3;:
            b next_m
        }
        s:(<MIN>)([0-9]+) ([0-9]+);:\1<MINp>\2 \3#result_mp_m<pNIM>;:
        b min_pos
        :result_mp_m
            s:<MINp>([0-9]+)[^<]+<pNIM>:\1:
    :next_m
        /;#[^<]+<NIM>/b print_m
        s:(<MIN>[^;]+);( -?[0-9]+):\1\2;:
    b loop_m
    :print_m
        s:;(#[^<]+<NIM>):#\1:
b redirect

#1+: <MIN>110 34 0 -34 -110#label<NIM> -> <MIN>-110##label<NIM>
:min
    #TODO
b redirect

######################### BASE LIB #########################

#1-2: <SUBp>9 14#label<pBUS> -> <SUBp>-5##label<pBUS>
#1-2: <SUBp>14 9#label<pBUS> -> <SUBp>5##label<pBUS>
:sub_pos
    /<SUBp>[0-9]+#/b print_sp
    :loop_sp
        /<SUBp>((0 )|([0-9]+ 0))/{
            s:(<SUBp>)([0-9]+) 0:\1\2:
            s:(<SUBp>)0 ([0-9]+):\1-\2:
            b print_sp
        }
        s:(<SUBp>)([0-9]+):\1<DECp>\2#result_dp_sp_1<pCED>:
        b decr_pos
        :result_dp_sp_1
            s:<DECp>([0-9]+)[^<]+<pCED>:\1:
        s:(<SUBp>[0-9]+ )([0-9]+):\1<DECp>\2#result_dp_sp_2<pCED>:
        b decr_pos
        :result_dp_sp_2
            s:<DECp>([0-9]+)[^<]+<pCED>:\1:
    b loop_sp
    :print_sp
        s:#[^<]+<pBUS>:#&:
b redirect

#1-2: <ADDp>9 14#label<pDDA> -> <ADDp>23##label<pDDA>
:add_pos
    /<ADDp>[0-9]+#/b print_ap
    :loop_ap
        /<ADDp>0/{
            s:(<ADDp>)0 :\1:
            b print_ap
        }
        s:(<ADDp>)([0-9]+):\1<DECp>\2#result_dp_ap<pCED>:
        b decr_pos
        :result_dp_ap
            s:<DECp>([0-9]+)[^<]+<pCED>:\1:
        s:(<ADDp>[0-9]+ )([0-9]+):\1<INCp>\2#result_ip_ap<pCNI>:
        b incr_pos
        :result_ip_ap
            s:<INCp>([0-9]+)[^<]+<pCNI>:\1:
    b loop_ap
    :print_ap
        s:#[^<]+<pDDA>:#&:
b redirect

#1-2: <MAXp>110 34#label<pXAM> -> <MAXp>110##label<pXAM>
:max_pos
    /(<MAXp>)([0-9]+)#/{
        s::\1A\2,0B\2,0M\2#:
        b print_Mp
    }
    s:(<MAXp>)([0-9]+) ([0-9]+):\1A\2,\2B\3,\3M\3:
    :loop_Mp
        /,0[BM][^<]+<pXAM>/{
            s:(<MAXp>)A([0-9]+),[1-9][0-9]*B[0-9]+,0M[0-9]+:\1A0,0B0,0M\2:
            b print_Mp
        }
        s:,([0-9]+)(B[^<]+<pXAM>):,<DECp>\1#result_dp_Mp_1<pCED>\2:
        b decr_pos
        :result_dp_Mp_1
            s:,<DECp>([0-9]+)#[^<]+<pCED>(B[^<]+<pXAM>):,\1\2:
        s:,([0-9]+)(M[^<]+<pXAM>):,<DECp>\1#result_dp_Mp_2<pCED>\2:
        b decr_pos
        :result_dp_Mp_2
            s:,<DECp>([0-9]+)#[^<]+<pCED>(M[^<]+<pXAM>):,\1\2:
    b loop_Mp
    :print_Mp
        s:(<MAXp>)A[0-9]+,[0-9]+B[0-9]+,[0-9]+M([0-9]+):\1\2:
        s:#[^<]+<pXAM>:#&:
b redirect

#1-2: <MINp>110 34#label<pNIM> -> <MINp>34##label<pNIM>
:min_pos
    /(<MINp>)([0-9]+)#/{
        s::\1A\2,0B\2,0m\2#:
        b print_mp
    }
    s:(<MINp>)([0-9]+) ([0-9]+):\1A\2,\2B\3,\3m\3:
    :loop_mp
        /,0[Bm][^<]+<pNIM>/{
            s:(<MINp>)A([0-9]+),0B[0-9]+,[1-9][0-9]*m[0-9]+:\1A0,0B0,0m\2:
            b print_mp
        }
        s:,([0-9]+)(B[^<]+<pNIM>):,<DECp>\1#result_dp_mp_1<pCED>\2:
        b decr_pos
        :result_dp_mp_1
            s:,<DECp>([0-9]+)#[^<]+<pCED>(B[^<]+<pNIM>):,\1\2:
        s:,([0-9]+)(m[^<]+<pNIM>):,<DECp>\1#result_dp_mp_2<pCED>\2:
        b decr_pos
        :result_dp_mp_2
            s:,<DECp>([0-9]+)#[^<]+<pCED>(m[^<]+<pNIM>):,\1\2:
    b loop_mp
    :print_mp
        s:(<MINp>)A[0-9]+,[0-9]+B[0-9]+,[0-9]+m([0-9]+):\1\2:
        s:#[^<]+<pNIM>:#&:
b redirect

#1: <DECp>10#label<pCED> -> <DECp>9##label<pCED>
#1: <DECp>0#label<pCED> -> <DECp>-1##label<pCED>
:decr_pos
	:zeros_dp
		s:0(@*)(#[^<]+<pCED>):@\1\2:
	t zeros_dp
	s:9(@*)(#[^<]+<pCED>):8\1\2:;t print_dp
	s:8(@*)(#[^<]+<pCED>):7\1\2:;t print_dp
	s:7(@*)(#[^<]+<pCED>):6\1\2:;t print_dp
	s:6(@*)(#[^<]+<pCED>):5\1\2:;t print_dp
	s:5(@*)(#[^<]+<pCED>):4\1\2:;t print_dp
	s:4(@*)(#[^<]+<pCED>):3\1\2:;t print_dp
	s:3(@*)(#[^<]+<pCED>):2\1\2:;t print_dp
	s:2(@*)(#[^<]+<pCED>):1\1\2:;t print_dp
	s:1(@*)(#[^<]+<pCED>):0\1\2:;t print_dp
	:print_dp
        s:(<DECp>)@#:\1-1#:
		s:(<DECp>)0@:\1@:
		:loop_dp
			s:(<DECp>[^#]*)@:\19:
		/<DECp>[^#]*@/b loop_dp
		s:#[^<]+<pCED>:#&:
b redirect

#1: <INCp>9#label<pCNI> -> <INCp>10##label<pCNI>
:incr_pos
	:nines_ip
		s:9(@*)(#[^<]+<pCNI>):@\1\2:
	t nines_ip
	s:0(@*)(#[^<]+<pCNI>):1\1\2:;t print_ip
	s:1(@*)(#[^<]+<pCNI>):2\1\2:;t print_ip
	s:2(@*)(#[^<]+<pCNI>):3\1\2:;t print_ip
	s:3(@*)(#[^<]+<pCNI>):4\1\2:;t print_ip
	s:4(@*)(#[^<]+<pCNI>):5\1\2:;t print_ip
	s:5(@*)(#[^<]+<pCNI>):6\1\2:;t print_ip
	s:6(@*)(#[^<]+<pCNI>):7\1\2:;t print_ip
	s:7(@*)(#[^<]+<pCNI>):8\1\2:;t print_ip
	s:8(@*)(#[^<]+<pCNI>):9\1\2:;t print_ip
	:print_ip
		s:(<INCp>)@:\11@:
		:loop_ip
			s:(<INCp>[^#]*)@:\10:
		/<INCp>[^#]*@/b loop_ip
		s:#[^<]+<pCNI>:#&:
b redirect

######################### flag-dependent math lib callbacks #########################

:redirect
    b base_lib_redirects
    :continue_redirects_1
	b math_lib_redirects
	:continue_redirects_2
	b user_redirects

:base_lib_redirects
    /##result_dp_mp_1<pCED>/b result_dp_mp_1
    /##result_dp_mp_2<pCED>/b result_dp_mp_2
    /##result_dp_Mp_1<pCED>/b result_dp_Mp_1
    /##result_dp_Mp_2<pCED>/b result_dp_Mp_2
    /##result_dp_ap<pCED>/b result_dp_ap
    /##result_ip_ap<pCNI>/b result_ip_ap
    /##result_dp_sp_1<pCED>/b result_dp_sp_1
    /##result_dp_sp_2<pCED>/b result_dp_sp_2
b continue_redirects_1

:math_lib_redirects
    /##result_m_sort<NIM>/b result_m_sort
    /##result_Mp_m<pXAM>/b result_Mp_m
	/##result_mp_m<pNIM>/b result_mp_m
    /##result_ap_a_1<pDDA>/b result_ap_a_1
    /##result_ap_a_2<pDDA>/b result_ap_a_2
    /##result_sp_a_1<pBUS>/b result_sp_a_1
    /##result_sp_a_2<pBUS>/b result_sp_a_2
    /##result_ap_s_1<pDDA>/b result_ap_s_1
    /##result_ap_s_2<pDDA>/b result_ap_s_2
    /##result_sp_s_1<pBUS>/b result_sp_s_1
    /##result_sp_s_2<pBUS>/b result_sp_s_2
b continue_redirects_2

:EOS
	#mainly used to skip over remaining code, when needed
