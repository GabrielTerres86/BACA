/***********************
 * Baca - Projeto FGTS
 * Autor: Rafael Cechet
 * Data: 08/03/2021
************************/
BEGIN
    -- criar Flag de pagamento FGTS
	FOR rw IN (SELECT cdcooper FROM crapcop WHERE cdcooper <> 3 AND flgativo = 1) LOOP
        insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM) 
        values ('CRED', rw.cdcooper, 'FLG_PAG_FGTS', 'Trava de bloqueio de arrecadação FGTS (A-permite todos PA´s arrecadar,Códigos PA separados por vígula-PA´s liberados, B-Todos PA´s bloqueados)', 'B');
    END LOOP;	
	
	update crapprm prm set prm.dsvlrprm = '76' where cdcooper =  1 and nmsistem = 'CRED' and cdacesso = 'FLG_PAG_FGTS';
	update crapprm prm set prm.dsvlrprm = '1'  where cdcooper = 14 and nmsistem = 'CRED' and cdacesso = 'FLG_PAG_FGTS';	
	update crapprm prm set prm.dsvlrprm = '11' where cdcooper =  9 and nmsistem = 'CRED' and cdacesso = 'FLG_PAG_FGTS';
	
	-- criar parâmetro de e-mail de repasse FGTS
	insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'EMAIL_REPASSE_FGTS', 'E-mail referente ao arquivo de repasse FGTS CEF', 'spb@ailos.coop.br');
	
	-- criar código de crítica 7000 - afeta crps449 na geração de arquivos FGTS
	insert into crapcri (CDCRITIC, DSCRITIC, TPCRITIC, FLGCHAMA)
	values (7000, '7000 - ATENCAO!! ENVIE O ARQUIVO POR CONNECT:', 4, 0);		

    -- criar parâmetro do diretório dos arquivos de envio para CEF
	insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	values ('CRED', 0, 'DIR_CEF_CONNECT_ENV', 'Diretorio utilizado para enviar arquivos para CEF', '/usr/connect/CAIXA/envia/');
	
    -- criar parâmetro do diretório dos arquivos de envio para CEF
	insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	values ('CRED', 0, 'DIR_CEF_CONNECT_REC', 'Diretorio utilizado para receber arquivos da CEF', '/usr/connect/CAIXA/recebe/');	

    -- atribuição das agencias CEF aos PAs das cooperativas
	update crapage set cdagecai = 02320 where cdagenci = 01 and cdcooper = 5;
	update crapage set cdagecai = 00040 where cdagenci = 06 and cdcooper = 5;
	update crapage set cdagecai = 00051 where cdagenci = 09 and cdcooper = 5;
	update crapage set cdagecai = 00029 where cdagenci = 10 and cdcooper = 5;
	update crapage set cdagecai = 00030 where cdagenci = 11 and cdcooper = 5;
	update crapage set cdagecai = 00062 where cdagenci = 12 and cdcooper = 5;
	update crapage set cdagecai = 00071 where cdagenci = 13 and cdcooper = 5;
	update crapage set cdagecai = 00084 where cdagenci = 14 and cdcooper = 5;
	update crapage set cdagecai = 00095 where cdagenci = 15 and cdcooper = 5;
	update crapage set cdagecai = 00107 where cdagenci = 01 and cdcooper = 2;
	update crapage set cdagecai = 00110 where cdagenci = 08 and cdcooper = 2;
	update crapage set cdagecai = 00120 where cdagenci = 09 and cdcooper = 2;
	update crapage set cdagecai = 00131 where cdagenci = 10 and cdcooper = 2;
	update crapage set cdagecai = 00142 where cdagenci = 12 and cdcooper = 2;
	update crapage set cdagecai = 00153 where cdagenci = 13 and cdcooper = 2;
	update crapage set cdagecai = 00164 where cdagenci = 14 and cdcooper = 2;
	update crapage set cdagecai = 00175 where cdagenci = 15 and cdcooper = 2;
	update crapage set cdagecai = 00186 where cdagenci = 16 and cdcooper = 2;
	update crapage set cdagecai = 00197 where cdagenci = 17 and cdcooper = 2;
	update crapage set cdagecai = 00200 where cdagenci = 18 and cdcooper = 2;
	update crapage set cdagecai = 00211 where cdagenci = 19 and cdcooper = 2;
	update crapage set cdagecai = 00222 where cdagenci = 20 and cdcooper = 2;
	update crapage set cdagecai = 02443 where cdagenci = 21 and cdcooper = 2;
	update crapage set cdagecai = 0250  where cdagenci = 22 and cdcooper = 2;
	update crapage set cdagecai = 00299 where cdagenci = 01 and cdcooper = 13;
	update crapage set cdagecai = 00242 where cdagenci = 02 and cdcooper = 13;
	update crapage set cdagecai = 00255 where cdagenci = 03 and cdcooper = 13;
	update crapage set cdagecai = 00266 where cdagenci = 04 and cdcooper = 13;
	update crapage set cdagecai = 00288 where cdagenci = 05 and cdcooper = 13;
	update crapage set cdagecai = 00277 where cdagenci = 06 and cdcooper = 13;
	update crapage set cdagecai = 00302 where cdagenci = 07 and cdcooper = 13;
	update crapage set cdagecai = 00313 where cdagenci = 08 and cdcooper = 13;
	update crapage set cdagecai = 00324 where cdagenci = 09 and cdcooper = 13;
	update crapage set cdagecai = 00335 where cdagenci = 10 and cdcooper = 13;
	update crapage set cdagecai = 00346 where cdagenci = 11 and cdcooper = 13;
	update crapage set cdagecai = 00357 where cdagenci = 12 and cdcooper = 13;
	update crapage set cdagecai = 00368 where cdagenci = 14 and cdcooper = 13;
	update crapage set cdagecai = 00379 where cdagenci = 15 and cdcooper = 13;
	update crapage set cdagecai = 02330 where cdagenci = 13 and cdcooper = 13;
	update crapage set cdagecai = 00459 where cdagenci = 01 and cdcooper = 7;
	update crapage set cdagecai = 00390 where cdagenci = 02 and cdcooper = 7;
	update crapage set cdagecai = 00413 where cdagenci = 03 and cdcooper = 7;
	update crapage set cdagecai = 00404 where cdagenci = 04 and cdcooper = 7;
	update crapage set cdagecai = 00448 where cdagenci = 06 and cdcooper = 7;
	update crapage set cdagecai = 00426 where cdagenci = 07 and cdcooper = 7;
	update crapage set cdagecai = 00437 where cdagenci = 08 and cdcooper = 7;
	update crapage set cdagecai = 00470 where cdagenci = 09 and cdcooper = 7;
	update crapage set cdagecai = 00460 where cdagenci = 10 and cdcooper = 7;
	update crapage set cdagecai = 00481 where cdagenci = 11 and cdcooper = 7;
	update crapage set cdagecai = 00492 where cdagenci = 12 and cdcooper = 7;
	update crapage set cdagecai = 00506 where cdagenci = 13 and cdcooper = 7;
	update crapage set cdagecai = 02454 where cdagenci = 14 and cdcooper = 7;
	update crapage set cdagecai = 00539 where cdagenci = 01 and cdcooper = 8;
	update crapage set cdagecai = 00528 where cdagenci = 02 and cdcooper = 8;
	update crapage set cdagecai = 00540 where cdagenci = 03 and cdcooper = 8;
	update crapage set cdagecai = 00559 where cdagenci = 04 and cdcooper = 8;
	update crapage set cdagecai = 00594 where cdagenci = 01 and cdcooper = 10;
	update crapage set cdagecai = 00572 where cdagenci = 02 and cdcooper = 10;
	update crapage set cdagecai = 00583 where cdagenci = 03 and cdcooper = 10;
	update crapage set cdagecai = 00608 where cdagenci = 05 and cdcooper = 10;
	update crapage set cdagecai = 00674 where cdagenci = 01 and cdcooper = 11;
	update crapage set cdagecai = 00620 where cdagenci = 02 and cdcooper = 11;
	update crapage set cdagecai = 00630 where cdagenci = 03 and cdcooper = 11;
	update crapage set cdagecai = 00685 where cdagenci = 04 and cdcooper = 11;
	update crapage set cdagecai = 00652 where cdagenci = 05 and cdcooper = 11;
	update crapage set cdagecai = 00641 where cdagenci = 06 and cdcooper = 11;
	update crapage set cdagecai = 00663 where cdagenci = 07 and cdcooper = 11;
	update crapage set cdagecai = 00694 where cdagenci = 08 and cdcooper = 11;
	update crapage set cdagecai = 00710 where cdagenci = 09 and cdcooper = 11;
	update crapage set cdagecai = 00700 where cdagenci = 10 and cdcooper = 11;
	update crapage set cdagecai = 00732 where cdagenci = 11 and cdcooper = 11;
	update crapage set cdagecai = 00720 where cdagenci = 12 and cdcooper = 11;
	update crapage set cdagecai = 00743 where cdagenci = 13 and cdcooper = 11;
	update crapage set cdagecai = 02396 where cdagenci = 14 and cdcooper = 11;
	update crapage set cdagecai = 00754 where cdagenci = 01 and cdcooper = 12;
	update crapage set cdagecai = 00765 where cdagenci = 02 and cdcooper = 12;
	update crapage set cdagecai = 00776 where cdagenci = 03 and cdcooper = 12;
	update crapage set cdagecai = 00823 where cdagenci = 01 and cdcooper = 14;
	update crapage set cdagecai = 00798 where cdagenci = 02 and cdcooper = 14;
	update crapage set cdagecai = 00801 where cdagenci = 03 and cdcooper = 14;
	update crapage set cdagecai = 00812 where cdagenci = 04 and cdcooper = 14;
	update crapage set cdagecai = 00834 where cdagenci = 05 and cdcooper = 14;
	update crapage set cdagecai = 00845 where cdagenci = 06 and cdcooper = 14;
	update crapage set cdagecai = 00856 where cdagenci = 07 and cdcooper = 14;
	update crapage set cdagecai = 00865 where cdagenci = 08 and cdcooper = 14;
	update crapage set cdagecai = 02374 where cdagenci = 09 and cdcooper = 14;
	update crapage set cdagecai = 02421 where cdagenci = 10 and cdcooper = 14;
	update crapage set cdagecai = 02476 where cdagenci = 11 and cdcooper = 14;
	update crapage set cdagecai = 00947 where cdagenci = 01 and cdcooper = 9;
	update crapage set cdagecai = 00889 where cdagenci = 02 and cdcooper = 9;
	update crapage set cdagecai = 00890 where cdagenci = 03 and cdcooper = 9;
	update crapage set cdagecai = 00903 where cdagenci = 04 and cdcooper = 9;
	update crapage set cdagecai = 00914 where cdagenci = 05 and cdcooper = 9;
	update crapage set cdagecai = 01010 where cdagenci = 06 and cdcooper = 9;
	update crapage set cdagecai = 00925 where cdagenci = 07 and cdcooper = 9;
	update crapage set cdagecai = 00936 where cdagenci = 08 and cdcooper = 9;
	update crapage set cdagecai = 00958 where cdagenci = 09 and cdcooper = 9;
	update crapage set cdagecai = 01021 where cdagenci = 10 and cdcooper = 9;
	update crapage set cdagecai = 01076 where cdagenci = 11 and cdcooper = 9;
	update crapage set cdagecai = 00969 where cdagenci = 12 and cdcooper = 9;
	update crapage set cdagecai = 00970 where cdagenci = 13 and cdcooper = 9;
	update crapage set cdagecai = 01043 where cdagenci = 14 and cdcooper = 9;
	update crapage set cdagecai = 00991 where cdagenci = 15 and cdcooper = 9;
	update crapage set cdagecai = 01052 where cdagenci = 16 and cdcooper = 9;
	update crapage set cdagecai = 00980 where cdagenci = 17 and cdcooper = 9;
	update crapage set cdagecai = 01032 where cdagenci = 18 and cdcooper = 9;
	update crapage set cdagecai = 01000 where cdagenci = 19 and cdcooper = 9;
	update crapage set cdagecai = 01098 where cdagenci = 20 and cdcooper = 9;
	update crapage set cdagecai = 01065 where cdagenci = 21 and cdcooper = 9;
	update crapage set cdagecai = 01087 where cdagenci = 22 and cdcooper = 9;
	update crapage set cdagecai = 02363 where cdagenci = 23 and cdcooper = 9;
	update crapage set cdagecai = 01101 where cdagenci = 24 and cdcooper = 9;
	update crapage set cdagecai = 01112 where cdagenci = 25 and cdcooper = 9;
	update crapage set cdagecai = 01178 where cdagenci = 01 and cdcooper = 6;
	update crapage set cdagecai = 01156 where cdagenci = 02 and cdcooper = 6;
	update crapage set cdagecai = 01145 where cdagenci = 03 and cdcooper = 6;
	update crapage set cdagecai = 01134 where cdagenci = 04 and cdcooper = 6;
	update crapage set cdagecai = 01167 where cdagenci = 05 and cdcooper = 6;
	update crapage set cdagecai = 01189 where cdagenci = 06 and cdcooper = 6;
	update crapage set cdagecai = 01198 where cdagenci = 07 and cdcooper = 6;
	update crapage set cdagecai = 01203 where cdagenci = 08 and cdcooper = 6;
	update crapage set cdagecai = 01214 where cdagenci = 01 and cdcooper = 1;
	update crapage set cdagecai = 01430 where cdagenci = 02 and cdcooper = 1;
	update crapage set cdagecai = 01735 where cdagenci = 03 and cdcooper = 1;
	update crapage set cdagecai = 01881 where cdagenci = 04 and cdcooper = 1;
	update crapage set cdagecai = 01291 where cdagenci = 05 and cdcooper = 1;
	update crapage set cdagecai = 01611 where cdagenci = 08 and cdcooper = 1;
	update crapage set cdagecai = 01530 where cdagenci = 09 and cdcooper = 1;
	update crapage set cdagecai = 01846 where cdagenci = 14 and cdcooper = 1;
	update crapage set cdagecai = 01429 where cdagenci = 15 and cdcooper = 1;
	update crapage set cdagecai = 01779 where cdagenci = 17 and cdcooper = 1;
	update crapage set cdagecai = 01305 where cdagenci = 18 and cdcooper = 1;
	update crapage set cdagecai = 01790 where cdagenci = 19 and cdcooper = 1;
	update crapage set cdagecai = 01961 where cdagenci = 192 and cdcooper = 1;
	update crapage set cdagecai = 02013 where cdagenci = 193 and cdcooper = 1;
	update crapage set cdagecai = 01860 where cdagenci = 194 and cdcooper = 1;
	update crapage set cdagecai = 02002 where cdagenci = 195 and cdcooper = 1;
	update crapage set cdagecai = 01972 where cdagenci = 196 and cdcooper = 1;
	update crapage set cdagecai = 01859 where cdagenci = 197 and cdcooper = 1;
	update crapage set cdagecai = 01462 where cdagenci = 198 and cdcooper = 1;
	update crapage set cdagecai = 01870 where cdagenci = 199 and cdcooper = 1;
	update crapage set cdagecai = 01724 where cdagenci = 20 and cdcooper = 1;
	update crapage set cdagecai = 02033 where cdagenci = 200 and cdcooper = 1;
	update crapage set cdagecai = 01981 where cdagenci = 201 and cdcooper = 1;
	update crapage set cdagecai = 01994 where cdagenci = 202 and cdcooper = 1;
	update crapage set cdagecai = 02046 where cdagenci = 203 and cdcooper = 1;
	update crapage set cdagecai = 02057 where cdagenci = 204 and cdcooper = 1;
	update crapage set cdagecai = 02080 where cdagenci = 205 and cdcooper = 1;
	update crapage set cdagecai = 02068 where cdagenci = 206 and cdcooper = 1;
	update crapage set cdagecai = 02079 where cdagenci = 207 and cdcooper = 1;
	update crapage set cdagecai = 02090 where cdagenci = 208 and cdcooper = 1;
	update crapage set cdagecai = 02104 where cdagenci = 209 and cdcooper = 1;
	update crapage set cdagecai = 01940 where cdagenci = 21 and cdcooper = 1;
	update crapage set cdagecai = 02340 where cdagenci = 210 and cdcooper = 1;
	update crapage set cdagecai = 02115 where cdagenci = 211 and cdcooper = 1;
	update crapage set cdagecai = 02126 where cdagenci = 212 and cdcooper = 1;
	update crapage set cdagecai = 02400 where cdagenci = 213 and cdcooper = 1;
	update crapage set cdagecai = 02432 where cdagenci = 214 and cdcooper = 1;
	update crapage set cdagecai = 01338 where cdagenci = 22 and cdcooper = 1;
	update crapage set cdagecai = 02352 where cdagenci = 220 and cdcooper = 1;
	update crapage set cdagecai = 02498 where cdagenci = 224 and cdcooper = 1;
	update crapage set cdagecai = 02485 where cdagenci = 225 and cdcooper = 1;
	update crapage set cdagecai = 02024 where cdagenci = 23 and cdcooper = 1;
	update crapage set cdagecai = 01327 where cdagenci = 25 and cdcooper = 1;
	update crapage set cdagecai = 01688 where cdagenci = 26 and cdcooper = 1;
	update crapage set cdagecai = 01407 where cdagenci = 28 and cdcooper = 1;
	update crapage set cdagecai = 01349 where cdagenci = 29 and cdcooper = 1;
	update crapage set cdagecai = 01906 where cdagenci = 30 and cdcooper = 1;
	update crapage set cdagecai = 01757 where cdagenci = 31 and cdcooper = 1;
	update crapage set cdagecai = 01804 where cdagenci = 32 and cdcooper = 1;
	update crapage set cdagecai = 01495 where cdagenci = 34 and cdcooper = 1;
	update crapage set cdagecai = 01780 where cdagenci = 35 and cdcooper = 1;
	update crapage set cdagecai = 01633 where cdagenci = 36 and cdcooper = 1;
	update crapage set cdagecai = 01393 where cdagenci = 37 and cdcooper = 1;
	update crapage set cdagecai = 01699 where cdagenci = 39 and cdcooper = 1;
	update crapage set cdagecai = 01258 where cdagenci = 40 and cdcooper = 1;
	update crapage set cdagecai = 01768 where cdagenci = 41 and cdcooper = 1;
	update crapage set cdagecai = 01451 where cdagenci = 42 and cdcooper = 1;
	update crapage set cdagecai = 01247 where cdagenci = 43 and cdcooper = 1;
	update crapage set cdagecai = 01316 where cdagenci = 44 and cdcooper = 1;
	update crapage set cdagecai = 01280 where cdagenci = 45 and cdcooper = 1;
	update crapage set cdagecai = 01826 where cdagenci = 46 and cdcooper = 1;
	update crapage set cdagecai = 01917 where cdagenci = 47 and cdcooper = 1;
	update crapage set cdagecai = 01644 where cdagenci = 48 and cdcooper = 1;
	update crapage set cdagecai = 01666 where cdagenci = 49 and cdcooper = 1;
	update crapage set cdagecai = 01270 where cdagenci = 50 and cdcooper = 1;
	update crapage set cdagecai = 01675 where cdagenci = 51 and cdcooper = 1;
	update crapage set cdagecai = 01950 where cdagenci = 52 and cdcooper = 1;
	update crapage set cdagecai = 01223 where cdagenci = 53 and cdcooper = 1;
	update crapage set cdagecai = 01700 where cdagenci = 54 and cdcooper = 1;
	update crapage set cdagecai = 01713 where cdagenci = 55 and cdcooper = 1;
	update crapage set cdagecai = 01269 where cdagenci = 56 and cdcooper = 1;
	update crapage set cdagecai = 01236 where cdagenci = 57 and cdcooper = 1;
	update crapage set cdagecai = 01350 where cdagenci = 58 and cdcooper = 1;
	update crapage set cdagecai = 01622 where cdagenci = 59 and cdcooper = 1;
	update crapage set cdagecai = 01520 where cdagenci = 61 and cdcooper = 1;
	update crapage set cdagecai = 01746 where cdagenci = 63 and cdcooper = 1;
	update crapage set cdagecai = 01440 where cdagenci = 64 and cdcooper = 1;
	update crapage set cdagecai = 01837 where cdagenci = 65 and cdcooper = 1;
	update crapage set cdagecai = 01600 where cdagenci = 67 and cdcooper = 1;
	update crapage set cdagecai = 01510 where cdagenci = 68 and cdcooper = 1;
	update crapage set cdagecai = 01655 where cdagenci = 70 and cdcooper = 1;
	update crapage set cdagecai = 01575 where cdagenci = 71 and cdcooper = 1;
	update crapage set cdagecai = 01939 where cdagenci = 72 and cdcooper = 1;
	update crapage set cdagecai = 01509 where cdagenci = 73 and cdcooper = 1;
	update crapage set cdagecai = 01418 where cdagenci = 74 and cdcooper = 1;
	update crapage set cdagecai = 01484 where cdagenci = 76 and cdcooper = 1;
	update crapage set cdagecai = 01369 where cdagenci = 77 and cdcooper = 1;
	update crapage set cdagecai = 01597 where cdagenci = 78 and cdcooper = 1;
	update crapage set cdagecai = 01371 where cdagenci = 79 and cdcooper = 1;
	update crapage set cdagecai = 01815 where cdagenci = 80 and cdcooper = 1;
	update crapage set cdagecai = 01542 where cdagenci = 81 and cdcooper = 1;
	update crapage set cdagecai = 01473 where cdagenci = 82 and cdcooper = 1;
	update crapage set cdagecai = 01892 where cdagenci = 83 and cdcooper = 1;
	update crapage set cdagecai = 01564 where cdagenci = 85 and cdcooper = 1;
	update crapage set cdagecai = 01382 where cdagenci = 86 and cdcooper = 1;
	update crapage set cdagecai = 01586 where cdagenci = 87 and cdcooper = 1;
	update crapage set cdagecai = 01553 where cdagenci = 88 and cdcooper = 1;
	update crapage set cdagecai = 01928 where cdagenci = 89 and cdcooper = 1;
	update crapage set cdagecai = 02137 where cdagenci = 01 and cdcooper = 16;
	update crapage set cdagecai = 02181 where cdagenci = 02 and cdcooper = 16;
	update crapage set cdagecai = 02192 where cdagenci = 03 and cdcooper = 16;
	update crapage set cdagecai = 02159 where cdagenci = 04 and cdcooper = 16;
	update crapage set cdagecai = 02204 where cdagenci = 05 and cdcooper = 16;
	update crapage set cdagecai = 02160 where cdagenci = 06 and cdcooper = 16;
	update crapage set cdagecai = 02148 where cdagenci = 07 and cdcooper = 16;
	update crapage set cdagecai = 02228 where cdagenci = 08 and cdcooper = 16;
	update crapage set cdagecai = 02179 where cdagenci = 09 and cdcooper = 16;
	update crapage set cdagecai = 02217 where cdagenci = 10 and cdcooper = 16;
	update crapage set cdagecai = 02239 where cdagenci = 11 and cdcooper = 16;
	update crapage set cdagecai = 02240 where cdagenci = 12 and cdcooper = 16;
	update crapage set cdagecai = 02250 where cdagenci = 13 and cdcooper = 16;
	update crapage set cdagecai = 02410 where cdagenci = 14 and cdcooper = 16;
	update crapage set cdagecai = 02261 where cdagenci = 15 and cdcooper = 16;
	update crapage set cdagecai = 02272 where cdagenci = 16 and cdcooper = 16;
	update crapage set cdagecai = 02283 where cdagenci = 17 and cdcooper = 16;
	update crapage set cdagecai = 02294 where cdagenci = 18 and cdcooper = 16;
	update crapage set cdagecai = 02308 where cdagenci = 19 and cdcooper = 16;
	update crapage set cdagecai = 02319 where cdagenci = 20 and cdcooper = 16;
	update crapage set cdagecai = 02385 where cdagenci = 21 and cdcooper = 16;
	update crapage set cdagecai = 02465 where cdagenci = 22 and cdcooper = 16;	
      
    COMMIT;	
	
END;
