namespace Audience {
    public class WelcomePage : Granite.Widgets.Welcome {
        public WelcomePage () {
            base (_("No Videos Open"), _("Select a source to begin playing."));
            this.append ("document-open", _("Open file"), _("Open a saved file."));

            this.set_size_request (350, 300);

            var filename = settings.current_video;
            var last_file = File.new_for_uri (filename);
            bool show_last_file = settings.current_video != "";
            if (last_file.query_exists () == false) {
                show_last_file = false;
            }

            if (settings.last_stopped == 0.0 || !settings.resume_videos)
                this.append ("media-playlist-repeat", _("Replay last video"), get_title (last_file.get_basename ()));
            else
                this.append ("media-playback-start", _("Resume last video"), get_title (last_file.get_basename ()));
            this.set_item_visible (1, show_last_file);

            //look for dvd
            this.append ("media-cdrom", _("Play from Disc"), _("Watch a DVD or open a file from disc"));
            this.set_item_visible (2, App.get_instance ().has_media_volumes ());
            App.get_instance ().media_volumes_changed.connect (() => {
                this.set_item_visible (2, App.get_instance ().has_media_volumes ());
            });

           //handle welcome
            this.activated.connect (on_activate);

            App.get_instance ().set_window_title (App.get_instance ().program_name);
            // FIXME : dont know why but cant move this to Audience.vala
            App.get_instance ().mainwindow.set_default_size (960, 640);

            App.get_instance ().mainwindow.key_press_event.connect (on_key_press_event);

        }
        ~WelcomePage () {
            this.activated.disconnect (on_activate);
            App.get_instance ().mainwindow.key_press_event.disconnect (on_key_press_event);
        }
        private void on_activate (int index) {
            switch (index) {
                case 0:
                    // Open file
                    App.get_instance ().run_open_file ();
                    break;
                case 1:
                    App.get_instance ().resume_last_videos ();
                    break;
                case 2:
                    App.get_instance ().run_open_dvd ();
                    break;
            }
        }
        private bool on_key_press_event (Gdk.EventKey e) {
            switch (e.keyval) {
                case Gdk.Key.p:
                case Gdk.Key.space:
                    App.get_instance ().resume_last_videos ();
                    break;
                default:
                    break;
            }

            return false;
        }
    }
}
