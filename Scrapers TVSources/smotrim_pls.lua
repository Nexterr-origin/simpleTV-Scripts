-- скрапер TVS для загрузки плейлиста "smotrim.ru" https://smotrim.ru (14/9/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotrim.lua, mediavitrina.lua
-- ## Переименовать каналы ##
local filter = {
	{'Setanta Sports Plus', 'Setanta Sports+'},
	{'Евроспорт 2', 'Eurosport 2'},
	}
	local my_src_name = 'Смотрим'
	module('smotrim_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotrim.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:130.0) Gecko/20100101 Firefox/130.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local host = 'https://smotrim.ru'
		local rc, answer = m_simpleTV.Http.Request(session, {url = host .. '/channels'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('[%c]', '')
		local t = {}
			for w in answer:gmatch('<div class="list%-item__box%-link">%s+<a class="list%-item__link".-</a>') do
				local adr = w:match('href="([^"]+)')
				local title = w:match('tabindex="%-1"%s+>(.-)</a>')
				if adr and title and not title:match('Радио') then
					t[#t + 1] = {}
					t[#t].name = unescape3(title):gsub('&quot;', '')
					t[#t].address = host .. adr
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