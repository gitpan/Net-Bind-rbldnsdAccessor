# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.
# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..37\n"; }
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
	:test
	rblf_next_answer
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

## test 2	setup, generate a header for a question

my $buffer = '';
my $off = newhead(\$buffer,
	12345,			# id
	QR | BITS_QUERY | RD | RA,	# query response, query, recursion desired, recursion available
);

print "bad question size $off\nnot "
	unless $off == NS_HFIXEDSZ;
&ok;

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

## test 3	setup, append question
# expect this from print_buf
my $exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0000  0x00    0    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_0001  0x01    1    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
);

my $name = 'foo.bar.com';

my($get,$put,$parse) = new Net::DNS::ToolKit::RR(C_IN);
($off,(my @dnptrs)) = $put->Question(\$buffer,$off,$name,T_A,C_IN);
put_qdcount(\$buffer,1);
#print_head(\$buffer);
#print_buf(\$buffer);

chk_exp(\$buffer,\$exptext);

#######################################
# append one each of NS A TXT MX SOA

my $ancount = 0;
## test 4	put NS record
#	This is what we must test

#  ($newoff,$name,$type,$class,$ttl,$rdlength,
#        $rdata,...) = $get->XYZ(\$buffer,$offset);
#
#  ($newoff,@dnptrs)=$put->XYZ(\$buffer,$offset,\@dnptrs,   
#        $name,$type,$class,$ttl,$rdlength,$rdata,...);
#
#  $name,$TYPE,$CLASS,$TTL,$rdlength,$IPaddr) 
#    = $parse->XYZ($name,$type,$class,$ttl,$rdlength,
#        $rdata,...);

$exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0000  0x00    0    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_0001  0x01    1    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
  29    :  1100_0000  0xC0  192    
  30    :  0000_1100  0x0C   12    
  31    :  0000_0000  0x00    0    
  32    :  0000_0010  0x02    2    
  33    :  0000_0000  0x00    0    
  34    :  0000_0001  0x01    1    
  35    :  0000_0000  0x00    0    
  36    :  0000_0000  0x00    0    
  37    :  0000_0100  0x04    4    
  38    :  1101_0010  0xD2  210    
  39    :  0000_0000  0x00    0    
  40    :  0000_1000  0x08    8    
  41    :  0000_0101  0x05    5    
  42    :  0110_0111  0x67  103  g  
  43    :  0110_1111  0x6F  111  o  
  44    :  0110_1111  0x6F  111  o  
  45    :  0111_0011  0x73  115  s  
  46    :  0110_0101  0x65  101  e  
  47    :  1100_0000  0xC0  192    
  48    :  0000_1100  0x0C   12    
);
### offset from above = 29
$ancount++;
my $ttl = 1234;
my $rdata = 'goose.foo.bar.com';
($off, @dnptrs) = $put->NS(\$buffer,$off,\@dnptrs,$name,$ttl,$rdata);
#print_buf(\$buffer);
#print_ptrs(@dnptrs);
chk_exp(\$buffer,\$exptext);      

## test 5	add and check A record
$exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0000  0x00    0    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_0001  0x01    1    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
  29    :  1100_0000  0xC0  192    
  30    :  0000_1100  0x0C   12    
  31    :  0000_0000  0x00    0    
  32    :  0000_0010  0x02    2    
  33    :  0000_0000  0x00    0    
  34    :  0000_0001  0x01    1    
  35    :  0000_0000  0x00    0    
  36    :  0000_0000  0x00    0    
  37    :  0000_0100  0x04    4    
  38    :  1101_0010  0xD2  210    
  39    :  0000_0000  0x00    0    
  40    :  0000_1000  0x08    8    
  41    :  0000_0101  0x05    5    
  42    :  0110_0111  0x67  103  g  
  43    :  0110_1111  0x6F  111  o  
  44    :  0110_1111  0x6F  111  o  
  45    :  0111_0011  0x73  115  s  
  46    :  0110_0101  0x65  101  e  
  47    :  1100_0000  0xC0  192    
  48    :  0000_1100  0x0C   12    
  49    :  1100_0000  0xC0  192    
  50    :  0000_1100  0x0C   12    
  51    :  0000_0000  0x00    0    
  52    :  0000_0001  0x01    1    
  53    :  0000_0000  0x00    0    
  54    :  0000_0001  0x01    1    
  55    :  0000_0000  0x00    0    
  56    :  0000_0000  0x00    0    
  57    :  0000_0010  0x02    2    
  58    :  0011_0111  0x37   55  7  
  59    :  0000_0000  0x00    0    
  60    :  0000_0100  0x04    4    
  61    :  0000_1010  0x0A   10    
  62    :  0110_0010  0x62   98  b  
  63    :  0100_1100  0x4C   76  L  
  64    :  0011_0110  0x36   54  6  
);
### offset from above = 49
$ancount++;
$ttl = 567;
$rdata = inet_aton('10.98.76.54');
($off, @dnptrs) = $put->A(\$buffer,$off,\@dnptrs,$name,$ttl,$rdata);
#print_head(\$buffer);
#print_buf(\$buffer);
#print_ptrs(@dnptrs);
chk_exp(\$buffer,\$exptext);      

