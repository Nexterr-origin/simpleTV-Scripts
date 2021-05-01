-- видеоскрипт для плейлиста "Смотрёшка" ("Смотрёшка 2") https://smotreshka.tv (30/12/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- расширение дополнения httptimeshift: smotreshka-timeshift_ext.lua
-- скрапер TVS: smotreshka_pls.lua (smotreshka2_pls.lua)
-- ## авторизация ##
-- логин, пароль установить в 'Password Manager', для id - smotreshka (smotreshka2)
-- ## открывает подобные ссылки ##
-- https://smotreshka.tv/5aead81921887f04724d1780
-- https://smotreshka2.tv/535f7f1eebf8c403a10050bb
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://smotreshka[%d]*%.tv/%x') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	require 'json'
	local url = 'https://fe.smotreshka.tv/playback-info/' .. inAdr:match('%.tv/(%x+)')
	local function showError(str, id_pm)
		local t = {text = id_pm .. ' ошибка: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:85.0) Gecko/20100101 Firefox/85.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.smotreshka then
		m_simpleTV.User.smotreshka = {}
	end
	local function getSession(id_pm)
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then return end
		local ret, login, pass = pm.GetTestPassword(id_pm, 'Смотрёшка ' .. id_pm, true)
			if not login
				or not pass
				or login == ''
				or pass == ''
			then
			 return
			end
		login = m_simpleTV.Common.toPercentEncoding(login)
		pass = m_simpleTV.Common.toPercentEncoding(pass)
		local body = 'email=' .. login .. '&password=' .. pass
		local headers = 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8\nReferer: https://fe.smotreshka.tv'
		local rc, answer = m_simpleTV.Http.Request(session, {body = body, url = 'https://fe.smotreshka.tv/login', method = 'post', headers = headers})
			if rc ~= 200 then return end
		local tab = json.decode(answer)
			if not tab
				or not tab.session
			then
			 return
			end
	 return tab.session
	end
	local smotreshka_session
	local id_pm = inAdr:match('^https?://(.-)%.tv')
	if id_pm == 'smotreshka' then
		if not m_simpleTV.User.smotreshka.session then
			m_simpleTV.User.smotreshka.session = getSession(id_pm)
				if not m_simpleTV.User.smotreshka.session then
					showError('[1]\nНеправильный логин или пароль', id_pm)
					m_simpleTV.Http.Close(session)
				 return
				end
		end
		smotreshka_session = m_simpleTV.User.smotreshka.session
	end
	if id_pm == 'smotreshka2' then
		if not m_simpleTV.User.smotreshka.session_2 then
			m_simpleTV.User.smotreshka.session_2 = getSession(id_pm)
				if not m_simpleTV.User.smotreshka.session_2 then
					showError('[2]\nНеправильный логин или пароль', id_pm)
					m_simpleTV.Http.Close(session)
				 return
				end
		end
		smotreshka_session = m_simpleTV.User.smotreshka.session_2
	end
	url = url .. '?session=' .. smotreshka_session
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			m_simpleTV.User.smotreshka = nil
			local err
			if answer then
				err = answer:match('"msg":"([^"]+)')
			end
			err = err or 'продлите подписку'
			showError('[3]\n' .. err, id_pm)
		 return
		end
	answer = answer:gsub('%[%]', '""')
	local tab = json.decode(answer)
		if not tab
			or not tab.languages
			or not tab.languages[1].renditions[1]
		then
			m_simpleTV.User.smotreshka = nil
			showError('[4]', id_pm)
		 return
		end
	local t, i = {}, 1
	local lastQuality, auto, retAdr
	if tab.languages[1].renditions[1].id ~= 'Auto' then
		local caption
		auto = false
			while tab.languages[1].renditions[i] do
				t[i] = {}
				caption = tab.languages[1].renditions[i].caption
				t[i].Name = caption
				caption = caption:gsub('Max4k', '2260')
				caption = caption:match('%d+') or 0
				t[i].Id = tonumber(caption)
				t[i].Address = tab.languages[1].renditions[i].url:gsub('u0026', '&')
				i = i + 1
			end
			if #t == 0 then
				showError('[5]', id_pm)
			 return
			end
		lastQuality = tonumber(m_simpleTV.Config.GetValue('smotreshka_qlty_noAuto')) or 5000
	else
		retAdr = tab.languages[1].renditions[1].url:gsub('u0026', '&')
		rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local base = retAdr:match('.+/')
		auto = true
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
				t[i].Address = adr
				i = i + 1
			end
			if #t == 0 then
				m_simpleTV.Control.CurrentAddress = retAdr
			 return
			end
		lastQuality = tonumber(m_simpleTV.Config.GetValue('smotreshka_qlty')) or 5000
	end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local index = #t
	if #t > 1 then
		if auto == true then
			t[#t + 1] = {}
			t[#t].Id = 5000
			t[#t].Name = '▫ всегда высокое'
			t[#t].Address = t[#t - 1].Address
			t[#t + 1] = {}
			t[#t].Id = 10000
			t[#t].Name = '▫ адаптивное'
			t[#t].Address = retAdr
		end
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
			if auto == true then
				t.ExtParams = {LuaOnOkFunName = 'smotreshkaSaveQuality'}
			else
				t.ExtParams = {LuaOnOkFunName = 'smotreshkaSaveQuality_noAuto'}
			end
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function smotreshkaSaveQuality(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('smotreshka_qlty', tostring(id))
		end
	end
	function smotreshkaSaveQuality_noAuto(obj, id)
		if id > 0 then
			m_simpleTV.Config.SetValue('smotreshka_qlty_noAuto', tostring(id))
		end
	end
-- debug_in_file(t[index].Address .. '\n')