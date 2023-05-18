[GtkTemplate (ui = "/krokoziabla/noty/root_window.xml")]
class RootWindow : Gtk.ApplicationWindow
{
    public RootWindow(Gtk.Application app)
    {
        Object(application: app);

        circle_of_fifths.set_draw_func (this.drawCircleOfFifths);

        var stream = new DataInputStream (resources_open_stream ("/krokoziabla/noty/major_notes.txt", 0));
        while (true)
        {
            var transparent = new Cairo.Pattern.rgba (0, 0, 0, 0);
            string? line = stream.read_line_utf8 ();
            if (line == null)
                break;
            colors.@set (line, transparent);
        }
        stream.close ();

        colors.@set("C", new Cairo.Pattern.rgba (1, 0, 0, 1));

        sweep = 2 * Math.PI / colors.size;
    }

    [GtkChild]
    private unowned Gtk.DrawingArea circle_of_fifths;
    private const int big_amp = 10;
    private const int little_amp = 6;

    private Gee.Map<string, Cairo.Pattern> colors = new Gee.HashMap<string, Cairo.Pattern> ();
    private double sweep;


    void drawCircleOfFifths (Gtk.DrawingArea drawing_area, Cairo.Context cr, int width, int height)
    {
        var radius = int.min (width, height) / 2;

        with (cr)
        {
            set_line_width (0.1);
            translate (radius, radius);

            save ();
                scale (radius / big_amp, radius / big_amp);
                rotate (-sweep / 2);

                var i = colors.map_iterator ();
                if (i.next ())
                {
                    Cairo.Pattern? color = i.get_value ();
                    while (color != null)
                    {
                        set_source (color);
                        var span = 1;

                        color = null;
                        while (i.next ())
                        {
                            color = i.get_value ();
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

                if (colors.size % 4 == 0 )
                {
                    for (int j = 0; j < colors.size / 4; ++j)
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
                }
                else
                    for (int j = 0; j < colors.size; ++j)
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

        var i = colors.map_iterator ();
        var phi = 0.0;
        while (i.next ())
        {
            layout.set_text (i.get_key (), -1);
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
