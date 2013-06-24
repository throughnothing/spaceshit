use Modern::Perl;

#use Player;

use AnyEvent;
use AnyEvent::Socket qw/tcp_server/;
use AnyEvent::Handle;
use JSON;

use TryCatch;

my %conns;

my %command_dispatch = (
    'part' => \&part_player,
    'join' => \&join_player,
    'thrust' => \&toggle_thrusters_player_ship,
    'turn' => \&toggle_turn_player_ship,
    'fire' => \&fire_player_bullet,
);

sub response_json {
    my ($player) = @_;
    my %response = (
        cmd => "info",
        type => "spaceship",
        x    => $player->{x},
        y    => $player->{y},
        id   => $player->{id},
        angle => $player->{angle},
    );
    to_json(\%response);
};

sub generate_player_updates {
    for my $xid ( keys %conns ) {
        my $player = ${conns}{$xid};
        if( $player->{thrust} && $player->{thrust}  eq "forward" ) {
            $player->{x} += 0.01;
            #$player{y} += 0.01;
        }
        print response_json($player);
        syswrite $player->{fh}, response_json($player) . "\015\012";
    }
};

sub generate_spectator_updates {
    for my $xid ( keys %conns ) {
        if( $conns{$xid}{type} eq "spectator" ){
            my $spectator = ${conns}{$xid};
            for my $yid ( keys %conns ) {
                my $player = ${conns}{$yid};
                syswrite $spectator->{fh}, response_json($player) . "\015\012";
            }
        }
    }
};

sub join_player {
    my ($request, $extra_args) = @_;
    my $id = $extra_args->{host} . ":" . $extra_args->{port};
    $conns{$id}{type} = $request->{type};
    $conns{$id}{host} = $extra_args->{host};
    $conns{$id}{port} = $extra_args->{port};
    $conns{$id}{fh} = $extra_args->{fh};
    $conns{$id}{x} = 0;
    $conns{$id}{y} = 0;
    $conns{$id}{angle} = 0;
    $conns{$id}{rotation} = 0;
    $conns{$id}{speed} = 10;
    $conns{$id}{id} = $id;
    use Data::Dumper;
    print "conns " . Dumper %conns;
}

sub part_player {
    my ($request, $extra_args) = @_;
};

sub toggle_thrusters_player_ship {
    my ($request, $extra_args) = @_;
    my $id = "" . $extra_args->{host}. ":". $extra_args->{port};
    $conns{$id}{thrust} = $request->{dir};

    syswrite $conns{$id}{fh}, "Set Thrusting \n";
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
my $pt = AnyEvent->timer (
    after => 5,
    interval => 1,
    cb => \&generate_player_updates,
);

my $st = AnyEvent->timer (
    after => 5,
    interval => 1,
    cb => \&generate_spectator_updates,
);

my $guard = tcp_server undef, 9000, sub {
    my ($fh, $host, $port) = @_;

    syswrite $fh, scalar(keys %conns) > 0 ?
    "There are " . scalar(keys %conns) . " players\015\012" :
    "There are no other players to challenge you yet\015\012";

    my $hdl = AnyEvent::Handle->new( fh => $fh,
        on_error => sub {
            say "we got an error";
            say "$_[2]";
            $_[0]->destroy;
        } );
    my $reader;
    $reader = sub {
        try {

            my $line = $_[1];
            print "line = $line\n";
            $hdl->push_read( line => $reader ) if ($line eq "");
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
            #generate_random_updates;
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


