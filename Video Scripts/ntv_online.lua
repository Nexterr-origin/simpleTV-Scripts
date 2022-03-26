-- видеоскрипт для сайта http://www.ntv.ru (26/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылки ##
-- https://www.ntv.ru/air
-- https://www.ntv.ru/air/ntvseries
-- https://www.ntv.ru/air/ntvlaw
-- https://www.ntv.ru/air/ntvstyle
-- https://www.ntv.ru/air/ntvhit
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://www%.ntv%.ru/air') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://www.ntv.ru/air'})
		if rc ~= 200 then return end
	answer = answer:gsub('%s', '')
	local retAdr
	if inAdr:match('ntvseries') then
		retAdr = answer:match('serialHlsURL=[\'"]([^\'?"]+)')
	elseif inAdr:match('ntvlaw') then
		retAdr = answer:match('pravoHlsURL=[\'"]([^\'?"]+)')
	elseif inAdr:match('ntvstyle') then
		retAdr = answer:match('styleHlsURL=[\'"]([^\'"]+)')
	elseif inAdr:match('ntvhit') then
		retAdr = answer:match('hitHlsURL=[\'"]([^\'?"]+)')
	else
		retAdr = answer:match('hdHlsURL=[\'"]([^\'?"]+)')
	end
		if not retAdr then return end
	retAdr = retAdr:gsub('^(.-/)airstream(%d%d).-(/.-)$', '%1/smil:ntvair%2.smil%3')
	retAdr = retAdr:gsub('hd_ntvair001', 'smil:ntvair001_hd')
	retAdr = retAdr:gsub('^//', 'https://')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local base = retAdr:match('.+/')
	local i, t0, name, adr = 1, {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			adr = w:match('\n(.+)')
			btr = w:match('BANDWIDTH=(%d+)')
			name = w:match('RESOLUTION=%d+x(%d+)')
				if not adr or not name or not btr then break end
			name = tonumber(name)
			if name > 300 then
				if not adr:match('^http') then
					adr = base .. adr:gsub('%.%./', ''):gsub('^/', '')
				end
				t0[i] = {}
				t0[i].Id = name
				t0[i].Address = adr
				t0[i].btr = tonumber(btr)
				i = i + 1
			end
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
		for _, v in pairs(t0) do
			if v.Id > 300 and v.Id <= 400 then
				v.Id = 360
			elseif v.Id > 400 and v.Id <= 530 then
				v.Id = 480
			elseif v.Id > 530 and v.Id <= 600 then
				v.Id = 576
			elseif v.Id > 600 and v.Id <= 780 then
				v.Id = 720
			elseif v.Id > 780 then
				v.Id = 1080
			end
			v.Name = v.Id .. 'p'
		end
	table.sort(t0, function(a, b) return a.btr > b.btr end)
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Name] then
				t[#t + 1] = t0[i]
				hash[t0[i].Name] = true
			end
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('ntv_qlty') or 5000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 5000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
		t[#t + 1] = {}
		t[#t].Id = 10000
		t[#t].Name = '▫ адаптивное'
		t[#t].Address = retAdr
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
			t.ExtParams = {LuaOnOkFunName = 'ntvSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function ntvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('ntv_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
