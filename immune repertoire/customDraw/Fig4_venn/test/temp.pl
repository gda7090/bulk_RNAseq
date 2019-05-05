my %hash;
my $f = shift;
open F, $f;
while(<F>){
	chomp;
	my @arr = split/\t/,$_;
	my $cdr3aa= @arr[3];
	$hash{$cdr3aa} = 1;
}
close F;

my %hash2;
my $com;
my $com2;
$f = shift;
open F, $f;
while(<F>){
        chomp;
        my @arr = split/\t/,$_;
        my $cdr3aa= @arr[3];
	if(not exists $hash2{$cdr3aa}){
		$hash2{$chr3aa} = 1;
		if(exists $hash{$cdr3aa}){
			$com++;
		}
	}else{
		next;
	}
}
close F;

print $com."\n";

