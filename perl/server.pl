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

sub generate_random_updates {
    for my $xid ( keys %conns ) {
        my $player = ${conns}{$xid};
        syswrite $player->{fh}, response_json($player) . "\015\012";
    }
};

#sub generate_spectator_update {


#};

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

#sub join_player {
    #my ($request, $extra_args) = @_;

    #try {
        #Player::new( { x => 1, y => 0,
            #fh => $extra_args->{fh}, rotation => 0, speed => 0,
            #host => $extra_args->{host}, port => $extra_args->{port},
            #type => $request->{type}
        #});

        #$conns{Player::id()} = $player;
        #syswrite $player->fh, "debugging: " . to_json( $request) . "\015\012";
    #} catch ($e) {
        #print "error : " . $e;
    #}
#};

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
            my $w = AnyEvent->timer (
                after => 5,
                interval => 1,
                cb => \&generate_random_updates,
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


