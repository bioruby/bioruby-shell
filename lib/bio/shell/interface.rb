#
# = bio/shell/interface.rb - core user interface of the BioRuby shell
#
# Copyright::   Copyright (C) 2005
#               Toshiaki Katayama <k@bioruby.org>
# License::     Ruby's
#
# $Id: interface.rb,v 1.13 2006/02/17 17:11:59 k Exp $
#

module Bio::Shell

  private

  ### work space

  def ls
    list = eval("local_variables", conf.workspace.binding).reject { |x|
      eval(x, conf.workspace.binding).nil?
    }
    puts list.inspect
  end

  def rm(name)
    list = eval("local_variables", conf.workspace.binding).reject { |x|
      eval(x, conf.workspace.binding).nil?
    }
    begin
      if list.include?(name.to_s)
        eval("#{name} = nil", conf.workspace.binding)
      else
        raise
      end
    rescue
      warn "Usage: rm :var or rm 'var' (rm var is not valid)"
    end
  end

  ### script

  def script(mode = nil)
    Bio::Shell.script(mode)
  end

  ### object

  def reload_object
    Bio::Shell.load_object
  end

  ### plugin

  def reload_plugin
    Bio::Shell.load_plugin
  end

  ### config

  def config(mode = :show, *opts)
    case mode
    when :show, "show"
      Bio::Shell.config_show
    when :echo, "echo"
      Bio::Shell.config_echo
    when :color, "color"
      Bio::Shell.config_color
    when :splash, "splash"
      Bio::Shell.config_splash
    when :pager, "pager"
      Bio::Shell.config_pager(*opts)
    when :message, "message"
      Bio::Shell.config_message(*opts)
    end
  end

  def reload_config
    Bio::Shell.load_config
  end

  ### pager

  def pager(cmd = nil)
    unless Bio::Shell.config[:pager]
      cmd = ENV['PAGER'] || cmd
    end
    Bio::Shell.config_pager(cmd)
    puts "Pager is set to '#{cmd ? cmd : 'off'}'"
  end

  def disp(*obj)
    # The original idea is from http://sheepman.parfait.ne.jp/20050215.html
    if Bio::Shell.config[:pager]
      pg = IO.popen(Bio::Shell.config[:pager], "w")
      begin
        stdout_save = STDOUT.clone
        STDOUT.reopen(pg)
        puts(*obj)
      ensure
        STDOUT.reopen(stdout_save)
        stdout_save.close
        pg.close
      end
    else
      # or use Object#display ?
      puts(*obj)
    end
  end

  def less(file)
    pager = Bio::Shell.config[:pager] || ENV['PAGER'] || "less"
    system("#{pager} #{file}")
  end

  def head(arg, num = 10)
    str = ""
    if File.exists?(arg)
      File.open(arg) do |file|
        num.times do
          if line = file.gets
            str << line
          end
        end
      end
    else
      arg.to_s.each_with_index do |line, i|
        break if i >= num
        str << line
      end
    end
    puts str
    return str
  end

  ### file save

  def savefile(file, *objs)
    datadir = Bio::Shell.datadir
    message = "Save file '#{file}' in '#{datadir}' directory? [y/n]: "
    if ! file[/^#{datadir}/] and Bio::Shell.ask_yes_or_no(message)
      file = datadir + file
    end
    if File.exists?(file)
      message = "Overwrite existing '#{file}' file? [y/n]: "
      if ! Bio::Shell.ask_yes_or_no(message)
        puts " ... save aborted."
        return
      end
    end
    begin
      print "Saving file (#{file}) ... "
      File.open(file, "w") do |f|
        objs.each do |obj|
          f.puts obj.to_s
        end
      end
      puts "done"
    rescue
      warn "Error: Failed to save (#{file}) : #{$!}"
    end
  end

  ### file system

  def cd(dir = ENV['HOME'])
    if dir
      Dir.chdir(dir)
    end
    puts Dir.pwd.inspect
  end

  def pwd
    puts Dir.pwd.inspect
  end

  def dir(file = nil)
    if file
      if File.directory?(file)
        files = Dir.glob("#{file}/*")
      else
        files = Dir.glob(file)
      end
    else
      files = Dir.glob("*")
    end
    if files
      str  = "   UGO  Date                                 Byte  File\n"
      str << "------  ----------------------------  -----------  ------------\n"
      files.sort.each { |f|
        stat = File.lstat(f)
        mode = format("%6o", stat.mode)
        date = stat.mtime
        byte = stat.size
        name = f.inspect
        str << format("%s  %s%13d  %s\n", mode, date, byte, name)
      }
      puts str
      return str
    end
  end

end


