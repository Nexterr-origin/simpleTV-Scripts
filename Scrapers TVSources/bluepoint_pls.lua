-- скрапер TVS для загрузки плейлиста "bluepoint" http://bptv.info (25/1/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\bluepoint.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko) MAG200 stbapp ver: 2 rev: 234 Safari/533.3')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local url = decode64('TnJyZ25JcGJ3anVyMTZIZnZxeVhmWnQ2SjFiTHJVSlVobFRoWVB1QXBrM1VJb1JpRkJpcnJRRFZGdkY0eU5JWD15ZWtfaXBhJjE9ZGlfdG5laWxjJj8vbmlnb2wvaXBhL2VyYXdlbGRkaW12dC9tb2MudnR0bmlvcGV1bGIueXRyYW1zLy86cHR0aA')
		local rc, answer = m_simpleTV.Http.Request(session, {url = string.reverse(url)})
			if rc ~= 200 then return end
		local authkey = answer:match('"authkey":"([^"]+)')
			if not authkey then return end
		url = decode64('PXlla2h0dWEmMD15ZWtfc3NlcyZOcnJnbklwYndqdXIxNkhmdnF5WGZadDZKMWJMclVKVWhsVGhZUHVBcGszVUlvUmlGQmlyclFEVkZ2RjR5TklYPXlla19pcGEmdXI9Z25hbCYxPWRpX3RuZWlsYyZnYW09ZWNpdmVkJjA9dGZpaHNlbWl0JjUxPWVub3plbWl0Py90c2lsL2xlbm5haGMvaXBhL2VyYXdlbGRkaW12dC9tb2MudnR0bmlvcGV1bGIueXRyYW1zLy86cHR0aA')
		rc, answer = m_simpleTV.Http.Request(session, {url = string.reverse(url) .. authkey})
			if rc ~= 200 then return end
		local t = {}
			for w in answer:gmatch('<item>.-</item>') do
				local name = w:match('<name>([^<]+)')
				local cid = w:match('<id>([^<]+)')
				if name and cid then
					local url = w:match('<url>([^<]+)')
					local archive = ''
					if url and url:match('/tvmiddleware/') then
						t[#t +1] = {}
						t[#t].name = name:gsub(' %(TEST%)', '')
						local days = w:match('<max_archive_duration>(%d+)')
						if days and tonumber(days) > 0 then
							t[#t].RawM3UString = 'catchup="append" catchup-days="' .. days .. '"' .. ' catchup-source="&timestamp=${start}"'
							archive = '?archive=true'
						end
						t[#t].address = 'http://bluepoint/' .. cid .. archive
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