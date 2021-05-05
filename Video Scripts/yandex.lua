-- видеоскрипт для плейлиста "Yandex" https://yandex.ru (5/5/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: yandex_pls.lua
-- расширение дополнения httptimeshift: yandex-timesift_ext.lua
-- ## открывает подобные ссылки ##
-- https://strm.yandex.ru/kal/bigasia/bigasia0.m3u8
-- https://strm.yandex.ru/kal/ohotnik/ohotnik0_169_480p.json/index-v1-a1.m3u8
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://strm%.yandex%.ru/k') then return end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=yandex_tv')
			or m_simpleTV.Control.CurrentAddress:match('decryption_key')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=yandex_tv$OPT:no-gnutls-system-trust'
	local url = inAdr:gsub('_%d+_%d+p%.json.-$', '.m3u8')
	url = url:gsub('%$OPT:.-$', '')
	url = url:gsub('%?.-$', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local host = url:match('.+/')
	if answer:match('%.json') then
		host = url:match('https?://[^/]+')
	end
	answer = answer .. '\n'
	local t, i = {}, 1
	local name, adr
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8.-)\n') do
			adr = w:match('\n(.+)')
				if not adr then break end
			if not adr:match('redundant') then
				name = w:match('RESOLUTION=%d+x(%d+)')
				adr = adr:gsub('[%?&]+.-$', '')
				t[i] = {}
				t[i].Name = name .. 'p'
				t[i].Address = host .. adr .. extOpt
				t[i].Id = tonumber(name)
				i = i + 1
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = url .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
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
