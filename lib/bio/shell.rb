#
# = bio/shell.rb - Loading all BioRuby shell features
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License:      Ruby's
#
# $Id: shell.rb,v 1.14 2006/02/17 17:12:39 k Exp $
#

require 'bio'
require 'yaml'
require 'open-uri'
require 'pp'

module Bio::Shell

  require 'bio/shell/core'
  require 'bio/shell/interface'
  require 'bio/shell/plugin/entry'
  require 'bio/shell/plugin/seq'
  require 'bio/shell/plugin/midi'
  require 'bio/shell/plugin/codon'
  require 'bio/shell/plugin/flatfile'
  require 'bio/shell/plugin/obda'
  require 'bio/shell/plugin/keggapi'
  require 'bio/shell/plugin/emboss'

  extend Ghost
  extend Private

end


