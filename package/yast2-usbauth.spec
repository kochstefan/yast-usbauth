#
# spec file for package yast2-usbauth
#
# Copyright (c) 2018 Stefan Koch <stefan.koch10@gmail.com>
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

Name:           yast2-usbauth
Version:        0.8
Release:        0

Group:          System/YaST
License:        GPL-2.0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2
Url:            https://github.com/kochstefan/yast-usbauth

BuildRequires:  update-desktop-files
BuildRequires:  yast2-ruby-bindings
BuildRequires:  yast2-devtools
BuildRequires:  yast2-branding-openSUSE
BuildRequires:  rubygem(yast-rake)
Requires:       yast2
Requires:       yast2-ruby-bindings
Requires:       libusbauth-configparser1
Requires:       xdg-utils
Requires:       rubygem(ffi)
Recommends:     usbauth

BuildArch:      noarch

Summary:        YaST2 component for usbauth configuration

%description
YaST module that helps to create an usbauth firewall config file

%prep
%setup -n %{name}-%{version}

%install
rake install DESTDIR="%{buildroot}"

%files
%defattr(-,root,root)
%{yast_dir}/clients/*.rb
%{yast_dir}/lib
%{yast_desktopdir}

%doc COPYING

%build

%changelog

