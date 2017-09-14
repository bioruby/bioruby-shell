#
#  bio/shell/plugin/obda.rb - plugin for OBDA
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
#  $Id: obda.rb,v 1.1 2005/09/23 13:57:08 k Exp $
#

require 'bio/io/registry'

module Bio::Shell

  def bioregistry
    @obda = Bio::Registry.new
  end

  def getentry(dbname, entry_id)
    bioregistry unless @obda
    db = @obda.get_database(dbname)
    entry = db.get_by_id(entry_id)
    if block_given?
      yield entry
    else
      display entry
    end
    return entry
  end

end


