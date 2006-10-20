# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.
# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..41\n"; }
END {print "not ok 1\n" unless $loaded;}

#use diagnostics;
use Net::DNS::ToolKit qw(
	newhead
	put_qdcount
	put_ancount
	get1char
	inet_aton
);
use Net::DNS::ToolKit::RR;
use Net::DNS::ToolKit::Debug qw(
	print_head
	print_buf
);
use Net::DNS::Codes qw(:all);

use Net::Bind::rbldnsdAccessor qw(
	:isc_constants
	rblf_create_zone
	rblf_query
	rblf_next_answer
	cons_str
	rblf_dump_packet
);

$loaded = 1;
print "ok 1\n";
######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$test = 2;

sub ok {
  print "ok $test\n";
  ++$test;
}

sub expect {
  my $x = shift;
  my @exp;
  foreach(split(/\n/,$x)) {
    if ($_ =~ /0x\w+\s+(\d+) /) {
      push @exp,$1;
    }
  }
  return @exp;
}

sub print_ptrs {
  foreach(@_) {
    print "$_ ";
  }
  print "\n";
}

sub chk_exp {
  my($bp,$exp) = @_;
  my @expect = expect($$exp);
  foreach(0..length($$bp) -1) {
    $char = get1char($bp,$_);
    next if $char == $expect[$_];
    print "buffer mismatch $_, got: $char, exp: $expect[$_]\nnot ";
    last;
  }
  &ok;
}

my $success = &ISC_R_SUCCESS;
my $notfound = &ISC_R_NOTFOUND;
my $zone1 = 'datasets/bl.my.zone.one.combined';
my $zone2 = 'datasets/bl.my.zone2.com.ip4set';
my $zone3 = 'datasets/bl.my.zone3.org.ip4tset';

# input: file above
# return zone,type,file
sub ztype {
  (my $zfile = shift) =~ m|[^/]+/(.+)\.(\w+)$|;
  return ($1,$2,$zfile);
}
  
## test 2	create zone3
my($zone,$ztype,$file) = ztype($zone3);
my $rv = rblf_create_zone($zone,$ztype,$file);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

$zone3 = $zone;
## test 3	create zone2
($zone,$ztype,$file) = ztype($zone2);
$rv = rblf_create_zone($zone,$ztype,$file);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

$zone2 = $zone;
## test 4	create zone1
($zone,$ztype,$file) = ztype($zone1);
$rv = rblf_create_zone($zone,$ztype,$file);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

$zone1 = $zone;
## test 5	check zone1 root
my $answers;
#		check number of answers
($answers,$rv) = rblf_query($zone);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

## test 6	check number of answers
print "got: $answers, exp: 6\nnot "
	unless $answers == 6;
&ok;

