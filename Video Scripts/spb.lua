-- видеоскрипт для плейлиста "spb" https://ru.spbtv.com (31/7/24)
-- Copyright © 2017-2024 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: spb_pls.lua
-- ## открывает подобные ссылки ##
-- https://ru.spbtv.com/61a11ebb-735a-4c15-bffd-874161ee4cb4
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ru%.spbtv%.com/.+') then return end
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
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:129.0) Gecko/20100101 Firefox/129.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local channel = inAdr:match('spbtv%.com/(.+)')
	local client_id = '3e28685c-fce0-4994-9d3a-1dad2776e16a'
	local function getToken()
		local rc, answer = m_simpleTV.Http.Request(session, {url = 'https://api.spbtv.com/v1/devices.json?client_id=' .. client_id .. '&client_version=1.7.0.259&timezone=10800&locale=ru-RU&device_id=00000000-0000-0000-0000-000000000000&type=browser&model=Chrome&os_name=Windows&os_version=', method = 'post'})
			if rc ~= 201 then return end
	 return answer:match('"device_token":"([^"]+)')
	end
	if not m_simpleTV.User.spb.token then
		local token = getToken()
				if not token then
					m_simpleTV.User.spb = nil
					m_simpleTV.Http.Close(session)
				 return
				end
			m_simpleTV.User.spb.token = token
		end
	local url = 'https://api.spbtv.com/v1/channels/' .. channel
		.. '/stream.json?client_id=' .. client_id .. '&client_version=4.4.3.2460&locale=ru-RU&timezone=10800&audio_codec=mp4a&device_token='.. m_simpleTV.User.spb.token ..'&protocol=hls&screen_height=231&screen_width=1152&video_codec=h264&drm=spbtvcas'
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
	local extOpt = ''
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
