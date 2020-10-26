DECLARE
 
  vr_exc_erro EXCEPTION;
  vr_dsinform##3_atu crappro.dsinform##3%TYPE;

  CURSOR cr_crappro IS
    SELECT a.cdcooper
          ,a.dsprotoc
          ,r.tppagamento
      FROM tbconv_registro_remessa_pagfor r
          ,tbconv_remessa_pagfor          p
          ,crapaut                        a
     WHERE r.idsicredi IN (2253640
                          ,2253818
                          ,2253862
                          ,2254002
                          ,2254570
                          ,2254662
                          ,2254518
                          ,2254517
                          ,2254516
                          ,2254695
                          ,2254691
                          ,2254693
                          ,2254694
                          ,2254692
                          ,2254690
                          ,2254688
                          ,2254689
                          ,2254807
                          ,2254869
                          ,2254870
                          ,2254887
                          ,2254888
                          ,2254947
                          ,2254951
                          ,2254992
                          ,2255023
                          ,2255102
                          ,2255136
                          ,2255149
                          ,2255185
                          ,2255184
                          ,2255197
                          ,2255199
                          ,2255198
                          ,2255232
                          ,2255267
                          ,2255269
                          ,2255268
                          ,2255335
                          ,2255337
                          ,2255336
                          ,2255368
                          ,2255364
                          ,2255421
                          ,2255482
                          ,2255488
                          ,2255489
                          ,2255492
                          ,2255491
                          ,2255490
                          ,2255534
                          ,2255537
                          ,2255539
                          ,2255549
                          ,2255541
                          ,2255544
                          ,2255540
                          ,2255585
                          ,2255582
                          ,2255593
                          ,2255594
                          ,2255598
                          ,2255596
                          ,2255597
                          ,2255595
                          ,2255627
                          ,2255624
                          ,2255633
                          ,2255679
                          ,2255680
                          ,2255683
                          ,2255682
                          ,2255681
                          ,2255734
                          ,2255765
                          ,2255764
                          ,2255892
                          ,2255887
                          ,2255902
                          ,2255904
                          ,2255903
                          ,2255929
                          ,2255940
                          ,2255942
                          ,2255941
                          ,2255999
                          ,2255997
                          ,2256003
                          ,2256004
                          ,2256005
                          ,2256000
                          ,2256001
                          ,2256002
                          ,2256076
                          ,2256193
                          ,2256247
                          ,2256249
                          ,2256257
                          ,2256256
                          ,2256258
                          ,2256293
                          ,2256368
                          ,2256373
                          ,2256390
                          ,2256433
                          ,2256429
                          ,2256430
                          ,2256435
                          ,2256471
                          ,2256469
                          ,2256481
                          ,2256480
                          ,2256479
                          ,2256529
                          ,2256523
                          ,2256532
                          ,2256524
                          ,2256537
                          ,2256536
                          ,2256601
                          ,2256604
                          ,2256610
                          ,2256611
                          ,2256612
                          ,2256614
                          ,2256613
                          ,2256615
                          ,2256653
                          ,2256652
                          ,2256708
                          ,2256707
                          ,2256700
                          ,2256699
                          ,2256698
                          ,2256695
                          ,2256694
                          ,2256743
                          ,2256757
                          ,2256756
                          ,2256750
                          ,2256748
                          ,2256759
                          ,2256761
                          ,2256760
                          ,2256821
                          ,2256815
                          ,2256814
                          ,2256808
                          ,2256805
                          ,2256816
                          ,2256824
                          ,2256868
                          ,2256872
                          ,2256873
                          ,2256874
                          ,2256912
                          ,2256911
                          ,2256916
                          ,2256917
                          ,2256918
                          ,2256920
                          ,2256959
                          ,2256966
                          ,2256964
                          ,2256974
                          ,2256975
                          ,2256996
                          ,2257004
                          ,2257003
                          ,2257005
                          ,2257039
                          ,2257070
                          ,2257075
                          ,2257080
                          ,2257081
                          ,2257113
                          ,2257112
                          ,2257108
                          ,2257114
                          ,2257111
                          ,2257116
                          ,2257165
                          ,2257192
                          ,2257194
                          ,2257193
                          ,2257195
                          ,2257222
                          ,2257225
                          ,2257227
                          ,2257239
                          ,2257263
                          ,2257264
                          ,2257265
                          ,2257279
                          ,2257280
                          ,2257277
                          ,2257276
                          ,2257298
                          ,2257299
                          ,2257313
                          ,2257312
                          ,2257314
                          ,2257315
                          ,2257337
                          ,2257336
                          ,2257367
                          ,2257359
                          ,2257362
                          ,2257443
                          ,2257445
                          ,2257446
                          ,2257476
                          ,2257477
                          ,2257526
                          ,2257580
                          ,2257579
                          ,2257582
                          ,2257620
                          ,2257622
                          ,2257621
                          ,2257677
                          ,2257680
                          ,2257679
                          ,2257678
                          ,2257682
                          ,2257705
                          ,2257737
                          ,2257732
                          ,2257741
                          ,2257744
                          ,2257743
                          ,2257742
                          ,2257768
                          ,2257771
                          ,2257770
                          ,2257769
                          ,2257813
                          ,2257814
                          ,2257815
                          ,2257816
                          ,2257824
                          ,2257819
                          ,2257820
                          ,2257821
                          ,2257823
                          ,2257817
                          ,2257828
                          ,2257827
                          ,2257854
                          ,2257867
                          ,2257915
                          ,2257918
                          ,2257917
                          ,2257916
                          ,2257956
                          ,2257975
                          ,2257977
                          ,2257976
                          ,2258017
                          ,2258021
                          ,2258030
                          ,2258029
                          ,2258025
                          ,2258031
                          ,2258033
                          ,2258032
                          ,2258073
                          ,2258087
                          ,2258078
                          ,2258089
                          ,2258091
                          ,2258090
                          ,2258132
                          ,2258147
                          ,2258151
                          ,2258150
                          ,2258149
                          ,2258181
                          ,2258194
                          ,2258184
                          ,2258195
                          ,2258196
                          ,2258197
                          ,2258201
                          ,2258199
                          ,2258200
                          ,2258198
                          ,2258235
                          ,2258246
                          ,2258249
                          ,2258248
                          ,2258247
                          ,2258310
                          ,2258311
                          ,2258312
                          ,2258313
                          ,2258306
                          ,2258308
                          ,2258309
                          ,2258365
                          ,2258366
                          ,2258372
                          ,2258373
                          ,2258377
                          ,2258448
                          ,2258449
                          ,2258447
                          ,2258446
                          ,2258496
                          ,2258514
                          ,2258561
                          ,2258567
                          ,2258568
                          ,2258566
                          ,2258620
                          ,2258623
                          ,2258621
                          ,2258622
                          ,2258680
                          ,2258683
                          ,2258684
                          ,2258657
                          ,2258658
                          ,2258677
                          ,2258678
                          ,2258688
                          ,2258687
                          ,2258745
                          ,2258746
                          ,2258760
                          ,2258752
                          ,2258749
                          ,2258764
                          ,2258767
                          ,2258766
                          ,2258765
                          ,2258814
                          ,2258813
                          ,2258818
                          ,2258820
                          ,2258819
                          ,2258873
                          ,2258867
                          ,2258875
                          ,2258877
                          ,2258876
                          ,2258934
                          ,2258992
                          ,2258994
                          ,2258993
                          ,2259029
                          ,2259030
                          ,2259035
                          ,2259032
                          ,2259033
                          ,2259031
                          ,2259043
                          ,2259090
                          ,2259089
                          ,2259133
                          ,2259166
                          ,2259169
                          ,2259168
                          ,2259167
                          ,2259172
                          ,2259173
                          ,2259176
                          ,2259175
                          ,2259174
                          ,2259239
                          ,2259238
                          ,2259302
                          ,2259314
                          ,2259315
                          ,2259319
                          ,2259317
                          ,2259318
                          ,2259316
                          ,2259374
                          ,2259371
                          ,2259375
                          ,2259378
                          ,2259377
                          ,2259376
                          ,2259430
                          ,2259438
                          ,2259432
                          ,2259440
                          ,2259439
                          ,2259486
                          ,2259497
                          ,2259539
                          ,2259540
                          ,2259544
                          ,2259542
                          ,2259543
                          ,2259541
                          ,2259605
                          ,2259607
                          ,2259606
                          ,2259648
                          ,2259691
                          ,2259698
                          ,2259699
                          ,2259702
                          ,2259701
                          ,2259700
                          ,2259749
                          ,2259751
                          ,2259750
                          ,2259800
                          ,2259801
                          ,2259805
                          ,2259803
                          ,2259804
                          ,2259802
                          ,2259821
                          ,2259831
                          ,2259830
                          ,2259856
                          ,2259855
                          ,2259858
                          ,2259859
                          ,2259860
                          ,2259861
                          ,2259866
                          ,2259863
                          ,2259864
                          ,2259865
                          ,2259862
                          ,2259899
                          ,2259952
                          ,2259955
                          ,2259954
                          ,2259953
                          ,2259981
                          ,2259980
                          ,2260009
                          ,2260028
                          ,2260029
                          ,2260030
                          ,2260060
                          ,2260093
                          ,2260118
                          ,2260125
                          ,2260127
                          ,2260126
                          ,2260153
                          ,2260188
                          ,2260242
                          ,2260247
                          ,2260246
                          ,2260248
                          ,2260264
                          ,2260267
                          ,2260266
                          ,2260293
                          ,2260292)
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
          ,decode(pro.cdtippro,13,substr(dsinform##3, 1, INSTR(dsinform##3,'#',1,9)),dsinform##3) dsinform##3
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
   
BEGIN
  
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
      CONTINUE;
    END IF;
    CLOSE cr_crapcop;    
    
    OPEN cr_arrec(pr_cddbanco => 748 -- Sicreci
                 ,pr_cdageban => rw_crapcop.cdagesic);
    FETCH cr_arrec INTO rw_arrec;
    
    IF cr_arrec%NOTFOUND THEN
      dbms_output.put_line('Registro do cursor cr_arrec não encontrado');
      CLOSE cr_arrec;
      CONTINUE;
    END IF;
    CLOSE cr_arrec;    
    
    IF rw_crappro.tppagamento = 4 THEN -- GPS
      vr_dsinform##3_atu := rw_crappro_rowid.dsinform##3 ||
                            'Agente Arrecadador: ' ||rw_arrec.nmextbcc || 
                            '#Agência: '||rw_arrec.nmageban;
    ELSE
      vr_dsinform##3_atu := rw_crappro_rowid.dsinform##3;
      vr_dsinform##3_atu := REPLACE(vr_dsinform##3_atu,gene0002.fn_busca_entrada(3, rw_crappro_rowid.dsinform##3, '#'),'Agente Arrecadador: ' || rw_arrec.nmextbcc);
      vr_dsinform##3_atu := REPLACE(vr_dsinform##3_atu,gene0002.fn_busca_entrada(4, rw_crappro_rowid.dsinform##3, '#'),'Agência: ' || rw_arrec.nmageban);
    END IF;
                          
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
      
END;
