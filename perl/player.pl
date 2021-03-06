use Modern::Perl;

use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use Socket qw( SOL_SOCKET SO_REUSEPORT );
use JSON;

my $server = $ENV{SPACESHIT_SERVER};
my $port = $ENV{SPACESHIT_PORT};

sub join_cmd {
    my ($fh, $handle) = @_;
    my $cmd = { cmd => 'join', type => 'player' };
    syswrite $fh, "@{[to_json($cmd)]}\015\012";

    $handle->push_read( line => sub {
        my ($handle, $line) = @_;
        say "$line";
    });
};

sub thrust_forward_cmd {
    my ($fh, $handle) = @_;
    my $cmd = { cmd => 'thrust', dir => 'forward' };
    syswrite $fh, "@{[to_json($cmd)]}\015\012";

    $handle->push_read( line => sub {
        my ($handle, $line) = @_;
        say "$line";
    });
};

sub thrust_off_cmd {
    my ($fh, $handle) = @_;
    my $cmd = { cmd => 'thrust', dir => 'off' };
    syswrite $fh, "@{[to_json($cmd)]}\015\012";

    $handle->push_read( line => sub {
        my ($handle, $line) = @_;
        say "$line";
    });
};

tcp_connect $server, $port, sub {
    my ($fh) = @_ or die "Connecting to $server:$port failed: $!";

    my $handle;
    $handle = AnyEvent::Handle->new(
        fh     => $fh,
        on_error => sub {
            say "we got an error";
            say "$_[2]";
            $_[0]->destroy;
        },
        on_eof => sub {
            $handle->destroy;
            say "Server ended.";
        },
        on_read => sub {
            print $_[0]->rbuf;
            $_[0]->rbuf = "";
        },
    );

    join_cmd ($fh, $handle);

    # This is really dumb, but I guess it works for now.
    foreach my $i (1..5) {
      int(rand(2)) ?
        thrust_forward_cmd ($fh, $handle) :
        thrust_off_cmd($fh, $handle),
        sleep(int(rand(6)));
    }
    thrust_forward_cmd ($fh, $handle);
};

AnyEvent->condvar->recv;
