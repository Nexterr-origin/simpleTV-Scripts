-- видеоскрипт для плейлиста "smartKZ" https://telecom.kz (8/12/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: smartKZ_pls.lua
-- ## открывает подобные ссылки ##
-- https://sc.id-tv.kz:443/bollywood_hd
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://sc%.id%-tv%.kz') then return end
		if m_simpleTV.Control.CurrentAddress:match('PARAMS=smartKZ') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'SmartLabs/1.51652.472 (sml723x, SML-482) SmartSDK/1.5.63-rt-25 Qt/4.7.3 API/20121210'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local retAdr = inAdr:gsub('^https://','http://'):gsub(':443',''):gsub('%.m3u8','') .. '.m3u8'
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local extOpt = '$OPT:no-spu$OPT:INT-SCRIPT-PARAMS=smartKZ$OPT:adaptive-livedelay=60000$OPT:adaptive-minbuffer=120000$OPT:http-ext-header=X-Forwarded-For:176.222.190.211$OPT:http-user-agent=' .. userAgent
	local t0 = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local bw = w:match('BANDWIDTH=(%d+)')
			if bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t0[#t0 + 1] = {}
				t0[#t0].Id = bw
				t0[#t0].Name = bw .. ' кбит/с'
				t0[#t0].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t0 == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	local hash, t = {}, {}
		for i = 1, #t0 do
			if not hash[t0[i].Name] then
				t[#t + 1] = t0[i]
				hash[t0[i].Name] = true
			end
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('smartKZ_qlty') or 5000)
	t[#t + 1] = {}
	t[#t].Id = 5000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 10000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = retAdr .. extOpt
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
		t.ExtParams = {LuaOnOkFunName = 'smartKZSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128 + 8)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function smartKZSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('smartKZ_qlty', id)
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')