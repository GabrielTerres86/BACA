-- Rollback.
-- Zerar IOF para operações de crédito por 90 dias.
-- CORONA VIRUS, ajuda do GOVERNO.
UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00001370 WHERE tit.tpiof = 1;

UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00008200 WHERE tit.tpiof = 2;

UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00004100 WHERE tit.tpiof = 3;

UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00380000 WHERE tit.tpiof = 4;

COMMIT;

UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1165284;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1272319;
UPDATE craptab set dstextab = '31/12/9999 31/12/9999 000000000,003800' where progress_recid = 1273726;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1286261;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1287737;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1293341;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1295383;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1296581;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1298107;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1300591;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1338058;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1343462;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1353516;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1354561;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1355532;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1386945;
UPDATE craptab set dstextab = '03/01/2008 31/12/9999 000000000,003800' where progress_recid = 1387970;

COMMIT;

-- Liberação Parametrização.
update crapprm
   set dsvlrprm = '1'
 where nmsistem = 'CRED'
   and cdcooper = 0
   and cdacesso = 'COBRANCA_IOF';
   COMMIT;