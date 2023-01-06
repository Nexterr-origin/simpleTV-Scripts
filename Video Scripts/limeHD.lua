-- видеоскрипт для плейлиста "LimeHD" https://limehd.tv (6/1/23)
-- Copyright © 2017-2023 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: LimeHD_pls.lua
-- расширение дополнения httptimeshift: limehd-timeshift_ext.lua
-- ## открывает подобные ссылки ##
-- https://limehd.tv/1
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://limehd.tv/%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.limehd then
		m_simpleTV.User.limehd = {}
	end
	m_simpleTV.User.limehd.url_archive = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:102.0) Gecko/20100101 Firefox/102.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local id = inAdr:match('%d+')
	local url = decode64('aHR0cHM6Ly9hcGkuaXB0djIwMjEuY29tL3YxL3N0cmVhbXMv') .. id
	local headers = decode64('WC1BY2Nlc3MtS2V5OiAxMGFhMDkxMTQ1ODhhNWY3NTBlYWVkNWU5ZGU1MzcwNGM4NThlMTQ0')
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
		if rc ~= 200 then return end
	local retAdr = answer:match('"playlist_url":"([^"]+)')
		if not retAdr then return end
	m_simpleTV.User.limehd.url_archive = answer:match('"archive_url":"([^"]+)')
	local extOpt = '$OPT:no-spu$OPT:adaptive-use-avdemux'
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		if rc ~= 200 then return end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local adr = w:match('\n(.+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if bw and adr then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = bw
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				else
					t[#t].Name = bw .. ' кбит/с'
				end
				if not adr:match('^http') then
					adr = retAdr:match('.+/') .. adr
				end
				t[#t].Address = string.format('%s$OPT:adaptive-logic=highest$OPT:adaptive-max-bw=%s%s', adr, bw, extOpt)
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('limehd_qlty') or 30000)
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 100000
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
		t.ExtParams = {LuaOnOkFunName = 'limehdSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function limehdSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('limehd_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
