#!/usr/bin/env lua

local output = require "thwap.output"
local config = require "thwap.config"
local utils  = require "thwap.utils"
local buildr = require "thwap.builder"

local bldr = buildr:new(config)
bldr:open('lang/python')
bldr:build('2.7.16')
bldr:build('3.7.3')
bldr:open('lang/ruby')
bldr:build('2.5.5')
bldr:open('lang/slang')
bldr:build('2.3.2')
bldr:open('editors/emacs')
bldr:build('26.1')
bldr:open('editors/vim')
bldr:build('8.1')
