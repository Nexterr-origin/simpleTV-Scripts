-- видеоскрипт для сайта https://matchtv.ru (26/4/22)
-- Copyright © 2017-2022 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## открывает ссылку ##
-- https://matchtv.ru/on-air
		if m_simpleTV.Control.ChangeAddress ~= 'No' then return end
		if not m_simpleTV.Control.CurrentAddress:match('^https?://matchtv%.ru/on%-air') then return end
	if m_simpleTV.Control.MainMode == 0 then
		m_simpleTV.Interface.SetBackground({BackColor = 0, TypeBackColor = 0, PictFileName = '', UseLogo = 0, Once = 1})
	end
	local inAdr = m_simpleTV.Control.CurrentAddress
	m_simpleTV.Control.ChangeAddress = 'Yes'
	m_simpleTV.Control.CurrentAddress = 'error'
	local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:99.0) Gecko/20100101 Firefox/99.0')
		if not session then return end
	m_simpleTV.Http.SetTimeout(session, 8000)
	local rc, answer = m_simpleTV.Http.Request(session, {url = inAdr})
		if rc ~= 200 then
			m_simpleTV.Http.Close(session)
		 return
		end
	local url = answer:match('<div class="video%-player.-src="([^"]+)')
		if not url then return end
	url = url:gsub('^//', 'http://')
	rc, answer = m_simpleTV.Http.Request(session, {url = url, headers = 'Referer: ' .. inAdr})
	m_simpleTV.Http.Close(session)
		if rc ~= 200 then return end
	answer = answer:gsub('%s+', '')
	answer = answer:match('sourcesWithRes[^%]]+')
		if not answer then return end
	local extOpt = ''
	local t, i = {}, 1
		for w in answer:gmatch('{.-}') do
			local res = w:match('res:(%d+)')
			local name = w:match('label:\'([^\']+)')
			local adr = w:match('src:\'([^\']+)')
			if adr and name and res then
				t[i] = {}
				t[i].Id = 100 - tonumber(res)
				t[i].Name = name
				t[i].Address = adr .. extOpt
				i = i + 1
			end
		end
		if #t == 0 then return end
	table.sort(t, function(a, b) return a.Id < b.Id end)
	local lastQuality = tonumber(m_simpleTV.Config.GetValue('matchtv_qlty') or 100)
	local index = #t
	if #t > 1 then
		index = #t
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
			t.ExtParams = {LuaOnOkFunName = 'matchtvSaveQuality'}
			m_simpleTV.OSD.ShowSelect_UTF8('⚙ Качество', index - 1, t, 5000, 32 + 64 + 128)
		end
	end
	m_simpleTV.Control.CurrentAddress = t[index].Address
	function matchtvSaveQuality(obj, id)
		m_simpleTV.Config.SetValue('matchtv_qlty', id)
	end
-- debug_in_file(t[index].Address .. '\n')
