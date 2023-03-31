-- скрапер TVS для загрузки плейлиста "24часаТВ" https://app.24h.tv (31/3/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: tv24h.lua
-- расширение дополнения httptimeshift: tv24h-timeshift_ext.lua
-- ## авторизация ##
local access_token = '4d3e29d908873a02ccb622c5ee0a30ec8c17f2af'
local isFree = true
-- ## переименовать каналы ##
local filter = {
	{'Мир-ТВ', 'МИР'},
	}
	module('tv24h_pls', package.seeall)
	local my_src_name = '24часаТВ'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\tv24h.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMess(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = decode64('aHR0cHM6Ly8yNGh0di5wbGF0Zm9ybTI0LnR2L3YyL2NoYW5uZWxzP2Zvcm1hdD1qc29uJmFjY2Vzc190b2tlbj0') .. access_token
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then
				answer = answer or ''
			 return answer:match('"message":"([^"]+)') or 'Недопустимый токен'
			end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab then return end
		local archived_days
		if isFree then
			archived_days = 1
		end
		local t, i, j = {}, 1, 1
			while tab[j] do
				if tab[j].is_purchased == true then
					t[i] = {}
					t[i].name = tab[j].name
					t[i].address = string.format('https://tv24h/%s/stream?access_token=%s', tab[j].id, access_token)
					t[i].RawM3UString = string.format('catchup="append" catchup-days="%s" catchup-source=""', (archived_days or tab[j].real_archived_days or 0))
					i = i + 1
				end
				j = j + 1
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then
				showMess(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			elseif type(t_pls) ~= 'table' then
				showMess(Source.name .. '\n' .. t_pls, ARGB(255, 255, 102, 0))
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
