-- видеоскрипт для сайта https://sport5.by (17/11/23)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылки ##
-- https://sport5.by/live/bt5i
-- https://sport5.by/live/bt5
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://sport5%.by/live') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://sport5.by/live/'})
		if rc ~= 200 then return end
	local retAdr
	if inAdr:match('bt5$') then
		retAdr = answer:match('<video id="player1".-<source src="([^"]+)')
	elseif inAdr:match('bt5i$') then
		retAdr = answer:match('<video id="player2".-<source src="([^"]+)')
	end
		if not retAdr then return end
	local extOpt = ''
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-)\n') do
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and res then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = bw
				t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', retAdr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('sport5by_qlty') or 10000)
	t[#t + 1] = {}
	t[#t].Id = 10000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 50000
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
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		t.ExtParams = {LuaOnOkFunName = 'sport5bySaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function sport5bySaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('sport5by_qlty', id)
		end
	end
-- debug_in_file(t[index].Address .. '\n')