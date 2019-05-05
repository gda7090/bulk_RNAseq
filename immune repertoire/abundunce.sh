echo "CLONE	DUPCOUNT	SAMPLE" >02.mixcr/all_sample.abundance
for sam  in NGD RGD TGD NC
do
cut -f 1,2 02.mixcr/${sam}/${sam}.specifc.clones.txt >temp
sed -i '1d' temp
cat temp|awk "{print \$0"\""\t${sam}"\""}" >02.mixcr/${sam}/${sam}.abundance
cat 02.mixcr/${sam}/${sam}.abundance >>02.mixcr/all_sample.abundance
sed -i '1iCLONE	DUPCOUNT	SAMPLE' 02.mixcr/${sam}/${sam}.abundance
done

for sam in GD7 NC6 NC1 HT3 HT4 GD9 GD2 HT1 NC4 NC2 NC5 NC3 GD5 GD11 HT2 GD6 GD8 GD12 HT6 GD10 GD4 HT5 GD3 GD1 HT
do
cut -f 1,2 02.mixcr/${sam}/${sam}.specifc.clones.txt >temp
sed -i '1d' temp
cat temp|awk "{print \$0"\""\t${sam}"\""}" >02.mixcr/${sam}/${sam}.abundance
sed -i '1iCLONE DUPCOUNT        SAMPLE' 02.mixcr/${sam}/${sam}.abundance
done
