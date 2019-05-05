Rscript vexpr_plot.r out/2.segments.wt.J.txt 18 1 1 FALSE out/2.segments.wt.J.pdf

perl temp.pl out/2.segments.wt.J.txt >out/2.segments.wt.J.test.txt
Rscript vexpr_plot.r out/2.segments.wt.J.test.txt 7 0 0 FALSE out/2.segments.wt.J.test.pdf

cut -f1-2,4-20 out/2.segments.wt.J.txt >out/2.segments.wt.J.test3.txt
Rscript vexpr_plot.r out/2.segments.wt.J.test3.txt 17 0 0 FALSE out/2.segments.wt.J.test3.pdf

Rscript vexpr_plot.2.r out/2.segments.wt.J.test.txt 7 0 0 FALSE out/2.segments.wt.J.test.pdf
