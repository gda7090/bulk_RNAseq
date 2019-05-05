for sample in NGD RGD TGD HT NC
do
echo perl top30TRBpairs_3dBarInput.pl /NJPROJ2/RNA_S/personal_dir/lindan/SHOUHOU/P101SC17111985-01-JinShanHospital/out/8.${sample}.fancyvj.wt.txt 30 \> ${sample}_TRBvjpairs_top30.xls
done

python plot3Dbar.py top30.list
