require 'jukebox'
require 'track'

class Player
  SLEEP_DURATION = 1
  PAUSED = 'pause'
  PLAYING = 'play'
  
  OPERATIONS = %w{
    handle_state_change
    handle_hammertime
    handle_playlist
  }
  
  def self.run
    loop do
      perform_next_operation or rest
    end
  end
  
  def self.perform_next_operation
    OPERATIONS.detect { |action| send action }
  end
  
  def self.handle_state_change
    return if @state == Jukebox.state
  
    @state = Jukebox.state
      
    if playing?
      play @hammertime or play @playlist_entry
    else
      pause @hammertime
      pause @playlist_entry
    end
  
    true
  end
  
  def self.handle_hammertime
    stop_hammertime or play_hammertime
  end
  
  def self.handle_playlist
    skip_playlist_entry or play_playlist_entry
  end
  
  def self.stop_hammertime
    return unless @hammertime && @hammertime.finished?
    Jukebox.pause if @hammertime.pause_after?
    @hammertime.stop
    @hammertime.release
    @hammertime = nil
    play @playlist_entry
  end
  
  def self.play_hammertime
    return unless playing?
    return true if @hammertime && @hammertime.playing?
    if next_hammertime
      pause @playlist_entry
      play @hammertime
    end
  end
  
  def self.skip_playlist_entry
    return unless @playlist_entry && @playlist_entry.playing? && Jukebox.skip?
    @playlist_entry.stop
    @playlist_entry.release
    @playlist_entry = nil
    true
  end
  
  def self.play_playlist_entry
    return unless playing?
    return true if @playlist_entry && @playlist_entry.playing?
    play next_playlist_entry
  end
  
  def self.rest
    sleep SLEEP_DURATION
  end
  
  def self.playing?
    @state == PLAYING
  end
  
  def self.play track
    return unless track
    track.play
  end
  
  def self.pause track
    return unless track
    track.pause
  end
  
  def self.next_playlist_entry
    file_location = Jukebox.next_playlist_entry
    return if file_location.nil? || file_location == ""
  
    @playlist_entry.release if @playlist_entry
    @playlist_entry = Track.new [file_location] rescue nil
  end
  
  def self.next_hammertime
    track_attributes = Jukebox.next_hammertime
    return if track_attributes.nil? || track_attributes.empty?

    @hammertime.release if @hammertime
    @hammertime = Track.new track_attributes rescue nil
  end
end
