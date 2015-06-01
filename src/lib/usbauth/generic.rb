# Copyright (c) 2015 SUSE LLC. All Rights Reserved.
# Author: Stefan Koch <skoch@suse.de>
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General
# Public License as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact SUSE LLC.
# 
# To contact SUSE about this file by physical or electronic mail,
# you may find current contact information at www.suse.com


# Description : YaST tool to edit config file from usbauth

$type = ["COMMENT", "DENY", "ALLOW", "COND"]

# ruby data structure
class RData
  attr_accessor :anyChild,
      :param,
      :op,
      :val
  
  def initialize()
    @anyChild = false
    @param = 0
    @op = 0
    @val = "0"
  end
end

# ruby rule structure
class RAuth
  attr_accessor :type,
      :devcount,
      :intfcount,
      :attr_array,
      :cond_array,
      :comment
  
  def initialize()
    @type = 0
    @devcount = 0
    @intfcount = 0
    @attr_array = []
    @cond_array = []
    @comment = nil
  end
end
