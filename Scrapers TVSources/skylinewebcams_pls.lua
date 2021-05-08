-- скрапер TVS для загрузки плейлиста веб камер "SkylineWebcams" https://www.skylinewebcams.com (8/5/21)
-- Copyright © 2017-2021 Nexterr | https://github.com/Nexterr-origin/simpleTV-Scripts
-- ## необходим ##
-- видоскрипт: skylinewebcams.lua
-- ##
	module('skylinewebcams_pls', package.seeall)
	local my_src_name = 'SkylineWebcams'
	function GetSettings()
	 return {name = my_src_name, sortname = '', scraper = '', m3u = 'out_' .. my_src_name .. '.m3u', logo = '..\\Channel\\logo\\Icons\\skylinewebcams.png', TypeSource = 1, TypeCoding = 1, DeleteM3U = 0, RefreshButton = 0, AutoBuild = 0, show_progress = 1, AutoBuildDay = {0, 0, 0, 0, 0, 0, 0}, LastStart = 0, TVS = {add = 0, FilterCH = 0, FilterGR = 0, GetGroup = 0, LogoTVG = 0}, STV = {add = 1, ExtFilter = 0, FilterCH = 0, FilterGR = 0, GetGroup = 1, HDGroup = 0, AutoSearch = 0, AutoNumber = 0, NumberM3U = 0, GetSettings = 1, NotDeleteCH = 0, TypeSkip = 1, TypeFind = 1, TypeMedia = 3}}
	end
	function GetVersion()
	 return 2, 'UTF-8'
	end
	local function showMsg(str, color)
		local t = {text = str, showTime = 1000 * 5, color = color, id = 'channelName'}
		m_simpleTV.OSD.ShowMessageT(t)
	end
	local function flags(str)
		local t = {
		{'zanzibar', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1ff.png'},
		{'caribbean netherlands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f6.png'},
		{'us virgin islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1ee.png'},
		{'czech republic', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1ff.png'},
		{'republic of san marino', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f2.png'},
		{'republic of singapore', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1ec.png'},
		{'afghanistan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1eb.png'},
		{'albania', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1f1.png'},
		{'algeria', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e9-1f1ff.png'},
		{'american samoa', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1f8.png'},
		{'andorra', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1e9.png'},
		{'angola', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1f4.png'},
		{'anguilla', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1ee.png'},
		{'antigua & barbuda', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1ec.png'},
		{'argentina', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1f7.png'},
		{'armenia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1f2.png'},
		{'aruba', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1fc.png'},
		{'australia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1fa.png'},
		{'austria', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1f9.png'},
		{'azerbaijan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1ff.png'},
		{'bahamas', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f8.png'},
		{'bahrain', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1ed.png'},
		{'bangladesh', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1e9.png'},
		{'barbados', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1e7.png'},
		{'belarus', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1fe.png'},
		{'belgique', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1ea.png'},
		{'belize', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1ff.png'},
		{'benin', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1ef.png'},
		{'bermuda', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f2.png'},
		{'bhutan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f9.png'},
		{'bolivia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f4.png'},
		{'bosnia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1e6.png'},
		{'botswana', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1fc.png'},
		{'brasil', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f7.png'},
		{'british virgin islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1ec.png'},
		{'brunei', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f3.png'},
		{'bulgaria', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1ec.png'},
		{'burkina faso', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1eb.png'},
		{'burundi', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1ee.png'},
		{'cambodia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1ed.png'},
		{'cameroon', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1f2.png'},
		{'canada', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1e6.png'},
		{'cape verde', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1fb.png'},
		{'cayman islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1fe.png'},
		{'central african republic', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1eb.png'},
		{'chad', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1e9.png'},
		{'chile', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1f1.png'},
		{'china', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1f3.png'},
		{'colombia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1f4.png'},
		{'comoros', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1f2.png'},
		{'congo - brazzaville', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1ec.png'},
		{'congo - kinshasa', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1e9.png'},
		{'cook islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1f0.png'},
		{'costa rica', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1f7.png'},
		{'hrvatska', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ed-1f1f7.png'},
		{'cuba', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1fa.png'},
		{'curacao', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1fc.png'},
		{'cyprus', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1fe.png'},
		{'czechia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1ff.png'},
		{'côte d’ivoire', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1ee.png'},
		{'denmark', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e9-1f1f0.png'},
		{'djibouti', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e9-1f1ef.png'},
		{'dominica', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e9-1f1f2.png'},
		{'dominican republic', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e9-1f1f4.png'},
		{'ecuador', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1e8.png'},
		{'egypt', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1ec.png'},
		{'el salvador', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1fb.png'},
		{'equatorial guinea', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f6.png'},
		{'eritrea', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1f7.png'},
		{'estonia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1ea.png'},
		{'eswatini', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1ff.png'},
		{'ethiopia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1f9.png'},
		{'faroe islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1eb-1f1f4.png'},
		{'fiji', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1eb-1f1ef.png'},
		{'finland', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1eb-1f1ee.png'},
		{'france', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1eb-1f1f7.png'},
		{'french guiana', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1eb.png'},
		{'french polynesia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1eb.png'},
		{'french southern territories', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1eb.png'},
		{'gabon', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1e6.png'},
		{'gambia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f2.png'},
		{'georgia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1ea.png'},
		{'deutschland', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e9-1f1ea.png'},
		{'ghana', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1ed.png'},
		{'ellada', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f7.png'},
		{'greenland', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f1.png'},
		{'grenada', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1e9.png'},
		{'guadeloupe', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f5.png'},
		{'guam', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1fa.png'},
		{'guatemala', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f9.png'},
		{'guinea', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1f3.png'},
		{'guinea-bissau', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1fc.png'},
		{'haiti', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ed-1f1f9.png'},
		{'honduras', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ed-1f1f3.png'},
		{'hong kong', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ed-1f1f0.png'},
		{'hungary', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ed-1f1fa.png'},
		{'iceland', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1f8.png'},
		{'india', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1f3.png'},
		{'indonesia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1e9.png'},
		{'international', 'https://github.githubassets.com/images/icons/emoji/unicode/1f30d.png'},
		{'iran', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1f7.png'},
		{'iraq', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1f6.png'},
		{'ireland', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1ea.png'},
		{'israel', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1f1.png'},
		{'italia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ee-1f1f9.png'},
		{'jamaica', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ef-1f1f2.png'},
		{'japan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ef-1f1f5.png'},
		{'jordan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ef-1f1f4.png'},
		{'kazakhstan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1ff.png'},
		{'kenya', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1ea.png'},
		{'kiribati', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1ee.png'},
		{'kosovo', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fd-1f1f0.png'},
		{'kuwait', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1fc.png'},
		{'kyrgyzstan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1ec.png'},
		{'laos', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1e6.png'},
		{'latvia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1fb.png'},
		{'lebanon', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1e7.png'},
		{'lesotho', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1f8.png'},
		{'liberia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1f7.png'},
		{'libya', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1fe.png'},
		{'liechtenstein', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1ee.png'},
		{'lithuania', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1f9.png'},
		{'luxembourg', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1fa.png'},
		{'macao', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f4.png'},
		{'madagascar', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1ec.png'},
		{'malawi', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1fc.png'},
		{'malaysia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1fe.png'},
		{'maldives', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1fb.png'},
		{'mali', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f1.png'},
		{'malta', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f9.png'},
		{'marshall islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1ed.png'},
		{'martinique', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f6.png'},
		{'mauritania', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f7.png'},
		{'mauritius', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1fa.png'},
		{'mayotte', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fe-1f1f9.png'},
		{'mexico', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1fd.png'},
		{'micronesia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1eb-1f1f2.png'},
		{'moldova', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1e9.png'},
		{'monaco', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1e8.png'},
		{'mongolia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f3.png'},
		{'montenegro', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1ea.png'},
		{'montserrat', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f8.png'},
		{'morocco', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1e6.png'},
		{'mozambique', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1ff.png'},
		{'myanmar', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f2.png'},
		{'namibia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1e6.png'},
		{'nauru', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1f7.png'},
		{'nepal', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1f5.png'},
		{'netherlands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1f1.png'},
		{'new caledonia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1e8.png'},
		{'new zealand', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1ff.png'},
		{'nicaragua', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1ee.png'},
		{'niger', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1ea.png'},
		{'nigeria', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1ec.png'},
		{'niue', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1fa.png'},
		{'norfolk island', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1eb.png'},
		{'north korea', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1f5.png'},
		{'north macedonia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f0.png'},
		{'northern mariana islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1f5.png'},
		{'norge', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f3-1f1f4.png'},
		{'oman', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f4-1f1f2.png'},
		{'pakistan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f0.png'},
		{'palau', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1fc.png'},
		{'palestine', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f8.png'},
		{'panama', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1e6.png'},
		{'papua new guinea', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1ec.png'},
		{'paraguay', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1fe.png'},
		{'peru', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1ea.png'},
		{'philippines', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1ed.png'},
		{'pitcairn islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f3.png'},
		{'poland', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f1.png'},
		{'portugal', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f9.png'},
		{'puerto rico', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f7.png'},
		{'qatar', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f6-1f1e6.png'},
		{'romania', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f7-1f1f4.png'},
		{'russia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f7-1f1fa.png'},
		{'rwanda', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f7-1f1fc.png'},
		{'réunion', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f7-1f1ea.png'},
		{'samoa', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fc-1f1f8.png'},
		{'repubblica-di-san-marino', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f2.png'},
		{'saudi arabia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1e6.png'},
		{'senegal', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f3.png'},
		{'serbia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f7-1f1f8.png'},
		{'seychelles', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1e8.png'},
		{'sierra leone', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f1.png'},
		{'singapore', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1ec.png'},
		{'sint maarten', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1fd.png'},
		{'slovakia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f0.png'},
		{'slovenija', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1ee.png'},
		{'solomon islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1e7.png'},
		{'somalia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f4.png'},
		{'south africa', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ff-1f1e6.png'},
		{'south korea', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1f7.png'},
		{'south sudan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f8.png'},
		{'espana', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1f8.png'},
		{'sri lanka', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1f0.png'},
		{'st. barthélemy', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e7-1f1f1.png'},
		{'st. helena', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1ed.png'},
		{'st. kitts & nevis', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f0-1f1f3.png'},
		{'st. lucia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f1-1f1e8.png'},
		{'st. martin', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f2-1f1eb.png'},
		{'st. pierre & miquelon', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f5-1f1f2.png'},
		{'st. vincent & grenadines', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1e8.png'},
		{'sudan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1e9.png'},
		{'sweden', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1ea.png'},
		{'schweiz', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e8-1f1ed.png'},
		{'syria', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1fe.png'},
		{'são tomé & príncipe', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f8-1f1f9.png'},
		{'taiwan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1fc.png'},
		{'tajikistan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1ef.png'},
		{'tanzania', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1ff.png'},
		{'thailand', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1ed.png'},
		{'timor-leste', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f1.png'},
		{'togo', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1ec.png'},
		{'tokelau', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f0.png'},
		{'tonga', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f4.png'},
		{'trinidad & tobago', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f9.png'},
		{'tunisia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f3.png'},
		{'turkey', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f7.png'},
		{'turkmenistan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1f2.png'},
		{'turks & caicos islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1e8.png'},
		{'tuvalu', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1f9-1f1fb.png'},
		{'u.s. virgin islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1ee.png'},
		{'uganda', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1ec.png'},
		{'ukraine', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1e6.png'},
		{'united arab emirates', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1ea.png'},
		{'united kingdom', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ec-1f1e7.png'},
		{'united states', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1f8.png'},
		{'uruguay', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1fe.png'},
		{'uzbekistan', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fa-1f1ff.png'},
		{'vanuatu', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1fa.png'},
		{'vatican city', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1e6.png'},
		{'venezuela', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1ea.png'},
		{'vietnam', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fb-1f1f3.png'},
		{'wallis & futuna', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fc-1f1eb.png'},
		{'western sahara', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ea-1f1ed.png'},
		{'yemen', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1fe-1f1ea.png'},
		{'zambia', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ff-1f1f2.png'},
		{'zimbabwe', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1ff-1f1fc.png'},
		{'åland islands', 'https://github.githubassets.com/images/icons/emoji/unicode/1f1e6-1f1fd.png'},
		}
		str = str:match('/webcam/([^.]+)')
			if not str then return end
			for i = 1, #t do
				local name = t[i][1]:gsub(' ', '-')
				if name == str then
					return t[i][2]
				end
			end
	 return
	end
	local function LoadFromSite()
		local session = m_simpleTV.Http.New('Mozilla/5.0 (Windows NT 10.0; rv:89.0) Gecko/20100101 Firefox/89.0')
			if not session then return end
		m_simpleTV.Http.SetTimeout(session, 16000)
		local url = 'https://www.skylinewebcams.com'
		local lngUrl = ''
		if m_simpleTV.Interface.GetLanguage() == 'ru' then
			lngUrl = '/ru.html'
		end
		local rc, answer = m_simpleTV.Http.Request(session, {url = url .. lngUrl})
			if rc ~= 200 then
				m_simpleTV.Http.Close(session)
			 return
			end
		answer = answer:match('data%-toggle="dropdown">[^<]+<span class="caret"></span>(.-)<a href="#"')
			if not answer then
				m_simpleTV.Http.Close(session)
			 return
			end
		local t0 = {}
			for w in answer:gmatch('<a.-</a>') do
				local adr = w:match('href="([^"]+)')
				local title = w:match('>([^<]+)')
				if adr and title then
					t0[#t0 + 1] = {}
					t0[#t0].name = title
					t0[#t0].grouplogo = flags(adr)
					t0[#t0].address = url .. adr
				end
			end
			if #t0 == 0 then
				m_simpleTV.Http.Close(session)
			 return
			end
		local t = {}
			for i = 1, #t0 do
				rc, answer = m_simpleTV.Http.Request(session, {url = t0[i].address})
				if rc == 200 then
					for w in answer:gmatch('<a href="%a+/webcam/.-</a>') do
						local adr = w:match('href="([^"]+)')
						local title = w:match('class="tcam">([^<]+)')
						if adr and title then
							t[#t + 1] = {}
							t[#t].name = title:gsub(',', '%%2C')
							t[#t].address = url .. '/' .. adr
							t[#t].group = t0[i].name
							t[#t].group_logo = t0[i].grouplogo
							t[#t].group_is_unique = 1
							t[#t].group_logo_force = 1
							t[#t].logo = w:match('<img src="([^"]+)')
							t[#t].video_title = w:match('class="subt">([^<]+)')
						end
					end
				end
				i = i + 1
			end
		m_simpleTV.Http.Close(session)
			if #t == 0 then return end
	 return t
	end
	function GetList(UpdateID, m3u_file)
			if not UpdateID then return end
			if not m3u_file then return end
			if not TVSources_var.tmp.source[UpdateID] then return end
		local Source = TVSources_var.tmp.source[UpdateID]
		local t_pls = LoadFromSite()
			if not t_pls then
				showMsg(Source.name .. ' ошибка загрузки плейлиста', ARGB(255, 255, 102, 0))
			 return
			end
		showMsg(Source.name .. ' (' .. #t_pls .. ')', ARGB(255, 153, 255, 153))
		local m3ustr = tvs_core.ProcessFilterTable(UpdateID, Source, t_pls)
		local handle = io.open(m3u_file, 'w+')
			if not handle then return end
		handle:write(m3ustr)
		handle:close()
	 return 'ok'
	end
-- debug_in_file(#t_pls .. '\n')
