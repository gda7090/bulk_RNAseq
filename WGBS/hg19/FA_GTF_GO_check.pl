#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
####################################
#modified by zcy
#2014-10-29
###################################
sub usage
{
	print STDERR <<USAGE;
==============================================================================
Description	to check whether gtf, fa and GO match for DNA_methylation pipeline

Options
	-fa <s>: *.fa
	-gtf <s>: *.gtf
	-go <s>: goann
	-h|?|help  :  Show this help
==============================================================================
USAGE
}


my ($help, $fa, $gtf, $go);
GetOptions(
        "h|?|help"=>\$help,
	"fa=s"=>\$fa,
	"gtf=s"=>\$gtf,
	"go=s"=>\$go,
);

if(!defined($fa) || !defined($gtf) || !defined($go) || defined($help)){
        &usage;
        exit 0;
}

#`sed -e 's/[ \t|+].*//g' $fa > $outfile.fa`;
#`sed -i '/^\$/d' $outfile.fa`;
#`awk '{if(\$3=="exon"){print \$0}}' $gtf > $outfile.gtf.tmp`;
#`msort -k mf1 -k nf4 $outfile.gtf.tmp > $outfile.gtf`;
#`grep '>' $outfile.fa > $outfile.fa.tmp`;
unless($gtf=~ /\.gtf$/ && $fa =~ /\.fa$|\.fasta$/){
	print "Error: the Extension Names of FA and GTF files must be .fa/.fasta and .gtf!\n";
	exit 0;
}	
	
open GTF, "< $gtf";
open FA, "< $fa";
if ($go ne "No"){
	open GO, "< $go";}

my %chr;
my %len;
my $fachr;
my $faline=-1;
my $length1=0;
my $length2=0;
#begin to read *.fa/*.fasta files
while(<FA>)
{
	chomp;
	$faline++;
	if(/^>\S+[ \t|+].*$/){
		print "Error($fa;line:$faline): Please make sure that there is nothing after the chromosome name in the file $fa\nthe command such as sed -i -e \'s/[ \\t|+].*//g\' $fa!\n";
		exit 0;
	}elsif(/^>(.*)$/){
		if($faline>0 && !defined($len{$fachr})){
			print "Error($fa;line:$faline): the chromosome \"$fachr\" has no sequences!\n";
			exit 0;
		}
		$length1=0;
		$length2=0;
		$fachr=$_;
		$fachr=~ s/^>//;
		$chr{$fachr}=1;
	}elsif(/^$/){
		print "Error($fa;line:$faline): Please delete blank lines in the file $fa\nthe command such as sed -i \'/^\$/d\' $fa!\n";
		exit 0;
	}else{ 
		if($length1 != $length2){
			print "Error($fa;line:$faline): the rows of file $fa does not have the same length!\n";
			exit 0;
		}
		if($length1==0){
			$length1=length($_);
		}
		$length2=length($_);
		$len{$fachr}+=length($_);
	}
			
}

#begin to read .gtf file
my %gene;
my $gtfline=0;
while(<GTF>)
{
	chomp;
	$gtfline++;
	my @line = split /\t/, $_;
	for(my $i=0;$i<8;$i++){
		if($line[$i]=~ /\s/){
			print "Error($gtf;line:$gtfline): \"$line[$i]\" has error Character(such as \" \")!\n";
			exit 0;
		}
	}
	if(!defined($chr{$line[0]})){
		print "Error($gtf;line:$gtfline): ".$line[0]." is not found in $fa!\n";
		exit 0;
	}elsif($line[3]>$line[4]){
		print "Error($gtf;line:$gtfline): geneStart:$line[3]>geneEnd:$line[4]!\n";
		exit 0;
	}elsif($line[4]>$len{$line[0]}){
		print "Error($gtf;line:$gtfline): geneEnd:$line[4] is larger than the length of chromosome $line[0]!\n";
		exit 0;
	}elsif($line[6] ne "+" && $line[6] ne "-"){
		print "Error($gtf;line:$gtfline): strand is not sure!\n";
		exit 0;
	}elsif($line[8]=~/[^"];/){
		print "Error($gtf;line:$gtfline): unexpected \";\" in $line[8]!\n";
		exit 0;
	}
	if($line[8]=~/gene_id "(.*?)"/){
		$gene{$1}=1;
	}else{
		print "Error($gtf;line:$gtfline): something is wrong in $line[8]!\n";
		exit 0;
	}
}

my $go_pl="delGOduplication.pl";
my %hash;
my $goline=0;
while(<GO>){
	chomp;
	$goline++;
	if(/\t$/){
		print "Error($go;line:$goline): unexpected \"\\t\"!\nyou can do\nperl $go_pl $go out.go\n";
		exit 0;
	}
	my @line=split /\t/,$_;
	my $id=shift @line;
	if(!defined($gene{$id})){
		print "Error($go;line:$goline): geneID \"$id\" is not in $gtf!\n";
		exit 0;
	}elsif(defined($hash{$id})){
		print "Error($go;line:$goline): duplicate geneID $id!\nyou can do\nperl $go_pl $go out.go\n";
		exit 0;
	}else{
		if(@line>0){
			foreach my $goterm(@line){
				if(defined($goterm)){
					if($goterm=~ /^GO:\d{7}$/){
						if(defined($hash{$id}{$goterm})){
							print "Error($go;line:$goline): duplicate $goterm for geneID $id!\nyou can do\nperl $go_pl $go out.go\n";
							exit 0;
						}else{
							$hash{$id}{$goterm}=1;
						}
					}else{
						print "Error($go;line:$goline): unexpected $goterm!\n";
						exit 0;
					}
				}else{
					print "Error($go;line:$goline): unexpected characters!\nyou can do\nperl $go_pl $go out.go\n";
					exit 0;
				}
			}
		}else{
			print "Error($go;line:$goline): geneID \"$id\" has no GO annotation!\nyou can do\nperl $go_pl $go out.go\n";
			exit 0;
		}
	}
}
		
close GTF;
close FA;
close GO;
