Name:           cationdns
Version:        1.0
Release:        1%{?dist}
Summary:        Lightweight Dynamic DNS client for the IONOS Hosting API
BuildArch:      noarch

License:        GPL-3.0-or-later
URL:            https://github.com/innovara/cationdns
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  systemd-rpm-macros

Requires:       curl

%description
A lightweight Dynamic DNS client for the IONOS Hosting API, written in POSIX shell.
It fetches the current public IPv4 and IPv6 addresses and updates all configured
Dynamic DNS entries when either address has changed.


%prep
%autosetup


%build


%install
%{__install} -Dm755 %{name} %{buildroot}/%{_bindir}/%{name}

install -d -m700 %{buildroot}/%{_sysconfdir}/%{name}
%{__install} -Dm600 %{name}.conf.example %{buildroot}/%{_sysconfdir}/%{name}/%{name}.conf

%{__install} -Dm644 systemd/%{name}.service %{buildroot}/%{_unitdir}/%{name}.service
%{__install} -Dm644 systemd/%{name}.timer %{buildroot}/%{_unitdir}/%{name}.timer

%{__install} -Dm644 systemd/%{name}.preset %{buildroot}/%{_presetdir}/50-%{name}.preset

%{__install} -Dm644 completion/%{name}.bash-completion %{buildroot}/%{_datadir}/bash-completion/completions/%{name}


%files
%license LICENSE
%doc README.md
%{_bindir}/%{name}
%dir %attr(700, root, root) %{_sysconfdir}/%{name}
%config(noreplace) %attr(600, root, root) %{_sysconfdir}/%{name}/%{name}.conf
%{_unitdir}/%{name}.service
%{_unitdir}/%{name}.timer
%{_presetdir}/50-%{name}.preset
%{_datadir}/bash-completion/completions/%{name}


%post
%systemd_post %{name}.timer


%preun
%systemd_preun %{name}.timer
%systemd_preun %{name}.service


%postun
%systemd_postun %{name}.timer
%systemd_postun %{name}.service
if [ $1 -eq 0 ]; then
    rm -f /var/run/cationdns_state
fi


%changelog
* Sat Apr 18 2026 Manuel Fombuena <mfombuena@innovara.tech> - 1.0-1
- First version packaged
