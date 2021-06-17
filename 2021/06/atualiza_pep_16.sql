DECLARE--7604,586
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
       AND (crapass.nrcpfcgc in (2160038903,351597905,351597905,6224585903,525491945,4414574951,1623120918,
                                67134823920,4179614995,69293228904,2993737970,3404333969,4475296927,46344888920,
                                2090455900,4272165917,9860497940,4744666981,5619992950,2400236925,81858558972,
                                65269020904,10590284924,3292937965,3208065965,1799381935,62559303949,71628967900,
                                601335970,12176181980,10972568980,9997184955,65712129949,6684710930,3238345907,
                                11305491947,9295229908,9384129909,6246154999,77208595968,6667415900,71438211953,
                                65269020904,56940394915,73974579915,4017666914,83807233920,94719942920,52144763968,
                                1926359992,81797761900,2947678940,12482538920,47699868072,29271509900,81883579953,
                                8332493986,89820118972,5733252944,83809066915,6624423935,10972557946,46344829915,
                                42070856968,9623427930,71552669904,8167251950,3895079979,10026998947,94862036953,
                                3424172901,41806506904,2739261950,84566868915,84612274920,39972291987,91070643904,
                                10710631979,8455024925,83446079904,4308801974,2100672924,57343284991,671930990,
                                57571481953,18091954972,63667460953,8267317910,7829700958,71977279015,1855788969,
                                6598603927,383456924,2195347996,4088622979,716482916,77507703991,8695401901,
                                44399960949,70309116953,3937211918,98852256920,39967476915,1824477902,2642256944,
                                84859415949,86679872987,1994552956,89646150934,11292576901,50114913900,7112307902,
                                56419740991,5319868960,8141964976,67815057934,1521414998,79631207900,53463072904,
                                92764452934,70137013949,3783297907,128154039,76278646900,4289122906,46945458920,
                                1926359992,2348932903,12176199928,2960509978,3302661959,3922914950,76963195900,
                                49839780972,3717869914,6071563178,95167552915,5044810967,340358939,7997993940,
                                50114913900,1615107959,80327966068,65269020904,65711637991,23315970904,6194879920,
                                7107851942,29279496972,9922293919,4396768940,3200832924,11033872946,922718989,
                                45392692915,371785987,96427930915,12134023953,83809066915,56419740991,7634155969,
                                44399960949,83807233920,8997536982,1774950901,31037216920,4475296927,76756599968,
                                7112307902,3580221930,5343282962,91577586972,3787586911,2570342939,6822440909,
                                5080357916,3209753989,54286913953,6406922905,2013972938,11584970910,3895079979,
                                4396768940,4747622977,90729161900,840318910,96391448949,2625154900,12254875957,
                                4352962996,11206121955,11274659965,939443902,82702594620,89814207934,41861477953,
                                6105366990,883535912,2431579913,811991989,4414574951,882960911,9683460909,
                                8799411970,8910644940,3855509956,85423971934,29406404915,5097293983,65712129949,
                                451117905,81797524968,66485339949,96427930915,2348932903,81722036915,94679355972,
                                8455024925,11214706967,31783056886,965280950,2840162091,12338968905,9981256951,
                                1987003934,81221967991,965280950,83345914972,11306420970,4637604923,2639903977,
                                48066516991,79426271953,57338337934,966841000,12134023953,363893903,75370140944,
                                86388479987,89779932968,1461202990,8150070940,6059576907,8695399907,5460979951,
                                3637718910,69305129900,3208065965,41806506904,9203847901,10111717914,93580088904,
                                550588922,2057038955,1879627906,81797524968,2353893902,2703926960,94865426949,
                                6059576907,53834062987,4744666981,83446079904,83809066915,46823778091,4744666981,
                                4844161970,4301243925,4241968910,9585369966,69052298904,1602644993,89820410959,
                                4897774900,8747434945,9100341924,9012530903,128154039,674073908,6937228945,
                                5619992950,435162977,3747713912,4028592941,7949631961,70137013949,10238013960,
                                5324096989,4241972942,655610901,7963000973,89814207934,12629877922,383456924,
                                2898930970,4747622977,8488521928,8150070940,7310377907,58439250991,3282755902,
                                8190166913,53834062987,59529814968,4487491908,66485339949,5649989907,6041536946,
                                3927690937,73277070930,9228998946,2353893902,31032028904,89525051900,94679983949,
                                8728183908,61352543915,75302845920,69368945934,5979988920,57960330930,1970134909,
                                83391940972,90273982915,6096049966,3351888937,2998019935,5736903911,48928127904,
                                71553681991,83808566949,89602625953,96959835968,3564257977,85423971934,53337565972,
                                8794309906,2353951961,3783297907,1438894945,95167552915,2840162091,11326901966,
                                5649989907,72043628968,38380331087,8298151984,3799851950,967972906,70309116953,
                                89820410959,18091954972,83363351968,2948457980,1602644993,2631468988,61352543915,
                                1855788969,452703921,596575963,1242166092,81221967991,4830852941,394143965,
                                435162977,4352962996,77208595968,7963000973,92865984915,10525671935,98370812953,
                                81712898949,9585369966,62579363904,65186451991,9918403640,1008130974,41861477953,
                                82470120063,94656657972,8925175908,8291495971,50114913900,1698191910,1602644993,
                                8291495971,71552669904,52555267972,4400126943,95151575953,81722036915,37935291934)
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
