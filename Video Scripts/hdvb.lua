-- видеоскрипт для видеобалансера "Hdvb" https://hdvb.tv (27/3/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает подобные ссылки ##
-- https://vid1647324294.vb17121coramclean.pw/movie/c77fd8d3ec03509000778d9af49f8d86/iframe
-- https://vid1648222294.vb17121coramclean.pw/serial/77de2d434d279e861121237797af59a26ae2a19b53718d36ce15bcca908eaed2/iframe
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://vid%d+.-/%a+/%x+/iframe')
			and not m_simpleTV.Control.CurrentAddress:match('^$hdvb')
		then
		 return
		end
	local inAdr = m_simpleTV.Control.CurrentAddress
	if not inAdr:match('&kinopoisk') then
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
	end
	require 'json'
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	if not m_simpleTV.User then
		m_simpleTV.User = {}
	end
	if not m_simpleTV.User.hdvb then
		m_simpleTV.User.hdvb = {}
	end
	if not inAdr:match('^$hdvb') then
		m_simpleTV.User.hdvb.startAdr = inAdr
	end
	m_simpleTV.User.hdvb.DelayedAddress = nil
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local function showMsg(str)
		local t = {text = 'Hdvb ошибка: ' .. str, showTime = 1000 * 8, color = ARGB(255, 255, 102, 0), id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function getAddress(adr)
			if adr:match('^http') then
			 return adr
			end
		adr = adr:gsub('^$hdvb', '')
		adr = adr:gsub('^~', '/playlist/')
		adr = m_simpleTV.User.hdvb.host .. adr .. '.txt'
		local rc, answer = m_simpleTV.Http.Request(session, {url = adr, headers = m_simpleTV.User.hdvb.headers, method = 'post'})
	 return answer
	end
	local function getIndex(t)
		local lastQuality = tonumber(m_simpleTV.Config.GetValue('hdvb_qlty') or 5000)
		local index = #t
			for i = 1, #t do
				if t[i].qlty >= lastQuality then
					index = i
				 break
				end
			end
		if index > 1 then
			if t[index].qlty > lastQuality then
				index = index - 1
			end
		end
	 return index
	end
	local function getAdrTab(url)
			if not url then return end
		url = url:gsub('^$hdvb', '')
		url = url:gsub('^//', 'https://')
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:98.0) Gecko/20100101 Firefox/98.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 8000)
		local rc, answer = m_simpleTV.Http.Request(session, {url = url})
		m_simpleTV.Http.Close(session)
			if rc ~= 200 then return end
		local base = url:match('.+/')
		local t, i = {}, 1
		local qlty, adr
			for w in answer:gmatch('#EXT%-X%-STREAM%-INF:(.-\n.-)\n') do
				qlty = w:match('RESOLUTION=%d+x(%d+)')
				adr = w:match('\n(.+)')
					if not qlty or not adr then break end
				t[i] = {}
				t[i].Address = base .. adr:gsub('^%./', '') .. '$OPT:NO-STIMESHIFT'
				t[i].qlty = qlty
				i = i + 1
			end
			if i == 1 then return end
			for _, v in pairs(t) do
				v.qlty = tonumber(v.qlty)
				if v.qlty > 0 and v.qlty <= 180 then
					v.qlty = 144
				elseif v.qlty > 180 and v.qlty <= 300 then
					v.qlty = 240
				elseif v.qlty > 300 and v.qlty <= 400 then
					v.qlty = 360
				elseif v.qlty > 400 and v.qlty <= 500 then
					v.qlty = 480
				elseif v.qlty > 500 and v.qlty <= 780 then
					v.qlty = 720
				elseif v.qlty > 780 and v.qlty <= 1200 then
					v.qlty = 1080
				elseif v.qlty > 1200 and v.qlty <= 1500 then
					v.qlty = 1444
				elseif v.qlty > 1500 and v.qlty <= 2800 then
					v.qlty = 2160
				elseif v.qlty > 2800 and v.qlty <= 4500 then
					v.qlty = 4320
				end
				v.Name = v.qlty .. 'p'
			end
		table.sort(t, function(a, b) return a.qlty < b.qlty end)
		for i = 1, #t do
			t[i].Id = i
		end
		m_simpleTV.User.hdvb.Tab = t
		local index = getIndex(t)
		m_simpleTV.User.hdvb.Index = index
	 return t[index].Address
	end
	local function getStream(adr)
		adr = getAddress(adr)
			if not adr then	return end
	 return getAdrTab(adr)
	end
	local function play(adr, title)
		local retAdr = getStream(adr)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
