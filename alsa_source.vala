[Compact (opaque = true)]
public class AlsaSource : Source
{
    public delegate bool Callback (Alsa.SeqEvent event);

    private unowned Alsa.SeqDevice device;
    private Posix.pollfd[] pfd;

    public AlsaSource (Alsa.SeqDevice device, owned Callback callback)
    {
        this.device = device;

        var npfd = device.poll_descriptors_count (Posix.POLLIN);
        pfd = new Posix.pollfd[npfd];
        device.poll_descriptors (pfd, Posix.POLLIN);

        foreach (var fd in pfd)
            add_unix_fd (fd.fd, fd.events);

        set_callback ((SourceFunc) callback);
    }

    protected override bool check ()
    {
        return (bool) device.event_input_pending (true);
    }

    protected override bool dispatch (SourceFunc? callback)
    {
        Alsa.SeqEvent event;
        device.event_input (out event);
        Callback cb = (Callback) callback;
        return cb(event) ? CONTINUE : REMOVE;
    }
}
