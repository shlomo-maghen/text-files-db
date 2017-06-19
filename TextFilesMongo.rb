require 'mysql2'
require 'mongo'
include Mongo
class TextFilesMongo

  def get_word_counts(directory)
    collection = get_collection # get a collection to write to
    words = {}
    if directory[-1] != '/'
      directory = directory + '/'
    end
    files = Dir[directory+'*.txt'] # get list of text files from directory
    files.each do |file|
      text = open(file).read
      text.split(' ').each_with_index do |word, token_index|
        word.gsub! /[^A-Za-z0-9]/, ''
        if word.length == 0
          next
        end
        if words.has_key? word
          words[word] += 1
        else
          words[word] = 1
        end
        insert_into_mongo(file, token_index, word, words[word], collection)
      end
    end
    return words
  end
  
  def insert_into_mongo(file, token_index, word, count, collection)
    # the new location for this word
    new_location = {
        file_name: file,
        token_index: token_index,
      }
    # update the document if it exists
    db_word = collection.find_one({word:word})
    if db_word
      collection.update(
        {word: word},
        {
          '$push' => {'locations' => new_location},
          '$inc' => {'count':1}  
        }
      )

      # collection.update({word: word}, )
    else
      # write to db if not
      document = {
        word: word,
        locations: [new_location],
        count: 1
      }
      collection.insert(document)
    end
  end


  def get_collection
    collection = MongoClient.new['test']['textfiles']
    collection.drop
    collection
  end
end


if __FILE__ == $0
  if ARGV.count != 1 # make sure we have one path
    puts 'Please provide a path'
    exit
  end
  tf = TextFilesMongo.new

  words = tf.get_word_counts ARGV[0]
  puts words
end