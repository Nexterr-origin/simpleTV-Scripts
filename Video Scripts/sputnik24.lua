-- видеоскрипт для плейлиста "Sputnik24" https://sputnik24.tv (5/8/24)
-- Copyright © 2017-2024 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: sputnik24_pls.lua
-- ## открывает подобные ссылки ##
-- https://sputnik24.tv/smotret/big-planet-hd?171
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://sputnik24%.tv')
		then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local num = inAdr:match('(%d+)$')
		if not num then return end
	local link = 'https://api1.sputnik24.tv/api/v2/get-playlist-channel/'.. num ..'?sig=undefined'
	local headers = 'Content-Type: application/json;charset=utf-8\nX-Ref: https://sputnik24.tv'
	local rc, answer = m_simpleTV.Http.Request(session, {url = link, headers = headers})
		if rc ~= 200 then return end
	local retAdr = answer:match('channel_source":"([^"]+)')
		if not retAdr then return end
	retAdr = retAdr:gsub('\\/', '/')
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local t = {}
	local base = retAdr:match('.+/')
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local adr = w:match('\n(.+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if adr and res then
				res = tonumber(res)
				t[#t + 1] = {}
				t[#t].Id = res
				t[#t].Name = res .. 'p'
				t[#t].Address = base .. adr
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('sputnik24_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 30000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = retAdr
	local index = #t
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
		t.ExtParams = {LuaOnOkFunName = 'sputnik24SaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function sputnik24SaveQuality(obj, id)
		m_simpleTV.Config.SetValue('sputnik24_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')