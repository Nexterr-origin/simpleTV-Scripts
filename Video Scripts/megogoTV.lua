-- видеоскрипт для плейлиста "megogoTV" http://megogo.ru (29/9/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: megogoTV_pls.lua
-- расширение дополнения httptimeshift: megogotv-timeshift_ext.lua
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - megogo
-- ## открывает подобные ссылки ##
-- http://TVmegogo/1352261
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://TVmegogo/%d') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'json'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.tvMegogo then
		m_simpleTV.User.tvMegogo = {}
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:81.0) Gecko/20100101 Firefox/81.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function GetSign(r)
		r = r:gsub('&', '')
		r = r .. '5066390625'
	 return '&sign=' .. m_simpleTV.Common.CryptographicHash(r) .. '_android_tvbox_j6'
	end
	local function GetToken()
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then return end
		local ret, login, pass = pm.GetTestPassword('megogo', 'megogo', true)
			if not login or not pass or login == '' or pass == '' then return end
		local strSign = 'login=' .. login .. '&password=' .. pass .. '&remember=1'
		local sign = GetSign(strSign)
		login = m_simpleTV.Common.toPercentEncoding(login)
		pass = m_simpleTV.Common.toPercentEncoding(pass)
		local str = 'login=' .. login .. '&password=' .. pass .. '&remember=1'
		local url = 'https://api.megogo.net/v1/auth/login'
		local body = str .. sign
		local headers = 'Content-Type: application/x-www-form-urlencoded'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab
				or not tab.data
				or not tab.data.tokens.remember_me_token
			then
			 return
			end
	 return '&token=' .. tab.data.tokens.remember_me_token
	end
	local function GetAddress(id)
		local strSign = 'video_id=' .. id .. m_simpleTV.User.tvMegogo.token
		local sign = GetSign(strSign)
		local url = 'https://api.megogo.net/v1/stream?' .. strSign .. sign
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		local tab = json.decode(answer)
			if not tab
				or not tab.data
				or not tab.data.src
				or tab.data.src == ''
			then
			 return
			end
	 return tab.data.src
	end
	if not m_simpleTV.User.tvMegogo.token then
		local token = GetToken()
			if not token then return end
		m_simpleTV.User.tvMegogo.token = token
	end
	inAdr = inAdr:match('TVmegogo/(%d+)')
	local retAdr = GetAddress(inAdr)
		if not retAdr then
			m_simpleTV.User.tvMegogo.token = nil
		 return
		end
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
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
			adr = adr:gsub('^[%c%s]*(.-)[%c%s]*$', '%1')
			t[i].Address = adr
			i = i + 1
		end
		if i == 1 then
			m_simpleTV.Control.CurrentAddress = retAdr
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('tvMegogo_qlty') or 5000)
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
			if m_simpleTV.User.paramScriptForSkin_buttonOk then
				t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
			end
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
			t.ExtParams = {LuaOnOkFunName = 'tvMegogoSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function tvMegogoSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('tvMegogo_qlty', id)
		end
	end
-- debug_in_file(t[index].Address .. '\n')