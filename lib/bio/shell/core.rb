#
# = bio/shell/core.rb - internal methods for BioRuby shell
#
# Copyright::	Copyright (C) 2005
#		Toshiaki Katayama <k@bioruby.org>
# Lisence::	LGPL
#
# $Id: core.rb,v 1.4 2005/11/05 08:33:53 k Exp $
#
#--
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
#++
#

module Bio::Shell::Core

  CONFIG  = "config"
  OBJECT  = "object"
  HISTORY = "history"
  SCRIPT  = "script.rb"
  PLUGIN  = "plugin/"
  BIOFLAT = "bioflat/"

  SITEDIR = "/etc/bioinformatics/bioruby/"
  USERDIR = "#{ENV['HOME']}/.bioinformatics/bioruby/"
  SAVEDIR = ".bioruby/"

  MARSHAL = [ Marshal::MAJOR_VERSION, Marshal::MINOR_VERSION ]

  MESSAGE = "...BioRuby in the shell..."

  ESC_SEQ = {
    :k => "\e[30m",  :black   => "\e[30m",
    :r => "\e[31m",  :red     => "\e[31m",  :ruby  => "\e[31m",
    :g => "\e[32m",  :green   => "\e[32m",
    :y => "\e[33m",  :yellow  => "\e[33m",
    :b => "\e[34m",  :blue    => "\e[34m",
    :m => "\e[35m",  :magenta => "\e[35m",
    :c => "\e[36m",  :cyan    => "\e[36m",
    :w => "\e[37m",  :white   => "\e[37m",
    :n => "\e[00m",  :none    => "\e[00m",  :reset => "\e[00m",
  }

  ### save/restore the environment

  def setup
    load_config
    load_plugin
    version_check
  end

  # *TODO* is this needed? (for reset)
  def reload
    load_config
    load_plugin
    load_object
  end

  def open
    load_object
    load_history
    opening_splash
  end

  def close
    closing_splash
    save_history
    save_object
    save_config
  end

  # *TODO* This works, but sometimes causes terminal collapse
  def opening_thread
    begin
      t1 = Thread.new do
        load_object
        load_history
      end
      t2 = Thread.new do
        opening_splash
      end
      t1.join
      t2.join
    rescue
    end
  end

  ### setup

  def version_check
    if RUBY_VERSION < "1.8.2"
      raise "BioRuby shell runs on Ruby version >= 1.8.2"
    end
    if $bioruby_config[:MARSHAL] and $bioruby_config[:MARSHAL] != MARSHAL
      raise "Marshal version mismatch"
    end
  end

  def create_save_dir(dir = SAVEDIR)
    create_real_dir(dir)
    create_real_dir(dir + PLUGIN)
    create_real_dir(dir + BIOFLAT)
  end

  def create_real_dir(dir)
    unless File.directory?(dir)
      begin
        print "Creating directory (#{dir}) ... "
        Dir.mkdir(dir)
        puts "done"
      rescue
        raise "Failed to create #{dir} : #{$!}"
      end
    end
  end

  ### config

  def load_config
    load_config_file(SITEDIR + CONFIG)
    load_config_file(USERDIR + CONFIG)
    load_config_file(SAVEDIR + CONFIG)
  end

  def load_config_file(file)
    if File.exists?(file)
      print "Loading config (#{file}) ... "
      if hash = YAML.load(File.read(file))
        $bioruby_config.update(hash)
      end
      puts "done"
    end
  end

  def save_config
    create_save_dir
    file = SAVEDIR + CONFIG
    begin
      print "Saving config (#{file}) ... "
      File.open(file, "w") do |f|
        f.puts $bioruby_config.to_yaml
      end
      puts "done"
    rescue
      raise "Failed to save (#{file}) : #{$!}"
    end
  end

  def config(mode, *opts)
    case mode
    when :show, "show"
      config_show
    when :echo, "echo"
      config_echo
    when :color, "color"
      config_color
    when :pager, "pager"
      config_pager(*opts)
    when :message, "message"
      config_message(*opts)
    end
  end

  def config_show
    $bioruby_config.each do |k, v|
      puts "#{k}\t= #{v.inspect}"
    end
  end

  def config_echo
    bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
    flag = ! $bioruby_config[:ECHO]
    $bioruby_config[:ECHO] = IRB.conf[:ECHO] = flag
    eval("conf.echo = #{flag}", bind)
    puts "Echo #{flag ? 'on' : 'off'}"
  end

  def config_color
    bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
    flag = ! $bioruby_config[:COLOR]
    $bioruby_config[:COLOR] = flag
    if flag
      IRB.conf[:PROMPT_MODE] = :BIORUBY_COLOR
      eval("conf.prompt_mode = :BIORUBY_COLOR", bind)
    else
      IRB.conf[:PROMPT_MODE] = :BIORUBY
      eval("conf.prompt_mode = :BIORUBY", bind)
    end
  end

  def config_pager(cmd = nil)
    $bioruby_config[:PAGER] = cmd
  end

  def config_message(str = nil)
    str ||= Bio::Shell::Core::MESSAGE
    $bioruby_config[:MESSAGE] = str
  end

  ### plugin

  def load_plugin
    load_plugin_dir(SITEDIR + PLUGIN)
    load_plugin_dir(USERDIR + PLUGIN)
    load_plugin_dir(SAVEDIR + PLUGIN)
  end

  def load_plugin_dir(dir)
    if File.directory?(dir)
      Dir.glob("#{dir}/*.rb").sort.each do |file|
        print "Loading plugin (#{file}) ... "
        load file
        puts "done"
      end
    end
  end

  ### object

  def load_object
    load_object_file(SAVEDIR + OBJECT)
  end

  def load_object_file(file)
    if File.exists?(file)
      print "Loading object (#{file}) ... "
      begin
        bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
        hash = Marshal.load(File.read(file))
        hash.each do |k, v|
          begin
            # p [k, v, v.class, Marshal.load(v)]
            eval("#{k} = Marshal.load('#{v}')", bind)
          rescue
            puts "Warning: object '#{k}' couldn't be loaded : #{$!}"
          end
        end
      rescue
        raise "Failed to load (#{file}) : #{$!}"
      end
      puts "done"
    end
  end
  
  def save_object
    create_save_dir
    save_object_file(SAVEDIR + OBJECT)
  end

  def save_object_file(file)
    begin
      print "Saving object (#{file}) ... "
      File.open(file, "w") do |f|
        begin
          bind = IRB.conf[:MAIN_CONTEXT].workspace.binding
          list = eval("local_variables", bind)
          list -= ["_"]
          hash = {}
          list.each do |elem|
            value = eval(elem, bind)
            if value
              hash[elem] = Marshal.dump(value)
            end
          end
          Marshal.dump(hash, f)
          $bioruby_config[:MARSHAL] = MARSHAL
        rescue
          raise "Failed to dump (#{file}) : #{$!}"
        end
      end
      puts "done"
    rescue
      raise "Failed to save (#{file}) : #{$!}"
    end
  end

  ### history

  def load_history
    load_history_file(SAVEDIR + HISTORY) unless $bioruby_cache[:no_readline]
  end

  def load_history_file(file)
    if File.exists?(file)
      print "Loading history (#{file}) ... "
      File.open(file).each do |line|
        Readline::HISTORY.push line.chomp
      end
      puts "done"
    end
  end
  
  def save_history
    create_save_dir
    save_history_file(SAVEDIR + HISTORY) unless $bioruby_cache[:no_readline]
  end

  def save_history_file(file)
    begin
      print "Saving history (#{file}) ... "
      File.open(file, "w") do |f|
        f.puts Readline::HISTORY.to_a
      end
      puts "done"
    rescue
      raise "Failed to save (#{file}) : #{$!}"
    end
  end

  ### script

  def script(mode)
    case mode
    when :begin, "begin", :start, "start"
      script_begin
    when :end, "end", :stop, "stop"
      script_end
      script_save
    end
  end

  def script_begin
    puts "-- 8< -- 8< -- 8< --  Script  -- 8< -- 8< -- 8< --"
    @script_begin = Readline::HISTORY.size
  end

  def script_end
    puts "-- >8 -- >8 -- >8 --  Script  -- >8 -- >8 -- >8 --"
    @script_end = Readline::HISTORY.size - 2
  end

  def script_save
    create_save_dir
    if @script_begin and @script_end and @script_begin <= @script_end
      script_save_file(SAVEDIR + SCRIPT)
    else
      raise "Script range '#{@script_begin}' .. '#{@script_end}' is invalid"
    end
  end

  def script_save_file(file)
    begin
      print "Saving script (#{file}) ... "
        File.open(file, "w") do |f|
        f.print "#!/usr/bin/env ruby\n\n"
        f.print "require 'bio/shell'\n\n"
        f.print "include Bio::Shell\n\n"
        f.print "Bio::Shell.setup\n\n"
        f.puts Readline::HISTORY.to_a[@script_begin..@script_end]
      end
      puts "done"
    rescue
      @script_begin = nil
      raise "Failed to save (#{file}) : #{$!}"
    end
  end

  ### splash

  def splash_message
    $bioruby_config[:MESSAGE] ||= MESSAGE
    $bioruby_config[:MESSAGE].to_s.split(//).join(" ")
  end

  def splash_message_color
    str = splash_message
    ruby = ESC_SEQ[:ruby]
    none = ESC_SEQ[:none]
    return str.sub(/R u b y/) { "#{ruby}R u b y#{none}" }
  end

  def opening_splash
    s = splash_message
    l = s.length
    c = ESC_SEQ
    x = " "

    print "\n"
    if $bioruby_config[:COLOR]
      0.step(l,2) do |i|
        l1 = l-i;  l2 = l1/2;  l4 = l2/2
        print "#{c[:n]}#{s[0,i]}#{x*l1}#{c[:y]}#{s[i,1]}\r"
        sleep(0.001)
        print "#{c[:n]}#{s[0,i]}#{x*l2}#{c[:g]}#{s[i,1]}#{x*(l1-l2)}\r"
        sleep(0.002)
        print "#{c[:n]}#{s[0,i]}#{x*l4}#{c[:r]}#{s[i,1]}#{x*(l2-l4)}\r"
        sleep(0.004)
        print "#{c[:n]}#{s[0,i+1]}#{x*l4}\r"
        sleep(0.008)
      end
    end
    if $bioruby_config[:COLOR]
      print splash_message_color
    else
      print splash_message
    end
    print "\n\n"
    print "  Version : BioRuby #{Bio::BIORUBY_VERSION.join(".")}"
    print " / Ruby #{RUBY_VERSION}\n\n"
  end

  def closing_splash
    print "\n\n"
    if $bioruby_config[:COLOR]
      print splash_message_color
    else
      print splash_message
    end
    print "\n\n"
  end

end

