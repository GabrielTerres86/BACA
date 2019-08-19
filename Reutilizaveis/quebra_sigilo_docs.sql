--RITM0032523 - 3834956,4043650,6121039,8474540
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo (compe@ailos.coop.br) informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 1
   AND lcm.nrdconta IN (3834956,4043650,6121039,8474540)
   AND lcm.dtmvtolt BETWEEN '01/01/2008' AND '05/05/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0031945 cdcooper 1 nrdconta (9227628, 2571730) 01/01/2008 a 31/12/2013
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 1
   AND lcm.nrdconta IN (9227628, 2571730)
   AND lcm.dtmvtolt BETWEEN '01/01/2008' AND '31/12/2013'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0029522 cdcooper 13 nrdconta 191850 01/01/2004 a 17/06/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 13
   AND lcm.nrdconta IN (191850)
   AND lcm.dtmvtolt BETWEEN '01/01/2004' AND '17/06/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0027827 cdcooper 7 nrdconta 136034 01/01/2018 a 04/06/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 7
   AND lcm.nrdconta IN (136034)
   AND lcm.dtmvtolt BETWEEN '01/01/2018' AND '04/06/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

/*
11  347000  8761591000121
11  343692  51558750991
11  489468  9154158958 */
--RITM0025851 cdcooper 11 nrdconta (347000,343692,489468) --01/01/2018 a 08/04/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 11
   AND lcm.nrdconta IN (347000,343692,489468)
   AND lcm.dtmvtolt BETWEEN '01/01/2018' AND '08/04/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0025850 cdcooper 1 nrdconta 9623442 --01/01/2018 a 08/04/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 1
   AND lcm.nrdconta IN (9623442)
   AND lcm.dtmvtolt BETWEEN '01/01/2018' AND '08/04/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------


--RITM0024673 cdcooper 11 nrdconta 470147 --01/01/2014 a 26/02/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 11
   AND lcm.nrdconta IN (470147)
   AND lcm.dtmvtolt BETWEEN '01/01/2014' AND '26/02/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0024196 cdcooper 13 nrdconta 4627979,17760 --01/01/2015 a 07/02/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 13
   AND lcm.nrdconta IN (4627979,17760)
   AND lcm.dtmvtolt BETWEEN '01/01/2015' AND '07/02/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0024195 COOP 9 CONTA  entre 22/01/2014 a 22/01/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 9
   AND lcm.nrdconta IN (21873)
   AND lcm.dtmvtolt BETWEEN '22/01/2014' and '22/01/2019'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0025088 COOP 1 CONTA 758310 entre 09/07/2015 a 09/07/2018
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 1
   AND lcm.nrdconta IN (758310)
   AND lcm.dtmvtolt BETWEEN '09/07/2015' and '09/07/2018'
   AND lcm.cdhistor in (548, 575);
----------------------------------------------

--RITM0024177 COOP 9 CONTA 46760 entre 01/11/2018 a 01/02/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 9
   AND lcm.nrdconta IN (46760)
   AND lcm.dtmvtolt BETWEEN '01/11/2018' and '01/02/2019'
   AND lcm.cdhistor in (548, 575);

----------------------------------------------

--RITM0024192 COOP 9 CONTA 46760 entre 01/10/2018 a 15/01/2019
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 9
   AND lcm.nrdconta IN (46760)
   AND lcm.dtmvtolt BETWEEN '01/10/2018' and '15/01/2019'
   AND lcm.cdhistor in (548, 575);

----------------------------------------------
--RITM0024164
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 2
   AND lcm.nrdconta IN (704580,704601)
   AND lcm.dtmvtolt BETWEEN '01/01/2015' and '17/12/2018'
   AND lcm.cdhistor in (548, 575);

SELECT nrcpfcgc, nrdconta FROM crapass WHERE cdcooper = 2 AND nrcpfcgc IN (09641484000122, 89032128949);
--09641484000122 ; 89032128949 -01/01/2015 a 17/12/2018
 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 53961
              CONTA : 704601
               DATA : 07/04/15
       BANCO DEBITO : 1
NOME CLIENTE DEBITO : E SCHAEFER YACHTS LTDA                  
              VALOR : 644,00

 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 53961
              CONTA : 704601
               DATA : 08/04/15
       BANCO DEBITO : 1
NOME CLIENTE DEBITO : E SCHAEFER YACHTS LTDA                  
              VALOR : 353,52

 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 53961
              CONTA : 704601
               DATA : 02/06/15
       BANCO DEBITO : 1
NOME CLIENTE DEBITO : E SCHAEFER YACHTS LTDA                  
              VALOR : 126,73

 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 97701
              CONTA : 704601
               DATA : 18/06/15
       BANCO DEBITO : 341
