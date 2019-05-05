my %clone;
my %cloneinfo;
my $f = shift;
open F, $f;
$head = <F>;
while(<F>){
	chomp;
	my $cdr3 = (split/\t/,$_)[2];
	$clone{$cdr3}++;
	push @{$cloneinfo{$cdr3}},$_;
}
close F;

foreach $cdr3(keys %clone){
	if($clone{$cdr3} >1){
		print $cdr3."\n".join("\n",@{$cloneinfo{$cdr3}})."\n";
	}
}
