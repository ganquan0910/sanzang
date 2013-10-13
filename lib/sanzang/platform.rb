# coding: UTF-8
#--
# Copyright (C) 2012-2013 Lapis Lazuli Texts
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <http://www.gnu.org/licenses/>.

require 'rbconfig'

# The Sanzang::Platform module includes information about the underlying system
# that is needed by the \Sanzang system. This includes information about the
# machine architecture and OS, the number of processors available, encodings
# that are supported, and encodings that are optimal.
#
module Sanzang::Platform
  class << self

    # CPU architecture of the underlying machine
    #
    def machine_arch
      RbConfig::CONFIG["target_cpu"]
    end

    # Operating system, which may be different from RUBY_PLATFORM
    #
    def os_name
      RbConfig::CONFIG["target_os"]
    end

    # Does this Ruby VM support Unix-style process handling?
    #
    def unix_processes?
      [:fork, :wait, :kill].each do |f|
        if not Process.respond_to?(f)
          return false
        end
      end
      true
    end

    # Find the number of logical processors seen by the system. This may be
    # different from the number of physical processors or CPU cores. If the
    # number of processors cannot be detected, nil is returned. For Windows,
    # this is detected through an OLE lookup, and for Unix systems, a heuristic
    # approach is taken. Supported Unix types include:
    #
    # * AIX: pmcycles (AIX 5+), lsdev
    # * BSD: /sbin/sysctl
    # * Cygwin: /proc/cpuinfo
    # * Darwin: hwprefs, /usr/sbin/sysctl
    # * HP-UX: ioscan
    # * IRIX: sysconf
    # * Linux: /proc/cpuinfo
    # * Minix 3+: /proc/cpuinfo
    # * Solaris: psrinfo
    # * Tru64 UNIX: psrinfo
    # * UnixWare: psrinfo
    #
    def processor_count
      if os_name =~ /mingw|mswin/
        require 'win32ole'
        result = WIN32OLE.connect("winmgmts://").ExecQuery(
          "select NumberOfLogicalProcessors from Win32_Processor")
        result.to_enum.first.NumberOfLogicalProcessors
      elsif File.readable?("/proc/cpuinfo")
        IO.read("/proc/cpuinfo").scan(/^processor/).size
      elsif File.executable?("/usr/bin/hwprefs")
        IO.popen(%w[/usr/bin/hwprefs thread_count]).read.to_i
      elsif File.executable?("/usr/sbin/psrinfo")
        IO.popen("/usr/sbin/psrinfo").read.scan(/^.*on-*line/).size
      elsif File.executable?("/usr/sbin/ioscan")
        IO.popen(%w[/usr/sbin/ioscan -kC processor]) do |out|
          out.read.scan(/^.*processor/).size
        end
      elsif File.executable?("/usr/sbin/pmcycles")
        IO.popen(%w[/usr/sbin/pmcycles -m]).read.count("\n")
      elsif File.executable?("/usr/sbin/lsdev")
        IO.popen(%w[/usr/sbin/lsdev -Cc processor -S 1]).read.count("\n")
      elsif File.executable?("/usr/sbin/sysconf") and os_name =~ /IRIX/i
        IO.popen(%w[/usr/sbin/sysconf NPROC_ONLN]).read.to_i
      elsif File.executable?("/usr/sbin/sysctl")
        IO.popen(%w[/usr/sbin/sysctl -n hw.ncpu]).read.to_i
      elsif File.executable?("/sbin/sysctl")
        IO.popen(%w[/sbin/sysctl -n hw.ncpu]).read.to_i
      else
        nil
      end
    end

    # Text encodings that can be converted to UTF-8. MRI still lacks some
    # converter implementations for obscure encodings.
    #
    def valid_encodings
      Encoding.list.find_all do |e|
        begin
          Encoding::Converter.search_convpath(e, Encoding::UTF_8)
        rescue Encoding::ConverterNotFoundError
          e == Encoding::UTF_8 ? true : false
        end
      end.sort_by! {|e| e.to_s.upcase }
    end

    # Default text data encoding on this platform. This is usually the default
    # external encoding of the Ruby interpreter; however, if the encoding is
    # an ASCII variant or an old IBM DOS encoding, then it should default to
    # UTF-8 since these are effectively obsolete, or they are subsets of UTF-8.
    #
    def data_encoding
      if Encoding.default_external.to_s =~ /ASCII|IBM/
        Encoding::UTF_8
      else
        Encoding.default_external
      end
    end

  end
end
