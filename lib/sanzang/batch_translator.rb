#!/usr/bin/env ruby
# -*- encoding: UTF-8 -*-
#--
# Copyright (C) 2012 Lapis Lazuli Texts
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

require "parallel"

require_relative "platform"
require_relative "translator"

module Sanzang

  # BatchTranslator can handle batches of files for translation, and may also
  # be able to translate them in parallel using multiprocessing, if your Ruby
  # virtual machine supports it. This class inherits from Translator.
  #
  class BatchTranslator < Translator

    # Translate a batch of files. The main parameter is an array, each element
    # of which should be a two-dimensional array with the first element being
    # the input file path, and the second element being the output file path.
    # If the _verbose_ parameter is true, then print progress to STDERR. The
    # return value is an array containing all the output file paths.
    #
    def translate_batch(fpath_pairs, verbose = true, jobs = nil)
      if not Sanzang::Platform.unix_processes?
        jobs = 0
      elsif not jobs
        jobs = Sanzang::Platform.processor_count
      end
      Parallel.map(fpath_pairs, :in_processes => jobs) do |f1,f2|
        translate_io(f1, f2)
        if verbose
          $stderr.write "[#{Process.pid}] #{File.expand_path(f2)} \n"
          $stderr.flush
        end
        f2
      end
    end

    # Translate a list of files to some output directory. The names of the
    # files written to the output directory will be the same as those of their
    # respective input files. If the _verbose_ parameter is true, then print
    # progress to STDERR.
    #
    def translate_to_dir(in_fpaths, out_dir, verbose = true, jobs = nil)
      pairs = []
      in_fpaths.each do |f1|
        pairs << [f1, File.join(out_dir, File.basename(f1))]
      end
      translate_batch(pairs, verbose, jobs)
    end

  end
end
