-- скрапер TVS для загрузки плейлиста "Rutube TV" https://rutube.ru (4/2/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: rutube.lua
-- ## Переименовать каналы ##
local filter = {
	{'Setanta Sports Plus', 'Setanta Sports+'},
	{'Евроспорт 2', 'Eurosport 2'},
	}
	local my_src_name = 'Rutube TV'
	module('rutubetv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\rutubetv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local sum = {}
	local function LoadFromSite(url_new)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = {}
		if url_new == nil then
			url = decode64('aHR0cHM6Ly9ydXR1YmUucnUvYXBpL3ZpZGVvL3RvcGljLzEv')
		else
			url = url_new
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.results then return end
		local t = {}
			for i = 1, #tab.results do
				local slug = tab.results[i].video_url
				local title = tab.results[i].title
				if slug and title and tab.results[i].is_paid ~= true then
					t[#t + 1] = {}
					title = unescape3(title)
					title = title:gsub('\\', '')
					title = title:gsub('??', '')
					title = title:gsub(':', '')
					title = title:gsub('"', '')
					title = title:gsub('«', '')
					title = title:gsub('»', '')
					title = title:gsub(',', '')
					title = title:gsub('-', ' ')
					title = title:gsub('%.', ' ')
					title = title:gsub(' ! ', ' ')
					title = title:gsub('Прямой эфир', '')
					title = title:gsub('ПРЯМОЙ ЭФИР', '')
					title = title:gsub('телеканала', '')
					title = title:gsub('телеканал', '')
					title = title:gsub('Телеканал', '')
					title = title:gsub('прямой эфир', '')
					title = title:gsub('Прямая трансляция', '')
					title = title:gsub('Эфир православного', '')
					title = title:gsub('Эфир', '')
					title = title:gsub('КРУГЛОСУТОЧНЫЙ', '')
					title = title:gsub('RUTUBE', '')
					title = title:gsub('ПРЯМАЯ ТРАНСЛЯЦИЯ', '')
					title = title:gsub('ОНЛАЙН', '')
					title = title:gsub('247', '')
					title = title:gsub('24/7', '')
					t[#t].name = title
					t[#t].address = slug
					t[#t].logo = tab.results[i].author.avatar_url or ''
				end
			end
		if tab.next ~= nil then
			LoadFromSite(tab.next)
		end
		for i=1,#t do
			sum[#sum+1] = t[i]
		end
	 return sum
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
