-- видеоскрипт для плейлиста "ДомаТвНет" http://tv.domatv.net (14/10/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: domatv_pls.lua
-- модуль: /core/playerjs.lua
-- ## открывает подобные ссылки ##
-- http://tv.domatv.net/107-bbc-world-news.html
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://[%w%.]*domatv%.net') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	require 'playerjs'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'domatv ошибка: ' .. str, showTime = 1000 * 5, color = 0xffff6600, id = 'channelName'})
	end
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:82.0) Gecko/20100101 Firefox/82.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then
			showError('0')
		 return
		end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('1')
		 return
		end
	answer = answer:gsub('%s+', '')
	answer = answer:gsub('<!%-%-.-%-%->', ''):gsub('/%*.-%*/', '')
	local retAdr = answer:match('file:"([^"]+)')
		if not retAdr then
			showError('2')
		 return
		end
	local playerjs_url = answer:match('src="(/templates/shamanim/js/tv[^"]+)')
		if not playerjs_url then
			showError('3')
		 return
		end
	playerjs_url = inAdr:match('^https?://[^/]+') .. playerjs_url
	retAdr = playerjs.decode(retAdr, playerjs_url)
		if not retAdr
			or retAdr == ''
		then
			showError('4')
		 return
		end
	local v1 = answer:match('firstIpProtect=\'([^\']+)') or ''
	local v2 = answer:match('secondIpProtect=\'([^\']+)') or ''
	local v3 = answer:match('portProtect=\'([^\']+)') or ''
	retAdr = retAdr:gsub('{v1}', v1):gsub('{v2}', v2):gsub('{v3}', v3)
	retAdr = retAdr .. '$OPT:http-referrer=' .. inAdr .. '$OPT:http-user-agent=' .. userAgent
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr, m_simpleTV.Common.GetMainPath(2) .. 'domatv.txt', true)