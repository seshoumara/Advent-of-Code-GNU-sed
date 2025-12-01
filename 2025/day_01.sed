#!/usr/bin/sed -nrf

:_Problem
	# Advent of Code, 2025, day 01
	# https://adventofcode.com/2025/day/1
:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	# init
	x
	1s:.*:0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 >50 :
	1s:$:51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99,0:
	x
	#b count_0_positions_part_1
	b count_0_positions_part_2
	:print_result
		x
		s/.*,/The password is: /
		p
		x
b EOS

:count_0_positions_part_1
	/^L/{
		s:^L(.*):\1;:
		G
		s:,.*$::
		s:;\n:;:
		:left_rotation_loop_p1
			/^0;/b save_tape_p1
			/>0/{
				s:>0:0:
				s:99$:>&:
				b before_decr_1_p1
			}
			s:([0-9]+) >:>\1 :
			:before_decr_1_p1
			s:^(.*);:<DECp>\1#return_decr_result_1_p1<pCED>;:
			b decr_pos
			:return_decr_result_1_p1
				s:<DECp>([0-9]+)##return_decr_result_1_p1<pCED>:\1:
		b left_rotation_loop_p1
	}
	/^R/{
		s:^R(.*):\1;:
                G
                s:,.*$::
		s:;\n:;:
                :right_rotation_loop_p1
                        /^0;/b save_tape_p1
                        />99$/{
				s:>99$:99:
                                s:;0:;>0:
                                b before_decr_2_p1
                        }
                        s:>([0-9]+) ([0-9]+):\1 >\2:
                        :before_decr_2_p1
                        s:^(.*);:<DECp>\1#return_decr_result_2_p1<pCED>;:
                        b decr_pos
                        :return_decr_result_2_p1
				s:<DECp>([0-9]+)##return_decr_result_2_p1<pCED>:\1:
                b right_rotation_loop_p1
	}
	:save_tape_p1
		s:^0;::
		x
		s:.*,:,:
		G
		s:,(.*)\n(.*):\2,\1:
		x
	:check_if_pos_0_p1
		/>0/{
			x
			s:,(.*):,<INCp>\1#return_incr_result_p1<pCNI>:
			b incr_pos
			:return_incr_result_p1
				s:<INCp>([0-9]+)##return_incr_result_p1<pCNI>:\1:
			x
		}
		$ b print_result
		$! b EOS
b EOS

:count_0_positions_part_2
	/^L/{
		s:^L(.*):\1;:
		G
		s:,.*$::
		s:;\n:;:
		:left_rotation_loop_p2
			/^0;/b save_tape_p2
			/>0/{
				s:>0:0:
				s:99$:>&:
				b check_if_pos_zero_1_p2
			}
			s:([0-9]+) >:>\1 :
			:check_if_pos_zero_1_p2
                		/>0/{
                        		x
                        		s:,(.*):,<INCp>\1#return_incr_result_1_p2<pCNI>:
                        		b incr_pos
                        		:return_incr_result_1_p2
                                		s:<INCp>([0-9]+)##return_incr_result_1_p2<pCNI>:\1:
                        		x
                		}
			s:^(.*);:<DECp>\1#return_decr_result_1_p2<pCED>;:
			b decr_pos
			:return_decr_result_1_p2
				s:<DECp>([0-9]+)##return_decr_result_1_p2<pCED>:\1:
		b left_rotation_loop_p2
	}
	/^R/{
		s:^R(.*):\1;:
                G
                s:,.*$::
		s:;\n:;:
                :right_rotation_loop_p2
                        /^0;/b save_tape_p2
                        />99$/{
				s:>99$:99:
                                s:;0:;>0:
                                b check_if_pos_zero_2_p2
                        }
                        s:>([0-9]+) ([0-9]+):\1 >\2:
			:check_if_pos_zero_2_p2
                		/>0/{
                        		x
                        		s:,(.*):,<INCp>\1#return_incr_result_2_p2<pCNI>:
                        		b incr_pos
                        		:return_incr_result_2_p2
                                		s:<INCp>([0-9]+)##return_incr_result_2_p2<pCNI>:\1:
                        		x
                		}
                        s:^(.*);:<DECp>\1#return_decr_result_2_p2<pCED>;:
                        b decr_pos
                        :return_decr_result_2_p2
				s:<DECp>([0-9]+)##return_decr_result_2_p2<pCED>:\1:
                b right_rotation_loop_p2
	}
	:save_tape_p2
		s:^0;::
		x
		s:.*,:,:
		G
		s:,(.*)\n(.*):\2,\1:
		x
	$ b print_result
	$! b EOS
