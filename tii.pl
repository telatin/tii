#!/usr/bin/env perl
use 5.014;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib/";
use WWW::Pastebin::PastebinCom::API;
use File::Spec::Functions;
use Getopt::Long;
our $VERSION = '1.0';
my $api_key = get_api_key();
my $opt_title   = 'tii paste';
my $opt_format;
my $opt_expire  = 'N';
my $opt_help;
my $opt_silent;
my $program_break = 0;
my $opt_append;
my $opt_listed;
my $opt_private;
my $opt_verbose;
my $opt_test;
# Gently stop reading STDIN if Ctrl+C is pressed
$SIG{INT} = sub { 
	print STDERR "Received Ctrl+C; will finish reading STDIN and create the paste. Press again to quit immediately.\n"; 
	$program_break++; 
	exit if ($program_break > 1);
};

my $_opt = GetOptions(
  'a|append'   => \$opt_append,
  's|silent'   => \$opt_silent,

  'k|apikey=s' => \$api_key,
  't|title=s'  => \$opt_title,
  'f|format=s' => \$opt_format,
  'e|expire=s' => \$opt_expire,
  'l|listed'   => \$opt_listed,
  'p|private'  => \$opt_private,
  'h|help'     => \$opt_help,
  'v|verbose'  => \$opt_verbose,
  'test'       => \$opt_test,
  
);

my $unlisted = 1;
$unlisted = 0 if ($opt_listed or $opt_private);


if ($opt_test) {
	say STDERR "Exiting test...";
	exit;
}
unless ($api_key) { 
	die "Pastebin.com api key not found in ~/.pastebin neither supplied via -k (--apikey)\n";
}

usage() if ($opt_help);

my $bin = WWW::Pastebin::PastebinCom::API->new(
	api_key => "$api_key",
);

my $data = '';
my $O;
if (defined $ARGV[0]) {
	if (defined $opt_append) {
		open $O, '>>', "$ARGV[0]" || die "Unable to write to output file: $ARGV[0]\n";
	} else {
		open $O, '>', "$ARGV[0]" || die "Unable to write to output file: $ARGV[0]\n";

	}
}
my $count_lines = 0;
while (my $line = <STDIN>) {
	last if ($program_break);
	$data .= $line;
	say $data if (not defined $opt_silent);
	say {$O} $data if (defined $ARGV[0]);
	$count_lines++;	
}

if ($data) {
	my $url = $bin->paste($data,
		title => $opt_title,
		format => $opt_format,
		expire => $opt_expire,
		unlisted => $unlisted,
		private => $opt_private,
           ) || die "$bin";

	if ($opt_silent) {
		say $url;
	} else {
		say STDERR "$url";
	}
	say STDERR "#$count_lines lines received." if ($opt_verbose);
} else {
	say STDERR "No data received\n";
}


sub get_api_key {
	my $api_file = catfile($ENV{'HOME'} , '.pastebin');
	my $key;
	local *STDERR;
	open  STDERR, '>', File::Spec->devnull() or die "could not open STDERR: $!\n";
	my $readkey = eval {
		open my $i, '<', $api_file;
		$key = readline($i);
		chomp($key);	
		1;
	};
	
	$key = 'not_found' unless ($readkey);
	return $key;
}

sub usage {
  say STDERR<<END;

  cat file.txt | tii [options] [filename]
  --------------------------------------------------------------------------
  Like tee, but will create a pastebin.com entry with your text.

  Options:
    -a, --append          Append to filename rather than overwriting

    -s, --silent          Will not print the stream to STDOUT

    -k, --apikey          Pastebin.com api key.
                          Can be stored (alone) in the ~/.pastebin file

    -t, --title           Pastebin title [default: $opt_title]

    -f, --format          Syntax highlight like: perl, php, javascript, python..

    -e, --expiry          Default N (never). Alternatives: 10M (10 minutes), 
                          1H (1 hour), 1D (1 day), 1W (1 week), 1M (1 month), 
                          6M (6 months),1Y (1 year)

    -l, --listed          Make the pasted listed [default: publica but unlisted]
    
    -p, --private         Make the pasted text private [overrides -l]
                     
    -v, --verbose         Print further informations     
END
 exit;
}


__END__