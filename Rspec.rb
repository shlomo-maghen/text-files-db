require 'rspec'
require './TextFiles.rb'
require 'mysql2'

tf = TextFiles.new
directory = '/home/shlomo/textfiles'
RSpec.describe TextFiles do
	it 'should get 8 word counts from a directory' do
		words = tf.get_word_counts directory
		expect(words.length).to eq 13
	end

	it 'should successfully insert into database' do
		words = tf.get_word_counts directory
		result = tf.write_to_db words
		expect(result).to eq 0
	end

	it 'should not add the punctuation in words' do
		words = tf.get_word_counts directory
		expect(words["dad's"]).to eq nil 
	end

	it 'should raise an error when db is offline' do
		# the reason it wasnt working is because we were looking for 'query'
		# to be called on the client class which never happens: Mysql2::Client.query
		@result = ''
		mysql = double('mysql') #create the double
		allow(Mysql2::Client).to receive(:new){mysql} #return the double when new is called
		allow(mysql).to receive(:query).and_raise Mysql2::Error, '' # raise error when query is called
		expect{@result = tf.write_to_db({})}.to raise_error(Mysql2::Error) # expect the error to be raised

		# this way just checks if any object which is of mysql type calls query 
		# allow_any_instance_of(Mysql2::Client).to receive(:query).and_raise Mysql2::Error, ''
		# expect{tf.write_to_db({})}.to raise_error(Mysql2::Error)
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