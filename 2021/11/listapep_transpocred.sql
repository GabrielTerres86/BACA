DECLARE--257.04
  vr_altera      BOOLEAN := TRUE;
  vr_count       NUMBER;
  vr_texto_carga CLOB;
  vr_texto_carga_aux VARCHAR2(32767);
  vr_dsdireto   VARCHAR2(4000) := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                           ,pr_cdcooper => 0
                                                           ,pr_cdacesso => 'ROOT_DIRCOOP')||'cecred/arq/';

  vr_nmarquiv   VARCHAR2(100)  := 'atualizacao_pep_9.csv';
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
       AND crapass.cdcooper = 9
       AND crapass.nrcpfcgc in (
        10054511925, 1014392969, 10458775000169, 10523467000170, 1060353989, 10841455961, 11068811927, 1111622035, 11118562909, 11156166926, 11186639938, 11186639938, 11246990903, 1127758969, 
		11408263955, 11416981000179, 11450287000178, 11489703985, 11489744908, 11646374959, 11938845000149, 11938845000149, 11970731087, 12142424000170, 1250634075, 12586672909, 1271298040, 
		12744125000105, 12924572000146, 13125951000139, 13141723000152, 13532495000141, 1372537000145, 1372537000145, 14013917000135, 1405384964, 14104037000174, 14118092000113, 1437432603, 
		14868618000182, 15213276000125, 1565904923, 1588444000152, 16464947000193, 1672458994, 17079813000111, 17772338015, 17819806915, 1795209976, 17958635000107, 18345356000122, 19269373000190, 
		19585765000169, 200728059, 200728059, 2014989958, 2037152094, 2095771931, 20992825000147, 21649169809, 21784658000101, 21852093000152, 21878139000102, 21932654968, 21935220900, 2223206000106, 
		2223206000106, 2223206000106, 2317551983, 23580511000125, 23700528000179, 23700528000179, 23839841000192, 2386927016, 24126734000180, 24608356000170, 24663199000104, 24819852000173, 
		24819852000173, 2484691939, 24916774000125, 24916774000125, 25130277953, 2526850000153, 25432871000105, 25432871000105, 25533799000102, 2577657943, 2590519931, 2590519931, 2605190900, 
		2606915933, 26076229000101, 2608958907, 2608958907, 2615500988, 26179463000156, 26179463000156, 26380095000100, 26380095000290, 26894433000121, 27342538000130, 27477938000153, 27550118000140, 
		27656096000105, 27758071864, 2799029000100, 28612105000110, 28612105000110, 2882422970, 2913171036, 29161997000143, 29261089000202, 2927336903, 2973751993, 3006693990, 30099508000150, 30163188068, 
		30320941000, 30323790000107, 30367693000116, 30487617991, 30518648000115, 30625610920, 30776898000155, 30839323000134, 3094114000136, 31098366000179, 31204937915, 31316750000109, 3202744976, 
		3250200948, 32932286000130, 3410276939, 34139400900, 34280525000140, 34343237087, 34362955000100, 34370889987, 34751424904, 34866836000195, 35494824004, 3553395958, 3553395958, 3553395958, 
		3618109970, 36184740000172, 3659124923, 36608157053, 3669423000197, 37279875000184, 37295667920, 37998552972, 381143996, 3811707990, 3811707990, 3827450000140, 38392208900, 38625217000160, 
		38641674004, 3886820947, 39842528000143, 39886190949, 3991791943, 4040246020, 4054322913, 41119126053, 4116897973, 4121291000127, 4121291000127, 4152985984, 41715178858, 4245222093, 42768802034, 
		42782085000157, 4412628000155, 4455308000182, 4476078982, 45877602934, 4705944976, 4716928918, 47402466000, 4777334000127, 4790557936, 4832825000123, 4833799995, 48593117953, 48667536091, 
		49585118068, 4965537980, 49877690004, 49877690004, 49944754900, 500660999, 5020291960, 50684949091, 50842757015, 5095664992, 51201640997, 5151253930, 5152558904, 5158170000112, 52182533915, 
		5223004990, 52945642034, 53052854020, 531534995, 53232909353, 5339371913, 5360801000181, 53794699904, 5433726932, 5436511937, 54518083920, 5473711952, 55148530987, 55149146900, 5545745000150, 
		5594829903, 56328206968, 5664518910, 56725540082, 57477124034, 5769494930, 5820433000107, 58229159904, 58829687987, 5903836984, 590506919, 5910812000198, 5942559961, 5960986930, 5960986930, 
		59773820904, 597925070, 6020858960, 6020864936, 6116603939, 61412570034, 6221411000193, 6228746910, 62315730015, 62562339991, 62759680959, 6293159900, 64095193972, 648445950, 64928780000, 6512596900, 
		65610210020, 658236997, 65869524091, 65967453920, 6600062940, 66103568900, 67466109004, 6756661981, 6812201049, 68376391968, 68784333049, 6891979935, 69369992987, 6939275932, 6939404929, 6959746965, 
		69609250963, 696614995, 6997431925, 7005354974, 702031992, 71018832904, 71034560972, 7186625000139, 7232015950, 72986441904, 73249777900, 74006115000120, 740299913, 744032903, 7448660000189, 7477099986, 
		74945491020, 75311321920, 760639922, 7610990000129, 7610990000129, 7610990000129, 7620630929, 76684737000132, 77058881000126, 7799537973, 7811192000165, 78147417853, 78147417853, 78491789987, 789262975, 
		79507141000155, 80090061000207, 8046361925, 8075352000118, 8075352000118, 8093896902, 81646101000136, 81783299991, 8179461955, 81810376000163, 81945302968, 82099136000165, 82379963053, 83085902000103, 
		83085902000103, 832842907, 8369813000165, 8369813000165, 8413972957, 8474167000104, 8474167000104, 8547336982, 85918903020, 8642771000194, 8653751947, 8662802940, 8721430900, 87920377000147, 8815669000143, 
		88166198053, 88382540015, 88668454000186, 88768210906, 88959368920, 88961974000182, 8897094000155, 89304470900, 89315774949, 9033301000196, 90503244953, 905811054, 91479983004, 92279363000126, 92719473200, 
		92854117972, 93293534953, 9330084000104, 9330084000104, 93613830000, 93734930006, 93903367087, 94886253920, 9519410970, 9531107000130, 9570439963, 9645065992, 9645065992, 97071633053, 977513912, 9846194960, 
		99617528568, 1055380000, 11243166983, 15001448000105, 15315675000105, 1593346913, 16757774000100, 18631500000197, 195661000110, 22017972000121, 28067010000163, 28423819000180, 29807994000134, 30728345000127, 
		31824866000140, 35423353000189, 36146291000178, 3695261986, 3779602000187, 4682144000126, 4715389908, 5592418957, 59418338904, 6020858960, 6221411000193, 63281910068, 773435000179, 7767838900, 80727928000101, 
		83085902000103, 83522227000124, 83522227000124, 8897094000155, 8897094000155, 90950338000105, 90950338000105, 97102601034, 98947656020
		)
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
