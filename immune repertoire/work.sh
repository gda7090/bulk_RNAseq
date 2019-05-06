##downsample normaliztion of 24 samples
less pre_normalize.specific_clone.list |perl -ne 'chomp;$smp=$_;open(IN,$_);<IN>;$sum=0;while(<IN>){$c=(split/\t/,$_)[1];$sum+=$c};print "$smp\t$sum\n"' >sum.list
sort -k2 -n sum.list #取最小数据量值26480
less pre_normalize.specific_clone.list |perl -ne 'chomp;$_=~/(02.mix.*)\/(.*)/;chomp($d=`pwd`);print "mkdir -p $d/$1\n cd $d/$1\nRscript $d/downsample.R $_ $d/$1/$2 2 26480 5\n\n"' >down.sh
qsub -cwd -l vf=5g,p=6 -V down.sh
perl -e '$rn=shift;for(`less $rn`){chomp;%rn=split/\s+/,`less $rn`;};$lst=shift;for(`less $lst`){chomp;$_=~/(.*)\/(.*)\/(.*)/;print "cd $1;mv $2 $rn{$2};mv $rn{$2}/$3 $rn{$2}/$rn{$2}.specifc.clones.txt\n"}' rename.list oldname.list |sh
#  perl super_worker.pl --qalter --cyqt 1 --maxjob 200 --sleept 600 --resource 5G  down.sh  -splits '\n\n' --prefix downs &

##group mean clone count
for group in HT NGD RGD TGD NC;
do
mkdir 02.mixcr/${group}
done
#group HT
perl group_clones_merge.pl 02.mixcr HT1,HT2,HT3,HT4,HT5,HT6 HT
mv HT.specifc.clones.txt 02.mixcr/
perl clone_dup_check.pl 02.mixcr/HT.specifc.clones.txt >02.mixcr/HT_clone_dup_check
#group NGD
perl group_clones_merge.pl 02.mixcr GD1,GD2,GD3,GD4,GD5,GD6 NGD 
mv NGD.specifc.clones.txt 02.mixcr/
perl clone_dup_check.pl 02.mixcr/NGD.specifc.clones.txt >02.mixcr/NGD_clone_dup_check
#group RGD
perl group_clones_merge.pl 02.mixcr GD7,GD8,GD9,GD10,GD11,GD12 RGD
mv RGD.specifc.clones.txt 02.mixcr/ 
perl clone_dup_check.pl 02.mixcr/RGD.specifc.clones.txt >02.mixcr/RGD_clone_dup_check
#group TGD
perl group_clones_merge.pl 02.mixcr GD1,GD2,GD3,GD4,GD5,GD6,GD7,GD8,GD9,GD10,GD11,GD12 TGD
mv TGD.specifc.clones.txt 02.mixcr/ 
perl clone_dup_check.pl 02.mixcr/TGD.specifc.clones.txt >02.mixcr/TGD_clone_dup_check
#group NC
perl group_clones_merge.pl 02.mixcr NC1,NC2,NC3,NC4,NC5,NC6 NC
mv NC.specifc.clones.txt 02.mixcr/ 
perl clone_dup_check.pl 02.mixcr/NC.specifc.clones.txt >02.mixcr/NC_clone_dup_check

qsub -cwd -l vf=5g,p=6 -V  demo.sh


