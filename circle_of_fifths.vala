class CircleOfFifths : Gtk.Widget
{
    public struct SectorSpec {
        string label;
        Cairo.Pattern pattern;
    }

    private const int big_amp = 10;
    private const int little_amp = 6;
    private SectorSpec[] _colors = {};
    private double sweep;

    public SectorSpec[] colors
    {
        get { return _colors; }
        set {
            _colors = value;
            sweep = 2 * Math.PI / _colors.length;
        }
    }

    public override Gtk.SizeRequestMode get_request_mode ()
    {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    public override void measure (Gtk.Orientation orientation, int for_size, out int minimum, out int natural, out int minimum_baseline, out int natural_baseline)
    {
        minimum = 400;
        natural = 400;
        minimum_baseline = -1;
        natural_baseline = -1;
    }

    public override void snapshot (Gtk.Snapshot snsh)
    {
        var radius = int.min (get_width (), get_height ()) / 2;

        var cr = snsh.append_cairo (Graphene.Rect.zero ().init (0.0f, 0.0f, get_width (), get_height ()));
        with (cr)
        {
            set_line_width (0.1);
            translate (radius, radius);

            save ();
                scale (radius / big_amp, radius / big_amp);
                rotate (-sweep / 2);

                if (_colors.length != 0)
                {
                    var i = 0;
                    Cairo.Pattern? color = _colors[i++].pattern;
                    while (color != null)
                    {
                        set_source (color);
                        var span = 1;

                        while (true)
                        {
                            color = null;
                            if (i == _colors.length)
                                break;
                            color = _colors[i++].pattern;
                            if (color != get_source ())
                                break;
                            ++span;
                        }

                        arc (0.0, 0.0, big_amp, 0.0, span * sweep);
                        rotate (span * sweep);
                        arc_negative (0.0, 0.0, little_amp, 0.0, -span * sweep);
                        fill ();
                    }
                }

                set_source (new Cairo.Pattern.rgb (0, 0, 0));

                arc (0, 0, big_amp, 0, 2 * Math.PI);
                stroke ();
                arc (0, 0, little_amp, 0, 2 * Math.PI);
                stroke ();

                if (_colors.length % 4 == 0 )
                    for (int j = 0; j < _colors.length / 4; ++j)
                    {
                        move_to (little_amp, 0);
                        line_to (big_amp, 0);
                        move_to (-little_amp, 0);
                        line_to (-big_amp, 0);
                        move_to (0, little_amp);
                        line_to (0, big_amp);
                        move_to (0, -little_amp);
                        line_to (0, -big_amp);
                        stroke();
                        rotate (sweep);
                    }
                else
                    for (int j = 0; j < _colors.length; ++j)
                    {
                        move_to (little_amp, 0);
                        line_to (big_amp, 0);
                        stroke();
                        rotate (sweep);
                    }
            restore ();
        }

        var layout = Pango.cairo_create_layout (cr);
        var font = Pango.cairo_create_context (cr).get_font_description ().copy_static ();
        font.set_size (Pango.SCALE * radius * (big_amp - little_amp) / 2 / big_amp);
        layout.set_font_description (font);
        var text_radius = radius * (big_amp + little_amp) / 2 / big_amp;

        var phi = 0.0;
        for (var i = 0; i < _colors.length; ++i)
        {
            int width, height;
            layout.set_text (_colors[i].label, -1);
            layout.get_size (out width, out height);
            cr.move_to (
                text_radius * Math.cos (phi) - width / Pango.SCALE / 2,
                text_radius * Math.sin (phi) - height / Pango.SCALE / 2
            );
            phi += sweep;
            Pango.cairo_show_layout (cr, layout);
        }
    }
}
