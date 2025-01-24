-- скрапер TVS для загрузки плейлиста "online-radio" https://online-radio.su, https://onlinetv.su (24/1/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: online-radio.lua
local host = {
-- {'https://online-radio.su',
			  'https://onlinetv.su'
			}
-- ## Переименовать каналы ##
local filter = {
	{'Discovery Science', 'Nat Geo Wild (дубль)'},
	{'История', 'Авто плюс'},
	{'Ani', 'Авто плюс (дубль)'},
	}
-- ##
	local my_src_name = 'online-radio'
	module('online-radio_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\online-radio.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite(host)
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 12000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host .. '/tv/'})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('[%c]', '')
		if host:match('https://online%-radio%.su') then
			answer = answer:match('<li class="submenu"><a href="/tv">Тв каналы</a><div class="menu%-btn%-toggle"><span class="fa fa%-angle%-up"></span></div><ul class="hidden%-menu">(.-)</ul>')
		end
		if host:match('https://onlinetv%.su') then
			answer = answer:match('<ul class="menu">(.-)</ul>')
		end
		local t = {}
			for w in answer:gmatch('<li>(.-)</li>') do
				local adr = w:match('tv/([^/]+)')
				if adr then
					t[#t + 1] = {}
					t[#t].address = host .. '/tv/' .. adr .. '/'
				end
			end
			if #t == 0 then return end
	 return t
	end
	local function showMess(str)
		local t = {text = 'Проверка канала: ' .. str, showTime = 1000 * 10, color = ARGB(255, 131, 255, 124), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadChannelsFromSite(pls)
		local sum = {}
		for _,val in pairs(pls) do
			local url = val
			local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0')
				if not session then return end
			m_simpleTV.Http.SetTimeout(session, 12000)
			local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			m_simpleTV.Http.Close(session)
				if rc ~= 200 then return end
			local d = {}
				for w in answer:gmatch('<a class="album%-in".-</a>') do
					w = w:gsub('[%c]', '')
					local adr = w:match('href="([^"]+)')
					local title = w:match('<b>(.-)</b>')
					showMess(title)
					local img = w:match('<img src="([^"]+)')
						local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0')
							if not session then return end
						m_simpleTV.Http.SetTimeout(session, 12000)
						local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
						m_simpleTV.Http.Close(session)
							if rc ~= 200 then break end
						answer = answer:match('file:"([^"]+)')
						if answer and answer:match('^https://ser2.musical.uz') then
							if adr and title and img then
								d[#d + 1] = {}
								d[#d].name = title
								d[#d].address = adr
								d[#d].logo = img or ''
								d[#d].stream = answer:match('^.-m3u8')
							end
						end
				end
				local x = {}
				for w in answer:gmatch('<a class="thumb d%-flex fd%-column grid%-item".-</a>')  do
					w = w:gsub('[%c]', '')
					local adr = w:match('href="([^"]+)')
					local title = w:match('<div class="thumb__title ws%-nowrap">(.-)</div>')
					showMess(title)
					local img = w:match('<img src="([^"]+)')
					img = 'https://onlinetv.su' .. img
						local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:131.0) Gecko/20100101 Firefox/131.0')
							if not session then return end
						m_simpleTV.Http.SetTimeout(session, 12000)
						local rc, answer = m_simpleTV.Http.Request(session, {url = adr})
						m_simpleTV.Http.Close(session)
							if rc ~= 200 then break end
						answer = answer:match('<source type="video/mp4" src="([^"]+)')
						if answer and answer:match('^https://ser2.musical.uz') then
							if adr and title and img then
								x[#x + 1] = {}
								x[#x].name = title
								x[#x].address = adr
								x[#x].logo = img or ''
								x[#x].stream = answer:match('^.-m3u8')
							end
						end
				end
				--if #d == 0 then return end
				for i=1,#d do
					sum[#sum+1] = d[i]
				end
				for i=1,#x do
					sum[#sum+1] = x[i]
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
			local t_pls = LoadFromSite(host[i])
				for m = 1, #t_pls do
					pls = LoadChannelsFromSite(t_pls[m])
					for i=1,#pls do
						s_pls[#s_pls+1] = pls[i]
					end
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
