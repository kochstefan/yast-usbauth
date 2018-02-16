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

require "ffi"

# C data structure (ruby see generic.rb)
class Struct_data < FFI::Struct
  layout :anyChild, :bool,
      :param, :int,
      :op, :int,
      :val, :pointer
end

# C rule structure (ruby see generic.rb)
class Struct_auth < FFI::Struct
  layout :type, :int,
      :devcount, :uint,
      :intfcount, :uint,
      :attr_len, :uint,
      :attr_array, Struct_data.ptr,
      :cond_len, :uint,
      :cond_array, Struct_data.ptr,
      :comment, :pointer
end

module Usbauth
  # CWrapper class uses the usbauth-configparser C library and wraps it into ruby style
  class CWrapper
    extend FFI::Library
    ffi_lib 'c'
    ffi_lib 'libusbauth-configparser.so.1'
    attach_function :usbauth_config_read, [], :int
    attach_function :usbauth_config_write, [], :int
    attach_function :usbauth_config_get_auths, [:pointer, :pointer], :void
    attach_function :usbauth_config_set_auths, [:pointer, :uint], :void
    attach_function :usbauth_auth_to_str, [Struct_auth.ptr], :string
    attach_function :usbauth_param_to_str, [:int], :string
    attach_function :usbauth_str_to_param, [:pointer], :int
    attach_function :usbauth_str_to_op, [:pointer], :int
    attach_function :usbauth_op_to_str, [:int], :string
    
    # convert C data structure array into ruby rules array
    def self.cauths_to_rauths(cauth, len)
      rauth = []
      for i in 0..len-1
	rdata = []
	rcond = []
	auth = Struct_auth.new(cauth.read_pointer + i*Struct_auth.size)
	rauthe = RAuth.new
	rauthe.type = auth[:type]
	rauthe.intfcount = auth[:intfcount]
	rauthe.devcount = auth[:devcount]
	rauthe.attr_array = rdata
	rauthe.cond_array = rcond
	if not auth[:comment].null?
	  rauthe.comment = auth[:comment].read_string()
	end
	rauth << rauthe
	len = auth[:attr_len]
	condlen = auth[:attr_len]
	dataptr = auth[:attr_array]
	condptr = auth[:cond_array]
	  for j in 0..len-1
	    data = Struct_data.new(dataptr.to_ptr + j*Struct_data.size)
	    rdatae = RData.new
	    rdatae.anyChild = data[:anyChild]
	    rdatae.param = data[:param]
	    rdatae.op = data[:op]
	    rdatae.val = data[:val].read_string()
	    rdata << rdatae
	  end
	  if $type[auth[:type]] == "COND"
	    for k in 0..condlen-1
	      cond = Struct_data.new(condptr.to_ptr + k*Struct_data.size)
	      rconde = RData.new
	      rconde.anyChild = cond[:anyChild]
	      rconde.param = cond[:param]
	      rconde.op = cond[:op]
	      rconde.val = cond[:val].read_string()
	      rcond << rconde
	    end
	  end
      end
	
      return rauth
    end
    
    # convert ruby rules array into C structure array
    def self.rauths_to_cauths(rauth)
      carr = FFI::MemoryPointer.new(Struct_auth, rauth.length)
      rcarr = Struct_auth.new(carr)
      for i in 0..rauth.length-1
	auth = Struct_auth.new(carr + i*Struct_auth.size)
	rauthe = rauth[i]
	rdata = rauthe.attr_array
	rcond = rauthe.cond_array
	auth[:type] = rauthe.type
	auth[:devcount] = rauthe.devcount
	auth[:intfcount] = rauthe.intfcount
	auth[:attr_len] = rdata.length
	rdata = rauthe.attr_array
	auth[:cond_len] = rcond.length
	rcond = rauthe.cond_array
	
	if not rauthe.comment.nil?
	  auth[:comment] = FFI::MemoryPointer.from_string(rauthe.comment)
	end
	
	dataarr = FFI::MemoryPointer.new(Struct_data, rdata.length)
	auth[:attr_array] = Struct_data.new(dataarr)
	  for j in 0..rdata.length-1
	    data = Struct_data.new(dataarr + j*Struct_data.size)
	    rdatae = rdata[j]
	    data[:anyChild] = rdatae.anyChild
	    data[:param] = rdatae.param
	    data[:op] = rdatae.op
	    data[:val] = FFI::MemoryPointer.from_string(rdatae.val)
	  end
	  condarr = FFI::MemoryPointer.new(Struct_data, rcond.length)
	  auth[:cond_array] = Struct_data.new(condarr)
	  if $type[auth[:type]] == "COND"
	    for k in 0..rcond.length-1
	      cond = Struct_data.new(condarr + k*Struct_data.size)
	      rconde = rcond[k]
	      cond[:anyChild] = rconde.anyChild
	      cond[:param] = rconde.param
	      cond[:op] = rconde.op
	      cond[:val] = FFI::MemoryPointer.from_string(rconde.val)
	    end
	  end
      end
	
      return rcarr
    end
    
    # convert C data structure array into ruby rules array
    def self.get_rauths()
      usbauth_config_read
      counter = 0
      counterptr = FFI::MemoryPointer.new :pointer
      authptr = FFI::MemoryPointer.new :pointer
      usbauth_config_get_auths(authptr, counterptr)
      counter = counterptr.read_uint
      
      return cauths_to_rauths(authptr, counter)
    end
    
    # convert one ruby rule into one C rule
    def self.rauth_to_cauth(rauth)
      return rauths_to_cauths([rauth])
    end
    
    # create ruby string from ruby rule
    def self.rauth_str(rauth)
      cauth = rauth_to_cauth(rauth)
      cstr = usbauth_auth_to_str(cauth)
      str = " "
      str += cstr
      return str
    end
    
    # set new rule array
    def self.set_rauths(auths)
      cauths = rauths_to_cauths(auths)
      len = auths.length
      usbauth_config_set_auths(cauths, len)
      usbauth_config_write
    end
    
    # get parameter as string
    def self.parameter_to_str(enum)
      cstr = usbauth_param_to_str(enum)
      str = ""
      str += cstr
      return str
    end
    
    # get parameter as enum
    def self.str_to_parameter(str)
      cstr = FFI::MemoryPointer.from_string(str)
      return usbauth_str_to_param(cstr)
    end
    
    # get parameter as string
    def self.operator_to_str(enum)
      cstr = usbauth_op_to_str(enum)
      str = ""
      str += cstr
      return str
    end
    
    # get op as enum
    def self.str_to_operator(str)
      cstr = FFI::MemoryPointer.from_string(str)
      return usbauth_str_to_op(cstr)
    end
      
  end
end
