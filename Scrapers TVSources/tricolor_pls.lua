-- скрапер TVS для загрузки плейлиста "Триколор ТВ" https://tricolor.ru (5/10/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: tricolor.lua
-- расширение дополнения httptimeshift: tricolor-timesift_ext.lua
-- ## Переименовать каналы ##
local filter = {
	{'Детско-юношеский телеканал "Карусель"', 'Карусель'},
	{'Телеканал "Радио Страна FM"', 'Радио Страна FM'},
	{'Телекомпания НТВ', 'НТВ'},
	{'Телекомпания НТВ HD', 'НТВ HD'},
	{'Телеканал Известия', 'Известия'},
	{'Телеканал Е HD', 'Е HD'},
	{'Неизвестная Россия! HD', 'Неизвестная Россия HD'},
	}
	
	local my_src_name = 'Триколор ТВ'
	module('tricolor_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\tricolor.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:143.0) Gecko/20100101 Firefox/143.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9jczEub3R0Z29vZHMucnUvYXBpL3YxL2NoYW5uZWxzLz9maWx0ZXIlNWJ0aW1lem9uZSU1ZD0rMyZwYWdlJTVibGltaXQlNWQ9YWxsJnBsYXRmb3JtPXdlYnVp')})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		answer = answer:gsub('stream%-url', 'stream_url')
		answer = answer:gsub('is%-radio%-channel', 'is_radio_channel')
		answer = answer:gsub('code%-name', 'code_name')
		answer = answer:gsub('catchup%-url', 'catchup_url')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.data then return end
		local t = {}
			for i = 1, #tab.data do
				local name = tab.data[i].attributes.name
				name = name:gsub('\\"', '"')
				local codename = tab.data[i].attributes.code_name
				if codename:match('Kinozal') then
					name = 'Киноазал ' .. codename:match('%d+$')
				end
				if tab.data[i].attributes.visible 
				and not tab.data[i].attributes.is_radio_channel
				and tab.data[i].attributes.description ~= '18+'
				and tab.data[i].attributes.stream_url then
					if not name:match('Триколор Спорт') then
						local url = tab.data[i].attributes.stream_url
						if url and name then
							t[#t + 1] = {}
							t[#t].name = unescape3(name)
							t[#t].address = url
							if tab.data[i].attributes.catchup_url ~= url then
								t[#t].RawM3UString = 'catchup="append" catchup-days="7"'
							end
						end
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