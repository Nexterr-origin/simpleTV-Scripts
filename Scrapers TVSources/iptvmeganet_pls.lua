-- скрапер TVS для загрузки плейлиста "iptv.mega.net" http://iptv.mega.net.ru (5/9/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ##
	module('iptvmeganet_pls', package.seeall)
	local my_src_name = 'Iptv.Mega.Net'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\iptvmeganet.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
	local function LoadPlst()
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://iptv.mega.net.ru'})
			if rc ~= 200 or not answer then return end
	 return answer
	end
	local function showMess(str, color)
		local t = {text = 'Проверка каналов: ' .. str, showTime = 1000 * 10, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			local url = t[i].address
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then 
				showMess(t[i].name .. ' - не найден', ARGB(255, 255, 55, 0))
				t[i] = nil 
			end
			if rc == 200 then 
				showMess(t[i].name .. ' - найден', ARGB(255, 131, 255, 124))
			end
		end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = tvs_core.GetPlsAsTable(LoadPlst())
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')