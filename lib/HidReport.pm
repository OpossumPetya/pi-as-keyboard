package HidReport;

use strict;
use warnings;

$|=1;

use constant {
    LEFT_CTRL   => 0b00000001,
    LEFT_SHIFT  => 0b00000010,
    LEFT_ALT    => 0b00000100,
    LEFT_GUI    => 0b00001000, # MS Win key, Mac Apple key, Sun Meta key
    RIGHT_CTRL  => 0b00010000,
    RIGHT_SHIFT => 0b00100000,
    RIGHT_ALT   => 0b01000000,
    RIGHT_GUI   => 0b10000000,
};

my %lower = (
    ord('a') => 0x04,
    ord('b') => 0x05,
    ord('c') => 0x06,
    ord('d') => 0x07,
    ord('e') => 0x08,
    ord('f') => 0x09,
    ord('g') => 0x0A,
    ord('h') => 0x0B,
    ord('i') => 0x0C,
    ord('j') => 0x0D,
    ord('k') => 0x0E,
    ord('l') => 0x0F,
    ord('m') => 0x10,
    ord('n') => 0x11,
    ord('o') => 0x12,
    ord('p') => 0x13,
    ord('q') => 0x14,
    ord('r') => 0x15,
    ord('s') => 0x16,
    ord('t') => 0x17,
    ord('u') => 0x18,
    ord('v') => 0x19,
    ord('w') => 0x1A,
    ord('x') => 0x1B,
    ord('y') => 0x1C,
    ord('z') => 0x1D,
    10       => 0x28, # New Line
    13       => 0x28, # Carriage Return
    9        => 0x2B, # Tab
    ord(' ') => 0x2C,
    ord('1') => 0x1E,
    ord('2') => 0x1F,
    ord('3') => 0x20,
    ord('4') => 0x21,
    ord('5') => 0x22,
    ord('6') => 0x23,
    ord('7') => 0x24,
    ord('8') => 0x25,
    ord('9') => 0x26,
    ord('0') => 0x27,
    ord('-') => 0x2D,
    ord('=') => 0x2E,
    ord('[') => 0x2F,
    ord(']') => 0x30,
    ord('\\') => 0x31,
    ord(';') => 0x33,
    ord("'") => 0x34,
    ord('`') => 0x35,
    ord(',') => 0x36,
    ord('.') => 0x37,
    ord('/') => 0x38,
);
my %upper = (
    ord('!') => 0x1E,
    ord('@') => 0x1F,
    ord('#') => 0x20,
    ord('$') => 0x21,
    ord('%') => 0x22,
    ord('^') => 0x23,
    ord('&') => 0x24,
    ord('*') => 0x25,
    ord('(') => 0x26,
    ord(')') => 0x27,
    ord('_') => 0x2D,
    ord('+') => 0x2E,
    ord('{') => 0x2F,
    ord('}') => 0x30,
    ord('|') => 0x31,
    ord(':') => 0x33,
    ord('"') => 0x34,
    ord('~') => 0x35,
    ord('<') => 0x36,
    ord('>') => 0x37,
    ord('?') => 0x38,
);

sub hex_print_str {
    my $str = shift;
    my $ret_str;
    my $len = length($str) - 1;
    for my $i (0 .. $len) {
        my $char = substr $str, $i, 1;
        $ret_str .= sprintf("%02X ", ord($char));
    }
    $ret_str // chop($ret_str);
    return $ret_str;
}

sub send_report {
    my $report = shift;
    my $debug = shift // 0;
    print hex_print_str($report)."\n" if $debug; # use debug with morbo
    open my $HIDKBD, '+<', '/dev/hidg0' 
        or die "Error: couldn't open '/dev/hidg0' for updating: $!\n";
    binmode $HIDKBD;
    print $HIDKBD $report;
    close $HIDKBD;
}

sub send_ascii_str_as_hid_report {
    my $str = shift;
    my $debug = shift // 0;
    
    my $release_keys    = "\0" x 8;
    my @report_template = (0) x 8;
        # 0     - modifier; to be populated; 0x00 to 0xFF
        # 1     - reserved; = 0x00
        # 2     - "Printable" character, 0x20 to 0x7E; to be populated
        # 3-7   - Zero-s
    
    my $len = length($str) - 1;
    for my $i (0 .. $len) {
        my @report = @report_template;
        my $char = substr $str, $i, 1;

        my $char_code = ord($char);
        if ($char_code >= 65 && $char_code <= 90 ) {
            # capital A-Z
            $report[0] = LEFT_SHIFT;
            $char = lc $char;
            $report[2] = $lower{ord($char)};
        }
        elsif ($upper{$char_code}) {
            # non-alpha-numerics created with shift: !@#$%^&*()_+|}{":?><~
            $report[0] = LEFT_SHIFT;
            $report[2] = $upper{$char_code};
        }
        elsif ($lower{$char_code}) {
            # numbers and non-alphas created without shift: [];',. ...
            $report[2] = $lower{$char_code};
        }
        else {
            # say "Unknown character: 0x".sprintf("%02X", $char_code);
        }
        
        # print hex_print_str( join('', map { chr } @report) );
        # print "\n";
        
        send_report( join('', map { chr } @report), $debug );
        send_report( $release_keys, $debug );
    }
}

1;