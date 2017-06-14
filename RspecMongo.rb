require 'rspec'
require './TextFilesMongo.rb'
require 'mongo'
include Mongo

tf = TextFilesMongo.new
directory = '/home/shlomo/textfiles'

RSpec.describe TextFilesMongo do
	it 'should get all words from a directory' do
		# mongo = double('mongo')
		# allow(TextFilesMongo).to receive(:insert_into_mongo){mongo}
		
		words = tf.get_word_counts directory
		expect(words.length).to eq words.length
	end

	it 'should save the words to mongo' do
		words = tf.get_word_counts directory
		expect(words.length).to eq words.length
		
		mongo = MongoClient.new
		db = mongo['test']
		collection = db['textfiles']
		
		expect(collection.find().count).to eq 13
	end

	it 'should raise an error when the database is offline' do
		mongo = double('mongo')
		allow(MongoClient).to receive(:new){mongo}.and_raise Mongo::ConnectionFailure.new
		expect{tf.get_word_counts('/')}.to raise_error Mongo::ConnectionFailure
	end

	it 'should return an empty hash if no txt files were found' do
		words = tf.get_word_counts('/home/shlomo/no_text_files_here')
		expect(words.count).to eq 0
	end

	it 'should return an empty hash if there were no words found' do
		words = tf.get_word_counts('/home/shlomo/no_words_here')
		expect(words.count).to eq 0
	end

end