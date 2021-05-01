-- видеоскрипт для плейлиста "impulsTV" http://impulstv.ru (22/9/20)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: impulsTV_pls.lua
-- расширение дополнения httptimeshift: impulstv-timeshift_ext.lua
-- открывает подобные ссылки:
-- http://impulstv/960
-- ##
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://impulstv/%d') then return end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
	end
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.impulstv then
		m_simpleTV.User.impulstv = {}
	end
	local function showError(str)
		m_simpleTV.OSD.ShowMessageT({text = 'impulsTV ошибка: ' .. str
											, color = 0xffff6600
											, showTime = 1000 * 5
											, id = 'channelName'})
	end
	m_simpleTV.User.impulstv.cid_sid = nil
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'erorr'
	local cid = inAdr:match('%d+')
	local session = m_simpleTV.Http.New('mag')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 12000)
	local function Get_Address()
		local url = decode64('aHR0cDovL2ltcHVsc3R2Lm1pY3JvLmltL2FwaS90dm1pZGRsZXdhcmUvYXBpL2NoYW5uZWwvdXJsLz9yZWRpcmVjdD0wJnRpbWV6b25lPTE1JnRpbWVzaGlmdD0wJmRldmljZT1tYWcmY2xpZW50X2lkPTc3JmFwaV9rZXk9bVMwWDAzY0Exbmdta1czS0oyU3hESE00OHRZUGVHM3FveVJiUGNsQlpYcGkyME1JUElwQ1NYWEl3d0JpT0tHcmxhbmc9cnUmc2Vzc19rZXk9MCZhdXRoa2V5PQ') .. m_simpleTV.User.impulstv.cid_sid
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
			if rc ~= 200 then return end
		 return answer:match('<uri>([^<]+)')
		end
	function impulstv_url_archive(offset)
		local session1 = m_simpleTV.Http.New('mag')
			if not session1 then return end
		m_simpleTV.Http.SetTimeout(session1, 8000)
		local url = decode64('aHR0cDovL2ltcHVsc3R2Lm1pY3JvLmltL2FwaS90dm1pZGRsZXdhcmUvYXBpL3Byb2dyYW0vdXJsLz9yZWRpcmVjdD0wJmRldmljZT1tYWcmY2xpZW50X2lkPTc3JmFwaV9rZXk9bVMwWDAzY0Exbmdta1czS0oyU3hESE00OHRZUGVHM3FveVJiUGNsQlpYcGkyME1JUElwQ1NYWEl3d0JpT0tHcmxhbmc9cnUmc2Vzc19rZXk9MCZhdXRoa2V5PQ') .. m_simpleTV.User.impulstv.cid_sid .. '&time=' .. math.floor(os.time() - offset/1000)
		local rc, answer = m_simpleTV.Http.Request(session1, {url = url})
		m_simpleTV.Http.Close(session1)
			if rc ~= 200 then return end
		local url_archive = answer:match('<uri>([^<]+)')
			if not url_archive then return end
		url_archive = url_archive:gsub('amp;', ''):gsub('&end_timestamp=%d+', '&end_timestamp=' .. os.time())
	 return url_archive
	end
	if not m_simpleTV.User.impulstv.authkey then
		local authkey = m_simpleTV.Config.GetValue('impulsTV_authkey')
			if not authkey then
				showError('1\nобновите плейлист')
			 return
			end
		m_simpleTV.User.impulstv.authkey = authkey
	end
	m_simpleTV.User.impulstv.cid_sid = m_simpleTV.User.impulstv.authkey .. '&cid=' .. cid
	local retAdr = Get_Address() or Get_Address()
	m_simpleTV.Http.Close(session)
		if not retAdr then
			showError('2\nобновите плейлист')
			m_simpleTV.User.impulstv.authkey = nil
		 return
		end
	retAdr = retAdr:gsub('amp;', '')
	m_simpleTV.Control.CurrentAddress = retAdr
-- debug_in_file(retAdr .. '\n')