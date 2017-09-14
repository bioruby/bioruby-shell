#
#  bio/shell/plugin/flatfile.rb - plugin for flatfile database
#
#   Copyright (C) 2005 KATAYAMA Toshiaki <k@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: flatfile.rb,v 1.2 2005/09/25 05:25:14 k Exp $
#

require 'bio/io/flatfile'

module Bio::Shell

  def convert_to_fasta(fastafile, *flatfiles)
    puts "Saving fasta file (#{fastafile}) ... "
    File.open(fastafile, "w") do |fasta|
      flatfiles.each do |flatfile|
        puts "  converting -- #{flatfile}"
        Bio::FlatFile.auto(flatfile) do |flat|
          flat.each do |entry|
            header = "#{entry.entry_id} #{entry.definition}"
            fasta.puts entry.seq.to_fasta(header, 50)
          end
        end
      end
    end
    puts "done"
  end

  def bioflat_index(dbname, *flatfiles)
    prefix = Core::SAVEDIR + Core::BIOFLAT
    unless File.directory?(prefix)
      Bio::Shell.create_save_dir
    end
    dir = prefix + dbname.to_s
    bdb = format = options = nil
    begin
      print "Creating BioFlat index (#{dir}) ... "
      Bio::FlatFileIndex.makeindex(bdb, dir, format, options, *flatfiles)
      puts "done"
    rescue
      raise "Failed to create index (#{dir}) : #{$!}"
    end
  end

  def bioflat_search(dbname, keyword)
    dir = Core::SAVEDIR + Core::BIOFLAT + dbname.to_s
    Bio::FlatFileIndex.open(dir) do |db|
      if results = db.include?(keyword)
        results.each do |entry_id|
          display db.search_primary(entry_id)
        end
      else
        display "No hits found"
      end
    end
  end

  def bioflat_namespaces(dbname)
    dir = Core::SAVEDIR + Core::BIOFLAT + dbname.to_s
    db = Bio::FlatFileIndex.open(dir)
    display db.namespaces.inspect
    db.close
  end

end
