my $f  = shift;
open F, $f;
my $head = <F>;
print $head;
while(<F>){
	chomp;
        my @arr = split/\t/,$_;
	if($arr[4] =~ /TRA|IGH|IGL|IGK/ or $arr[5] =~ /TRA|IGH|IGL|IGK/ or $arr[6] =~ /TRA|IGH|IGL|IGK/){
		next;
	}
	print $_."\n";
}
close F;
			
