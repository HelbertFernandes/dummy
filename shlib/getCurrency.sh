#!/bin/bash

getDB_Data(){
	mysql -e "$1" | sed 1d
}
getCurrnecy(){ #http://www.xe.com/currencyconverter/convert/?Amount=1&From=ZWD&To=BRL
	local LOG_FILE="$TMP_DIR/${FILE_BASE}.log";
	local HTML_FILE="$TMP_DIR/${FILE_BASE}.html";
	local KEY="${1}_${2}"

	wget "http://free.currencyconverterapi.com/api/v6/convert?q=${KEY}&compact=y" -o  "$LOG_FILE" -O "$HTML_FILE"
	
	local RET=$(cat "$HTML_FILE")
	local VAL=$(echo "print(${RET}.${KEY}.val);" | js)
	echo $VAL
	rm -f "$LOG_FILE" "$HTML_FILE"
}
get_CodFrom(){
	COD_FROM=$(
		getDB_Data "
			SELECT c.ISO4217
			FROM $TABLE c
			WHERE c.Active=1 AND c.referer IS NULL AND (c.DtCol IS NULL OR c.DtCol<=DATE_SUB(NOW(),INTERVAL $INTERVAL))
			ORDER BY c.DtCol
			LIMIT 1
		"
	)
	[ ! "$COD_FROM" ] && exit;
	getDB_Data "UPDATE $TABLE c SET c.DtCol=NOW() WHERE c.ISO4217='$COD_FROM'"
}
get_CodTo(){
	COD_TO=$(
		getDB_Data "
			SELECT c.ISO4217
			FROM $TABLE c
			WHERE c.Active=1 AND c.referer IS NOT NULL
			LIMIT 1
		"
	)
	[ ! "$COD_TO" ] && exit;
}
saveCurrency(){
	local CR=$1
	local GET_ERROR=0
	[ ! "$CR" ] && GET_ERROR=1 && CR='NULL';
	echo "$COD_FROM - $COD_TO=$CR"
	
	getDB_Data "UPDATE $TABLE c SET c.GetError=$GET_ERROR, c.Rate=$CR WHERE c.ISO4217='$COD_FROM'"
}
startCollect(){
	get_CodTo
	get_CodFrom
	local VAL=$(getCurrnecy "$COD_FROM" "$COD_TO")
	saveCurrency $VAL
}

TMP_DIR='/tmp';
FILE_BASE='currency';
DB_CMD='mysql -u root -e ';
TABLE='db_System.tb_Currency';
INTERVAL='24 HOUR'
#INTERVAL='1 SECOND'

if [ `expr match "$*" '--test\b'` != 0 ];then getDB_Data 'SELECT "Test de Database OK" Teste '; exit; fi
startCollect
exit;

"
USE db_System;
SET NAMES 'utf8';

CREATE TABLE db_System.tb_Currency (
  ISO4217 varchar(9) NOT NULL COMMENT 'ISO-4217',
  idCountry int(11) UNSIGNED DEFAULT NULL,
  CodCountry int(11) UNSIGNED DEFAULT NULL,
  Symbol varchar(36) DEFAULT NULL,
  SymbolDec varchar(20) DEFAULT NULL,
  SymbolHex varchar(15) DEFAULT NULL,
  Entity text DEFAULT NULL,
  Currency varchar(128) DEFAULT NULL,
  `Decimal` smallint(6) DEFAULT NULL,
  Rate double NOT NULL DEFAULT 0,
  referer enum ('1') DEFAULT NULL,
  GetError tinyint(1) UNSIGNED NOT NULL DEFAULT 0,
  Active tinyint(1) UNSIGNED NOT NULL DEFAULT 1,
  DtCol datetime DEFAULT NULL,
  DtUpdate timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (ISO4217),
  INDEX Active (Active),
  INDEX DtUpdate (DtUpdate),
  INDEX idCountry (idCountry),
  UNIQUE INDEX nCode (CodCountry),
  UNIQUE INDEX referer (referer)
);

