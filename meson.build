project('noty', 'vala')

executable(
    meson.project_name(),
    'alsa_source.vala',
    'circle_of_fifths.vala',
    'fsm.vala',
    'helpers.c',
    'main.vala',
    'root_window.vala',
    import('gnome').compile_resources('main', 'gresource.xml'),
    c_args: ['-Wall','-Wextra'],
    dependencies: [
        meson.get_compiler('c').find_library('m', required: true),
        dependency('glib-2.0', version: '>=2.38'),
        dependency('gtk4'),
        dependency('gee-0.8'),
        dependency('alsa'),
        dependency('pango'),
        dependency('pangocairo'),
    ])