## test 7	check packet info
my $exptext = q(
  0     :  0000_0000  0x00    0    
  1     :  0000_0000  0x00    0    
  2     :  0000_0000  0x00    0    
  3     :  0000_0000  0x00    0    
  4     :  0000_0000  0x00    0    
  5     :  0000_0000  0x00    0    
  6     :  0000_0000  0x00    0    
  7     :  0000_0110  0x06    6    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0010  0x02    2    
  13    :  0110_0010  0x62   98  b  
  14    :  0110_1100  0x6C  108  l  
  15    :  0000_0010  0x02    2    
  16    :  0110_1101  0x6D  109  m  
  17    :  0111_1001  0x79  121  y  
  18    :  0000_0100  0x04    4    
  19    :  0111_1010  0x7A  122  z  
  20    :  0110_1111  0x6F  111  o  
  21    :  0110_1110  0x6E  110  n  
  22    :  0110_0101  0x65  101  e  
  23    :  0000_0011  0x03    3    
  24    :  0110_1111  0x6F  111  o  
  25    :  0110_1110  0x6E  110  n  
  26    :  0110_0101  0x65  101  e  
  27    :  0000_0000  0x00    0    
  28    :  0000_0000  0x00    0    
  29    :  0000_0000  0x00    0    
  30    :  0000_0000  0x00    0    
  31    :  0000_0000  0x00    0    
  32    :  1100_0000  0xC0  192    
  33    :  0000_1100  0x0C   12    
  34    :  0000_0000  0x00    0    
  35    :  0000_0110  0x06    6    
  36    :  0000_0000  0x00    0    
  37    :  0000_0001  0x01    1    
  38    :  0000_0000  0x00    0    
  39    :  0000_0000  0x00    0    
  40    :  0000_0010  0x02    2    
  41    :  0101_1000  0x58   88  X  
  42    :  0000_0000  0x00    0    
  43    :  0001_1111  0x1F   31    
  44    :  1100_0000  0xC0  192    
  45    :  0000_1100  0x0C   12    
  46    :  0000_0110  0x06    6    
  47    :  0111_0011  0x73  115  s  
  48    :  0111_1001  0x79  121  y  
  49    :  0111_0011  0x73  115  s  
  50    :  0110_0001  0x61   97  a  
  51    :  0110_0100  0x64  100  d  
  52    :  0110_1101  0x6D  109  m  
  53    :  1100_0000  0xC0  192    
  54    :  0000_1111  0x0F   15    
  55    :  0100_0101  0x45   69  E  
  56    :  0011_0010  0x32   50  2  
  57    :  1000_0101  0x85  133    
  58    :  0011_0010  0x32   50  2  
  59    :  0000_0000  0x00    0    
  60    :  0000_0000  0x00    0    
  61    :  1010_1000  0xA8  168    
  62    :  1100_0000  0xC0  192    
  63    :  0000_0000  0x00    0    
  64    :  0000_0000  0x00    0    
  65    :  0000_0011  0x03    3    
  66    :  1000_0100  0x84  132    
  67    :  0000_0000  0x00    0    
  68    :  0000_0010  0x02    2    
  69    :  1010_0011  0xA3  163    
  70    :  0000_0000  0x00    0    
  71    :  0000_0000  0x00    0    
  72    :  0000_0000  0x00    0    
  73    :  1010_1000  0xA8  168    
  74    :  1100_0000  0xC0  192    
  75    :  1100_0000  0xC0  192    
  76    :  0000_1100  0x0C   12    
  77    :  0000_0000  0x00    0    
  78    :  0000_0010  0x02    2    
  79    :  0000_0000  0x00    0    
  80    :  0000_0001  0x01    1    
  81    :  0000_0000  0x00    0    
  82    :  0000_0000  0x00    0    
  83    :  1010_1000  0xA8  168    
  84    :  1100_0000  0xC0  192    
  85    :  0000_0000  0x00    0    
  86    :  0000_0010  0x02    2    
  87    :  1100_0000  0xC0  192    
  88    :  0000_1100  0x0C   12    
  89    :  1100_0000  0xC0  192    
  90    :  0000_1100  0x0C   12    
  91    :  0000_0000  0x00    0    
  92    :  0000_0010  0x02    2    
  93    :  0000_0000  0x00    0    
  94    :  0000_0001  0x01    1    
  95    :  0000_0000  0x00    0    
  96    :  0000_0000  0x00    0    
  97    :  1010_1000  0xA8  168    
  98    :  1100_0000  0xC0  192    
  99    :  0000_0000  0x00    0    
  100   :  0001_0100  0x14   20    
  101   :  0000_0011  0x03    3    
  102   :  0110_1110  0x6E  110  n  
  103   :  0111_0011  0x73  115  s  
  104   :  0011_0001  0x31   49  1  
  105   :  0000_1010  0x0A   10    
  106   :  0110_1110  0x6E  110  n  
  107   :  0110_0001  0x61   97  a  
  108   :  0110_1101  0x6D  109  m  
  109   :  0110_0101  0x65  101  e  
  110   :  0111_0011  0x73  115  s  
  111   :  0110_0101  0x65  101  e  
  112   :  0111_0010  0x72  114  r  
  113   :  0111_0110  0x76  118  v  
  114   :  0110_0101  0x65  101  e  
  115   :  0111_0010  0x72  114  r  
  116   :  0000_0011  0x03    3    
  117   :  0110_1110  0x6E  110  n  
  118   :  0110_0101  0x65  101  e  
  119   :  0111_0100  0x74  116  t  
  120   :  0000_0000  0x00    0    
  121   :  1100_0000  0xC0  192    
  122   :  0000_1100  0x0C   12    
  123   :  0000_0000  0x00    0    
  124   :  0000_0010  0x02    2    
  125   :  0000_0000  0x00    0    
  126   :  0000_0001  0x01    1    
  127   :  0000_0000  0x00    0    
  128   :  0000_0000  0x00    0    
  129   :  1010_1000  0xA8  168    
  130   :  1100_0000  0xC0  192    
  131   :  0000_0000  0x00    0    
  132   :  0000_0110  0x06    6    
  133   :  0000_0011  0x03    3    
  134   :  0110_1110  0x6E  110  n  
  135   :  0111_0011  0x73  115  s  
  136   :  0011_0100  0x34   52  4  
  137   :  1100_0000  0xC0  192    
  138   :  0110_1001  0x69  105  i  
  139   :  1100_0000  0xC0  192    
  140   :  0000_1100  0x0C   12    
  141   :  0000_0000  0x00    0    
  142   :  0000_0001  0x01    1    
  143   :  0000_0000  0x00    0    
  144   :  0000_0001  0x01    1    
  145   :  0000_0000  0x00    0    
  146   :  0000_0000  0x00    0    
  147   :  1010_1000  0xA8  168    
  148   :  1100_0000  0xC0  192    
  149   :  0000_0000  0x00    0    
  150   :  0000_0100  0x04    4    
  151   :  0000_1010  0x0A   10    
  152   :  0000_0110  0x06    6    
  153   :  0111_0000  0x70  112  p  
  154   :  1110_0010  0xE2  226    
  155   :  1100_0000  0xC0  192    
  156   :  0000_1100  0x0C   12    
  157   :  0000_0000  0x00    0    
  158   :  0000_0001  0x01    1    
  159   :  0000_0000  0x00    0    
  160   :  0000_0001  0x01    1    
  161   :  0000_0000  0x00    0    
  162   :  0000_0000  0x00    0    
  163   :  1010_1000  0xA8  168    
  164   :  1100_0000  0xC0  192    
  165   :  0000_0000  0x00    0    
  166   :  0000_0100  0x04    4    
  167   :  0000_1010  0x0A   10    
  168   :  0000_0110  0x06    6    
  169   :  0111_0000  0x70  112  p  
  170   :  1110_0000  0xE0  224    
);
my($len,$packet,$pbuf,$pcur,$psans,$pend,$coff,$aoff) = rblf_dump_packet();
#print "pcur = $pcur\npsans = $psans\npend = $pend\ncoff = $coff\naoff = $aoff\nlen  = $len\n";
#print_buf(\$packet);
chk_exp(\$packet,\$exptext);

