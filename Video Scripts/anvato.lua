-- видеоскрипт "anvato" (15/4/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылки ##
-- https://www.fox5atlanta.com/live
-- https://www.fox5dc.com/live
-- https://www.fox5ny.com/live
-- https://www.fox2detroit.com/live
-- https://www.fox9.com/live
-- https://ktla.com/on-air/live-streaming
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.fox5atlanta%.com/live')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://www%.fox5dc%.com/live')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://www%.fox5ny%.com/live')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://www%.fox2detroit%.com/live')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://www%.fox9%.com/live')
			and not m_simpleTV.Control.CurrentAddress:match('^https?://ktla%.com/on%-air/live%-streaming')
		then
		 return
		end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'anvato ошибка: ' .. str, showTime = 8000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:79.0) Gecko/20100101 Firefox/79.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 16000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
			showError('1\nnet error = ' .. rc)
		 return
		end
	answer = answer:gsub('%s+', '')
	local videoId = answer:match('%.liveId="([^"]+)') or answer:match('"video":"adst([^"]+)')
	answer = answer:match('serverRendered.-%)%)') or answer:match('<figureclass="ns%-block%-embed%-anvato".-</figure>')
		if not answer then
			showError('2\nno serverRendered')
		 return
		end
	local anvack
		for w in answer:gmatch('"(%w+)"') do
			if #w == 32 then
				anvack = w
			 break
			end
		end
	anvack = answer:match('"accessKey":"([^"]+)') or anvack
	videoId = videoId or answer:match('"adst([^"]+)')
		if not anvack or not videoId then
			showError('3\nno anvack or videoId')
		 return
		end
	local url = 'https://tkx.apis.anvato.net/rest/v2/mcp/video/adst' .. videoId .. '?anvack=' .. anvack
	rc, answer = m_simpleTV.Http.Request(session, {url = url})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('4\nnet error = ' .. rc)
		 return
		end
	local retAdr = answer:match('[^\'\"<>]+%.m3u8[^<>\'\"]+')
		if not retAdr then
			showError('5\nno address')
		 return
		end
	retAdr = retAdr:gsub('\\/', '/')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')
