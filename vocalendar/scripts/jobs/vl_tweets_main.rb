#! /usr/local/bin/ruby
# -*- encoding: utf-8 -*-
#
# Vocalendar bot | Twitter Developers
# https://dev.twitter.com/apps/1995843/show

require 'yaml'
require 'rubygems';
require 'net/https';
require 'uri';
require 'rexml/document';
require 'date'
require 'active_support'
require 'twitter'
require 'pp'

# Proxy設定（不要なら、proxy_hostをnilに設定
proxy_host = nil;
proxy_port = 8080;

# 認証設定
config = YAML.load_file("/var/local/common_service/conf/vocalendar_twitter.yaml")
consumer_key = config["oauth.consumerKey"];
consumer_secret = config["oauth.consumerSecret"];
oauth_token = config["oauth.accessToken"];
oauth_token_secret = config["oauth.accessTokenSecret"];

# ツイート内容毎設定
# 設定ファイルパスは第一引数に設定
config2 = YAML.load_file(ARGV[0])
gmail_id = config2["gmail_id"]

Net::HTTP.version_1_2;

Net::HTTP.version_1_2;

#つぶやかない対象
#呟きたくないワードはここに入れてね
untweetlist = [ "【XXXXXXXXXXX】","【ZZZZZZZZZZ】" ]

# 現在時間、いつからいつまでの予定を呟き対象とするかの時間
now = DateTime.now()
totime = now + Rational(1, 24) * 4
fromtime = totime - Rational(1, 24 * 60 ) * 10

puts '----- start -----'
puts now
puts fromtime
puts totime

# カレンダーの予定の取得条件
# 左から、開始時刻順、現在時刻からの予定、昇順、繰り返し予定を1つずつ取得
query_hash = { 'orderby' => 'starttime', 'start-min' => now.new_offset.strftime('%FT%T'), 'sortorder' => 'a', 'singleevents' => 'true'};
query_string = query_hash.map{ |key,value|
        "#{URI.encode(key)}=#{URI.encode(value)}" }.join("&");

res = nil;

begin

        # Google Feedを利用して予定を取得
        https = Net::HTTP::Proxy( proxy_host, proxy_port).new('www.google.com', 443);
        https.use_ssl = true;
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE;
        https.verify_depth = 5;
#! /usr/local/bin/ruby
# -*- encoding: utf-8 -*-
#
# Vocalendar bot | Twitter Developers
# https://dev.twitter.com/apps/1995843/show

require 'yaml'
require 'rubygems';
require 'net/https';
require 'uri';
require 'rexml/document';
require 'date'
require 'active_support'
require 'twitter'
require 'pp'

# Proxy設定（不要なら、proxy_hostをnilに設定
proxy_host = nil;
proxy_port = 8080;

# 認証設定
config = YAML.load_file("/var/local/common_service/conf/vocalendar_twitter.yaml")
consumer_key = config["oauth.consumerKey"];
consumer_secret = config["oauth.consumerSecret"];
oauth_token = config["oauth.accessToken"];
oauth_token_secret = config["oauth.accessTokenSecret"];

# ツイート内容毎設定
# 設定ファイルパスは第一引数に設定
config2 = YAML.load_file(ARGV[0])
gmail_id = config2["gmail_id"]

Net::HTTP.version_1_2;

                ###日付###
                tweetsStr = tweetsStr + starttime.strftime('%-m月%-d日 ');

                ###時・分###
                if timeEvent then
                        tweetsStr = tweetsStr + starttime.strftime('%-H時');

                        if starttime.min != 0 then
                              tweetsStr = tweetsStr + starttime.strftime('%-M分')
                        end

                        tweetsStr = tweetsStr + 'から '
                end

                ###タイトル###
                #50で切ったのはメンションのツイートを期待している為です
                if title.split(//).size > 50 then
                        tweetsStr = tweetsStr + title[0,50] + '...'
                else
                        tweetsStr = tweetsStr + title
                end

                ###URL、ハッシュタグ###
                tweetsStr = tweetsStr + ' ' + url + ' #vocalendar'

                puts tweetsStr

                Twitter.update(tweetsStr);

        end
end