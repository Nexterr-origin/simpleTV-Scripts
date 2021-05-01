-- видеоскрипт для сайта https://otr-online.ru (25/12/19)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылку ##
-- https://otr-online.ru
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://otr%-online%.ru') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML,like Gecko) Chrome/79.0.3785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://otr.webcaster.pro/schedule'})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	inAdr = answer:match('"config=([^"]+)')
		if not inAdr then return end
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	inAdr = answer:match('<video_hd><!%[CDATA%[([^%]]+)')
		if not inAdr then return end
	local eend = inAdr:match('%?.-$') or ''
	rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local retAdr = answer:match('<track.-CDATA%[([^%]]+)')
		if not retAdr then return end
	retAdr = url_decode(retAdr .. eend)
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local extOpt = '$OPT:no-ts-cc-check$OPT:no-ts-trust-pcr$OPT:no-gnutls-system-trust$OPT:demux=adaptive,any$OPT:adaptive-use-access'
	local base = retAdr:match('.+/')
	local i, t, name, adr = 1, {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-%.m3u8.-)\n') do
			adr = w:match('\n(.+)')
				if not adr then break end
			name = w:match('RESOLUTION=%d+x(%d+)')
			if name and tonumber(name) > 300 then
				if not adr:match('^http') then
					adr = base .. adr:gsub('%.%./', ''):gsub('^/', '')
				end
				t[i] = {}
				t[i].Id = tonumber(name)
				t[i].Address = adr .. extOpt
				i = i + 1
			end
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
		for _, v in pairs(t) do
			if v.Id > 300 and v.Id <= 400 then
				v.Id = 360
			elseif v.Id > 400 and v.Id <= 530 then
				v.Id = 480
			elseif v.Id > 530 and v.Id <= 780 then
				v.Id = 720
			elseif v.Id > 780 then
				v.Id = 1080
			end
			v.Name = v.Id .. 'p'
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('otr_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr .. extOpt
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
			t.ExtParams = {LuaOnOkFunName = 'otrSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function otrSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('otr_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')