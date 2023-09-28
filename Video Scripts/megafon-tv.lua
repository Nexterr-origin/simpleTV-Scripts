-- видеоскрипт для плейлиста "megafon-tv" https://megafon.tv (28/9/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: megafon-tv_pls.lua
-- ## открывает подобные ссылки ##
-- https://play.megafon.tv/out/u/v1-video-6370563.mpd$OPT:adaptive-use-avdemux$OPT:avdemux-options-v={decryption_key=ef6fdcecdbaece3d2c95385ee54e4ec0}$OPT:avdemux-options-a={decryption_key=2233171a1e45cacfc1428d9398f0c1a4}
-- https://megafon.tv/PTBITWlsVE53SVRaaVpEW...
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://play%.megafon%.tv/out')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://megafon%.tv')
		then
		 return
		end
	if m_simpleTV.Control.CurrentAddress:match('PARAMS=megafon') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if inAdr:match('^https?://megafon%.tv') then
		inAdr = inAdr:gsub('^https?://megafon%.tv/', ''):gsub('$OPT.+', '')
		inAdr = decode64(inAdr)
		inAdr = string.reverse(inAdr)
		inAdr = decode64(inAdr)
	end
	local url = inAdr:gsub('$OPT.+', '')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then return end
	local extOpt = '$OPT:INT-SCRIPT-PARAMS=megafon$OPT:no-spu$OPT:adaptive-init-on-each-segment'
	local t = {}
		for w in answer:gmatch('<Representation[^>]+frameRate[^>]+>') do
			local bw = w:match('bandwidth="(%d+)')
			local res = w:match('height="(%d+)')
			if res and bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', inAdr, bw, extOpt)
			end
		end
		if #t == 0 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('megafon_qlty') or 10000)
	t[#t + 1] = {}
	t[#t].Id = 10000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 20000
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
		t.ExtParams = {LuaOnOkFunName = 'megafonSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function megafonSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('megafon_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')