NOME CLIENTE DEBITO : VENDOR COM.PROD.INFORM.LTDA ME          
              VALOR : 285,64

 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 97701
              CONTA : 704601
               DATA : 29/07/15
       BANCO DEBITO : 341
NOME CLIENTE DEBITO : VENDOR COM.PROD.INFORM.LTDA ME          
              VALOR : 330,00

 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 130019285
              CONTA : 704580
               DATA : 15/04/16
       BANCO DEBITO : 33
NOME CLIENTE DEBITO : TAM LINHAS AEREAS S/A                   
              VALOR : 1.152,27

 AGENCIA SEM DIGITO : 1
    CPF/CNPJ DEBITO : ?????
       CONTA DEBITO : 362638
              CONTA : 704580
               DATA : 26/12/17
       BANCO DEBITO : 1
NOME CLIENTE DEBITO : IEDA MARISA ARCEGA                      
              VALOR : 340,00

---------------------------------------------------------------------

--RITM0023312
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 9
   AND lcm.nrdconta = 201391
   AND lcm.dtmvtolt BETWEEN '01/01/2016' and '31/03/2019'
   AND lcm.cdhistor in (548, 575);
--02668369000100 --01/01/2016 a 31/03/2019

SELECT * FROM crapass  WHERE cdcooper = 9 AND nrcpfcgc = 02668369000100
SELECT * FROM craplcm WHERE  cdcooper = 9 AND nrdconta = 201391 AND dtmvtolt > '01/01/2018'

--ritm0023300
SELECT 'vr_tbdoc('||ROWNUM||').cdagenci := ' || lcm.cdagenci || ';
        vr_tbdoc('||ROWNUM||').nrcpfdeb := ;
        vr_tbdoc('||ROWNUM||').nrdconta := ' || lcm.nrdconta || ';
        vr_tbdoc('||ROWNUM||').nrctadeb := ' || lcm.nrctachq || ';
        vr_tbdoc('||ROWNUM||').dtmvtolt := TO_DATE(''' || lcm.dtmvtolt ||''',''DD/MM/RRRR'');
        vr_tbdoc('||ROWNUM||').cdbancod := ' || lcm.cdbanchq || ';
        vr_tbdoc('||ROWNUM||').nmclideb := ''' || TRIM(lcm.cdpesqbb) || ''';
        vr_tbdoc('||ROWNUM||').valordoc := ' || REPLACE(lcm.vllanmto,',','.') || ';
        vr_tbdoc('||ROWNUM||').flgativo := 0;',
        -- Solicitar cpf/cnpj para a Natalia Busnardo informando o lançamento:
        'AGENCIA SEM DIGITO : ' || lcm.cdagenci || '
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : ' || lcm.nrctachq || '
                      CONTA : ' || lcm.nrdconta || '
                       DATA : ' || lcm.dtmvtolt || '
               BANCO DEBITO : ' || lcm.cdbanchq || '
        NOME CLIENTE DEBITO : ' || lcm.cdpesqbb || '
                      VALOR : ' || to_char(lcm.vllanmto, 'fm999g999g990d00')
  FROM craplcm lcm
 WHERE lcm.cdcooper = 2
   AND lcm.nrdconta IN (641529,269123)
   AND lcm.dtmvtolt BETWEEN '01/01/2015' and '28/05/2019'
   AND lcm.cdhistor in (548, 575);
--641529, 269123   
   
/*       AGENCIA SEM DIGITO : 1
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : 130035323
                      CONTA : 4023617
                       DATA : 19/07/16
               BANCO DEBITO : 33
        NOME CLIENTE DEBITO : PROCOMEX CONSULTORIA EM NEGOCIOS INTERNA
                      VALOR : 1.000,00

         AGENCIA SEM DIGITO : 1
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : 984580
                      CONTA : 4023617
                       DATA : 22/12/16
               BANCO DEBITO : 341
        NOME CLIENTE DEBITO : PROCOMEX CONS EM NEGOCIOS INT           
                      VALOR : 2.700,00
                      
         AGENCIA SEM DIGITO : 1
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : 304085
                      CONTA : 4023617
                       DATA : 20/02/17
               BANCO DEBITO : 1
        NOME CLIENTE DEBITO : PABLO PINHEIRO V SANTOS                 
                      VALOR : 2.000,00
                      
         AGENCIA SEM DIGITO : 1
            CPF/CNPJ DEBITO : ?????
               CONTA DEBITO : 130035323
                      CONTA : 4023617
                       DATA : 07/11/17
               BANCO DEBITO : 33
        NOME CLIENTE DEBITO : PROCOMEX CONSULTORIA EM NEGOCIOS INTERNA
                      VALOR : 500,00
*/