## test 8	verify answers
my ($get,$put,$parse) = new Net::DNS::ToolKit::RR;

my @answers = (
	T_SOA, 600, 56, q(
  0     :  0000_0010  0x02    2    
  1     :  0110_0010  0x62   98  b  
  2     :  0110_1100  0x6C  108  l  
  3     :  0000_0010  0x02    2    
  4     :  0110_1101  0x6D  109  m  
  5     :  0111_1001  0x79  121  y  
  6     :  0000_0100  0x04    4    
  7     :  0111_1010  0x7A  122  z  
  8     :  0110_1111  0x6F  111  o  
  9     :  0110_1110  0x6E  110  n  
  10    :  0110_0101  0x65  101  e  
  11    :  0000_0011  0x03    3    
  12    :  0110_1111  0x6F  111  o  
  13    :  0110_1110  0x6E  110  n  
  14    :  0110_0101  0x65  101  e  
  15    :  0000_0000  0x00    0    
  16    :  0000_0110  0x06    6    
  17    :  0111_0011  0x73  115  s  
  18    :  0111_1001  0x79  121  y  
  19    :  0111_0011  0x73  115  s  
  20    :  0110_0001  0x61   97  a  
  21    :  0110_0100  0x64  100  d  
  22    :  0110_1101  0x6D  109  m  
  23    :  0000_0010  0x02    2    
  24    :  0110_1101  0x6D  109  m  
  25    :  0111_1001  0x79  121  y  
  26    :  0000_0100  0x04    4    
  27    :  0111_1010  0x7A  122  z  
  28    :  0110_1111  0x6F  111  o  
  29    :  0110_1110  0x6E  110  n  
  30    :  0110_0101  0x65  101  e  
  31    :  0000_0011  0x03    3    
  32    :  0110_1111  0x6F  111  o  
  33    :  0110_1110  0x6E  110  n  
  34    :  0110_0101  0x65  101  e  
  35    :  0000_0000  0x00    0    
  36    :  0100_0101  0x45   69  E  
  37    :  0011_0010  0x32   50  2  
  38    :  1000_0101  0x85  133    
  39    :  0011_0010  0x32   50  2  
  40    :  0000_0000  0x00    0    
  41    :  0000_0000  0x00    0    
  42    :  1010_1000  0xA8  168    
  43    :  1100_0000  0xC0  192    
  44    :  0000_0000  0x00    0    
  45    :  0000_0000  0x00    0    
  46    :  0000_0011  0x03    3    
  47    :  1000_0100  0x84  132    
  48    :  0000_0000  0x00    0    
  49    :  0000_0010  0x02    2    
  50    :  1010_0011  0xA3  163    
  51    :  0000_0000  0x00    0    
  52    :  0000_0000  0x00    0    
  53    :  0000_0000  0x00    0    
  54    :  1010_1000  0xA8  168    
  55    :  1100_0000  0xC0  192    
),
	T_NS, 43200, 16, q(
  0     :  0000_0010  0x02    2    
  1     :  0110_0010  0x62   98  b  
  2     :  0110_1100  0x6C  108  l  
  3     :  0000_0010  0x02    2    
  4     :  0110_1101  0x6D  109  m  
  5     :  0111_1001  0x79  121  y  
  6     :  0000_0100  0x04    4    
  7     :  0111_1010  0x7A  122  z  
  8     :  0110_1111  0x6F  111  o  
  9     :  0110_1110  0x6E  110  n  
  10    :  0110_0101  0x65  101  e  
  11    :  0000_0011  0x03    3    
  12    :  0110_1111  0x6F  111  o  
  13    :  0110_1110  0x6E  110  n  
  14    :  0110_0101  0x65  101  e  
  15    :  0000_0000  0x00    0    
),
	T_NS, 43200, 20, q(
  0     :  0000_0011  0x03    3    
  1     :  0110_1110  0x6E  110  n  
  2     :  0111_0011  0x73  115  s  
  3     :  0011_0001  0x31   49  1  
  4     :  0000_1010  0x0A   10    
  5     :  0110_1110  0x6E  110  n  
  6     :  0110_0001  0x61   97  a  
  7     :  0110_1101  0x6D  109  m  
  8     :  0110_0101  0x65  101  e  
  9     :  0111_0011  0x73  115  s  
  10    :  0110_0101  0x65  101  e  
  11    :  0111_0010  0x72  114  r  
  12    :  0111_0110  0x76  118  v  
  13    :  0110_0101  0x65  101  e  
  14    :  0111_0010  0x72  114  r  
  15    :  0000_0011  0x03    3    
  16    :  0110_1110  0x6E  110  n  
  17    :  0110_0101  0x65  101  e  
  18    :  0111_0100  0x74  116  t  
  19    :  0000_0000  0x00    0    
),
	T_NS, 43200, 20, q(
  0     :  0000_0011  0x03    3    
  1     :  0110_1110  0x6E  110  n  
  2     :  0111_0011  0x73  115  s  
  3     :  0011_0100  0x34   52  4  
  4     :  0000_1010  0x0A   10    
  5     :  0110_1110  0x6E  110  n  
  6     :  0110_0001  0x61   97  a  
  7     :  0110_1101  0x6D  109  m  
  8     :  0110_0101  0x65  101  e  
  9     :  0111_0011  0x73  115  s  
  10    :  0110_0101  0x65  101  e  
  11    :  0111_0010  0x72  114  r  
  12    :  0111_0110  0x76  118  v  
  13    :  0110_0101  0x65  101  e  
  14    :  0111_0010  0x72  114  r  
  15    :  0000_0011  0x03    3    
  16    :  0110_1110  0x6E  110  n  
  17    :  0110_0101  0x65  101  e  
  18    :  0111_0100  0x74  116  t  
  19    :  0000_0000  0x00    0    
),
	T_A, 43200, 4, q(
  0     :  0000_1010  0x0A   10    
  1     :  0000_0110  0x06    6    
  2     :  0111_0000  0x70  112  p  
  3     :  1110_0010  0xE2  226    
),
	T_A, 43200, 4, q(
  0     :  0000_1010  0x0A   10    
  1     :  0000_0110  0x06    6    
  2     :  0111_0000  0x70  112  p  
  3     :  1110_0000  0xE0  224    
),
);

