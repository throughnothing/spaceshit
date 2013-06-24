package Player;
#use Moose;

my ($x,$y, $rotation, $speed, $host, $port, $fh, $angle );

#has 'x' => ( is => 'rw' ) ;#, isa => 'Int' );
#has 'y' => ( is => 'rw' ); #, isa => 'Int' );
#has 'rotation' => ( is => 'rw', isa => 'Bool' );
#has 'speed' => ( is => 'rw', isa => 'Bool' );
#has 'host' => ( is => 'rw', isa => 'Str' );
#has 'port' => ( is => 'rw', isa => 'Int' );
#has 'fh' => ( is => 'rw', isa => 'FileHandle' );
#has 'angle' => (is => 'rw', isa => 'Num' );

sub new {
    my ($args ) = @_;
    print "args-x : " . $args->{x} . "\n";
    $x=$args->{x};
    $y=$args->{y};
    $fh=$args->{fh};
    $host= $args->{host};
    $port= $args->{port};
    $speed= $args->{speed};
    $rotation= $args->{rotation};
    $angle=0;

    #$self->x($args->{x});
    #$self->y($args->{y});
    #$self->fh($args->{fh});
    #$self->host( $args->{host});
    #$self->port( $args->{port});
    #$self->speed( $args->{speed});
    #$self->rotation( $args->{rotation});
    #$self->angle(0);
};

sub response_json {
    #my ($self) = @_;
    my %response = (
        cmd => "info",
        type => "spaceship",
        x    => $x,
        y    => $y,
        id   => $id,
        angle => $angle,
    );
    to_json(\%response);
};

sub id {
    #my $self = @_;
    return "player";

    return $host . ":". $port;
};

1;