## test 6       add and check TXT record
$exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0000  0x00    0    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_0001  0x01    1    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
  29    :  1100_0000  0xC0  192    
  30    :  0000_1100  0x0C   12    
  31    :  0000_0000  0x00    0    
  32    :  0000_0010  0x02    2    
  33    :  0000_0000  0x00    0    
  34    :  0000_0001  0x01    1    
  35    :  0000_0000  0x00    0    
  36    :  0000_0000  0x00    0    
  37    :  0000_0100  0x04    4    
  38    :  1101_0010  0xD2  210    
  39    :  0000_0000  0x00    0    
  40    :  0000_1000  0x08    8    
  41    :  0000_0101  0x05    5    
  42    :  0110_0111  0x67  103  g  
  43    :  0110_1111  0x6F  111  o  
  44    :  0110_1111  0x6F  111  o  
  45    :  0111_0011  0x73  115  s  
  46    :  0110_0101  0x65  101  e  
  47    :  1100_0000  0xC0  192    
  48    :  0000_1100  0x0C   12    
  49    :  1100_0000  0xC0  192    
  50    :  0000_1100  0x0C   12    
  51    :  0000_0000  0x00    0    
  52    :  0000_0001  0x01    1    
  53    :  0000_0000  0x00    0    
  54    :  0000_0001  0x01    1    
  55    :  0000_0000  0x00    0    
  56    :  0000_0000  0x00    0    
  57    :  0000_0010  0x02    2    
  58    :  0011_0111  0x37   55  7  
  59    :  0000_0000  0x00    0    
  60    :  0000_0100  0x04    4    
  61    :  0000_1010  0x0A   10    
  62    :  0110_0010  0x62   98  b  
  63    :  0100_1100  0x4C   76  L  
  64    :  0011_0110  0x36   54  6  
  65    :  1100_0000  0xC0  192    
  66    :  0000_1100  0x0C   12    
  67    :  0000_0000  0x00    0    
  68    :  0001_0000  0x10   16    
  69    :  0000_0000  0x00    0    
  70    :  0000_0001  0x01    1    
  71    :  0000_0000  0x00    0    
  72    :  0000_0000  0x00    0    
  73    :  0000_0010  0x02    2    
  74    :  1010_0110  0xA6  166    
  75    :  0000_0000  0x00    0    
  76    :  0010_1101  0x2D   45  -  
  77    :  0010_1100  0x2C   44  ,  
  78    :  0101_0100  0x54   84  T  
  79    :  0110_1000  0x68  104  h  
  80    :  0110_0101  0x65  101  e  
  81    :  0010_0000  0x20   32     
  82    :  0101_0001  0x51   81  Q  
  83    :  0111_0101  0x75  117  u  
  84    :  0110_1001  0x69  105  i  
  85    :  0110_0011  0x63   99  c  
  86    :  0110_1011  0x6B  107  k  
  87    :  0010_0000  0x20   32     
  88    :  0100_0010  0x42   66  B  
  89    :  0111_0010  0x72  114  r  
  90    :  0110_1111  0x6F  111  o  
  91    :  0111_0111  0x77  119  w  
  92    :  0110_1110  0x6E  110  n  
  93    :  0010_0000  0x20   32     
  94    :  0100_0110  0x46   70  F  
  95    :  0110_1111  0x6F  111  o  
  96    :  0111_1000  0x78  120  x  
  97    :  0010_0000  0x20   32     
  98    :  0100_1010  0x4A   74  J  
  99    :  0111_0101  0x75  117  u  
  100   :  0110_1101  0x6D  109  m  
  101   :  0111_0000  0x70  112  p  
  102   :  0110_0101  0x65  101  e  
  103   :  0110_0100  0x64  100  d  
  104   :  0010_0000  0x20   32     
  105   :  0100_1111  0x4F   79  O  
  106   :  0111_0110  0x76  118  v  
  107   :  0110_0101  0x65  101  e  
  108   :  0111_0010  0x72  114  r  
  109   :  0010_0000  0x20   32     
  110   :  0101_0100  0x54   84  T  
  111   :  0110_1000  0x68  104  h  
  112   :  0110_0101  0x65  101  e  
  113   :  0010_0000  0x20   32     
  114   :  0100_1100  0x4C   76  L  
  115   :  0110_0001  0x61   97  a  
  116   :  0111_1010  0x7A  122  z  
  117   :  0111_1001  0x79  121  y  
  118   :  0010_0000  0x20   32     
  119   :  0100_0100  0x44   68  D  
  120   :  0110_1111  0x6F  111  o  
  121   :  0110_0111  0x67  103  g  
);

