-- скрапер TVS для загрузки плейлиста "ОККО" https://okko.tv (25/11/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- Обновляемый токен предоставлен @FC_Sparta4
-- ## необходим ##
-- видеоскрипт: okko.lua
-- ## Переименовать каналы ##
local filter = {
	{'Телеканал «Россия»', 'Россия'},
	{'Телеканал «Россия-Культура»', 'Россия Культура'},
	{'Российский информационный канал «Россия-24»', 'Россия 24'}
	}
	
	local host = 'https://okko.tv/'
	local my_src_name = 'ОККО'
	module('okko_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\okko.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	
	local channels = decode64('aHR0cHM6Ly9jdHgucGxheWZhbWlseS5ydS9zY3JlZW5hcGkvdjEvZXBnY29sbGVjdGlvbi93ZWIvMT9saW1pdD01MDAmZWxlbWVudEFsaWFzPXR2Y2hhbm5lbHNfYWxsJmVsZW1lbnRJZD10dmNoYW5uZWxzX2FsbCZwcm9ncmFtSW5UaW1lbGluZT10cnVlJmN1cnJlbnRQbHVzSG91cj02JnNpZD0')
	
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 2, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	
	local function GetHeader()
		local sum = 0;
		local characters = 'abcdefghijklmnopqrstuvwxyz0123456789'
		for i = 1, 32 do
			local rand = math.floor(math.random() * #characters)
			local character = characters:sub(rand,rand)
			sum = sum .. character
		end	
		local header = 'x-scrapi-signature: ' .. sum
	  return header
	end
	
	local function GetJson(token)
		local rc, answer = m_simpleTV.Http.Request(session, {url = channels .. token, headers = GetHeader()})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
	  return tab
	end
	
	local function CheckToken(token)
		local stat
		local tab = GetJson(token)
		if tab.authorized and tab.element.collectionItems.items then
			return tab
		else 
			stat = 'Нет рабочего токена'
			return stat
		end
	end
	
	local function GetToken()
		local saveToken = m_simpleTV.Config.GetValue('okko_token')
		local tok
		if saveToken then
			tok = CheckToken(saveToken)
			if tok and tok ~= 'Нет рабочего токена' then
				return tok
			end
		end
		if not saveToken or tok == 'Нет рабочего токена' then
			local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9rb3Zyb3YtMzMucnUvb2trby50eHQ')})
			if rc ~= 200 then return end
				if answer then
					answer = decode64(answer)
					local tok = CheckToken(answer)
					if tok ~= 'Нет рабочего токена' then
						m_simpleTV.Config.SetValue('okko_token', answer)
						return tok
					else
						showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
					end
				else
					showMsg('Нет рабочего токена', ARGB(255,255, 0, 0))
				end
		end
	end
	
	local function LoadFromSite()
		local tab = GetToken()
			if not tab or not tab.element.collectionItems.items then return end
		local t = {}
			for i = 1, #tab.element.collectionItems.items do
				local logo
				local id = tab.element.collectionItems.items[i].element.id
				local name = tab.element.collectionItems.items[i].element.name
					for x = 1, #tab.element.collectionItems.items[i].element.basicCovers.items do
						if tab.element.collectionItems.items[i].element.basicCovers.items[x].imageType == 'TITLE' then
							logo = tab.element.collectionItems.items[i].element.basicCovers.items[x].url
						end
					end
					if not name:match('Amedia') 
					and not name:match('viju%+ premiere') 
					and not name:match('viju%+ megahit') 
					and not name:match('viju%+ comedy') 
					and not name:match('viju%+ planet') 
					and not name:match('viju%+ serial') 
					and not name:match('Карусель') 
					and not name:match('ТВ Центр %- Москва') 
					and not name:match('Телекомпания НТВ') 
					and not name:match('Суббота') 
					then
						if id and name then
							t[#t + 1] = {}
							t[#t].name = unescape3(name)
							t[#t].address = host .. id
							t[#t].logo = logo or ''
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
