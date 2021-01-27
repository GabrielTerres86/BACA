-- INC0075518 - Atualizar tabela de controle, número sequencial e indicador de envio
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, dtcredit, nmarquiv, qtdoctos, vldoctos, vltarifa, vlapagar, nrsequen, vldocto2, flgmigra, cdsitret)
values (1 , 6, 8261426, trunc(sysdate), null, '3239-FC000826142620210121.081.AILOS', 3, 201.25, 1.68, 199.57, 81, 0, 0, 1);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, dtcredit, nmarquiv, qtdoctos, vldoctos, vltarifa, vlapagar, nrsequen, vldocto2, flgmigra, cdsitret)
values (2 , 6, 8261426, trunc(sysdate), null, '3265-FC000826142620210121.079.AILOS', 9, 427.26, 4.41, 422.85, 79, 0, 0, 1);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, dtcredit, nmarquiv, qtdoctos, vldoctos, vltarifa, vlapagar, nrsequen, vldocto2, flgmigra, cdsitret)
values (7 , 6, 8261426, trunc(sysdate), null, '4416-FC000826142620210121.020.AILOS', 1,  38.06, 0.56,  37.50, 20, 0, 0, 1);
insert into gncontr (cdcooper, tpdcontr, cdconven, dtmvtolt, dtcredit, nmarquiv, qtdoctos, vldoctos, vltarifa, vlapagar, nrsequen, vldocto2, flgmigra, cdsitret)
values (12, 6, 8261426, trunc(sysdate), null, '4449-FC000826142620210121.032.AILOS', 1,  39.22, 0.35,  38.87, 32, 0, 0, 1);
--
update craptab
   set dstextab = lpad(to_number(substr(dstextab, 1, 6)) + 1, 6, '0')||' '||to_char(sysdate, 'DDMMYYYY')
 where upper(nmsistem) = 'CRED'
   and upper(tptabela) = 'GENERI'
   and upper(cdacesso) = 'ARQBANCOOB'
   and tpregist = 00
   and cdempres = 8261426
   and cdcooper in (1, 2, 7, 12);
--
update craplft
   set craplft.insitfat = 2,
       craplft.dtdenvio = trunc(sysdate)
 where craplft.rowid in ('AAAS9iAKwAADcfjAAB',
                         'AAAS9iAKwAADcbpAAD',
                         'AAAS9iAKyAADBD7AAk',
                         'AAAS9iAKwAADcHMAAE',
                         'AAAS9iAKwAADdcXAAF',
                         'AAAS9iAKwAADdcXAAG',
                         'AAAS9iAKxAADIVjAAC',
                         'AAAS9iAKxAADIU/AAI',
                         'AAAS9iAKtAADwQtAAe',
                         'AAAS9iAKtAADw0gAAX',
                         'AAAS9iAKtAADvXJAAf',
                         'AAAS9iAKxAADIVmAAA',
                         'AAAS9iAKwAADcguAAH',
                         'AAAS9iAKuAAEGg5AAe');
--
commit;
