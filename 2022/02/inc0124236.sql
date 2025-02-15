declare 

  vr_cdcritic      INTEGER:= 0;
  vr_dscritic      VARCHAR2(4000);
  vr_exc_erro      EXCEPTION;
  
  vr_nmarqrbk       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(400); 
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  
  vr_contrato GENE0002.typ_split;
  vr_dadosctr GENE0002.typ_split;
  
  vr_lstcontr_1 VARCHAR(4000) := '16;110736;118359|16;122440;123279|6;151556;240117|16;158615;117619|6;223026;240188|16;338214;115634|16;379875;124760|16;411680;117571|16;435520;121100|16;462578;121616|16;515531;121553|2;761095;274894|2;845973;287386|16;2409046;124600|1;2978709;1283802|1;3815773;828630|1;6800980;1347287|1;6800980;1353307|1;8008787;1374453|1;8172722;877871|1;8172722;1703791|1;8813973;3161684|9;313483;44914|2;875589;288532';

  vr_lstcontr_2 VARCHAR(4000) := '2;379000;214417|1;4301811;405982|1;8673519;1090254|8;248;6257|6;671;231949|6;1716;231303|8;4588;7812|5;5304;23330|8;7986;7025|8;12890;6831|8;13102;7360|6;14117;230468|6;14117;230473|6;14397;233255|8;15270;6869|6;23906;230673|6;23906;232227|6;25380;229164|6;26476;230147|8;29947;7723|6;30210;229629|8;35084;7277|6;35998;228910|6;41858;232456|8;42420;7811|8;43214;6341|8;43214;7105|8;45713;7322|6;54097;232046|6;58408;233854|6;69086;233914|6;69647;229514|6;75825;233054|6;84590;236424|6;87696;230926|5;87734;29513|6;90190;229404|5;94102;28153|6;111880;228911|5;115568;19163|6;115673;235015|6;117935;235118|6;123544;231016|6;125059;231005|6;129437;229032|5;130400;20349|5;130400;20351|6;131776;233841|6;138223;229803|6;138738;235944|5;140430;21757|6;140848;229612|5;140961;20419|5;142107;29841|5;142522;19246|6;142700;229440|6;142700;229441|6;155942;231649|6;157406;233278|6;159549;229480|6;165077;230771|5;169323;20479|5;171620;19505|5;172260;29564|6;172294;235662|6;172359;230658|5;175170;27961|5;175587;19972|5;180602;20186|5;180602;20187|5;180912;26876|5;181900;19921|5;183164;20180|5;184535;19384|5;187445;26022|5;189588;19844|5;191515;19342|5;203580;19820|7;229016;35042|5;229547;19983|5;230588;19515|5;232408;19407|5;309222;46267|6;500976;228634|6;501379;232779|6;503436;230496|16;819042;246673|1;2041600;1461307|1;2114747;2723356|1;2495422;1171086|1;3220990;2960872|1;6445934;2603202|1;6567975;3238385|1;6840973;3541250|1;9330488;1427938|1;9754229;1682966|1;10316868;4247756|1;10817964;2807761|1;11104430;3261673|1;11104430;4007723|1;11968818;3156052|1;11968818;3158691|1;12396591;3590537|1;12431346;4012801|1;12677264;4042197|13;22810;39547|1;9091;2226479|1;9091;2249014|1;9091;2268697|8;10472;6899|6;10480;231078|8;11843;7704|8;28193;7099|6;34568;236176|8;40339;6901|6;47988;230853|5;70190;26951|5;72591;22861|5;81787;28762|6;82104;231118|6;92924;229386|5;97454;26186|6;101818;229097|5;115223;28840|6;118184;228705|5;122106;21171|6;123650;228952|6;129020;230564|6;135704;228767|6;136476;229006|6;136476;230115|6;137502;231947|6;138380;229286|5;142964;29781|6;153699;230184|5;155748;22217|5;192856;26200|5;199907;22583|5;216470;26101|5;225940;29473|7;226971;38192|6;500658;228636|9;504300;19100665|6;504416;229495|2;643947;270669|2;684600;252189|1;2643057;1720696|1;2653028;2384844|1;2997312;3353727|1;2997312;3410188|1;6073352;1583491|1;8076618;3434458|1;8076618;3453039|1;10078550;1979206|1;10541691;3430898|1;11038330;3630823|1;11228849;2531480|6;1996;232946|8;32298;6342|6;33260;236505|8;43958;6979|6;101460;229728|6;112232;229470|6;168351;232825|6;181692;229439|5;213128;20831|2;814989;258780|1;6886299;2774590|1;8718784;1175705|1;9498265;4176268|1;10331697;2150144|1;10347020;3675240|1;11260041;3006797|2;832197;315490|1;943428;1089433|1;11618396;3255822|1;11873701;3858106|1;10861378;2710910';

  vr_lstcontr_3 VARCHAR(4000) := '1;1836544;28824|1;1837818;38576|1;738743;175365|1;2351498;45703|1;2072980;63778|1;2134853;20238|1;2448300;201755|1;2468360;94216|1;2468581;114238|1;2659034;188595|1;2950260;77504|1;6401570;188663|1;3531228;994941|1;7029071;9181923|1;2656655;9113312|1;6121381;176275|1;6616887;9119504|1;7561342;232896|1;6685382;210768|1;80101461;171976|1;6603270;141030|1;80243240;196896|1;6186556;227569|1;6605249;39424|1;7597940;248518|1;3071839;243250|1;7900759;230357|1;3795900;241240|1;80246273;39457|1;8297908;233744|1;7099177;194166|1;8333297;271300|1;7336950;9199160|1;7188056;228935|1;3026140;247328|1;7039069;9176198|1;2741679;246600|1;6072895;175731|1;6073450;198247|1;1964194;194881|1;8069905;9178298|1;7730667;240427|1;6221530;9165100|1;6766412;9273654|1;8787379;224605|1;3869261;175795|1;7071817;8156467|1;7553919;9232308|1;6961169;8199456|1;8663661;287777|1;9011005;309120|1;85537;279215|1;7800045;312409|1;8858446;278219|1;8615756;281852|1;3713709;9278999|1;2187825;310003|1;6195598;560|1;2657074;2306|1;7736827;2807|1;9181792;1984|1;2742012;3965|1;9384456;6619|1;8211060;8839|1;80490050;7905|1;9545298;8871|1;9342117;9517|1;6322123;9561|1;6363938;10557|1;7731370;11659|1;9615393;14054|1;8251983;14064|1;1963279;14282|1;2988453;14774|1;2867745;14589|1;2822814;17070|1;2830949;17003|1;8464910;18530|1;750441;25220|1;3902528;25069|1;8813086;26391|1;8081204;26797|1;9850376;27337|1;6008330;26999|1;8982945;27522|1;7332416;27436|1;1992040;30537|1;822914;31971|1;7462034;32405|1;6410782;32828|1;8608156;32854|1;2475499;38861|1;9949810;38933|1;2197030;38934|1;7764120;39196|1;7594143;39038|1;6403611;39221|1;9969764;39369|1;2855682;39587|1;4076222;39699|1;9973834;39767|1;2083280;40506|1;8350973;40544|1;2607298;40576|1;894052;40508|1;1924893;41074|1;9809465;41234|1;7309392;42003|1;6659365;42405|1;7913214;42309|1;8578540;42455|1;8922608;43785|1;2398559;43863|1;6092322;43953|1;7831196;46276|1;7394829;47570|1;9039180;47685|1;2569035;47603|1;3742784;47715|1;8524440;47858|1;7571291;47753|1;7199805;48268|1;10175148;47887|1;6141714;49495|1;6658326;49500|1;10172459;49567|1;7243030;52728|1;8762066;53019|1;7057610;52974|1;2180073;53023|1;10218467;53151|1;10214291;53050|1;3890040;53098|1;6990860;53122|1;9070320;53136|1;9683216;53382|1;6658300;53319|1;10230874;53395|1;9861505;54635|1;6893260;54659|1;3914283;56095|1;8966664;55174|1;7444869;55264|1;10228071;56130|1;3087034;56398|1;7806230;56729|1;10061452;56951|1;7109563;57070|1;3656020;57139|1;6478239;57258|1;3621006;57955|1;3073467;58480|1;895334;58720|1;10401466;58697|1;10316078;58906|1;10399895;58843|1;7368860;58988|1;8313792;59061|1;9171673;59257|1;8767475;59514|1;3581764;59662|1;6499155;59982|1;2892006;60280|1;6478840;60242|1;10486453;60293|1;8877319;60353|1;9880771;60385|1;2585448;60504|1;6257356;60778|1;10519335;60797|1;620;61093|1;6368476;64148|1;10218459;64395|1;7753918;64207|1;8023131;64904|1;8739676;64958|1;10228675;65075|1;2698765;65201|1;10553444;65400|1;8845387;65504|1;1825674;65706|1;3960900;134481|1;7619120;65668|1;2341395;67934|1;7735600;67874|1;10050760;65868|1;2711060;67944|1;10294686;67947|1;10127666;67948|1;4013670;67991|1;3906884;68096|1;2975726;70086|1;8530670;70289|1;8702691;70365|1;10749411;70490|1;10487859;70680|1;10751718;70661|1;6532284;70664|1;2820021;70696|1;10607609;71050|1;2530023;73054|1;9261010;72490|1;7637888;73812|1;10342680;78543|1;10469303;77257|1;9226125;80293|1;10664874;80806|1;10517057;81288|1;6029396;82311|1;10488251;83444|16;3679799;3108|16;880760;3342';
  vr_lstcontr_4 VARCHAR(4000) := '1;9353950;84910|1;10821341;84813|1;7801076;84816|1;10805982;85024|1;6871941;85153|1;9454888;85360|1;8301239;85426|1;2359871;85894|1;2563770;86128|1;8770662;86196|1;8762570;86611|1;8712190;86298|1;9783830;86736|1;6250882;86748|1;2425270;89802|1;11036788;89959|1;8481830;90043|1;11063211;90272|1;8216231;90881|1;10714634;90582|1;10949658;91607|1;7214570;92388|1;8968942;92061|1;10858423;95963|1;8713553;99195|1;9939881;98963|1;9702270;99008|1;11142766;99297|1;10690654;100572|1;6205577;103749|1;8584575;103872|1;3817032;103838|1;2996855;103910|1;1512854;104002|1;9185178;104147|1;11120517;104495|1;11243937;104674|1;8193606;104799|1;10136878;104978|1;3667812;104899|1;1527576;105008|1;4080300;104988|1;11002654;105023|1;11122285;105178|1;7803850;105102|1;7965974;105168|1;2214768;105335|1;10315080;105328|1;2761955;105360|1;9896899;105363|1;11233400;105390|1;11229918;105413|1;8700532;105679|1;7729871;105602|1;6093582;105841|1;10463887;105791|1;1857398;106031|1;7903383;106035|1;11440058;106059|1;11493593;107326|1;11503211;106794|1;11455241;106931|1;11480270;107328|1;2484080;107339|1;11519983;107354|1;7427263;107451|1;9064664;107377|1;11537833;107573|1;3639827;107518|1;7703627;108113|1;10188444;108020|1;11298413;108242|1;8268649;108157|1;11063980;108177|1;10226800;109249|1;11396075;109002|1;11654414;109009|1;1879529;109657|1;11782072;114684|1;7768478;112797|1;8802769;116357|1;11856564;118956|1;11726512;119469|1;11819928;121775|1;11998873;124454|1;8264503;124431|1;11565926;124470|1;12123994;124945|1;11348836;124846|1;12071609;124996|1;11244429;131905|1;7152175;130655|1;12189057;129256|1;12966932;133096|2;217549;432|2;544990;322|2;507954;582|2;575887;600|2;640468;778|2;709875;1012|2;314323;255331|2;574465;1065|2;769614;1344|2;771287;1304|2;804290;1495|2;760811;1470|2;838373;1698|5;72907;282805|5;203335;615|5;174190;408|5;174343;410|5;145459;478|5;190012;522|5;239496;755|5;233005;883|5;213071;911|6;503363;132108|6;119598;78|6;147303;150|6;79480;168|6;175811;185|7;39411;261505|7;31542;167517|7;40959;167222|7;20311;206549|7;34428;150528|7;333689;261541|7;334030;261538|7;41564;202506|7;10200;187556|7;129704;167632|7;240362;237116|7;236012;269121|7;71226;217301|7;330957;217099|7;17582;167635|7;12343;42|7;150134;251602|7;71234;98|7;231878;162|7;37842;128|7;161896;395|7;193763;310|7;148750;338|7;205370;398|7;252336;480|7;255220;542|7;247618;562|7;187330;810|7;13820;792|7;123323;859|9;242764;793|9;253685;778|9;198900;988|9;101621;869|9;290092;996|9;302899;1099|9;324396;1272|10;59226;226588|10;43036;226567|10;52337;270738|10;51314;226590|10;58289;216|10;149659;693|10;83135;688|10;55352;289|10;156710;762|10;184845;847|11;274976;237585|11;96040;237729|11;301248;264044|11;144649;207710|11;172227;268692|11;196371;268407|11;385417;301|11;303801;788|11;426652;675|11;467260;1092|11;400599;1274|11;419656;791|11;424145;1215|11;299006;1542|11;554642;2001|11;493910;2132|11;180700;2037|11;563960;2162|11;289078;2395|11;711543;2813|11;686638;2729|12;23205;291105|12;21814;283099|12;1643;320|12;122114;323|12;76970;329|12;143634;407|12;155411;495|12;40320;514|13;732982;1034|13;272000;1018|13;356042;1661|13;437514;1872|13;245585;1845|13;449342;1987|13;409286;2679|14;39896;276368|14;876;316004|14;53694;658|14;118605;1214|14;35254;1287|14;24317;1359|14;184039;1673|16;107700;611|16;213373;496|16;252310;1445|16;1888170;2036|16;566071;2041|16;249602;2264|16;647780;2361|16;271527;2539|16;3001768;2854|16;2473623;2833|16;3900002;3005|16;799270;2984';

  vr_lstcontr_5 VARCHAR(4000) := '1;10749411;16556|1;7214570;19352|1;11218266;19089|1;7291094;19961|1;10994610;18639|1;11480270;20930|1;11514647;20923|1;11305070;20775|1;11571136;21108|1;8298297;22329|1;9558462;22018|1;11246200;23357|1;8927979;24691|1;7979312;25089|1;12605549;25429|1;8767017;25199|1;12859230;26022|2;811858;852|2;583650;966|5;174343;290|5;203335;567|7;329339;1061|7;93033;1400|9;101621;1099|9;311090;1274|9;349941;1468|9;373907;1574|10;160598;530|10;130567;480|11;345563;1256|11;320021;1251|11;467260;1465|11;714445;1346|13;379328;1000|14;24317;986|16;750760;990';
  
  CURSOR cr_operacao(pr_cdcooper tbrisco_operacoes.cdcooper%TYPE
                    ,pr_nrdconta tbrisco_operacoes.nrdconta%TYPE
                    ,pr_nrctremp tbrisco_operacoes.nrctremp%TYPE
                    ,pr_tpctrato tbrisco_operacoes.tpctrato%TYPE) IS
  SELECT o.inrisco_rating, o.dtrisco_rating, o.inrisco_inclusao, w.dsnivori
    FROM tbrisco_operacoes o, crawepr w
   WHERE o.cdcooper = w.cdcooper
     AND o.nrdconta = w.nrdconta
     AND o.nrctremp = w.nrctremp 
     AND o.cdcooper = pr_cdcooper
     AND o.nrdconta = pr_nrdconta
     AND o.nrctremp = pr_nrctremp 
     AND o.tpctrato = pr_tpctrato;
  rw_operacao cr_operacao%ROWTYPE;
  
  PROCEDURE pc_processa_contratos(pr_dadosctr IN VARCHAR2
                                 ,pr_tpctrato IN INTEGER
                                 ,pr_updcompl IN INTEGER
                                 ,pr_cdcritic OUT INTEGER
                                 ,pr_dscritic OUT VARCHAR2) IS
  
  BEGIN
    
    vr_contrato := GENE0002.fn_quebra_string(pr_string  => pr_dadosctr
                                          ,pr_delimit => '|');  
    
    FOR vr_idx_lst IN 1..vr_contrato.COUNT LOOP
      
      vr_dadosctr := GENE0002.fn_quebra_string(pr_string  => vr_contrato(vr_idx_lst)
                                              ,pr_delimit => ';');  
      
      IF pr_updcompl = 1 THEN
        OPEN cr_operacao(pr_cdcooper => vr_dadosctr(1)
                        ,pr_nrdconta => vr_dadosctr(2)
                        ,pr_nrctremp => vr_dadosctr(3)
                        ,pr_tpctrato => pr_tpctrato);
        FETCH cr_operacao INTO rw_operacao;
        CLOSE cr_operacao;
        
        UPDATE tbrisco_operacoes a 
           SET a.flintegrar_sas = 1,
               a.inrisco_rating = a.inrisco_rating_autom,
               a.dtrisco_rating = a.dtrisco_rating_autom,
               a.inrisco_inclusao = 2
         WHERE a.cdcooper = vr_dadosctr(1)
           AND a.nrdconta = vr_dadosctr(2)
           AND a.nrctremp = vr_dadosctr(3)
           AND a.tpctrato = pr_tpctrato;
           
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE tbrisco_operacoes a ' || chr(13) || 
                                '   SET a.flintegrar_sas = 0'|| chr(13) ||
                                '      ,a.inrisco_rating = ' || nvl(CAST(rw_operacao.inrisco_rating AS STRING), 'NULL') || chr(13) ||
                                '      ,a.dtrisco_rating = to_date(''' || to_char(rw_operacao.dtrisco_rating, 'dd/mm/yyyy') || ''', ''dd/mm/yyyy'')' || chr(13) ||
                                '      ,a.inrisco_inclusao = ' || nvl(CAST(rw_operacao.inrisco_inclusao AS STRING), 'NULL') || chr(13) ||
                                ' WHERE a.cdcooper = ' || vr_dadosctr(1)  || chr(13) ||
                                '   AND a.nrdconta = ' || vr_dadosctr(2)  || chr(13) ||
                                '   AND a.nrctremp = ' || vr_dadosctr(3)  || chr(13) ||
                                '   AND a.tpctrato = ' || pr_tpctrato || ';' ||chr(13)||chr(13), FALSE);    
        
      ELSE 
        UPDATE tbrisco_operacoes a 
           SET a.flintegrar_sas = 1
         WHERE a.cdcooper = vr_dadosctr(1) 
           AND a.nrdconta = vr_dadosctr(2)
           AND a.nrctremp = vr_dadosctr(3)
           AND a.tpctrato = pr_tpctrato;

        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE tbrisco_operacoes a ' || chr(13) || 
                                '   SET a.flintegrar_sas = 0'|| chr(13) ||
                                ' WHERE a.cdcooper = ' || vr_dadosctr(1)  || chr(13) ||
                                '   AND a.nrdconta = ' || vr_dadosctr(2)  || chr(13) ||
                                '   AND a.nrctremp = ' || vr_dadosctr(3)  || chr(13) ||
                                '   AND a.tpctrato = ' || pr_tpctrato || ';' ||chr(13)||chr(13), FALSE);   
      END IF;
      
      
      IF pr_tpctrato = 90 THEN
        UPDATE crawepr e
           SET e.dsnivori = 'A'
         WHERE e.cdcooper = vr_dadosctr(1) 
           AND e.nrdconta = vr_dadosctr(2) 
           AND e.nrctremp = vr_dadosctr(3);
        
        
        IF pr_updcompl = 0 THEN 
          OPEN cr_operacao(pr_cdcooper => vr_dadosctr(1)
                          ,pr_nrdconta => vr_dadosctr(2)
                          ,pr_nrctremp => vr_dadosctr(3)
                          ,pr_tpctrato => pr_tpctrato);
          FETCH cr_operacao INTO rw_operacao;
          CLOSE cr_operacao;
        END IF;
        
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback                       
                               ,'UPDATE crawepr e ' || chr(13) || 
                                '   SET e.dsnivori = ''' || rw_operacao.dsnivori || '''' || chr(13) ||
                                ' WHERE e.cdcooper = ' || vr_dadosctr(1)  || chr(13) ||
                                '   AND e.nrdconta = ' || vr_dadosctr(2)  || chr(13) ||
                                '   AND e.nrctremp = ' || vr_dadosctr(3)  || ';' ||chr(13)||chr(13), FALSE);    
      END IF;
    END LOOP;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao processar contratos: ' || SQLERRM;
  END pc_processa_contratos;
BEGIN
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0124236';
  vr_nmarqrbk := 'ROLLBACK_INC0124236_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
    
  vr_dados_rollback := NULL;

  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);     

  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Programa para rollback das informacoes'||chr(13), FALSE);

  pc_processa_contratos(pr_dadosctr => vr_lstcontr_1
                       ,pr_tpctrato => 90
                       ,pr_updcompl => 1
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 
  
  pc_processa_contratos(pr_dadosctr => vr_lstcontr_2
                       ,pr_tpctrato => 90
                       ,pr_updcompl => 0
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 
  
  pc_processa_contratos(pr_dadosctr => vr_lstcontr_3
                       ,pr_tpctrato => 2
                       ,pr_updcompl => 0
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 
  
  pc_processa_contratos(pr_dadosctr => vr_lstcontr_4
                       ,pr_tpctrato => 2
                       ,pr_updcompl => 0
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 

  pc_processa_contratos(pr_dadosctr => vr_lstcontr_5
                       ,pr_tpctrato => 3
                       ,pr_updcompl => 0
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF; 
  
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);

  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);    
    
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                     
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_rollback             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqrbk 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
          
  IF TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
  END IF;  
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);  

  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_lob.close(vr_dados_rollback);
    dbms_lob.freetemporary(vr_dados_rollback);  
    raise_application_error(-20111, vr_dscritic);
end;
