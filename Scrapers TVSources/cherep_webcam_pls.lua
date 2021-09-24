-- скрапер TVS для загрузки плейлиста "Веб камеры Череповца" http://www.cmirit.ru (24/9/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
	module('cherep_webcam_pls', package.seeall)
	local my_src_name = 'Веб камеры Череповца'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\cherep_webcam.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 3, RemoveDupCH = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:92.0) Gecko/20100101 Firefox/92.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = 'https://video.cmirit.ru'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local array = answer:match('parse%("%[(.-)%]"')
			if not array then return end
		array = array:gsub('\\u0022', '"')
		array = array:gsub('\u', '\\u')
		array = unescape3(array)
		array = array:gsub('\\\\', '')
		array = array:gsub('\\%-', '-')
		array = array:gsub('\\u', 'u')
		local t = {}
			for w in array:gmatch('"id":[^{}]+"path":%s*"[^"]+"') do
				local name = w:match('"name":%s*"([^"]+)')
				local adr = w:match('"path":%s*"([^"]+)')
				if name and adr then
					t[#t + 1] = {}
					t[#t].name = name
					t[#t].address = adr
					t[#t].group = 'Веб камеры Череповца'
					local logo = adr:match('/live/([^._]+)')
					if logo then
						t[#t].logo = 'http://live.cmirit.ru:8000/autopics/' .. logo .. '.jpg'
					end
				end
			end
			if #t == 0 then return end
		local hash, tab = {}, {}
			for i = 1, #t do
				if not hash[t[i].address] then
					tab[#tab + 1] = t[i]
					hash[t[i].address] = true
				end
			end
	 return tab
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then return end
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
