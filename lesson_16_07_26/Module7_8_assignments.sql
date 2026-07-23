--DDL (one non-normalized table)
CREATE SCHEMA IF NOT EXISTS practice_module_7;
SET SEARCH_PATH = 'practice_module_7';
DROP TABLE IF EXISTS countries;
CREATE TABLE countries
(
    country_id       serial PRIMARY KEY,
    name             varchar(80)    NOT NULL UNIQUE,
    iso3             char(3)        NOT NULL UNIQUE,
    capital          varchar(80),
    continent        varchar(20)    NOT NULL,
    region           varchar(40)    NOT NULL,
    population       bigint         NOT NULL CHECK (population >= 0),
    area_km2         numeric(12, 2) NOT NULL CHECK (area_km2 >= 0),
    gdp_usd_millions numeric(14, 2) NOT NULL CHECK (gdp_usd_millions >= 0),
    life_expectancy  numeric(4, 1) CHECK (life_expectancy BETWEEN 0 AND 120),
    currency         varchar(30),
    government_form  varchar(40),
    landlocked       boolean        NOT NULL DEFAULT FALSE,
    un_member        boolean        NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_countries_continent ON countries (continent);
CREATE INDEX idx_countries_region ON countries (region);

-- DML (193 rows)
INSERT INTO countries
(name, iso3, capital, continent, region, population, area_km2,
 gdp_usd_millions, life_expectancy, currency, government_form, landlocked, un_member)
VALUES ('Algeria', 'DZA', 'Algiers', 'Africa', 'Northern Africa', 47400000, 2381741, 285724, 76.5, 'Dinar', 'Republic',
        FALSE, TRUE),
       ('Egypt', 'EGY', 'Cairo', 'Africa', 'Northern Africa', 118400000, 1002450, 364640, 70.7, 'Pound', 'Republic',
        FALSE, TRUE),
       ('Libya', 'LBY', 'Tripoli', 'Africa', 'Northern Africa', 7400000, 1759540, 44732, 71.6, 'Dinar', 'Provisional',
        FALSE, TRUE),
       ('Morocco', 'MAR', 'Rabat', 'Africa', 'Northern Africa', 38400000, 446550, 182587, 75.0, 'Dirham',
        'Constitutional monarchy', FALSE, TRUE),
       ('Sudan', 'SDN', 'Khartoum', 'Africa', 'Northern Africa', 50400000, 1886068, 39718, 65.9, 'Pound', 'Provisional',
        FALSE, TRUE),
       ('Tunisia', 'TUN', 'Tunis', 'Africa', 'Northern Africa', 12300000, 163610, 57589, 74.4, 'Dinar', 'Republic',
        FALSE, TRUE),
       ('Benin', 'BEN', 'Porto-Novo', 'Africa', 'Sub-Saharan Africa', 14800000, 112622, 24382, 60.8, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('Burkina Faso', 'BFA', 'Ouagadougou', 'Africa', 'Sub-Saharan Africa', 24100000, 272967, 27140, 61.1,
        'CFA franc', 'Provisional', TRUE, TRUE),
       ('Cape Verde', 'CPV', 'Praia', 'Africa', 'Sub-Saharan Africa', 530000, 4033, 3000, 76.1, 'Escudo', 'Republic',
        FALSE, TRUE),
       ('Ivory Coast', 'CIV', 'Yamoussoukro', 'Africa', 'Sub-Saharan Africa', 32000000, 322463, 98885, 61.9,
        'CFA franc', 'Republic', FALSE, TRUE),
       ('Gambia', 'GMB', 'Banjul', 'Africa', 'Sub-Saharan Africa', 2800000, 11295, 2900, 63.9, 'Dalasi', 'Republic',
        FALSE, TRUE),
       ('Ghana', 'GHA', 'Accra', 'Africa', 'Sub-Saharan Africa', 34900000, 238533, 114708, 64.9, 'Cedi', 'Republic',
        FALSE, TRUE),
       ('Guinea', 'GIN', 'Conakry', 'Africa', 'Sub-Saharan Africa', 15100000, 245857, 27215, 60.7, 'Franc',
        'Provisional', FALSE, TRUE),
       ('Guinea-Bissau', 'GNB', 'Bissau', 'Africa', 'Sub-Saharan Africa', 2250000, 36125, 2300, 60.3, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('Liberia', 'LBR', 'Monrovia', 'Africa', 'Sub-Saharan Africa', 5700000, 111369, 4900, 62.2, 'Dollar', 'Republic',
        FALSE, TRUE),
       ('Mali', 'MLI', 'Bamako', 'Africa', 'Sub-Saharan Africa', 24500000, 1240192, 30050, 60.4, 'CFA franc',
        'Provisional', TRUE, TRUE),
       ('Mauritania', 'MRT', 'Nouakchott', 'Africa', 'Sub-Saharan Africa', 5300000, 1030700, 11600, 68.5, 'Ouguiya',
        'Republic', FALSE, TRUE),
       ('Niger', 'NER', 'Niamey', 'Africa', 'Sub-Saharan Africa', 27900000, 1267000, 21836, 61.2, 'CFA franc',
        'Provisional', TRUE, TRUE),
       ('Nigeria', 'NGA', 'Abuja', 'Africa', 'Sub-Saharan Africa', 237500000, 923768, 290491, 54.6, 'Naira',
        'Federal republic', FALSE, TRUE),
       ('Senegal', 'SEN', 'Dakar', 'Africa', 'Sub-Saharan Africa', 18900000, 196722, 37116, 68.7, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('Sierra Leone', 'SLE', 'Freetown', 'Africa', 'Sub-Saharan Africa', 8900000, 71740, 7700, 61.8, 'Leone',
        'Republic', FALSE, TRUE),
       ('Togo', 'TGO', 'Lome', 'Africa', 'Sub-Saharan Africa', 9700000, 56785, 10400, 62.2, 'CFA franc', 'Republic',
        FALSE, TRUE),
       ('Cameroon', 'CMR', 'Yaounde', 'Africa', 'Sub-Saharan Africa', 29900000, 475442, 59282, 63.7, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('Central African Republic', 'CAF', 'Bangui', 'Africa', 'Sub-Saharan Africa', 5500000, 622984, 3000, 57.4,
        'CFA franc', 'Republic', TRUE, TRUE),
       ('Chad', 'TCD', 'N''Djamena', 'Africa', 'Sub-Saharan Africa', 20700000, 1284000, 22092, 55.1, 'CFA franc',
        'Republic', TRUE, TRUE),
       ('Congo', 'COG', 'Brazzaville', 'Africa', 'Sub-Saharan Africa', 6500000, 342000, 15592, 65.6, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('DR Congo', 'COD', 'Kinshasa', 'Africa', 'Sub-Saharan Africa', 112800000, 2344858, 92833, 62.1, 'Franc',
        'Republic', FALSE, TRUE),
       ('Equatorial Guinea', 'GNQ', 'Malabo', 'Africa', 'Sub-Saharan Africa', 1900000, 28051, 10900, 62.6, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('Gabon', 'GAB', 'Libreville', 'Africa', 'Sub-Saharan Africa', 2600000, 267668, 21624, 68.3, 'CFA franc',
        'Republic', FALSE, TRUE),
       ('Sao Tome and Principe', 'STP', 'Sao Tome', 'Africa', 'Sub-Saharan Africa', 240000, 964, 750, 69.7, 'Dobra',
        'Republic', FALSE, TRUE),
       ('Burundi', 'BDI', 'Gitega', 'Africa', 'Sub-Saharan Africa', 14400000, 27834, 2700, 63.7, 'Franc', 'Republic',
        TRUE, TRUE),
       ('Comoros', 'COM', 'Moroni', 'Africa', 'Sub-Saharan Africa', 870000, 2235, 1500, 66.8, 'Franc', 'Republic',
        FALSE, TRUE),
       ('Djibouti', 'DJI', 'Djibouti', 'Africa', 'Sub-Saharan Africa', 1200000, 23200, 4600, 65.0, 'Franc', 'Republic',
        FALSE, TRUE),
       ('Eritrea', 'ERI', 'Asmara', 'Africa', 'Sub-Saharan Africa', 3600000, 117600, 2700, 68.5, 'Nakfa', 'Republic',
        FALSE, TRUE),
       ('Ethiopia', 'ETH', 'Addis Ababa', 'Africa', 'Sub-Saharan Africa', 135500000, 1104300, 109109, 67.3, 'Birr',
        'Federal republic', TRUE, TRUE),
       ('Kenya', 'KEN', 'Nairobi', 'Africa', 'Sub-Saharan Africa', 57500000, 580367, 136455, 63.6, 'Shilling',
        'Republic', FALSE, TRUE),
       ('Madagascar', 'MDG', 'Antananarivo', 'Africa', 'Sub-Saharan Africa', 32700000, 587041, 19556, 65.9, 'Ariary',
        'Republic', FALSE, TRUE),
       ('Malawi', 'MWI', 'Lilongwe', 'Africa', 'Sub-Saharan Africa', 22200000, 118484, 15047, 66.0, 'Kwacha',
        'Republic', TRUE, TRUE),
       ('Mauritius', 'MUS', 'Port Louis', 'Africa', 'Sub-Saharan Africa', 1270000, 2040, 16126, 74.9, 'Rupee',
        'Republic', FALSE, TRUE),
       ('Mozambique', 'MOZ', 'Maputo', 'Africa', 'Sub-Saharan Africa', 35600000, 801590, 22338, 62.0, 'Metical',
        'Republic', FALSE, TRUE),
       ('Rwanda', 'RWA', 'Kigali', 'Africa', 'Sub-Saharan Africa', 14600000, 26338, 15973, 67.8, 'Franc', 'Republic',
        TRUE, TRUE),
       ('Seychelles', 'SYC', 'Victoria', 'Africa', 'Sub-Saharan Africa', 130000, 455, 2300, 75.1, 'Rupee', 'Republic',
        FALSE, TRUE),
       ('Somalia', 'SOM', 'Mogadishu', 'Africa', 'Sub-Saharan Africa', 19700000, 637657, 13300, 58.8, 'Shilling',
        'Federal republic', FALSE, TRUE),
       ('South Sudan', 'SSD', 'Juba', 'Africa', 'Sub-Saharan Africa', 11900000, 619745, 3900, 57.6, 'Pound', 'Republic',
        TRUE, TRUE),
       ('Tanzania', 'TZA', 'Dodoma', 'Africa', 'Sub-Saharan Africa', 70500000, 945087, 87344, 66.8, 'Shilling',
        'Republic', FALSE, TRUE),
       ('Uganda', 'UGA', 'Kampala', 'Africa', 'Sub-Saharan Africa', 51400000, 241550, 66014, 68.2, 'Shilling',
        'Republic', TRUE, TRUE),
       ('Zambia', 'ZMB', 'Lusaka', 'Africa', 'Sub-Saharan Africa', 21900000, 752618, 28880, 66.3, 'Kwacha', 'Republic',
        TRUE, TRUE),
       ('Zimbabwe', 'ZWE', 'Harare', 'Africa', 'Sub-Saharan Africa', 16900000, 390757, 53474, 62.8, 'ZiG', 'Republic',
        TRUE, TRUE),
       ('Angola', 'AGO', 'Luanda', 'Africa', 'Sub-Saharan Africa', 38400000, 1246700, 141728, 63.0, 'Kwanza',
        'Republic', FALSE, TRUE),
       ('Botswana', 'BWA', 'Gaborone', 'Africa', 'Sub-Saharan Africa', 2600000, 582000, 19533, 69.2, 'Pula', 'Republic',
        TRUE, TRUE),
       ('Eswatini', 'SWZ', 'Mbabane', 'Africa', 'Sub-Saharan Africa', 1250000, 17364, 5400, 64.1, 'Lilangeni',
        'Absolute monarchy', TRUE, TRUE),
       ('Lesotho', 'LSO', 'Maseru', 'Africa', 'Sub-Saharan Africa', 2400000, 30355, 2500, 57.4, 'Loti',
        'Constitutional monarchy', TRUE, TRUE),
       ('Namibia', 'NAM', 'Windhoek', 'Africa', 'Sub-Saharan Africa', 3100000, 825615, 14600, 67.4, 'Dollar',
        'Republic', FALSE, TRUE),
       ('South Africa', 'ZAF', 'Pretoria', 'Africa', 'Sub-Saharan Africa', 64000000, 1221037, 427141, 66.1, 'Rand',
        'Republic', FALSE, TRUE),
       ('China', 'CHN', 'Beijing', 'Asia', 'Eastern Asia', 1416100000, 9596960, 19626247, 78.6, 'Yuan',
        'Socialist republic', FALSE, TRUE),
       ('Japan', 'JPN', 'Tokyo', 'Asia', 'Eastern Asia', 123100000, 377930, 4435163, 84.7, 'Yen',
        'Constitutional monarchy', FALSE, TRUE),
       ('Mongolia', 'MNG', 'Ulaanbaatar', 'Asia', 'Eastern Asia', 3500000, 1564110, 25370, 72.5, 'Tugrik', 'Republic',
        TRUE, TRUE),
       ('North Korea', 'PRK', 'Pyongyang', 'Asia', 'Eastern Asia', 26200000, 120538, 16447, 73.6, 'Won',
        'Socialist republic', FALSE, TRUE),
       ('South Korea', 'KOR', 'Seoul', 'Asia', 'Eastern Asia', 51700000, 100210, 1872375, 84.3, 'Won', 'Republic',
        FALSE, TRUE),
       ('Afghanistan', 'AFG', 'Kabul', 'Asia', 'Southern Asia', 43800000, 652230, 19662, 65.0, 'Afghani', 'Provisional',
        TRUE, TRUE),
       ('Bangladesh', 'BGD', 'Dhaka', 'Asia', 'Southern Asia', 175700000, 147570, 457904, 74.7, 'Taka', 'Republic',
        FALSE, TRUE),
       ('Bhutan', 'BTN', 'Thimphu', 'Asia', 'Southern Asia', 800000, 38394, 3300, 72.9, 'Ngultrum',
        'Constitutional monarchy', TRUE, TRUE),
       ('India', 'IND', 'New Delhi', 'Asia', 'Southern Asia', 1463900000, 3287263, 3916312, 72.0, 'Rupee',
        'Federal republic', FALSE, TRUE),
       ('Iran', 'IRN', 'Tehran', 'Asia', 'Southern Asia', 92400000, 1648195, 371196, 77.6, 'Rial', 'Islamic republic',
        FALSE, TRUE),
       ('Maldives', 'MDV', 'Male', 'Asia', 'Southern Asia', 530000, 300, 7900, 81.0, 'Rufiyaa', 'Republic', FALSE,
        TRUE),
       ('Nepal', 'NPL', 'Kathmandu', 'Asia', 'Southern Asia', 29700000, 147181, 44810, 71.3, 'Rupee',
        'Federal republic', TRUE, TRUE),
       ('Pakistan', 'PAK', 'Islamabad', 'Asia', 'Southern Asia', 255200000, 881912, 407786, 67.6, 'Rupee',
        'Federal republic', FALSE, TRUE),
       ('Sri Lanka', 'LKA', 'Colombo', 'Asia', 'Southern Asia', 22000000, 65610, 98964, 77.5, 'Rupee', 'Republic',
        FALSE, TRUE),
       ('Brunei', 'BRN', 'Bandar Seri Begawan', 'Asia', 'South-Eastern Asia', 460000, 5765, 15942, 75.3, 'Dollar',
        'Absolute monarchy', FALSE, TRUE),
       ('Cambodia', 'KHM', 'Phnom Penh', 'Asia', 'South-Eastern Asia', 17400000, 181035, 49288, 70.7, 'Riel',
        'Constitutional monarchy', FALSE, TRUE),
       ('Indonesia', 'IDN', 'Jakarta', 'Asia', 'South-Eastern Asia', 285700000, 1904569, 1445642, 71.1, 'Rupiah',
        'Republic', FALSE, TRUE),
       ('Laos', 'LAO', 'Vientiane', 'Asia', 'South-Eastern Asia', 7800000, 236800, 17822, 69.2, 'Kip',
        'Socialist republic', TRUE, TRUE),
       ('Malaysia', 'MYS', 'Kuala Lumpur', 'Asia', 'South-Eastern Asia', 35100000, 330803, 472193, 76.7, 'Ringgit',
        'Constitutional monarchy', FALSE, TRUE),
       ('Myanmar', 'MMR', 'Naypyidaw', 'Asia', 'South-Eastern Asia', 54900000, 676578, 82400, 66.9, 'Kyat',
        'Provisional', FALSE, TRUE),
       ('Philippines', 'PHL', 'Manila', 'Asia', 'South-Eastern Asia', 116800000, 300000, 487161, 69.8, 'Peso',
        'Republic', FALSE, TRUE),
       ('Singapore', 'SGP', 'Singapore', 'Asia', 'South-Eastern Asia', 6000000, 710, 603870, 84.1, 'Dollar', 'Republic',
        FALSE, TRUE),
       ('Thailand', 'THA', 'Bangkok', 'Asia', 'South-Eastern Asia', 71600000, 513120, 577010, 79.7, 'Baht',
        'Constitutional monarchy', FALSE, TRUE),
       ('Timor-Leste', 'TLS', 'Dili', 'Asia', 'South-Eastern Asia', 1400000, 14874, 2200, 70.6, 'Dollar', 'Republic',
        FALSE, TRUE),
       ('Vietnam', 'VNM', 'Hanoi', 'Asia', 'South-Eastern Asia', 101600000, 331212, 494046, 74.6, 'Dong',
        'Socialist republic', FALSE, TRUE),
       ('Kazakhstan', 'KAZ', 'Astana', 'Asia', 'Central Asia', 20600000, 2724900, 302746, 74.4, 'Tenge', 'Republic',
        TRUE, TRUE),
       ('Kyrgyzstan', 'KGZ', 'Bishkek', 'Asia', 'Central Asia', 7200000, 199951, 21567, 72.3, 'Som', 'Republic', TRUE,
        TRUE),
       ('Tajikistan', 'TJK', 'Dushanbe', 'Asia', 'Central Asia', 10600000, 143100, 17542, 71.8, 'Somoni', 'Republic',
        TRUE, TRUE),
       ('Turkmenistan', 'TKM', 'Ashgabat', 'Asia', 'Central Asia', 7500000, 488100, 77398, 69.4, 'Manat', 'Republic',
        TRUE, TRUE),
       ('Uzbekistan', 'UZB', 'Tashkent', 'Asia', 'Central Asia', 37100000, 447400, 147069, 72.4, 'Som', 'Republic',
        TRUE, TRUE),
       ('Armenia', 'ARM', 'Yerevan', 'Asia', 'Western Asia', 3000000, 29743, 29243, 76.1, 'Dram', 'Republic', TRUE,
        TRUE),
       ('Bahrain', 'BHR', 'Manama', 'Asia', 'Western Asia', 1600000, 765, 47538, 79.7, 'Dinar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Cyprus', 'CYP', 'Nicosia', 'Asia', 'Western Asia', 1350000, 9251, 41019, 81.7, 'Euro', 'Republic', FALSE,
        TRUE),
       ('Georgia', 'GEO', 'Tbilisi', 'Asia', 'Western Asia', 3800000, 69700, 38216, 74.0, 'Lari', 'Republic', FALSE,
        TRUE),
       ('Iraq', 'IRQ', 'Baghdad', 'Asia', 'Western Asia', 46500000, 438317, 264167, 72.3, 'Dinar', 'Federal republic',
        FALSE, TRUE),
       ('Israel', 'ISR', 'Jerusalem', 'Asia', 'Western Asia', 9900000, 20770, 610778, 82.7, 'Shekel', 'Republic', FALSE,
        TRUE),
       ('Jordan', 'JOR', 'Amman', 'Asia', 'Western Asia', 11600000, 89342, 61692, 76.0, 'Dinar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Kuwait', 'KWT', 'Kuwait City', 'Asia', 'Western Asia', 5000000, 17818, 157835, 80.4, 'Dinar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Lebanon', 'LBN', 'Beirut', 'Asia', 'Western Asia', 5800000, 10452, 34497, 76.0, 'Pound', 'Republic', FALSE,
        TRUE),
       ('Oman', 'OMN', 'Muscat', 'Asia', 'Western Asia', 5300000, 309500, 106127, 80.0, 'Rial', 'Absolute monarchy',
        FALSE, TRUE),
       ('Qatar', 'QAT', 'Doha', 'Asia', 'Western Asia', 3100000, 11586, 221229, 81.5, 'Riyal', 'Absolute monarchy',
        FALSE, TRUE),
       ('Saudi Arabia', 'SAU', 'Riyadh', 'Asia', 'Western Asia', 34600000, 2149690, 1276943, 78.7, 'Riyal',
        'Absolute monarchy', FALSE, TRUE),
       ('Syria', 'SYR', 'Damascus', 'Asia', 'Western Asia', 24700000, 185180, 19993, 71.5, 'Pound', 'Provisional',
        FALSE, TRUE),
       ('Turkey', 'TUR', 'Ankara', 'Asia', 'Western Asia', 87700000, 783562, 1597301, 77.2, 'Lira', 'Republic', FALSE,
        TRUE),
       ('United Arab Emirates', 'ARE', 'Abu Dhabi', 'Asia', 'Western Asia', 10900000, 83600, 571643, 79.9, 'Dirham',
        'Federal monarchy', FALSE, TRUE),
       ('Yemen', 'YEM', 'Sanaa', 'Asia', 'Western Asia', 40600000, 527968, 17000, 65.5, 'Rial', 'Provisional', FALSE,
        TRUE),
       ('Denmark', 'DNK', 'Copenhagen', 'Europe', 'Northern Europe', 6000000, 43094, 461718, 81.9, 'Krone',
        'Constitutional monarchy', FALSE, TRUE),
       ('Estonia', 'EST', 'Tallinn', 'Europe', 'Northern Europe', 1370000, 45228, 47004, 79.1, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Finland', 'FIN', 'Helsinki', 'Europe', 'Northern Europe', 5600000, 338424, 316860, 82.0, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Iceland', 'ISL', 'Reykjavik', 'Europe', 'Northern Europe', 390000, 103000, 38583, 82.6, 'Krona', 'Republic',
        FALSE, TRUE),
       ('Ireland', 'IRL', 'Dublin', 'Europe', 'Northern Europe', 5300000, 70273, 718140, 82.7, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Latvia', 'LVA', 'Riga', 'Europe', 'Northern Europe', 1850000, 64559, 48591, 76.2, 'Euro', 'Republic', FALSE,
        TRUE),
       ('Lithuania', 'LTU', 'Vilnius', 'Europe', 'Northern Europe', 2850000, 65300, 94927, 77.0, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Norway', 'NOR', 'Oslo', 'Europe', 'Northern Europe', 5600000, 323802, 530756, 83.4, 'Krone',
        'Constitutional monarchy', FALSE, TRUE),
       ('Sweden', 'SWE', 'Stockholm', 'Europe', 'Northern Europe', 10600000, 450295, 668999, 83.4, 'Krona',
        'Constitutional monarchy', FALSE, TRUE),
       ('United Kingdom', 'GBR', 'London', 'Europe', 'Northern Europe', 69600000, 242495, 4003022, 81.3, 'Pound',
        'Constitutional monarchy', FALSE, TRUE),
       ('Albania', 'ALB', 'Tirana', 'Europe', 'Southern Europe', 2750000, 28748, 30279, 79.6, 'Lek', 'Republic', FALSE,
        TRUE),
       ('Andorra', 'AND', 'Andorra la Vella', 'Europe', 'Southern Europe', 81000, 468, 4000, 84.0, 'Euro',
        'Parliamentary co-principality', TRUE, TRUE),
       ('Bosnia and Herzegovina', 'BIH', 'Sarajevo', 'Europe', 'Southern Europe', 3100000, 51209, 32962, 77.8, 'Mark',
        'Federal republic', FALSE, TRUE),
       ('Croatia', 'HRV', 'Zagreb', 'Europe', 'Southern Europe', 3870000, 56594, 106055, 78.6, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Greece', 'GRC', 'Athens', 'Europe', 'Southern Europe', 10400000, 131957, 280476, 81.9, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Italy', 'ITA', 'Rome', 'Europe', 'Southern Europe', 58900000, 301340, 2550111, 83.7, 'Euro', 'Republic', FALSE,
        TRUE),
       ('Malta', 'MLT', 'Valletta', 'Europe', 'Southern Europe', 550000, 316, 27756, 83.6, 'Euro', 'Republic', FALSE,
        TRUE),
       ('Montenegro', 'MNE', 'Podgorica', 'Europe', 'Southern Europe', 630000, 13812, 8900, 77.0, 'Euro', 'Republic',
        FALSE, TRUE),
       ('North Macedonia', 'MKD', 'Skopje', 'Europe', 'Southern Europe', 1800000, 25713, 19142, 76.5, 'Denar',
        'Republic', TRUE, TRUE),
       ('Portugal', 'PRT', 'Lisbon', 'Europe', 'Southern Europe', 10600000, 92090, 346412, 82.4, 'Euro', 'Republic',
        FALSE, TRUE),
       ('San Marino', 'SMR', 'San Marino', 'Europe', 'Southern Europe', 34000, 61, 2100, 85.0, 'Euro', 'Republic', TRUE,
        TRUE),
       ('Serbia', 'SRB', 'Belgrade', 'Europe', 'Southern Europe', 6600000, 88361, 99953, 76.2, 'Dinar', 'Republic',
        TRUE, TRUE),
       ('Slovenia', 'SVN', 'Ljubljana', 'Europe', 'Southern Europe', 2120000, 20273, 79603, 81.9, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Spain', 'ESP', 'Madrid', 'Europe', 'Southern Europe', 48800000, 505992, 1903826, 83.7, 'Euro',
        'Constitutional monarchy', FALSE, TRUE),
       ('Vatican City', 'VAT', 'Vatican City', 'Europe', 'Southern Europe', 800, 0.49, 0, 84.0, 'Euro',
        'Absolute theocracy', TRUE, FALSE),
       ('Austria', 'AUT', 'Vienna', 'Europe', 'Western Europe', 9100000, 83871, 579928, 82.0, 'Euro',
        'Federal republic', TRUE, TRUE),
       ('Belgium', 'BEL', 'Brussels', 'Europe', 'Western Europe', 11800000, 30528, 724917, 82.2, 'Euro',
        'Constitutional monarchy', FALSE, TRUE),
       ('France', 'FRA', 'Paris', 'Europe', 'Western Europe', 68600000, 551695, 3368925, 83.1, 'Euro', 'Republic',
        FALSE, TRUE),
       ('Germany', 'DEU', 'Berlin', 'Europe', 'Western Europe', 84100000, 357114, 5048059, 81.2, 'Euro',
        'Federal republic', FALSE, TRUE),
       ('Liechtenstein', 'LIE', 'Vaduz', 'Europe', 'Western Europe', 40000, 160, 8100, 84.6, 'Franc',
        'Constitutional monarchy', TRUE, TRUE),
       ('Luxembourg', 'LUX', 'Luxembourg', 'Europe', 'Western Europe', 680000, 2586, 101100, 83.0, 'Euro',
        'Constitutional monarchy', TRUE, TRUE),
       ('Monaco', 'MCO', 'Monaco', 'Europe', 'Western Europe', 39000, 2.02, 9900, 86.5, 'Euro',
        'Constitutional monarchy', FALSE, TRUE),
       ('Netherlands', 'NLD', 'Amsterdam', 'Europe', 'Western Europe', 18100000, 41850, 1332240, 82.2, 'Euro',
        'Constitutional monarchy', FALSE, TRUE),
       ('Switzerland', 'CHE', 'Bern', 'Europe', 'Western Europe', 9000000, 41277, 1043544, 84.2, 'Franc',
        'Federal republic', TRUE, TRUE),
       ('Belarus', 'BLR', 'Minsk', 'Europe', 'Eastern Europe', 9000000, 207600, 92766, 74.3, 'Ruble', 'Republic', TRUE,
        TRUE),
       ('Bulgaria', 'BGR', 'Sofia', 'Europe', 'Eastern Europe', 6400000, 110879, 131024, 75.6, 'Lev', 'Republic', FALSE,
        TRUE),
       ('Czechia', 'CZE', 'Prague', 'Europe', 'Eastern Europe', 10900000, 78865, 389020, 79.9, 'Koruna', 'Republic',
        TRUE, TRUE),
       ('Hungary', 'HUN', 'Budapest', 'Europe', 'Eastern Europe', 9500000, 93028, 246891, 76.7, 'Forint', 'Republic',
        TRUE, TRUE),
       ('Moldova', 'MDA', 'Chisinau', 'Europe', 'Eastern Europe', 3000000, 33846, 20342, 71.9, 'Leu', 'Republic', TRUE,
        TRUE),
       ('Poland', 'POL', 'Warsaw', 'Europe', 'Eastern Europe', 38100000, 312696, 1035586, 78.5, 'Zloty', 'Republic',
        FALSE, TRUE),
       ('Romania', 'ROU', 'Bucharest', 'Europe', 'Eastern Europe', 19000000, 238391, 427941, 76.6, 'Leu', 'Republic',
        FALSE, TRUE),
       ('Russia', 'RUS', 'Moscow', 'Europe', 'Eastern Europe', 144000000, 17098242, 2587938, 73.0, 'Ruble',
        'Federal republic', FALSE, TRUE),
       ('Slovakia', 'SVK', 'Bratislava', 'Europe', 'Eastern Europe', 5400000, 49037, 154442, 78.1, 'Euro', 'Republic',
        TRUE, TRUE),
       ('Ukraine', 'UKR', 'Kyiv', 'Europe', 'Eastern Europe', 38900000, 603500, 212927, 71.0, 'Hryvnia', 'Republic',
        FALSE, TRUE),
       ('Canada', 'CAN', 'Ottawa', 'North America', 'Northern America', 41500000, 9984670, 2319900, 82.6, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('United States', 'USA', 'Washington, D.C.', 'North America', 'Northern America', 347300000, 9833517, 30767075,
        78.4, 'Dollar', 'Federal republic', FALSE, TRUE),
       ('Mexico', 'MEX', 'Mexico City', 'North America', 'Central America', 131500000, 1964375, 1832641, 75.3, 'Peso',
        'Federal republic', FALSE, TRUE),
       ('Belize', 'BLZ', 'Belmopan', 'North America', 'Central America', 420000, 22966, 3600, 73.6, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Costa Rica', 'CRI', 'San Jose', 'North America', 'Central America', 5200000, 51100, 102902, 80.9, 'Colon',
        'Republic', FALSE, TRUE),
       ('El Salvador', 'SLV', 'San Salvador', 'North America', 'Central America', 6300000, 21041, 37268, 72.5, 'Dollar',
        'Republic', FALSE, TRUE),
       ('Guatemala', 'GTM', 'Guatemala City', 'North America', 'Central America', 18700000, 108889, 121113, 72.0,
        'Quetzal', 'Republic', FALSE, TRUE),
       ('Honduras', 'HND', 'Tegucigalpa', 'North America', 'Central America', 10800000, 112492, 39694, 72.5, 'Lempira',
        'Republic', FALSE, TRUE),
       ('Nicaragua', 'NIC', 'Managua', 'North America', 'Central America', 7000000, 130373, 22237, 74.9, 'Cordoba',
        'Republic', FALSE, TRUE),
       ('Panama', 'PAN', 'Panama City', 'North America', 'Central America', 4600000, 75417, 90463, 79.7, 'Balboa',
        'Republic', FALSE, TRUE),
       ('Antigua and Barbuda', 'ATG', 'Saint John''s', 'North America', 'Caribbean', 94000, 442, 2400, 79.0, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Bahamas', 'BHS', 'Nassau', 'North America', 'Caribbean', 410000, 13943, 16508, 74.6, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Barbados', 'BRB', 'Bridgetown', 'North America', 'Caribbean', 280000, 430, 7100, 79.2, 'Dollar', 'Republic',
        FALSE, TRUE),
       ('Cuba', 'CUB', 'Havana', 'North America', 'Caribbean', 10900000, 109884, 201986, 77.9, 'Peso',
        'Socialist republic', FALSE, TRUE),
       ('Dominica', 'DMA', 'Roseau', 'North America', 'Caribbean', 66000, 751, 750, 73.2, 'Dollar', 'Republic', FALSE,
        TRUE),
       ('Dominican Republic', 'DOM', 'Santo Domingo', 'North America', 'Caribbean', 11400000, 48671, 127895, 74.0,
        'Peso', 'Republic', FALSE, TRUE),
       ('Grenada', 'GRD', 'Saint George''s', 'North America', 'Caribbean', 117000, 344, 1500, 75.2, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Haiti', 'HTI', 'Port-au-Prince', 'North America', 'Caribbean', 11900000, 27750, 32102, 64.9, 'Gourde',
        'Republic', FALSE, TRUE),
       ('Jamaica', 'JAM', 'Kingston', 'North America', 'Caribbean', 2800000, 10991, 22313, 71.5, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Saint Kitts and Nevis', 'KNA', 'Basseterre', 'North America', 'Caribbean', 47000, 261, 1250, 72.6, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Saint Lucia', 'LCA', 'Castries', 'North America', 'Caribbean', 180000, 616, 2800, 71.3, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Saint Vincent and the Grenadines', 'VCT', 'Kingstown', 'North America', 'Caribbean', 100000, 389, 1300, 72.7,
        'Dollar', 'Constitutional monarchy', FALSE, TRUE),
       ('Trinidad and Tobago', 'TTO', 'Port of Spain', 'North America', 'Caribbean', 1500000, 5130, 25932, 73.5,
        'Dollar', 'Republic', FALSE, TRUE),
       ('Argentina', 'ARG', 'Buenos Aires', 'South America', 'South America', 45900000, 2780400, 681485, 77.4, 'Peso',
        'Federal republic', FALSE, TRUE),
       ('Bolivia', 'BOL', 'Sucre', 'South America', 'South America', 12600000, 1098581, 64250, 68.6, 'Boliviano',
        'Republic', TRUE, TRUE),
       ('Brazil', 'BRA', 'Brasilia', 'South America', 'South America', 212800000, 8515767, 2279918, 75.8, 'Real',
        'Federal republic', FALSE, TRUE),
       ('Chile', 'CHL', 'Santiago', 'South America', 'South America', 19900000, 756102, 355346, 81.2, 'Peso',
        'Republic', FALSE, TRUE),
       ('Colombia', 'COL', 'Bogota', 'South America', 'South America', 53400000, 1141748, 457410, 77.3, 'Peso',
        'Republic', FALSE, TRUE),
       ('Ecuador', 'ECU', 'Quito', 'South America', 'South America', 18300000, 283561, 130321, 77.9, 'Dollar',
        'Republic', FALSE, TRUE),
       ('Guyana', 'GUY', 'Georgetown', 'South America', 'South America', 840000, 214969, 27097, 66.4, 'Dollar',
        'Republic', FALSE, TRUE),
       ('Paraguay', 'PRY', 'Asuncion', 'South America', 'South America', 7000000, 406752, 49358, 73.8, 'Guarani',
        'Republic', TRUE, TRUE),
       ('Peru', 'PER', 'Lima', 'South America', 'South America', 34600000, 1285216, 341025, 76.8, 'Sol', 'Republic',
        FALSE, TRUE),
       ('Suriname', 'SUR', 'Paramaribo', 'South America', 'South America', 630000, 163820, 4900, 70.8, 'Dollar',
        'Republic', FALSE, TRUE),
       ('Uruguay', 'URY', 'Montevideo', 'South America', 'South America', 3400000, 181034, 85575, 78.1, 'Peso',
        'Republic', FALSE, TRUE),
       ('Venezuela', 'VEN', 'Caracas', 'South America', 'South America', 28500000, 916445, 99661, 72.5, 'Bolivar',
        'Federal republic', FALSE, TRUE),
       ('Australia', 'AUS', 'Canberra', 'Oceania', 'Australia and New Zealand', 26800000, 7692024, 1839961, 83.9,
        'Dollar', 'Constitutional monarchy', FALSE, TRUE),
       ('New Zealand', 'NZL', 'Wellington', 'Oceania', 'Australia and New Zealand', 5300000, 270467, 258832, 82.7,
        'Dollar', 'Constitutional monarchy', FALSE, TRUE),
       ('Fiji', 'FJI', 'Suva', 'Oceania', 'Melanesia', 930000, 18274, 6000, 68.2, 'Dollar', 'Republic', FALSE, TRUE),
       ('Papua New Guinea', 'PNG', 'Port Moresby', 'Oceania', 'Melanesia', 10800000, 462840, 32491, 66.4, 'Kina',
        'Constitutional monarchy', FALSE, TRUE),
       ('Solomon Islands', 'SLB', 'Honiara', 'Oceania', 'Melanesia', 830000, 28896, 1800, 70.9, 'Dollar',
        'Constitutional monarchy', FALSE, TRUE),
       ('Vanuatu', 'VUT', 'Port Vila', 'Oceania', 'Melanesia', 340000, 12189, 1300, 71.0, 'Vatu', 'Republic', FALSE,
        TRUE),
       ('Kiribati', 'KIR', 'Tarawa', 'Oceania', 'Micronesia', 134000, 811, 330, 67.7, 'Dollar', 'Republic', FALSE,
        TRUE),
       ('Marshall Islands', 'MHL', 'Majuro', 'Oceania', 'Micronesia', 37000, 181, 300, 65.6, 'Dollar', 'Republic',
        FALSE, TRUE),
       ('Micronesia', 'FSM', 'Palikir', 'Oceania', 'Micronesia', 115000, 702, 500, 71.3, 'Dollar', 'Federal republic',
        FALSE, TRUE),
       ('Nauru', 'NRU', 'Yaren', 'Oceania', 'Micronesia', 12000, 21, 170, 64.3, 'Dollar', 'Republic', FALSE, TRUE),
       ('Palau', 'PLW', 'Ngerulmud', 'Oceania', 'Micronesia', 18000, 459, 340, 66.4, 'Dollar', 'Republic', FALSE, TRUE),
       ('Samoa', 'WSM', 'Apia', 'Oceania', 'Polynesia', 220000, 2842, 1100, 73.5, 'Tala', 'Republic', FALSE, TRUE),
       ('Tonga', 'TON', 'Nuku''alofa', 'Oceania', 'Polynesia', 104000, 747, 580, 71.4, 'Pa''anga',
        'Constitutional monarchy', FALSE, TRUE),
       ('Tuvalu', 'TUV', 'Funafuti', 'Oceania', 'Polynesia', 10000, 26, 70, 67.3, 'Dollar', 'Constitutional monarchy',
        FALSE, TRUE);



-- ============================================================================
-- ASSIGNMENT SUBMISSION INSTRUCTIONS
-- ============================================================================
-- 1. For every task below, create a corresponding VIEW within the same schema
--    to store your query solution (e.g., CREATE VIEW view_1_1 AS ...).
-- 2. After completing all queries, generate a backup of your schema/database.
-- 3. Upload your final backup file (.sql or .bak) to our DB internship chat.
-- ============================================================================


-- ------------------------------------------------------------
-- Topic 1: GROUPING SETS, CUBE and ROLLUP
-- ------------------------------------------------------------
-- 1.1  In ONE query using GROUPING SETS, return the total population
--      per continent, per region, and a single world total.
CREATE OR REPLACE VIEW view_1_1 AS
SELECT continent, region, SUM(population) AS total_population
FROM countries
GROUP BY GROUPING SETS ((continent), (region), ());

SELECT *
FROM view_1_1;

-- 1.2  With ROLLUP (continent, region), build a hierarchical report of
--      SUM(population) and SUM(gdp_usd_millions): detail rows, a subtotal
--      for every continent, and a grand total. Order it so subtotals
--      appear under their continent.
CREATE OR REPLACE VIEW view_1_2 AS
SELECT continent, region, SUM(population) AS total_population, SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries
GROUP BY ROLLUP (continent, region)
ORDER BY continent, region;

SELECT *
FROM view_1_2;

-- 1.3  With CUBE (continent, landlocked), show the number of countries and
--      the average life expectancy for every combination, including totals.
CREATE OR REPLACE VIEW view_1_3 AS
SELECT continent, landlocked, COUNT(country_id) AS country_count, AVG(life_expectancy) AS avg_life_expectancy
FROM countries
GROUP BY CUBE (continent, landlocked);

SELECT *
FROM view_1_3;

-- 1.4  Rewrite 1.2 without ROLLUP, using several GROUP BY queries joined by
--      UNION ALL.
CREATE OR REPLACE VIEW view_1_4 AS
(
SELECT continent, region, SUM(population) AS total_population, SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries
GROUP BY continent, region

UNION ALL

SELECT continent, NULL as region, SUM(population) AS total_population, SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries
GROUP BY continent

UNION ALL

SELECT NULL                  AS continent,
       NULL                  AS region,
       SUM(population)       AS total_population,
       SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries)
ORDER BY continent, region;

SELECT *
FROM view_1_4;

-- ------------------------------------------------------------
-- Topic 2: GROUPING
-- ------------------------------------------------------------

-- 2.1  Repeat task 1.2, but use GROUPING() to replace the NULLs in subtotal
--      rows with the labels 'All regions' and 'World total'.
CREATE OR REPLACE VIEW view_2_1 AS
SELECT CASE WHEN GROUPING(continent) = 1 THEN 'World Total' ELSE continent END,
       CASE WHEN GROUPING(region) = 1 THEN 'All Regions' ELSE region END,
       SUM(population)       AS total_population,
       SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries
GROUP BY ROLLUP (continent, region)
ORDER BY continent, region;

SELECT *
FROM view_2_1;

-- 2.2  Add GROUPING(continent, region) as a column to the same query and
--      explain what each returned value (0, 1, 3) means for the row.
CREATE OR REPLACE VIEW view_2_2 AS
SELECT CASE WHEN GROUPING(continent) = 1 THEN 'World Total' ELSE continent END,
       CASE WHEN GROUPING(region) = 1 THEN 'All Regions' ELSE region END,
       CASE
           WHEN GROUPING(continent, region) = 0 THEN 'Grouped by continent and region'
           WHEN GROUPING(continent, region) = 1 THEN 'Grouped only by continent'
           WHEN GROUPING(continent, region) = 3 THEN 'Not grouped'
           ELSE 'Unknown'
           END               AS explanation,
       SUM(population)       AS total_population,
       SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries
GROUP BY ROLLUP (continent, region)
ORDER BY continent, region;

SELECT *
FROM view_2_2;

-- 2.3  Using GROUPING in HAVING, return ONLY the subtotal and grand-total
--      rows (no detail rows).
CREATE OR REPLACE VIEW view_2_3 AS
SELECT CASE WHEN GROUPING(continent) = 1 THEN 'World Total' ELSE continent END,
       CASE WHEN GROUPING(region) = 1 THEN 'All Regions' ELSE region END,
       SUM(population)       AS total_population,
       SUM(gdp_usd_millions) AS total_gdp_usd_millions
FROM countries
GROUP BY ROLLUP (continent, region)
HAVING GROUPING(region) = 1
ORDER BY continent, region;

SELECT *
FROM view_2_3;

-- ------------------------------------------------------------
-- Topic 3: Ranking - ROW_NUMBER, RANK, DENSE_RANK, NTILE
-- ------------------------------------------------------------

-- 3.1  For every country show ROW_NUMBER, RANK and DENSE_RANK by population
--      within its continent (largest first). Then rank by life expectancy
--      rounded to whole years and find a place where RANK skips a number
--      but DENSE_RANK does not.
CREATE OR REPLACE VIEW view_3_1 AS
SELECT *
FROM (SELECT continent,
             name,
             population,
             ROW_NUMBER() OVER (PARTITION BY continent ORDER BY population DESC)          rn,
             RANK() OVER (PARTITION BY continent ORDER BY population DESC)                r,
             DENSE_RANK() OVER (PARTITION BY continent ORDER BY population DESC)          dr,

             RANK() OVER (PARTITION BY continent ORDER BY ROUND(life_expectancy) DESC) AS life_expectancy_ranking,
             DENSE_RANK()
             OVER (PARTITION BY continent ORDER BY ROUND(life_expectancy) DESC)        AS life_expectancy_dense_ranking
      FROM countries) AS ranking
WHERE life_expectancy_ranking <> life_expectancy_dense_ranking;

SELECT *
FROM view_3_1;

-- 3.2  Return the top 3 economies (by gdp_usd_millions) in each continent.
CREATE OR REPLACE VIEW view_3_2 AS
SELECT *
FROM (SELECT continent,
             name,
             gdp_usd_millions,
             RANK() OVER (PARTITION BY continent ORDER BY gdp_usd_millions DESC) AS gdp_ranking
      FROM countries) AS g
WHERE gdp_ranking <= 3;

SELECT *
FROM view_3_2;

-- 3.3  With NTILE(4), split all countries into four quartiles by GDP per
--      capita (gdp_usd_millions * 1000000 / population). Show each country's
--      quartile, then count how many countries of each continent fall into
--      quartile 1.
CREATE OR REPLACE VIEW view_3_3 AS
WITH country_gdp AS (SELECT country_id,
                            continent,
                            name,
                            gdp_usd_millions * 1000000.0 / population AS gdp_per_capita
                     FROM countries)
SELECT *,
       NTILE(4) OVER (ORDER BY gdp_per_capita DESC) AS quartile
FROM country_gdp;

SELECT *
FROM view_3_3
ORDER BY quartile, gdp_per_capita DESC;

SELECT continent, COUNT(*) AS country_count
FROM view_3_3
WHERE quartile = 1
GROUP BY continent
ORDER BY country_count DESC;


-- ------------------------------------------------------------
-- Topic 4: Aggregate functions with OVER() - SUM, AVG, COUNT, MIN, MAX
-- ------------------------------------------------------------

-- 4.1  For every country show: its population, the total population of its
--      continent (SUM OVER), and its percentage share of that total.
CREATE OR REPLACE VIEW view_4_1 AS
SELECT *,
       ROUND(population * 100.0 / continent_population, 2) AS population_percentage_share
FROM (SELECT country_id,
             name,
             continent,
             population,
             SUM(population) OVER (PARTITION BY continent) AS continent_population
      FROM countries) t
ORDER BY continent, population DESC;

SELECT *
FROM view_4_1;

-- 4.2  For every country show its GDP next to the average GDP of its region
--      (AVG OVER), and the difference between the two.
CREATE OR REPLACE VIEW view_4_2 AS
WITH country_with_avg_region_gdp AS (SELECT country_id,
                                            name,
                                            region,
                                            gdp_usd_millions,
                                            AVG(gdp_usd_millions) OVER (PARTITION BY region) AS avg_gdp
                                     FROM countries)
SELECT *, (gdp_usd_millions - avg_gdp) AS gdp_diff
FROM country_with_avg_region_gdp
ORDER BY region, gdp_usd_millions DESC;

SELECT *
FROM view_4_2;

-- 4.3  In one query show, beside every row: COUNT(*) of countries in the
--      continent, and the MIN and MAX life expectancy of that continent.
CREATE OR REPLACE VIEW view_4_3 AS
SELECT continent,
       name,
       COUNT(*) OVER (PARTITION BY continent)             AS country_count,
       MIN(life_expectancy) OVER (PARTITION BY continent) AS min_life_expectency_per_continent,
       MAX(life_expectancy) OVER (PARTITION BY continent) AS max_life_expectency_per_continent
FROM countries;

SELECT *
FROM view_4_3;

-- 4.4  Order countries by population (largest first) and compute a running
--      total with SUM(...) OVER (ORDER BY ...). After how many countries
--      does the running total exceed half of the world's population?
CREATE OR REPLACE VIEW view_4_4 AS
SELECT name,
       continent,
       population,
       SUM(population) OVER (ORDER BY population DESC) AS running_total,
       ROW_NUMBER() OVER (ORDER BY population DESC)    AS pop_rank
FROM countries;

SELECT name, continent, population, running_total, pop_rank
FROM view_4_4
WHERE running_total > (SELECT SUM(population) / 2 FROM countries)
ORDER BY pop_rank
LIMIT 1;

-- ------------------------------------------------------------
-- Topic 5: Analytic functions - LAG, LEAD, FIRST_VALUE, LAST_VALUE
-- ------------------------------------------------------------

-- 5.1  Order countries by area within each continent (largest first). With
--      LAG, show for every country how much smaller it is than the previous
--      (larger) one.
CREATE OR REPLACE VIEW view_5_1 AS
SELECT name,
       continent,
       area_km2,
       LAG(area_km2) OVER (PARTITION BY continent ORDER BY area_km2 DESC) - area_km2 AS area_diff
FROM countries
ORDER BY continent, area_km2 DESC;

SELECT *
FROM view_5_1;

-- 5.2  With LEAD, for each country (ordered by GDP descending within its
--      continent) show the name of the next-smaller economy and the GDP gap
--      between them.
CREATE OR REPLACE VIEW view_5_2 AS
SELECT name,
       continent,
       gdp_usd_millions,
       LEAD(name) OVER (PARTITION BY continent ORDER BY gdp_usd_millions DESC)                                AS next_country,
       gdp_usd_millions - LEAD(gdp_usd_millions) OVER (PARTITION BY continent ORDER BY gdp_usd_millions DESC) AS gdp_gap
FROM countries
ORDER BY continent, gdp_usd_millions DESC;

SELECT *
FROM view_5_2;

-- 5.3  With FIRST_VALUE, show each country's life expectancy next to the
--      highest life expectancy in its continent, and the difference.
CREATE OR REPLACE VIEW view_5_3 AS
SELECT *, highest_life_expectancy - life_expectancy AS life_difference
FROM (SELECT name,
             continent,
             life_expectancy,
             FIRST_VALUE(life_expectancy)
             OVER (PARTITION BY continent ORDER BY life_expectancy DESC) AS highest_life_expectancy
      FROM countries) AS t
ORDER BY continent;

SELECT *
FROM view_5_3;

-- 5.4  With LAST_VALUE and a correct window frame (ROWS BETWEEN UNBOUNDED
--      PRECEDING AND UNBOUNDED FOLLOWING), show the smallest country by
--      population of each continent beside every row. Run it once WITHOUT
--      the frame and explain why the result is wrong.
CREATE OR REPLACE VIEW view_5_4 AS
SELECT name,
       continent,
       population,
       LAST_VALUE(name)
       OVER (PARTITION BY continent ORDER BY population DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS smallest_country
FROM countries
ORDER BY continent, population DESC;

SELECT *
FROM view_5_4;

-- This version give the smallest country till that row and doesn't consider the rest of the countries
SELECT name,
       continent,
       population,
       LAST_VALUE(name) OVER (PARTITION BY continent ORDER BY population DESC) AS smallest_country
FROM countries;