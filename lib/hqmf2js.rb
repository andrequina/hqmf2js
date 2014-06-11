# Top level include file that brings in all the necessary code
require 'bundler/setup'
require 'rubygems'
require 'erb'
require 'ostruct'
require 'singleton'
require 'json'
require 'tilt'
require 'coffee_script'
require 'sprockets'
require 'nokogiri'

require 'hqmf-parser'


require_relative 'generator/js'
require_relative 'generator/codes_to_json'
require_relative 'generator/converter'
require_relative 'generator/execution'

Tilt::CoffeeScriptTemplate.default_bare = true
