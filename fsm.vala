interface Actions {
    public abstract void play (int note);
    public abstract void draw (int? wrong, int? right);
}

interface State: GLib.Object {
    public abstract State key_pressed (int key, Actions actions);
    public abstract State mouse_clicked (Actions actions);
    public abstract void perform_eigenactions (Actions actions);
}

struct Params {
    int lower_octave;
    int upper_octave;
    int octave_size;
}

class Riddle: State, GLib.Object {
    private Params p;
    private int secret;
    private Rand rand = new Rand ();

    public Riddle (Params p)
    {
        this.p = p;
        this.secret = rand.int_range (p.lower_octave * p.octave_size, p.upper_octave * p.octave_size);
    }
    State key_pressed (int key, Actions actions)
    {
        if (key % p.octave_size == secret % p.octave_size) {
            actions.draw (null, key);
            return new Riddle (p);
        } else {
            actions.draw (key, secret);
            actions.play (secret);
            actions.play (key);
            return new Answer (p);
        }
    }
    State mouse_clicked (Actions actions)
    {
        return this;
    }
    void perform_eigenactions (Actions actions)
    {
        actions.play (secret);
    }
}

class Answer: State, GLib.Object {
    private Params p;

    public Answer (Params p)
    {
        this.p = p;
    }
    State key_pressed (int key, Actions actions)
    {
        actions.play (key);
        return this;
    }
    State mouse_clicked (Actions actions)
    {
        actions.draw (null, null);
        return new Riddle (p);
    }
    void perform_eigenactions (Actions actions)
    {
    }
}
