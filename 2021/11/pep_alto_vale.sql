
DECLARE--257.04
  vr_altera      BOOLEAN := TRUE;
  vr_count       NUMBER;
  vr_texto_carga CLOB;
  vr_texto_carga_aux VARCHAR2(32767);
  vr_dsdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';

  vr_nmarquiv   VARCHAR2(100)  := 'atualizacao_pep_16.csv';
  vr_dscritic   VARCHAR2(4000);

  vr_req      utl_http.req;
  vr_res      utl_http.resp;
  vr_req_url  VARCHAR2(4000) := 'http://api.advicetech.com.br/apipepadvice/ws/AdviceListaPEP.asmx?op=Consulta';
  vr_res_body VARCHAR2(4000);
  vr_req_body VARCHAR2(4000);
  vr_req_body_m VARCHAR2(4000) := '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><ValidationSoapHeader xmlns="http://tempuri.org/"><ChaveSeguranca>ailoslistapep</ChaveSeguranca><ChaveLicenca>HFKR/fN+FGD2TL9BJjl+GZ8cbvD+38Cop88BXFyeCOajlhe73Z+H/zbj7WnkYnobb5eTbWa2deXNtOGzMLnjBrX1AKVTACPNIEZxevUk3Yr3BndhEmvfHK28QObizt+H</ChaveLicenca></ValidationSoapHeader></soap:Header><soap:Body><Consulta xmlns="http://tempuri.org/"><CPF_CNPJ>{nrcpfcgc}</CPF_CNPJ><Nome>{nmextttl}</Nome></Consulta></soap:Body></soap:Envelope>';

  CURSOR cr_crapass IS
    SELECT crapttl.nrcpfcgc
          ,crapttl.nmextttl
      FROM crapass crapass
          ,crapttl crapttl
     WHERE crapass.nrdconta = crapttl.nrdconta
       AND crapass.cdcooper = crapttl.cdcooper
       AND crapass.dtdemiss IS NULL
       AND crapass.cdcooper = 16
       AND crapass.nrcpfcgc in (
        2339459974, 1001185935, 10070146950, 10079059996, 10111717914, 10115264922, 10144548917, 10164778993, 10187351945, 10205890946, 10273489984, 10305582992, 10345645952, 10525671935, 
        10558009999, 10580557000100, 10607178000159, 10607178000159, 10607178000159, 10645944920, 10657852000100, 10727433000105, 10770315992, 10855623000108, 10858992000146, 10873211901, 
        10972568980, 11033872946, 11212204956, 11214706967, 11214706967, 11274659965, 11279609974, 11292576901, 1134304005, 11486185000102, 11486185000102, 11584970910, 11584970910, 1199057959, 
        12004181000103, 12004181000375, 12058353935, 1210487993, 12134023953, 1215339992, 12249262934, 12254875957, 12399814000120, 12482049000107, 12626705000106, 12629877922, 12669843808, 
        13008424000144, 13085582959, 13147154000152, 13226987000109, 13329257903, 13548733948, 13598727950, 13692134000162, 13822843000115, 13866640000120, 14025492000184, 14133116000103, 
        1436876974, 1438894945, 14436739000155, 14436739000155, 1460537963, 1461202990, 14637081000140, 1474112030, 1509251000169, 1509251000169, 1511067977, 1521402981, 1521414998, 15234383000130, 
        1527296903, 1527310914, 15388107949, 1540388000186, 1602644993, 1612588913, 1624779000189, 1624779000189, 1638072990, 16730646000164, 16893280963, 1693517930, 1698191910, 1698191910, 
        17004323000156, 1717481000113, 17279918000114, 1730107923, 1743916922, 1743916922, 17569841000117, 1774384957, 1774950901, 1783061936, 1783791900, 1785124943, 17881722000103, 17902304972, 
        18021195000111, 18091954972, 18405404000120, 18604378000160, 18655302000163, 1887219919, 18920045000140, 19052826722, 19132987000126, 1914476921, 19408404904, 1951034406, 1953729991, 
        1953729991, 1994552956, 1994552956, 20416966000111, 2057038955, 20611210000123, 2061240909, 20818962000160, 20850033000138, 20945096000178, 2100672924, 2119763933, 2142568980, 21468721000109, 
        21498968000160, 2151267000105, 2151281000109, 21639113000101, 21699542953, 2195347996, 2227049936, 2227844906, 22350281000145, 22533661000115, 22620809000159, 2272012990, 22810272000190, 
        2282481917, 22869698000119, 22977601000191, 22989394000195, 23315970904, 2332273930, 2339459974, 2348932903, 2353373909, 23691899000131, 23846176000164, 23846176000164, 24152230000134, 
        2431579913, 2458757944, 2463766948, 2466849925, 24830205000162, 2488363901, 24921971900, 24924610925, 24925284991, 24933163000195, 2503474900, 25390305000188, 2541079907, 2570342939, 
        2585568000147, 2598924000167, 26153876000161, 26153876000161, 26207785000161, 26406222000100, 2656222000192, 2656222000192, 27350810000124, 27350810000124, 2739261950, 27527802000100, 
        2780835958, 27890769000189, 2790160937, 28003221000132, 2819272940, 2819752993, 2820678920, 28381573000121, 2840162091, 2840162091, 2846522960, 28520657000107, 28537106968, 28551725000197, 
        28706136000130, 28916380000128, 2896957910, 2898930970, 29074142915, 29224357000135, 29244281000100, 29271509900, 29284465915, 29290880953, 29296003000104, 29299187991, 29364120000150, 
        29406404915, 29407818934, 29408520904, 29439978000136, 2944481959, 2944849905, 2947678940, 2947678940, 2948251931, 2948457980, 2960509978, 29656864000148, 29660574000178, 29715037000188, 
        29715037000188, 2995194906, 2998019935, 3006942000175, 30473461000142, 3054931919, 30768197000174, 30769017000179, 30912402000123, 31023452987, 31034276972, 31037216920, 31098762991, 
        31111210000180, 31116434920, 31117368904, 3125876940, 3175869980, 3176394985, 31783056886, 3189585000128, 3192982000159, 3209753989, 3209753989, 32139143000175, 3222166000140, 3223632921, 
        3238345907, 3238345907, 3258877998, 3282755902, 3301106919, 3302661959, 33030267000180, 3303841985, 3309669955, 3327023913, 33361044000104, 33511611000153, 3351888937, 3361245974, 
        33673301000135, 336926960, 33853503000169, 33995969000107, 3404191994, 3404333969, 340720980, 34078573000150, 34146384000177, 3424347990, 34366274000110, 3443404499, 34525682000178, 
        34525682000178, 3484799994, 348731981, 3513161913, 351597905, 351597905, 35230177934, 35309282000198, 3531122916, 3580221930, 35929508000153, 36369325000193, 36436827000190, 3652365000199, 
        3660708000167, 3664707958, 3679982976, 3683382902, 368845966, 37023685000100, 37040843000121, 371785987, 371785987, 37219800000108, 37229925000119, 372621902, 37469199000101, 37530811000104, 
        37539647000104, 37540122900, 37557289900, 3758809924, 3780100000176, 3783297907, 3786139954, 3787677984, 37918206991, 37935291934, 37935291934, 37939564900, 3799851950, 3799851950, 38155656934, 
        38273756904, 38277174934, 38326370959, 38548887915, 38548887915, 3855509956, 3862642950, 3863060954, 3895079979, 3895079979, 3921121914, 3922914950, 3927185000172, 3929861917, 3937211918, 
        3937211918, 394143965, 39431699000180, 3967716961, 39835357000125, 3986796908, 39967476915, 39972291987, 40008185972, 4004465966, 4008689974, 4016644909, 4028592941, 4031692919, 40468875000137, 
        4068707995, 4088622979, 4088622979, 4088687914, 4093757000128, 4095534923, 40973598000110, 4101087903, 4109526990, 41223177000134, 4124834918, 4127952997, 4144755932, 4156288900, 41628330953, 
        41676836000198, 4171325900, 4179614995, 41806506904, 41861477953, 41935845934, 4201648982, 42070856968, 42070856968, 42195624949, 42264050000126, 42579998000170, 4265509940, 4272165917, 428021999, 
        42879761000105, 42887328000111, 4289122906, 43018734904, 4308801974, 4352962996, 4369692000109, 4396768940, 4397212961, 4398223940, 4400126943, 4427143000135, 4437050975, 44399960949, 4449732901, 
        44661371968, 44661762991, 44673787900, 4472710000175, 4487491908, 4491791929, 4494165930, 4494633976, 44996772972, 4513698900, 4519470960, 4534892900, 45392692915, 4600250907, 4632057908, 46406603915, 
        46823778091, 46945458920, 4698256000175, 4718750903, 4758695911, 4778526961, 47835729920, 47835729920, 4787275933, 4791024907, 47958065949, 48066516991, 4813576966, 4815927928, 4826537018, 48279706968, 
        4844161970, 4845770938, 4852405999, 48658260925, 4870967979, 4877682996, 48928127904, 4897774900, 4912956937, 4925340000184, 49486705968, 49516000991, 4963120909, 4975086999, 49839772953, 49839780972, 
        4997181000123, 503059994, 5032192000131, 5042342000198, 5042500000100, 5042500000100, 5042500000100, 5043062940, 5044810967, 505993996, 5068295965, 5068295965, 5068390950, 5080357916, 5097293983, 
        5100647957, 5109208000167, 5117516990, 51209110997, 51209110997, 5140614995, 514150971, 5162189995, 516223941, 51716615968, 5173492996, 5179790980, 518291936, 51831546949, 5203576980, 52144763968, 
        5221808927, 5253452000107, 525491945, 52792730900, 5286057985, 5286169945, 5294547937, 5306190910, 5319868960, 5324096989, 53337565972, 5343282962, 5343282962, 53463072904, 53463226987, 5352043967, 
        53834062987, 53879260915, 5390169930, 5393038950, 542454947, 54286913953, 54859212991, 54859557972, 54868149920, 54931908934, 550588922, 5531120000139, 5554422926, 5588811000179, 5601818924, 
        5606037971, 56215134953, 562362000176, 562668985, 56419740991, 5649989907, 56940394915, 5701553981, 5725967905, 5729518000184, 5733252944, 57343284991, 5736903911, 57571481953, 57575045953, 
        57575541934, 5784505939, 57960330930, 58191330997, 58191747987, 585796998, 59003723915, 5906924000175, 591565978, 5923458900, 5936100910, 59454962949, 59529814968, 59529814968, 596575963, 5967335935, 
        5968786990, 5985194914, 601335970, 6019775992, 6020513980, 60335823904, 60464596300, 6059576907, 6059576907, 6062923906, 606902910, 6071563178, 6085633904, 6095461000252, 6096049966, 6105366990, 
        6111212982, 611829908, 611835983, 61269425900, 6130741901, 61439770972, 61814857915, 619350938, 6204534947, 6223795939, 6224585903, 6246154999, 62559303949, 62564293972, 63081849934, 631622969, 
        63269988915, 6328680902, 6333969907, 6349605985, 6349605985, 6356091932, 6361097986, 6395486950, 6406922905, 6425184914, 64726665987, 64739074915, 6483001886, 6483753900, 6506121912, 6513928966, 
        65186451991, 65269020904, 65269020904, 6542811907, 655610901, 65566556949, 65700694972, 6577552908, 6592330961, 65947215934, 6598603927, 6602224930, 66047412904, 6624423935, 66484103968, 6675981978, 
        6684710930, 669796921, 67079830915, 671930990, 674073908, 67411746991, 67826407915, 6818639941, 68574916900, 68575092987, 6858189939, 6865081900, 68656289934, 689616937, 69022097900, 6904521953, 
        69052301972, 69055998915, 6908692906, 6911401976, 69240396934, 69292809920, 69309396920, 69309396920, 69353476968, 69356998949, 69368945934, 6965097000153, 6973198902, 6973198902, 6995915976, 
        70172218934, 70309116953, 70334231280, 70548145920, 7071387000116, 70902795295, 71049851900, 7107851942, 7112307902, 71255133287, 71438211953, 71438211953, 71462317987, 71474501915, 71552669904, 
        71553681991, 71577548949, 716482916, 71681965968, 7187876920, 720553911, 7211701960, 72227680920, 72230185934, 72236904000121, 7239746917, 72844620949, 7310377907, 7320969955, 73277070930, 73298018953, 
        73306458000147, 7336814921, 73539279920, 7354587907, 73733024915, 73792969904, 738489999, 7390133945, 7392210947, 73974870920, 7402598900, 74162527920, 74166840991, 74327127949, 7440566912, 744326990, 
        7448227939, 74674374987, 75154510925, 7525390000162, 7529868993, 753027992, 75302845920, 75370140944, 75403315934, 7573434000120, 7573434000120, 7575018930, 75862961000538, 76278646900, 76328660944, 
        7637011909, 76578426000270, 76700712904, 76707849972, 76751074972, 7686562905, 7686562905, 76963195900, 7705881000195, 77208595968, 773061983, 7731871975, 77402774953, 77485300920, 77507703991, 
        7759352000174, 7761063923, 77756215915, 77781813987, 77855013000177, 7811592967, 7829700958, 78960762920, 7910011997, 79372959000108, 79372959000108, 7963000973, 79631207900, 79631207900, 7964830945, 
        7966667000192, 797577408, 80016090900, 80070659000153, 80096175000183, 8010156930, 80124789943, 8013308901, 80144538000109, 80327966068, 80458771000166, 8048466937, 8060984900, 8061040905, 8061692902, 
        80734007000176, 81087780934, 8114015969, 81176562991, 811808963, 81461933900, 8150070940, 81518839000118, 8167251950, 81722036915, 81722702915, 81858558972, 81883579953, 8190166913, 8190758926, 
        8195191975, 82054096920, 82103037000100, 82131814000120, 82161631934, 82177874000183, 821894986, 82272549934, 82440816949, 82470120063, 8253550000124, 8253550000124, 82686971991, 82702594620, 
        82759928934, 82760446972, 82796491900, 8291495971, 8291495971, 82968074000180, 82968074000180, 82968074000180, 8298151984, 83073486000115, 8314340901, 83165177953, 83341668934, 83345914972, 
        83345914972, 83363840900, 8337515902, 83381481991, 8342095940, 83446079904, 83446419934, 83499541000133, 8368177960, 83743723972, 83783340000163, 83807047972, 83807624953, 83808566949, 83808779934, 
        83809066915, 8385594922, 840318910, 84148436000112, 84148436000112, 8419940992, 8421506927, 8448246900, 84566868915, 84612274920, 8476875975, 84859415949, 85111854000106, 85111854000106, 85120426000131, 
        8513461970, 8546646961, 8578396910, 85785988000102, 85788289000884, 85788941000194, 85788941000194, 85789782000142, 8582294980, 8602807996, 86298755268, 86322732000113, 86324860000104, 8651786000119, 
        8651786000119, 86731494000108, 86731494000108, 86842862949, 86847163968, 86867857949, 8728183908, 8733125970, 8794309906, 8799411970, 881641952, 8826198969, 883535912, 8838711909, 885810988, 8858565975, 
        8863101990, 8910644940, 89148428949, 89168380968, 892144980, 8925175908, 89525051900, 8954391907, 89595424900, 89602625953, 89603060968, 89646150934, 89779932968, 89805810925, 89814207934, 89820118972, 
        89820410959, 9012530903, 9012530903, 9013066000190, 90160622972, 90161491987, 9023308964, 90260279900, 90273982915, 90297024949, 90310594987, 90310756987, 9046190951, 90508483972, 9062009000100, 
        9068353000106, 90729161900, 90779517920, 91070643904, 9113078933, 91416175172, 91577276949, 91577586972, 91577667972, 91577667972, 91701040000, 9185871000100, 9188397939, 92065562900, 92067034987, 
        923533982, 9268599000113, 92764452934, 92865682900, 92872492968, 92872573968, 9295229908, 9299782938, 934466912, 93580088904, 93673302949, 93674180944, 9383872000150, 9384129909, 93849494004, 9435911986, 
        94679355972, 94679355972, 94679983949, 94679983949, 94719284949, 94719942920, 94722781915, 94861315972, 94862036953, 95061800915, 95061800915, 95064842953, 95070168991, 9542203900, 9567301913, 9585450909, 
        9593912908, 9593912908, 9600919470, 9652566934, 965280950, 965280950, 9661950946, 9683460909, 96959835968, 983727937, 98374370904, 9845278930, 9859139911, 9860497940, 9860497940, 98607596934, 98720589972, 
        98760327987, 9918403640, 9933169998, 9955730854, 9997184955, 10906014921, 11486185000102, 12249262934, 12249262934, 12250201900, 12522847000115, 14703223000120, 15279340049, 16569609000116, 20213174000140, 
        2038230951, 22163313000101, 24531312000190, 24771600953, 32056546000150, 3354549920, 33958233000150, 36864749991, 4449832957, 4581394910, 53358252949, 57571562953, 5875571926, 64838315953, 66485096949, 
        71732810915, 760465916, 81518839000118, 84148436000112, 8668583930, 8728105000173, 89528670920, 9002196962, 95144323987)
     GROUP BY crapttl.nrcpfcgc
             ,crapttl.nmextttl;

  CURSOR cr_crapttl(pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
    SELECT crapttl.cdcooper
          ,crapttl.nrdconta
          ,crapttl.idseqttl
      FROM crapttl crapttl
     WHERE crapttl.nrcpfcgc = pr_nrcpfcgc;

  TYPE typ_pep IS RECORD(
     vr_flgpep       BOOLEAN
    ,vr_cpfpesquisa  tbcadast_politico_exposto.nrcpf_politico%TYPE
    ,vr_nomepesquisa tbcadast_politico_exposto.nmpolitico%TYPE
    ,vr_idpessoa     tbcadast_pessoa.idpessoa%TYPE
    ,vr_idpessoapep  tbcadast_pessoa.idpessoa%TYPE
    ,vr_cpfpep       tbcadast_politico_exposto.nrcpf_politico%TYPE
    ,vr_nomepep      tbcadast_politico_exposto.nmpolitico%TYPE
    ,vr_tpexposto    tbcadast_politico_exposto.tpexposto%TYPE
    ,vr_dsocupacao   VARCHAR2(4000)
    ,vr_ocupacao     gncdocp.dsdocupa%TYPE
    ,vr_cdocupacao   gncdocp.cdocupa%TYPE --gncdocp
    ,vr_dsrelacmnto  VARCHAR2(4000) --CONJUGE,1,PAI/MAE,2,FILHO(A),3,COMPANHEIRO(A),4,OUTROS,5,COLABORADOR(A),6,ENTEADO(A),7,ASSESSOR (A),8,PARENTE,9,REPRESENTANTE PEP,10,PROCURADOR PEP,11,SOCIO (A) PEP,12
    ,vr_relacmnto    VARCHAR2(4000) --craptab WHERE cdacesso = 'VINCULOTTL'
    ,vr_cdrelacmnto  NUMBER(2)
    ,vr_dsinicio     VARCHAR2(100)
    ,vr_dtinicio     tbcadast_politico_exposto.dttermino%TYPE
    ,vr_dstermino    VARCHAR2(100)
    ,vr_dttermino    tbcadast_politico_exposto.dttermino%TYPE
    ,vr_log          VARCHAR(4000));
  vr_pep typ_pep;

BEGIN
  dbms_lob.createtemporary(vr_texto_carga, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_texto_carga,dbms_lob.lob_readwrite);  

  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,'CPF Pesquisado;' ||
                                                            'Nome Pesquisado;' ||
                                                            'PEP;' ||
                                                            'CPF PEP;' ||
                                                            'Nome PEP;' ||
                                                            'Tipo Exposto;' ||
                                                            'Ocupacao;' ||
                                                            'Cod Ocupacao;' ||
                                                            'Dsc Ocupacao;' ||
                                                            'Relacionamento;' ||
                                                            'Cod Relacionamento;' ||
                                                            'Dsc Relacionamento;' ||
                                                            'Data Inicio;' ||
                                                            'Data Termino;' ||
                                                            'Log Execucao' || CHR(10));
  FOR rw_crapass IN cr_crapass LOOP
    vr_req := utl_http.begin_request(vr_req_url, 'POST', ' HTTP/1.1');
    utl_http.set_header(vr_req, 'Content-Type', 'text/xml');
    
    vr_req_body := REPLACE(REPLACE(vr_req_body_m, '{nrcpfcgc}', rw_crapass.nrcpfcgc),'{nmextttl}',rw_crapass.nmextttl);
    
    utl_http.set_header(vr_req, 'Content-Length', length(vr_req_body));
    utl_http.write_text(vr_req, vr_req_body);
    vr_res := utl_http.get_response(vr_req);
  
    BEGIN
      utl_http.read_line(vr_res, vr_res_body);
      
      vr_pep.vr_flgpep       := FALSE;
      vr_pep.vr_cpfpesquisa  := NULL;
      vr_pep.vr_nomepesquisa := NULL;
      vr_pep.vr_idpessoa     := NULL;
      vr_pep.vr_idpessoapep  := NULL;
      vr_pep.vr_cpfpep       := NULL;
      vr_pep.vr_nomepep      := NULL;
      vr_pep.vr_tpexposto    := NULL;
      vr_pep.vr_dsocupacao   := NULL;
      vr_pep.vr_ocupacao     := NULL;
      vr_pep.vr_cdocupacao   := NULL;
      vr_pep.vr_dsrelacmnto  := NULL;
      vr_pep.vr_relacmnto    := NULL;
      vr_pep.vr_cdrelacmnto  := NULL;
      vr_pep.vr_dsinicio     := NULL;
      vr_pep.vr_dtinicio     := NULL;
      vr_pep.vr_dstermino    := NULL;
      vr_pep.vr_dttermino    := NULL;
      vr_pep.vr_log          := NULL;
      
      IF instr(vr_res_body, '<DATA>') > 0 THEN
        vr_pep.vr_flgpep       := TRUE;
        vr_pep.vr_cpfpesquisa  := to_number(substr(vr_res_body,instr(vr_res_body, '<CPF_CNPJ_STR>') +length('<CPF_CNPJ_STR>'),instr(vr_res_body,'</CPF_CNPJ_STR>') -(instr(vr_res_body,'<CPF_CNPJ_STR>') +length('<CPF_CNPJ_STR>'))));
        vr_pep.vr_nomepesquisa := substr(vr_res_body,instr(vr_res_body, '<NM_PESSOA>') +length('<NM_PESSOA>'),instr(vr_res_body,'</NM_PESSOA>') -(instr(vr_res_body,'<NM_PESSOA>') +length('<NM_PESSOA>')));
        vr_pep.vr_cpfpep       := to_number(substr(vr_res_body,instr(vr_res_body, '<CPF_PEP>') +length('<CPF_PEP>'),instr(vr_res_body,'</CPF_PEP>') -(instr(vr_res_body,'<CPF_PEP>') +length('<CPF_PEP>'))));
        vr_pep.vr_nomepep      := TRIM(upper(substr(vr_res_body,instr(vr_res_body, '<PEP>') +length('<PEP>'),instr(vr_res_body,'</PEP>') -(instr(vr_res_body,'<PEP>') +length('<PEP>')))));
        vr_pep.vr_tpexposto    := CASE WHEN vr_pep.vr_cpfpesquisa = vr_pep.vr_cpfpep THEN 1 ELSE 2 END;
        
        vr_pep.vr_dsocupacao   := TRIM(upper(substr(vr_res_body,instr(vr_res_body, '<DS_CARGO>') +length('<DS_CARGO>'),instr(vr_res_body,'</DS_CARGO>') -(instr(vr_res_body,'<DS_CARGO>') +length('<DS_CARGO>')))));
        vr_pep.vr_dsrelacmnto  := TRIM(upper(substr(vr_res_body,instr(vr_res_body, '<DS_RELACIONAMENTO>') +length('<DS_RELACIONAMENTO>'),instr(vr_res_body,'</DS_RELACIONAMENTO>') -(instr(vr_res_body,'<DS_RELACIONAMENTO>') +length('<DS_RELACIONAMENTO>')))));
        
        vr_pep.vr_dsinicio     := substr(vr_res_body,instr(vr_res_body, '<DT_INICIO>') +length('<DT_INICIO>'),instr(vr_res_body,'</DT_INICIO>') -(instr(vr_res_body,'<DT_INICIO>') +length('<DT_INICIO>')));
        vr_pep.vr_dsinicio     := substr(vr_pep.vr_dsinicio,0,instr(vr_pep.vr_dsinicio,'T')-1);
        vr_pep.vr_dstermino    := substr(vr_res_body,instr(vr_res_body, '<DT_FIM>') +length('<DT_FIM>'),instr(vr_res_body,'</DT_FIM>') -(instr(vr_res_body,'<DT_FIM>') +length('<DT_FIM>')));
        vr_pep.vr_dstermino    := substr(vr_pep.vr_dstermino,0,instr(vr_pep.vr_dstermino,'T')-1);
          
        vr_pep.vr_dtinicio     := to_date(vr_pep.vr_dsinicio, 'yyyy-mm-dd');
        vr_pep.vr_dttermino    := to_date(vr_pep.vr_dstermino, 'yyyy-mm-dd');
        
        BEGIN
          IF instr(vr_pep.vr_dsocupacao, 'CARGO:') > 0 THEN
            vr_pep.vr_ocupacao := TRIM(substr(vr_pep.vr_dsocupacao,instr(vr_pep.vr_dsocupacao, 'CARGO:') +length('CARGO:'), instr(substr(vr_pep.vr_dsocupacao,instr(vr_pep.vr_dsocupacao, 'CARGO:') +length('CARGO:')),',')-1));
          ELSIF instr(vr_pep.vr_dsocupacao, '/') > 0 THEN
            vr_pep.vr_ocupacao := TRIM(substr(vr_pep.vr_dsocupacao,0,instr(vr_pep.vr_dsocupacao, '/')-1));
          END IF;  
        
          CASE vr_pep.vr_ocupacao
            WHEN 'VICE-PREFEITO' THEN vr_pep.vr_cdocupacao := 312;
            WHEN 'PREFEITO' THEN vr_pep.vr_cdocupacao := 311;
            ELSE
              SELECT cdocupa
                INTO vr_pep.vr_cdocupacao
                FROM gncdocp
               WHERE rownum = 1 AND dsdocupa LIKE '%' || TRIM(vr_pep.vr_ocupacao) || '%';
           END CASE;
        EXCEPTION
          WHEN OTHERS THEN
            vr_pep.vr_cdocupacao := NULL;
        END;
        
        BEGIN
          IF instr(vr_pep.vr_dsrelacmnto, ' CONJUGE ') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' CÔNJUGE/') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' EX-CÔNJUGE') > 0 THEN
            vr_pep.vr_cdrelacmnto := 1;
            vr_pep.vr_relacmnto   := 'Conjuge';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'PAI/MÃE') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' PAI ') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' MÃE ') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' MAE ') > 0 THEN
            vr_pep.vr_cdrelacmnto := 2;
            vr_pep.vr_relacmnto   := 'Pai/Mae';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'FILHA(O)') > 0 OR instr(vr_pep.vr_dsrelacmnto, 'FILHO(A)') > 0 THEN
            vr_pep.vr_cdrelacmnto := 3;
            vr_pep.vr_relacmnto   := 'Filha(o)';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'TIO/TIA') > 0 OR instr(vr_pep.vr_dsrelacmnto, 'TIA/TIO') > 0 OR instr(vr_pep.vr_dsrelacmnto, 'TIO(A)') > 0 OR instr(vr_pep.vr_dsrelacmnto, 'TIA(O)') > 0 THEN
            vr_pep.vr_cdrelacmnto := 9;
            vr_pep.vr_relacmnto   := 'Tio/tia - Parente';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'PRIMO(A)') > 0 OR instr(vr_pep.vr_dsrelacmnto, 'PRIMA(O)') > 0 THEN
            vr_pep.vr_cdrelacmnto := 9;
            vr_pep.vr_relacmnto   := 'Primo(a) - Parente';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'ENTEADA(O)') > 0 OR instr(vr_pep.vr_dsrelacmnto, 'ENTEADO(A)') > 0 THEN
            vr_pep.vr_cdrelacmnto := 7;
            vr_pep.vr_relacmnto   := 'Enteada(o) - Parente';
          ELSIF instr(vr_pep.vr_dsrelacmnto, ' SÓCIO ') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' SÓCIA ') > 0 THEN
            vr_pep.vr_cdrelacmnto := 12;
            vr_pep.vr_relacmnto   := 'Sócio(a)';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'IRMÃ(O)') > 0 THEN
            vr_pep.vr_cdrelacmnto := 9;
            vr_pep.vr_relacmnto   := 'IRMA(O) - Parente';
          ELSIF instr(vr_pep.vr_dsrelacmnto, 'SOBRINHO(A)') > 0 THEN
            vr_pep.vr_cdrelacmnto := 9;
            vr_pep.vr_relacmnto   := 'SOBRINHO(A) - Parente';
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            vr_pep.vr_cdocupacao := NULL;
        END;
                                                    
        IF instr(vr_pep.vr_dsocupacao, 'SUPLENTE') > 0 THEN
          vr_pep.vr_log := vr_pep.vr_log || 'Suplente, nao altera dados|';
          CONTINUE;
        END IF;
        
        BEGIN
          SELECT idpessoa
            INTO vr_pep.vr_idpessoa
            FROM tbcadast_pessoa
           WHERE nrcpfcgc = vr_pep.vr_cpfpesquisa;
        EXCEPTION
           WHEN OTHERS THEN
             vr_pep.vr_idpessoa := NULL;
        END;
        
        BEGIN
          SELECT idpessoa
            INTO vr_pep.vr_idpessoapep
            FROM tbcadast_pessoa
           WHERE nrcpfcgc = vr_pep.vr_cpfpep;
        EXCEPTION
           WHEN OTHERS THEN
             vr_pep.vr_idpessoapep := NULL;
             vr_pep.vr_log := vr_pep.vr_log || 'Nao foi encontrado esse cpf do pep na tbcadast_pessoa, nao incluira o idpessoa_politico|';
        END;
          
        IF vr_pep.vr_idpessoa IS NOT NULL THEN
          SELECT COUNT(1)
            INTO vr_count
            FROM tbcadast_pessoa_polexp
           WHERE idpessoa = vr_pep.vr_idpessoa;
              
          IF vr_count = 0 THEN
            vr_pep.vr_log := vr_pep.vr_log || 'Incluindo tbcadast_pessoa_polexp:' || vr_pep.vr_idpessoa || '|';
            IF vr_altera THEN
              INSERT INTO tbcadast_pessoa_polexp
                (idpessoa,tpexposto,dtinicio,dttermino,cdocupacao,tprelacao_polexp,idpessoa_politico)
              VALUES
                (vr_pep.vr_idpessoa,vr_pep.vr_tpexposto,vr_pep.vr_dtinicio,vr_pep.vr_dttermino,vr_pep.vr_cdocupacao,vr_pep.vr_cdrelacmnto,vr_pep.vr_idpessoapep);
            END IF;
          ELSE 
            vr_pep.vr_log := vr_pep.vr_log || 'Ja existe tbcadast_pessoa_polexp, nao altera dados|';
          END IF;
        ELSE
          vr_pep.vr_log := vr_pep.vr_log || 'Nao foi encontrado esse cpf cadastrado na tbcadast_pessoa, nao altera tbcadast_pessoa_polexp|';
        END IF;
        
        FOR rw_crapttl IN cr_crapttl(vr_pep.vr_cpfpesquisa) LOOP
          vr_pep.vr_log := vr_pep.vr_log || 'Alterando crapttl:' || rw_crapttl.idseqttl || '/' || rw_crapttl.cdcooper || '/' || rw_crapttl.nrdconta || '|';
          IF vr_altera THEN
            UPDATE crapttl
               SET inpolexp = 1
             WHERE idseqttl = rw_crapttl.idseqttl
               AND cdcooper = rw_crapttl.cdcooper
               AND nrdconta = rw_crapttl.nrdconta;
          END IF;
            
          SELECT COUNT(1)
            INTO vr_count
            FROM tbcadast_politico_exposto
           WHERE idseqttl = rw_crapttl.idseqttl
             AND cdcooper = rw_crapttl.cdcooper
             AND nrdconta = rw_crapttl.nrdconta;
            
          IF vr_count = 0 THEN
            vr_pep.vr_log := vr_pep.vr_log || 'Incluindo tbcadast_politico_exposto:' || rw_crapttl.idseqttl || '/' || rw_crapttl.cdcooper || '/' || rw_crapttl.nrdconta || '|';
            IF vr_altera THEN
              INSERT INTO tbcadast_politico_exposto
                (cdcooper,nrdconta,idseqttl,tpexposto,dtinicio,dttermino
                ,nmpolitico,cdocupacao,cdrelacionamento,nrcpf_politico)
              VALUES
                (rw_crapttl.cdcooper,rw_crapttl.nrdconta,rw_crapttl.idseqttl,vr_pep.vr_tpexposto,vr_pep.vr_dtinicio,vr_pep.vr_dttermino
                ,vr_pep.vr_nomepep,vr_pep.vr_cdocupacao,vr_pep.vr_cdrelacmnto,vr_pep.vr_cpfpep);
            END IF;
          ELSE 
            vr_pep.vr_log := vr_pep.vr_log || 'Ja existe tbcadast_politico_exposto, nao altera dados|';
          END IF;
        END LOOP;
        
        gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,rw_crapass.nrcpfcgc || ';' ||
                                                                  rw_crapass.nmextttl || ';' ||
                                                                  CASE WHEN vr_pep.vr_flgpep THEN 'Sim' ELSE 'Nao' END || ';' ||
                                                                  vr_pep.vr_cpfpep || ';' ||
                                                                  vr_pep.vr_nomepep || ';' ||
                                                                  vr_pep.vr_tpexposto || ';' ||
                                                                  vr_pep.vr_dsocupacao || ';' ||
                                                                  vr_pep.vr_cdocupacao || ';' ||
                                                                  vr_pep.vr_ocupacao || ';' ||
                                                                  vr_pep.vr_dsrelacmnto || ';' ||
                                                                  vr_pep.vr_cdrelacmnto || ';' ||
                                                                  vr_pep.vr_relacmnto || ';' ||
                                                                  vr_pep.vr_dtinicio || ';' ||
                                                                  vr_pep.vr_dttermino || ';' ||
                                                                  vr_pep.vr_log || CHR(10));
      ELSE
        gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,rw_crapass.nrcpfcgc || ';' || rw_crapass.nmextttl || ';' || CASE WHEN vr_pep.vr_flgpep THEN 'Sim' ELSE 'Nao' END || ';;;;;;;;;;;;;' || CHR(10));
      END IF;
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        utl_http.end_response(vr_res);
      WHEN utl_http.too_many_requests THEN
        utl_http.end_response(vr_res);
    END;
    utl_http.end_response(vr_res);
  END LOOP;
  gene0002.pc_escreve_xml(vr_texto_carga,vr_texto_carga_aux,'',true);

  -- Gerar o arquivo na pasta converte
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_texto_carga
                               ,pr_caminho  => vr_dsdireto
                               ,pr_arquivo  => vr_nmarquiv
                               ,pr_des_erro => vr_dscritic);

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_texto_carga);
  dbms_lob.freetemporary(vr_texto_carga);
  commit;
END;
