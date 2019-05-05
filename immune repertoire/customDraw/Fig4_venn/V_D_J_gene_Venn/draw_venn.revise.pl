use List::Compare;
use FindBin qw($Bin);
use strict;
use lib "/NJPROJ2/MICRO/share/MetaGenome_pipeline/MetaGenome_pipeline_V5.1/lib/00.Commbin/";
my $lib = "/NJPROJ2/MICRO/share/MetaGenome_pipeline/MetaGenome_pipeline_V5.1/lib/00.Commbin/";
use PATHWAY;
(-s "Pathway_cfg.txt") || die"error: can't find config at Pathway_cfg.txt, $!\n";

BEGIN{
        my($math_comb) = get_pathway("Pathway_cfg.txt",[qw(MATH_COMB)],$Bin,$lib);                                                                       
            unshift @INC, $math_comb
}
use Math::Combinatorics;
use Cwd qw(abs_path);
use Getopt::Long;
use Data::Dumper;
use File::Basename;
my($R,$convert) = get_pathway("Pathway_cfg.txt",[qw(R4 CONVERT)],$Bin,$lib);
my %opt=("outdir" => ".");
GetOptions(\%opt,"in:s","venn:s","outdir:s","width","height","lwd:s","lty:s","alpha:s","col_cir:s","cat_cex:s");
$opt{in} || die "Descritpion: scription : draw Venn Figure for the number of sample <= 5