my $off = $aoff;
for(my $i = 0;$i < $answers *4; $i += 4) {
  my($type,$ttl,$rdl,$rdata) = rblf_next_answer();
  print "TYPE got: ". $TypeTxt->{$type} .", exp: ". TypeTxt->{$answers[$i]} ."\nnot "
	unless $type == $answers[$i];
  &ok;
  print "TTL  got: $ttl, exp: $answers[$i +1]\nnot "
	unless $ttl == $answers[$i +1];
  &ok;
  print "RDL  got: $rdl, exp: $answers[$i +2]\nnot "
	unless $rdl == $answers[$i +2];
  &ok;
#  print_buf(\$rdata);
  chk_exp(\$rdata,\$answers[$i+3]);
}

## test 32	query for good RBL entry
#		check number of answers
my $lookup = '99.173.23.4.';
($answers,$rv) = rblf_query($lookup . $zone1);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

## test 33	check number of answers
print "got: $answers, exp: 6\nnot "
	unless $answers == 2;
&ok;

## test 34	check packet info
$exptext = q(
  0     :  0000_0000  0x00    0    
  1     :  0000_0000  0x00    0    
  2     :  0000_0000  0x00    0    
  3     :  0000_0000  0x00    0    
  4     :  0000_0000  0x00    0    
  5     :  0000_0000  0x00    0    
  6     :  0000_0000  0x00    0    
  7     :  0000_0010  0x02    2    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0010  0x02    2    
  13    :  0011_1001  0x39   57  9  
  14    :  0011_1001  0x39   57  9  
  15    :  0000_0011  0x03    3    
  16    :  0011_0001  0x31   49  1  
  17    :  0011_0111  0x37   55  7  
  18    :  0011_0011  0x33   51  3  
  19    :  0000_0010  0x02    2    
  20    :  0011_0010  0x32   50  2  
  21    :  0011_0011  0x33   51  3  
  22    :  0000_0001  0x01    1    
  23    :  0011_0100  0x34   52  4  
  24    :  0000_0010  0x02    2    
  25    :  0110_0010  0x62   98  b  
  26    :  0110_1100  0x6C  108  l  
  27    :  0000_0010  0x02    2    
  28    :  0110_1101  0x6D  109  m  
  29    :  0111_1001  0x79  121  y  
  30    :  0000_0100  0x04    4    
  31    :  0111_1010  0x7A  122  z  
  32    :  0110_1111  0x6F  111  o  
  33    :  0110_1110  0x6E  110  n  
  34    :  0110_0101  0x65  101  e  
  35    :  0000_0011  0x03    3    
  36    :  0110_1111  0x6F  111  o  
  37    :  0110_1110  0x6E  110  n  
  38    :  0110_0101  0x65  101  e  
  39    :  0000_0000  0x00    0    
  40    :  0000_0000  0x00    0    
  41    :  0000_0000  0x00    0    
  42    :  0000_0000  0x00    0    
  43    :  0000_0000  0x00    0    
  44    :  1100_0000  0xC0  192    
  45    :  0000_1100  0x0C   12    
  46    :  0000_0000  0x00    0    
  47    :  0000_0001  0x01    1    
  48    :  0000_0000  0x00    0    
  49    :  0000_0001  0x01    1    
  50    :  0000_0000  0x00    0    
  51    :  0000_0000  0x00    0    
  52    :  1010_1000  0xA8  168    
  53    :  1100_0000  0xC0  192    
  54    :  0000_0000  0x00    0    
  55    :  0000_0100  0x04    4    
  56    :  0111_1111  0x7F  127    
  57    :  0000_0000  0x00    0    
  58    :  0000_0000  0x00    0    
  59    :  0000_0010  0x02    2    
  60    :  1100_0000  0xC0  192    
  61    :  0000_1100  0x0C   12    
  62    :  0000_0000  0x00    0    
  63    :  0001_0000  0x10   16    
  64    :  0000_0000  0x00    0    
  65    :  0000_0001  0x01    1    
  66    :  0000_0000  0x00    0    
  67    :  0000_0000  0x00    0    
  68    :  1010_1000  0xA8  168    
  69    :  1100_0000  0xC0  192    
  70    :  0000_0000  0x00    0    
  71    :  0100_1111  0x4F   79  O  
  72    :  0100_1110  0x4E   78  N  
  73    :  0110_0010  0x62   98  b  
  74    :  0110_1100  0x6C  108  l  
  75    :  0110_1111  0x6F  111  o  
  76    :  0110_0011  0x63   99  c  
  77    :  0110_1011  0x6B  107  k  
  78    :  0110_0101  0x65  101  e  
  79    :  0110_0100  0x64  100  d  
  80    :  0010_1100  0x2C   44  ,  
  81    :  0010_0000  0x20   32     
  82    :  0101_0011  0x53   83  S  
  83    :  0110_0101  0x65  101  e  
  84    :  0110_0101  0x65  101  e  
  85    :  0011_1010  0x3A   58  :  
  86    :  0010_0000  0x20   32     
  87    :  0110_1000  0x68  104  h  
  88    :  0111_0100  0x74  116  t  
  89    :  0111_0100  0x74  116  t  
  90    :  0111_0000  0x70  112  p  
  91    :  0011_1010  0x3A   58  :  
  92    :  0010_1111  0x2F   47  /  
  93    :  0010_1111  0x2F   47  /  
  94    :  0111_0111  0x77  119  w  
  95    :  0111_0111  0x77  119  w  
  96    :  0111_0111  0x77  119  w  
  97    :  0010_1110  0x2E   46  .  
  98    :  0110_1101  0x6D  109  m  
  99    :  0111_1001  0x79  121  y  
  100   :  0010_1110  0x2E   46  .  
  101   :  0111_1010  0x7A  122  z  
  102   :  0110_1111  0x6F  111  o  
  103   :  0110_1110  0x6E  110  n  
  104   :  0110_0101  0x65  101  e  
  105   :  0010_1110  0x2E   46  .  
  106   :  0110_1111  0x6F  111  o  
  107   :  0110_1110  0x6E  110  n  
  108   :  0110_0101  0x65  101  e  
  109   :  0010_1111  0x2F   47  /  
  110   :  0110_1100  0x6C  108  l  
  111   :  0110_1111  0x6F  111  o  
  112   :  0110_1111  0x6F  111  o  
  113   :  0110_1011  0x6B  107  k  
  114   :  0111_0101  0x75  117  u  
  115   :  0111_0000  0x70  112  p  
  116   :  0010_1110  0x2E   46  .  
  117   :  0110_0011  0x63   99  c  
  118   :  0110_0111  0x67  103  g  
  119   :  0110_1001  0x69  105  i  
  120   :  0011_1111  0x3F   63  ?  
  121   :  0111_0000  0x70  112  p  
  122   :  0110_0001  0x61   97  a  
  123   :  0110_0111  0x67  103  g  
  124   :  0110_0101  0x65  101  e  
  125   :  0011_1101  0x3D   61  =  
  126   :  0110_1100  0x6C  108  l  
  127   :  0110_1111  0x6F  111  o  
  128   :  0110_1111  0x6F  111  o  
  129   :  0110_1011  0x6B  107  k  
  130   :  0111_0101  0x75  117  u  
  131   :  0111_0000  0x70  112  p  
  132   :  0010_0110  0x26   38  &  
  133   :  0110_1100  0x6C  108  l  
  134   :  0110_1111  0x6F  111  o  
  135   :  0110_1111  0x6F  111  o  
  136   :  0110_1011  0x6B  107  k  
  137   :  0111_0101  0x75  117  u  
  138   :  0111_0000  0x70  112  p  
  139   :  0011_1101  0x3D   61  =  
  140   :  0011_0100  0x34   52  4  
  141   :  0010_1110  0x2E   46  .  
  142   :  0011_0010  0x32   50  2  
  143   :  0011_0011  0x33   51  3  
  144   :  0010_1110  0x2E   46  .  
  145   :  0011_0001  0x31   49  1  
  146   :  0011_0111  0x37   55  7  
  147   :  0011_0011  0x33   51  3  
  148   :  0010_1110  0x2E   46  .  
  149   :  0011_1001  0x39   57  9  
  150   :  0011_1001  0x39   57  9  
);
($len,$packet,$pbuf,$pcur,$psans,$pend,$coff,$aoff) = rblf_dump_packet();
#print "pcur = $pcur\npsans = $psans\npend = $pend\ncoff = $coff\naoff = $aoff\nlen  = $len\n";
#print_buf(\$packet);
chk_exp(\$packet,\$exptext);

