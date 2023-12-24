-- скрапер TVS для загрузки плейлиста "Виват ТВ" http://mag.vivat.live (24/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: vivattv.lua
-- ## переименовать каналы ##
local filter = {
	{'8 канал HD', '8 канал HD (UA)'},
	{'5 канал', 'Пятый канал (UA)'},
	}
	module('vivattv_pls', package.seeall)
	local my_src_name = 'Виват ТВ'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\vivattv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 234 Safari/533.3')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local headers = 'Referer: http://mag.vivat.live/'
		local url = decode64('aHR0cDovL2FwaS52aXZhdC5saXZlL3N0YWJsZS9zaWduP3JlZnJlc2hUb2tlbj0mcHJvZmlsZUlkPTEmbGFuZ3VhZ2U9ZW4mZGV2aWNlVHlwZT0xJmRldmljZUlkPVhYWCtYWFg')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		local accessToken = answer:match('"accessToken":"([^"]+)')
			if not accessToken then return end
		headers = '\nAuthorization: Bearer ' .. accessToken
		url = decode64('aHR0cDovL2FwaS52aXZhdC5saXZlL3N0YWJsZS9jb250ZW50P2xpbWl0PTEwMDAmY29udGVudFR5cGVzPTEmZGV2aWNlVHlwZT0xJmZhdm9yaXRlPTAmZ2VucmVJZHM9MCZzZWFyY2hGbGFnPWFuZCZvbmx5QXZhaWxhYmxlPTEmcHJvZmlsZUlkPTEmbGFuZ3VhZ2U9ZW4mZGV2aWNlSWQ9WFhYK1hYWA')
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		local t = {}
			for i = 1, #tab do
				t[#t + 1] = {}
				t[#t].name = tab[i].title
				t[#t].logo = 'http://api.hmara.tv/images/saved/' .. tab[i].images
				t[#t].address = 'https://vivattv/' .. tab[i].urls
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