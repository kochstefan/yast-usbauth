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

Name: yast2-usbauth
Version: 0.8
Release: 0
BuildArch: noarch

BuildRoot: %{tmppath}/%{name}-%{version}-build
Source0: %{name}-%{version}.tar.bz2

Requires: yast2
Requires: yast2-ruby-bindings
Requires: libusbauth_configparser0
Requires: xdg-utils
Requires: rubygem(ffi)

BuildRequires: update-desktop-files
BuildRequires: yast2-ruby-bindings
BuildRequires: yast2-devtools
BuildRequires: yast2-branding-openSUSE
BuildRequires: rubygem(yast-rake)

Group: System/YaST
License: GPL-2.0
Summary: YaST tool to edit config file from usbauth
Url: https://build.opensuse.org/package/show/home:skoch_suse/yast2-usbauth

%description
YaST module that help with creating an USB firewall config file

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
* Tue May 5 2015 skoch@suse.de
- initial created spec file
 
