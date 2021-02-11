-- Created on 22/10/2020 by F0030474 
declare 
  vr_exc_erro EXCEPTION;
  vr_dsinform##3_atu crappro.dsinform##3%TYPE;
  -- Local variables here
  CURSOR cr_crappro IS
    SELECT a.cdcooper
          ,a.dsprotoc
      FROM tbconv_registro_remessa_pagfor r
          ,tbconv_remessa_pagfor          p
          ,crapaut                        a
     WHERE r.idsicredi IN (2245825
                          ,2245826
                          ,2245827
                          ,2245853
                          ,2245882
                          ,2245883
                          ,2246751
                          ,2246788
                          ,2246816
                          ,2246817
                          ,2246818
                          ,2249090
                          ,2249091
                          ,2249092
                          ,2249203
                          ,2249204
                          ,2249205
                          ,2249206
                          ,2249242
                          ,2249243
                          ,2249244
                          ,2249245
                          ,2249246
                          ,2249247
                          ,2249248
                          ,2249249
                          ,2249250
                          ,2249280
                          ,2249281
                          ,2249282
                          ,2249283
                          ,2249284
                          ,2249785
                          ,2249786
                          ,2249787
                          ,2245133
                          ,2245307
                          ,2245308
                          ,2245309
                          ,2245310
                          ,2245311
                          ,2245312
                          ,2245313
                          ,2245314
                          ,2245315
                          ,2245317
                          ,2245494
                          ,2245495
                          ,2245514
                          ,2245537
                          ,2245538
                          ,2245539
                          ,2245620
                          ,2245621
                          ,2245653
                          ,2245654
                          ,2245655
                          ,2245675
                          ,2245676
                          ,2245707
                          ,2245708
                          ,2245709
                          ,2245710
                          ,2245736
                          ,2245771
                          ,2245772
                          ,2245906
                          ,2245907
                          ,2245908
                          ,2245937
                          ,2245938
                          ,2245963
                          ,2245964
                          ,2245965
                          ,2245966
                          ,2245998
                          ,2245999
                          ,2246037
                          ,2246038
                          ,2246039
                          ,2246040
                          ,2246041
                          ,2246063
                          ,2246064
                          ,2246105
                          ,2246106
                          ,2246107
                          ,2246108
                          ,2246109
                          ,2246157
                          ,2246158
                          ,2246159
                          ,2246192
                          ,2246193
                          ,2246194
                          ,2246195
                          ,2246232
                          ,2246233
                          ,2246234
                          ,2246235
                          ,2246267
                          ,2246268
                          ,2246269
                          ,2246301
                          ,2246302
                          ,2246303
                          ,2246304
                          ,2246305
                          ,2246306
                          ,2246346
                          ,2246378
                          ,2246379
                          ,2246380
                          ,2246428
                          ,2246508
                          ,2246509
                          ,2246510
                          ,2246511
                          ,2246512
                          ,2246513
                          ,2246514
                          ,2246515
                          ,2246516
                          ,2246517
                          ,2246563
                          ,2246564
                          ,2246566
                          ,2246567
                          ,2246568
                          ,2246569
                          ,2246570
                          ,2246606
                          ,2246641
                          ,2246642
                          ,2246643
                          ,2246682
                          ,2246683
                          ,2246684
                          ,2246685
                          ,2246686
                          ,2246687
                          ,2246717
                          ,2246718
                          ,2246719
                          ,2246720
                          ,2246878
                          ,2246879
                          ,2246906
                          ,2246907
                          ,2246908
                          ,2246909
                          ,2246939
                          ,2246940
                          ,2246941
                          ,2246942
                          ,2246943
                          ,2246994
                          ,2246995
                          ,2246996
                          ,2246997
                          ,2247034
                          ,2247079
                          ,2247137
                          ,2247165
                          ,2247213
                          ,2247238
                          ,2247271
                          ,2247306
                          ,2247351
                          ,2247396
                          ,2247428
                          ,2247454
                          ,2247455
                          ,2247457
                          ,2247506
                          ,2247507
                          ,2247562
                          ,2247563
                          ,2247564
                          ,2247607
                          ,2247629
                          ,2247630
                          ,2247672
                          ,2247673
                          ,2247674
                          ,2247675
                          ,2247676
                          ,2247703
                          ,2247704
                          ,2247729
                          ,2247764
                          ,2247765
                          ,2247766
                          ,2247767
                          ,2247837
                          ,2247838
                          ,2247839
                          ,2247840
                          ,2247841
                          ,2247886
                          ,2247887
                          ,2247888
                          ,2247889
                          ,2247890
                          ,2247916
                          ,2247917
                          ,2247918
                          ,2247948
                          ,2247949
                          ,2247976
                          ,2247977
                          ,2247978
                          ,2247979
                          ,2247980
                          ,2248013
                          ,2248014
                          ,2248015
                          ,2248016
                          ,2248017
                          ,2248018
                          ,2248019
                          ,2248020
                          ,2248080
                          ,2248082
                          ,2248083
                          ,2248084
                          ,2248139
                          ,2248140
                          ,2248141
                          ,2248142
                          ,2248143
                          ,2248144
                          ,2248145
                          ,2248146
                          ,2248147
                          ,2248181
                          ,2248182
                          ,2248183
                          ,2248184
                          ,2248185
                          ,2248214
                          ,2248215
                          ,2248216
                          ,2248217
                          ,2248218
                          ,2248219
                          ,2248220
                          ,2248221
                          ,2248222
                          ,2248271
                          ,2248272
                          ,2248332
                          ,2248333
                          ,2248334
                          ,2248370
                          ,2248371
                          ,2248372
                          ,2248406
                          ,2248407
                          ,2248408
                          ,2248409
                          ,2248410
                          ,2248443
                          ,2248444
                          ,2248445
                          ,2248446
                          ,2248447
                          ,2248448
                          ,2248489
                          ,2248544
                          ,2248545
                          ,2248546
                          ,2248547
                          ,2248639
                          ,2248640
                          ,2248641
                          ,2248642
                          ,2248643
                          ,2248645
                          ,2248691
                          ,2248692
                          ,2248693
                          ,2248695
                          ,2248696
                          ,2248697
                          ,2248698
                          ,2248755
                          ,2248756
                          ,2248757
                          ,2248758
                          ,2248792
                          ,2248831
                          ,2248832
                          ,2248833
                          ,2248835
                          ,2248836
                          ,2248837
                          ,2248838
                          ,2248839
                          ,2248840
                          ,2248841
                          ,2248842
                          ,2248843
                          ,2248844
                          ,2248845
                          ,2248846
                          ,2248921
                          ,2248922
                          ,2248923
                          ,2248961
                          ,2248962
                          ,2248963
                          ,2248964
                          ,2248965
                          ,2248966
                          ,2248967
                          ,2248968
                          ,2248969
                          ,2248970
                          ,2248971
                          ,2249014
                          ,2249015
                          ,2249016
                          ,2249017
                          ,2249121
                          ,2249122
                          ,2249123
                          ,2249124
                          ,2249125
                          ,2249126
                          ,2249127
                          ,2249128
                          ,2249129
                          ,2249169
                          ,2249170
                          ,2249171
                          ,2249172
                          ,2249332
                          ,2249333
                          ,2249334
                          ,2249335
                          ,2249377
                          ,2249378
                          ,2249379
                          ,2249380
                          ,2249381
                          ,2249382
                          ,2249383
                          ,2249384
                          ,2249385
                          ,2249386
                          ,2249387
                          ,2249388
                          ,2249389
                          ,2249390
                          ,2249426
                          ,2249427
                          ,2249428
                          ,2249459
                          ,2249460
                          ,2249461
                          ,2249486
                          ,2249487
                          ,2249488
                          ,2249489
                          ,2249490
                          ,2249491
                          ,2249519
                          ,2249520
                          ,2249521
                          ,2249582
                          ,2249583
                          ,2249584
                          ,2249610
                          ,2249611
                          ,2249664
                          ,2249665
                          ,2249666
                          ,2249667
                          ,2249692
                          ,2249694
                          ,2249695
                          ,2249696
                          ,2249697
                          ,2249698
                          ,2249699
                          ,2249722
                          ,2249723
                          ,2249724
                          ,2249725
                          ,2249726
                          ,2249727
                          ,2249728
                          ,2249729
                          ,2249730
                          ,2249731
                          ,2249732
                          ,2249760
                          ,2249761
                          ,2249762
                          ,2249763)
       AND p.idremessa = r.idremessa
       AND a.cdcooper = r.cdcooper
       AND a.dtmvtolt = p.dtmovimento
       AND a.cdagenci = r.cdagenci
       AND a.nrdcaixa = DECODE(r.cdempresa_documento
                              ,'C06'
                              ,(r.nrdolote - 31000)
                              ,(r.nrdolote - 15000))
       AND a.nrsequen = r.nrautenticacao_documento;
   
   CURSOR cr_crappro_rowid (pr_cdcooper IN crappro.cdcooper%TYPE
                           ,pr_dsprotoc IN crappro.dsprotoc%TYPE) IS
    SELECT pro.rowid
          ,substr(dsinform##3, 1, INSTR(dsinform##3,'#',1,9)) dsinform##3
      FROM crappro pro
     WHERE pro.cdcooper = pr_cdcooper
       AND upper(pro.dsprotoc) = pr_dsprotoc;
   rw_crappro_rowid cr_crappro_rowid%ROWTYPE;
   
   CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT cop.cdagesic
       FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
   rw_crapcop cr_crapcop%ROWTYPE;

   CURSOR cr_arrec(pr_cddbanco crapagb.cddbanco%TYPE
                  ,pr_cdageban crapagb.cdageban%TYPE) IS
     SELECT UPPER(ban.cdbccxlt || ' - ' || ban.nmextbcc) nmextbcc
           ,UPPER(to_char(agb.cdageban,'fm0000') || ' - ' || DECODE(agb.cddbanco,93,ban.nmextbcc,agb.nmageban)) nmageban
       FROM crapban ban
           ,crapagb agb
      WHERE ban.cdbccxlt = agb.cddbanco
        AND ban.cdbccxlt = pr_cddbanco
        AND agb.cdageban = pr_cdageban;
   rw_arrec cr_arrec%ROWTYPE;   

   
begin
  -- Test statements here
  FOR rw_crappro IN cr_crappro LOOP
    OPEN cr_crappro_rowid(pr_cdcooper => rw_crappro.cdcooper
                         ,pr_dsprotoc => rw_crappro.dsprotoc);
    FETCH cr_crappro_rowid INTO rw_crappro_rowid;

    IF cr_crappro_rowid%NOTFOUND THEN
      dbms_output.put_line('Registro da crappro não encontrado');
      CLOSE cr_crappro_rowid;
      CONTINUE;
    END IF;
    CLOSE cr_crappro_rowid;
    
    OPEN cr_crapcop (pr_cdcooper => rw_crappro.cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN
      dbms_output.put_line('Registro da crapcop não encontrado');
      CLOSE cr_crapcop;
    END IF;
    CLOSE cr_crapcop;    
    
    OPEN cr_arrec(pr_cddbanco => 748 -- Sicreci
                 ,pr_cdageban => rw_crapcop.cdagesic);
    FETCH cr_arrec INTO rw_arrec;
    
    IF cr_arrec%NOTFOUND THEN
      dbms_output.put_line('Registro do cursor cr_arrec não encontrado');
      CLOSE cr_arrec;
    END IF;
    CLOSE cr_arrec;    
    
    vr_dsinform##3_atu := rw_crappro_rowid.dsinform##3 ||
                          'Agente Arrecadador: ' ||rw_arrec.nmextbcc || 
                          '#Agência: '||rw_arrec.nmageban;
                          
    BEGIN
      UPDATE crappro
         SET crappro.dsinform##3 = vr_dsinform##3_atu
       WHERE crappro.rowid = rw_crappro_rowid.rowid;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao atualizar registro da crappro. Erro -> '|| SQLERRM);
        RAISE vr_exc_erro;
    END;
    
  END LOOP;
  COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
    WHEN OTHERS THEN
      dbms_output.put_line('Erro não tratado no script. Erro -> '|| SQLERRM);
      ROLLBACK;
end;
