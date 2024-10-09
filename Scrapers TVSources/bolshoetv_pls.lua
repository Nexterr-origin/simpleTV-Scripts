-- скрапер TVS для загрузки плейлиста "Большое ТВ" https://bolshoe.tv (9/10/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видеоскрипт: bolshoetv.lua
-- ## Переименовать каналы ##
local filter = {
	}
	local host = 'https://bolshoe.tv'
	local my_src_name = 'Большое ТВ'
	module('bolshoetv_pls', package.seeall)
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\bolshoetv.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:131.0) Gecko/20100101 Firefox/131.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkuYm9sc2hvZS50di93ZWIvMS9hdXRoL3dlYg')})
			if rc ~= 200 then return end
		local token = answer:match('"access_token":"([^"]+)')
			if not token then return end
		local header = 'X-APP-ACCESS-TOKEN: ' .. token
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cHM6Ly9hcGkuYm9sc2hvZS50di93ZWIvMS9jb2xsZWN0aW9ucz90YWJfaWQ9dHZfY2hhbm5lbHNfdGFiJlJCX3F1ZXVlX2NvdW50PTEwMCZSQl90ZWFzZXJfY291bnQ9MTAw'), headers = header})
			if rc ~= 200 then return end
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local err, tab = pcall(json.decode, answer)
			if not tab or not tab.response then return end
		local t = {}
		for i = 1, #tab.response do
			for x = 1, #tab.response[i].EKs do
				local id = tab.response[i].EKs[x].stream_id
				local title = unescape3(tab.response[i].EKs[x].chan_name)
				local img = tab.response[i].EKs[x].chan_poster_url
				if id and title and img then
					t[#t + 1] = {}
					t[#t].name = title
					t[#t].address = host .. '/promo/web/tv/' .. id .. '/'
					if tab.response[i].EKs[x].archived_hours_number then 
						t[#t].RawM3UString = string.format('catchup="append" catchup-days="%s" catchup-source=""', (tab.response[i].EKs[x].archived_hours_number/24 or 0))
					end
					t[#t].logo = img or ''
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
		
		local hash = {}
		local res = {}

		for _,v in ipairs(t_pls) do
		   if (not hash[v.address]) then
			   res[#res+1] = v
			   hash[v.address] = true
		   end
		end
		
		t_pls = res
		
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