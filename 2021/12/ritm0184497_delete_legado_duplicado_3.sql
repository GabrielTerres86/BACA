DECLARE
  CURSOR c01 IS
    SELECT a.idcalris_tanque
          ,a.tpcalculadora
      FROM tbcalris_tanque a
     WHERE a.nrcpfcgc IN (12277220442
                         ,37074359000113
                         ,3142298924
                         ,7601793958
                         ,32188984000172
                         ,9826772941
                         ,7740898902
                         ,32111990809
                         ,5490921960
                         ,9119402945
                         ,41524037000104
                         ,43781644000177
                         ,801353238
                         ,4879083925
                         ,10511422962
                         ,5200216907
                         ,6150192938
                         ,6175042964
                         ,7827815944
                         ,8359517908
                         ,29544867830
                         ,11698231903
                         ,10472930990
                         ,11703456971
                         ,85775738934
                         ,98988859987
                         ,44131012000120
                         ,5619924955
                         ,3824189992
                         ,10092041906
                         ,4089907403
                         ,33396280000158
                         ,3563373914
                         ,4489104979
                         ,8174727973
                         ,10699507936
                         ,11188191950
                         ,9221449904
                         ,8106698971
                         ,7833217913
                         ,663062993
                         ,3851385985
                         ,6841654307
                         ,6901207964
                         ,10007349947
                         ,10797820957
                         ,11125116951
                         ,11177383969
                         ,12782383957
                         ,41752202000177
                         ,44171153000177
                         ,8796737964
                         ,14424636941
                         ,1487179000116
                         ,75326256991
                         ,8556548997
                         ,39173011053
                         ,17860776049
                         ,75855763900
                         ,13108926950
                         ,36456608287
                         ,11744306990
                         ,33666426000138
                         ,42398304000107
                         ,3836048000
                         ,15909625918
                         ,8051126939
                         ,9514777905
                         ,1195179227
                         ,27946340000166
                         ,5846039910
                         ,6197398940
                         ,8410581990
                         ,92036643949
                         ,8268089997
                         ,92225446920
                         ,55169406991
                         ,53251238825
                         ,2737853974
                         ,3551840954
                         ,5587712540
                         ,44301262000161
                         ,34465731000124
                         ,9774258940
                         ,11080894969
                         ,5884864930
                         ,5904548974
                         ,89169255920
                         ,7180660000140
                         ,5151760955
                         ,10539821942
                         ,8980630948
                         ,11187837946
                         ,8297734951
                         ,13028017911
                         ,39422625000187
                         ,41038397839
                         ,12875804910
                         ,4523666741
                         ,10102788944
                         ,6368726962
                         ,9577725996
                         ,44036898000123
                         ,9887805939
                         ,90282116915
                         ,48374318953
                         ,15474319000126
                         ,3981163931
                         ,7805515913
                         ,68020155953
                         ,12906599905
                         ,70091926262
                         ,8903641922
                         ,10778517900
                         ,97052930900
                         ,11554902908
                         ,15052573952
                         ,15331453775
                         ,16973143920
                         ,30712459049
                         ,39833020925
                         ,39857050972
                         ,39987230997
                         ,50969170963
                         ,10637245970
                         ,15619000958
                         ,7690153950
                         ,11224416902
                         ,3855595933
                         ,5916862954
                         ,5131883989
                         ,7074818992
                         ,13246688907
                         ,3189280000116
                         ,8220800950
                         ,86896890010
                         ,70012613274
                         ,10604452985
                         ,6028123994
                         ,2872813535
                         ,10398935971
                         ,7459090948
                         ,5910496948
                         ,3416619960
                         ,6766830964
                         ,76202674920
                         ,73960250959
                         ,9679769950
                         ,48182168953
                         ,43640772000109
                         ,10696589605
                         ,4561664912
                         ,42821715000155
                         ,14603974000174
                         ,87823047004
                         ,37795139000189
                         ,22567392000108
                         ,4343953904
                         ,1200683978
                         ,5397491926
                         ,9272037905
                         ,3880033242
                         ,11067293906
                         ,13504127910
                         ,86594508920
                         ,12881257984
                         ,7365323906
                         ,11961254905
                         ,42957861000102
                         ,2413318976
                         ,4289791069
                         ,5514197921
                         ,5823332963
                         ,436894262
                         ,6631926920
                         ,16209944701
                         ,84093986053
                         ,61016506341
                         ,16109447986
                         ,3707754901
                         ,10576779903
                         ,4455759131
                         ,4011710008
                         ,9522003921
                         ,89268598787
                         ,9290854936
                         ,36625484000101
                         ,4340784257
                         ,10029649978
                         ,340905000100
                         ,10031557902
                         ,14275605950
                         ,3853946917
                         ,42797245806
                         ,75855232972
                         ,8703624960
                         ,10642912955
                         ,84889039953
                         ,10493139923
                         ,11135653909
                         ,82902640978
                         ,4705315928
                         ,11425345964
                         ,44264394000160
                         ,15744199942
                         ,5929265917
                         ,43853707000153
                         ,78331811704
                         ,83204784215
                         ,10539202967
                         ,16101179990
                         ,36213234000164
                         ,39579332000108
                         ,11553156420
                         ,2666598969
                         ,11330663993
                         ,76330362904
                         ,43661067000180
                         ,85341517920
                         ,78543738504
                         ,1615143912
                         ,41577626000142
                         ,12997475902
                         ,6460147906
                         ,3780837919
                         ,33127860889
                         ,3946659292
                         ,77493990972
                         ,852817940
                         ,8321390927
                         ,8279078932
                         ,4825727956
                         ,6682577176
                         ,8693638599
                         ,14106347954
                         ,9859584486
                         ,25699777806
                         ,14183751950
                         ,12212930950
                         ,10838389970
                         ,7712129924
                         ,13435489936
                         ,2113892006
                         ,38324722000174
                         ,989403920
                         ,11704485000110
                         ,4663340954
                         ,616251912
                         ,44255431000174
                         ,44327897000138
                         ,30629298807
                         ,91931711968
                         ,30450408000126
                         ,73465151968
                         ,3542344982
                         ,36931361000107
                         ,4978967961
                         ,9764422993
                         ,8260473941
                         ,10250601990
                         ,9666843978
                         ,43474026000184
                         ,5329141982
                         ,14355974944
                         ,16114607945
                         ,8386695900
                         ,6294285909
                         ,6996948258
                         ,9656522702
                         ,13039704907
                         ,2032322919
                         ,42739650000101
                         ,8863651981
                         ,7673568969
                         ,28134227000149
                         ,7815317995
                         ,1155987233
                         ,34619927805
                         ,9682084954
                         ,2570153966
                         ,4808988984
                         ,10218361920
                         ,12619565910
                         ,6877215982
                         ,43774357000130
                         ,45059560910
                         ,7181209906
                         ,10396804969
                         ,11549241907
                         ,9410209919
                         ,12162650975
                         ,4143977974
                         ,44120281949
                         ,69704384904
                         ,38403635869
                         ,14857709988
                         ,11555388973
                         ,76442276791
                         ,11279333960
                         ,10353777994
                         ,824133986
                         ,1677161906
                         ,7768956990
                         ,44123627000105
                         ,48347986827
                         ,41099010000103
                         ,14397750955
                         ,8388627996
                         ,4753048969
                         ,14482689904
                         ,82183465034
                         ,8192128903
                         ,9470961919
                         ,29376319915
                         ,10431736928
                         ,11184282935
                         ,11517189985
                         ,77010744904
                         ,88743632220
                         ,89889096234
                         ,96218681653
                         ,806797061
                         ,3520774925
                         ,7065149986
                         ,3117167927
                         ,42185028898
                         ,70828798222
                         ,85784030531
                         ,16634345490
                         ,9538573951
                         ,31244053821
                         ,41800719833
                         ,13178108483
                         ,13697997998
                         ,320492265
                         ,8985222937
                         ,5004849960
                         ,6601431940
                         ,10295625988
                         ,99381362220
                         ,6445931995
                         ,1223187900
                         ,998452963
                         ,3094999921
                         ,5999639999
                         ,14041982960
                         ,27043246890
                         ,78220416904
                         ,36163351000160
                         ,42454586000104
                         ,12631777948
                         ,61340316900
                         ,7520138909
                         ,10262566907
                         ,3684581992
                         ,10275972976
                         ,5461211950
                         ,10892830913
                         ,1939421519
                         ,35854768801
                         ,11911241931
                         ,3724819579
                         ,14177134961
                         ,13573838944
                         ,4338031263
                         ,6098786976
                         ,86889036204
                         ,7179743593
                         ,83323848934
                         ,3834879002
                         ,15756407910
                         ,62145269398
                         ,32824976870
                         ,2395790036
                         ,96482117287
                         ,38301180900
                         ,44577764830
                         ,57600384272
                         ,40255173000175
                         ,5321045011
                         ,12283227674
                         ,58633073900
                         ,11537875710
                         ,9678566982
                         ,3121115928
                         ,6925331924
                         ,43655038000105
                         ,6195161942
                         ,47787687878
                         ,1058288903
                         ,93945779987
                         ,9149959956
                         ,10770381944
                         ,42234019000142
                         ,1241152500
                         ,3797284276
                         ,4263956974
                         ,7843246975
                         ,40692751000130
                         ,8312216740
                         ,8344954304
                         ,60112143040
                         ,11690378956
                         ,44325740000173
                         ,34545060854
                         ,65158253072
                         ,6590283958
                         ,33677419000131
                         ,4714575902
                         ,43296358000116
                         ,9530575939
                         ,5683895901
                         ,11903703956
                         ,57335907934
                         ,31581875000158
                         ,12338691911
                         ,7879056904
                         ,8727266907
                         ,62893521304
                         ,44326424000116
                         ,9193680937
                         ,5691256939
                         ,1985499975
                         ,2893435262
                         ,3873873907
                         ,60971959900
                         ,70239100930
                         ,2413350942
                         ,6625570427
                         ,50104705949
                         ,39552472000192
                         ,6855807925
                         ,3767402998
                         ,72580240268
                         ,9099373970
                         ,7827465943
                         ,6448154930
                         ,1308789955
                         ,43853393000199
                         ,95306480900
                         ,8448464907
                         ,9714133980
                         ,10257229906
                         ,33368066153
                         ,67340970991
                         ,7498327201
                         ,8471731940
                         ,10664669980
                         ,9928451907
                         ,2486726225
                         ,62871864373
                         ,71256260410
                         ,5447405998
                         ,44351456000171
                         ,10885853962
                         ,11578897000151
                         ,8505398971
                         ,12396897993
                         ,11670837920
                         ,2700117069
                         ,1460363957
                         ,6251202998
                         ,25149861000167
                         ,1164119000162
                         ,9940964960
                         ,36833664000189
                         ,44303161000120
                         ,68121474949
                         ,44347282000173
                         ,71008537292
                         ,4900083216
                         ,95577548004
                         ,8856712954
                         ,8901100932
                         ,4238153936
                         ,11673721907
                         ,9354944990
                         ,41853210900
                         ,81763786900
                         ,10487737000134
                         ,2662838965
                         ,6866216460
                         ,71468277987
                         ,72777575991
                         ,6004988910
                         ,10278692974
                         ,9689201956
                         ,7365642920
                         ,10789342901
                         ,96381655020
                         ,78263530920
                         ,44415312000131
                         ,1039467997
                         ,5317235936
                         ,11312640960
                         ,6605305973
                         ,12726544940
                         ,9768909927
                         ,14381379900
                         ,71555269915
                         ,6901368976
                         ,4632908525
                         ,43876306809
                         ,837098270
                         ,2649476575
                         ,80151750971
                         ,717936902
                         ,4450291964
                         ,35624974000120
                         ,46515167857
                         ,2224158009
                         ,4598502967
                         ,11521050945
                         ,9259879990
                         ,72486627987
                         ,90567242900
                         ,48949082802
                         ,9008077922
                         ,45643687968
                         ,16882591000108
                         ,6377754906
                         ,38329581934
                         ,13018518926
                         ,84261471949
                         ,12928315705
                         ,9183141944
                         ,37002525875
                         ,936275995
                         ,43072070920
                         ,71732845468
                         ,715087240
                         ,9465503000107
                         ,44093370000196
                         ,10332396908
                         ,11288150873
                         ,14032956979
                         ,42591215000174
                         ,2761937252
                         ,82738025072
                         ,93981821904
                         ,11553619978
                         ,3832922202
                         ,5429172979
                         ,2251226001
                         ,40312168000157
                         ,43871317000106
                         ,44207368000109
                         ,44162478000193
                         ,10704181967
                         ,12678555000176
                         ,80136231900
                         ,15916443994
                         ,13520087693
                         ,4913579908
                         ,30097764000108
                         ,9903982933
                         ,86509316501
                         ,238884236
                         ,44227404000198
                         ,80056326904
                         ,6151762916
                         ,59125209949
                         ,39010287904
                         ,44285349000192
                         ,774446986
                         ,3738122990
                         ,86057502949
                         ,99497387920
                         ,6370577910
                         ,76894088004
                         ,80019237979
                         ,10980510000126
                         ,11673012930
                         ,35866020904
                         ,86585258053
                         ,77595289904
                         ,12555669906
                         ,6823911581
                         ,14384045905
                         ,1031509941
                         ,12461292990
                         ,11731779909
                         ,8616025952
                         ,4253088988
                         ,2612436596
                         ,4288704065
                         ,4724094923
                         ,44264392000171
                         ,6852960919
                         ,4544826985
                         ,6315686974
                         ,7562699976
                         ,11628118970
                         ,42106403879
                         ,65691881515
                         ,32313115000122
                         ,44318086000170
                         ,44320175972
                         ,2438353961
                         ,9810658990
                         ,79419271000136
                         ,44135126000149
                         ,7704567900
                         ,7649423956
                         ,12115082931
                         ,3526243964
                         ,43226506000126
                         ,43572934000100
                         ,8990011906
                         ,849815983
                         ,11229498982
                         ,3782912977
                         ,4170558979
                         ,12372873911
                         ,12783717964
                         ,5815739944
                         ,44197520000101
                         ,6112938979
                         ,11403991952
                         ,37236061000162
                         ,82699330906
                         ,5609638909
                         ,12424152977
                         ,70826315968
                         ,42825407968
                         ,51997347768
                         ,3926548908
                         ,12533886955
                         ,8360662940
                         ,80231012004
                         ,44127750000102
                         ,2575464994
                         ,72127910915
                         ,5065384002
                         ,94052999215
                         ,6454006964
                         ,6595228963
                         ,10887868983
                         ,2625434945
                         ,8297166961
                         ,8535830995
                         ,8887650969
                         ,19606815000147
                         ,44012560000131
                         ,5773689316
                         ,2279437830
                         ,12914743904
                         ,39014630972
                         ,5406387901
                         ,5740896916
                         ,6719914340
                         ,7830030995
                         ,19173651796
                         ,33997063249
                         ,62427047309
                         ,6911377579
                         ,43476989000117
                         ,9777190905
                         ,33563719837
                         ,9216285958
                         ,7627943990
                         ,11982008989
                         ,8480643994
                         ,8013996964
                         ,55215157987
                         ,3331993913
                         ,69910154900
                         ,5889762370
                         ,98566229991
                         ,62535340097
                         ,7625452913
                         ,80037261908
                         ,12536250423
                         ,11166560945
                         ,9285438970
                         ,37996406000186
                         ,5571517913
                         ,8737280929
                         ,12906110922
                         ,21674426020
                         ,91272017915
                         ,70422846406
                         ,13682796940
                         ,1247614964
                         ,44140394000159
                         ,9003478996
                         ,14618896930
                         ,89551141920
                         ,11127938444
                         ,14044926905
                         ,660157900
                         ,9311155900
                         ,11254582916
                         ,43293352987
                         ,21904088000146
                         ,9657155908
                         ,15339632903
                         ,5565632986
                         ,675090539
                         ,1549490940
                         ,7738435585
                         ,7944765978
                         ,3949791922
                         ,9971652943
                         ,16362950291
                         ,7786756000157
                         ,7619418946
                         ,37736803000119
                         ,4504943905
                         ,6049774927
                         ,8108484901
                         ,8389445905
                         ,8946676965
                         ,54367549968
                         ,60174144377
                         ,564326232
                         ,70680345949
                         ,10023539984
                         ,58095594920
                         ,9113414984
                         ,290648130
                         ,14412813983
                         ,6060462910
                         ,9287954976
                         ,9518260931
                         ,6688580950
                         ,10622573918
                         ,1277492921
                         ,10673591921
                         ,7003238993
                         ,11585571911
                         ,4304767950
                         ,50592197808
                         ,13717616986
                         ,16467020855
                         ,7267293964
                         ,14217662998
                         ,5414227900
                         ,87546574315
                         ,5246478000110
                         ,8702663902
                         ,2061097928
                         ,14334309917
                         ,44336916000192
                         ,92258484987
                         ,2387364902
                         ,2630282910
                         ,16112957930
                         ,26171031372
                         ,5764923964
                         ,7584495184
                         ,15934429981
                         ,1189272997
                         ,9591739940
                         ,8936605909
                         ,5147558900
                         ,13555683900
                         ,156120232
                         ,2035406978
                         ,2244405940
                         ,3287292994
                         ,3740050950
                         ,7256433905
                         ,42667067000124
                         ,3459094966
                         ,13739781980
                         ,47115769249
                         ,71144552915
                         ,10802885977
                         ,5975024986
                         ,42873419000106
                         ,11173540911
                         ,613977920
                         ,60922168005307
                         ,68385021949
                         ,73427144968
                         ,7432608997
                         ,4691530916
                         ,7764248908
                         ,491597983
                         ,6298910956
                         ,8860994985
                         ,12778272909
                         ,5758803502
                         ,91634784553
                         ,9185733946
                         ,10964365901
                         ,11047342901
                         ,87580616220
                         ,4814473931
                         ,81832339000156
                         ,8246034944
                         ,8979781962
                         ,9370265902
                         ,11492335916
                         ,11764699912
                         ,12570663905
                         ,7798042954
                         ,2471412246
                         ,5744399941
                         ,11196279900
                         ,10527614459
                         ,12130240992
                         ,14782694806
                         ,15567465980
                         ,28538137972
                         ,5914724490
                         ,10557798922
                         ,44160705000141
                         ,84753480925
                         ,41861458819
                         ,7332580187
                         ,10532201973
                         ,3661204920
                         ,3737803978
                         ,1946875201
                         ,4786763950
                         ,2051523096
                         ,7201623354
                         ,9497968914
                         ,7844658940
                         ,6230756951
                         ,91396948953
                         ,14421935905
                         ,35871814972
                         ,2422008933
                         ,3308444909
                         ,8998942917
                         ,4628380996
                         ,5061287339
                         ,10422658952
                         ,44067689000147
                         ,2020227908
                         ,41667225812
                         ,8542186966
                         ,8414482996
                         ,10296244961
                         ,12542620911
                         ,12701834945
                         ,78577608972
                         ,80013143913
                         ,12929353910
                         ,26914178000131
                         ,34251240000180
                         ,71254609920
                         ,3257023901
                         ,63244047904
                         ,7436038931
                         ,5923681579
                         ,1452603995
                         ,6903423907
                         ,3858857505
                         ,41992986000100
                         ,69352348915
                         ,8028428959
                         ,84509635915
                         ,9488969903
                         ,13078949923
                         ,32439368000147
                         ,70650009231
                         ,13909732984
                         ,80253458900
                         ,91751179915
                         ,10750820993
                         ,31420109000292
                         ,70845597280
                         ,2331711500
                         ,3251715992
                         ,5449027508
                         ,5655564955
                         ,6749642926
                         ,7381802970
                         ,8942289940
                         ,8972510912
                         ,11119484960
                         ,11446317935
                         ,12327440424
                         ,13801825906
                         ,14147194931
                         ,14923896922
                         ,24877585893
                         ,70582769949
                         ,70942814207
                         ,4434799509
                         ,35673877900
                         ,83432914920
                         ,28862952000133
                         ,7838828902
                         ,172034060
                         ,85917206953
                         ,6492716965
                         ,8595311803
                         ,620796979
                         ,2452446971
                         ,46814167204
                         ,72211261949
                         ,48467928972
                         ,4566450988
                         ,3401313061
                         ,14426395984
                         ,9037979920
                         ,7550254907
                         ,2113101904
                         ,1627742069
                         ,10635817969
                         ,15477015950
                         ,10636734960
                         ,40169400000140
                         ,7699469925
                         ,35240331000183
                         ,90102002991
                         ,4498049926
                         ,9994522906
                         ,13753212938
                         ,7362168985
                         ,42225476000170
                         ,8958877979
                         ,4577927012
                         ,1115637983
                         ,94698040906
                         ,10057038929
                         ,11765041937
                         ,3156750204
                         ,4549050926
                         ,8506543940
                         ,1035183048
                         ,44155246000108
                         ,15059660940
                         ,42227500000100
                         ,91777283000
                         ,11098913930
                         ,32952433000133
                         ,1133808956
                         ,469388935
                         ,4991235570
                         ,5914942306
                         ,9139762963
                         ,10627906931
                         ,3196663957
                         ,80969658915
                         ,60062291025
                         ,11368433960
                         ,9273304907)
       AND a.tpcooperado = 'L';
  TYPE tb_cursor IS TABLE OF c01%ROWTYPE INDEX BY PLS_INTEGER;
  tb_c01 tb_cursor;
BEGIN
  OPEN c01;
  LOOP
    FETCH c01 BULK COLLECT
      INTO tb_c01;
    FORALL i IN tb_c01.first .. tb_c01.last
      DELETE FROM tbcalris_tanque
       WHERE idcalris_tanque = tb_c01(i).idcalris_tanque
         AND tpcalculadora = tb_c01(i).tpcalculadora;
    COMMIT;
    EXIT;
  END LOOP;
  CLOSE c01;
END;