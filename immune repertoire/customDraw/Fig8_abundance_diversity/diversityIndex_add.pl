use Math::Complex;
my $f = shift;
open F, $f;
my @print;
chomp(my $head = <F>);
push @print, $head;
my ($richness, $shannon, $simpson);
while(<F>){
	chomp;
	push @print, $_;
	my @arr = split/\t/,$_;
	my ($q, $D) = @arr[0..1];
	if($q eq 0){
		$richness = $D;
		push @index, $richness;
	}
	if($q eq 1){
		$shannon = ln($D);
		push @index, $shannon;
	}
	if($q eq 2) {
		$simpson = 1/$D;
	}
}
close F;
my $index_string = "#Richness: $richness\tShannon Index: $shannon\tSimpson Index: $simpson";
unshift @print, $index_string;
print join("\n",@print)."\n";

