#include <alsa/asoundlib.h>

void play_note (snd_seq_t *device, int port, int note)
{
    snd_seq_event_t ev;

    snd_seq_ev_clear(&ev);
    snd_seq_ev_set_source(&ev, port);
    snd_seq_ev_set_subs(&ev);
    snd_seq_ev_set_direct(&ev);
    snd_seq_ev_set_noteon(&ev, 3, note, 64);
    snd_seq_event_output(device, &ev);
    snd_seq_drain_output(device);
}
