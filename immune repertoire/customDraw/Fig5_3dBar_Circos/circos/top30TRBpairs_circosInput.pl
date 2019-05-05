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
			my $key = "$Vgene\_$Jgene";
			$TRBpairs{$key}= $values;
		}
	}
}
close F;
	
my @vjpairs =  sort { $TRBpairs{$b} <=> $TRBpairs{$a} } keys %TRBpairs;
my @top_vjpairs = @vjpairs[0..($topN-1)];
my (%Vgenes,%Jgenes);
foreach (@top_vjpairs){
	my ($Vgene,$Jgene) = split/_/,$_;
	$Vgenes{$Vgene} = 1;
	$Jgenes{$Jgene} = 1;
}

my @Vgenes = keys %Vgenes;
print "\.\t".join("\t",@Vgenes)."\n";
foreach my $Jgene(keys %Jgenes){
	my @vjlines;
	push @vjlines,$Jgene;
	foreach my $Vgene(@Vgenes){
		my $vjpair = "$Vgene\_$Jgene";
		if(exists $TRBpairs{$vjpair}){
			push @vjlines,$TRBpairs{$vjpair};
		}else{
			push @vjlines,"0.0";
		}
	}
	print join("\t",@vjlines)."\n";
}


	