b EOS

:user_redirects
	/##return_decr_result_1_p1<pCED>/ b return_decr_result_1_p1
	/##return_decr_result_2_p1<pCED>/ b return_decr_result_2_p1
	/##return_incr_result_p1<pCNI>/b return_incr_result_p1
	/##return_decr_result_1_p2<pCED>/ b return_decr_result_1_p2
        /##return_decr_result_2_p2<pCED>/ b return_decr_result_2_p2
        /##return_incr_result_1_p2<pCNI>/b return_incr_result_1_p2
	/##return_incr_result_2_p2<pCNI>/b return_incr_result_2_p2
b EOS

:debug
        #test if GNU extensions are supported
        1v
b main



######################### MATH LIB #########################

#1-2: <DIV>14 5#label<VID> -> <DIV>2##label<VID>
#1-2: <DIV>-27 3#label<VID> -> <DIV>-9##label<VID>
#1-2: <DIV>0 -5#label<VID> -> <DIV>0##label<VID>
#1-2: <DIV>-15 -5#label<VID> -> <DIV>3##label<VID>
#1-2: <DIV>9 0#label<VID> -> <DIVp>DIVISION BY ZERO!##label<pVID>
:div
	s:<DIV>-?[0-9]+:&;:
    b next_dv
    :loop_dv
        /(<DIV>)-([0-9]+) -([0-9]+);/{
            s::\1<DIVp>\2 \3#result_dvp_dv_1<pVID>;:
            b div_pos
            :result_dvp_dv_1
                s:<DIVp>([0-9]+)[^<]+<pVID>:\1:
            b next_dv
        }
        /(<DIV>)-([0-9]+) ([0-9]+);/{
            s::\1<DIVp>\2 \3#result_dvp_dv_2<pVID>;:
            b div_pos
            :result_dvp_dv_2
                s:<DIVp>([0-9]+)[^<]+<pVID>:-\1:
            b next_dv
        }
        /(<DIV>)([0-9]+) -([0-9]+);/{
            s::\1<DIVp>\2 \3#result_dvp_dv_3<pVID>;:
            b div_pos
            :result_dvp_dv_3
                s:<DIVp>0[^<]+<pVID>:0:
                s:<DIVp>([0-9]+)[^<]+<pVID>:-\1:
            b next_dv
        }
        s:(<DIV>)([0-9]+) ([0-9]+);:\1<DIVp>\2 \3#result_dvp_dv_4<pVID>;:
        b div_pos
        :result_dvp_dv_4
            s:<DIVp>([0-9]+)[^<]+<pVID>:\1:
    :next_dv
        /;#[^<]+<VID>/b print_dv
        s:(<DIV>[^;]+);( -?[0-9]+):\1\2;:
    b loop_dv
    :print_dv
        s:;(#[^<]+<VID>):#\1:
b redirect


#1+: <MULT>9 1 -14 -10#label<TLUM> -> <MULT>1260##label<TLUM>
:mult
	s:<MULT>-?[0-9]+:&;:
    b next_mm
    :loop_mm
        /(<MULT>)-([0-9]+) -([0-9]+);/{
            s::\1<MULTp>\2 \3#result_mmp_mm_1<pTLUM>;:
            b mult_pos
            :result_mmp_mm_1
                s:<MULTp>([0-9]+)[^<]+<pTLUM>:\1:
            b next_mm
        }
        /(<MULT>)-([0-9]+) ([0-9]+);/{
            s::\1<MULTp>\2 \3#result_mmp_mm_2<pTLUM>;:
            b mult_pos
            :result_mmp_mm_2
                s:<MULTp>([0-9]+)[^<]+<pTLUM>:-\1:
            b next_mm
        }
        /(<MULT>)([0-9]+) -([0-9]+);/{
            s::\1<MULTp>\2 \3#result_mmp_mm_3<pTLUM>;:
            b mult_pos
            :result_mmp_mm_3
                s:<MULTp>([0-9]+)[^<]+<pTLUM>:-\1:
            b next_mm
        }
        s:(<MULT>)([0-9]+) ([0-9]+);:\1<MULTp>\2 \3#result_mmp_mm_4<pTLUM>;:
        b mult_pos
        :result_mmp_mm_4
            s:<MULTp>([0-9]+)[^<]+<pTLUM>:\1:
    :next_mm
        /;#[^<]+<TLUM>/b print_mm
        s:(<MULT>[^;]+);( -?[0-9]+):\1\2;:
    b loop_mm
    :print_mm
        s:;(#[^<]+<TLUM>):#\1:
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


#1+: <MAX>110 34 0 -34 -110#label<XAM> -> <MAX>110##label<XAM>
:max
    s:<MAX>-?[0-9]+:&;:
    b next_M
    :loop_M
        /(<MAX>)-([0-9]+) -([0-9]+);/{
            s::\1<MINp>\2 \3#result_mp_M<pNIM>;:
            b min_pos
            :result_mp_M
                s:<MINp>([0-9]+)[^<]+<pNIM>:-\1:
            b next_M
        }
        /(<MAX>)(-[0-9]+) ([0-9]+);/{
            s::\1\3;:
            b next_M
        }
        /(<MAX>)([0-9]+) (-[0-9]+);/{
            s::\1\2;:
            b next_M
        }
        s:(<MAX>)([0-9]+) ([0-9]+);:\1<MAXp>\2 \3#result_Mp_M<pXAM>;:
        b max_pos
        :result_Mp_M
            s:<MAXp>([0-9]+)[^<]+<pXAM>:\1:
    :next_M
        /;#[^<]+<XAM>/b print_M
        s:(<MAX>[^;]+);( -?[0-9]+):\1\2;:
    b loop_M
    :print_M
        s:;(#[^<]+<XAM>):#\1:
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


#1+: <DEC>10 0 -9#label<CED> -> <DEC>9 -1 -10##label<CED>
:decr
    s:<DEC>:&;:
    :loop_d
        /<DEC>[^;]*; ?-/{
            s:(<DEC>[^;]*; ?)-([0-9]+):\1<INCp>\2#result_ip_d<pCNI>:
            b incr_pos
            :result_ip_d
                s:<INCp>([0-9]+)[^<]+<pCNI>:-\1:
            b next_d
        }
        s:(<DEC>[^;]*; ?)([0-9]+):\1<DECp>\2#result_dp_d<pCED>:
        b decr_pos
        :result_dp_d
            s:<DECp>(-?[0-9]+)[^<]+<pCED>:\1:
    :next_d
        s:(<DEC>[^;]*);( ?-?[0-9]+):\1\2;:
    /;#[^<]+<CED>/!b loop_d
    s:;(#[^<]+<CED>):#\1:
b redirect


#1+: <INC>9 0 -10 -1#label<CNI> -> <INC>10 1 -9 0##label<CNI>
:incr
    s:<INC>:&;:
    :loop_i
        /<INC>[^;]*; ?-/{
            s:(<INC>[^;]*; ?)-([0-9]+):\1<DECp>\2#result_dp_i<pCED>:
            b decr_pos
            :result_dp_i
                s:<DECp>0#[^<]+<pCED>:0:
                s:<DECp>([0-9]+)[^<]+<pCED>:-\1:
            b next_i
        }
        s:(<INC>[^;]*; ?)([0-9]+):\1<INCp>\2#result_ip_i<pCNI>:
        b incr_pos
        :result_ip_i
            s:<INCp>([0-9]+)[^<]+<pCNI>:\1:
    :next_i
        s:(<INC>[^;]*);( ?-?[0-9]+):\1\2;:
    /;#[^<]+<CNI>/!b loop_i
    s:;(#[^<]+<CNI>):#\1:
b redirect


######################### BASE LIB #########################

#1-2: <DIVp>14 5#label<pVID> -> <DIVp>2##label<pVID>
#1-2: <DIVp>5 14#label<pVID> -> <DIVp>0##label<pVID>
#1-2: <DIVp>9 0#label<pVID> -> <DIVp>DIVISION BY ZERO!##label<pVID>
:div_pos
    /(<DIVp>)([0-9]+)#/{
        s::\1\2 1,\2 \2#:
        b print_dvp
    }
    /(<DIVp>)[0-9]+ 0#/{
        s::\1DIVISION BY ZERO!##:p
        #b redirect (when lib can handle exceptions)
        b EOS
    }
    s:#[^<]+<pVID>:,0 0&:
    :loop_dvp
        s: ([0-9]+),[0-9]+ ([0-9]+):&<ADDp>\1 \2#result_ap_dvp<pDDA>:
		b add_pos
		:result_ap_dvp
			s:(,[0-9]+ )[0-9]+<ADDp>([0-9]+)[^<]+<pDDA>:\1\2:
        /<DIVp>([0-9]+) [0-9]+,[0-9]+ \1#/!{
			s:<DIVp>([0-9]+) [0-9]+,[0-9]+ ([0-9]+):&<MAXp>\1 \2#result_Mp_dvp<pXAM>:
			b max_pos
			:result_Mp_dvp
				s:<MAXp>([0-9]+)[^<]+<pXAM>:;\1:
			/([0-9]+);\1#[^<]+<pVID>/b print_dvp
			s:;[0-9]+(#[^<]+<pVID>):\1:
		}
		s:,([0-9]+) [0-9]+:&<INCp>\1#result_ip_dvp<pCNI>:
		b incr_pos
		:result_ip_dvp
			s:,[0-9]+( [0-9]+)<INCp>([0-9]+)[^<]+<pCNI>:,\2\1:
        /<DIVp>([0-9]+) [0-9]+,[0-9]+ \1#/b print_dvp
    b loop_dvp
    :print_dvp
        s:(<DIVp>)[0-9]+ [0-9]+,([0-9]+) [0-9]+(;[0-9]+)?:\1\2#:
b redirect


#1-2: <MULTp>9 14#label<pTLUM> -> <MULTp>126##label<pTLUM>
:mult_pos
	/(<MULTp>)([0-9]+)#/{
        s::\10 \2,\2:
        b print_mmp
    }
    s:#[^<]+<pTLUM>:,0&:
	:loop_mmp
        /<MULTp>0/b print_mmp
        s:(<MULTp>)([0-9]+):\1<DECp>\2#result_dp_mmp<pCED>:
        b decr_pos
        :result_dp_mmp
            s:<DECp>([0-9]+)[^<]+<pCED>:\1:
        s:(<MULTp>[0-9]+ )([0-9]+),([0-9]+):\1\2,<ADDp>\3 \2#result_ap_mmp<pDDA>:
        b add_pos
        :result_ap_mmp
            s:<ADDp>([0-9]+)[^<]+<pDDA>:\1:
    b loop_mmp
	:print_mmp
		s:(<MULTp>)0 [0-9]+,([0-9]+):\1\2#:
b redirect


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


######################### FUNCTION GLUE #########################

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
    /##result_dp_mmp<pCED>/b result_dp_mmp
    /##result_ap_mmp<pDDA>/b result_ap_mmp
    /##result_ap_dvp<pDDA>/b result_ap_dvp
    /##result_Mp_dvp<pXAM>/b result_Mp_dvp
    /##result_ip_dvp<pCNI>/b result_ip_dvp
b continue_redirects_1


:math_lib_redirects
    /##result_dp_i<pCED>/b result_dp_i
	/##result_ip_i<pCNI>/b result_ip_i
	/##result_ip_d<pCNI>/b result_ip_d
	/##result_dp_d<pCED>/b result_dp_d
    /##result_Mp_m<pXAM>/b result_Mp_m
	/##result_mp_m<pNIM>/b result_mp_m
    /##result_mp_M<pNIM>/b result_mp_M
	/##result_Mp_M<pXAM>/b result_Mp_M
    /##result_ap_a_1<pDDA>/b result_ap_a_1
    /##result_ap_a_2<pDDA>/b result_ap_a_2
    /##result_sp_a_1<pBUS>/b result_sp_a_1
    /##result_sp_a_2<pBUS>/b result_sp_a_2
    /##result_ap_s_1<pDDA>/b result_ap_s_1
    /##result_ap_s_2<pDDA>/b result_ap_s_2
    /##result_sp_s_1<pBUS>/b result_sp_s_1
    /##result_sp_s_2<pBUS>/b result_sp_s_2
    /##result_mmp_mm_1<pTLUM>/b result_mmp_mm_1
    /##result_mmp_mm_2<pTLUM>/b result_mmp_mm_2
    /##result_mmp_mm_3<pTLUM>/b result_mmp_mm_3
    /##result_mmp_mm_4<pTLUM>/b result_mmp_mm_4
    /##result_dvp_dv_1<pVID>/b result_dvp_dv_1
    /##result_dvp_dv_2<pVID>/b result_dvp_dv_2
    /##result_dvp_dv_3<pVID>/b result_dvp_dv_3
    /##result_dvp_dv_4<pVID>/b result_dvp_dv_4
b continue_redirects_2


:EOS
	#mainly used to skip over remaining code, when needed

