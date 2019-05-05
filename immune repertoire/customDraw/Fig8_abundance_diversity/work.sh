Rscript abundunce2.R

for sample in RGD TGD NC NGD NC6 NC1 HT3 HT4 GD9 GD2 HT1 NC4 NC2 NC5 NC3 GD5 GD11 HT2 GD6 GD8 GD12 HT6 GD10 GD4 HT5 GD3 GD1 HT GD7;
do 
perl diversityIndex_add.pl ${sample}_diversity.xls >${sample}_diversity2.xls
mv ${sample}_diversity2.xls ${sample}_diversity.xls
done
