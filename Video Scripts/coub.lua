-- видеоскрипт для сайта https://coub.com (7/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://coub.com/embed/ug5d0
-- https://coub.com/view/168rgy/
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
		if not inAdr then return end
		if not inAdr:match('https?://coub%.com/view/') and not inAdr:match('https?://coub%.com/embed/') then return end
	m_simpleTV.OSD.ShowMessageT({text = '', showTime = 1000, id = 'channelName'})
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local id = inAdr:match('coub%.com/[^/]+/([^/]+)')
		if not id then return end
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:86.0) Gecko/20100101 Firefox/86.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = 'http://coub.com/api/v2/coubs/' .. id .. '.json'})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local tab = json.decode(answer:gsub('%[%]', '""'))
		if not tab or not tab.file_versions or not tab.file_versions.html5 or not tab.file_versions.html5.video then
			m_simpleTV.Http.Close(session)
		 return
		end
	local title = tab.title or 'coub'
		if tab.file_versions.share and tab.file_versions.share.default and tab.file_versions.share.default ~= '' then
			local retAdr = tab.file_versions.share.default .. '$OPT:POSITIONTOCONTINUE=0$OPT:NO-STIMESHIFT'
			m_simpleTV.Control.CurrentAddress = retAdr
			m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
			m_simpleTV.Control.CurrentTitle_UTF8 = title
		 return
		end
	local shell = os.getenv('TEMP')
		if not shell then return end
	local path = shell:gsub('\\', '\\\\') .. '\\'
	local audio, video = '', ''
	if tab.file_versions.html5.video.high and tab.file_versions.html5.video.high.url then
		video = tab.file_versions.html5.video.high.url
	elseif tab.file_versions.html5.video.med and tab.file_versions.html5.video.med.url then
		video = tab.file_versions.html5.video.med.url
	end
	if tab.file_versions.html5.audio and tab.file_versions.html5.audio.high and tab.file_versions.html5.audio.high.url then
		audio = tab.file_versions.html5.audio.high.url
	elseif tab.file_versions.html5.audio and tab.file_versions.html5.audio.med and tab.file_versions.html5.audio.med.url then
		audio = tab.file_versions.html5.audio.med.url
	end
		if video == '' then
			m_simpleTV.Http.Close(session)
		 return
		end
	m_simpleTV.OSD.ShowMessageT({text = title, color = 0xff9999ff, showTime = 1000 * 5, id = 'channelName'})
	m_simpleTV.Control.CurrentTitle_UTF8 = title
	if audio ~= '' then
		rc, audio = m_simpleTV.Http.Request(session, {url = audio, writeinfile = true, filename = path .. 'coub_audio.mp3'})
		if not audio then audio = '' end
	end
	rc, video = m_simpleTV.Http.Request(session, {url = video, writeinfile = true, filename = path .. 'coub_video.mp4'})
	m_simpleTV.Http.Close(session)
		if not video then return end
	local file = io.open(video, 'r+b')
		if not file then return end
	file:seek()
	file:write(string.char('0x00', '0x00'))
	file:close()
	local retAdr = video .. '$OPT:POSITIONTOCONTINUE=0$OPT:NO-STIMESHIFT$OPT:input-slave=' .. audio
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')