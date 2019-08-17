-- Atualização da tabela CRAPLCR, da coluna TPMODCON
-- TPMODCON = 1-Privado/  2-Público / 3-INSS

-- Atualização VIACRED - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 --- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 1 -- VIACRED
   and a.cdlcremp in (406, 412, 424 , 436 , 521 , 945 ,1406,1412, 1521)
/   
-- Atualização ACREDICOOP - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 2 -- ACREDICOOP
   and a.cdlcremp in ( 700,701, 702,703,913, 924,937)
/   
-- Atualização ACENTRA = CECRISACRED - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 5 -- ACENTRA
   and a.cdlcremp in ( 28, 29, 30, 31, 33, 34, 35, 36, 37, 39, 41, 44, 50, 51, 52, 53,
                       55, 56, 58, 69, 71, 74, 76, 77, 78, 85, 88,134,192,221,222,224,
                      227,229,230,232,233,307,308,312,528,529,530,531,535,536,541,569,
                      571,574,576,577,585,620,622,624,644,645,646,647,670,704)
/                      
-- Atualização ACENTRA = CECRISACRED - Consignado = PUBLICO
UPDATE cecred.craplcr a
   set tpmodcon = 2 -- publico
   
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 5 -- ACENTRA
   and a.cdlcremp in ( 743,744,745,746)
/                      

-- Atualização CREDCREA - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 7 -- CREDCREA
   and a.cdlcremp in (1,2,3,4,5,6,7,8,33,34,35,36,70,3615,3617)
/   

-- Atualização CREDELESC - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 8  -- CREDELESC
   and a.cdlcremp in (15,42,66,166)
/   

-- Atualização CREDICOMIN - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 10  -- CREDICOMIN
   and a.cdlcremp in (12,13,14,15)
/ 

-- Atualização CREDIFIESC - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 6 -- CREDIFIESC
   and a.cdlcremp in (38)
/ 

-- Atualização CREDIFOZ - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 11 -- CREDIFOZ
   and a.cdlcremp in (17,27,78,261,286,334)
/ 

-- Atualização CREDIFOZ - Consignado = publico
UPDATE cecred.craplcr a
   set tpmodcon = 2 -- publico
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 11 -- CREDIFOZ
   and a.cdlcremp in (371,373)
/ 

-- Atualização CIVIA = SCRCRED - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 13 -- CIVIA
   and a.cdlcremp in (13,14,15,63,64,65,141,170,204,213,240,241,242,281)
/ 

-- Atualização CIVIA = SCRCRED - Consignado = PUBLICO
UPDATE cecred.craplcr a
   set tpmodcon = 2 -- publico
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 13 -- CIVIA
   and a.cdlcremp in (195,196,205,206,207,208,209,210,211,212,215,216,217,218,219,
                      220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,
                      235,236,238,239,248,249,250,251,252,253,272,273,279,280)
/ 

-- Atualização TRANSPOCRED = SCRCRED - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 9 -- TRANSPOCRED
   and a.cdlcremp in (59,60,61,62)
/

-- Atualização VIACREDI AV  - Consignado = PRIVADO
UPDATE cecred.craplcr a
   set tpmodcon = 1 -- privado
 where a.cdmodali = '02'
   and a.cdsubmod = '02'
   and a.cdcooper = 16 -- VIACREDI AV
   and a.cdlcremp in (406,412,424,436,1031,1032,1406,1412,2406,2412)
/
COMMIT
/
