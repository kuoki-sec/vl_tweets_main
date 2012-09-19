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

# Proxy�ݒ�i�s�v�Ȃ�Aproxy_host��nil�ɐݒ�
proxy_host = nil;
proxy_port = 8080;

# �F�ؐݒ�
config = YAML.load_file("/var/local/common_service/conf/kuoki_sec_twitter.yaml")
consumer_key = config["oauth.consumerKey"];
consumer_secret = config["oauth.consumerSecret"];
oauth_token = config["oauth.accessToken"];
oauth_token_secret = config["oauth.accessTokenSecret"];

Net::HTTP.version_1_2;

#�Ԃ₩�Ȃ��Ώ�
untweetlist = [ "�y�j�R��/���N�G�X�g�z","�y�j�R���z"]

# ���ݎ��ԁA�����炢�܂ł̗\���ꂫ�ΏۂƂ��邩�̎���
now = DateTime.now()
totime = now + Rational(1, 24) * 4
fromtime = totime - Rational(1, 24 * 60 ) * 10

puts '----- start -----'
puts now
puts fromtime
puts totime

# �J�����_�[�̗\��̎擾����
# ������A�J�n�������A���ݎ�������̗\��A�����A�J��Ԃ��\���1���擾
query_hash = { 'orderby' => 'starttime', 'start-min' => now.new_offset.strftime('%FT%T'), 'sortorder' => 'a', 'singleevents' => 'true'};
query_string = query_hash.map{ |key,value|
        "#{URI.encode(key)}=#{URI.encode(value)}" }.join("&");

res = nil;

begin

        # Google Feed�𗘗p���ė\����擾
        https = Net::HTTP::Proxy( proxy_host, proxy_port).new('www.google.com', 443);
        https.use_ssl = true;
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE;
        https.verify_depth = 5;
        https.start {
                res = https.get('/calendar/feeds/0mprpb041vjq02lk80vtu6ajgo@group.calendar.google.com/public/full?' + query_string).body;
        }

rescue Exception
  puts $!;
end

# XML���p�[�X
document = REXML::Document.new(res);
if document.elements.to_a('feed/entry').size == 0 then
        # �Ԃ₫���Ȃ���ΏI��
        puts "�ΏۂȂ�";
        exit(true);
end

# Twitter ���O�C��
Twitter.configure do |config|
  config.consumer_key = consumer_key;
  config.consumer_secret = consumer_secret;
  config.oauth_token = oauth_token
  config.oauth_token_secret = oauth_token_secret
  if proxy_host != nil then
          config.proxy = 'http://' + proxy_host + ':' + proxy_port.to_s
  end
end

# �\��̐������J��Ԃ�
document.elements.each('feed/entry') do |entry|

        title = entry.elements['title'].text;

        time = entry.elements['gd:when'];

        url = '';
        entry.elements.each('link') do |link|
                if link.attributes['rel'] == 'alternate' then
                        url = link.attributes['href'];
                end

        end

        starttimeStr = time.attributes['startTime'];
        endtimeStr = time.attributes['endTime'];
        timeEvent = starttimeStr.count('T') > 0;
        if !timeEvent then
                starttimeStr = starttimeStr + 'T00:00:00+09:00';
        end
        starttime = DateTime.rfc3339(starttimeStr);

        puts title;
        puts starttime;
        puts url;

        #�Ώێ��ԑтƂԂ₩�Ȃ����X�g�ɍڂ��Ă��Ȃ����̂��c�C�[�g
        if fromtime < starttime and starttime <= totime and
           untweetlist.any?{|s|title.include?(s)} == false then

                tweetsStr = nil;
                puts '--�Ԃ₫�Ώ�--';

                ###�ړ��C��###
                tweetsStr = '�� INFO �� '
                if now.day.to_s == starttime.strftime('%d').to_s then
                        tweetsStr = tweetsStr + '�{�� '
                else
                        tweetsStr = tweetsStr + '���� '
                end

                ###���t�E����###
                if timeEvent then
                        tweetsStr = tweetsStr + starttime.strftime('%m��%d�� %H��%M������ ');
                else
                        tweetsStr = tweetsStr + starttime.strftime('%m��%d�� ');
                end

                ###�^�C�g��###
                #50�Ő؂����̂̓����V�����̃c�C�[�g�����҂��Ă���ׂł�
                if title.split(//).size > 50 then
                        tweetsStr = tweetsStr + title[0,50] + '...'
                else
                        tweetsStr = tweetsStr + title
                end

                ###URL�A�n�b�V���^�O###
                tweetsStr = tweetsStr + ' ' + url + ' #vocalendar'

                puts tweetsStr

                Twitter.update(tweetsStr);

        end
end