INSERT INTO db_System.tb_Currency(ISO4217, idCountry, CodCountry, Symbol, SymbolDec, SymbolHex, Entity, Currency, `Decimal`, referer, Active) VALUES
('AED', 71, 784, NULL, NULL, NULL, 'Emirados Árabes Unidos', 'UAE Dirham', 2, NULL, 1),
('AFN', 1, 971, '؋', '1547', '60b', 'Afeganistão', 'Afghani', 2, NULL, 1),
('ALL', 4, 8, 'Lek', '76,101,107', '4c,65,6b', 'Albânia', 'Lek', 2, NULL, 1),
('AMD', 14, 51, NULL, NULL, NULL, 'Arménia', 'Armenian Dram', 2, NULL, 1),
('ANG', 261, 532, 'ƒ', '402', '192', 'Antilhas Holandesas', 'Netherlands Antillian Guilder', 2, NULL, 1),
('AOA', 7, 973, NULL, NULL, NULL, 'Angola', 'Kwanza', 2, NULL, 1),
('ARS', 13, 32, '$', '36', '24', 'Argentina', 'Argentine Peso', 2, NULL, 1),
('ATS', 17, 40, NULL, NULL, NULL, 'AUSTRIA', 'Schilling', 2, NULL, 2),
('AUD', 16, 36, '$', '36', '24', 'Austrália, Território Antárctico Australiano, Ilha Christmas, Ilhas Cocos (Keeling), Ilha Heard e Ilhas McDonald, Kiribati, Nauru, Ilha Norfolk, Tuvalu', 'Australian Dollar', 2, NULL, 1),
('AWG', 15, 533, 'ƒ', '402', '192', 'Aruba', 'Aruban Guilder', 2, NULL, 1),
('AZN', 18, 944, 'ман', '1084,1072,1085', '43c,430,43d', 'Azerbaijão', 'Azerbaijanian Manat', 2, NULL, 1),
('BAM', 30, 977, 'KM', '75,77', '4b,4d', 'Bósnia e Herzegovina', 'Convertible Marks', 2, NULL, 1),
('BBD', 22, 52, '$', '36', '24', 'Barbados', 'Barbados Dollar', 2, NULL, 1),
('BDT', 21, 50, NULL, NULL, NULL, 'Bangladesh', 'Taka', 2, NULL, 1),
('BEF', 23, 56, NULL, NULL, NULL, 'BELGIUM', 'Belgian Franc', 0, NULL, 2),
('BGN', 35, 975, 'лв', '1083,1074', '43b,432', 'Bulgária', 'Bulgarian Lev', 2, NULL, 1),
('BHD', 20, 48, NULL, NULL, NULL, 'Bahrein', 'Bahraini Dinar', 3, NULL, 1),
('BIF', 37, 108, NULL, NULL, NULL, 'Burundi', 'Burundi Franc', 0, NULL, 1),
('BMD', 26, 60, '$', '36', '24', 'Bermudas', 'Bermudian Dollar(customarily known asBermuda Dollar)', 2, NULL, 1),
('BND', 34, 96, '$', '36', '24', 'Brunei, Singapura', 'Brunei Dollar', 2, NULL, 1),
('BOB', 28, 68, '$b', '36,98', '24,62', 'Bolívia', 'Boliviano', 2, NULL, 1),
('BOV', 28, 984, NULL, NULL, NULL, 'Bolívia', 'Boliviano Mvdol – the funds code', 2, NULL, 0),
('BRL', 33, 986, 'R$', '82,36', '52,24', 'Brasil', 'Brazilian Real', 2, '1', 1),
('BSD', 19, 44, '$', '36', '24', 'Bahamas', 'Bahamian Dollar', 2, NULL, 1),
('BTN', 38, 64, NULL, NULL, NULL, 'Butão', 'Bhutanese ngultrum', 2, NULL, 1),
('BWP', 31, 72, 'P', '80', '50', 'Botswana', 'Pula', 2, NULL, 1),
('BYR', 27, 974, 'p.', '112,46', '70,2e', 'Bielorrússia', 'Belarussian Ruble', 0, NULL, 1),
('BZD', 24, 84, 'BZ$', '66,90,36', '42,5a,24', 'Belize', 'Belize Dollar', 2, NULL, 1),
('CAD', 42, 124, '$', '36', '24', 'Canadá', 'Canadian Dollar', 2, NULL, 1),
('CDF', 56, 976, NULL, NULL, NULL, 'República Democrática do Congo', 'Franc Congolais', 2, NULL, 1),
('CHE', 218, 947, NULL, NULL, NULL, 'Suíça', 'WIR Euro Complementary Curncy', 2, NULL, 0),
('CHF', 218, 756, 'CHF', '67,72,70', '43,48,46', 'Suíça', 'Swiss Franc', 2, NULL, 1),
('CHW', 218, 948, NULL, NULL, NULL, 'Suíça', 'WIR Franc – Complementary Currency', 2, NULL, 0),
('CLF', 48, 990, NULL, NULL, NULL, 'Chile', 'Unidad de Fomento funds code', 0, NULL, 1),
('CLP', 48, 152, '$', '36', '24', 'Chile', 'Chilean Peso', 0, NULL, 1),
('CNY', 49, 156, '¥', '165', 'a5', 'República Popular da China', 'Yuan Renminbi', 2, NULL, 1),
('COP', 53, 170, '$', '36', '24', 'Colômbia', 'Colombian Peso', 2, NULL, 1),
('COU', 53, 970, NULL, NULL, NULL, 'Colômbia', 'Unidad de Valor Real', 2, NULL, 0),
('CRC', 61, 188, '₡', '8353', '20a1', 'Costa Rica', 'Costa Rican Colon', 2, NULL, 1),
('CUC', 63, 931, NULL, NULL, NULL, 'Cuba', 'Cuban convertible peso', 2, NULL, 2),
('CUP', 63, 192, '₱', '8369', '20b1', 'Cuba', 'Cuban Peso', 2, NULL, 1),
('CVE', 39, 132, NULL, NULL, NULL, 'Cabo Verde Cabo Verde', 'Cape Verde Escudo', 2, NULL, 1),
('CYP', 50, 196, NULL, NULL, NULL, 'CYPRUS', 'Cyprus Pound', 2, NULL, 2),
('CZK', 47, 203, 'Kč', '75,269', '4b,10d', 'República Checa', 'Czech Koruna', 2, NULL, 1),
('DEM', 5, 276, NULL, NULL, NULL, 'GERMANY', 'Deutsche Mark', 2, NULL, 2),
('DJF', 66, 262, NULL, NULL, NULL, 'Djibouti', 'Djibouti Franc', 0, NULL, 1),
('DKK', 65, 208, 'kr', '107,114', '6b,72', 'Dinamarca, incluindo as  Ilhas Feroé,  Gronelândia', 'Danish Krone', 2, NULL, 1),
('DOP', 68, 214, 'RD$', '82,68,36', '52,44,24', 'República Dominicana', 'Dominican Peso', 2, NULL, 1),
('DZD', 12, 12, NULL, NULL, NULL, 'Argélia', 'Algerian Dinar', 2, NULL, 1),
('ECS', 72, 895, NULL, NULL, NULL, 'Equador', 'Sucre (O dólar americano USD é a moeda corrente no país)', 2, NULL, 0),
('EEK', 78, 233, 'kr', '107,114', '6b,72', 'ESTONIA', 'Kroon', 2, NULL, 2),
('EGP', 69, 818, '£', '163', 'a3', 'Egito', 'Egyptian Pound', 2, NULL, 1),
('ERN', 73, 232, NULL, NULL, NULL, 'Eritreia', 'Nakfa', 2, NULL, 1),
('ESP', 76, 724, NULL, NULL, NULL, 'SPAIN', 'Spanish Peseta', 0, NULL, 2),
('ETB', 79, 230, NULL, NULL, NULL, 'Etiópia', 'Ethiopian Birr', 2, NULL, 1),
('EUR', 116, 978, '€', '8364', '20ac', 'Itália,  Vaticano,  Áustria,  Bélgica,  Espanha,  Estónia,  Finlândia,  Alemanha,  Grécia,  Irlanda,  Andorra,  Luxemburgo,  Mónaco,  Mónaco,  Países Baixos,  Portugal,  São Marino,  Françaincl. Guiana Francesa, Guadalupe, Martinica,Mayotte, Reunião, Sai', 'Euro', 2, NULL, 1),
('FIM', 83, 246, NULL, NULL, NULL, 'FINLAND', 'Markka', 2, NULL, 2),
('FJD', 81, 242, '$', '36', '24', 'Fiji', 'Fiji Dollar', 2, NULL, 1),
('FKP', 140, 238, '£', '163', 'a3', 'Ilhas Malvinas', 'Falkland Islands Pound', 2, NULL, 1),
('FRF', 84, 250, NULL, NULL, NULL, 'FRANCE', 'French Franc', 2, NULL, 2),
('GBP', 187, 826, '£', '163', 'a3', 'Reino Unido, Dependências da Coroa (a Ilha de Man e as Ilhas Channel), determinado Territórios britânicos ultramarinos (Ilhas Geórgia do Sul e Sandwich do Sul, Território Antártico Britânico eTerritório Britânico do Oceano Índico)', 'Pound Sterling', 2, NULL, 1),
('GEL', 88, 981, NULL, NULL, NULL, 'Geórgia', 'Lari', 2, NULL, 1),
('GGP', 97, NULL, '£', '163', 'a3', 'Guernsey', 'Pound', NULL, NULL, 2),
('GHC', 87, 288, '¢', '162', 'a2', 'GHANA', 'Cedi', 2, NULL, 2),
('GHS', 87, 936, NULL, NULL, NULL, 'Gana', 'Cedi', 2, NULL, 1),
('GIP', 90, 292, '£', '163', 'a3', 'Gibraltar', 'Gibraltar Pound', 2, NULL, 1),
('GMD', 86, 270, NULL, NULL, NULL, 'Gâmbia', 'Dalasi', 2, NULL, 1),
('GNF', 101, 324, NULL, NULL, NULL, 'Guiné', 'Guinea Franc', 0, NULL, 1),
('GRD', 91, 300, NULL, NULL, NULL, 'GREECE', 'Drachma', 0, NULL, 2),
('GTQ', 96, 320, 'Q', '81', '51', 'Guatemala', 'Quetzal', 2, NULL, 1),
('GWP', 100, 624, NULL, NULL, NULL, 'Guiné-Bissau', 'Peso da Guiné-Bissau', NULL, NULL, 0),
('GWPXOF', 100, 624952, NULL, NULL, NULL, 'GUINEA-BISSAU', 'Guinea-Bissau PesoCFA Franc BCEAO', 20, NULL, 0),
('GYD', 98, 328, '$', '36', '24', 'Guiana', 'Guyana Dollar', 2, NULL, 1),
('HKD', 106, 344, '$', '36', '24', 'Hong Kong Região Administrativa Especial', 'Hong Kong Dollar', 2, NULL, 1),
('HNL', 105, 340, 'L', '76', '4c', 'Honduras', 'Lempira', 2, NULL, 1),
('HRK', 62, 191, 'kn', '107,110', '6b,6e', 'Croácia', 'Croatian kuna', 2, NULL, 1),
('HTG', 103, 332, NULL, NULL, NULL, 'Haiti', 'Gourde', 2, NULL, 1),
('HTGUSD', 103, 332840, NULL, NULL, NULL, 'HAITI', 'GourdeUS Dollar', 22, NULL, 0),
('HUF', 107, 348, 'Ft', '70,116', '46,74', 'Hungria', 'Forint', 2, NULL, 1),
('IDR', 110, 360, 'Rp', '82,112', '52,70', 'Indonésia', 'Rupiah', 2, NULL, 1),
('IEP', 113, 372, NULL, NULL, NULL, 'IRELAND', 'Irish Pound', 2, NULL, 2),
('ILS', 115, 376, '₪', '8362', '20aa', 'Israel', 'New Israeli Sheqel', 2, NULL, 1),
('IMP', NULL, NULL, '£', '163', 'a3', 'Isle of Man', 'Pound', NULL, NULL, 2),
('INR', 109, 356, NULL, NULL, NULL, 'Brunei,  Índia', 'Indian Rupee', 2, NULL, 1),
('IQD', 111, 368, NULL, NULL, NULL, 'Iraque', 'Iraqi Dinar', 3, NULL, 1),
('IRR', 112, 364, '﷼', '65020', 'fdfc', 'Irã', 'Iranian Rial', 2, NULL, 1),
('ISK', 114, 352, 'kr', '107,114', '6b,72', 'Islândia', 'Iceland Krona', 2, NULL, 1),
('ITL', 116, 380, NULL, NULL, NULL, 'HOLY SEE (VATICAN CITY STATE)', 'Italian Lira', 0, NULL, 2),
('JEP', 119, NULL, '£', '163', 'a3', 'Jersey', 'Pound', NULL, NULL, 2),
('JMD', 117, 388, 'J$', '74,36', '4a,24', 'Jamaica', 'Jamaican Dollar', 2, NULL, 1),
('JOD', 120, 400, NULL, NULL, NULL, 'Jordânia', 'Jordanian Dinar', 3, NULL, 1),
('JPY', 118, 392, '¥', '165', 'a5', 'Japão', 'Yen', 0, NULL, 1),
('KES', 185, 404, NULL, NULL, NULL, 'Quênia', 'Kenyan Shilling', 2, NULL, 1),
('KGS', 186, 417, 'лв', '1083,1074', '43b,432', 'Quirguistão', 'Som', 2, NULL, 1),
('KHR', 40, 116, '៛', '6107', '17db', 'Camboja', 'Riel', 2, NULL, 1),
('KMF', 54, 174, NULL, NULL, NULL, 'Comores', 'Comoro Franc', 0, NULL, 1),
('KPW', 59, 408, NULL, NULL, NULL, 'Coreia do Norte', 'North Korean Won', 2, NULL, 1),
('KRW', 58, 410, NULL, NULL, NULL, 'Coreia do Sul', 'Won', 0, NULL, 1),
('KWD', 122, 414, NULL, NULL, NULL, 'Kuwait', 'Kuwaiti Dinar', 3, NULL, 1),
('KYD', 43, 136, '$', '36', '24', 'Ilhas Cayman', 'Cayman Islands Dollar', 2, NULL, 1),
('KZT', 44, 398, 'лв', '1083,1074', '43b,432', 'Cazaquistão', 'Tenge', 2, NULL, 1),
('LAK', 123, 418, '₭', '8365', '20ad', 'Laos', 'Kip', 2, NULL, 1),
('LBP', 126, 422, '£', '163', 'a3', 'Líbano', 'Lebanese Pound', 2, NULL, 1),
('LKR', 213, 144, '₨', '8360', '20a8', 'Sri Lanka', 'Sri Lanka Rupee', 2, NULL, 1),
('LRD', 127, 430, '$', '36', '24', 'Libéria', 'Liberian Dollar', 2, NULL, 1),
('LSL', 124, 426, NULL, NULL, NULL, 'Lesoto', 'Loti', 2, NULL, 1),
('LTL', 130, 440, 'Lt', '76,116', '4c,74', 'Lituânia', 'Lithuanian Litus', 2, NULL, 1),
('LUF', 131, 442, NULL, NULL, NULL, 'LUXEMBOURG', 'Luxembourg Franc', 0, NULL, 2),
('LVL', 125, 428, 'Ls', '76,115', '4c,73', 'Letônia', 'Latvian Lats', 2, NULL, 1),
('LYD', 128, 434, NULL, NULL, NULL, 'Líbia', 'Libyan Dinar', 3, NULL, 1),
('MAD', 143, 504, NULL, NULL, NULL, 'Marrocos,  Saara Ocidental', 'Moroccan Dirham', 2, NULL, 1),
('MDL', 154, 498, NULL, NULL, NULL, 'Moldávia', 'Moldovan Leu', 2, NULL, 1),
('MGA', 134, 969, NULL, NULL, NULL, 'Madagáscar', 'Ariary', 1, NULL, 1),
('MGF', 134, 450, NULL, NULL, NULL, 'MADAGASCAR', 'Malagasy Franc', 0, NULL, 2),
('MKD', 133, 807, 'ден', '1076,1077,1085', '434,435,43d', 'Macedónia', 'Denar', 2, NULL, 1),
('MMK', 151, 104, NULL, NULL, NULL, 'Myanmar', 'Kyat', 2, NULL, 1),
('MNT', 156, 496, '₮', '8366', '20ae', 'Mongólia', 'Tugrik', 2, NULL, 1),
('MOP', 132, 446, NULL, NULL, NULL, 'Macau Região Administrativa Especial', 'Pataca', 2, NULL, 1),
('MRO', 147, 478, NULL, NULL, NULL, 'Mauritânia', 'Ouguiya', 2, NULL, 1),
('MTL', 139, 470, NULL, NULL, NULL, 'MALTA', 'Maltese Lira', 2, NULL, 2),
('MUR', 146, 480, '₨', '8360', '20a8', 'Maurícia', 'Mauritius Rupee', 2, NULL, 1),
('MVR', 137, 462, NULL, NULL, NULL, 'Maldivas', 'Rufiyaa', 2, NULL, 1),
('MWK', 136, 454, NULL, NULL, NULL, 'Malawi', 'Kwacha', 2, NULL, 1),
('MXN', 150, 484, '$', '36', '24', 'México', 'Peso mexicano', 2, NULL, 1),
('MXNMXV', 150, 484979, NULL, NULL, NULL, 'MEXICO', 'Mexican PesoMexican Unidad de Inversion (UDI)', 22, NULL, 0),
('MXV', 150, 979, NULL, NULL, NULL, 'México', 'Unidade Mexicana de Investimento', 2, NULL, 0),
('MYR', 135, 458, 'RM', '82,77', '52,4d', 'Malásia', 'Malaysian Ringgit', 2, NULL, 1),
('MZM', 153, 508, NULL, NULL, NULL, 'MOZAMBIQUE', 'Metical', 2, NULL, 2),
('MZN', 153, 943, 'MT', '77,84', '4d,54', 'Moçambique', 'Metical', 2, NULL, 1),
('NAD', 159, 516, '$', '36', '24', 'Namíbia', 'Dólar da Namíbia', 2, NULL, 2),
('NGN', 164, 566, '₦', '8358', '20a6', 'Nigéria', 'Naira', 2, NULL, 1),
('NIO', 162, 558, 'C$', '67,36', '43,24', 'Nicarágua', 'Cordoba Oro', 2, NULL, 1),
('NLG', 171, 528, NULL, NULL, NULL, 'NETHERLANDS', 'Netherlands Guilder', 2, NULL, 2),
('NOK', 167, 578, 'kr', '107,114', '6b,72', 'Noruega, Ilha Bouvet, Queen Maud Land, Ilha Peter I', 'Norwegian Krone', 2, NULL, 1),
('NPR', 161, 524, '₨', '8360', '20a8', 'Nepal', 'Nepalese Rupee', 2, NULL, 1),
('NZD', 169, 554, '$', '36', '24', 'Nova Zelândia, incl.  Ilhas Cook,  Niue,  Pitcairn,  Toquelau', 'New Zealand Dollar', 2, NULL, 1),
('OMR', 170, 512, '﷼', '65020', 'fdfc', 'Omã', 'Rial Omani', 3, NULL, 1),
('PAB', 174, 590, 'B/.', '66,47,46', '42,2f,2e', 'Panamá', 'Balboa (O dólar americano USD é a moeda corrente no país)', 2, NULL, 1),
('PABUSD', 174, 590840, NULL, NULL, NULL, 'PANAMA', 'BalboaUS Dollar', 22, NULL, 0),
('PEN', 178, 604, 'S/.', '83,47,46', '53,2f,2e', 'Peru', 'Nuevo Sol', 2, NULL, 1),
('PGK', 175, 598, NULL, NULL, NULL, 'Papua-Nova Guiné', 'Kina', 2, NULL, 1),
('PHP', 82, 608, '₱', '8369', '20b1', 'Filipinas', 'Philippine Peso', 2, NULL, 1),
('PKR', 176, 586, '₨', '8360', '20a8', 'Paquistão', 'Pakistan Rupee', 2, NULL, 1),
('PLN', 181, 985, 'zł', '122,322', '7a,142', 'Polónia', 'Zloty', 2, NULL, 1),
('PTE', 183, 620, NULL, NULL, NULL, 'PORTUGAL', 'Portuguese Escudo', 0, NULL, 2),
('PYG', 177, 600, 'Gs', '71,115', '47,73', 'Paraguai', 'Guarani', 0, NULL, 1),
('QAR', 184, 634, '﷼', '65020', 'fdfc', 'Catar', 'Qatari Rial', 2, NULL, 1),
('ROL', 189, 642, NULL, NULL, NULL, 'ROMANIA', 'Leu', 2, NULL, 2),
('RON', 189, 946, 'lei', '108,101,105', '6c,65,69', 'Roménia', 'RON', 2, NULL, 1),
('RSD', 208, 941, 'Дин.', '1044,1080,1085,46', '414,438,43d,2e', 'Sérvia', 'Dinar Sérvio', 2, NULL, 1),
('RUB', 191, 643, 'руб', '1088,1091,1073', '440,443,431', 'Rússia, Abkhazia, Ossétia do Sul', 'Rublo', 2, NULL, 1),
('RURRUB', 191, 810643, NULL, NULL, NULL, 'RUSSIAN FEDERATION', 'Russian RubleRussian Ruble', 22, NULL, 0),
('RWF', 190, 646, NULL, NULL, NULL, 'Ruanda', 'Rwanda Franc', 0, NULL, 1),
('SAR', 11, 682, '﷼', '65020', 'fdfc', 'Arábia Saudita', 'Saudi Riyal', 2, NULL, 1),
('SBD', 196, 90, '$', '36', '24', 'Ilhas Salomão', 'Solomon Islands Dollar', 2, NULL, 1),
('SCR', 209, 690, '₨', '8360', '20a8', 'Seychelles', 'Seychelles Rupee', 2, NULL, 1),
('SDD', 215, 736, NULL, NULL, NULL, 'SUDAN', 'Sudanese Dinar', 2, NULL, 2),
('SDG', 215, 938, NULL, NULL, NULL, 'Sudão', 'Dinar sudanês', 2, NULL, 1),
('SEK', 217, 752, 'kr', '107,114', '6b,72', 'Suécia', 'Swedish Krona', 2, NULL, 1),
('SGD', 210, 702, '$', '36', '24', 'Singapura', 'Singapore Dollar', 2, NULL, 1),
('SHP', 198, 654, '£', '163', 'a3', 'Santa Helena, Ascensão e Tristão da Cunha', 'Saint Helena Pound', 2, NULL, 1),
('SIT', 75, 705, NULL, NULL, NULL, 'SLOVENIA', 'Tolar', 2, NULL, 2),
('SKK', 74, 703, NULL, NULL, NULL, 'SLOVAKIA', 'Slovak Koruna', 2, NULL, 2),
('SLL', 207, 694, NULL, NULL, NULL, 'Serra Leoa', 'Leone', 2, NULL, 1),
('SOS', 212, 706, 'S', '83', '53', 'Somália', 'Somali Shilling', 2, NULL, 1),
('SRD', 219, 968, '$', '36', '24', 'Suriname', 'Dólar do Suriname', 2, NULL, 1),
('SRG', 219, 740, NULL, NULL, NULL, 'SURINAME', 'Suriname Guilder', 2, NULL, 2),
('STD', 204, 678, NULL, NULL, NULL, 'São Tomé e Príncipe', 'Dobra', 2, NULL, 1),
('SVC', 70, 222, '$', '36', '24', 'El Salvador', 'El Salvador Colon', 2, NULL, 1),
('SYP', 211, 760, '£', '163', 'a3', 'Síria', 'Syrian Pound', 2, NULL, 1),
('SZL', 214, 748, NULL, NULL, NULL, 'Suazilândia', 'Lilangeni', 2, NULL, 1),
('THB', 221, 764, '฿', '3647', 'e3f', 'Tailândia', 'Baht', 2, NULL, 1),
('TJR', 223, 762, NULL, NULL, NULL, 'TAJIKISTAN', 'Tajik Ruble', 0, NULL, 0),
('TJS', 223, 972, NULL, NULL, NULL, 'Tajiquistão', 'Somoni', 2, NULL, 1),
('TMM', 234, 795, NULL, NULL, NULL, 'TURKMENISTAN', 'Manat', 2, NULL, 2),
('TMT', 234, 934, NULL, NULL, NULL, 'Turquemenistão', 'Manat turcomano', 2, NULL, 1),
('TND', 232, 788, NULL, NULL, NULL, 'Tunísia', 'Tunisian Dinar', 3, NULL, 1),
('TOP', 230, 776, NULL, NULL, NULL, 'Tonga', 'Pa’anga', 2, NULL, 1),
('TPEIDR', 227, 626360, NULL, NULL, NULL, 'EAST TIMOR', 'Timor EscudoRupiah', 2, NULL, 0),
('TRL', 235, 792, '₤', '8356', '20a4', 'TURKEY', 'Turkish Lira', 0, NULL, 2),
('TRY', 235, 949, NULL, NULL, NULL, 'Turquia', 'Nova Lira turca', 2, NULL, 1),
('TTD', 231, 780, 'TT$', '84,84,36', '54,54,24', 'Trinidad e Tobago', 'Trinidad and Tobago Dollar', 2, NULL, 1),
('TVD', 236, NULL, '$', '36', '24', 'Tuvalu', 'Dollar', NULL, NULL, 2),
('TWD', 222, 901, 'NT$', '78,84,36', '4e,54,24', 'Taiwan and other islands that are under the effective control of the Republic of China (ROC)', 'New Taiwan Dollar', 2, NULL, 1),
('TZS', 224, 834, NULL, NULL, NULL, 'Tanzânia', 'Tanzanian Shilling', 2, NULL, 1),
('UAH', 237, 980, '₴', '8372', '20b4', 'Ucrânia', 'Hryvnia', 2, NULL, 1),
('UGX', 238, 800, NULL, NULL, NULL, 'Uganda', 'Uganda Shilling', 2, NULL, 1),
('USD', 77, 840, '$', '36', '24', 'Estados Unidos e também:  Equador,  El Salvador,  Guam,  Haiti,  Ilhas Marshall, Estados Federados da Micronésia,  Marianas Setentrionais,  Palau,  Panamá,  Timor-Leste,  Turcas e Caicos,  Ilhas Virgens Americanas,  Samoa,  Samoa Americana,  Território B', 'US Dollar', 2, NULL, 1),
('USDUSSUSN', 77, 840998997, NULL, NULL, NULL, 'UNITED STATES', 'US Dollar(Same day)(Next day)', 222, NULL, 0),
('USN', 77, 997, NULL, NULL, NULL, 'Estados Unidos', 'United States dollar (next day) (funds code)', 2, NULL, 0),
('USS', 77, 998, NULL, NULL, NULL, 'Estados Unidos', 'United States dollar (same day) (funds code) (one source claims it is no longer used, but it is still on the ISO 4217-MA list)', 2, NULL, 0),
('UYI', 239, 940, NULL, NULL, NULL, 'Uruguai', 'Peso do Uruguay em Unidades Indexadas', NULL, NULL, 0),
('UYU', 239, 858, '$U', '36,85', '24,55', 'Uruguai', 'Peso Uruguayo', 2, NULL, 1),
('UZS', 240, 860, 'лв', '1083,1074', '43b,432', 'Uzbequistão', 'Uzbekistan Sum', 2, NULL, 1),
('VEB', 243, 862, NULL, NULL, NULL, 'VENEZUELA', 'Bolivar', 2, NULL, 2),
('VEF', 243, 937, 'Bs', '66,115', '42,73', 'Venezuela', 'Venezuelan bolívar fuerte', 2, NULL, 1),
('VND', 244, 704, '₫', '8363', '20ab', 'Vietname', 'Dong', 2, NULL, 1),
('VUV', 241, 548, NULL, NULL, NULL, 'Vanuatu', 'Vatu', 0, NULL, 1),
('WST', 194, 882, NULL, NULL, NULL, 'Samoa', 'Tala', 2, NULL, 1),
('XAF', 41, 950, NULL, NULL, NULL, 'Camarões,  República Centro-Africana, República do Congo,  Chade,  Guiné Equatorial,  Gabão', 'CFA Franc BEAC', 0, NULL, 1),
('XAG', NULL, 961, NULL, NULL, NULL, 'uma onça Troy', 'Prata', NULL, NULL, 2),
('XAU', NULL, 959, NULL, NULL, NULL, 'uma onça Troy', 'Ouro', NULL, NULL, 2),
('XBA', NULL, 955, NULL, NULL, NULL, NULL, 'European Composite Unit(EURCO) (bond market unit)', NULL, NULL, 0),
('XBB', NULL, 956, NULL, NULL, NULL, NULL, 'European Monetary Unit(E.M.U.-6) (bond market unit)', NULL, NULL, 0),
('XBC', NULL, 957, NULL, NULL, NULL, NULL, 'European Unit of Account 9(E.U.A.-9) (bond market unit)', NULL, NULL, 0),
('XBD', NULL, 958, NULL, NULL, NULL, NULL, 'European Unit of Account 17(E.U.A.-17) (bond market unit)', NULL, NULL, 0),
('XCD', 8, 951, '$', '36', '24', 'Anguilla,  Antígua e Barbuda,  Dominica,  Granada,  Montserrat,  São Cristóvão e Nevis,  Santa Lúcia,  São Vicente e Granadinas', 'East Caribbean Dollar', 2, NULL, 1),
('XDR', NULL, 960, NULL, NULL, NULL, 'International Monetary Fund', 'SDR', NULL, NULL, 2),
('XFU', NULL, 0, NULL, NULL, NULL, 'International Union of Railways', 'UIC franc(special settlement currency)', NULL, NULL, 0),
('XOF', 25, 952, NULL, NULL, NULL, 'Benim,  Burkina Faso,  Costa do Marfim,  Guiné-Bissau,  Mali,  Níger,  Senegal,  Togo', 'CFA Franc BCEAO', 0, NULL, 1),
('XPD', NULL, 964, NULL, NULL, NULL, 'uma onça Troy', 'Paládio', NULL, NULL, 2),
('XPF', 180, 953, NULL, NULL, NULL, 'Polinésia Francesa,  Nova Caledônia,  Wallis e Futuna', 'CFP Franc', 0, NULL, 1),
('XPT', NULL, 962, NULL, NULL, NULL, 'uma onça Troy', 'Platina', NULL, NULL, 2),
('XTS', NULL, 963, NULL, NULL, NULL, NULL, 'Reservado para efeitos de teste', NULL, NULL, 0),
('XXX', NULL, 999, NULL, NULL, NULL, NULL, 'No currency', NULL, NULL, 0),
('YER', 108, 886, '﷼', '65020', 'fdfc', 'Iémen/Iêmen', 'Yemeni Rial', 2, NULL, 1),
('YUM', NULL, 891, NULL, NULL, NULL, 'YUGOSLAVIA', 'Yugoslavian Dinar', 2, NULL, 0),
('ZAR', 2, 710, 'R', '82', '52', 'Lesoto,  Namíbia,  África do Sul', 'Rand', 2, NULL, 1),
('ZARLSL', 124, 710426, NULL, NULL, NULL, 'LESOTHO', 'RandLoti', 22, NULL, 0),
('ZARNAD', 159, 710516, NULL, NULL, NULL, 'NAMIBIA', 'RandNamibia Dollar', 22, NULL, 0),
('ZMK', 248, 894, NULL, NULL, NULL, 'Zâmbia', 'Kwacha', 2, NULL, 1),
('ZWD', 249, 716, 'Z$', '90,36', '5a,24', 'ZIMBABWE', 'Zimbabwe Dollar', 2, NULL, 2),
('ZWL', 249, 932, NULL, NULL, NULL, 'Zimbabwe', 'Zimbabwe dollar', 2, NULL, 1);
"