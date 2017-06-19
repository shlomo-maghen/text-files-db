require 'mysql2'
class TextFiles

  def get_word_counts(directory)
    words = {} # to hold results
    if directory[-1] != '/'
      directory = directory + '/'
    end
    files = Dir[directory+'*.txt'] # get list of text files from directory
    files.each do |directory|
      text = open(directory).read
      # process each word
      text.split(' ').each do |word|
        word.gsub! /[^A-Za-z0-9]/, ''
        if word.length == 0
          next
        end
        if words.has_key? word
          words[word] += 1
        else
          words[word] = 1
        end
      end
    end
    return words.sort.to_h
  end

  def write_to_db(words)
    # connect to database
    client = Mysql2::Client.new(host: 'localhost', username: 'root', password: '', database: 'textfiles')
    # clear the table (for test)
    client.query 'delete from words where 1=1'
    # add each result
    words.each do |word, count|
      #escape
      word = client.escape word
      # create insert statement
      insert = "insert into words(word, count) values('#{word}',#{count})"
      client.query insert
    end

    # confirm success
    if client.query('select * from words').count == words.count
      return 0
    else
      return 1
    end
  end

end

if __FILE__ == $0
  if ARGV.count != 1 # make sure we have one path
    puts 'Please provide a path'
    exit
  end
  tf = TextFiles.new

  words = tf.get_word_counts ARGV[0]
  result = tf.write_to_db words

  puts words
  puts result
end