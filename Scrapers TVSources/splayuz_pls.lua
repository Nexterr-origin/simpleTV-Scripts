-- скрапер TVS для загрузки плейлиста "Splay UZ" https://splay.uz (26/9/25)
-- Copyright © 2017-2025 Nexterr, NEKTO666 | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## Переименовать каналы ##
local filter = {
	--{'Мир-ТВ', 'МИР'},
	}
	local my_src_name = 'Splay UZ'
	module('splayuz_pls', package.seeall)
	local function ProcessFilterTableLocal(t)
		if not type(t) == 'table' then return end
		for i = 1, #t do
			t[i].name = tvs_core.tvs_clear_double_space(t[i].name)
			for _, ff in ipairs(filter) do
				if (type(ff) == 'table' and t[i].name == ff[1]) then
					t[i].name = ff[2]
				end
			end
		end
	 return t
	end
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\splayuz.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 1, RefreshButton = 1, show_progress = 0, AutoBuild = 0, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, LogoTVG = 0}, STV = {add = 1, ExtFilter = 1, FilterCH = 1, FilterGR = 1, GetGroup = 1, HDGroup = 1, AutoSearch = 1, AutoNumber = 1, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 0, RemoveDupCH = 1}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function LoadFromSite()
	local channels = {
				{'ZooPark', 'ZooПарк', '59'},
				{'Zvezda', 'Звезда', '3'},
				{'Viasat_Explorer', 'Viasat Explorer', '56'},
				{'Viasat_History', 'Viasat History', '57'},
				{'Viasat_Nature', 'Viasat Nature', '158'},
				{'Viasat_Sport', 'Viasat Sport', '155'},
				{'TVC', 'ТВЦ', '127'},
				{'TV3', 'ТВ3', '53'},
				{'Telekafe', 'Телекафе', '49'},
				{'TV1000', 'TV1000', '120'},
				{'TNT', 'ТНТ', ''},
				{'STS', 'СТС', ''},
				{'RossiyaK', 'Россия К', '44'},
				{'Rossiya24', 'Россия24', '43'},
				{'Rossiya1', 'Россия', '2'},
				{'Retro', 'Ретро', '41'},
				{'Nickelodeon', 'Nickelodeon', ''},
				{'NTV', 'НТВ', '189'},
				{'Mir24', 'Мир24', '28'},
				{'Mir', 'Мир', '27'},
				{'Karusel', 'Карусель', '9'},
				{'Euronews', 'Euronews', '16'},
				{'Eurosport', 'Eurosport 1 HD', '17'},
				{'Eurosport2HD', 'Eurosport 2 HD', '203'},
				{'Domashniy', 'Домашний', '147'},
				{'Detskiy', 'Уникум', '55'},
				{'Davinci', 'Da Vinci', '160'},
				{'5Kanal', 'Пятый канал', ''},
				{'8Kanal', 'Восьмой канал', '4'},
				{'NaukaHD', 'Наука HD', '106'},
				{'MoyaPlanetaHD', 'Моя планета HD', '123'},
				{'Nat_Geo_Wild_HD', 'Nat Geo Wild HD', '206'},
				{'National_Geographic', 'National Geographic', '32'},
				{'Kinopremera', 'Кинопремьера', '81'},
				{'KinomiksHD', 'Киномикс', '66'},
				{'Kinosemya', 'Киносемья', '65'},
				{'Kinoseriya', 'Киносерия', '82'},
				{'Kinosvidanie', 'Киносвидание', '83'},
				{'Kinoxit', 'Кинохит', '79'},
				{'Kinokomediya', 'Кинокомедия', '78'},
				{'Nashe_novoe_kino', 'Наше новое кино', '31'},
				{'Mujskoe-KinoHD', 'Мужское кино', '69'},
				{'Rodnoe_Kino', 'Родное кино', '182'},
				{'Avto24', 'Авто24', '73'},
				{'JivayaPrirodaHD', 'Живая Природа HD', '97'},
				{'Animal_Planet', 'Animal Planet', '5'},
				{'Discovery_Channel', 'Discovery Channel', '13'},
				{'Setanta1HD', 'Setanta 1 HD', ''},
				{'Setanta2HD', 'Setanta 2 HD', ''},
				{'CinemaHD', 'Cinema HD', '113'},
				{'Fashion_TV', 'Fashion TV', '18'},
				{'HDL_HD', 'HDL', '71'},
				{'Deutsche_Welle', 'Deutsche Welle', '75'},
				{'Dom_Kino', 'Дом кино', '76'},
				{'KuxnyaTV', 'Кухня ТВ', '84'},
				{'Trace_Sport_Stars', 'Trace Sport Stars', '105'},
				{'Mama', 'Мама', '108'},
				{'History', 'История', '110'},
				{'JivayaPlaneta', 'Живая планета', '111'},
				{'BBCWorldNews', 'BBC World News', '115'},
				{'Star_Cinema', 'Star Cinema', '185'},
				{'Bober', 'Бобер ', '188'},
				{'Uzbekiston', 'Ozbekiston', '36'},
				{'YoshlarHD', 'Yoshlar HD', '58'},
				{'Toshkent', 'TOSHKENT', '50'},
				{'Sport-UZ', 'Sport TV', '46'},
				{'Uzb24', 'Ozbekiston 24', '37'},
				{'Bolajon', 'Bolajon', '8'},
				{'FutbolTV', 'Futbol TV', '195'},
				{'Navo', 'Navo', '33'},
				{'Madaniyat_va_Marifat', 'Madaniyat va Marifat', '22'},
				{'Mahalla', 'Mahalla', '23'},
				{'Kinoteatr_HD', 'Kinoteatr HD', '21'},
				{'Uzbekiston-TarixiHD', 'Ozbekiston Tarixi', '38'},
				{'Dunyoboylab_HD', 'Dunyo boylab TV', '15'},
				{'Nurafshon_TV', 'Nurafshon TV', '35'},
				{'TTV_Musiqa', 'TTV Musiqa', '164'},
				{'FTVHD', 'FTV HD', '134'},
				{'Muz_TV', 'Муз Ozbekiston', '86'},
				{'Zor_TVHD', 'ZOR TV HD', '60'},
				{'Milly_TVHD', 'Milly TV HD', '26'},
				{'Mening_YurtimHD', 'Mening Yurtim HD', '30'},
				{'DasturxonTV', 'Dasturxon TV', '12'},
				{'Myday', 'Myday TV', '162'},
				{'LuxTV', 'Lux.TV 4K', '90'},
				{'Renessans_TV', 'Renessans TV', '116'},
				{'Xabar24', 'Хабар 24', '91'},
				{'Dorama', 'Дорама', '92'},
				{'TRT_Muzik', 'TRT Müzik', '133'},
				{'TRT_Avaz', 'TRT Avaz', '170'},
				{'ITV_Music', 'ITV Music', '194'},
				{'AlJazeera', 'Al Jazeera', '198'},
				{'BizTV', 'Biz TV', '214'},
				{'BizMusic', 'Biz Music', '215'},
				{'ShifoTV', 'Shifo TV', '216'},
				{'Makon_TV', 'Makon TV', '219'},
				{'QiziqTV', 'Qiziq TV', '220'},
				}
		local t = {}
			for i, v in pairs(channels) do
				if v[1] and v[2] then
					t[#t + 1] = {}
					t[#t].name = unescape3(v[2])
					t[#t].address = decode64('aHR0cHM6Ly92b2Quc3BsYXkudXovbGl2ZV9zcGxheS9vcmlnaW5hbC8') .. v[1] .. '/playlist.m3u8'
					if string.len(v[3]) >= 1 then
						t[#t].logo = decode64('aHR0cHM6Ly9jZG4uc3BsYXkudXovbWVkaWEvdHZfY2hhbm5lbHMv') .. v[3] .. '.png'
						
					else
						t[#t].logo = ''
					end
				end
			end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls or #t_pls == 0 then return end
		t_pls = ProcessFilterTableLocal(t_pls)
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(token .. '\n', "D:\xxx.txt")
