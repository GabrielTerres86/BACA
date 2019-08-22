PL/SQL Developer Test script 3.0
122
/*

Lucas Ranghetti - INC0023074
-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

         Cooperativa |      Conta |        Nro Dcto |     Boleto |    Emissão | Vencimento |        Valor
          1-VIACREDI |    2301440 |    15541-2/0001 |       2343 | 25/04/2019 | 02/05/2019 | R$    658,30
          1-VIACREDI |    2301440 |    15541-3/0001 |       2344 | 25/04/2019 | 02/05/2019 | R$    658,30
          1-VIACREDI |    2301440 |    15541-4/0001 |       2345 | 25/04/2019 | 02/05/2019 | R$    658,30
          1-VIACREDI |    6057888 | 12.776 ACP/0018 |      11847 | 09/01/2019 | 16/08/2019 | R$    550,00
          1-VIACREDI |    9155180 |         46/0002 |         21 | 28/10/2014 | 23/12/2014 | R$    202,00
       9-TRANSPOCRED |       1619 |      0203886400 |        787 | 28/08/2018 | 11/09/2018 | R$  3.305,44
       9-TRANSPOCRED |     207900 |         13/0001 |         17 | 28/02/2019 | 20/03/2019 | R$    232,80
       9-TRANSPOCRED |     907766 |      27434/0002 |         16 | 10/08/2018 | 09/10/2018 | R$    195,98
       10-CREDICOMIN |       3379 |      3.991/0001 |          4 | 27/09/2018 | 26/10/2018 | R$    720,00
       10-CREDICOMIN |     100650 |         N6567-1 |        224 | 28/11/2018 | 12/12/2018 | R$    133,22
         11-CREDIFOZ |     392626 |           116/A |          8 | 25/07/2018 | 11/09/2018 | R$    607,50
          12-CREVISC |     115320 |        159832-1 |  400000200 | 23/01/2019 | 22/02/2019 | R$  3.521,88
            13-CIVIA |     712361 |     235/02/0001 |          7 | 09/09/2014 | 09/10/2014 | R$     65,00
           14-EVOLUA |      36404 |         28/0001 |         10 | 20/03/2018 | 30/04/2018 | R$  9.200,00
           14-EVOLUA |      71595 |         01/0004 |        192 | 29/03/2019 | 10/08/2019 | R$    500,00
      16-VIACREDI AV |     134929 |       2644/0004 |       1865 | 24/01/2019 | 08/07/2019 | R$    396,10
      16-VIACREDI AV |     204625 |        541/0001 |        107 | 12/06/2018 | 11/08/2018 | R$  1.110,00
      
*/

declare 
  -- Local variables here
  i integer;
  vr_dserro VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);
  
  CURSOR cr_crapcob IS
    SELECT cob.rowid
          ,cob.incobran
          ,cob.cdcooper
          ,cob.nrdconta
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,cob.dsdoccop
          ,cob.nrnosnum
      FROM crapcob cob
     WHERE (cob.cdcooper,cob.cdbandoc,cob.nrdctabb,cob.nrcnvcob,cob.nrdconta,cob.nrdocmto)
      IN (
           (           1,          85,       10130,       10130,     2301440,        2343)
          ,(           1,          85,       10130,       10130,     2301440,        2344)
          ,(           1,          85,       10130,       10130,     2301440,        2345)
          ,(           1,          85,       10150,       10150,     6057888,       11847)
          ,(           1,           1,     1243381,     2280716,     9155180,          21)
          ,(           9,           1,     1243390,     2287339,        1619,         787)
          ,(           9,          85,      108002,      108002,      207900,          17)
          ,(           9,           1,     1243390,     2287339,      907766,          16)
          ,(          10,           1,     1254944,     2287344,        3379,           4)
          ,(          10,           1,     1254944,     2287344,      100650,         224)
          ,(          11,           1,     1254936,     2293514,      392626,           8)
          ,(          12,          85,      111004,      111004,      115320,   400000200)
          ,(          13,           1,     1575996,     2567994,      712361,           7)
          ,(          14,           1,     1254979,     2287349,       36404,          10)
          ,(          14,          85,      113002,      113002,       71595,         192)
          ,(          16,          85,       11530,       11530,      134929,        1865)
          ,(          16,           1,     1900056,     2459285,      204625,         107)
         )
     ORDER BY COB.CDCOOPER, COB.NRDCONTA, COB.DSDOCCOP, COB.NRDOCMTO;

BEGIN

  dbms_output.put_line('Situacao (0=A, 3=B, 5=L) - Cooperativa - Conta - Convenio - Boleto - Documento');

  -- Test statements here
  FOR rw IN cr_crapcob LOOP
  
    dbms_output.put_line(rw.incobran || ' - ' ||
                         rw.cdcooper || ' - ' ||
                         rw.nrdconta || ' - ' ||
                         rw.nrcnvcob || ' - ' ||
                         rw.nrdocmto || ' - ' ||
                         rw.dsdoccop || ' - ' ||
                         rw.nrnosnum );
                         
    IF rw.incobran = 0 THEN
       UPDATE crapcob SET incobran = 3, 
                          dtdbaixa = TRUNC(SYSDATE)
        WHERE cdcooper = rw.cdcooper
          AND nrdconta = rw.nrdconta
          AND nrcnvcob = rw.nrcnvcob
          AND nrdocmto = rw.nrdocmto;
          
      paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid
                                  , pr_cdoperad => '1'
                                  , pr_dtmvtolt => trunc(SYSDATE)
                                  , pr_dsmensag => 'Titulo baixado manualmente'
                                  , pr_des_erro => vr_dserro
                                  , pr_dscritic => vr_dscritic );
          
    END IF;
    
    COMMIT;
    
  END LOOP;
  
  dbms_output.put_line(' ');
  dbms_output.put_line('Apos atualizacao');  
  
  FOR rw IN cr_crapcob LOOP
  
    dbms_output.put_line(rw.incobran || ' - ' ||
                         rw.cdcooper || ' - ' ||
                         rw.nrdconta || ' - ' ||
                         rw.nrcnvcob || ' - ' ||
                         rw.nrdocmto || ' - ' ||
                         rw.dsdoccop || ' - ' ||
                         rw.nrnosnum);                                                           
    
  END LOOP;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
0
0
