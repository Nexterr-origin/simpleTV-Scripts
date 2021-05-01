-- скрапер TVS для загрузки плейлиста "acesearch" http://acestream.net (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- Acestream
-- ## время последней проверки доступности канала, в часах ##
local updated = 3
-- ## ссылки вида http://ipadress:YYYY/ace/getstream?infohash=XXXXXX&.mp4 ##
local ace_adrPort = ''
-- адрес:порт (например '127.0.0.1:6878')
-- '' - по умолчанию
-- ## категории ##
local group = 1
-- 0 - нет
-- 1 - да
-- ## переименовать каналы ##
local filter = {
	{'CCTV-Русский', 'CGTN Русский'},
	{'Архыз 24', 'Архыз 24 (Черкесск)'},
	{'Belarus 24', 'Беларусь 24'},
	{'Наука', 'Наука UA'},
	{'Наука 2.0', 'Наука'},
	{'AMC', 'Hollywood'},
	}
-- ##
	module('acesearch_pls', package.seeall)
	local my_src_name = 'acesearch'
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
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\acesearch.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 0, show_progress = 1, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 1}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 0, AutoSearch = 1, AutoNumber = 0, NumberM3U = 0, GetSettings = 0, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, color = color, showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:83.0) Gecko/20100101 Firefox/83.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 20000)
		local url = decode64('aHR0cHM6Ly9hcGkuYWNlc3RyZWFtLm1lL2FsbD9hcGlfdmVyc2lvbj0xLjAmYXBpX2tleT10ZXN0X2FwaV9rZXk')
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		answer = answer:gsub(string.char(239, 187, 191), '')
		answer = answer:gsub('%[%]', '""')
		answer = answer:gsub('\\', '\\\\')
		answer = answer:gsub('\\"', '\\\\"')
		answer = answer:gsub('\\/', '/')
		require 'json'
		local tab = json.decode(answer)
			if not tab then return end
		if updated == 0 then
			updated = 1000
		end
		local t, i, h = {}, 1, 1
		local cat
			while tab[h] do
				if tab[h].availability
					and tab[h].availability_updated_at
					and tab[h].availability == 1
					and (os.time() - tab[h].availability_updated_at) < 3600 * updated
				then
					t[i] = {}
					local name = tab[h].name:gsub('\\"', '"')
					t[i].name = unescape3(name)
					if ace_adrPort ~= '' then
						t[i].address = string.format('http://%s/ace/getstream?infohash=%s&.mp4', ace_adrPort, tab[h].infohash)
					else
						t[i].address = 'torrent://INFOHASH=' .. tab[h].infohash
					end
					if group ~= 0 then
						if tab[h].categories then
							cat = tab[h].categories[1] or 'неизвестно'
						else
							cat = 'неизвестно'
						end
						t[i].group = unescape3(cat)
					end
					i = i + 1
				end
				h = h + 1
			end
				if i == 1 then return end
		local cleanNamesTab = {
				'https?://%S+',
				'%(%)',
				'%%5B%%5D',
				'%(PlayList 24%)',
				'Резерв %d',
				'%(резерв%)',
				'%(%d:%d%)',
				'%(на модерации%)',
				'!!!',
				'%s!$',
				'%(allfon%)',
				'%(allfon_tv%)',
				'^%.$', 'неизвестно',
				'%(alfabass%-tv%)',
				'%(altabass%-tv%)',
			}
			local function cleanNames(name)
				for i = 1, #cleanNamesTab do
					name = name:gsub(cleanNamesTab[i], '')
				end
			 return name
			end
			for i = 1, #t do
				t[i].name = cleanNames(t[i].name)
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