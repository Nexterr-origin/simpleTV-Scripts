-- скрапер TVS для загрузки плейлиста "Smotret TV" https://smotrettv.com (11/8/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotrettvcom.lua
-- ## Переименовать каналы ##
local filter = {
	--{'Discovery Science', 'Nat Geo Wild (дубль)'},
	--{'История', 'Авто плюс'},
	--{'Ani', 'Авто плюс (дубль)'},
	}
-- ##
	local host = 'https://smotrettv.com'
	local my_src_name = 'Smotret TV'
	module('smotrettvcom_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotrettvcom.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host .. '/channels.html'})
			if rc ~= 200 then return end
			if not answer then return end
		answer = answer:gsub('[%c]', '')
		answer = answer:match('<div id="dle%-content"><h1> Все каналы в прямом эфире</h1>(.-)</div>')
		local t = {}
			for w in answer:gmatch('<a(.-)</a>') do
				local adr = w:match('href="([^"]+)')
				local title = w:match('<b>(.-)</b>')
				title = title:gsub('Канал ', '')
				title = title:gsub(' смотреть прямой эфир', '')
				title = title:gsub('&#039;', '')
				title = unescape3(title)
				 local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
					answer = answer:match('file:"([^"]+)')
					if answer and answer:match('.-%.musical%.uz') then
						showMsg('Проверка канала: ' .. title, ARGB(255, 131, 255, 124))
						if adr and title then
							t[#t + 1] = {}
							t[#t].address = adr
							t[#t].name = title
						end
					else
						showMsg('Проверка канала: ' .. title .. ' - ошибка', ARGB(255,255, 0, 0))
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
		
		local t_pls = LoadFromSite()
		
			if not t_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		showMsg(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		s_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n', "D:\xxx.txt")