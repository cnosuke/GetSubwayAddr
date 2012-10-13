# encoding: utf-8

# Subwayは全国のサブウェイの住所を得るためのクラスである。
# 実行時の引数にサブウェイの店舗一覧ページのURLを入れる。
# ダミーの住所入力等に使う。
# HOW TO USE 
#  =実行時=
#  ruby ./subway.rb http://www.subway.co.jp/shops/tokyo/city0_0/
#
#  =その時の中身=
#  subway = Subway.new(ARGV[0])
#  subway.search
#
#  subway.addr_reader.each do |addr| 
#    puts addr
#  end
#  

require 'nokogiri'
require 'open-uri'
require 'optparse'
Opt = OptionParser.new
Version = "1.0"

class Subway

    attr_reader :addr_list
    def initialize(uri= "http://www.subway.co.jp/shops/tokyo/city0_0/")
         @sub_url =  "http://www.subway.co.jp"
         @doc =  Nokogiri::HTML(open(uri).read, nil, 'CP932')
         @next_url = ""
         @addr_list = []
     end

    #サブウェイの住所一覧ページから、住所を探しだして出力する
    public
    def search
        while @doc
            # そのページから住処を取得           
            get_addr("275")
            get_addr("380")            

            # 次の20件を取得
            get_next

            # 次のページのHTMLを取得
            if @next_url
                @doc = Nokogiri::HTML(open(@next_url).read, nil, 'CP932')
            else
                #puts "pege is end"
                @doc = nil
            end      

        end #while end
    end #search end

    #与えられたノコギリオブジェクトから住所をパースして出力する
    #引数には、パースのために必要なtdのwidthサイズを指定する
    private
    def get_addr (width_size)
        @doc.xpath('//td[@width="'+width_size+'"]//font[@class="f12"]').each do |font|
            unless font.text =~ /^\d/ 
                if font.text != "住所"
                    @addr_list << font.text
                end
            end
        end
    end #end get_addr
    
    #ページネーションがある場合、次のページへのURLを探して代入する
    private
    def get_next
        @next_url = nil
        @doc.xpath('//a[@href]').each do |a|
            if a.text == "次の20件へ >>"
                @next_url = @sub_url + a.attr('href')            
            end
        end  
    end #end get_next

    #デバッグ用、取ってきた住所を出力する
    public
    def print_addr
        @addr_list.each do |addr|
            puts addr
        end
    end #end print_addr

end

# 動作サンプル
# 実行時引数にサブウェイの店舗一覧のURLを与えると、住所を探してきて出力する

subway = nil

Opt.on("-s","--sample") do
  subway = Subway.new()
  subway.search
  puts "size: "+subway.addr_list.size.to_s
end

Opt.on("-l","--list") do
  unless subway
    subway = Subway.new()
    subway.search
  end
  puts subway.addr_list
end

Opt.parse(ARGV)
