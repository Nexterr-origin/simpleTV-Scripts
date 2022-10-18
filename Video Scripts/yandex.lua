-- видеоскрипт для плейлиста "Yandex+" https://yandex.ru (18/10/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: yandex+_pls.lua
-- расширение дополнения httptimeshift: yandex-timesift_ext.lua
-- ## открывает подобные ссылки ##
-- https://strm.yandex.ru/kal/rtg/rtg0.m3u8
-- https://strm.yandex.ru/kal/sony_channel/manifest.mpd ...
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://strm%.yandex%.ru/k') then return end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=yandex_tv') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=yandex_tv'
	local url = inAdr:gsub('_%d+_%d+p%.json.-$', '.m3u8')
	url = url:gsub('%$OPT:.-$', '')
	url = url:gsub('%?.-$', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local function streamsTab(answer)
		local t0 = {}
			for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
				local qlty = w:match('RESOLUTION=%d+x(%d+)')
				if qlty then
					qlty = tonumber(qlty)
					t0[#t0 + 1] = {}
					t0[#t0].Name = qlty .. 'p'
					t0[#t0].Id = qlty
					t0[#t0].Address = url .. '$OPT:adaptive-maxheight=' .. qlty .. '$OPT:adaptive-logic=highest' .. extOpt
				end
			end
			if #t0 > 0 then
			 return t0
			end
		url = inAdr
			for w in answer:gmatch('<Representation[^>]+height=[^>]+>') do
				local qlty = w:match('height="(%d+)')
				if qlty then
					qlty = tonumber(qlty)
					t0[#t0 + 1] = {}
					t0[#t0].Name = qlty .. 'p'
					t0[#t0].Id = qlty
					t0[#t0].Address = url .. '$OPT:adaptive-maxheight=' .. qlty .. '$OPT:adaptive-logic=highest' .. extOpt
				end
			end
	 return t0
	end
	local t0 = streamsTab(answer)
		if #t0 == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr .. extOpt
		 return
		end
	table.sort(t0, function(a, b) return a.Id < b.Id end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Id] then
				t[#t + 1] = t0[i]
				hash[t0[i].Id] = true
			end
		end
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('yandex_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = url .. extOpt
		index = #t
			for i = 1, #t do
				if t[i].Id >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].Id > lastQuality then
				index = index - 1
			end
		end
		if m_simpleTV.Control.MainMode == 0 then
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'yandexSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function yandexSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('yandex_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')
