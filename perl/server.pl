use Modern::Perl;

use AnyEvent;
use AnyEvent::Socket qw/tcp_server/;
use AnyEvent::Handle;

my %conns;

my $gaurd = tcp_server undef, 9000, sub {
    my ($fh, $host, $port) = @_;

    syswrite $fh, scalar(keys %conns) > 0 ?
      "There are " . scalar(keys %conns) . " players\015\012" :
      "There are no other players to challeng you yet\015\012";

    my $hdl = AnyEvent::Handle->new( fh => $fh );
    my $id = "$host:$port";
    $conns{$id} = {fh => $fh, x => 0, y => 0, rotation => 0, speed => 0};

    my $reader;
    $reader = sub {
        my $line = $_[1];
        syswrite $conns{$id}{fh}, "debugging: $line\015\012";
        if ($line ~~ /get_info/i){
            syswrite $conns{$id}{fh}, "X => $conns{$id}{x}\n";
            syswrite $conns{$id}{fh}, "Y => $conns{$id}{y}\n";
            syswrite $conns{$id}{fh}, "Rotation => $conns{$id}{rotation}\n";
            syswrite $conns{$id}{fh}, "Speed => $conns{$id}{speed}\n";
        } elsif ($line ~~ /set_speed/i){
          my @args = split(/ /, $line);
          $conns{$id}{speed} = $args[1];
          syswrite $conns{$id}{fh}, "New speed is set\n";
        } elsif ($line ~~ /set_rotation/i){
          my @args = split(/ /, $line);
          $conns{$id}{rotation} = $args[1];
          syswrite $conns{$id}{fh}, "New rotation is set\n";
        }
        #for my $xid (grep {$_ ne $id} keys %conns) {
        #    syswrite $conns{$xid}, "$id $line\015\012";
        #}
        $hdl->push_read( line => $reader );
    };
    $hdl->push_read( line => $reader );
};

AnyEvent->condvar->recv;
