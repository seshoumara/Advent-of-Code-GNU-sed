#!/usr/bin/sed -nrf

:_Author
	# https://seshoumara.itch.io/
	# https://discord.gg/8pWpB59YKZ


b debug
:main
	#b benchmark_decr
	b benchmark_add
	#b benchmark_cadd
	#b benchmark_cammy_add
	#b benchmark_fadd
b EOS

:benchmark_decr
	s:.*:<DEC>&#return_dec_result_bd<CED>:
	b decr_pos
	:return_dec_result_bd
		s:<DEC>([0-9]+)##return_dec_result_bd<CED>:\1:
	p
b EOS

:benchmark_add
	s:.*:<ADD>&#return_add_result_ba<DDA>:
	b add_pos
	:return_add_result_ba
		s:<ADD>([0-9]+)##return_add_result_ba<DDA>:\1:
	p
b EOS

:benchmark_cadd
	s:.*:<CADD>&#return_cadd_result_bc<DDAC>:
	b custom_add
	:return_cadd_result_bc
		s:<CADD>([0-9]+)##return_cadd_result_bc<DDAC>:\1:
	p
b EOS

:benchmark_cammy_add
	s:.*:<ADDc>&#return_addc_result_bca<cDDA>:
	b cammy_add
	:return_addc_result_bca
		s:<ADDc>([0-9]+)[^<]+<cDDA>:\1:
	p
b EOS

:benchmark_fadd
	s:.*:<FADD>&#return_fadd_result_bf<DDAF>:
	b fast_add
	:return_fadd_result_bf
		s:<FADD>([0-9]+)##return_fadd_result_bf<DDAF>:\1:
	p

b EOS

:debug
	#test if GNU extensions are supported
	1v
b main

:user_redirects
	/##return_dec_result_bd<CED>/ b return_dec_result_bd
	/##return_add_result_ba<DDA>/ b return_add_result_ba
	/##return_cadd_result_bc<DDAC>/ b return_cadd_result_bc
	/##return_addc_result_bca<cDDA>/ b return_addc_result_bca
	/##return_fadd_result_bf<DDAF>/ b return_fadd_result_bf
b EOS


######################### MATH / UTILS #########################

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


#cammy
# add from the top, so fast and with no carries except in the increment func
#1-2: <ADDc>9 14#label<cDDA> -> <ADDp>23##label<pDDA>
:cammy_add
    /<ADDc>[0-9]+#/{
        s:<ADDc>[0-9]+#:&#:
        b redirect
    }
    # setup for finding highest common place
    s:(<ADDc>[0-9]*)([0-9]) ([0-9]*)([0-9])#:\1@\2 \3@\4#:
    # if at least one number has only one digit, shortcut directly to loop
    s:<ADDc>([0-9]*@[0-9]) (@[0-9])#:<ADDc>\2 \1#:
    /<ADDc>@/{
        s:<ADDc>@([0-9]) ([0-9]*)@([0-9])#:<ADDc>\1@ \2\3@#:
        b loop_add_f_cammy
    }

    # find highest common place
    :loop_add_f_high_pl_cammy
        /<ADDc>[0-9][0-9]+@[0-9]+ [0-9][0-9]+@[0-9]+/{
            s:(<ADDc>[0-9]+)([0-9])@([0-9]+) ([0-9]+)([0-9])@([0-9]+)#:\1@\2\3 \4@\5\6#:
            b loop_add_f_high_pl_cammy
        }
    # order the shorter number first
    s:<ADDc>([0-9][0-9]+@[0-9]+) ([0-9]@[0-9]+)#:<ADDc>\2 \1#:
    #something went wrong, should only have 1 digit before @ in the first num
    /<ADDc>[0-9][0-9]+@/q12
    :loop_add_f_cammy
        /<ADDc>0@ /b add_f_done_cammy
        /<ADDc>0@/{
            s:<ADDc>0@([0-9])([0-9]*) ([0-9]+)@([0-9])([0-9]*)#:<ADDc>\1@\2 \3\4@\5#:
            b loop_add_f_cammy
        }
        s:(<ADDc>[0-9@]+) ([0-9]+)@([0-9]*)#:\1 <INC>\2#result_af_inc_cammy<CNI>@\3#:
        b incr_pos
        :result_af_inc_cammy
            s:<INC>([0-9]+)[^<]+<CNI>:\1:
        s:(<ADDc>)([0-9])@:\1<DEC1d>\2#result_af_dec1d_cammy<d1CED>@:
        b decr_1_digit
        :result_af_dec1d_cammy
            s:<DEC1d>([0-9])[^<]+<d1CED>:\1:
    b loop_add_f_cammy
    :add_f_done_cammy
    s:<ADDc>0@ ([0-9]+)@#:<ADDc>\1##:
b redirect


#cammy
# dec single digit, errors if called on 0
#1: <DEC1d>6#label<d1CED> -> <DEC1d>6##label<d1CED>
:decr_1_digit
    /<DEC1d>0#/q24
    s:<DEC1d>1#:<DEC1d>0##:
    s:<DEC1d>2#:<DEC1d>1##:
    s:<DEC1d>3#:<DEC1d>2##:
    s:<DEC1d>4#:<DEC1d>3##:
    s:<DEC1d>5#:<DEC1d>4##:
    s:<DEC1d>6#:<DEC1d>5##:
    s:<DEC1d>7#:<DEC1d>6##:
    s:<DEC1d>8#:<DEC1d>7##:
    s:<DEC1d>9#:<DEC1d>8##:
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


