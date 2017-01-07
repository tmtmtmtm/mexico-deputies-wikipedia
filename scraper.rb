#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//h2[contains(.,"Deputies of the LXII Legislature")]/following-sibling::table[.//th[contains(.,"State")]]//tr[td]').each do |tr|
    tr.css('td').each_slice(3) do |tds|
      # store a 'holder' number to know if they were a replacement
      # (in the absence of replacement dates)
      tds[1].css('a').each_with_index do |link, i|
        data = {
          name:          link.text.tidy,
          wikipedia__en: link.attr('title'),
          state:         tds[0].text.tidy,
          party:         tds[2].text.tidy,
          term:          '62',
          holder:        i + 1,
          source:        url,
        }
        ScraperWiki.save_sqlite(%i(name wikipedia__en state), data)
      end
    end
  end
end

scrape_list('https://en.wikipedia.org/wiki/LXII_Legislature_of_the_Mexican_Congress')
