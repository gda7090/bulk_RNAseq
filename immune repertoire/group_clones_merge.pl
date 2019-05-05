my $indir=shift;
my $clones = shift;
my $prefix = shift;
my @clones = split/,/,$clones;
my $sampleNum = @clones;
my $head;
my %cdr3toinfo;
my $totalCloneCount;
open O, ">$prefix\.specifc.clones.txt";
foreach my $clone(@clones){
    my $lineNum=0;
    for(`less "$indir/$clone/$clone\.specifc.clones.txt"`){
	chomp;
	if($lineNum eq 0){
		$head = $_;
		$lineNum++;
	}
	else{
	my @arr = split/\t/,$_;
	my @cloneinfo = (split/\t/,$_)[2..7];
	my $cloneinfo = join(",",@cloneinfo);
	my $cloneCount = (split/\t/,$_)[1];
	$cdr3toinfo{$cloneinfo} += $cloneCount;
	$totalCloneCount += $cloneCount;
	}
    }
}

print O "$head\n";
my @cloneinfo = sort { $cdr3toinfo{$b} <=> $cdr3toinfo{$a} } keys %cdr3toinfo;
my $cloneIndex=0;
foreach my $clone(@cloneinfo){
	my @clone = split/,/,$clone;
	my $count = $cdr3toinfo{$clone};
	$count /= $sampleNum;
	my $cloneFraction = $count/$totalCloneCount;
	unshift @clone, ($cloneIndex,$count);
	push @clone,$cloneFraction; 
	print O join("\t",@clone)."\n";	
	$cloneIndex++;
}
close O;

			
