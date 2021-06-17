DECLARE--16182,111
  vr_altera      BOOLEAN := TRUE;
  vr_count       NUMBER;
  vr_texto_carga CLOB;
  vr_texto_carga_aux VARCHAR2(32767);
  vr_dsdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';

  vr_nmarquiv   VARCHAR2(100)  := 'atualizacao_pep_1_3.csv';
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
       AND crapass.cdcooper = 1 AND crapttl.nrcpfcgc > 13142888900
       AND (crapass.nrcpfcgc in (60829257934,66509505991,52899004972,55649335915,68419350982,44038569934,
                                34808973987,46458611900,88691586915,83519858991,80624618900,70492727953,
                                90218140991,63068621968,44074948915,96094478991,81843909987,67146848949,
                                93763310959,75071207915,58276629920,91598320963,81712898949,53352823987,
                                40216888972,57027552949,65601440972,43297749920,82174067900,84621770900,
                                31153895900,50576461920,65638581987,82117136915,48537543934,78522838968,
                                52313484904,93981791991,67520090906,53132530930,63554330906,82777578249,
                                77255496920,24747920900,77108191920,60423153900,72177969972,89095243915,
                                83367489972,90218140991,80624200949,62945904934,43911609949,37857720925,
                                65838246987,71647830982,70768862000,47580666987,68526474987,64232050949,
                                80624634949,68345844987,66101964949,64081486387,83840141915,63334569934,
                                38282569968,56598130972,58276629920,84830190949,83218467934,93982992915,
                                67307760991,71092935991,71557105987,65977220944,41881095991,43518532987,
                                61910023949,64995224904,55675603972,74648063953,90481542949,75808587972,
                                38860252920,48373893920,21875235949,67491090982,76385019934,61430200944,
                                82403465968,93620659915,84804297987,35247250826,77255496920,45379572987,
                                72565608934,62965140930,39639878987,29130930944,94846561968,89178726972,
                                43959490968,98311875049,62420550900,69114587904,96386762991,69441936987,
                                46911596904,94989052900,90503120987,78008468904,81235712915,77255275915,
                                45093628972,85219576968,94767807972,29326079953,57772240910,58197982953,
                                74637916968,95780610053,89528751920,83451501953,49840363972,73534170997,
                                88675300972,31151957968,52036022987,44739044900,77775082968,90273974904,
                                22456929934,31037445953,67048889934,81101678968,95155228972,50552325953,
                                29447402968,64981177968,47218800904,85061050991,74369130930,43911609949,
                                67309666968,60128658991,19414595953,44417055904,63783924987,67775802049,
                                96094478991,66551331904,85436232949,60572825900,48537764949,88693309900,
                                73375128991,71263420982,81101678968,58696598920,52082890910,47603577934,
                                83451323915,89178726972,77108191920,41840469838,78133084920,63334046915,
                                82472165900,37864068987,93763310959,38396211949,17898650930,72581840900,
                                79953573972,90481542949,89599411900,21873860900,67491090982,80581030982,
                                29170613915,48537543934,61234885972,64187713972,72178418953,55052657900,
                                80158692934,44317867915,89927680953,95145044968,58146482953,65502256049,
                                46068082920,72178418953,63860988972,40772926972,88705129915,59470879953,
                                65465938153,33739192828,41974280900,53921232953,94662070910,80691641900,
                                33877757847,69062021972,93565038934,69350540959,89838785920,55171842949,
                                77585720904,37938991953,75151235915,80320813991,95684786553,78859972949,
                                53353501991,61430080949,33877757847,20749228920,76771407934,42139317904,
                                21796270920,61342726987,61489867953,77744837991,54064066987,37857720925,
                                69490929972,75075458904,75363909987,25385330078,64114201068,85488518991,
                                56226691972,47580542900,78977010934,54064015991,83218467934,65476476920,
                                45093628972,24925381920,54674549949,74662740991,97928062100,47580542900,
                                38346176953,77678630930,93664060920,63302306920,66479053915,98826964904,
                                72716827915,75075458904,39470622812,37928090953,54539951904,54706165920,
                                21796270920,62504908920,55860966920,34065762812,52812324953,98705512972,
                                37941240904,47218800904,94121699904,42140935934,72283629934,60097531987,
                                29327750900,54064066987,81652526900,99070090910,38282569968,69289948949,
                                44317867915,64081486387,81295740982,19474768900,97054640900,38300290982,
                                53352866953,96977779934,52313484904,21631883968,93674279991,57885427900,
                                41970675934,50208250930,70245762949,44445679968,75075458904,85096300978,
                                31181325900,43297749920,29695635920,42139635949,73975729953,83380485934,
                                77711610904,75363909987,44417055904,91849250944,46042270982,40407462015,
                                37857509949,83451587904,60097531987,43959482949,72939320900,56923872987,
                                97616800963,71300767987,38369710972,93620659915,82050287020,52228029904,
                                61430080949,46668195920,47384484987,57027552949,83841164900,49045555972,
                                31037445953,48537764949,80624618900,81180756991,93674279991,77862554868,
                                32652925091,64511731934,63560330963,71092811915,82434093949,90512014949,
                                90144384949,44038569934,52331385904,30508327890,71093486953,55769195991,
                                86276506915,63783924987,88304736934,56226861991,75395533915,64981177968,
                                37614835972,55865313053,93153147949,63302306920,73375128991,88675300972,
                                66247748787,55860966920,88683494934,71255443987,34496173972,50115480900,
                                92544053020,18044425934,71319379915,77255275915,74553127920,34183523915,
                                78560470972,66617219953,37963651915,46049274991,38240858953,63687984087,
                                67146848949,99090961968,90812875915,63860988972,69299420904,97054640900,
                                46738207972,43959490968,65602013920,98861700934,58474285968,56923872987,
                                77862554868,76771407934,55996078953,29327440978,48634557987,63687984087,
                                89535642987,29700191915,80693016949,69035253949,78161010900,86608320949,
                                78560470972,69050392920,41807260925,89535618920,90020626053,74662740991,
                                91529140978,29197643904,40910857253,94765839915,62203614900,20749228920,
                                81702728900,57333840930,97616800963,65232291904,55518788991,19235194091,
                                76509745968,83395121968,46888233987,81652526900,57660476904,46668195920,
                                31154301915,94768927904,37864068987,29091003839,80302939920,51975203291,
                                55769195991,90770650910,68526474987,66247748787,64407438991,71237461987,
                                95163050915,68179367991,38369710972,31143598920,89872363900,57333572900,
                                71320350968,59423331904,30284775991,88626431953,63463857987,75074516900,
                                91432189972,69441936987,59654015900,46048081987,71319379915,63560330963,
                                44317867915,69080984949,31057748900,58474161991)
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
