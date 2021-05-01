-- видеоскрипт для сайта https://www.dropbox.com (12/3/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://www.dropbox.com/s/dvspvf22x2y7vby
-- https://www.dropbox.com/s/kimukvqsbum379g/1x03.HIMYM%20-%20JingKing.mkv?dl=0
-- https://www.dropbox.com/s/ypvn9sjsteeg6tf/EN%20HAUT%20EN%20BAS%20A%20GAUCHE%20A%20DROITE.mp3?dl=1
-- https://www.dropbox.com/s/dvspvf22x2y7vby/Shawn%20Mendes%2C%20Camila%20Cabello%20-%20Se%C3%B1orita%20%28Lyrics%29.mp3?raw=1~Senorita
-- https://www.dropbox.com/s/eyb1jqi06zmiwap/11_MHW-IB_PV3_PS4_FR
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://www%.dropbox%.com/sh?/') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = ''
	local retAdr = inAdr:gsub('%?.-$', '')
	retAdr = retAdr .. '?dl=1'
	m_simpleTV.Control.CurrentAddress = retAdr
	local title = retAdr:match('/s/.-/(.+)%?') or 'Dropbox'
	title = title:gsub('%....$', '')
	title = m_simpleTV.Common.fromPercentEncoding(title)
	m_simpleTV.Control.CurrentTitle_UTF8 = title
-- debug_in_file(retAdr .. '\n')