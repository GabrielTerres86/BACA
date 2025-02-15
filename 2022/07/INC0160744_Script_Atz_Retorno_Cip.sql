DECLARE  
         
  CURSOR cr_crapcob  IS
  SELECT cob.cdcooper,
         cob.nrdconta,
         cob.nrcnvcob,
         cob.nrdocmto,
         cob.vltitulo,
         cob.dtvencto,
         cob.cdbandoc, 
         cob.cdcartei,
         rowid
    FROM crapcob cob
    WHERE cob.incobran = 0
                    AND   cob.inenvcip = 2
                    AND   idtitleg IN (77798041
                                         ,77797593
                                         ,77798198
                                         ,77797608
                                         ,77797730
                                         ,77798108
                                         ,77797737
                                         ,77797735
                                         ,77798005
                                         ,77798007
                                         ,77798013
                                         ,77798032
                                         ,77798206
                                         ,77798207
                                         ,77798233
                                         ,77798347
                                         ,77798111
                                         ,77798034
                                         ,77798256
                                         ,77798251
                                         ,77798120
                                         ,77798042
                                         ,77798244
                                         ,77798125
                                         ,77798127
                                         ,77798128
                                         ,77798129
                                         ,77798131
                                         ,77798132
                                         ,77798137
                                         ,77798138
                                         ,77798141
                                         ,77798142
                                         ,77798150
                                         ,77798154
                                         ,77798155
                                         ,77798156
                                         ,77798158
                                         ,77798166
                                         ,77798167
                                         ,77798172
                                         ,77798181
                                         ,77798183
                                         ,77798257
                                         ,77798258
                                         ,77798343
                                         ,77797815
                                         ,77798051
                                         ,77798106
                                         ,77797531
                                         ,77797533
                                         ,77797570
                                         ,77797571
                                         ,77797577
                                         ,77797587
                                         ,77797588
                                         ,77797589
                                         ,77797595
                                         ,77797597
                                         ,77797598
                                         ,77797600
                                         ,77797601
                                         ,77797626
                                         ,77797627
                                         ,77797628
                                         ,77797629
                                         ,77797630
                                         ,77797631
                                         ,77797632
                                         ,77797633
                                         ,77797640
                                         ,77797641
                                         ,77797642
                                         ,77797643
                                         ,77797658
                                         ,77798011
                                         ,77798027
                                         ,77798040
                                         ,77798201
                                         ,77798235
                                         ,77798054
                                         ,77798092
                                         ,77798104
                                         ,77798052
                                         ,77797648
                                         ,77797667
                                         ,77798346
                                         ,77798230
                                         ,77798047
                                         ,77798009
                                         ,77797602
                                         ,77797811
                                         ,77798110
                                         ,77798139
                                         ,77798140
                                         ,77797592
                                         ,77797590
                                         ,77797591
                                         ,77798159
                                         ,77798199
                                         ,77797537
                                         ,77798025
                                         ,77798061
                                         ,77798062
                                         ,77798063
                                         ,77798064
                                         ,77798065
                                         ,77798066
                                         ,77797561
                                         ,77797579
                                         ,77797580
                                         ,77797581
                                         ,77797582
                                         ,77797532
                                         ,77797534
                                         ,77798121
                                         ,77798174
                                         ,77798078
                                         ,77798176
                                         ,77798177
                                         ,77798180
                                         ,77798182
                                         ,77798184
                                         ,77798185
                                         ,77798028
                                         ,77798112
                                         ,77798205
                                         ,77798126
                                         ,77798134
                                         ,77798136
                                         ,77798144
                                         ,77798147
                                         ,77798148
                                         ,77798151
                                         ,77798153
                                         ,77798170
                                         ,77798171
                                         ,77797507
                                         ,77798071
                                         ,77798073
                                         ,77798175
                                         ,77798186
                                         ,77797575
                                         ,77798044
                                         ,77798045
                                         ,77797634
                                         ,77797635
                                         ,77797636
                                         ,77797637
                                         ,77797638
                                         ,77798046
                                         ,77798048
                                         ,77798097
                                         ,77798109
                                         ,77798004
                                         ,77798008
                                         ,77797525
                                         ,77797529
                                         ,77797544
                                         ,77797550
                                         ,77797572
                                         ,77797573
                                         ,77797576
                                         ,77797666
                                         ,77798113
                                         ,77797501
                                         ,77798204
                                         ,77798033
                                         ,77798050
                                         ,77797744
                                         ,77797745
                                         ,77798080
                                         ,77798081
                                         ,77798087
                                         ,77798093
                                         ,77798095
                                         ,77798096
                                         ,77798107
                                         ,77798145
                                         ,77798197
                                         ,77798227
                                         ,77797611
                                         ,77798026
                                         ,77798200
                                         ,77798043
                                         ,77797556
                                         ,77797555
                                         ,77797553
                                         ,77797548
                                         ,77798192
                                         ,77798169
                                         ,77798168
                                         ,77798164
                                         ,77798162
                                         ,77798160
                                         ,77798157
                                         ,77798152
                                         ,77798146
                                         ,77798143
                                         ,77798031
                                         ,77798179
                                         ,77798088
                                         ,77798079
                                         ,77798077
                                         ,77798074
                                         ,77798072
                                         ,77798070
                                         ,77798069
                                         ,77798067
                                         ,77797583
                                         ,77797678
                                         ,77798252
                                         ,77797651
                                         ,77797672
                                         ,77798272
                                         ,77797679
                                         ,77797652
                                         ,77797653
                                         ,77797661
                                         ,77797688
                                         ,77797680
                                         ,77798263
                                         ,77798014
                                         ,77798231
                                         ,77798103
                                         ,77798259
                                         ,77797660
                                         ,77797816
                                         ,77797819
                                         ,77797824
                                         ,77797825
                                         ,77797826
                                         ,77797827
                                         ,77797828
                                         ,77797829
                                         ,77797830
                                         ,77797832
                                         ,77797833
                                         ,77797834
                                         ,77797835
                                         ,77797836
                                         ,77797837
                                         ,77797838
                                         ,77797839
                                         ,77798161
                                         ,77798163
                                         ,77798165
                                         ,77797738
                                         ,77797739
                                         ,77797742
                                         ,77797809
                                         ,77798082
                                         ,77798089
                                         ,77798102
                                         ,77798105
                                         ,77797689
                                         ,77798068
                                         ,77798075
                                         ,77798229
                                         ,77798056
                                         ,77798057
                                         ,77798058
                                         ,77798059
                                         ,77798060
                                         ,77797503
                                         ,77798245
                                         ,77797535
                                         ,77797541
                                         ,77797543
                                         ,77797546
                                         ,77797549
                                         ,77797560
                                         ,77797566
                                         ,77797567
                                         ,77797568
                                         ,77797578
                                         ,77797586
                                         ,77797599
                                         ,77797603
                                         ,77797623
                                         ,77797646
                                         ,77797812
                                         ,77797682
                                         ,77797685
                                         ,77797530
                                         ,77797552
                                         ,77797665
                                         ,77797594
                                         ,77797656
                                         ,77797663
                                         ,77797569
                                         ,77797639
                                         ,77797624
                                         ,77797705
                                         ,77797706
                                         ,77797707
                                         ,77797708
                                         ,77797709
                                         ,77797710
                                         ,77797711
                                         ,77797714
                                         ,77797654
                                         ,77797746
                                         ,77798094
                                         ,77798098
                                         ,77798099
                                         ,77797803
                                         ,77797806
                                         ,77798055
                                         ,77797804
                                         ,77797805
                                         ,77798188
                                         ,77797808
                                         ,77797606
                                         ,77798246
                                         ,77797502
                                         ,77798240
                                         ,77797521
                                         ,77797574
                                         ,77798194
                                         ,77798195
                                         ,77798196
                                         ,77797703
                                         ,77798236
                                         ,77797554
                                         ,77797536
                                         ,77798216
                                         ,77798083
                                         ,77797802
                                         ,77798076
                                         ,77797506
                                         ,77797526
                                         ,77797527
                                         ,77797625
                                         ,77797540
                                         ,77797596
                                         ,77797807
                                         ,77797740
                                         ,77797673
                                         ,77797662
                                         ,77798191
                                         ,77797610
                                         ,77797690
                                         ,77797704
                                         ,77797547
                                         ,77797670
                                         ,77797505
                                         ,77798118
                                         ,77797551
                                         ,77797558
                                         ,77797831
                                         ,77798084
                                         ,77797820
                                         ,77797562
                                         ,77798242
                                         ,77798266
                                         ,77797748
                                         ,77798114
                                         ,77797668
                                         ,77797801
                                         ,77797722
                                         ,77798254
                                         ,77798208
                                         ,77798085
                                         ,77797731
                                         ,77797691
                                         ,77798273
                                         ,77797681
                                         ,77797674
                                         ,77797584
                                         ,77797813
                                         ,77798015
                                         ,77798086
                                         ,77797821
                                         ,77797817
                                         ,77797693
                                         ,77798249
                                         ,77797647
                                         ,77798260
                                         ,77797712
                                         ,77797750
                                         ,77798267
                                         ,77798189
                                         ,77798269
                                         ,77798100
                                         ,77797545
                                         ,77797542
                                         ,77797538
                                         ,77797686
                                         ,77797683
                                         ,77797655
                                         ,77798237
                                         ,77797557
                                         ,77798217
                                         ,77797715
                                         ,77797694
                                         ,77797508
                                         ,77797741
                                         ,77797675
                                         ,77797613
                                         ,77797822
                                         ,77798119
                                         ,77797563
                                         ,77797753
                                         ,77797669
                                         ,77798115
                                         ,77797724
                                         ,77798255
                                         ,77798234
                                         ,77798209
                                         ,77798035
                                         ,77797732
                                         ,77797585
                                         ,77797676
                                         ,77797696
                                         ,77797823
                                         ,77797818
                                         ,77797814
                                         ,77798274
                                         ,77798016
                                         ,77798261
                                         ,77797539
                                         ,77797649
                                         ,77797698
                                         ,77797684
                                         ,77797687
                                         ,77797713
                                         ,77797755
                                         ,77798190
                                         ,77798101
                                         ,77797729
                                         ,77797657
                                         ,77798238
                                         ,77797716
                                         ,77797559
                                         ,77797509
                                         ,77797615
                                         ,77797677
                                         ,77797564
                                         ,77798116
                                         ,77797671
                                         ,77797726
                                         ,77798210
                                         ,77798036
                                         ,77797733
                                         ,77798017
                                         ,77798262
                                         ,77798271
                                         ,77797659
                                         ,77798239
                                         ,77797717
                                         ,77798219
                                         ,77797692
                                         ,77797510
                                         ,77797616
                                         ,77797565
                                         ,77798117
                                         ,77797728
                                         ,77798037
                                         ,77798211
                                         ,77797734
                                         ,77798018
                                         ,77797718
                                         ,77798220
                                         ,77797511
                                         ,77797695
                                         ,77797617
                                         ,77798019
                                         ,77797719
                                         ,77797618
                                         ,77797512
                                         ,77797697
                                         ,77798213
                                         ,77798020
                                         ,77798222
                                         ,77797720
                                         ,77797619
                                         ,77797513
                                         ,77797699
                                         ,77798214
                                         ,77798021
                                         ,77798223
                                         ,77797721
                                         ,77797514
                                         ,77797700
                                         ,77797620
                                         ,77798224
                                         ,77797723
                                         ,77797621
                                         ,77797515
                                         ,77797701
                                         ,77797725
                                         ,77798225
                                         ,77797702
                                         ,77797622
                                         ,77797516
                                         ,77798024
                                         ,77797727
                                         ,77797517
                                         ,77797747
                                         ,77797518
                                         ,77797749
                                         ,77797519
                                         ,77797751
                                         ,77797520
                                         ,77797752
                                         ,77797522
                                         ,77797754
                                         ,77797523
                                         ,77797756
                                         ,77797524
                                         ,77797757
                                         ,77797758
                                         ,77797759
                                         ,77797760
                                         ,77797761
                                         ,77797762
                                         ,77797763
                                         ,77797764
                                         ,77797765
                                         ,77797766
                                         ,77797767
                                         ,77797768
                                         ,77797769
                                         ,77797770
                                         ,77797771
                                         ,77797772
                                         ,77797773
                                         ,77797774
                                         ,77797775
                                         ,77797776
                                         ,77797777
                                         ,77797778
                                         ,77797779
                                         ,77797780
                                         ,77797781
                                         ,77797782
                                         ,77797783
                                         ,77797784
                                         ,77797785
                                         ,77797786
                                         ,77797787
                                         ,77797788
                                         ,77797789
                                         ,77797790
                                         ,77797791
                                         ,77797792
                                         ,77797793
                                         ,77797794
                                         ,77797795
                                         ,77797796
                                         ,77797797
                                         ,77797798
                                         ,77797799
                                         ,77797800);

   rw_crapcob cr_crapcob%ROWTYPE;

   vr_cdbarras VARCHAR2(60);    
   vr_lindigi1 NUMBER;
   vr_lindigi2 NUMBER;
   vr_lindigi3 NUMBER;
   vr_lindigi4 NUMBER;
   vr_lindigi5 NUMBER;

   vr_nrdocbenf     NUMBER;  
   vr_tppesbenf     VARCHAR2(100); 
   vr_dsbenefic     VARCHAR2(100); 
   vr_nrdocbenf_fin NUMBER;
   vr_tppesbenf_fin VARCHAR2(100);
   vr_dsbenefic_fin VARCHAR2(100);   
   vr_vlrtitulo     NUMBER;       
   vr_cdctrlcs      VARCHAR2(100);  
   vr_tbtitulocip   NPCB0001.typ_reg_titulocip;        
   vr_flblq_valor   INTEGER;
   vr_flgtitven     INTEGER;
   vr_flcontig      NUMBER;   
   vr_vlrjuros NUMBER;
   vr_vlrmulta NUMBER;
   vr_vldescto NUMBER;
   
   vr_cdcritic crapcri.cdcritic%TYPE;
   vr_dscritic VARCHAR2(4000);
   vr_des_erro VARCHAR2(4000);
   vr_idsacavalst NUMBER;
   
   vr_cdprogra VARCHAR2(40) := 'INC0160744';
   vr_idprglog         NUMBER := 0;
   vr_module_name      VARCHAR2(100) := NULL;
   vr_action_name      VARCHAR2(100) := NULL;  
       
  BEGIN   

    cobr0014.gerarLogInicio(pr_cdcooper      => 3
                           ,pr_cdagenci      => 0
                           ,pr_cdprogra      => vr_cdprogra
                           ,pr_cdprocedure   => vr_cdprogra
                           ,pr_idprglog      => vr_idprglog
                           ,pr_dscomplemento => NULL
                           ,pr_module_name   => vr_module_name
                           ,pr_action_name   => vr_action_name);      
    
    FOR rw_crapcob IN cr_crapcob LOOP

      cobr0005.pc_calc_codigo_barras
                 (pr_dtvencto => rw_crapcob.dtvencto,
                  pr_cdbandoc => rw_crapcob.cdbandoc,
                  pr_vltitulo => rw_crapcob.vltitulo,
                  pr_nrcnvcob => rw_crapcob.nrcnvcob,
                  pr_nrcnvceb => 0,
                  pr_nrdconta => rw_crapcob.nrdconta,
                  pr_nrdocmto => rw_crapcob.nrdocmto,
                  pr_cdcartei => rw_crapcob.cdcartei,
                  pr_cdbarras => vr_cdbarras);


      vr_lindigi1 := 0;
      vr_lindigi2 := 0;
      vr_lindigi3 := 0;
      vr_lindigi4 := 0;
      vr_lindigi5 := 0;

      NPCB0002.pc_consultar_titulo_cip(pr_cdcooper      => rw_crapcob.cdcooper 
                                      ,pr_nrdconta      => rw_crapcob.nrdconta      
                                      ,pr_cdagenci      => 90
                                      ,pr_flmobile      => 0
                                      ,pr_dtmvtolt      => trunc(SYSDATE)
                                      ,pr_titulo1       => vr_lindigi1  
                                      ,pr_titulo2       => vr_lindigi2  
                                      ,pr_titulo3       => vr_lindigi3  
                                      ,pr_titulo4       => vr_lindigi4  
                                      ,pr_titulo5       => vr_lindigi5  
                                      ,pr_codigo_barras => vr_cdbarras  
                                      ,pr_cdoperad      => '1'
                                      ,pr_idorigem      => 3
                                      ,pr_nrdocbenf     => vr_nrdocbenf
                                      ,pr_tppesbenf     => vr_tppesbenf
                                      ,pr_dsbenefic     => vr_dsbenefic      
                                      ,pr_nrdocbenf_fin => vr_nrdocbenf_fin
                                      ,pr_tppesbenf_fin => vr_tppesbenf_fin
                                      ,pr_dsbenefic_fin => vr_dsbenefic_fin
                                      ,pr_idsacavalst   => vr_idsacavalst
                                      ,pr_vlrtitulo     => vr_vlrtitulo      
                                      ,pr_vlrjuros      => vr_vlrjuros       
                                      ,pr_vlrmulta      => vr_vlrmulta       
                                      ,pr_vlrdescto     => vr_vldescto      
                                      ,pr_cdctrlcs      => vr_cdctrlcs       
                                      ,pr_tbtitulocip   => vr_tbtitulocip    
                                      ,pr_flblq_valor   => vr_flblq_valor    
                                      ,pr_fltitven      => vr_flgtitven
                                      ,pr_flcontig      => vr_flcontig
                                      ,pr_des_erro      => vr_des_erro       
                                      ,pr_cdcritic      => vr_cdcritic       
                                      ,pr_dscritic      => vr_dscritic);     
                                                         
      IF vr_des_erro = 'OK' THEN
          UPDATE crapcob cob
          SET cob.inenvcip = 3
             ,cob.insitpro = 3
             ,cob.nrdident = vr_tbtitulocip.NumIdentcTit
             ,cob.nratutit = vr_tbtitulocip.NumRefAtlCadTit
             ,cob.flgcbdda = 1
             ,cob.dhenvcip = SYSDATE             
          WHERE rowid = rw_crapcob.rowid;             
          
          PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'Titulo Registrado Manual - CIP'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);          
      ELSE 
        cobr0014.gerarLogFim( pr_cdcooper      => rw_crapcob.cdcooper
                             ,pr_cdagenci      => 0
                             ,pr_cdprogra      => vr_cdprogra
                             ,pr_cdprocedure   => vr_cdprogra
                             ,pr_idprglog      => vr_idprglog
                             ,pr_dscomplemento => 'Boleto n�o atualizado - '||rw_crapcob.cdcooper||'-'||rw_crapcob.nrdconta||'-'||rw_crapcob.nrdocmto||' Erro - '||vr_dscritic
                             ,pr_module_name   => vr_module_name
                             ,pr_action_name   => vr_action_name);                                    
        
      END IF;  

      COMMIT;                  

    END LOOP;

    cobr0014.gerarLogFim(pr_cdcooper      => 3
                           ,pr_cdagenci      => 0
                           ,pr_cdprogra      => vr_cdprogra
                           ,pr_cdprocedure   => vr_cdprogra
                           ,pr_idprglog      => vr_idprglog
                           ,pr_dscomplemento => vr_dscritic
                           ,pr_module_name   => vr_module_name
                           ,pr_action_name   => vr_action_name);                                    
    
  EXCEPTION 
    WHEN OTHERS THEN
      cobr0014.gerarLogFim(pr_cdcooper      => 3
                           ,pr_cdagenci      => 0
                           ,pr_cdprogra      => vr_cdprogra
                           ,pr_cdprocedure   => vr_cdprogra
                           ,pr_idprglog      => vr_idprglog
                           ,pr_dscomplemento => 'Erro - '||SQLERRM
                           ,pr_module_name   => vr_module_name
                           ,pr_action_name   => vr_action_name);                                    
      
      ROLLBACK;
  END ;
