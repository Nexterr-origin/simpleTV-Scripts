-- скрапер TVS для загрузки плейлиста "voka" https://www.voka.tv (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: voka.lua
-- ## Беларусъ прокси ##
local proxy = ''
-- 'http://134.17.84.84:8080' -- (пример)
-- ## переименовать каналы ##
local filter = {
	{'Мир-ТВ', 'МИР'},
	{'СТВ', 'СТВ (Беларусь)'},
	{'Русский экстрим', 'Russian Extreme'},
	{'8 канал', '8 Канал (Беларусь)'},
	{'ТВ-3', 'ТВ-3 Беларусь'},
	{'2-й городской канал', 'ТВ2 Могилёв'},
	{'8 канал HD', '8 Канал (Беларусь)'},
	{'М1-Глобал', 'M-1 Global'},
	{'Amedia 1 HD', 'A1'},
	{'Amedia 2 HD', 'A2'},
	{'MTV', 'MTV Russia'},
	{'Cinema HD', 'Cinema Космос ТВ'},
	{'ПерецI', 'Перец Int'},
	{'ДомашнийI', 'Домашний Int'},
	{'HD Медиа', 'HD Media'},
	}
-- ##
	module('voka_pls', package.seeall)
	local my_src_name = 'voka'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\voka.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2,'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local userAgent = 'Mozilla/5.0 (SMART-TV; Linux; Tizen 4.0.0.2) AppleWebkit/605.1.15 (KHTML, like Gecko) SamsungBrowser/9.2 TV Safari/605.1.15'
		local session = m_simpleTV.Http.New(userAgent, proxy, false)
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local url = decode64('aHR0cHM6Ly9hcGkudm9rYS50di92MS9jb2xsZWN0aW9uX2l0ZW1zLmpzb24/Y2xpZW50X3ZlcnNpb249MC4wLjEmZXhwYW5kW2NoYW5uZWxdPWdlbnJlcyxnZW5yZXMuaW1hZ2VzLGltYWdlcyxsaXZlX3ByZXZpZXcsbGFuZ3VhZ2UsbGl2ZV9zdHJlYW0sY2F0Y2h1cF9hdmFpbGFiaWxpdHksdGltZXNoaWZ0X2F2YWlsYWJpbGl0eSxjZXJ0aWZpY2F0aW9uX3JhdGluZ3MmZmlsdGVyW2NvbGxlY3Rpb25faWRfZXFdPTlmYzY3ODUxLTQxYTEtNDI5ZC1iN2NhLTRiOGY0OWM1MzY1OSZsb2NhbGU9cnUtUlUmcGFnZVtsaW1pdF09MzAwJnBhZ2Vbb2Zmc2V0XT0wJnNvcnQ9cmVsZXZhbmNlJnRpbWV6b25lPTEwODAwJmNsaWVudF9pZD02OWMyOTQ5Zi1kNTY4LTRkN2YtODA2OC01Y2YyZjYyOTVlNTY')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		require 'json'
		local tab = json.decode(answer)
			if not tab or not tab.data then return end
		local t, i = {}, 1
			while tab.data[i] do
				t[i] = {}
				if tab.data[i].catchup_availability
					and tab.data[i].catchup_availability.available
					and tab.data[i].catchup_availability.available == true
				then
					local period = tab.data[i].catchup_availability.period.value
					if tab.data[i].catchup_availability.period.unit == 'hours' then
						period = period * 60
						t[i].RawM3UString = 'catchup="append" catchup-minutes="' .. period
											.. '" catchup-source="?stream_start_offset=${offset}000000"'
					else
						t[i].RawM3UString = 'catchup="append" catchup-days="' .. period
											.. '" catchup-source="?stream_start_offset=${offset}000000"'
					end
				end
				t[i].name = tab.data[i].name:gsub('%(новый%)', ''):gsub('%(тест%)', ''):gsub('%(Тест%)', ''):gsub('%(тест, англ%.%)', '')
				t[i].address = 'https://www.voka.tv/' .. tab.data[i].id
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
-- debug_in_file(#t_pls .. '\n')