-- видеоскрипт для сайта https://mults.info (10/8/20)
-- Copyright © 2017-2020 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://mults.info/mults/?id=614
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('https?://mults%.info') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000 * 5, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'mults ошибка: ' .. str, showTime = 5000, color = 0xffff6600, id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'https://s00.yaplakal.com/pics/pics_original/1/1/6/8655611.jpg'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.2785.143 Safari/537.36')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			showError('1')
		 return
		end
	local retAdr = answer:match('"og:video" content="(.-)"')
		if not retAdr then
			showError('2')
		 return
		end
	retAdr = retAdr .. '$OPT:NO-STIMESHIFT'
	local title = answer:match('<H1>.-&quot;(.-)&quot;</H1>') or 'mults.info'
	m_simpleTV.Control.CurrentTitle_UTF8 = m_simpleTV.Common.multiByteToUTF8(title)
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')