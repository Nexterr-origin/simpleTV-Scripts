-- скрапер TVS для загрузки плейлиста "Inetcom" https://inetcom.tv/ (9/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: inetcom.lua
-- ## переименовать каналы ##
local filter = {
	{'Звезда - RU', 'Звезда'},
	{'Dомашний', 'Домашний'},
	}
	module('inetcom_pls', package.seeall)
	local my_src_name = 'Inetcom'
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\inetcom.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Linux; Android 7.1.2; A5010 Build/N2G48H; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/66.0.3359.158 Mobile Safari/537.36')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local headers = decode64('WC1DbGllbnQtSW5mbzogQW5kcm9pZFBob25lIDUwMzI3NTgyClgtQ2xpZW50LU1vZGVsOiBPbmVQbHVzIEE1MDEwClgtRGV2aWNlOiA0ClJlZmVyZXI6IGh0dHA6Ly9pcHR2LmluZXRjb20ucnUvcGhvbmVfYXBwX3YyL2luZGV4Lmh0bWw/cGxhdGZvcm09QW5kcm9pZFBob25lJnNlcmlhbD01MDMyNzU4MgpYLVJlcXVlc3RlZC1XaXRoOiB0di5pbmV0Y29tLnBob25lMg')
		local url = decode64('aHR0cDovL2FwaTQuaW5ldGNvbS50di9jaGFubmVsL2FsbA')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab
				or not tab[1]
				or not tab[1].id
			then
			 return
			end
		local t = {}
			for i = 1, #tab do
				t[#t + 1] = {}
				t[#t].name = tab[i].caption
				t[#t].logo = tab[i].logoUrl
				t[#t].address = 'https://inetcom.tv/' .. tab[i].id
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
