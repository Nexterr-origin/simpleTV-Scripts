-- скрапер TVS для загрузки плейлиста "smotret-tv.live, telik.live" http://smotret-tv.live, http://telik.live/ (24/03/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotre-tv_telik_live.lua
local host = {'http://smotret-tv.live',
			  'http://telik.live'
			}
-- ## Переименовать каналы ##
local filter = {
	--{'Discovery Science', 'Nat Geo Wild (дубль)'},
	}
-- ##

	local my_src_name = 'Смотреть ТВ Телик Live'
	module('smotre-tv_telik_live_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotre-tv_telik_live.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function showMess(str)
		local t = {text = 'Проверка канала: ' .. str, showTime = 1000 * 10, color = ARGB(255, 131, 255, 124), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function LoadFromSite(host)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
			if not answer then return end
		local t = {}
			for w in answer:gmatch('<td.-</td>') do
				local adr = w:match('<a href="(.-)">')
				local title = w:match('title="(.-)"')
				if adr and title and answer:match('src="([^"]+)') then
					local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
						if not session then return end
					m_simpleTV.Http.SetTimeout(session, 20000)
					local rc, answer = m_simpleTV.Http.Request(session, {url = host .. adr})
					m_simpleTV.Http.Close(session)
					answer = answer:match('<iframe.-</iframe>')
					answer = answer:match('src="([^"]+)')
					if answer:match('cdntvmedia.com') then
						title = title:gsub(' онлайн', '')
						title = title:gsub(' прямой эфир', '')
						title = unescape3(title)
						showMess(title)
							t[#t + 1] = {}
							t[#t].name = title
							t[#t].address = host .. adr
							t[#t].stream = answer
					end
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
		local s_pls = {}

		for i = 1, #host do
			local t_pls = LoadFromSite(host[i])
				for m = 1, #t_pls do
					s_pls[#s_pls+1] = t_pls[m]
				end	
		end
		
		local hash = {}
		local res = {}

		for _,v in ipairs(s_pls) do
		   if (not hash[v.stream]) then
			   res[#res+1] = v
			   hash[v.stream] = true
		   end
		end
		
		s_pls = res
		
		
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