### offset from above = 65
$ancount++;
$ttl = 678;
$rdata = 'The Quick Brown Fox Jumped Over The Lazy Dog';
($off, @dnptrs) = $put->TXT(\$buffer,$off,\@dnptrs,$name,$ttl,$rdata);
#print_head(\$buffer);
#print_buf(\$buffer); 
#print_ptrs(@dnptrs); 
chk_exp(\$buffer,\$exptext);

## test 7       add and check MX record
$exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0000  0x00    0    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_0001  0x01    1    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
  29    :  1100_0000  0xC0  192    
  30    :  0000_1100  0x0C   12    
  31    :  0000_0000  0x00    0    
  32    :  0000_0010  0x02    2    
  33    :  0000_0000  0x00    0    
  34    :  0000_0001  0x01    1    
  35    :  0000_0000  0x00    0    
  36    :  0000_0000  0x00    0    
  37    :  0000_0100  0x04    4    
  38    :  1101_0010  0xD2  210    
  39    :  0000_0000  0x00    0    
  40    :  0000_1000  0x08    8    
  41    :  0000_0101  0x05    5    
  42    :  0110_0111  0x67  103  g  
  43    :  0110_1111  0x6F  111  o  
  44    :  0110_1111  0x6F  111  o  
  45    :  0111_0011  0x73  115  s  
  46    :  0110_0101  0x65  101  e  
  47    :  1100_0000  0xC0  192    
  48    :  0000_1100  0x0C   12    
  49    :  1100_0000  0xC0  192    
  50    :  0000_1100  0x0C   12    
  51    :  0000_0000  0x00    0    
  52    :  0000_0001  0x01    1    
  53    :  0000_0000  0x00    0    
  54    :  0000_0001  0x01    1    
  55    :  0000_0000  0x00    0    
  56    :  0000_0000  0x00    0    
  57    :  0000_0010  0x02    2    
  58    :  0011_0111  0x37   55  7  
  59    :  0000_0000  0x00    0    
  60    :  0000_0100  0x04    4    
  61    :  0000_1010  0x0A   10    
  62    :  0110_0010  0x62   98  b  
  63    :  0100_1100  0x4C   76  L  
  64    :  0011_0110  0x36   54  6  
  65    :  1100_0000  0xC0  192    
  66    :  0000_1100  0x0C   12    
  67    :  0000_0000  0x00    0    
  68    :  0001_0000  0x10   16    
  69    :  0000_0000  0x00    0    
  70    :  0000_0001  0x01    1    
  71    :  0000_0000  0x00    0    
  72    :  0000_0000  0x00    0    
  73    :  0000_0010  0x02    2    
  74    :  1010_0110  0xA6  166    
  75    :  0000_0000  0x00    0    
  76    :  0010_1101  0x2D   45  -  
  77    :  0010_1100  0x2C   44  ,  
  78    :  0101_0100  0x54   84  T  
  79    :  0110_1000  0x68  104  h  
  80    :  0110_0101  0x65  101  e  
  81    :  0010_0000  0x20   32     
  82    :  0101_0001  0x51   81  Q  
  83    :  0111_0101  0x75  117  u  
  84    :  0110_1001  0x69  105  i  
  85    :  0110_0011  0x63   99  c  
  86    :  0110_1011  0x6B  107  k  
  87    :  0010_0000  0x20   32     
  88    :  0100_0010  0x42   66  B  
  89    :  0111_0010  0x72  114  r  
  90    :  0110_1111  0x6F  111  o  
  91    :  0111_0111  0x77  119  w  
  92    :  0110_1110  0x6E  110  n  
  93    :  0010_0000  0x20   32     
  94    :  0100_0110  0x46   70  F  
  95    :  0110_1111  0x6F  111  o  
  96    :  0111_1000  0x78  120  x  
  97    :  0010_0000  0x20   32     
  98    :  0100_1010  0x4A   74  J  
  99    :  0111_0101  0x75  117  u  
  100   :  0110_1101  0x6D  109  m  
  101   :  0111_0000  0x70  112  p  
  102   :  0110_0101  0x65  101  e  
  103   :  0110_0100  0x64  100  d  
  104   :  0010_0000  0x20   32     
  105   :  0100_1111  0x4F   79  O  
  106   :  0111_0110  0x76  118  v  
  107   :  0110_0101  0x65  101  e  
  108   :  0111_0010  0x72  114  r  
  109   :  0010_0000  0x20   32     
  110   :  0101_0100  0x54   84  T  
  111   :  0110_1000  0x68  104  h  
  112   :  0110_0101  0x65  101  e  
  113   :  0010_0000  0x20   32     
  114   :  0100_1100  0x4C   76  L  
  115   :  0110_0001  0x61   97  a  
  116   :  0111_1010  0x7A  122  z  
  117   :  0111_1001  0x79  121  y  
  118   :  0010_0000  0x20   32     
  119   :  0100_0100  0x44   68  D  
  120   :  0110_1111  0x6F  111  o  
  121   :  0110_0111  0x67  103  g  
  122   :  1100_0000  0xC0  192    
  123   :  0000_1100  0x0C   12    
  124   :  0000_0000  0x00    0    
  125   :  0000_1111  0x0F   15    
  126   :  0000_0000  0x00    0    
  127   :  0000_0001  0x01    1    
  128   :  0000_0000  0x00    0    
  129   :  0000_0000  0x00    0    
  130   :  0000_0011  0x03    3    
  131   :  0001_0101  0x15   21    
  132   :  0000_0000  0x00    0    
  133   :  0000_1111  0x0F   15    
  134   :  0000_0000  0x00    0    
  135   :  0011_0111  0x37   55  7  
  136   :  0000_1010  0x0A   10    
  137   :  0110_1101  0x6D  109  m  
  138   :  0110_0001  0x61   97  a  
  139   :  0110_1001  0x69  105  i  
  140   :  0110_1100  0x6C  108  l  
  141   :  0111_0011  0x73  115  s  
  142   :  0110_0101  0x65  101  e  
  143   :  0111_0010  0x72  114  r  
  144   :  0111_0110  0x76  118  v  
  145   :  0110_0101  0x65  101  e  
  146   :  0111_0010  0x72  114  r  
  147   :  1100_0000  0xC0  192    
  148   :  0001_0000  0x10   16    
);
  
