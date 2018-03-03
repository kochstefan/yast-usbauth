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

module Usbauth
  # dialog to edit rule type and rule attributes (parameter, operator, value)
  class PopupDialog
    include Yast::UIShortcuts
    
    # initialize
    def initialize(auths, id, id2)
      @ra = ["comment", "deny", "allow", "condition"]
      @auths = auths
      @id = id
      @id2 = id2
    end
    
    def run()
      return nil unless showPopup(@id, @id2)
      loop do
	case Yast::UI.UserInput
	when :ok
	  modifyAuthFromPopup(@auths[@id], @id2)
	  Yast::UI.CloseDialog
	  break
	when :cancel
	  Yast::UI.CloseDialog
	  break
	end
      end
    end
    
    # make combo box items for string array
    def arrayToCombo(arr, dnr)
      it = []
      for i in 0..arr.length-1
	if i == dnr
	  it << Item(Id(i), arr[i], true)
	else
	  it << Item(Id(i), arr[i])
	end 
      end
      return it
    end
    
    # make combo box items for parameters
    def paramToCombo(dnr)
      len = ConfigManager.parameterEnum("PARAM_NUM_ITEMS");
      it = []
      for i in 0..len-1
	if i == dnr
	  it << Item(Id(i), ConfigManager.parameterStr(i), true)
	else
	  it << Item(Id(i), ConfigManager.parameterStr(i))
	end 
      end
      return it
    end
    
    # make combo box items for operators
    def opToCombo(dnr)
      len = ConfigManager.operatorEnum("OP_NUM_ITEMS");
      it = []
      for i in 0..len-1
	if i == dnr
	  it << Item(Id(i), ConfigManager.operatorStr(i), true)
	else
	  it << Item(Id(i), ConfigManager.operatorStr(i))
	end 
      end
      return it
    end
    
    # popup dialog for tree item edit
    def popup_items(id, id2)
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
	for k in 0..cond_array.length-1
	  v = offsk + k
	  if v == id2
	    ak = []
	    ak << ComboBox(Id(:parameter), "parameter", paramToCombo(cond_array[k].param))
	    ak << HSpacing(2)
	    ak << ComboBox(Id(:operator), "operator", opToCombo(cond_array[k].op))
	    ak << HSpacing(2)
	    ak << InputField(Id(:value), "value", cond_array[k].val)
	    items << HBox(*ak)
	  end
	end
      end
      attr_array = auth.attr_array
      offsj = 200
      for j in 0..attr_array.length-1
	v = offsj + j
	if v == id2
	  aj = []
	  aj << CheckBox(Id(:anyChild), "anyChild", attr_array[j].anyChild)
	  aj << HSpacing(2)
	  aj << ComboBox(Id(:parameter), "parameter", paramToCombo(attr_array[j].param))
	  aj << HSpacing(2)
	  aj << ComboBox(Id(:operator), "operator", opToCombo(attr_array[j].op))
	  aj << HSpacing(2)
	  aj << InputField(Id(:value), "value", attr_array[j].val)
	  items << HBox(*aj)
	end
      end
      
      if id2 == :rule
	items << ComboBox(Id(:rule), "rule", arrayToCombo(@ra, rv))
      end
      
      comment = "#"
      
      if not auth.comment.nil?
	comment = "#" + auth.comment
      end
      
      if id2 == :comment
	items << InputField(Id(:commentInput), "comment", comment)
      end
      
      return items
    end
    
    # change a rule to values from popup dialog
    def modifyAuthFromPopup(auth, id)
      cond_array = auth.cond_array
      if $type[auth.type] == "COND"
	offsk = 100
	for k in 0..cond_array.length-1
	  v = offsk + k
	  if v == id
	    cond_array[k].param = Yast::UI.QueryWidget(Id(:parameter), :Value)
	    cond_array[k].op = Yast::UI.QueryWidget(Id(:operator), :Value)
	    cond_array[k].val = Yast::UI.QueryWidget(Id(:value), :Value).to_s
	    if cond_array[k].val == ""
	      cond_array[k].val = "0"
	    end
	  end
	end
      end
      attr_array = auth.attr_array
      offsj = 200
      for j in 0..attr_array.length-1
	v = offsj + j
	if v == id
	  attr_array[j].param = Yast::UI.QueryWidget(Id(:parameter), :Value)
	  attr_array[j].op = Yast::UI.QueryWidget(Id(:operator), :Value)
	  attr_array[j].val = Yast::UI.QueryWidget(Id(:value), :Value).to_s
	  if attr_array[j].val == ""
	      attr_array[j].val = "0"
	  end
	  attr_array[j].anyChild = Yast::UI.QueryWidget(Id(:anyChild), :Value);
	end
      end
      
      if  $type[auth.type] == "COND"
	rv = 3
      elsif $type[auth.type] == "ALLOW"
	rv = 2
      elsif $type[auth.type] == "DENY"
	rv = 1
      else
	rv = 0
      end
      
      if(id == :rule)
	rv = Yast::UI.QueryWidget(Id(:rule), :Value).to_i
	auth.type = rv
      end
      
      if(id == :comment)
	rv = Yast::UI.QueryWidget(Id(:commentInput), :Value).to_str
	if rv.length >= 2 && rv[0] == '#'
	  rv[0] = ''
	  auth.comment = rv
	else
	  auth.comment = nil
	end
      end
    end
    
    # show popup to edit on element of rule tree
    def showPopup(id, id2)
      Yast::UI.OpenDialog(
        VBox(
             HSpacing(40),
             Heading("Detail"),
             HBox(VSpacing(5), *popup_items(id, id2)),
             HBox(PushButton(Id(:cancel), Yast::Label.CancelButton), PushButton(Id(:ok), Yast::Label.OKButton))
            )
      )
    end
      
  end
end
