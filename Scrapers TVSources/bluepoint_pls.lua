-- скрапер TVS для загрузки плейлиста "bluepoint" http://bptv.info (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: bluepoint.lua
-- расширение дополнения httptimeshift: bluepoint-timeshift_ext.lua
-- ## переименовать каналы ##
local filter = {
	{'Кино 24', 'KINO 24'},
	{'Pro100TV', 'Про100ТВ'},
	{'HD-Life', 'HDL'},
	{'O2', 'О2ТВ'},
	{'RT News HD', 'Russia Today'},
	{'Russia Today Documentary', 'RTД'},
	{'ЕГЭ ТВ', 'ЕГЭ'},
	{'ТНТ-Music', 'ТНТ Music'},
	{'ТЕЛЕКАНАЛ 360', '360 Подмосковье (Москва)'},
	{'ТРК Футбол 1', 'Футбол 1'},
	{'ТРК Футбол 2', 'Футбол 2'},
	{'ТНТ-Comedy', 'ТНТ4'},
	{'Первый.', 'Первый'},
	{'Игра', 'Матч! Игра'},
	{'Боец', 'Матч! Боец'},
	{'Nat Geo', 'National Geographic'},
	{'Матч! Футбол HD', 'Матч! Футбол 1'},
	}
-- ##
	module('bluepoint_pls', package.seeall)
	local my_src_name = 'bluepoint'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\bluepoint.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('mag')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 30000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2lwdHYuYmx1ZXBvaW50dHYuY29tL2FwaS90dm1pZGRsZXdhcmUvYXBpL2xvZ2luLz9kZXZpY2VfdWlkPWEwOmIxOmMyOmQzOmU0OmY1JmRldmljZV9tb2RlbD1Nb2RlbCUyMEEmZGV2aWNlX3NlcmlhbD1TTjowMTAxMTk3MCZkZXZpY2U9bWFnJmNsaWVudF9pZD0xJmFwaV9rZXk9WElOeTRGdkZWRFFycmlCRmlSb0lVM2twQXVQWWhUbGhVSlVyTGIxSjZ0WmZYeXF2Zkg2MXJ1andicEluZ3JyTiZzZXNzX2tleT0mbGFuZz1ydSZhdXRoa2V5PTAmYWJvbmVtZW50PSZwYXNzd29yZD0')})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local authkey = answer:match('<authkey>([^<]+)')
			if not authkey then
				m_simpleTV.Http.Close(session)
			 return
			end
		rc, answer = m_simpleTV.Http.Request(session, {url = decode64('aHR0cDovL2lwdHYuYmx1ZXBvaW50dHYuY29tL2FwaS90dm1pZGRsZXdhcmUvYXBpL2NoYW5uZWwvbGlzdC8/dGltZXpvbmU9MTUmdGltZXNoaWZ0PTAmZGV2aWNlPW1hZyZjbGllbnRfaWQ9MSZsYW5nPXJ1JmFwaV9rZXk9WElOeTRGdkZWRFFycmlCRmlSb0lVM2twQXVQWWhUbGhVSlVyTGIxSjZ0WmZYeXF2Zkg2MXJ1andicEluZ3JyTiZzZXNzX2tleT0wJmF1dGhrZXk9') .. authkey})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local t, i = {}, 1
			for w in answer:gmatch('<item>.-</item>') do
				local name = w:match('<name>([^<]+)')
				local cid = w:match('<id>([^<]+)')
					if not name or not cid then break end
				local url = w:match('<url>([^<]+)')
				local archive = ''
				if url and url:match('/tvmiddleware/') then
					t[i] = {}
					t[i].name = name:gsub(' %(TEST%)', '')
					local days = w:match('<max_archive_duration>(%d+)')
					if days and tonumber(days) > 0 then
						t[i].RawM3UString = 'catchup="append" catchup-days="' .. days .. '"'
											.. ' catchup-source="&timestamp=${start}"'
						archive = '?archive=true'
					end
					t[i].address = 'http://bluepoint/' .. cid .. archive
					i = i + 1
				end
			end
			if i > 50 then
				if not m_simpleTV.User then
					m_simpleTV.User = {}
				end
				if not m_simpleTV.User.bluepoint then
					m_simpleTV.User.bluepoint = {}
				end
				m_simpleTV.User.bluepoint.authkey = authkey
			else
			 return
			end
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