#1+: <FADD>1 2 3#label<DDAF> -> <FADD>6##label<DDAF>
:fast_add
	s:(<FADD>[^#]+):& :
	s:<FADD>:&, 0@0;:
	b next_fadd
	:column_loop_fadd
		#exit condition
		/<FADD>[0-9]*, <[0-9]+ <[0-9]+@/ b cleanup_fadd
		#copy the column digits to the carry pos, separated by space
		s:(<FADD>[0-9]*, [0-9]*)([0-9])(<[0-9]* [0-9<]+@):&\2 :
		s:(<FADD>[0-9]*, [0-9<]+ [0-9]*)([0-9])(<[0-9]*@):&\2 :
		#edge case: in that column, one of the two digits is missing
		s:(<FADD>[^@]+@)(.) (.);:\10 \2 \3;:
		#sum all nrs in carry pos, using a table lookup approach
		s:<FADD>[0-9]*, [0-9<]+ [0-9<]+@[^;]+:&%00-0%01-1%02=11-2%03=12-3%04=13=22-4%05=14=23-5%06=15=24=33-6%07=16=25=34-7%08=17=26=35=44-8%09=18=27=36=45-9:
		s:<FADD>[0-9]*, [0-9<]+ [0-9<]+@[^;]+:&%19=28=37=46=55-10%29=38=47=56-11%39=48=57=66-12%49=58=67-13%59=68=77-14%69=78-15%79=88-16%89-17%99-18%xx-19:
		s:(<FADD>[0-9]*, [0-9<]+ [0-9<]+@)(.) (.) 0[^;]*[%=]\2\3[^-]*-([0-9]+)[^;]*:\1\4:
		s:(<FADD>[0-9]*, [0-9<]+ [0-9<]+@)(.) (.) 0[^;]*[%=]\3\2[^-]*-([0-9]+)[^;]*:\1\4:
		s:(<FADD>[0-9]*, [0-9<]+ [0-9<]+@)(.) (.) 1[^;]*[%=]\2\3[^%]+%[^-]+-([0-9]+)[^;]*:\1\4:
		s:(<FADD>[0-9]*, [0-9<]+ [0-9<]+@)(.) (.) 1[^;]*[%=]\3\2[^%]+%[^-]+-([0-9]+)[^;]*:\1\4:
		#if col sum is 2 digits, 1st digit is carry, 2nd digit is the result
		/(<FADD>)([0-9]*, [0-9<]+ [0-9<]+@)([0-9])([0-9])/{
			s::\1\4\2\3:
			b shift_fadd
		}
		/(<FADD>)([0-9]*, [0-9<]+ [0-9<]+@)([0-9])/s::\1\3\20:
		:shift_fadd
		#shift both of <, edge case: if < is at start of nr don't shift
		s:(<FADD>[0-9]*, [0-9]*)([0-9])<:\1<\2:
		s:(<FADD>[0-9]*, [0-9<]+ [0-9]*)([0-9])<:\1<\2:
	b column_loop_fadd
	:cleanup_fadd
		#check if carry from last col add is != 0, put it in front of sum
		s:(<FADD>)([0-9]*, [0-9<]+ [0-9<]+@)([1-9]):\1\3\20:
		#delete the nrs, move the sum into where nrs where
		s:(<FADD>)([0-9]+),[^@]+:\1, \2:
	:next_fadd
		/(<FADD>, [0-9]+)(@0;)#/b print_fadd
		s:(<FADD>, [0-9]+)(@0;)([0-9]+) :\1< \3<\2:
	b column_loop_fadd
	:print_fadd
		#cleanup and double the #
		s:(<FADD>), ([0-9]+)@0;:\1\2#:
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
	s:(<DEC>)1@:\1@:;t print_dp
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
		s:(<DEC>[^#]*)@:\19:
	t print_dp
	s:#[^<]+<CED>:#&:
b redirect


#1: <INC>9#label<CNI> -> <INC>10##label<CNI>
:incr_pos
	:nines
		s:9(@*)(#[^<]+<CNI>):@\1\2:
	t nines
	s:(<INC>)@:\11@:;t print_ip
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
		s:(<INC>[^#]*)@:\10:
	t print_ip
	s:#[^<]+<CNI>:#&:
b redirect


:redirect
	b library_redirects
	:continue_redirects
b user_redirects


:library_redirects
	/##result_dp_ap<CED>/b result_dp_ap
	/##return_add_result_cadd<DDA>/ b return_add_result_cadd
	/##result_dp_mp1<CED>/b result_dp_mp1
	/##result_dp_mp2<CED>/b result_dp_mp2
	/##result_ip_ap<CNI>/b result_ip_ap
	/##result_ip_sp<CNI>/b result_ip_sp

    #cammy
    /##result_af_inc_cammy<CNI>/b result_af_inc_cammy
    /##result_af_dec1d_cammy<d1CED>/b result_af_dec1d_cammy
b continue_redirects


:EOS
	#End Of Script (mainly used to skip over remaining code, when needed)
