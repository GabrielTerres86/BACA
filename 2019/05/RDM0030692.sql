prompt RDM0030692

set feedback off
set define off

INSERT INTO CRAPLEM ( DTMVTOLT 
                    , CDAGENCI
                    , CDBCCXLT
                    , NRDOLOTE
                    , NRDCONTA
                    , NRDOCMTO
                    , CDHISTOR
                    , NRSEQDIG
                    , NRCTREMP
                    , VLLANMTO
                    , DTPAGEMP
                    , TXJUREPR
                    , VLPREEMP
                    , NRAUTDOC
                    , NRSEQUNI
                    , CDCOOPER
                    , NRPAREPR
                    , NRSEQAVA
                    , DTESTORN
                    , CDORIGEM
                    , QTDIACAL
                    , VLTAXPER
                    , VLTAXPRD )
             SELECT ( SELECT DTMVTOLT FROM CRAPDAT WHERE CDCOOPER = 1 )
                    , CDAGENCI
                    , CDBCCXLT
                    , 1 --NUMERO DO LOTE  
                    , NRDCONTA
                    , NRDOCMTO
                    , 88 --HISTORICO
                    , ( SELECT NRSEQDIG 
                          FROM CRAPLOT 
                         WHERE CDCOOPER = 1 
                           AND CDAGENCI = 17 
                           AND NRDOLOTE = 1 
                           AND DTMVTOLT = ( SELECT DTMVTOLT FROM CRAPDAT WHERE CDCOOPER = 1 ) 
                           AND CDBCCXLT = 100 ) --SEQUENCIAL
                    , NRCTREMP
                    , VLLANMTO
                    , DTPAGEMP
                    , TXJUREPR
                    , VLPREEMP
                    , NRAUTDOC
                    , NRSEQUNI
                    , CDCOOPER
                    , NRPAREPR
                    , NRSEQAVA
                    , DTESTORN
                    , CDORIGEM
                    , QTDIACAL
                    , VLTAXPER
                    , VLTAXPRD 
  FROM CRAPLEM
 WHERE PROGRESS_RECID = 123694651;
 
UPDATE CRAPLEM
   SET DTESTORN = SYSDATE
 WHERE PROGRESS_RECID = 123694651;


UPDATE CRAPLOT
   SET NRSEQDIG = NRSEQDIG + 1
     , VLINFODB = VLINFODB + 400
     , QTINFOLN = QTINFOLN + 1
     , VLCOMPDB = VLCOMPDB + 400
     , QTCOMPLN = QTCOMPLN + 1
 WHERE CDCOOPER = 1
   AND CDAGENCI = 17
   AND NRDOLOTE = 1
   AND CDBCCXLT = 100
   AND DTMVTOLT = ( SELECT DTMVTOLT FROM CRAPDAT WHERE CDCOOPER = 1 );
   
commit;

prompt Done.
