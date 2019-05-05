#!/usr/bin/perl -w
use strict;

unless (@ARGV == 4) {
	die"Usage: perl $0   diff.list(diff_top_genes)  6(top6)  Jgenetab.relative.xls(abun) group.list > output.table
	output format: geneid relative_abundance  sample  group\n";
}

my ($diff,$top,$tab,$group) = @ARGV;

# the groups have which top6 genes?
my %group2genes;
my @groups;
for (`less $diff`){
	chomp;
	my $group=$1 if $_=~/(\w+)-vs-NC/;
	push @groups,$group;
	my $withead=$top+1;
	open(IN,$_);<IN>;
	my $n=1;
	while(<IN>){
		chomp(my $line=<IN>);
		my $geneid=(split/\t/,$line)[0];
		push @{$group2genes{$group}}, $geneid;
		$n++;
		$n>$top && last;
	}
	close IN;

}

my %group2smps;
for(`less $group`){
	chomp;
	my @tmps=split/\t/,$_;
	push @{$group2smps{$tmps[1]}},$tmps[0];
}
# = split/\s+/,`less $group`;

my %gene2smp2abu;
open (TAB,$tab);
chomp(my $head=<TAB>);
my @heads=split/\t/,$head;
while(<TAB>){
	chomp;
	my @tmp=split/\t/,$_;
	for my $i (1..$#tmp){
		$gene2smp2abu{$tmp[0]}{$heads[$i]}=$tmp[$i]
	}
}
close TAB;

print "geneid\trelative_abu\tsample\tgroup\n";
for my $g (@groups){
	for my $gene (@{$group2genes{$g}}){
		for my $smp (@{$group2smps{$g}}){
			print "$gene\t$gene2smp2abu{$gene}{$smp}\t$smp\t$g\n";

		}
	}
}

