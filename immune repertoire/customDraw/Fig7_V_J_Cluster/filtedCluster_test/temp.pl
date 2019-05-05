my $f = shift;
open F, $f;
chomp(my $head = <F>);
my @head = split/\t/,$head;
my @except = qw(IGHJ3	IGHJ4	IGKJ1	IGKJ4	TRAJ52 TRBJ1-4 TRBJ1-6 TRBJ1-3 TRBJ2-4 TRBJ2-6 TRBJ1-5);
my %except;
foreach(@except){
	$except{$_} = 1;
}
my @index;
foreach my $index(0..$#head){
	if(not exists $except{$head[$index]}){
		push @index, $index;
	}
}
print join("\t",@head[@index])."\n";
while(<F>){
	chomp;
	my @arr = split/\t/,$_;
	@arr = @arr[@index];
	print join("\t",@arr)."\n";
}
close F;
