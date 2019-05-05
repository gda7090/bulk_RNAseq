my $f = shift;
chomp(my $head = <F>);
print $head."\n";
open F, $f;
while(<F>){
	chomp;
	my @arr = split/\t/,$_;
	my $sum;
	my $last = $#arr-1;
	foreach my $i(2..$last){
		$sum += $arr[$i];
	}
	$arr[$#arr]=1-$sum;
	print join("\t",@arr)."\n";
}
close F;
