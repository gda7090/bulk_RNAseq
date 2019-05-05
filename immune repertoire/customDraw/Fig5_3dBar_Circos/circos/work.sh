l /NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/New/out/8*txt |awk '{print $NF}' |perl -ne 'chomp;$a=(split/\//,$_)[-1];$a=(split/\./,$a)[1];print "perl top30TRBpairs_circosInput.pl $_ 30 >$a\_TRBvjpairs_top30.xls\nRscript vj_pairing_plot.r $a\_TRBvjpairs_top30.xls $a\_TRBvjpairs_top30.pdf\n "' >run.sh
sh run.sh

