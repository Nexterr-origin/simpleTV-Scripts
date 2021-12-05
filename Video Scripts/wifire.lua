-- видеоскрипт для плейлиста "wifire" https://wifire.tv (5/12/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- скрапер TVS: wifire_pls.lua
-- открывает подобные ссылки:
-- https://wifire.tv/1TVHD_OTT_wflite.m3u8
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://wifire%.tv/.+') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.wifire then
		m_simpleTV.User.wifire = {}
	end
	local function showMsg(str)
		m_simpleTV.OSD.ShowMessageT({text = 'wifire ошибка: ' .. str, showTime = 5000, color = ARGB(255, 255, 102, 0), id = 'channelName'})
	end
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local userAgent = 'Mozilla/5.0 (Windows NT 10.0; rv:95.0) Gecko/20100101 Firefox/95.0'
	local session = m_simpleTV.Http.New(userAgent)
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function GetToken()
		local url = 'https://api.wifire.tv/api/v1/salt/web'
		local headers = 'Referer: https://wifire.tv/'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		local user_id = decode64('Nzg0M2Q0YTQtZTY3NS00M2NkLTgwODgtMTkzNDcxNzNiOGU2')
		local timeSt = math.floor(os.time() / 1e3) * 1000
		timeSt = timeSt - timeSt % 600
		local secret = timeSt .. user_id .. 'register;salt=' .. answer
		url = 'https://api.wifire.tv/api/v1/register?userId=' .. user_id .. '&secret=' .. m_simpleTV.Common.CryptographicHash(secret) .. '&client=web'
		rc, answer = m_simpleTV.Http.Request(session, {url = url, method = 'post', headers = headers})
			if rc ~= 200 then return end
	 return answer:match('"session_token":"([^"]+)')
	end
	if not m_simpleTV.User.wifire.token then
		m_simpleTV.User.wifire.token = GetToken()
			if not m_simpleTV.User.wifire.token then
				m_simpleTV.Http.Close(session)
				showMsg('1')
			 return
			end
	end
	local extOpt = '$OPT:adaptive-minbuffer=30000$OPT:adaptive-livedelay=60000$OPT:http-user-agent=' .. userAgent
	local retAdr = 'https://api.wifire.tv/proxy/cookies?url=http%3A%2F%2Fsgw.tv.ti.ru%2FstreamingGateway%2FGetLivePlayList%3Fsource%3D'
			.. inAdr:gsub('https://wifire.tv/', '')
			.. '%26serviceArea%3DNBN_SA&c='
			.. m_simpleTV.User.wifire.token
	local rc, answer = m_simpleTV.Http.Request(session, {url = retAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then
			m_simpleTV.User.wifire.token = nil
			showMsg('2')
		 return
		end
	local t = {}
		for w in answer:gmatch('EXT%-X%-STREAM%-INF(.-\n.-)\n') do
			local adr = w:match('\n(.+)')
			local bw = w:match('BANDWIDTH=(%d+)')
			local res = w:match('RESOLUTION=%d+x(%d+)')
			if adr and bw then
				bw = tonumber(bw)
				bw = math.ceil(bw / 100000) * 100
				t[#t + 1] = {}
				t[#t].Id = bw
				if res then
					t[#t].Name = res .. 'p (' .. bw .. ' кбит/с)'
				else
					t[#t].Name = bw .. ' кбит/с'
				end
				t[#t].Address = adr .. extOpt
			end
		end
		if #t == 0 then
			m_simpleTV.Control.CurrentAddress = retAdr .. extOpt
		 return
		end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('wifire_qlty') or 50000)
	t[#t + 1] = {}
	t[#t].Id = 50000
	t[#t].Name = '▫ всегда высокое'
	t[#t].Address = t[#t - 1].Address
	t[#t + 1] = {}
	t[#t].Id = 100000
	t[#t].Name = '▫ адаптивное'
	t[#t].Address = retAdr .. extOpt
	local index = #t
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
		t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		t.ExtParams = {LuaOnOkFunName = 'wifireSaveQuality'}
		m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function wifireSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('wifire_qlty', tostring(id))
	end
-- debug_in_file(m_simpleTV.Control.CurrentAddress .. '\n')