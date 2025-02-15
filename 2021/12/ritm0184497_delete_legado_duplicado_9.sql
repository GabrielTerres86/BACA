DECLARE
  CURSOR c01 IS
    SELECT a.idcalris_tanque
          ,a.tpcalculadora
      FROM tbcalris_tanque a
     WHERE a.nrcpfcgc IN (7953928930
                         ,8741798902
                         ,8978264930
                         ,9283022530
                         ,9823553947
                         ,12694419909
                         ,13136142977
                         ,6031615452
                         ,55079970987
                         ,6728232923
                         ,15988165940
                         ,12298463956
                         ,9852997971
                         ,2926878001
                         ,1585944017
                         ,8681804910
                         ,6749027938
                         ,9674554998
                         ,43142773000115
                         ,14322586724
                         ,3739257946
                         ,13818284938
                         ,9956666955
                         ,35041826000183
                         ,465565913
                         ,2446521398
                         ,9153645812
                         ,10161555900
                         ,10882729918
                         ,10917638875
                         ,13192718803
                         ,71204288968
                         ,74321269253
                         ,87237300997
                         ,2365060994
                         ,7568287912
                         ,11472385969
                         ,10895807971
                         ,35387050978
                         ,5601618917
                         ,7533891937
                         ,11794791906
                         ,44291666000111
                         ,44275793000127
                         ,7674928977
                         ,52030385972
                         ,2913904475
                         ,8619022970
                         ,43644992000100
                         ,7838103932
                         ,8754995973
                         ,2171954078
                         ,58567658934
                         ,26686954810
                         ,70745042201
                         ,8527108950
                         ,6314578957
                         ,58499695949
                         ,8485908996
                         ,35209975000109
                         ,70064415953
                         ,65498828187
                         ,9126394901
                         ,1789874920
                         ,72803266920
                         ,89015940053
                         ,33193544000176
                         ,44108434000185
                         ,44134780000138
                         ,8269796964
                         ,6988353950
                         ,7697637901
                         ,97087025953
                         ,11449816975
                         ,5457936538
                         ,3333478978
                         ,6898428993
                         ,3599349940
                         ,7669299908
                         ,10157534936
                         ,9380848951
                         ,10954932994
                         ,3263712900
                         ,943945984
                         ,1214765963
                         ,4038035948
                         ,4508145485
                         ,43856212000188
                         ,43568232000153
                         ,7229388961
                         ,7994366902
                         ,10151288909
                         ,13035915962
                         ,13600285955
                         ,27103901830
                         ,38301067934
                         ,79149650904
                         ,44104699000105
                         ,2286533989
                         ,3986681914
                         ,39818302000107
                         ,7112877911
                         ,6062089922
                         ,1931860980
                         ,5633950950
                         ,2190863201
                         ,8963396452
                         ,10342470930
                         ,5175581902
                         ,43674658968
                         ,5993023309
                         ,2941675957
                         ,44104624000124
                         ,12049407971
                         ,4911940999
                         ,29728597000177
                         ,7009820511
                         ,4786064270
                         ,9364047958
                         ,10916986942
                         ,93627866991
                         ,10575168994
                         ,80069690944
                         ,9776856918
                         ,1061509958
                         ,4407293942
                         ,4340692000178
                         ,132055000155
                         ,3745942957
                         ,45056348848
                         ,18985891000148
                         ,12025643993
                         ,97306070010
                         ,4733820917
                         ,4362376283
                         ,83066159000306
                         ,9317291902
                         ,95190465004
                         ,6763400594
                         ,14003283902
                         ,38147215000102
                         ,8967019998
                         ,40180026020
                         ,46405784827
                         ,3430496000202
                         ,6478288986
                         ,65158431353
                         ,22925423000155
                         ,8545939930
                         ,10114544913
                         ,36654940000222
                         ,9179059970
                         ,70995850968
                         ,1363039008
                         ,63297577398
                         ,10283305967
                         ,10485994933
                         ,13675426939
                         ,51227851049
                         ,10765940930
                         ,50866826904
                         ,80096362901
                         ,44137626000110
                         ,9362808919
                         ,58946276991
                         ,7421799907
                         ,62420286383
                         ,91136121900
                         ,2916046925
                         ,8664721939
                         ,9739892973
                         ,10654069913
                         ,71055611223
                         ,10982726929
                         ,12156070911
                         ,10267059590
                         ,42168057000144
                         ,15508069984
                         ,10613915909
                         ,5338169983
                         ,70434798436
                         ,10888408927
                         ,4480786945
                         ,7332196913
                         ,44363692000108
                         ,1146916221
                         ,9720834994
                         ,10867253959
                         ,10442354975
                         ,79910475987
                         ,3078180980
                         ,3175599907
                         ,3720676978
                         ,4143740966
                         ,4247269046
                         ,9341578981
                         ,68030088
                         ,5784923935
                         ,38091726000150
                         ,12211188974
                         ,38057140925
                         ,8808403904
                         ,7077307590
                         ,4279822000
                         ,8269860999
                         ,3564896201
                         ,56336012972
                         ,4339329533
                         ,2935346912
                         ,5677665940
                         ,24921947953
                         ,10531723976
                         ,7656176926
                         ,6675195999
                         ,1675243212
                         ,8698832911
                         ,6849154990
                         ,34549136000177
                         ,2409686036
                         ,31917356900
                         ,58675558953
                         ,14722936498
                         ,339233966
                         ,4937483935
                         ,9273713408
                         ,64382117968
                         ,81400691915
                         ,4844704931
                         ,3450470957
                         ,65635086934
                         ,74402226953
                         ,7649187969
                         ,3353584544
                         ,60179953087
                         ,99959879968
                         ,2468451988
                         ,35138765000177
                         ,44195357000148
                         ,7488935985
                         ,7840506941
                         ,8268722983
                         ,8412407954
                         ,10510111912
                         ,83304584900
                         ,7391570940
                         ,30194783000152
                         ,9608459508
                         ,9731048995
                         ,1968682031
                         ,42875646000162
                         ,464824907
                         ,15487032300
                         ,10010512977
                         ,6690163903
                         ,10067683940
                         ,9098174990
                         ,44226020000150
                         ,30167293850
                         ,10015301958
                         ,10723303932
                         ,12261756941
                         ,9490224979
                         ,12358994979
                         ,10053455975
                         ,8304131978
                         ,7530104969
                         ,37643572000107
                         ,7664178916
                         ,14177978
                         ,44164767000121
                         ,8042014988
                         ,9181663900
                         ,2758341077
                         ,5447916909
                         ,86655337968
                         ,452868920
                         ,4970461309
                         ,11383993963
                         ,5456532905
                         ,7311772907
                         ,9487715932
                         ,5742166931
                         ,13263519905
                         ,10250571986
                         ,15955138927
                         ,22806046807
                         ,38666093889
                         ,62133245340
                         ,13812685000112
                         ,44263350000116
                         ,41944874000184
                         ,1798833999
                         ,9800745920
                         ,13024561994
                         ,3562661410
                         ,56231407934
                         ,85910252968
                         ,29151854848
                         ,4867273945
                         ,55741240925
                         ,977395960
                         ,12873326921
                         ,12223068910
                         ,13079315960
                         ,2434214517
                         ,3314284900
                         ,1278831002
                         ,4647266974
                         ,5796185365
                         ,6469587208
                         ,6761877903
                         ,10948926961
                         ,52878481291
                         ,57874115287
                         ,42750210000147
                         ,8537710903
                         ,8034911909
                         ,12694406912
                         ,3882936088
                         ,87656060944
                         ,37260812000186
                         ,3007437938
                         ,12586974913
                         ,44245557000168
                         ,81655355953
                         ,9439948000112
                         ,13711671926
                         ,6372637316
                         ,36463354830
                         ,9921628909
                         ,13841657974
                         ,13005752984
                         ,29897409000134
                         ,11780795971
                         ,97880329587
                         ,96006200910
                         ,1066819742
                         ,3763486909
                         ,2424582971
                         ,9733204943
                         ,9653115979
                         ,13940815969
                         ,10086778927
                         ,5491484938
                         ,6016259942
                         ,5646303907
                         ,7504433918
                         ,86004549991
                         ,8168896947
                         ,11243761946
                         ,9302259960
                         ,13495851909
                         ,4336037639
                         ,65232356968
                         ,46886798820
                         ,5042172912
                         ,42359935852
                         ,44022593000162
                         ,8929100465
                         ,35707755187
                         ,80674831000188
                         ,2868453503
                         ,92423655215
                         ,10415346983
                         ,3051474207
                         ,9064929980
                         ,2780296984
                         ,3247737901
                         ,42816998215
                         ,10250232000151
                         ,15773632000165
                         ,3601244969
                         ,54206715904
                         ,7090177904
                         ,90286413949
                         ,3602248909
                         ,44289665000132
                         ,12689177706
                         ,55374757822
                         ,66054745972
                         ,1795808926
                         ,6958821980
                         ,38186448888
                         ,11298337984
                         ,3716976970
                         ,5936439925
                         ,12502229901
                         ,3273612983
                         ,9591196989
                         ,7154409932
                         ,2237755922
                         ,9698814957
                         ,32372914049
                         ,6402282910
                         ,3786604975
                         ,25255709000169
                         ,8794462933
                         ,15036188977
                         ,3840378958
                         ,5328613961
                         ,6416731916
                         ,4762024000139
                         ,6079475944
                         ,43906393000100
                         ,1387123017
                         ,4344327179
                         ,42074944000153
                         ,1024499960
                         ,6294427975
                         ,2049265212
                         ,6499389927
                         ,56267134920
                         ,9399583929
                         ,398605904
                         ,1117444821
                         ,8079084955
                         ,12484198981
                         ,29298229291
                         ,35251717814
                         ,4288322960
                         ,98559923004
                         ,9534839914
                         ,5714003020
                         ,44225960000125
                         ,4023229911
                         ,15947249979
                         ,4897504945
                         ,11299892914
                         ,10525117407
                         ,10635205920
                         ,12027662936
                         ,12323018507
                         ,42360692534
                         ,43803441854
                         ,11038161444
                         ,7175602952
                         ,39562466000116
                         ,10468652930
                         ,10668273976
                         ,3897490951
                         ,3473125008
                         ,9581710922
                         ,14033459960
                         ,8622173933
                         ,441722903
                         ,11171672918
                         ,11850812918
                         ,12887487957
                         ,36720046187
                         ,13527698914
                         ,14059756440
                         ,28967151000132
                         ,71307801188
                         ,43427982000105
                         ,80182557928
                         ,84409312472
                         ,99818426053
                         ,40406219000100
                         ,48333756808
                         ,39613586806
                         ,3180210052
                         ,7689706959
                         ,4925126202
                         ,42348591000132
                         ,1276185030
                         ,9867843975
                         ,4034896957
                         ,6485914927
                         ,10277669944
                         ,4430261148
                         ,4759531939
                         ,72165103991
                         ,97817309272
                         ,96207981987
                         ,1856914984
                         ,55887387807
                         ,6921356930
                         ,12580135928
                         ,7468499900
                         ,11647215935
                         ,3986472916
                         ,7922508930
                         ,8077694950
                         ,6153636950
                         ,9389921988
                         ,64858502953
                         ,36874566091
                         ,11201306973
                         ,11635717000126
                         ,5093197939
                         ,7195439917
                         ,3862236960
                         ,12030526932
                         ,1805969269
                         ,44363374000147
                         ,93811047272
                         ,8711761903
                         ,1334047227
                         ,3430063914
                         ,41046366220
                         ,7732073924
                         ,10244132925
                         ,10074387979
                         ,525312951
                         ,819942227
                         ,3712207930
                         ,12837914983
                         ,12852521954
                         ,8762957902
                         ,42655102000195
                         ,3821562935
                         ,7980087925
                         ,64547108900
                         ,42664489968
                         ,47680950890
                         ,71225192447
                         ,11080960000125
                         ,3051804959
                         ,43822897000141
                         ,8009797960
                         ,12171214988
                         ,11342990951
                         ,9250958935
                         ,43010143000197
                         ,69900507053
                         ,7286463900
                         ,12589710976
                         ,1909691992
                         ,10162779976
                         ,10888236964
                         ,12330198990
                         ,19135627867
                         ,67462995972
                         ,18234467000161
                         ,2557964980
                         ,10988751925
                         ,9049518982
                         ,9226055998
                         ,6815798976
                         ,10492026947
                         ,8842629952
                         ,3930788926
                         ,4691009906
                         ,10013244981
                         ,8512998903
                         ,11538927900
                         ,8558822980
                         ,44091598000147
                         ,2681702070
                         ,87452995953
                         ,42684144000154
                         ,7081868908
                         ,2876996928
                         ,3411260980
                         ,9211358906
                         ,13215100983
                         ,5567570929
                         ,5887092980
                         ,12336388669
                         ,7693178554
                         ,9714752965
                         ,10215728963
                         ,33397721000136
                         ,53077202700
                         ,85905224900
                         ,11449299970
                         ,13875066928
                         ,97847771934
                         ,41085659836
                         ,62842469356
                         ,5173466995
                         ,4803849919
                         ,8694775956
                         ,6713152937
                         ,87695782904
                         ,36704663000134
                         ,70576220906
                         ,81855567920
                         ,31134516000152
                         ,11746091924
                         ,2942590408
                         ,2915281980
                         ,4317982900
                         ,6197203952
                         ,6524980948
                         ,9950181976
                         ,10573377901
                         ,14117321978
                         ,5277487905
                         ,33825937852
                         ,10548615950
                         ,1570947902
                         ,15069855999
                         ,5386100262
                         ,1063070295
                         ,7150914926
                         ,10094551928
                         ,10968421490
                         ,2727152981
                         ,13971726909
                         ,2165423082
                         ,9867968913
                         ,5296223942
                         ,8484578976
                         ,6984971551
                         ,1584620927
                         ,10481218955
                         ,57841713991
                         ,9687097965
                         ,2465514539
                         ,879376970
                         ,51428849904
                         ,998374989
                         ,8910920998
                         ,10482263954
                         ,596440952
                         ,8151594985
                         ,5725360970
                         ,35335782000102
                         ,8030607261
                         ,93549890982
                         ,9606892905
                         ,3115192967
                         ,5648967993
                         ,5153381927
                         ,75531356900
                         ,7034795983
                         ,3756508900
                         ,8304603900
                         ,221254188
                         ,1580399983
                         ,1801334978
                         ,3565037202
                         ,8161778990
                         ,8162823905
                         ,8235235439
                         ,8470934929
                         ,43443981000154
                         ,12224648960
                         ,16329812462
                         ,26346739000143
                         ,3147877981
                         ,9424585918
                         ,84514876968
                         ,31254772987
                         ,9560763946
                         ,12704302979
                         ,490052002
                         ,7828286988
                         ,44296883000102
                         ,12211041442
                         ,7511524982
                         ,6054289993
                         ,80197658911
                         ,44038778000165
                         ,3885381982
                         ,43104869000199
                         ,9344838925
                         ,5172614990
                         ,3021836046
                         ,4103481986
                         ,862896916
                         ,5373649000171
                         ,44325211000170
                         ,93989873920
                         ,43433561000197
                         ,10248332597
                         ,2150141973
                         ,12167302967
                         ,12863601881
                         ,6352174906
                         ,12595919482
                         ,4313101900
                         ,415101948
                         ,8503546922
                         ,83007857953
                         ,89177789920
                         ,12528425970
                         ,92402070900
                         ,6841669924
                         ,67348319904
                         ,9436352921
                         ,5240564981
                         ,8000056941
                         ,7214214903
                         ,12023581958
                         ,8583394989
                         ,9668708911
                         ,1282251902
                         ,12352182956
                         ,8142929929
                         ,8283909916
                         ,8430791507
                         ,6330799954
                         ,43812877000190
                         ,70033141266
                         ,75362473972
                         ,50809912830
                         ,1917289260
                         ,8996667951
                         ,6315425909
                         ,499987900
                         ,212493000123
                         ,11472119908
                         ,78892247000157
                         ,44414382000175
                         ,8232485930
                         ,13174669936
                         ,14021640924
                         ,35164379953
                         ,71614346968
                         ,72951842953
                         ,2147771970
                         ,8776222993
                         ,9307232954
                         ,44184024000113
                         ,44382553000121
                         ,1310627940
                         ,3168175030
                         ,3823964992
                         ,3849370984
                         ,830034951
                         ,11456376470
                         ,4570724906
                         ,9118106501
                         ,275211258
                         ,6238434988
                         ,9707251913
                         ,7835662981
                         ,5963274982
                         ,6865051661
                         ,79350801515
                         ,8030298960
                         ,4081604975
                         ,7211019921
                         ,8598874990
                         ,4683761947
                         ,7757294932
                         ,6473114963
                         ,5508159967
                         ,7366673935
                         ,35331685811
                         ,5432201925
                         ,44275116000109
                         ,9435204953
                         ,92640060953
                         ,95021990900
                         ,8288841961
                         ,97822019520
                         ,30774209000173
                         ,43767690000111
                         ,13036674950
                         ,7444522952
                         ,14374918000105
                         ,37730337000164
                         ,5703059933
                         ,5075498990
                         ,23520199823
                         ,1245001965
                         ,3451507919
                         ,53037219734
                         ,14653663777
                         ,2219660990
                         ,13381847929
                         ,5797083000105
                         ,10105947962
                         ,84650621968
                         ,77428293987
                         ,87697998068
                         ,40440648904
                         ,71761586904
                         ,5411942918
                         ,8418309911
                         ,11893232905
                         ,13935618964
                         ,42383497843
                         ,54281547991
                         ,71486712991
                         ,12212196938
                         ,9295521994
                         ,8022754943
                         ,13333101963
                         ,12688433857
                         ,10954458982
                         ,10344033970
                         ,64079643934
                         ,6913212992
                         ,11971074950
                         ,2640725297
                         ,8632990918
                         ,11905880995
                         ,39774148000119
                         ,659435110
                         ,708990967
                         ,9524602970
                         ,6369889962
                         ,11792409958
                         ,10720899982
                         ,10063230909
                         ,676157912
                         ,2789863903
                         ,3226061950
                         ,5953467907
                         ,9290874961
                         ,9786947835
                         ,8600781914
                         ,49340238877
                         ,10585418977
                         ,10676181988
                         ,11915144981
                         ,12416997980
                         ,33187281000192
                         ,60985685379
                         ,762037270
                         ,6166674937
                         ,172055229
                         ,5411294908
                         ,55702600053
                         ,6156620990
                         ,3865003206
                         ,934833923
                         ,10872311910
                         ,11880507960
                         ,12468618955
                         ,35498820259
                         ,44364192821
                         ,30073056000137
                         ,5654968599
                         ,45569177949
                         ,72219351904
                         ,13352659966
                         ,6347020920
                         ,10337978980
                         ,4993045000165
                         ,6414224901
                         ,10811957977
                         ,44259887000102
                         ,6999710988
                         ,13069621961
                         ,9621131901
                         ,2105788238
                         ,2945522004
                         ,9491483935
                         ,701224908
                         ,7567326973
                         ,10046606939
                         ,8739610993
                         ,8673979935
                         ,30205638000120
                         ,9110312943
                         ,10971935947
                         ,3973608946
                         ,8228994931
                         ,4579001990
                         ,3530414913
                         ,4977364970
                         ,10360199933
                         ,82143684991
                         ,762341939
                         ,12047586976
                         ,7038616978
                         ,5852618900
                         ,14339895903
                         ,2605799980
                         ,8930607551
                         ,7234952977
                         ,92407226968
                         ,82427631949
                         ,15154384733
                         ,5359947969
                         ,6624844957
                         ,6869496927
                         ,9776459919
                         ,24665614920
                         ,72023180910
                         ,91073235904
                         ,97304930225
                         ,76115518920
                         ,50478834934
                         ,10894105906
                         ,43371751000127
                         ,9661659000163
                         ,80189901900
                         ,30248016000189
                         ,30914825000182
                         ,11291465375
                         ,2958751279
                         ,3356189956
                         ,2557478962
                         ,1018474919
                         ,9591537999
                         ,12815979000135
                         ,2768713910
                         ,43708322000100
                         ,9164895904
                         ,9372301469
                         ,6818115950
                         ,6170425946
                         ,13208882912
                         ,759839905
                         ,42625274000116
                         ,4780389925
                         ,96156635904
                         ,58790179900
                         ,5203360979
                         ,12705194924
                         ,3190688974
                         ,72325453120
                         ,10284701939
                         ,3288912902
                         ,9000369908
                         ,3208807961
                         ,43635019000117
                         ,70829012915
                         ,938923900
                         ,7170625970
                         ,9057127903
                         ,8865899913
                         ,3360824520
                         ,81221126504
                         ,89648340978
                         ,8366049973
                         ,10082358907
                         ,71690361182
                         ,43806795000132
                         ,4726716930
                         ,7091336348
                         ,500883947
                         ,661605965
                         ,1351162950
                         ,1502427273
                         ,5402400288
                         ,11903441900
                         ,24581356920
                         ,13207152902
                         ,71024975207
                         ,77596617115
                         ,10826349994
                         ,11803558490
                         ,14330942909
                         ,4186350990
                         ,12768265918
                         ,15947225956
                         ,44321261000189
                         ,4643540990
                         ,71535949490
                         ,94545227287
                         ,30408010000121
                         ,81595077987
                         ,10832363936
                         ,4726986210
                         ,4268287558
                         ,95576673115
                         ,14111380905
                         ,6960245940
                         ,7715679950
                         ,10317182900
                         ,10155888919
                         ,12565807910
                         ,11287482902
                         ,13039078950
                         ,8483772906
                         ,10264166639
                         ,72003863915
                         ,12769472917
                         ,84282142987
                         ,2750403995
                         ,34540792000109
                         ,43929935000160
                         ,1343725496
                         ,1828284920
                         ,1953462979
                         ,2764640951
                         ,3288424940
                         ,93059981949
                         ,5673050909
                         ,5290202978
                         ,692877916
                         ,71220995479
                         ,11582289964
                         ,15457052915
                         ,2443674932
                         ,3878028946
                         ,8351700550
                         ,5224565960)
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