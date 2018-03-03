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
require "usbauth/cwrapper"
require "usbauth/config_manager"
require "usbauth/rule_dialog"

module Usbauth
  # entry dialog that show all rules from the configuration file
  class UsbauthDialog
    include Yast::UIShortcuts
    
    # initialize
    def initialize()
      @configManager = ConfigManager.new
      @auths = @configManager.getAuths()
      @idarr = []
    end
    
    # table for main dialog with rules from config file
    def table
      Table(
        Id(:table),
        Opt(:keep_sorting),
        Header("ID", "Rule"),
        table_items
      )
    end
    
    # items of table
    def table_items
      a = []
      for i in 0..@auths.length-1
        str = @configManager.authToStr(@auths[i])
        a << Item(Id(i), i, str)
      end
      return a
    end
    
    # entrance point of program
    def run()
      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
             Heading("usbauth"),
             table,
             HBox(PushButton(Id(:add), Yast::Label.AddButton), PushButton(Id(:delete), Yast::Label.DeleteButton), PushButton(Id(:edit), Yast::Label.EditButton)),
             HBox(PushButton(Id(:cancel), Yast::Label.CancelButton), PushButton(Id(:ok), Yast::Label.OKButton))
            )
      )
      
      begin
	event_loop
      end
 
    end
    
    # detect button click
    def event_loop()
      loop do
	input = Yast::UI.UserInput
	case input
	when :ok
	  @configManager.setAuths(@auths)
	  Yast::UI.CloseDialog
	  break
	when :cancel
	  Yast::UI.CloseDialog
	  break
	when :edit
	  id = Yast::UI.QueryWidget(Id(:table), :CurrentItem)
	  RuleDialog.new(@auths, id).run
	  Yast::UI.ChangeWidget(Id(:table), :Items, table_items)
	when :add
	  did = Yast::UI.QueryWidget(Id(:table), :CurrentItem)
	  @auths.insert(did+1, RAuth.new)
	  Yast::UI.ChangeWidget(Id(:table), :Items, table_items)
	when :delete
	  did = Yast::UI.QueryWidget(Id(:table), :CurrentItem)
	  @auths.delete_at(did)
	  Yast::UI.ChangeWidget(Id(:table), :Items, table_items)
	end
      end
    end
  end
end
