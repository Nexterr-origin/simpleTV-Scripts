-- скрапер TVS для загрузки плейлиста "onlyTV" http://online-tv.live, http://sweet-tv.net/ (9/6/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: onlytv.lua
local host = {'https://online-tv.live',
			  'http://sweet-tv.net'
			}
-- ## Переименовать каналы ##
local filter = {
	--{'Setanta Sports Plus', 'Setanta Sports+'},
	--{'Евроспорт 2', 'Eurosport 2'},
	}
-- ##
	local my_src_name = 'onlyTV'
	module('onlyTV_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\onlytv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function LoadFromSite(host)
		local url
		if host:match('https://online%-tv%.live') then
			url = host .. '/kategorii.html'
		end
		if host:match('http://sweet%-tv%.net') then
			url = host
		end
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('[%c]', '')
		if host:match('http://sweet%-tv%.net') then
			answer = answer:match('<div class="layout%-cell sidebar1">(.-)</div>')
		end
			if not answer then return end
		local t = {}
			for w in answer:gmatch('<td.-</td>') do
				local adr = w:match('href="([^"]+)')
				if adr then
					t[#t + 1] = {}
					t[#t].address = host .. adr
				end
			end
			if #t == 0 then return end
	 return t
	end
	
	local function LoadChannelsFromSite(pls)
		local sum = {}
		for _,val in pairs(pls) do
			local url = val.address
			local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:134.0) Gecko/20100101 Firefox/134.0')
			if not session then return end
			m_simpleTV.Http.SetTimeout(session, 20000)
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			local host = url:match('https?://.-/')
			host = host:sub(1, -2)
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			answer = answer:gsub('[%c]', '')
			if host:match('https://online%-tv%.live') then
				answer = answer:match('<table style="width: 100%%;">.-</table>')
			end
			if host:match('http://sweet%-tv%.net') then
				answer = answer:match('<table style="margin: 0px auto; width: 100%%;" border="0">.-</table>')
			end
				if not answer then return end
				local d = {}
				for w in answer:gmatch('<td.-</td>') do
					local adr = w:match('href="([^"]+)')
					local title = w:match('title="([^"]+)')
					if host:match('https://online%-tv%.live') and title then
						title = title:gsub(' смотреть онлайн', '')
					end
					if host:match('http://sweet%-tv%.net') and title then
						title = title:gsub('Смотреть ', '')
						title = title:gsub(' онлайн', '')
					end
					local img = w:match('src="([^"]+)')
					if adr and title and img then
						d[#d + 1] = {}
						d[#d].name = title
						d[#d].address = host .. adr
						d[#d].title = title
						d[#d].logo = host .. img or ''
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
	
		local s_pls = {}
		for i = 1, #host do
			local res = LoadFromSite(host[i])
				for m = 1, #res do
					s_pls[#s_pls+1] = res[m]
				end	
		end
		
		local x_pls = LoadChannelsFromSite(s_pls)
		
		local hash = {}
		local t_pls = {}

		for _,v in ipairs(x_pls) do
		   if (not hash[v.title]) then
			   t_pls[#t_pls+1] = v
			   hash[v.title] = true
		   end
		end
		
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
