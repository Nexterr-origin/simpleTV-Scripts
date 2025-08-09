-- скрапер TVS для загрузки плейлиста "Sarkor TV" https://sarkor.tv/ (14/7/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: sarkortv.lua
-- ## Переименовать каналы ##
local filter = {
	{'HDL', 'Точка.РФ'},
	--{'Евроспорт 2', 'Eurosport 2'},
	}
	local host = 'https://sarkor.tv/'
	local my_src_name = 'Sarkor TV'
	module('sarkortv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\sarkortv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:140.0) Gecko/20100101 Firefox/140.0')
	
	local function RenewToken()
		local body = '{"login":"' .. decode64('dHYtNDQ3MzUz') .. '","password":"' .. decode64('MTIzNDU2') .. '"}'
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'post', url = decode64('aHR0cHM6Ly9zYXJrb3IudHYvYXBpL3VzZXIvdjIvbG9naW4'), body = body})
			if rc ~= 200 then return end
		local cookie = m_simpleTV.Http.GetCookies(session, host, 'TOKEN')
			if not cookie then return end
		local sql_string = 'UPDATE ExtFilter SET PlaylistLoadOptions = \'' .. cookie .. '\' WHERE ExtFilter.Name = \'Sarkor TV\';'
		m_simpleTV.Database.ExecuteSql(sql_string,true)
		return cookie
	end
	
	local function GetToken()
		local sql_str = 'SELECT ExtFilter.PlaylistLoadOptions FROM ExtFilter WHERE ExtFilter.Name = \'Sarkor TV\';'
		local x = m_simpleTV.Database.GetTable(sql_str,true)
		local access_token
		if x == nil or #x == 0 then 
			access_token = RenewToken()
		end
		for i,w in pairs(x) do  
			for r,e in pairs(w) do
				if e == nil or e == '' then
					access_token = RenewToken()
				else
					access_token = e
					m_simpleTV.Http.SetTimeout(session, 8000)
					local header = 'Cookie: TOKEN=' .. access_token
						local rc, answer = m_simpleTV.Http.Request(session, {method = 'get', url = decode64('aHR0cHM6Ly9zYXJrb3IudHYvYXBpL3VzZXIvcHJvZmlsZQ'), headers = header})
					if rc ~= 200 then return end
					local status = answer:match('"status":"([^"]+)')
					local msg = answer:match('"message":"([^"]+)')
					if status == 'error' and msg == 'Не авторизованы' then
						local access_token = RenewToken()
					end
				end
			end
		end
			if not access_token then return end
		return access_token
	end
	
	local function LoadFromSite()
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local token = GetToken()
		local header = 'Cookie: TOKEN=' .. token
		local rc, answer = m_simpleTV.Http.Request(session, {method = 'get', url = decode64('aHR0cHM6Ly9zYXJrb3IudHYvYXBpL3BsYXlsaXN0L2dldA'), headers = header})
			if rc ~= 200 then return end

			answer = answer:gsub('\\', '\\\\')
			answer = answer:gsub('\\"', '\\\\"')
			answer = answer:gsub('\\/', '/')
			answer = answer:gsub('%[%]', '""')
			
			require 'json'
			local err, tab = pcall(json.decode, answer)
				if not tab or not tab.result.channels then return end
				local t = {}
				for i = 1, #tab.result.channels do
					local url = tab.result.channels[i].stream_url
					local s = url:match('^https://s([^.]%d+)') or '0'
					local m = url:match('/(%d+)/video%.m3u8$')
					local title = tab.result.channels[i].title
					local logo = tab.result.channels[i].logo
					if s and m and title and logo then
						t[#t + 1] = {}
						t[#t].name = unescape3(title)
						t[#t].address = host .. s .. '/' .. m
						t[#t].logo = logo or ''
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
-- debug_in_file(#tab.result.channels .. '\n', "D:\xxx.txt")