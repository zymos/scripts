#!/usr/bin/perl

    use strict;
    use warnings;

    use lib qw(/home/jason/bin);

    use Getopt::Std;
    use File::Basename;
    use FFmpeg::Command;
    use FFprobe;

    $|++;

    ###############################
    sub _encode_mp3 {
      my ($input_file, $output_dir, $album, $starting_track) = @_;

      my %tags = ();
      my $track_number;
      my $mp4 = FFprobe->probe_file($input_file);
      my $base_output_file = basename($input_file);
      $base_output_file =~ s/\.\w+$//;

      if (exists $mp4->{format}->{'TAG:comment'}) {
        $tags{genre} = $mp4->{format}->{'TAG:comment'};
        $tags{genre} =~ s/("')//g;
      }

      if (exists $mp4->{format}->{'TAG:genre'}) {
        $tags{genre} = $mp4->{format}->{'TAG:genre'};
        $tags{genre} =~ s/("')//g;
      }

      if (exists $mp4->{format}->{'TAG:artist'}) {
        $tags{artist} = $mp4->{format}->{'TAG:artist'};
        $tags{artist} =~ s/("')//g;
      }

      if ($album) {
        $tags{album} = $album;
      } elsif (exists $mp4->{format}->{'TAG:album'}) {
        $tags{album} = $mp4->{format}->{'TAG:album'};
      }

      $tags{album} =~ s/("')//g;
      $track_number = $starting_track if $starting_track;

      foreach my $chapter (sort keys %{$mp4->{chapters}}) {
        unless ($starting_track) {
          $track_number = $chapter;
        }

        my $output_file = sprintf "%s/%03d %s.mp3", $output_dir, $track_number, $tags{album};
        my $start = $mp4->{chapters}->{$chapter}->{start};
        my $duration = $mp4->{chapters}->{$chapter}->{end} - $start;
        my @options = ();

        if ($album) {
          $tags{title} = sprintf "%03d – %s", $track_number, $album;
        } else {
          if (exists $mp4->{format}->{'TAG:title'}) {
            $tags{title} = sprintf "%03d – %s", $track_number, $mp4->{format}->{'TAG:title'};
          } else {
            $tags{title} = sprintf "%03d – %s", $track_number, $base_output_file;
          }
        }

        $tags{title} =~ s/("')//g;

        my $ffmpeg = FFmpeg::Command->new;

        $ffmpeg->input_options({
            file => $input_file,
         });

        $ffmpeg->output_options({
         'file' => $output_file,
         'audio_codec' => 'libmp3lame',
         'audio_bit_rate' => 64,
         });

        printf "Converting \"%s\" to \"%s\"…\n", basename($input_file), $output_file;

        foreach my $tag (keys %tags) {
          push @options, '-metadata', $tag . "=" . $tags{$tag};
          printf "\t%s: %s\n", $tag, $tags{$tag};
        }

        push @options,
          '-metadata' => 'track=' . $track_number,
          '-ss' => $start,
          '-t' => $duration;

        printf "\ttrack: %d\n", $track_number;

        $ffmpeg->options(
          @options
        );

        $ffmpeg->exec();
        print "\t… COMPLETE\n";
        $track_number++ if $starting_track;
      }
    }
    ###############################

    my %arg_options = ();
    getopts('a:i:o:t:', \%arg_options);

    if ($arg_options{i} && $arg_options{o}) {
      my $input_file = $arg_options{i};
      my $output_dir = $arg_options{o};
      my $starting_track = $arg_options{t};
      my $album = $arg_options{a};

      if (-f $input_file && -d $output_dir) {
        _encode_mp3($input_file, $output_dir, $album, $starting_track);
      } else {
        warn ("Unable to find file: \"" . $input_file . "\"\n") unless -f $input_file;
        warn ("Unable to find dir: \"" . $output_dir . "\"\n") unless -f $output_dir;
      }
    }
