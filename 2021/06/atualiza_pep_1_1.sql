DECLARE--257.04
  vr_altera      BOOLEAN := TRUE;
  vr_count       NUMBER;
  vr_texto_carga CLOB;
  vr_texto_carga_aux VARCHAR2(32767);
  vr_dsdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';

  vr_nmarquiv   VARCHAR2(100)  := 'atualizacao_pep_1_1.csv';
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
       AND crapass.cdcooper = 1 AND crapttl.nrcpfcgc <= 6362014901
       AND (crapass.nrcpfcgc in (495680940,694562912,3049962976,5668293980,5030638946,510586937,491318936,
                                2882318995,1907675965,4716236951,4927673944,5370592969,4953640969,
                                5679022931,4263807979,696614995,2541043988,2171049910,856921076,
                                3279337984,3558425995,371002036,6227207918,3629222927,1560122005,
                                5252771960,3934751903,4982648905,1676698930,4745650922,5597190946,
                                5865309919,5352299929,483115967,4001574977,4538699985,2222589932,
                                3594018997,2271018986,567823903,3118269979,5279934925,4400126943,
                                5904092989,1745569936,3978961903,3809282995,482011971,3474956990,
                                6254606933,193622009,4202840950,2048044930,2004300094,1510668926,
                                6081406946,4329039923,6195457981,4215787939,558006027,4168147940,
                                3514873950,5830569973,5912874982,3276796970,1622357981,587310910,
                                2466307952,2037156910,1282451073,4903580989,5649590907,3224522950,
                                5884124902,5851409959,3795216958,882960911,732488940,5932135999,
                                4344134966,1211257347,2999903979,5652432926,4295791954,4716224945,
                                2670988989,6274119914,2076563989,3934751903,2463634952,4044929912,
                                5203314942,2458460933,5961135950,19718080,372509908,2453012916,4492311947,
                                902468960,820333905,4549382929,726911070,5432665913,2484206909,2330433905,
                                4469288950,3330579960,5727213908,3517324973,939194929,891839917,
                                1556454988,557643988,5515112903,4903754995,5838667940,5125503959,
                                4168147940,5727213908,3021757928,2122925957,3347859952,5703899923,
                                1962027953,2555066942,5321294909,700986979,3863153960,4884898907,
                                186550090,2931453935,5630238990,1003032931,334698901,404172989,
                                5228111913,4296369970,3607756597,705109976,5752961947,1903067936,
                                446165972,2135328910,3327347905,368791939,1014249902,3629474900,
                                5417152919,1745569936,5374849905,149360118,3125047994,1010118900,
                                2121486992,2241322962,840318910,5675534938,1605250988,1103146114,
                                3325096999,2562108965,4853308903,4431705929,1469158957,778196917,
                                354310917,560931956,1561199940,2937039901,6103883555,4325271929,
                                3839017904,3132132918,558748945,1014249902,2484206909,3035677913,
                                453829996,5434855957,3096447985,2876080931,371002036,4888041911,
                                3022645902,1994645962,2076563989,4897890993,2127445937,3059520992,
                                2486158901,1458634922,468446940,5841460943,2654117936,4168147940,
                                1709308907,3912889970,6355939989,3327347905,2004300094,2862029998,
                                3550162901,6049019924,390329908,3795216958,5914128960,4779099900,
                                5683164958,5173390999,1676039902,655264906,143970054,4295791954,
                                2882318995,5076639937,2469258928,3491750989,4927673944,4631321903,
                                1659093902,5185801999,2109184973,5780092931,6210679978,2160777960,
                                481511903,5838667940,2689370956,354310917,5041213917,2329634951,
                                2719867942,1865586943,5370592969,3717165941,537873902,2062983077,
                                2528834977,2062983077,362869901,5942577943,2705178988,4427500994,
                                961685956,5886618996,558748945,2819656927,2245716990,4116230952,
                                5100767936,3946586988,2196909955,4459309939,61650951,372807089,
                                2079362933,1624118984,3314744927,4661013921,1656649918,5792473927,
                                3830921918,2984592999,4522773960,5896692900,4793314996,1825493995,
                                1504565908,441514979,3491750989,4752849925,5675534938,4402097908,
                                4304520989,4298863905,1504565908,2379757933,1169722970,5469664970,
                                780462971,780462971,2878757505,578625911,11641983,5192940923,
                                1563837994,3760671950,3077083655,3357187957,5807525930,610733931,
                                6217378957,4538699985,3629683908,1624118984,5777023940,962389099,
                                3953756494,5864098906,5861642940,4316852906,5228626913,4416028946,
                                3849474925,549956980,3327347905,378583948,6325851960,471748978,
                                5843305961,1979383960,684721961,3914472979,1605250988,3125047994,
                                1982641940,4204886930,2705178988,5265710981,546468985,3771714923,
                                1593417950,1441052925,626168970,3347878906,3053452901,1556454988,
                                3429058643,510209980,5158118906,556129970,2465889931,5961988929,
                                5851919990,6090953903,3216070905,2066898961,5566235921,5566235921,
                                1827372923,1111758956,2330433905,3810927988,5812787980,5023199924,
                                2128695902,429288930,1085533964,587310910,4229459866,714934925,
                                4486179943,5160328360,610176986,3789472905,4431705929,2556299908,
                                4019914907,2163037967,5374869922,357185951,6081406946,143970054,
                                149360118,1510668926,865195900,4883487903,2121486992,865195900,
                                2379757933,714934925,511437986,10564926,3737988900,1479221945,
                                2588466079,2588466079,4888041911,1928900933,4295791954,3789472905,
                                5199288903,4373089957,515905577,4895672905,4324162930,6083835976,
                                458105910,1759087963,1667104900,2689370956,482011971,3284543970,
                                2156106959,4158816920,4474998901,1923735950,556129970,
                                1676594990,1823774903,2060422990,1751594912,4700787902,820333905)
        OR crapass.dtabtcct >= '01/05/2021')
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
          IF instr(vr_pep.vr_dsrelacmnto, ' CONJUGE ') > 0 OR instr(vr_pep.vr_dsrelacmnto, ' CÔNJUGE/') > 0 THEN
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
