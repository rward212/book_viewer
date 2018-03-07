require "tilt/erubis"
require "sinatra"
require "sinatra/reloader" if development?

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map do |paragraph|
      "<p> #{paragraph} </p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end

end


def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

# returns an array of hashes, one of which is another hash
def chapters_matching(query)
  results = []
  return results if !query || query.empty?
  each_chapter do |number, name, contents|
    if contents.include?(query)
      matches = {}
      contents.split(/(?<=[!.?\"])\s(?=[A-Z\"\n])/).each_with_index do |sentence, index|
        matches[index] = sentence if sentence.include?(query)
      end
      matches << {number: number, name: name, paragraphs: text}
    end
  end
  results
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end

get "/" do 
  @title = "Contents"
  @contents = File.readlines("data/toc.txt")
  erb :home
end

get "/chapters/:number" do
  @contents = File.readlines("data/toc.txt")

  number = params[:number].to_i
  chapter_name = @contents[number -1]
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")
  erb :chapter
end

not_found do
  redirect "/"
end