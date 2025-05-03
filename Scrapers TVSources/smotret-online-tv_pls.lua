-- скрапер TVS для загрузки плейлиста "Смотреть онлайн ТВ" https://smotret-online.tv (3/5/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotret-online-tv.lua
local host = 'https://smotret-online.tv'
local filter = {
	{'Setanta Sports Plus', 'Setanta Sports+'},
	{'Евроспорт 2', 'Eurosport 2'},
	}
-- ##
	local my_src_name = 'Смотреть онлайн ТВ'
	module('smotret-online-tv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotret-online-tv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:match('<div class="dropdown%-menu">(.-)</div>')
			if not answer then return end
		local t = {}
			for w in answer:gmatch('<a.-</a>') do
				local adr = w:match('href="([^"]+)')
				if adr then
					t[#t + 1] = {}
					t[#t].address = adr
				end
			end
			if #t == 0 then return end
	 return t
	end
	
	local function LoadChannelsFromSite(pls)
		local sum = {}
		for _,val in pairs(pls) do
			local url = host .. val.address
			local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
				if not session then return end
			m_simpleTV.Http.SetTimeout(session, 20000)
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			local d = {}
			for w in answer:gmatch('<div class="tv%-schedule".-</div>') do
				local adr = w:match('data%-link="([^"]+)')
				local title = w:match('data%-custom%-name="([^"]+)')
				local img = w:match('data%-logo="([^"]+)')
				if adr and title and img then
					d[#d + 1] = {}
					d[#d].name = unescape3(title)
					d[#d].address = adr
					d[#d].logo = img or ''
				end
			end
			if #d == 0 then return end
			
			for i=1,#d do
				sum[#sum+1] = d[i]
			end
				
		end
		return sum
	end

	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
		t_pls = LoadChannelsFromSite(t_pls)
			if not t_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		showMsg(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n', "D:\xxx.txt")