-- скрапер TVS для загрузки плейлиста "Zala" http://zala.by (23/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- только для беларуссии
-- ## переименовать каналы ##
local filter = {
	{'Муз ТВ', 'МУЗ-ТВ'},
	{'Фест-ТВ', '1HD'},
	{'СТВ', 'СТВ (Беларусь)'},
	{'Eureka', 'Эврика'},
	{'National Geographic Channel', 'National Geographic'},
	{'Setanta Sport Eurasia +', 'Setanta Sports 2'},
	{'Setanta Sport Eurasia', 'Setanta Sports 1'},
	{'8 канал', 'ВосьМой'},
	{'Европа +', 'Europa Plus TV'},
	{'5 International', 'Пятый канал Int'},
	{'ТВ3', 'ТВ-3 Беларусь'},
	{'Тайны Галактики MSS', 'Тайны Галактики'},
	{'8 Канал', 'ВосьМой'},
	}
-- ##
	module('zala_pls', package.seeall)
	local my_src_name = 'Zala'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\zala.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local url = decode64('aHR0cHM6Ly9mZS5zdmMub3R0LnphbGEuYnkvQ2FjaGVDbGllbnRKc29uL2pzb24vQ2hhbm5lbFBhY2thZ2UvbGlzdF9jaGFubmVscz9jaGFubmVsUGFja2FnZUlkPTU5MDI4MzAwJmxvY2F0aW9uSWQ9MTExMSZsYW5nPXJ1JmZyb209MCZ0bz05OTk5')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		require 'json'
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab
				or not tab.channels_list
			then
			 return
			end
		local t, i = {}, 1
			while tab.channels_list[i] do
				local title = tab.channels_list[i].bcname
				local adr = tab.channels_list[i].smlOttURL
				if title
					and adr
					and tab.channels_list[i].is_crypted == '0'
				then
					adr = adr:gsub('https://', 'http://')
					t[#t + 1] = {}
					t[#t].name = title
					t[#t].address = adr
					t[#t].RawM3UString = 'catchup="append" catchup-days="2" catchup-source="?offset=-${offset}&utcstart=${timestamp}" catchup-record-source="?utcstart=${start}&utcend=${end}"'
					local logo = tab.channels_list[i].logo
					if logo then
						t[#t].logo = 'https://mfe.svc.ott.zala.by/images/' .. logo
					end
				end
				i = i + 1
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
				showMsg(Source.name .. ': ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
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
