-- скрапер TVS для загрузки плейлиста "Telik Live" http://telik.live/ (20/08/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: telik-live.lua
local host = 'http://telik.live'
-- ## Переименовать каналы ##
local filter = {
	{'Kinozal 1', 'viju+ Megahit'},
	{'Kinozal 2', 'viju+ Comedy'},
	{'Kinozal 3', 'viju+ Premiere'},
	{'Kinozal 4', 'viju TV1000 action'},
	{'Kinozal 5', 'viju TV1000'},
	{'Kinozal 6', 'viju+ Serial'},
	{'Kinozal 7', 'viju TV1000 русское'},
	{'KLI Fantastic', 'ММ 007'},
	{'KBC-Fantastic', 'ММ Приключения'},
	{'Oasis Фантастика', 'ММ Боевик'},
	}
-- ##

	local my_src_name = 'Telik Live'
	module('telik-live_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\telik-live.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 10, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function LoadFromSite(host)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0')
			if not session then return end
		local rc, answer = m_simpleTV.Http.Request(session, {url = host .. '/sitemap.html'})
			if rc ~= 200 or not answer then return end
		answer = answer:match('<ul class="level_0">(.-)</ul>')
		local t = {}
			for w in answer:gmatch('<li>(.-)</li>') do
				local adr = w:match('href="(.-)"')
				local title = w:match('title="(.-)"')
				title = title:gsub('Канал ', '')
				title = title:gsub('Телеканал ', '')
				title = title:gsub(' прямой эфир', '')
				title = title:gsub(' смотреть', '')
				title = title:gsub(' онлайн', '')
				title = unescape3(title)
				if not title:match('^MM ') 
				and not title:match('^MS ')
				and not title:match('^KLI ')
				and not title:match('^KBC-')
				and not title:match('^YOSSO ')
				and not title:match('^VeleS ')
				and not title:match('^Oasis ')
				and not title:match('^Magic ')
				and not title:match('Marvel TV')
				or title:match('MM Фантастика') 
				or title:match('KLI Fantastic') 
				or title:match('KBC-Fantastic') 
				or title:match('Oasis Фантастика') 
				then
					if adr and title then
						local rc, answer = m_simpleTV.Http.Request(session, {url = host .. adr})
							if not answer then return end
						if answer:match('<iframe.-</iframe>') then
							answer = answer:match('<iframe.-</iframe>')
							if answer:match('src="([^"]+)') then
								answer = answer:match('src="([^"]+)')
							else
								showMsg('Проверка канала: ' .. title .. ' - ошибка нет src', ARGB(255,255, 0, 0))
							end
						else
							showMsg('Проверка канала: ' .. title .. ' - ошибка нет iframe', ARGB(255,255, 0, 0))
						end
						if answer:match('cdntvmedia.com') then
							local header = 'Referer: ' .. host
							local rc, answer = m_simpleTV.Http.Request(session, {url = answer, headers = header})
								if not answer then return end
							if answer:match('tv.tvcdnpotok.com') then
									showMsg('Проверка канала: ' .. title, ARGB(255, 131, 255, 124))
									t[#t + 1] = {}
									t[#t].name = title
									t[#t].address = host .. adr
							else
								showMsg('Проверка канала: ' .. title .. ' - ошибка 2', ARGB(255,255, 0, 0))
							end
						else
							showMsg('Проверка канала: ' .. title .. ' - ошибка 1', ARGB(255, 255, 0, 0))
						end
					end
				else
					showMsg('Проверка канала: ' .. title .. ' - ошибка title', ARGB(255,255, 0, 0))
				end
			end
			if #t == 0 then return end
	 return t
	end

	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		
		local s_pls = LoadFromSite(host)
		
			if not s_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		showMsg(Source.name .. ' (' .. #s_pls .. ')', ARGB(255, 153, 255, 153))
		s_pls = ProcessFilterTableLocal(s_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, s_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n', "D:\xxx.txt")