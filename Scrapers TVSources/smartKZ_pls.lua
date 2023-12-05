-- скрапер TVS для загрузки плейлиста "smartKZ" https://telecom.kz (8/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: smartKZ.lua
-- ## переименовать каналы ##
local filter = {
	{'EuroSport2 HD', 'EuroSport 2 HD'},
	}
	module('smartKZ_pls', package.seeall)
	local my_src_name = 'smartKZ'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smartKZ.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('SmartLabs/1.51652.472 (sml723x, SML-482) SmartSDK/1.5.63-rt-25 Qt/4.7.3 API/20121210')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 18000)
		local url = decode64('aHR0cHM6Ly9zbWFydC10di5pZC10di5rei9yZXN0L2NoYW5uZWxzP2F1dGhUb2tlbj0wMmJmOGU0NjBmYmZmNzZiJmZ3VmVyc2lvbj1wY3BsYXllci5tM3U')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.channels then return end
		local t = {}
			for i = 1, #tab.channels do
				if tab.channels[i]
					and tab.channels[i].url
					and tab.channels[i].url ~= ''
					and tab.channels[i].name
				then
					t[#t + 1] = {}
					t[#t].name = tab.channels[i].name:gsub('%.%s*$', '')
					t[#t].address = tab.channels[i].url
					if tab.channels[i].posters
						and tab.channels[i].posters.default
					then
						t[#t].logo = tab.channels[i].posters.default.url
					end
				end
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