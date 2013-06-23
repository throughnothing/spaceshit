use Modern::Perl;

use AnyEvent;
use AnyEvent::Socket qw/tcp_server/;
use AnyEvent::Handle;
#use JSON::Parse qw/json_to_perl/;
use JSON;
#use JSON::XS;

use TryCatch;

my %conns;

my %command_dispatch = (
    'part' => \&part_player,
    'join' => \&join_player,
    'thrust' => \&toggle_thrusters_player_ship,
    'turn' => \&toggle_turn_player_ship,
    'fire' => \&fire_player_bullet,
);

sub join_player {
    my ($request, $extra_args) = @_;

    my $id = "" . $extra_args->{host}. ":". $extra_args->{port};
    $conns{$id} = {fh => $extra_args->{fh}, x => 0, y => 0, rotation => 0, speed => 0};
    syswrite $conns{$id}{fh}, "debugging: " . to_json( $request) . "\015\012";
};

sub part_player {
    my ($request, $extra_args) = @_;
};

sub toggle_thrusters_player_ship {
    my ($request, $extra_args) = @_;
    my $id = "" . $extra_args->{host}. ":". $extra_args->{port};
    $conns{$id}{thrust} = $request->{thrust};
};

sub toggle_turn_player_ship{
    my ($request, $extra_args) = @_;
    my $id = "" . $extra_args->{host}. ":". $extra_args->{port};
    $conns{$id}{turning} = $extra_args->{turn};
    #syswrite $conns{$id}{fh}, "New rotation is set\n";
};

sub fire_player_bullet {
    my ($request, $extra_args) = @_;
    my $id = "" . $extra_args->{host}. ":". $extra_args->{port};
    #syswrite $conns{$id}{fh},
};

my $guard = tcp_server undef, 9000, sub {
    my ($fh, $host, $port) = @_;

    syswrite $fh, scalar(keys %conns) > 0 ?
    "There are " . scalar(keys %conns) . " players\015\012" :
    "There are no other players to challeng you yet\015\012";

    my $hdl = AnyEvent::Handle->new( fh => $fh );
    my $reader;
    $reader = sub {
        try {

            my $line = $_[1];
            print "line = $line\n";
            my $request = JSON->new->decode($line);

            $hdl->push_read( line => $reader ) if !$request;

            use Data::Dumper;
            print "request: " . Dumper $request;

            my $response = $command_dispatch{ $request->{cmd}}->($request, {
                    host => $host, port => $port, fh => $fh });
            if ( $response ){
                my $id = "" . $host. ":". $port;
                syswrite $conns{$id}{fh}, $response;
            }
        } catch ($e) {
            print "error: " . $e . "\n";
         }
        #for my $xid (grep {$_ ne $id} keys %conns) {
        #    syswrite $conns{$xid}, "$id $line\015\012";
        #}
        $hdl->push_read( line => $reader );
    };
    $hdl->push_read( line => $reader );
};

AnyEvent->condvar->recv;