-- debug_in_file(retAdr .. '\n')
		m_simpleTV.Control.SetTitle(title)
		m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
		m_simpleTV.Control.CurrentAddress = retAdr
	end
	local function seasons()
		local tab = m_simpleTV.User.hdvb.tab
		local title = m_simpleTV.User.hdvb.title
		local t, i = {}, 1
			while tab[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab[i].title
				i = i + 1
			end
			if #t == 0 then return end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		local _, id = m_simpleTV.OSD.ShowSelect_UTF8('сезон: ' .. title, 0, t, 10000, 1 + 2 + 4 + 8)
		id = id or 1
		m_simpleTV.User.hdvb.season = id
		m_simpleTV.User.hdvb.seasonName = ' (' .. t[id].Name .. ')'
	 return true
	end
	local function episodes()
		local tab = m_simpleTV.User.hdvb.tab
		local season = m_simpleTV.User.hdvb.season
		local t, i = {}, 1
			while tab[season].folder[i] do
				t[i] = {}
				t[i].Id = i
				t[i].Name = tab[season].folder[i].title .. ' (' .. tab[season].folder[i].folder[1].title .. ')'
				t[i].Address = '$hdvb' .. tab[season].folder[i].folder[1].file
				i = i + 1
			end
			if #t == 0 then return end
		local retAdr = getStream(t[1].Address)
			if not retAdr then
				m_simpleTV.Control.CurrentAddress = 'http://wonky.lostcut.net/vids/error_getlink.avi'
			 return
			end
		m_simpleTV.User.hdvb.DelayedAddress = retAdr
		local title = m_simpleTV.User.hdvb.title .. m_simpleTV.User.hdvb.seasonName
		m_simpleTV.Control.SetTitle(title)
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qlty_hdvb()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_hdvb()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonPlst then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonPlst, ButtonScript = 'm_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.hdvb.startAdr, position = 0})'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '📋', ButtonScript = 'm_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.hdvb.startAdr, position = 0})'}
		end
		t.ExtParams = {}
		t.ExtParams.LuaOnCancelFunName = 'OnMultiAddressCancel_hdvb'
		t.ExtParams.LuaOnOkFunName = 'OnMultiAddressOk_hdvb'
		t.ExtParams.LuaOnTimeoutFunName = 'OnMultiAddressCancel_hdvb'
		t.ExtParams.StopOnError = 1
		t.ExtParams.StopAfterPlay = 1
		t.ExtParams.PlayMode = 1
		m_simpleTV.OSD.ShowSelect_UTF8(title, 0, t, 10000, 2 + 64)
		m_simpleTV.Control.CurrentAddress = 'wait'
		m_simpleTV.User.hdvb.episodeTitle = title .. ': ' .. t[1].Name
	end
	local function movie()
		local title = m_simpleTV.User.hdvb.title
		local adr = m_simpleTV.User.hdvb.tab
		local t = {}
		t[1] = {}
		t[1].Id = 1
		t[1].Name = title
		if m_simpleTV.User.paramScriptForSkin_buttonOptions then
			t.ExtButton0 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOptions, ButtonScript = 'qlty_hdvb()'}
		else
			t.ExtButton0 = {ButtonEnable = true, ButtonName = '⚙', ButtonScript = 'qlty_hdvb()'}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		m_simpleTV.OSD.ShowSelect_UTF8('Hdvb', 0, t, 10000, 64 + 32 + 128)
		play(adr, title)
	end
	local function getData()
		local url = inAdr:gsub('&kinopoisk.+', '')
		local headers = 'Referer: http://filmhd1080.net/'
		local rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = headers})
			if rc ~= 200 then return end
		answer = answer:gsub('\\/', '/')
		local file = answer:match('"file":"([^"]+)')
		local key = answer:match('"key":"([^"]+)')
			if not file or not key then return end
		m_simpleTV.User.hdvb.host = url:match('^https?://[^/]+')
		file = file:gsub('^~', '/playlist/')
		url = m_simpleTV.User.hdvb.host .. file
		if not url:match('%.txt') then
			url = url .. '.txt'
		end
		m_simpleTV.User.hdvb.headers = headers .. '\nX-CSRF-TOKEN: ' .. key
		rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = m_simpleTV.User.hdvb.headers, method = 'post'})
			if rc ~= 200 then return end
		answer = answer:gsub('%[%]', '""')
		answer = answer:gsub('\\', '\\\\')
		answer = unescape3(answer)
		local err, tab = pcall(json.decode, answer)
		if err == false then
			tab = answer
		end
	 return tab
	end
	function OnMultiAddressOk_hdvb(Object, id)
		if id == 1 then
			OnMultiAddressCancel_hdvb(Object)
		else
			m_simpleTV.User.hdvb.DelayedAddress = nil
		end
	end
	function OnMultiAddressCancel_hdvb(Object)
		if m_simpleTV.User.hdvb.DelayedAddress then
			if m_simpleTV.Control.GetState() == 0 then
				m_simpleTV.Control.SetNewAddressT({address = m_simpleTV.User.hdvb.DelayedAddress, position = 0})
				local title = m_simpleTV.User.hdvb.episodeTitle
				m_simpleTV.Control.SetTitle(title)
				m_simpleTV.OSD.ShowMessageT({text = title, showTime = 1000 * 5, id = 'channelName'})
			end
			m_simpleTV.User.hdvb.DelayedAddress = nil
		end
	end
	function serials_hdvb()
		if seasons() then
			episodes()
		end
	end
	function qlty_hdvb()
		local t = m_simpleTV.User.hdvb.Tab
			if not t then return end
		m_simpleTV.Control.ExecuteAction(37)
		local index = getIndex(t)
		if m_simpleTV.User.paramScriptForSkin_buttonOk then
			t.OkButton = {ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonOk}
		end
		if m_simpleTV.User.paramScriptForSkin_buttonClose then
			t.ExtButton1 = {ButtonEnable = true, ButtonImageCx = 30, ButtonImageCy= 30, ButtonImage = m_simpleTV.User.paramScriptForSkin_buttonClose, ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		else
			t.ExtButton1 = {ButtonEnable = true, ButtonName = '✕', ButtonScript = 'm_simpleTV.Control.ExecuteAction(37)'}
		end
		local ret, id = m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 10000, 1 + 2 + 4)
		if ret == 1 then
			m_simpleTV.Control.SetNewAddressT({address = t[id].Address, position = m_simpleTV.Control.GetPosition()})
			m_simpleTV.Config.SetValue('hdvb_qlty', t[id].qlty)
		end
	end
		if inAdr:match('^$hdvb') then
			local title = ''
			local t = m_simpleTV.Control.GetCurrentChannelInfo()
			if t
				and t.MultiHeader
				and t.MultiName
			then
				title = t.MultiHeader .. ': ' .. t.MultiName
			end
			play(inAdr, title)
		 return
		end
	local tab = getData()
		if not tab then
			showMsg('нет данных')
		 return
		end
	local title = inAdr:match('&kinopoisk=(.+)')
	if title then
		title = m_simpleTV.Common.fromPercentEncoding(title)
	else
		title = 'Hdvb'
	end
	m_simpleTV.User.hdvb.title = title
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Control.ChangeChannelName(title, m_simpleTV.Control.ChannelID, false)
	end
	m_simpleTV.User.hdvb.tab = tab
	if type(tab) == 'table' then
		serials_hdvb()
	else
		if m_simpleTV.Control.MainMode == 0 then
			m_simpleTV.Interface.SetBackground({BackColor = 0, PictFileName = '', TypeBackColor = 0, UseLogo = 0, Once = 1})
		end
		movie()
	end
