
# Talk class
class Talk

  attr_accessor :description, :length

  def initialize(data)
    @description = data[0]
    @length = data[1]
  end

end

# Track class
class Track

  attr_accessor :talks, :total_length

  def initialize(talks = [])
    @talks = talks
    @total_length = 0
  end

end


# This class validates talks arrays
class CValidator

  attr_accessor :talks

  # maximum length in minutes
  MAX_LENGTH = 240

  def initialize(talks)
    @talks = talks
    select_valid
  end

  # Check  length more than the limits
  def select_valid
    @talks.select! { |talk| talk.length.to_i <= MAX_LENGTH }
    @talks
  end
end


# for the format
class CParser

  attr_accessor :data
  attr_reader :talks

  def initialize(file_name)
    @file_name = file_name
    @talks = [] #includes all the Talk objects parsed from file
    read_file_data
  end

  # Reads data from file, line by line and creates a new Talk object for each
  # of them, then appends them all to an array @talks
  def read_file_data
    File.open(@file_name, 'r').each_line do |line|
      @talks << Talk.new(process_line(line))
    end
    @talks
  end

  # Uses regEx to slice each line to two parts, substitutes "lightning" with
  # the time length of 5 minutes, then returns an array with the talk
  # description and its length.
  def process_line(line)

    talk = line.match(/(\w+.*?)(\d+|lightning$)/)
    data = []
    if talk[2] == "lightning"
      data = [talk[1].strip, 5]
    else
      data = [talk[1].strip, talk[2].to_i]
    end

    return data
  end
end



# This class solves the conference talk management
class CManage

  attr_accessor :talks
  attr_reader :tracks

  def initialize(talks)
    @talks = talks
    @tracks = []
    transform_to_decreasing
    pack_talks
  end

  # Reverse sorts @talks list in order 
  def transform_to_decreasing
    @talks.sort_by!{ |x| x.length.to_i }.reverse!
  end

  # Returns max length depending on track placement
  def get_max_length(x)
    x % 2 == 0 ? y = 180 : y = 240
  end

  # Packs the talks into Track containers
  def pack_talks

    @tracks << Track.new() # create first [0] Track object
    x = 0 # first object @tracks[0]

    @talks.each do |talk|

      len = get_max_length(x)

      if @tracks[x].total_length + talk.length.to_i <= len

        # append talk to current Track
        @tracks[x].talks << talk

        # add current talk's length to Track's total length
        @tracks[x].total_length += talk.length.to_i

      else
        available_tracks = @tracks.dup.reject{|k| k == x}
        available_tracks.each_with_index do |track, index|

          # if it's morning session, set limit to 180min, otherwise to 240min
          len = get_max_length(index)

          if track.total_length + talk.length.to_i <= len

            # append talk to current Track
            track.talks << talk

            # add current talk's length to Track's total length
            track.total_length += talk.length.to_i
            break
          else
            # append a new Track to the conference
            @tracks << Track.new()

            # set the last element of the array as the current one
            x = @tracks.size - 1

            # append talk to current track
            @tracks[x].talks << talk

            # add current talk's length to Track's total length
            @tracks[x].total_length += talk.length.to_i
            break
          end

        end

      end

    end
    @tracks
  end
end




# Print output data to terminal
class CPrinter

  attr_accessor :talks, :tracks

  def initialize(talks, tracks)
    @talks = talks
    @tracks = tracks
  end

  # Prints the total length of all the talks in minutes
  def calc_total_length
    sum = 0
    @talks.each { |talk| sum += talk.length.to_i }
    puts "-- Total length: #{sum} min"
  end

  # Prints all the talk descriptions and lengths
  def puts_talks
    @talks.each { |talk| puts "* #{talk.length} :: #{talk.description}" }
  end

  # Takes time as an integer e.g. 1230 and returns it in the appropriate
  # format: "12:30"
  def format_time(ttime)

    # slice integer into an array of characters
    ttime = ttime.to_s.chars

    minutes = ttime[-1].to_i
    tminutes = ttime[-2].to_i
    hrs = ttime[-3].to_i

    # add "0" in case time is less than 10:00 so they all have the same length
    ttime[-4].nil? ? thrs = 0 : thrs = ttime[-4].to_i

    # convert 60 minutes to 1 hour
    if tminutes >=6
      tminutes -= 6
      if hrs == 9
         hrs = 0
         thrs += 1
      else
         hrs += 1
      end
    end

    # return the formatted time
    ttime = "#{thrs}#{hrs}:#{tminutes}#{minutes}"
  end

  # Prints the final schedule
  def print_schedule
    @tracks.each_with_index do |track, index|
      puts
      puts "Track #{index + 1} :: #{track.total_length}min"

      # if it's a morning session, the starting time is 09:00 (AM) and
      # if it's an afternoon one, it's 01:00 (PM)
      index % 2 == 0 ? ttime = 900 : ttime = 100

      track.talks.each do |talk|
        # get formatted time in "xx:xx" format
        time_formatted = format_time(ttime)
        # add AM/PM suffix
        index % 2 == 0 ? ampm = "AM" : ampm = "PM"

        puts "#{time_formatted}#{ampm} #{talk.description} #{talk.length.to_s + 'min'}"
        # split new time
        new_time = time_formatted.chars
        # delete ":" from array's elements
        new_time.delete(":")
        # join elements, convert to integer and add current talk's length
        # converted to integer
        ttime = new_time.join.to_i + talk.length.to_i
      end

      # add lunch break and networking event
      if index % 2 == 0
        puts "12:00PM Lunch"
      else
        puts "05:00PM Networking Event"
      end
    end
  end

end



ctp = CParser.new('./lib/talks.txt')
validated_talks = CValidator.new(ctp.talks)
ctm = CManage.new(validated_talks.talks)
ctp = CPrinter.new(ctm.talks, ctm.tracks)
ctp.calc_total_length
ctp.print_schedule