Usage  perl $0 --in Un.even --venn venn.list --outdir [outdir] [-options]
	
	--in*		Unigenes.readsNum.even.xls
	--venn*		venn.list format sample1\\tsample2\\tsample3
	--outdir	set output  Directory,default ./
	--width		set output wdith of pdf's file,default 4
	--height	set output height of pdf's file,default 4
	--lwd		set line width of the circles' circumferences,default 1
	--lty		set the line dash pattern of the circles' circumferences,default solid,
				option [blank|dashed|dotted|dotdash|longdash|twodash]
	--alpha		set the alpha transparency of the circles' areas,default 0.5
	--col_cir	set the colours of the circles' circumferences,default white
				the color based on R language
	--cat_cex	the size of the category(usually sample's name)names,default 1

	Example:
		perl --in Unigenes.readsNum.even.xls --venn venn.list --outdir ./
";
open IN,"< $opt{in}";
my $sample=<IN>;
chomp $sample;
my @sample=split/\t/,$sample;
shift @sample;
my %hash;###样本=>id名集合
my ($width,$height,$lwd,$lty,$col_cir,$cat_cex,$alpha);
$width = $opt{width} || ($width = 4);
$height = $opt{height} || ($height = 4);
$lwd = $opt{lwd} || ($lwd = 1);
$col_cir = $opt{col_cir} || ($col_cir = "white");
$alpha = $opt{alpha} || ($alpha = 0.5);
$lty = $opt{lty} || ($lty = "solid");
$cat_cex = $opt{cat_cex} || ($cat_cex = 1);
$opt{outdir}=abs_path($opt{outdir});
#print "$lty\t$width\n";
while (<IN>)
{
    chomp;
    my @line=split/\t/;
	
    foreach my $n (0..$#sample)
    {
        if ($line[$n+1]>0)
        {
           push @{$hash{$sample[$n]}},$line[0];
        }
    }
}
close IN;
open VENN,"< $opt{venn}";
while(<VENN>)
{
	chomp;
	my @line= (/\t/ ?  split /\t/ : split /\s+/);
    my $r=join"_",@line;
    (-s "$opt{outdir}/venndata/$r") || `mkdir -p $opt{outdir}/venndata/$r`;
    my %zuhe;###交集数目
####统计
	foreach my $n (1..scalar @line)
	{
		my $combine=  Math::Combinatorics->new(count=>$n,data=>[@line]);###取所用可能的Combinatorics（组合）
		my $zuhe;
		while (my @combine = $combine->next_combination)
		{
			$zuhe.=join("\t",@combine).",";
		}
		my @zuhe=split/,/,$zuhe;
		unless (/\t/ ~~ @zuhe)
		{
			foreach my $ele (@zuhe)
			{
				open OUT ,"> $opt{outdir}/venndata/$r/$ele.xls";####单个样本所含数目
				print OUT join"\t",@{$hash{$ele}};
				$zuhe{$ele}=scalar @{$hash{$ele}};
				close OUT;
			}
		
		}
		else
		{
			foreach my $ele(@zuhe)
			{
				my @group = split/\t/,$ele;
				my $file  = join"_",@group;
				open OUT,"> $opt{outdir}/venndata/$r/$file.xls";
				my @arrref;
				foreach my $s (@group)
				{
					push @arrref,\@{$hash{$s}};
				}
				my $lcm=List::Compare -> new({lists=>\@arrref});#####计算多个样本中数目的
				my @intersection = $lcm -> get_intersection;####计算交集
				print OUT join"\t",@intersection;
				close OUT;
				$zuhe{$file} = scalar @intersection;
			}
		}	

	}
	open R,">$opt{outdir}/$r.R";
###画图
	if(scalar @line ==2)
	{
print R 
"library\(\"VennDiagram\"\)
setwd\(\"$opt{outdir}\"\)
pdf\(\'$opt{outdir}/$r.pdf\',width=$width,height=$height\)
draw.pairwise.venn\(category = c\(\"$line[0]\",\"$line[1]\"), 
fill=c\(\"cornflowerblue\", \"green\"),cat.col=c\(\"cornflowerblue\",\"green\"\),
alpha=rep\($alpha,2\),col=rep\(\"$col_cir\",2\),lwd=rep\($lwd,2\),lty=rep\(\"$lty\",2\),ind=TRUE,
area1=$zuhe{$line[0]},area2=$zuhe{$line[1]},cex=c(0.5,0.5,0.5),cat.cex=rep\($cat_cex,2\),";
	foreach my $key (keys %zuhe)
	{
		print R "cross.area=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1])\_($line[0]|$line[1])$/);
	}
print R "\)\ndev.off\(\)";
close R;	
#`/NJPROJ2/MICRO/share/software/R-3.3.3/bin/R -f $opt{outdir}/$r.R`;
`$R -f $opt{outdir}/$r.R`;
# `/usr/bin/convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;
 `$convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;
    }	
	elsif(scalar @line ==3)
	{
print R 
"library\(\"VennDiagram\"\)
setwd\(\"$opt{outdir}\"\)
pdf\(\'$opt{outdir}/$r.pdf\',width=$width,height=$height\)
draw.triple.venn\(category = c\(\"$line[0]\",\"$line[1]\",\"$line[2]\"\), 
fill=c\(\"cornflowerblue\", \"green\",\"maroon\"\),
cat.col=c\(\"cornflowerblue\",\"green\",\"maroon\"\),
alpha=rep\($alpha,3\),lwd=rep\($lwd,3\),lty=rep\(\"$lty\",3\),ind = TRUE,col=rep\(\"$col_cir\",3\),cat.cex=rep\($cat_cex,3\),
area1=$zuhe{$line[0]},area2=$zuhe{$line[1]},area3=$zuhe{$line[2]},";
	foreach my $key (keys %zuhe)
	{
		print R "n12=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1])\_($line[0]|$line[1])$/);
		print R "n13=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2])\_($line[0]|$line[2])$/);
		print R "n23=$zuhe{$key}," if ($key =~ /^($line[1]|$line[2])\_($line[1]|$line[2])$/);
		print R "n123=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2])\_($line[0]|$line[1]|$line[2])\_($line[0]|$line[1]|$line[2])$/);
	}
print R "\)\ndev.off\(\)";
close R;	
    `$R -f $opt{outdir}/$r.R`; 
    #`/NJPROJ2/MICRO/share/software/R-3.3.3/bin/R -f $opt{outdir}/$r.R`; 
    # `/usr/bin/convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;
     `$convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;
    }
	elsif(scalar @line == 4)
	{
	
print R 
"library\(\"VennDiagram\"\)
setwd\(\"$opt{outdir}\"\)
pdf\(\'$opt{outdir}/$r.pdf\',width=$width,height=$height\)
draw.quad.venn\(category = c\(\"$line[0]\",\"$line[1]\",\"$line[2]\",\"$line[3]\"\),
fill=c\(\"cornflowerblue\", \"green\",\"maroon\",\"darkorchid1\"\),
cat.col = c\(\"cornflowerblue\", \"green\",\"maroon\",\"darkorchid1\"\),
lwd=rep\($lwd,4\),lty=rep\(\"$lty\",4\),alpha=rep\($alpha,4\),ind = TRUE,col=rep\(\"$col_cir\",4\),cat.cex=rep\($cat_cex,4\),
area1=$zuhe{$line[0]},area2=$zuhe{$line[1]},area3=$zuhe{$line[2]},area4=$zuhe{$line[3]},";
	foreach my $key (keys %zuhe)
	{
		print R "n12=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1])\_($line[0]|$line[1])$/);
		print R "n13=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2])\_($line[0]|$line[2])$/);
		print R "n14=$zuhe{$key}," if ($key =~ /^($line[0]|$line[3])\_($line[0]|$line[3])$/);
		print R "n23=$zuhe{$key}," if ($key =~ /^($line[1]|$line[2])\_($line[1]|$line[2])$/);
		print R "n24=$zuhe{$key}," if ($key =~ /^($line[1]|$line[3])\_($line[1]|$line[3])$/);
		print R "n34=$zuhe{$key}," if ($key =~ /^($line[2]|$line[3])\_($line[2]|$line[3])$/);		
		print R "n123=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2])\_($line[0]|$line[1]|$line[2])\_($line[0]|$line[1]|$line[2])$/);
		print R "n124=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[3])\_($line[0]|$line[1]|$line[3])\_($line[0]|$line[1]|$line[3])$/);
		print R "n134=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2]|$line[3])\_($line[0]|$line[2]|$line[3])\_($line[0]|$line[2]|$line[3])$/);
		print R "n234=$zuhe{$key}," if ($key =~ /^($line[3]|$line[1]|$line[2])\_($line[3]|$line[1]|$line[2])\_($line[3]|$line[1]|$line[2])$/);
		print R "n1234=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2]|$line[3])\_($line[0]|$line[1]|$line[2]|$line[3])\_($line[0]|$line[1]|$line[2]|$line[3])\_($line[0]|$line[1]|$line[2]|$line[3])$/);	
	}
print R "\)\ndev.off\(\)";
close R;	
    #`/NJPROJ2/MICRO/share/software/R-3.3.3/bin/R -f $opt{outdir}/$r.R`; 
    `$R -f $opt{outdir}/$r.R`; 
    #`/usr/bin/convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;
    `$convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;
    }
	elsif(scalar @line == 5)
	{
	
print R 
"library\(\"VennDiagram\"\)
setwd\(\"$opt{outdir}\"\)
pdf\(\'$opt{outdir}/$r.pdf\',width=$width,height=$height\)
draw.quintuple.venn\(category = c\(\"$line[0]\",\"$line[1]\",\"$line[2]\",\"$line[3]\",\"$line[4]\"\),
fill=c\(\"cornflowerblue\", \"green\",\"maroon\",\"darkorchid1\"\,\"orange\"),
cat.pos = c\(0,329,215,145,10\),cat.col = c\(\"cornflowerblue\", \"green\", \"maroon\", \"darkorchid1\", \"orange\"\),
lwd=rep\($lwd,5\),lty=rep\(\"$lty\",5\),alpha=rep\($alpha,5\),col=rep\(\"$col_cir\",5\),cat.cex=rep\($cat_cex,5\),
cex = c\(1, 1, 1, 1, 1, 0.5, 0.4, 0.5, 0.4, 0.5, 0.4, 0.5, 0.4, 0.5, 0.4, 0.5, 0.3, 0.5, 0.3, 0.5, 0.3, 0.5, 0.3, 0.5, 0.3, 0.5, 0.5, 0.5, 0.5, 0.5, 1\),margin=0.05,ind = TRUE,
area1=$zuhe{$line[0]},area2=$zuhe{$line[1]},area3=$zuhe{$line[2]},area4=$zuhe{$line[3]},area5=$zuhe{$line[4]},";
	foreach my $key (keys %zuhe)
	{
		print R "n12=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1])\_($line[0]|$line[1])$/);
		print R "n13=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2])\_($line[0]|$line[2])$/);
		print R "n14=$zuhe{$key}," if ($key =~ /^($line[0]|$line[3])\_($line[0]|$line[3])$/);
		print R "n15=$zuhe{$key}," if ($key =~ /^($line[0]|$line[4])\_($line[0]|$line[4])$/);

		print R "n23=$zuhe{$key}," if ($key =~ /^($line[1]|$line[2])\_($line[1]|$line[2])$/);
		print R "n24=$zuhe{$key}," if ($key =~ /^($line[1]|$line[3])\_($line[1]|$line[3])$/);
		print R "n25=$zuhe{$key}," if ($key =~ /^($line[1]|$line[4])\_($line[1]|$line[4])$/);
		
		print R "n34=$zuhe{$key}," if ($key =~ /^($line[2]|$line[3])\_($line[2]|$line[3])$/);
		print R "n35=$zuhe{$key}," if ($key =~ /^($line[2]|$line[4])\_($line[2]|$line[4])$/);
		print R "n45=$zuhe{$key}," if ($key =~ /^($line[3]|$line[4])\_($line[3]|$line[4])$/);
	
		print R "n123=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2])\_($line[0]|$line[1]|$line[2])\_($line[0]|$line[1]|$line[2])$/);
		print R "n124=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[3])\_($line[0]|$line[1]|$line[3])\_($line[0]|$line[1]|$line[3])$/);
		print R "n125=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[4])\_($line[0]|$line[1]|$line[4])\_($line[0]|$line[1]|$line[4])$/);
		
		print R "n134=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2]|$line[3])\_($line[0]|$line[2]|$line[3])\_($line[0]|$line[2]|$line[3])$/);
		print R "n135=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2]|$line[4])\_($line[0]|$line[2]|$line[4])\_($line[0]|$line[2]|$line[4])$/);
		print R "n145=$zuhe{$key}," if ($key =~ /^($line[0]|$line[3]|$line[4])\_($line[0]|$line[3]|$line[4])\_($line[0]|$line[3]|$line[4])$/);
		
		print R "n234=$zuhe{$key}," if ($key =~ /^($line[3]|$line[1]|$line[2])\_($line[3]|$line[1]|$line[2])\_($line[3]|$line[1]|$line[2])$/);
		print R "n235=$zuhe{$key}," if ($key =~ /^($line[1]|$line[2]|$line[4])\_($line[1]|$line[2]|$line[4])\_($line[1]|$line[2]|$line[4])$/);
		print R "n245=$zuhe{$key}," if ($key =~ /^($line[1]|$line[3]|$line[4])\_($line[1]|$line[3]|$line[4])\_($line[1]|$line[3]|$line[4])$/);
		
		print R "n345=$zuhe{$key}," if ($key =~ /^($line[2]|$line[3]|$line[4])\_($line[2]|$line[3]|$line[4])\_($line[2]|$line[3]|$line[4])$/);
		
		print R "n1234=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2]|$line[3])\_($line[0]|$line[1]|$line[2]|$line[3])\_($line[0]|$line[1]|$line[2]|$line[3])\_($line[0]|$line[1]|$line[2]|$line[3])$/);
		print R "n1235=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[4])$/);	
		print R "n1245=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[3]|$line[4])$/);	

		print R "n1345=$zuhe{$key}," if ($key =~ /^($line[0]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[2]|$line[3]|$line[4])$/);	
		print R "n2345=$zuhe{$key}," if ($key =~ /^($line[1]|$line[2]|$line[3]|$line[4])\_($line[1]|$line[2]|$line[3]|$line[4])\_($line[1]|$line[2]|$line[3]|$line[4])\_($line[1]|$line[2]|$line[3]|$line[4])$/);	
		
		print R "n12345=$zuhe{$key}," if ($key =~ /^($line[0]|$line[1]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[3]|$line[4])\_($line[0]|$line[1]|$line[2]|$line[3]|$line[4])$/);	
		
	}
print R "\)\ndev.off\(\)";
close R;	
	}
    #`/NJPROJ2/MICRO/share/software/R-3.3.3/bin/R -f $opt{outdir}/$r.R`; 
    `$R -f $opt{outdir}/$r.R`; 
   # `/usr/bin/convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;	
    `$convert -density 150 $opt{outdir}/$r.pdf $opt{outdir}/$r.png`;	

}
close IN;