## test 35	query for bad RBL entry
#		check number of answers
$lookup = '1.2.3.4.';
($answers,$rv) = rblf_query($lookup . $zone1);
print 'got: '. cons_str($rv) .", exp: not found\nnot "
	unless $rv == $notfound;
&ok;

## test 36	query for good RBL entry 128.2.164.228
#		check number of answers
$lookup = '228.164.2.128.';
($answers,$rv) = rblf_query($lookup . $zone2);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

## test 37	check number of answers
print "got: $answers, exp: 6\nnot "
	unless $answers == 2;
&ok;

## test 38	check packet info
$exptext = q(
  0     :  0000_0000  0x00    0    
  1     :  0000_0000  0x00    0    
  2     :  0000_0000  0x00    0    
  3     :  0000_0000  0x00    0    
  4     :  0000_0000  0x00    0    
  5     :  0000_0000  0x00    0    
  6     :  0000_0000  0x00    0    
  7     :  0000_0010  0x02    2    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0011_0010  0x32   50  2  
  14    :  0011_0010  0x32   50  2  
  15    :  0011_1000  0x38   56  8  
  16    :  0000_0011  0x03    3    
  17    :  0011_0001  0x31   49  1  
  18    :  0011_0110  0x36   54  6  
  19    :  0011_0100  0x34   52  4  
  20    :  0000_0001  0x01    1    
  21    :  0011_0010  0x32   50  2  
  22    :  0000_0011  0x03    3    
  23    :  0011_0001  0x31   49  1  
  24    :  0011_0010  0x32   50  2  
  25    :  0011_1000  0x38   56  8  
  26    :  0000_0010  0x02    2    
  27    :  0110_0010  0x62   98  b  
  28    :  0110_1100  0x6C  108  l  
  29    :  0000_0010  0x02    2    
  30    :  0110_1101  0x6D  109  m  
  31    :  0111_1001  0x79  121  y  
  32    :  0000_0101  0x05    5    
  33    :  0111_1010  0x7A  122  z  
  34    :  0110_1111  0x6F  111  o  
  35    :  0110_1110  0x6E  110  n  
  36    :  0110_0101  0x65  101  e  
  37    :  0011_0010  0x32   50  2  
  38    :  0000_0011  0x03    3    
  39    :  0110_0011  0x63   99  c  
  40    :  0110_1111  0x6F  111  o  
  41    :  0110_1101  0x6D  109  m  
  42    :  0000_0000  0x00    0    
  43    :  0000_0000  0x00    0    
  44    :  0000_0000  0x00    0    
  45    :  0000_0000  0x00    0    
  46    :  0000_0000  0x00    0    
  47    :  1100_0000  0xC0  192    
  48    :  0000_1100  0x0C   12    
  49    :  0000_0000  0x00    0    
  50    :  0000_0001  0x01    1    
  51    :  0000_0000  0x00    0    
  52    :  0000_0001  0x01    1    
  53    :  0000_0000  0x00    0    
  54    :  0000_0000  0x00    0    
  55    :  1010_1000  0xA8  168    
  56    :  1100_0000  0xC0  192    
  57    :  0000_0000  0x00    0    
  58    :  0000_0100  0x04    4    
  59    :  0111_1111  0x7F  127    
  60    :  0000_0000  0x00    0    
  61    :  0000_0000  0x00    0    
  62    :  0000_0010  0x02    2    
  63    :  1100_0000  0xC0  192    
  64    :  0000_1100  0x0C   12    
  65    :  0000_0000  0x00    0    
  66    :  0001_0000  0x10   16    
  67    :  0000_0000  0x00    0    
  68    :  0000_0001  0x01    1    
  69    :  0000_0000  0x00    0    
  70    :  0000_0000  0x00    0    
  71    :  1010_1000  0xA8  168    
  72    :  1100_0000  0xC0  192    
  73    :  0000_0000  0x00    0    
  74    :  0101_0010  0x52   82  R  
  75    :  0101_0001  0x51   81  Q  
  76    :  0110_0010  0x62   98  b  
  77    :  0110_1100  0x6C  108  l  
  78    :  0110_1111  0x6F  111  o  
  79    :  0110_0011  0x63   99  c  
  80    :  0110_1011  0x6B  107  k  
  81    :  0110_0101  0x65  101  e  
  82    :  0110_0100  0x64  100  d  
  83    :  0010_1100  0x2C   44  ,  
  84    :  0010_0000  0x20   32     
  85    :  0101_0011  0x53   83  S  
  86    :  0110_0101  0x65  101  e  
  87    :  0110_0101  0x65  101  e  
  88    :  0011_1010  0x3A   58  :  
  89    :  0010_0000  0x20   32     
  90    :  0110_1000  0x68  104  h  
  91    :  0111_0100  0x74  116  t  
  92    :  0111_0100  0x74  116  t  
  93    :  0111_0000  0x70  112  p  
  94    :  0011_1010  0x3A   58  :  
  95    :  0010_1111  0x2F   47  /  
  96    :  0010_1111  0x2F   47  /  
  97    :  0111_0111  0x77  119  w  
  98    :  0111_0111  0x77  119  w  
  99    :  0111_0111  0x77  119  w  
  100   :  0010_1110  0x2E   46  .  
  101   :  0110_1101  0x6D  109  m  
  102   :  0111_1001  0x79  121  y  
  103   :  0010_1110  0x2E   46  .  
  104   :  0111_1010  0x7A  122  z  
  105   :  0110_1111  0x6F  111  o  
  106   :  0110_1110  0x6E  110  n  
  107   :  0110_0101  0x65  101  e  
  108   :  0011_0010  0x32   50  2  
  109   :  0010_1110  0x2E   46  .  
  110   :  0110_0011  0x63   99  c  
  111   :  0110_1111  0x6F  111  o  
  112   :  0110_1101  0x6D  109  m  
  113   :  0010_1111  0x2F   47  /  
  114   :  0110_1100  0x6C  108  l  
  115   :  0110_1111  0x6F  111  o  
  116   :  0110_1111  0x6F  111  o  
  117   :  0110_1011  0x6B  107  k  
  118   :  0111_0101  0x75  117  u  
  119   :  0111_0000  0x70  112  p  
  120   :  0010_1110  0x2E   46  .  
  121   :  0110_0011  0x63   99  c  
  122   :  0110_0111  0x67  103  g  
  123   :  0110_1001  0x69  105  i  
  124   :  0011_1111  0x3F   63  ?  
  125   :  0111_0000  0x70  112  p  
  126   :  0110_0001  0x61   97  a  
  127   :  0110_0111  0x67  103  g  
  128   :  0110_0101  0x65  101  e  
  129   :  0011_1101  0x3D   61  =  
  130   :  0110_1100  0x6C  108  l  
  131   :  0110_1111  0x6F  111  o  
  132   :  0110_1111  0x6F  111  o  
  133   :  0110_1011  0x6B  107  k  
  134   :  0111_0101  0x75  117  u  
  135   :  0111_0000  0x70  112  p  
  136   :  0010_0110  0x26   38  &  
  137   :  0110_1100  0x6C  108  l  
  138   :  0110_1111  0x6F  111  o  
  139   :  0110_1111  0x6F  111  o  
  140   :  0110_1011  0x6B  107  k  
  141   :  0111_0101  0x75  117  u  
  142   :  0111_0000  0x70  112  p  
  143   :  0011_1101  0x3D   61  =  
  144   :  0011_0001  0x31   49  1  
  145   :  0011_0010  0x32   50  2  
  146   :  0011_1000  0x38   56  8  
  147   :  0010_1110  0x2E   46  .  
  148   :  0011_0010  0x32   50  2  
  149   :  0010_1110  0x2E   46  .  
  150   :  0011_0001  0x31   49  1  
  151   :  0011_0110  0x36   54  6  
  152   :  0011_0100  0x34   52  4  
  153   :  0010_1110  0x2E   46  .  
  154   :  0011_0010  0x32   50  2  
  155   :  0011_0010  0x32   50  2  
  156   :  0011_1000  0x38   56  8  
);
($len,$packet,$pbuf,$pcur,$psans,$pend,$coff,$aoff) = rblf_dump_packet();
#print "pbuf = $pbuf\npcur = $pcur\npsans = $psans\npend = $pend\ncoff = $coff\naoff = $aoff\nlen  = $len\n";
#print_buf(\$packet);
chk_exp(\$packet,\$exptext);

