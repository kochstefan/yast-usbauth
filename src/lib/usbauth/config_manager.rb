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

require "usbauth/generic"

module Usbauth
  class ConfigManager
    # initialize, so read config
    def initialize()
      readConfig()
    end
    
    # convert one rule to string
    def authToStr(auth)
      return CWrapper.rauth_str(auth)
    end
    
    # convert rules to string
    def authsToStr(auths)
      str = ""
      for i in 0..auths.length-1
	str += authToStr(auths[i])
      end
      return str
    end
    
    # read config file
    def readConfig()
      @auths = CWrapper.get_rauths()
    end
    
    # save edited config file
    def writeConfig()
      CWrapper.set_rauths(@auths)
    end
    
    # get reference to rules array
    def getAuths()
      return @auths
    end
    
    # set a new rules array
    def setAuths(arr)
      @auths = arr
      writeConfig()
    end
    
    # get parameter as string
    def self.parameterStr(enum)
      return CWrapper.parameter_to_str(enum)
    end
    
    # get parameter as string
    def self.parameterEnum(str)
      return CWrapper.str_to_parameter(str)
    end
    
    # get parameter as string
    def self.operatorStr(enum)
      return CWrapper.operator_to_str(enum)
    end
    
    # get parameter as string
    def self.operatorEnum(str)
      return CWrapper.str_to_operator(str)
    end
    
  end
end

