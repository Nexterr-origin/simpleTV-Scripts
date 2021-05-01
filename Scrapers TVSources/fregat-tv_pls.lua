-- скрапер TVS для загрузки плейлиста "Фрегат ТВ" https://fregat.com (8/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## переименовать каналы ##
local filter = {
	{'ZeeTv', 'Zee TV'},
	}
-- ##
	module('fregat-tv_pls', package.seeall)
	local my_src_name = 'Фрегат ТВ'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\fregat.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, AutoBuild = 0, show_progress = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function extOpt()
	 return decode64('JE9QVDpodHRwLWV4dC1oZWFkZXI9eC1zbWFydGxhYnMtbWFjLWFkZHJlc3M6RjU6MTE6QTA6MEY6')
					..  string.format('%02X:%02X', math.random(255), math.random(255))
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('SmartLabs/1.51652.472 (sml723x, SML-482) SmartSDK/1.5.63-rt-25 Qt/4.7.3 API/20121210')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 14000)
		local url = decode64('aHR0cDovL2ZlLm90dC5mcmVnYXQubmV0L0NhY2hlQ2xpZW50L25jZHhtbC9DaGFubmVsUGFja2FnZS9saXN0X2NoYW5uZWxzP2NoYW5uZWxQYWNrYWdlSWQ9MjA4MTM0MTImbG9jYXRpb25JZD0xMDAwMDUwJmZyb209MCZ0bz0yMTQ3NDgzNjQ3Jmxhbmc9cnU')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t, i = {}, 1
		local logoHost = url:match('^https?://[^/]+')
			for w in answer:gmatch('<channel>.-</channel>') do
				local name = w:match('<bcname>([^<]+)')
				local adr = w:match('<smlOttURL>([^<]+)')
				if adr and name then
					t[i] = {}
					t[i].name = name:gsub('amp;', '')
					t[i].address = adr .. extOpt()
					local logo = w:match('<logo2>([^<]+)') or ''
					if logo ~= '' then
						t[i].logo = string.format('%s/images/%s', logoHost, logo)
					end
					i = i + 1
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
		local t_pls = LoadFromSite()
			if not t_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		t_pls = ProcessFilterTableLocal(t_pls)
		showMsg(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
