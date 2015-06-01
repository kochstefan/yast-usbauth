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

require "yast"
Yast.import "UI"
Yast.import "Label"
require "usbauth/generic"
require "usbauth/popup_dialog"

module Usbauth
  class RuleDialog
    include Yast::UIShortcuts
    
    # initialize
    def initialize(auth_arr, id)
      @ra = ["comment", "deny", "allow", "condition"]
      @auths = auth_arr
      @id = id
    end
    
    def run()
      return nil unless showRuleDialog(@id)
      loop do
	case Yast::UI.UserInput
	when :cancel
	  Yast::UI.CloseDialog
	  break
	when :d2close
	  Yast::UI.CloseDialog
	  break
	when :d2edit
	  id2 = Yast::UI.QueryWidget(Id(:tree), :CurrentItem)
	  PopupDialog.new(@auths, @id, id2).run
	  Yast::UI.ChangeWidget(Id(:tree), :Items, tree_items(@id))
	when :d2add
	  id2 = Yast::UI.QueryWidget(Id(:tree), :CurrentItem)
	  if id2 == :rule
	    arr = @auths[@id].attr_array
	    rd = RData.new
	    arr << rd
	    Yast::UI.ChangeWidget(Id(:tree), :Items, tree_items(@id))
	  elsif id2 == :cond
	    arr = @auths[@id].cond_array
	    arr << RData.new
	    Yast::UI.ChangeWidget(Id(:tree), :Items, tree_items(@id))
	  end
	when :d2delete
	  input = Yast::UI.QueryWidget(Id(:tree), :CurrentItem)
	  val = -1
	  if input == :comment
	    @auths[@id].comment = nil
	    Yast::UI.ChangeWidget(Id(:tree), :Items, tree_items(@id))
	  elsif input < 200
	    val = input - 100
	    arr = @auths[@id].cond_array
	    arr.delete_at(val)
	  elsif input < 300
	    val = input - 200
	    arr = @auths[@id].attr_array
	    arr.delete_at(val)
	  end
	  Yast::UI.ChangeWidget(Id(:tree), :Items, tree_items(@id))
	end
      end
    end
    
    # items for tree in tree dialog
    def tree_items(id)
      auth = @auths[id]
      items = []
      
      if  $type[auth.type] == "COND"
	rv = 3
      elsif $type[auth.type] == "ALLOW"
	rv = 2
      elsif $type[auth.type] == "DENY"
	rv = 1
      else
	rv = 0
      end

      cond_array = auth.cond_array
      if $type[auth.type] == "COND"
	offsk = 100
	vk = []
	for k in 0..cond_array.length-1
	  vk << Item(Id(offsk + k), ConfigManager.parameterStr(cond_array[k].param) + ConfigManager.operatorStr(cond_array[k].op) + cond_array[k].val)
	end
	items << Item(Id(:cond), "cond", vk)
      end
      
      attr_array = auth.attr_array
      offsj = 200
      for j in 0..attr_array.length-1
	astr = attr_array[j].anyChild ? "anyChild " : "";
	items << Item(Id(offsj + j), astr + ConfigManager.parameterStr(attr_array[j].param) + ConfigManager.operatorStr(attr_array[j].op) + attr_array[j].val)
      end
      
      comment = "#"
      
      if not auth.comment.nil?
	comment = "#" + auth.comment
      end
      
      items << Item(Id(:comment), comment)
      
      return [Item(Id(:rule), @ra[rv], items)]
    end
    
    # show dialog with rule view as tree
    def showRuleDialog(id)
      Yast::UI.OpenDialog(
	HBox(
          VSpacing(20),
	  VBox(
	      HSpacing(80),
	      Heading("Rule"),
	      Tree(Id(:tree), "label",  tree_items(id)),
	      HBox(PushButton(Id(:d2add), Yast::Label.AddButton), PushButton(Id(:d2delete), Yast::Label.DeleteButton), PushButton(Id(:d2edit), Yast::Label.EditButton)),
	      HBox(PushButton(Id(:d2close), Yast::Label.CloseButton))
	  )
        )
      )
    end
      
  end
end
