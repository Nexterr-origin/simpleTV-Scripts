-- видеоскрипт для плейлиста "beetvkz" https://beetv.kz (26/5/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: beetvkz_pls.lua
-- ## открывает подобные ссылки ##
-- http://edge05.beetv.kz/btv/SWM/FOX/FOX.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('https?://edge%d+%.beetv%.kz')then return
		end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=beetvkz') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New(userAgent, proxy, false)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=beetvkz'
	local function streamsTab(answer, extOpt)
		local t = {}
			for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
				local bw = w:match('BANDWIDTH=(%d+)')
				local res = w:match('RESOLUTION=%d+x(%d+)')
				if bw then
					bw = tonumber(bw)
					bw = math.ceil(bw / 100000) * 100
					t[#t + 1] = {}
					t[#t].Id = bw
					if res then
						t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
					else
						t[#t].Name = bw .. ' кбит/с'
					end
					t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', inAdr, bw, extOpt)
				end
			end
	 return t
	end
	function beetvkzSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('beetvkz_qlty', id)
	end
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local t = streamsTab(answer, extOpt)
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = inAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('beetvkz_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 30000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = inAdr .. extOpt
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
		t.ExtParams = {LuaOnOkFunName = 'beetvkzSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 +8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')