print "Vgene\tJgene\tabundance\n";
my $circos_input = shift;
my $topN = shift;
my %TRBpairs;
open F, $circos_input;
chomp(my $head = <F>);
my @head = split/\t/,$head;
while(<F>){
	chomp;
	my @arr = split/\t/,$_;
	my $Jgene = $arr[0];
	foreach my $index(1..$#arr){
		my $Vgene = $head[$index];
		my $values = $arr[$index];
		if($Jgene =~ /TRBJ/ and $Vgene =~ /TRBV/){
			my $key = "$Vgene\t$Jgene";
			$TRBpairs{$key}= $values;
		}
	}
}
close F;
	
my @vjpairs =  sort { $TRBpairs{$b} <=> $TRBpairs{$a} } keys %TRBpairs;
my @top_vjpairs = @vjpairs[0..($topN-1)];
foreach (@top_vjpairs){
	print "$_\t$TRBpairs{$_}\n";
}
