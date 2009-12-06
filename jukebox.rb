require 'net/http'

class Jukebox
  PAUSED = 'pause'
  PLAYING = 'play'
  
  def self.state
    Net::HTTP.get URI.parse('http://localhost:3000/playlist/status')
  end
  
  def self.skip?
    Net::HTTP.get(URI.parse('http://localhost:3000/playlist/skip_requested')) == true.to_s
  end

  def self.pause
    Net::HTTP.post_form(URI.parse('http://localhost:3000/playlist/pause'), {})
  end

  def self.next_playlist_entry
    Net::HTTP.get URI.parse('http://localhost:3000/playlist/next_entry')
  end

  def self.next_hammertime
    response = Net::HTTP.get URI.parse('http://localhost:3000/playlist/next_hammertime')
    response.split('|')
  end
end
