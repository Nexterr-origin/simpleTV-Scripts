-- видеоскрипт для сайта https://camera.rt.ru (21/11/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://camera.rt.ru/sl/HLRszUaHM
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://camera%.rt%.ru') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:83.0) Gecko/20100101 Firefox/83.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then return end
	local uid = answer:match('data%-camera%-uid="([^"]+)')
		if not uid then return end
	local url = string.format('https://camera.rt.ru/api/v1/vc/cameras/%s.json', uid)
	local rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('%[%]', '""')
	require 'json'
	local tab = json.decode(answer)
		if not tab
			or not tab.status
			or not tab.status == 'ok'
			or not tab.camera
			or not tab.camera.is_alive
			or not tab.camera.hls_url
		then
		 return
		end
	m_simpleTV.Control.CurrentTitle_UTF8 = tab.camera.name
	local retAdr = tab.camera.hls_url
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')