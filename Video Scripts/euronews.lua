-- видеоскрипт для сайта http://www.euronews.com (26/8/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- открывает ссылки:
-- http://www.euronews.com/live - English
-- http://fr.euronews.com/live - Français
-- http://de.euronews.com/live - Deutsch
-- http://it.euronews.com/live - Italiano
-- http://es.euronews.com/live - Español
-- http://pt.euronews.com/live - Português
-- http://ru.euronews.com/live - Русский
-- http://gr.euronews.com/live - Ελληνικά
-- http://hu.euronews.com/live - Magyar
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://%a+%.euronews%.com/live') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	inAdr = inAdr:gsub('//www%.', '//en.')
	local lng = inAdr:match('http?://(..)%.')
		if not lng then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local url = string.format('https://%s.euronews.com/api/watchlive.json?countryCode=%s&playerName=jw', lng, lng)
	url = url:gsub('//en%.', '//')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	answer = answer:gsub('%[%]', '""')
	local tab = json.decode(answer)
		if not tab or not tab.url then return end
	url = tab.url:gsub('^//', 'https://')
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	answer = answer:gsub('%[%]', '""')
	tab = json.decode(answer)
		if not tab or not tab.primary then return end
	local retAdr = tab.primary
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local base = retAdr:match('.+/')
	local i, t = 1, {}
		for w in string.gmatch(answer,'EXT%-X%-STREAM%-INF(.-%.m3u8.-)\n') do
			local adr = w:match('\n(.+)')
			local name = w:match('RESOLUTION=%d+x(%d+)')
			local br = w:match('BANDWIDTH=(%d+)')
			if adr and name and br then
				if not adr:match('^http') then
					adr = base .. adr:gsub('^[%.]*/', '')
				end
				br = tonumber(br)
				br = math.ceil(br / 10000) * 10
				t[i] = {}
				t[i].Id = br
				t[i].Name = name .. 'p' .. ' (' .. br .. ' кбит/с)'
				t[i].Address = adr
				i = i + 1
			end
		end
		if #t == 0 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('euronews_qlty') or 500000)
	local index = #t
	if #t > 1 then
		t[#t + 1] = {}
		t[#t].Id = 500000
		t[#t].Name = '▫ всегда высокое'
		t[#t].Address = t[#t - 1].Address
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
			t.ExtParams = {LuaOnOkFunName = 'euronewsSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function euronewsSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('euronews_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')