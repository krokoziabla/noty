extern void play_note (Alsa.SeqDevice device, int port, int note);

[GtkTemplate (ui = "/krokoziabla/noty/root_window.xml")]
class RootWindow : Gtk.ApplicationWindow, Actions
{
    private Alsa.SeqDevice device;
    private int port;
    private Source source;
    private State state = new Riddle (Params () {lower_octave = 2, upper_octave = 6, octave_size = 12});

    [GtkChild]
    private unowned CircleOfFifths circle_of_fifths;

    public RootWindow (Gtk.Application app)
    {
        Object(application: app);

        var stream = new DataInputStream (resources_open_stream ("/krokoziabla/noty/major_notes.txt", 0));
        CircleOfFifths.SectorSpec[] colors = {};

        while (true)
        {
            string? line = stream.read_line_utf8 ();
            if (line == null)
                break;
            colors += CircleOfFifths.SectorSpec () { label = line, pattern = new Cairo.Pattern.rgba (0, 0, 0, 0) };
        }
        stream.close ();

        circle_of_fifths.colors = colors;

        Alsa.SeqDevice.open (out device, "default", Alsa.SeqOpenMode.DUPLEX, 0);
        port = device.create_simple_port ("Noty", Alsa.SeqPortCap.WRITE | Alsa.SeqPortCap.READ, Alsa.SeqPortType.APPLICATION);
        device.connect_from (port, 40, 0);
        device.connect_to (port, 128, 0);

        source = new AlsaSource (device, (event) => {
            if (event.type == Alsa.SeqEventType.NOTEON) {
                state = state.key_pressed (event.note.note, this);
                state.perform_eigenactions (this);
            }
            return true;
        });
        source.attach ();

        var click = new Gtk.GestureClick ();
        click.pressed.connect ((click, n_press, x, y) => {
            state = state.mouse_clicked (this);
            state.perform_eigenactions (this);
        });
        circle_of_fifths.add_controller (click);
    }
    ~RootWindow ()
    {
        device.delete_simple_port (port);
        device.close ();
    }

    private void play (int note)
    {
        play_note (device, port, note);
    }
    private void draw (int? wrong, int? right)
    {
        for (int i = 0; i < circle_of_fifths.colors.length; ++i) {
            var note = (i + 3) * 7 % circle_of_fifths.colors.length;

            if (wrong != null && wrong % circle_of_fifths.colors.length == note)
                circle_of_fifths.colors[i].pattern = new Cairo.Pattern.rgb (1, 0, 0);
            else if (right != null && right % circle_of_fifths.colors.length == note)
                circle_of_fifths.colors[i].pattern = new Cairo.Pattern.rgb (0, 1, 0);
            else
                circle_of_fifths.colors[i].pattern = new Cairo.Pattern.rgba (0, 0, 0, 0);
        }
        circle_of_fifths.queue_draw ();
    }
}
