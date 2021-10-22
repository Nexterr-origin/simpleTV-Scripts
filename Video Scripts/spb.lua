-- видеоскрипт для плейлиста "spb" https://tv.spbtv.com + https://ru.spbtv.com (22/10/21)
-- ## необходим ##
-- скрапер TVS: spb_pls.lua
-- ## открывает подобные ссылки ##
-- https://ru.spbtv.com/aHR0cHM6Ly9hcGkuc3BidHYuY29tL3Yx/eb78f76a-4456-4645-9ed7-13a2d685b0c9
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ru%.spbtv%.com/%w+/.+') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.spb then
		m_simpleTV.User.spb = {}
	end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (SMART-TV; Linux; Tizen 4.0.0.2) AppleWebkit/605.1.15 (KHTML, like Gecko) SamsungBrowser/9.2 TV Safari/605.1.15')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local api, channel = inAdr:match('spbtv%.com/(%w+)/([^&$]*)')
	local function getToken(apiUrl)
		m_simpleTV.User.spb.client_id = decode64('NjY3OTc5NDItZmY1NC00NmNiLWExMDktM2JhZTdjODU1Mzcw')
		local rc, answer = m_simpleTV.Http.Request(session, {url = apiUrl .. '/devices.json?client_id=' .. m_simpleTV.User.spb.client_id .. decode64('JmNsaWVudF92ZXJzaW9uPTEuNy4wLjI1OSZ0aW1lem9uZT0xMDgwMCZsb2NhbGU9cnUtUlUmZGV2aWNlX2lkPTAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCZ0eXBlPWJyb3dzZXImbW9kZWw9Q2hyb21lJm9zX25hbWU9V2luZG93cyZvc192ZXJzaW9uPQ=='), method = 'post'})
			if rc ~= 201 then return end
	 return answer:match('"device_token":"([^"]+)')
	end
	api = decode64(api)
	local token
	if api:match('api%.spbtv') then
		if not m_simpleTV.User.spb.token1 then
			local token1 = getToken(api)
				if not token1 then
					m_simpleTV.User.spb = nil
					m_simpleTV.Http.Close(session)
				 return
				end
			m_simpleTV.User.spb.token1 = token1
		end
		token = m_simpleTV.User.spb.token1
	else
		if not m_simpleTV.User.spb.token2 then
			local token2 = getToken(api)
				if not token2 then
					m_simpleTV.User.spb = nil
					m_simpleTV.Http.Close(session)
				 return
				end
			m_simpleTV.User.spb.token2 = token2
		end
		token = m_simpleTV.User.spb.token2
	end
	local url = api .. '/channels/' .. channel
		.. '/stream.json?client_id=' .. m_simpleTV.User.spb.client_id
		.. '&protocol=hls'
		.. decode64('JmNsaWVudF92ZXJzaW9uPTEuNy4wLjMwNiZ0aW1lem9uZT0xMDgwMCZsb2NhbGU9cnUtUlUmdmlkZW9fY29kZWM9aDI2NCZhdWRpb19jb2RlYz1tcDRhJmRybT1zcGJ0dmNhcyZzY3JlZW5fd2lkdGg9MTI4MCZzY3JlZW5faGVpZ2h0PTgwMCZkZXZpY2VfdG9rZW49')
		.. token
	local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Accept: application/json'})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.User.spb = nil
		 return
		end
	local retAdr = answer:match('"url":"([^"]+)')
		if not retAdr then
			m_simpleTV.User.spb = nil
		 return
		end
	retAdr = retAdr:gsub('https://', 'http://'):gsub('%?.-$', '')
	rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	local extOpt = '$OPT:adaptive-livedelay=60000$OPT:adaptive-minbuffer=60000'
	local base = retAdr:match('.+/')
	local t, i = {}, 1
		for res, br, res1, adr in answer:gmatch('EXT%-X%-STREAM%-IN([%C]+)[:,]BANDWIDTH=(%d+)([%C]*).-\n(.-)\n') do
			t[i] = {}
			br = tonumber(br)
			br = math.ceil(br / 10000) * 10
			res = res:match('RESOLUTION=(%d+x%d+)')
				or res1:match('RESOLUTION=(%d+x%d+)')
			if res then
				t[i].Name = res .. ' (' .. br .. ' кбит/с)'
				res = res:match('x(%d+)')
				t[i].Id = tonumber(res)
			else
				t[i].Name = 'аудио (' .. br .. ' кбит/с)'
				t[i].Id = 0
			end
			if not adr:match('^%s*http') then
				adr = base .. adr:gsub('^[%s/%.]+', '')
			end
			adr = adr:gsub('%-vid%-', '')
			adr = adr:gsub('^[%c%s]*(.-)[%c%s]*$', '%1')
			t[i].Address = adr:gsub('https://', 'http://'):gsub('%?.-$', '') .. extOpt
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('spb_qlty') or 5000)
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
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'spbSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function spbSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('spb_qlty', id)
		end
	end
-- debug_in_file(t[index].Address .. '\n')