### offset from above = 122
$ancount++;
$ttl = 789;
my @rdata = (55,'mailserver.bar.com');
($off, @dnptrs) = $put->MX(\$buffer,$off,\@dnptrs,$name,$ttl,@rdata);
#print_head(\$buffer);
#print_buf(\$buffer); 
#print_ptrs(@dnptrs); 
chk_exp(\$buffer,\$exptext);

## test 8       add and check SOA record
$exptext = q(
  0     :  0011_0000  0x30   48  0  
  1     :  0011_1001  0x39   57  9  
  2     :  1000_0001  0x81  129    
  3     :  1000_0000  0x80  128    
  4     :  0000_0000  0x00    0    
  5     :  0000_0001  0x01    1    
  6     :  0000_0000  0x00    0    
  7     :  0000_0101  0x05    5    
  8     :  0000_0000  0x00    0    
  9     :  0000_0000  0x00    0    
  10    :  0000_0000  0x00    0    
  11    :  0000_0000  0x00    0    
  12    :  0000_0011  0x03    3    
  13    :  0110_0110  0x66  102  f  
  14    :  0110_1111  0x6F  111  o  
  15    :  0110_1111  0x6F  111  o  
  16    :  0000_0011  0x03    3    
  17    :  0110_0010  0x62   98  b  
  18    :  0110_0001  0x61   97  a  
  19    :  0111_0010  0x72  114  r  
  20    :  0000_0011  0x03    3    
  21    :  0110_0011  0x63   99  c  
  22    :  0110_1111  0x6F  111  o  
  23    :  0110_1101  0x6D  109  m  
  24    :  0000_0000  0x00    0    
  25    :  0000_0000  0x00    0    
  26    :  0000_0001  0x01    1    
  27    :  0000_0000  0x00    0    
  28    :  0000_0001  0x01    1    
  29    :  1100_0000  0xC0  192    
  30    :  0000_1100  0x0C   12    
  31    :  0000_0000  0x00    0    
  32    :  0000_0010  0x02    2    
  33    :  0000_0000  0x00    0    
  34    :  0000_0001  0x01    1    
  35    :  0000_0000  0x00    0    
  36    :  0000_0000  0x00    0    
  37    :  0000_0100  0x04    4    
  38    :  1101_0010  0xD2  210    
  39    :  0000_0000  0x00    0    
  40    :  0000_1000  0x08    8    
  41    :  0000_0101  0x05    5    
  42    :  0110_0111  0x67  103  g  
  43    :  0110_1111  0x6F  111  o  
  44    :  0110_1111  0x6F  111  o  
  45    :  0111_0011  0x73  115  s  
  46    :  0110_0101  0x65  101  e  
  47    :  1100_0000  0xC0  192    
  48    :  0000_1100  0x0C   12    
  49    :  1100_0000  0xC0  192    
  50    :  0000_1100  0x0C   12    
  51    :  0000_0000  0x00    0    
  52    :  0000_0001  0x01    1    
  53    :  0000_0000  0x00    0    
  54    :  0000_0001  0x01    1    
  55    :  0000_0000  0x00    0    
  56    :  0000_0000  0x00    0    
  57    :  0000_0010  0x02    2    
  58    :  0011_0111  0x37   55  7  
  59    :  0000_0000  0x00    0    
  60    :  0000_0100  0x04    4    
  61    :  0000_1010  0x0A   10    
  62    :  0110_0010  0x62   98  b  
  63    :  0100_1100  0x4C   76  L  
  64    :  0011_0110  0x36   54  6  
  65    :  1100_0000  0xC0  192    
  66    :  0000_1100  0x0C   12    
  67    :  0000_0000  0x00    0    
  68    :  0001_0000  0x10   16    
  69    :  0000_0000  0x00    0    
  70    :  0000_0001  0x01    1    
  71    :  0000_0000  0x00    0    
  72    :  0000_0000  0x00    0    
  73    :  0000_0010  0x02    2    
  74    :  1010_0110  0xA6  166    
  75    :  0000_0000  0x00    0    
  76    :  0010_1101  0x2D   45  -  
  77    :  0010_1100  0x2C   44  ,  
  78    :  0101_0100  0x54   84  T  
  79    :  0110_1000  0x68  104  h  
  80    :  0110_0101  0x65  101  e  
  81    :  0010_0000  0x20   32     
  82    :  0101_0001  0x51   81  Q  
  83    :  0111_0101  0x75  117  u  
  84    :  0110_1001  0x69  105  i  
  85    :  0110_0011  0x63   99  c  
  86    :  0110_1011  0x6B  107  k  
  87    :  0010_0000  0x20   32     
  88    :  0100_0010  0x42   66  B  
  89    :  0111_0010  0x72  114  r  
  90    :  0110_1111  0x6F  111  o  
  91    :  0111_0111  0x77  119  w  
  92    :  0110_1110  0x6E  110  n  
  93    :  0010_0000  0x20   32     
  94    :  0100_0110  0x46   70  F  
  95    :  0110_1111  0x6F  111  o  
  96    :  0111_1000  0x78  120  x  
  97    :  0010_0000  0x20   32     
  98    :  0100_1010  0x4A   74  J  
  99    :  0111_0101  0x75  117  u  
  100   :  0110_1101  0x6D  109  m  
  101   :  0111_0000  0x70  112  p  
  102   :  0110_0101  0x65  101  e  
  103   :  0110_0100  0x64  100  d  
  104   :  0010_0000  0x20   32     
  105   :  0100_1111  0x4F   79  O  
  106   :  0111_0110  0x76  118  v  
  107   :  0110_0101  0x65  101  e  
  108   :  0111_0010  0x72  114  r  
  109   :  0010_0000  0x20   32     
  110   :  0101_0100  0x54   84  T  
  111   :  0110_1000  0x68  104  h  
  112   :  0110_0101  0x65  101  e  
  113   :  0010_0000  0x20   32     
  114   :  0100_1100  0x4C   76  L  
  115   :  0110_0001  0x61   97  a  
  116   :  0111_1010  0x7A  122  z  
  117   :  0111_1001  0x79  121  y  
  118   :  0010_0000  0x20   32     
  119   :  0100_0100  0x44   68  D  
  120   :  0110_1111  0x6F  111  o  
  121   :  0110_0111  0x67  103  g  
  122   :  1100_0000  0xC0  192    
  123   :  0000_1100  0x0C   12    
  124   :  0000_0000  0x00    0    
  125   :  0000_1111  0x0F   15    
  126   :  0000_0000  0x00    0    
  127   :  0000_0001  0x01    1    
  128   :  0000_0000  0x00    0    
  129   :  0000_0000  0x00    0    
  130   :  0000_0011  0x03    3    
  131   :  0001_0101  0x15   21    
  132   :  0000_0000  0x00    0    
  133   :  0000_1111  0x0F   15    
  134   :  0000_0000  0x00    0    
  135   :  0011_0111  0x37   55  7  
  136   :  0000_1010  0x0A   10    
  137   :  0110_1101  0x6D  109  m  
  138   :  0110_0001  0x61   97  a  
  139   :  0110_1001  0x69  105  i  
  140   :  0110_1100  0x6C  108  l  
  141   :  0111_0011  0x73  115  s  
  142   :  0110_0101  0x65  101  e  
  143   :  0111_0010  0x72  114  r  
  144   :  0111_0110  0x76  118  v  
  145   :  0110_0101  0x65  101  e  
  146   :  0111_0010  0x72  114  r  
  147   :  1100_0000  0xC0  192    
  148   :  0001_0000  0x10   16    
  149   :  1100_0000  0xC0  192    
  150   :  0000_1100  0x0C   12    
  151   :  0000_0000  0x00    0    
  152   :  0000_0110  0x06    6    
  153   :  0000_0000  0x00    0    
  154   :  0000_0001  0x01    1    
  155   :  0000_0000  0x00    0    
  156   :  0000_0000  0x00    0    
  157   :  0010_0010  0x22   34  "  
  158   :  1100_1110  0xCE  206    
  159   :  0000_0000  0x00    0    
  160   :  0010_0100  0x24   36  $  
  161   :  0000_0101  0x05    5    
  162   :  0110_1101  0x6D  109  m  
  163   :  0110_1110  0x6E  110  n  
  164   :  0110_0001  0x61   97  a  
  165   :  0110_1101  0x6D  109  m  
  166   :  0110_0101  0x65  101  e  
  167   :  1100_0000  0xC0  192    
  168   :  0001_0000  0x10   16    
  169   :  0000_0101  0x05    5    
  170   :  0111_0010  0x72  114  r  
  171   :  0110_1110  0x6E  110  n  
  172   :  0110_0001  0x61   97  a  
  173   :  0110_1101  0x6D  109  m  
  174   :  0110_0101  0x65  101  e  
  175   :  1100_0000  0xC0  192    
  176   :  0001_0000  0x10   16    
  177   :  0000_0111  0x07    7    
  178   :  0101_1011  0x5B   91  [  
  179   :  1100_1101  0xCD  205    
  180   :  0001_0101  0x15   21    
  181   :  0000_0000  0x00    0    
  182   :  0000_0000  0x00    0    
  183   :  0010_0111  0x27   39  '  
  184   :  0001_0000  0x10   16    
  185   :  0000_0000  0x00    0    
  186   :  0000_0000  0x00    0    
  187   :  0000_0001  0x01    1    
  188   :  1001_0000  0x90  144    
  189   :  0000_0000  0x00    0    
  190   :  0000_0011  0x03    3    
  191   :  0000_1101  0x0D   13    
  192   :  0100_0000  0x40   64  @  
  193   :  0000_0000  0x00    0    
  194   :  0000_0000  0x00    0    
  195   :  0000_1110  0x0E   14    
  196   :  0001_0000  0x10   16    
);
  
### offset from above = 149
$ancount++;
$ttl = 8910;
@rdata = ('mname.bar.com','rname.bar.com',123456789,10000,400,200000,3600);
($off, @dnptrs) = $put->SOA(\$buffer,$off,\@dnptrs,$name,$ttl,@rdata);
#print_head(\$buffer);
#print_buf(\$buffer); 
#print_ptrs(@dnptrs); 
put_ancount(\$buffer,$ancount);
chk_exp(\$buffer,\$exptext);


## test 9       check load of internal test buffer
my($answers,$toff) = rblf_load_dnstest($buffer);
my $exp = 5;
print "got: $answers, exp: $exp\nnot "
	unless $answers == $exp;
&ok;

## test 10
$exp = 197;	# final offest
print "got: $toff, exp: $exp\nnot "
	unless $toff == $exp;
&ok;

## test 11	dump and check the internal packet buffer
my($len,$packet) = rblf_dump_packet();
print "got: $len, exp: $exp\nnot "
	unless $len == $exp;
&ok;

## test 12
chk_exp(\$packet,\$exptext);

########## transfer mechanisms tested, internal buffer verified
# check query response for NS A TXT MX SOA, uncompressed
#
## test 13-17	check case out of NS
my($type,$rdl);
($type,$ttl,$rdl,$rdata,$off) = rblf_next_answer();
$exptext = q(
  0     :  0000_0101  0x05    5    
  1     :  0110_0111  0x67  103  g  
  2     :  0110_1111  0x6F  111  o  
  3     :  0110_1111  0x6F  111  o  
  4     :  0111_0011  0x73  115  s  
  5     :  0110_0101  0x65  101  e  
  6     :  0000_0011  0x03    3    
  7     :  0110_0110  0x66  102  f  
  8     :  0110_1111  0x6F  111  o  
  9     :  0110_1111  0x6F  111  o  
  10    :  0000_0011  0x03    3    
  11    :  0110_0010  0x62   98  b  
  12    :  0110_0001  0x61   97  a  
  13    :  0111_0010  0x72  114  r  
  14    :  0000_0011  0x03    3    
  15    :  0110_0011  0x63   99  c  
  16    :  0110_1111  0x6F  111  o  
  17    :  0110_1101  0x6D  109  m  
  18    :  0000_0000  0x00    0    
);
##subtest	type
$exp = 'T_NS';
print 'got: '. TypeTxt->{$type} .", exp: $exp\nnot "
	unless TypeTxt->{$type} eq $exp;
&ok;

##subtest	ttl
$exp = 1234;
print "got: $ttl, exp: $exp\nnot "
	unless $ttl == $exp;
&ok;

##subtest	rdl
$exp = 19;
print "got: $rdl, exp: $exp\nnot "
	unless $rdl == $exp;
&ok;

##subtest	rdata
#print_buf(\$rdata);
chk_exp(\$rdata,\$exptext);

##subtest	offset
$exp = 49;
print "got: $off, exp: $exp\nnot "
	unless $off == $exp;
&ok;

## test 18-22	check case out of A
($type,$ttl,$rdl,$rdata,$off) = rblf_next_answer();
$exptext = q(
  0     :  0000_1010  0x0A   10    
  1     :  0110_0010  0x62   98  b  
  2     :  0100_1100  0x4C   76  L  
  3     :  0011_0110  0x36   54  6  
);
##subtest	type
$exp = 'T_A';
print 'got: '. TypeTxt->{$type} .", exp: $exp\nnot "
	unless TypeTxt->{$type} eq $exp;
&ok;

##subtest	ttl
$exp = 567;
print "got: $ttl, exp: $exp\nnot "
	unless $ttl == $exp;
&ok;

##subtest	rdl
$exp = 4;
print "got: $rdl, exp: $exp\nnot "
	unless $rdl == $exp;
&ok;

##subtest	rdata
#print_buf(\$rdata);
chk_exp(\$rdata,\$exptext);

##subtest	offset
$exp = 65;
print "got: $off, exp: $exp\nnot "
	unless $off == $exp;
&ok;

## test 23-27	check case out of TXT
($type,$ttl,$rdl,$rdata,$off) = rblf_next_answer();
$exptext = q(
  0     :  0010_1100  0x2C   44  ,  
  1     :  0101_0100  0x54   84  T  
  2     :  0110_1000  0x68  104  h  
  3     :  0110_0101  0x65  101  e  
  4     :  0010_0000  0x20   32     
  5     :  0101_0001  0x51   81  Q  
  6     :  0111_0101  0x75  117  u  
  7     :  0110_1001  0x69  105  i  
  8     :  0110_0011  0x63   99  c  
  9     :  0110_1011  0x6B  107  k  
  10    :  0010_0000  0x20   32     
  11    :  0100_0010  0x42   66  B  
  12    :  0111_0010  0x72  114  r  
  13    :  0110_1111  0x6F  111  o  
  14    :  0111_0111  0x77  119  w  
  15    :  0110_1110  0x6E  110  n  
  16    :  0010_0000  0x20   32     
  17    :  0100_0110  0x46   70  F  
  18    :  0110_1111  0x6F  111  o  
  19    :  0111_1000  0x78  120  x  
  20    :  0010_0000  0x20   32     
  21    :  0100_1010  0x4A   74  J  
  22    :  0111_0101  0x75  117  u  
  23    :  0110_1101  0x6D  109  m  
  24    :  0111_0000  0x70  112  p  
  25    :  0110_0101  0x65  101  e  
  26    :  0110_0100  0x64  100  d  
  27    :  0010_0000  0x20   32     
  28    :  0100_1111  0x4F   79  O  
  29    :  0111_0110  0x76  118  v  
  30    :  0110_0101  0x65  101  e  
  31    :  0111_0010  0x72  114  r  
  32    :  0010_0000  0x20   32     
  33    :  0101_0100  0x54   84  T  
  34    :  0110_1000  0x68  104  h  
  35    :  0110_0101  0x65  101  e  
  36    :  0010_0000  0x20   32     
  37    :  0100_1100  0x4C   76  L  
  38    :  0110_0001  0x61   97  a  
  39    :  0111_1010  0x7A  122  z  
  40    :  0111_1001  0x79  121  y  
  41    :  0010_0000  0x20   32     
  42    :  0100_0100  0x44   68  D  
  43    :  0110_1111  0x6F  111  o  
  44    :  0110_0111  0x67  103  g  
);
##subtest	type
$exp = 'T_TXT';
print 'got: '. TypeTxt->{$type} .", exp: $exp\nnot "
	unless TypeTxt->{$type} eq $exp;
&ok;

##subtest	ttl
$exp = 678;
print "got: $ttl, exp: $exp\nnot "
	unless $ttl == $exp;
&ok;

##subtest	rdl
$exp = 45;
print "got: $rdl, exp: $exp\nnot "
	unless $rdl == $exp;
&ok;

##subtest	rdata
#print_buf(\$rdata);
chk_exp(\$rdata,\$exptext);

##subtest	offset
$exp = 122;
print "got: $off, exp: $exp\nnot "
	unless $off == $exp;
&ok;

## test 28-32	check case out of MX
($type,$ttl,$rdl,$rdata,$off) = rblf_next_answer();
$exptext = q(
  0     :  0000_0000  0x00    0    
  1     :  0011_0111  0x37   55  7  
  2     :  0000_1010  0x0A   10    
  3     :  0110_1101  0x6D  109  m  
  4     :  0110_0001  0x61   97  a  
  5     :  0110_1001  0x69  105  i  
  6     :  0110_1100  0x6C  108  l  
  7     :  0111_0011  0x73  115  s  
  8     :  0110_0101  0x65  101  e  
  9     :  0111_0010  0x72  114  r  
  10    :  0111_0110  0x76  118  v  
  11    :  0110_0101  0x65  101  e  
  12    :  0111_0010  0x72  114  r  
  13    :  0000_0011  0x03    3    
  14    :  0110_0010  0x62   98  b  
  15    :  0110_0001  0x61   97  a  
  16    :  0111_0010  0x72  114  r  
  17    :  0000_0011  0x03    3    
  18    :  0110_0011  0x63   99  c  
  19    :  0110_1111  0x6F  111  o  
  20    :  0110_1101  0x6D  109  m  
  21    :  0000_0000  0x00    0    
);
##subtest	type
$exp = 'T_MX';
print 'got: '. TypeTxt->{$type} .", exp: $exp\nnot "
	unless TypeTxt->{$type} eq $exp;
&ok;

##subtest	ttl
$exp = 789;
print "got: $ttl, exp: $exp\nnot "
	unless $ttl == $exp;
&ok;

##subtest	rdl
$exp = 22;
print "got: $rdl, exp: $exp\nnot "
	unless $rdl == $exp;
&ok;

##subtest	rdata
#print_buf(\$rdata);
chk_exp(\$rdata,\$exptext);

##subtest	offset
$exp = 149;
print "got: $off, exp: $exp\nnot "
	unless $off == $exp;
&ok;

## test 33-37	check case out of SOA
($type,$ttl,$rdl,$rdata,$off) = rblf_next_answer();
$exptext = q(
  0     :  0000_0101  0x05    5    
  1     :  0110_1101  0x6D  109  m  
  2     :  0110_1110  0x6E  110  n  
  3     :  0110_0001  0x61   97  a  
  4     :  0110_1101  0x6D  109  m  
  5     :  0110_0101  0x65  101  e  
  6     :  0000_0011  0x03    3    
  7     :  0110_0010  0x62   98  b  
  8     :  0110_0001  0x61   97  a  
  9     :  0111_0010  0x72  114  r  
  10    :  0000_0011  0x03    3    
  11    :  0110_0011  0x63   99  c  
  12    :  0110_1111  0x6F  111  o  
  13    :  0110_1101  0x6D  109  m  
  14    :  0000_0000  0x00    0    
  15    :  0000_0101  0x05    5    
  16    :  0111_0010  0x72  114  r  
  17    :  0110_1110  0x6E  110  n  
  18    :  0110_0001  0x61   97  a  
  19    :  0110_1101  0x6D  109  m  
  20    :  0110_0101  0x65  101  e  
  21    :  0000_0011  0x03    3    
  22    :  0110_0010  0x62   98  b  
  23    :  0110_0001  0x61   97  a  
  24    :  0111_0010  0x72  114  r  
  25    :  0000_0011  0x03    3    
  26    :  0110_0011  0x63   99  c  
  27    :  0110_1111  0x6F  111  o  
  28    :  0110_1101  0x6D  109  m  
  29    :  0000_0000  0x00    0    
  30    :  0000_0111  0x07    7    
  31    :  0101_1011  0x5B   91  [  
  32    :  1100_1101  0xCD  205    
  33    :  0001_0101  0x15   21    
  34    :  0000_0000  0x00    0    
  35    :  0000_0000  0x00    0    
  36    :  0010_0111  0x27   39  '  
  37    :  0001_0000  0x10   16    
  38    :  0000_0000  0x00    0    
  39    :  0000_0000  0x00    0    
  40    :  0000_0001  0x01    1    
  41    :  1001_0000  0x90  144    
  42    :  0000_0000  0x00    0    
  43    :  0000_0011  0x03    3    
  44    :  0000_1101  0x0D   13    
  45    :  0100_0000  0x40   64  @  
  46    :  0000_0000  0x00    0    
  47    :  0000_0000  0x00    0    
  48    :  0000_1110  0x0E   14    
  49    :  0001_0000  0x10   16    
);
##subtest	type
$exp = 'T_SOA';
print 'got: '. TypeTxt->{$type} .", exp: $exp\nnot "
	unless TypeTxt->{$type} eq $exp;
&ok;

##subtest	ttl
$exp = 8910;
print "got: $ttl, exp: $exp\nnot "
	unless $ttl == $exp;
&ok;

##subtest	rdl
$exp = 50;
print "got: $rdl, exp: $exp\nnot "
	unless $rdl == $exp;
&ok;

##subtest	rdata
#print_buf(\$rdata);
chk_exp(\$rdata,\$exptext);

##subtest	offset
$exp = 197;
print "got: $off, exp: $exp\nnot "
	unless $off == $exp;
&ok;

