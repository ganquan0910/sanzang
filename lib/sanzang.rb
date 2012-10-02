#!/usr/bin/env ruby -w
# -*- encoding: UTF-8 -*-

# == Description
#
# The Sanzang module contains a basic infrastructure for machine translation
# using a simple direct translation method that does not attempt to change the
# underlying grammar of the source text. The Sanzang module also contains
# functionality for preparing source texts by reformatting them in a manner
# that will facilitates both machine translation as well as the readability of
# the final translation listing that is generated. All program source code for
# the Sanzang system is contained within the Sanzang module, with code for the
# Sanzang commands being located in the Sanzang::Command module.
#
# == Copyright
#
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
#
module Sanzang; end

require_relative File.join("sanzang", "text_formatter")
require_relative File.join("sanzang", "translation_table")
require_relative File.join("sanzang", "translator")
require_relative File.join("sanzang", "version")

# == Description
#
# The Sanzang::Command module contains Unix style commands utilizing the
# Sanzang module. Each class is typically a different command, with usage
# information given when running the command with the "-h" or "--help" options.
#
# == Copyright
#
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
#
module Sanzang::Command; end

require_relative File.join("sanzang", "command", "reflow")
require_relative File.join("sanzang", "command", "translate")
