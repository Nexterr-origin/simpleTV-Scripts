-- скрапер TVS для загрузки плейлиста "LimeHD" https://limehd.tv (6/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: limeHD.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'ЛДПР LIVE', 'ЛДПР ТВ'},
	{'Липецкое время', 'Липецкое время (Липецк)'},
	}
	module('limeHD_pls', package.seeall)
	local my_src_name = 'LimeHD'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\limehd.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, show_progress = 0, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = decode64('aHR0cHM6Ly9hcGkuaXB0djIwMjEuY29tL3YxL2NoYW5uZWxzL2J5X2dyb3VwLzExP2xvY2FsZT1ydQ')
		local headers = decode64('WC1BY2Nlc3MtS2V5OiAxMGFhMDkxMTQ1ODhhNWY3NTBlYWVkNWU5ZGU1MzcwNGM4NThlMTQ0')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab
				or not tab.data
			then
			 return
			end
		local t, i = {}, 1
			while tab.data[i] do
				if tab.data[i].attributes
					and tab.data[i].attributes.streams
					and tab.data[i].attributes.streams[1]
					and tab.data[i].attributes.streams[1].id
				then
					t[#t + 1] = {}
					t[#t].name = tab.data[i].attributes.name
					t[#t].address = 'https://limehd.tv/' .. tab.data[i].attributes.streams[1].id
					t[#t].logo = tab.data[i].attributes.image_url
					local archive_minutes = (tab.data[i].attributes.streams[1].archive_hours or 0) * 60
					t[#t].RawM3UString = 'catchup="append" catchup-minutes="' .. archive_minutes .. '"'
				end
				i = i + 1
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