## test 39	query for good RBL entry 212.142.152.10
#		check number of answers
$lookup = '10.152.142.212.';
($answers,$rv) = rblf_query($lookup . $zone3);
print 'got: '. cons_str($rv) .", exp: success\nnot "
	unless $rv == $success;
&ok;

## test 40	check number of answers
print "got: $answers, exp: 6\nnot "
	unless $answers == 2;
&ok;

## test 41	check packet info
$exptext = q(
  0     :  0000_0000  0x00    0    
  1     :  0000_0000  0x00    0    
  2     :  0000_0000  0x00    0    
  3     :  0000_0000  0x00    0    
  4     :  0000_0000  0x00    0    
  5     :  0000_0000  0x00    0    
  6     :  0000_0000  0x00    0    
  7     :  0000_0010  0x02    2    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0010  0x02    2    
  13    :  0011_0001  0x31   49  1  
  14    :  0011_0000  0x30   48  0  
  15    :  0000_0011  0x03    3    
  16    :  0011_0001  0x31   49  1  
  17    :  0011_0101  0x35   53  5  
  18    :  0011_0010  0x32   50  2  
  19    :  0000_0011  0x03    3    
  20    :  0011_0001  0x31   49  1  
  21    :  0011_0100  0x34   52  4  
  22    :  0011_0010  0x32   50  2  
  23    :  0000_0011  0x03    3    
  24    :  0011_0010  0x32   50  2  
  25    :  0011_0001  0x31   49  1  
  26    :  0011_0010  0x32   50  2  
  27    :  0000_0010  0x02    2    
  28    :  0110_0010  0x62   98  b  
  29    :  0110_1100  0x6C  108  l  
  30    :  0000_0010  0x02    2    
  31    :  0110_1101  0x6D  109  m  
  32    :  0111_1001  0x79  121  y  
  33    :  0000_0101  0x05    5    
  34    :  0111_1010  0x7A  122  z  
  35    :  0110_1111  0x6F  111  o  
  36    :  0110_1110  0x6E  110  n  
  37    :  0110_0101  0x65  101  e  
  38    :  0011_0011  0x33   51  3  
  39    :  0000_0011  0x03    3    
  40    :  0110_1111  0x6F  111  o  
  41    :  0111_0010  0x72  114  r  
  42    :  0110_0111  0x67  103  g  
  43    :  0000_0000  0x00    0    
  44    :  0000_0000  0x00    0    
  45    :  0000_0000  0x00    0    
  46    :  0000_0000  0x00    0    
  47    :  0000_0000  0x00    0    
  48    :  1100_0000  0xC0  192    
  49    :  0000_1100  0x0C   12    
  50    :  0000_0000  0x00    0    
  51    :  0000_0001  0x01    1    
  52    :  0000_0000  0x00    0    
  53    :  0000_0001  0x01    1    
  54    :  0000_0000  0x00    0    
  55    :  0000_0000  0x00    0    
  56    :  1010_1000  0xA8  168    
  57    :  1100_0000  0xC0  192    
  58    :  0000_0000  0x00    0    
  59    :  0000_0100  0x04    4    
  60    :  0111_1111  0x7F  127    
  61    :  0000_0000  0x00    0    
  62    :  0000_0000  0x00    0    
  63    :  0000_0010  0x02    2    
  64    :  1100_0000  0xC0  192    
  65    :  0000_1100  0x0C   12    
  66    :  0000_0000  0x00    0    
  67    :  0001_0000  0x10   16    
  68    :  0000_0000  0x00    0    
  69    :  0000_0001  0x01    1    
  70    :  0000_0000  0x00    0    
  71    :  0000_0000  0x00    0    
  72    :  1010_1000  0xA8  168    
  73    :  1100_0000  0xC0  192    
  74    :  0000_0000  0x00    0    
  75    :  0101_0101  0x55   85  U  
  76    :  0101_0100  0x54   84  T  
  77    :  0110_0010  0x62   98  b  
  78    :  0110_1100  0x6C  108  l  
  79    :  0110_1111  0x6F  111  o  
  80    :  0110_0011  0x63   99  c  
  81    :  0110_1011  0x6B  107  k  
  82    :  0110_0101  0x65  101  e  
  83    :  0110_0100  0x64  100  d  
  84    :  0010_1100  0x2C   44  ,  
  85    :  0010_0000  0x20   32     
  86    :  0101_0011  0x53   83  S  
  87    :  0110_0101  0x65  101  e  
  88    :  0110_0101  0x65  101  e  
  89    :  0011_1010  0x3A   58  :  
  90    :  0010_0000  0x20   32     
  91    :  0110_1000  0x68  104  h  
  92    :  0111_0100  0x74  116  t  
  93    :  0111_0100  0x74  116  t  
  94    :  0111_0000  0x70  112  p  
  95    :  0011_1010  0x3A   58  :  
  96    :  0010_1111  0x2F   47  /  
  97    :  0010_1111  0x2F   47  /  
  98    :  0111_0111  0x77  119  w  
  99    :  0111_0111  0x77  119  w  
  100   :  0111_0111  0x77  119  w  
  101   :  0010_1110  0x2E   46  .  
  102   :  0110_1101  0x6D  109  m  
  103   :  0111_1001  0x79  121  y  
  104   :  0010_1110  0x2E   46  .  
  105   :  0111_1010  0x7A  122  z  
  106   :  0110_1111  0x6F  111  o  
  107   :  0110_1110  0x6E  110  n  
  108   :  0110_0101  0x65  101  e  
  109   :  0011_0011  0x33   51  3  
  110   :  0010_1110  0x2E   46  .  
  111   :  0110_1111  0x6F  111  o  
  112   :  0111_0010  0x72  114  r  
  113   :  0110_0111  0x67  103  g  
  114   :  0010_1111  0x2F   47  /  
  115   :  0110_0011  0x63   99  c  
  116   :  0110_0001  0x61   97  a  
  117   :  0110_1110  0x6E  110  n  
  118   :  0110_1110  0x6E  110  n  
  119   :  0110_1001  0x69  105  i  
  120   :  0110_0010  0x62   98  b  
  121   :  0110_0001  0x61   97  a  
  122   :  0110_1100  0x6C  108  l  
  123   :  0010_1110  0x2E   46  .  
  124   :  0110_0011  0x63   99  c  
  125   :  0110_0111  0x67  103  g  
  126   :  0110_1001  0x69  105  i  
  127   :  0011_1111  0x3F   63  ?  
  128   :  0111_0000  0x70  112  p  
  129   :  0110_0001  0x61   97  a  
  130   :  0110_0111  0x67  103  g  
  131   :  0110_0101  0x65  101  e  
  132   :  0011_1101  0x3D   61  =  
  133   :  0110_1100  0x6C  108  l  
  134   :  0110_1111  0x6F  111  o  
  135   :  0110_1111  0x6F  111  o  
  136   :  0110_1011  0x6B  107  k  
  137   :  0111_0101  0x75  117  u  
  138   :  0111_0000  0x70  112  p  
  139   :  0010_0110  0x26   38  &  
  140   :  0110_1100  0x6C  108  l  
  141   :  0110_1111  0x6F  111  o  
  142   :  0110_1111  0x6F  111  o  
  143   :  0110_1011  0x6B  107  k  
  144   :  0111_0101  0x75  117  u  
  145   :  0111_0000  0x70  112  p  
  146   :  0011_1101  0x3D   61  =  
  147   :  0011_0010  0x32   50  2  
  148   :  0011_0001  0x31   49  1  
  149   :  0011_0010  0x32   50  2  
  150   :  0010_1110  0x2E   46  .  
  151   :  0011_0001  0x31   49  1  
  152   :  0011_0100  0x34   52  4  
  153   :  0011_0010  0x32   50  2  
  154   :  0010_1110  0x2E   46  .  
  155   :  0011_0001  0x31   49  1  
  156   :  0011_0101  0x35   53  5  
  157   :  0011_0010  0x32   50  2  
  158   :  0010_1110  0x2E   46  .  
  159   :  0011_0001  0x31   49  1  
  160   :  0011_0000  0x30   48  0  
);
($len,$packet,$pbuf,$pcur,$psans,$pend,$coff,$aoff) = rblf_dump_packet();
#print "pbuf = $pbuf\npcur = $pcur\npsans = $psans\npend = $pend\ncoff = $coff\naoff = $aoff\nlen  = $len\n";
#print_buf(\$packet);
chk_exp(\$packet,\$exptext);

