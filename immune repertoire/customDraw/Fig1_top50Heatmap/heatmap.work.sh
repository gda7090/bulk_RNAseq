Rscript plot.heatmap.basedon.cor.R --qsigr1 TRB.ordersample.Vgenetab.xls --anno2 group.anno.list --outdir heatmap_top50_TRB --top 50 --prefix Vgenetab_top50
Rscript plot.heatmap.basedon.cor.R --qsigr1 TRB.ordersample.Jgenetab.xls --anno2 group.anno.list --outdir heatmap_top50_TRB --top 50 --prefix Jgenetab_top50
Rscript plot.heatmap.basedon.cor.R --qsigr1 TRB.ordersample.Dgenetab.xls --anno2 group.anno.list --outdir heatmap_top50_TRB --top 50 --prefix Dgenetab_top50
history|tail|grep anno > heatmap.work.sh
