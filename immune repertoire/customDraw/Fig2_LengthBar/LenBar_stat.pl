#!/usr/bin/perl
use strict;

my @clone_calc;
my @gene_calc;
my $f = shift;
open F, $f;
print "gene name\tclone count\tclone frequency\tgene count\tgene frequency\n";
while(<F>){
	chomp;
	my @arr = split/\t/,$_;
	print join("\t",@arr)."\n";
	push @clone_calc,$arr[2];
	push @gene_calc, $arr[4];
}
close F;

my @clone_rank = sort{$a<=>$b} @clone_calc;
my $clone_min = $clone_rank[0];
my $clone_max = $clone_rank[$#clone_rank];
my $clone_sd = &var(\@clone_calc);
my @gene_rank = sort{$a<=>$b} @gene_calc;
my $gene_min = $gene_rank[0];
my $gene_max = $gene_rank[$#gene_rank];
my $gene_sd = &var(\@gene_calc);

print "#Min clone frequency: $clone_min\tMax clone frequency: $clone_max\t clone frequency SD: $clone_sd
#Min gene frequency: $gene_min\tMax gene frequency: $gene_max\t gene frequency SD: $gene_sd\n";

sub aver{
    my $arr = shift;
    my $s = 0;
    grep {$s += $_}@$arr;
    return $s/@$arr;
}
sub var {
    my $arr = shift;
    my $v = aver($arr);
    my $d = 0;
    grep {$d += ($_-$v)**2;}@$arr;
    my $s = @$arr;
    $d = sqrt($d/($s-1));
    return $d;
}
sub var2 {
    my $arr = shift;
    my $v = aver($arr);
    my $d = 0;
    grep {$d += ($_-$v)**2;}@$arr;
    return $d;
}
