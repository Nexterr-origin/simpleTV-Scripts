-- скрапер TVS для загрузки плейлиста "Смотрёшка" https://smotreshka.tv (9/12/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: smotreshka.lua
-- ## Переименовать каналы ##
local filter = {
		{'РБК ТВ HD', 'РБК HD'},
	}
	local host = 'https://fe.smotreshka.tv/'
	local my_src_name = 'Смотрёшка'
	module('smotreshka_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\smotreshka.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 3, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local function CheckToken(token)
		local stat
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9mZS5zbW90cmVzaGthLnR2L3YyL2FjY291bnQ/c2Vzc2lvbj0') .. token})
		if rc == 200 and answer:match('"login":"([^"]+)') ~= 'anonymous' then
			stat = 200
		elseif rc ~= 200 then
			stat = 'Нет рабочего токена'
		end
	 return stat
	end	
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('smtrk_token')
		local tok
		if saveToken and CheckToken(saveToken) == 200 then
			tok = saveToken
		else
			local headers = m_simpleTV.Common.CryptographicHash(m_simpleTV.Common.GetCModuleExtension(), Md5) .. ': ' .. m_simpleTV.Common.CryptographicHash(os.date("!%Y|%m|%d", os.time()), Md5)
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL285Njg4OW5vLmJlZ2V0LnRlY2gvdGtuLnBocD90dj1zbXRyaw'), headers = headers})
			if rc ~= 200 then return end
				if answer then
					answer = decode64(answer)
					if CheckToken(answer) == 200 then
						tok = answer
						m_simpleTV.Config.SetValue('smtrk_token', tok)
					else
						showMsg(CheckToken(answer), ARGB(255,255, 0, 0))
					end
				else
					showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
				end
		end
	 return tok
	end
	
	local function GetTvAssetToken()
		local token = GetToken()
			if not token then return end
		local tvAssetToken
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9mZS5zbW90cmVzaGthLnR2L3VzZXIvdjEvYXNzZXQtdG9rZW5zP3Nlc3Npb249') .. token})
			if rc ~= 200 then return end
		if rc == 200 then
			tvAssetToken = answer:match('"tvAssetToken":"([^"]+)')
		end
			if not tvAssetToken then return end
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9mZS5zbW90cmVzaGthLnR2L3R2L3YyL21lZGlhcz90di1hc3NldC10b2tlbj0') .. tvAssetToken})
			if rc ~= 200 then return end
		if rc == 200 then
			return tvAssetToken
		else 
			showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
		end
	end
	
	local token = GetTvAssetToken()
		if not token then return end
	
	local function GetJson(url)
		local url = decode64(url)
		local rc, answer = m_simpleTV.Http.Request(session, {url = host .. url .. '?tv-asset-token=' .. token})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local mass = url:match('([^/]+)$')
		if mass:match('-') then 
			mass = url:match('([^-]+)$')
		end
		local err, data = pcall(json.decode, answer)
			if not data or not data[mass] then return end
	 return data[mass]
	end
	
	local function LoadFromSite()
		local offer = GetJson('b2ZmZXJzL3YzLzY2ZGVmMzNmM2YzODg0OTU2Yjc2MzlhMy9zaG93Y2FzZS1jaGFubmVscw')
		local o = {}
			for i = 1, #offer do
				o[#o + 1] = {}
				o[#o].id = offer[i].channelId
			end
			
		local media = GetJson('dHYvdjIvbWVkaWFz')
		local m = {}
			for i = 1, #media do
				m[#m + 1] = {}
				m[#m].media = media[i].channelId
				m[#m].id = media[i].id
			end
		
		local f = {}		
		for _, v in pairs(m) do
			for _, y in ipairs(o) do
				if v.media == y.id then
					f[#f + 1] = {}
					f[#f].id = y.id
					f[#f].media = v.id
				end
			end
		end
		
		local channels = GetJson('dHYvdjIvY2hhbm5lbHM')
		local t = {}
			for i = 1, #channels do
				for _, v in pairs(f) do
					if channels[i].id == v.id then
						id = v.media
						local title = channels[i].title
						if id and title then
							t[#t + 1] = {}
							t[#t].name = unescape3(title)
							t[#t].address = host .. id
							t[#t].logo = channels[i].logoUrl or ''
							t[#t].RawM3UString = string.format('catchup="append" catchup-days="%s" catchup-source="&delay=${offset}"', (math.ceil(channels[i].dvrDepthLimitHours/24) or 0))
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
