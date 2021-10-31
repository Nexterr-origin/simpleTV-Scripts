-- видеоскрипт для сайта https://ufcfightpass.com (31/10/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- логин, пароль установить в 'Password Manager', для id: ufcfightpass
-- ## открывает подобные ссылки ##
-- https://ufcfightpass.com/live/129428/fight-pass-247
-- https://ufcfightpass.com/video/206187/ufc---vs--?playlistId=2939
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://ufcfightpass%.com') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local logo = 'https://static.diceplatform.com/prod/AUTOx100/dce.ufc/settings/UFC-FIGHT-PASS-Vertical_White.98nci.png'
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = logo, UseLogo = 1, Once = 1})
	end
	local function showMsg(str)
		local t = {text = 'UFC Fight Pass: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local id = inAdr:match('/live/([^/]+)')
	local idVod = inAdr:match('/video/([^/]+)')
		if not id and not idVod then
			showMsg('неправильная ссылка')
		 return
		end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:94.0) Gecko/20100101 Firefox/94.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local headers = 'Content-Type: application/json\nRealm: dce.ufc\nx-api-key: 857a1e5d-e35e-4fdf-805b-a87b6f8364bf\nAuthorization: Bearer '
	local apiUrl = 'https://dce-frontoffice.imggaming.com/api/v2/'
	local function showMsg(str)
		local t = {text = 'UFC Fight Pass: ' .. str, color = ARGB(255, 255, 102, 0), showTime = 1000 * 5, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function GetTokens()
		local error_text, pm = pcall(require, 'pm')
			if not package.loaded.pm then return end
		local ret, login, pass = pm.GetTestPassword('ufcfightpass', 'ufcfightpass', true)
			if not login or not pass or login == '' or pass == '' then return end
		local url = apiUrl .. 'login'
		local headers = headers .. 'null'
		local body = string.format('{"id":"%s","secret":"%s"}', login, pass)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', body = body, headers = headers})
			if rc ~= 201 then return end
	 return answer:match('"authorisationToken":"([^"]+)')
	end
	local function GetAddress(id, idVod, token)
		local headers = headers .. token
		local url
		if id then
			url = apiUrl .. 'stream?sportId=0&propertyId=0&tournamentId=0&displayGeoblockedLive=false&eventId=' .. id
		else
			url = apiUrl .. 'stream/vod/' .. idVod
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		url = answer:match('"playerUrlCallback":"([^"]+)')
			if not url then return end
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
	 return answer:match('"hlsUrl":"([^"]+)')
	end
	local authToken = GetTokens()
		if not authToken then
			showMsg('необходима авторизация')
		 return
		end
	local retAdr = GetAddress(id, idVod, authToken)
		if not retAdr then
			showMsg('нет адреса трансляции/видео')
		 return
		end
	local extOpt = '$OPT:http-user-agent=' .. userAgent
	retAdr = retAdr .. extOpt
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
