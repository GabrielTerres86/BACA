DECLARE

  vr_arq_path            VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/ptask0011925/arquivos';
  vr_rollback_path       VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/ptask0011925';
  vr_prefarq101          VARCHAR2(100) := 'APCS101_%';
  vr_listaArq101         VARCHAR2(4000);
  vr_tab_arq101          CECRED.GENE0002.typ_split;
  vr_clob101             CLOB;
  vr_prefarq102          VARCHAR2(100) := 'APCS102_%';
  vr_listaArq102         VARCHAR2(4000);
  vr_tab_arq102          CECRED.GENE0002.typ_split;
  vr_clob102             CLOB;
  vr_rollback104         VARCHAR2(4000);
  vr_dscriticGeral       cecred.crapcri.dscritic%type;
  vr_cdcooper            cecred.crapcop.cdcooper%type;
  vr_nrdconta            cecred.crapass.nrdconta%type;
  vr_nmarqbkp            VARCHAR2(100) := 'PTASK0011925_script_rollback.sql';
  vr_nmarqcri            VARCHAR2(100) := 'PTASK0011925_script_log.txt';

  vr_dsdominioerro       CONSTANT VARCHAR2(20) := 'ERRO_PCPS_CIP';
  vr_dsmotivoreprv       CONSTANT VARCHAR2(30) := 'MOTVREPRVCPORTDDCTSALR';
  vr_dsmotivoaceite      CONSTANT VARCHAR2(30) := 'MOTVACTECOMPRIOPORTDDCTSALR';
  vr_datetimeformat      CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS';
  vr_dsmasklog           CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
  
  vr_des_rollback_xml    CLOB;
  vr_texto_rb_completo   VARCHAR2(32600);
  vr_des_critic_xml      CLOB;
  vr_texto_cri_completo  VARCHAR2(32600);

  vr_exc_erro            EXCEPTION;
  vr_exc_clob            EXCEPTION;
  vr_des_erroGeral       VARCHAR2(4000);

  CURSOR cr_201 is
    SELECT t.cdcooper,
           t.nrdconta,
           t.nrsolicitacao,
           t.dtsolicitacao,
           t.nrcpfcgc,
           t.nmprimtl,
           t.nrddd_telefone,
           t.nrtelefone,
           t.dsdemail,
           t.cdbanco_folha,
           t.cdagencia_folha,
           t.nrispb_banco_folha,
           t.nrcnpj_banco_folha,
           t.nrcnpj_empregador,
           t.dsnome_empregador,
           t.nrispb_destinataria,
           t.nrcnpj_destinataria,
           t.cdtipo_conta,
           t.cdagencia,
           t.idsituacao,
           t.nrnu_portabilidade,
           t.dtretorno,
           t.dsdominio_motivo,
           t.cdmotivo,
           t.cdoperador,
           t.nmarquivo_envia,
           t.nmarquivo_retorno,
           t.dtassina_eletronica,
           t.idseqttl,
           t.tppessoa_empregador
      FROM CECRED.tbcc_portabilidade_envia t
     WHERE t.nrnu_portabilidade = '202304060000256562416';

  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_rollback_xml, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_critica(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    CECRED.gene0002.pc_escreve_xml(vr_des_critic_xml, vr_texto_cri_completo, pr_des_dados, pr_fecha_xml);
  END;

  FUNCTION fn_remove_xmlns(pr_dsxmlarq IN CLOB) RETURN CLOB IS
    vr_dsremove  VARCHAR2(1000);
    vr_nrposant  NUMBER;
    vr_nrposdep  NUMBER;
  BEGIN
    vr_nrposant := INSTR(pr_dsxmlarq,'xmlns=');
    vr_nrposdep := INSTR(pr_dsxmlarq,'>',vr_nrposant);
    vr_dsremove := SUBSTR(pr_dsxmlarq, vr_nrposant, (vr_nrposdep - vr_nrposant));
    RETURN REPLACE(pr_dsxmlarq,vr_dsremove,NULL);
  END fn_remove_xmlns;
  
  PROCEDURE pc_proc_ERR_APCS101(pr_dsxmlarq  IN CLOB
                               ,pr_dscritic OUT VARCHAR2) IS
    CURSOR cr_ret_erro(pr_dsxmlarq  CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , cderrret
        FROM DATA 
           , XMLTABLE('/APCSDOC/BCARQ'
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , cderrret  VARCHAR2(10)  PATH 'NomArq/@CodErro');
    CURSOR cr_101(pr_nmarqenv VARCHAR2) IS
      SELECT t.dsdominio_motivo
            ,t.cdmotivo
            ,t.idsituacao
            ,t.nmarquivo_retorno
            ,t.nrnu_portabilidade
            ,t.rowid
        FROM cecred.tbcc_portabilidade_envia t
       WHERE t.idsituacao       = 2
       AND t.nmarquivo_envia  = pr_nmarqenv;
    vr_dsarqxml      CLOB;
    vr_nmarquiv      VARCHAR2(100);
    vr_nmarqenv      VARCHAR2(100);
    vr_cderrret      VARCHAR2(10);
  BEGIN
    vr_dsarqxml := fn_remove_xmlns(pr_dsxmlarq);
    OPEN  cr_ret_erro(vr_dsarqxml);
    FETCH cr_ret_erro INTO vr_nmarquiv
                         , vr_cderrret;
    IF cr_ret_erro%NOTFOUND THEN
      pr_dscritic := 'Não foi possível extrair conteúdo do arquivo.';
      CLOSE cr_ret_erro;
      RETURN;
    END IF;
    CLOSE cr_ret_erro;
    
    vr_nmarqenv := REPLACE(vr_nmarquiv, '_ERR', NULL);
    
    FOR rg_101 in cr_101(vr_nmarqenv) LOOP
      pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_envia   T' || chr(10) ||
                              '   SET t.dsdominio_motivo = ''' || nvl(rg_101.dsdominio_motivo,'') || '''' || chr(10) ||
                              '     , t.cdmotivo         = ''' || nvl(rg_101.cdmotivo,'') || '''' || chr(10) ||
                              '     , t.idsituacao       = 2' || chr(10) ||
                              '     , t.nmarquivo_retorno= ''' || nvl(rg_101.nmarquivo_retorno,'') || '''' || chr(10) ||
                              ' WHERE t.rowid = ''' || rg_101.rowid || ''';' || chr(10) || chr(10));      
    END LOOP;
    
    UPDATE cecred.tbcc_portabilidade_envia   T
       SET t.dsdominio_motivo = vr_dsdominioerro
         , t.cdmotivo         = vr_cderrret
         , t.idsituacao       = 1
         , t.nmarquivo_retorno= vr_nmarquiv
     WHERE t.idsituacao       = 2
       AND t.nmarquivo_envia  = vr_nmarqenv;
    pc_escreve_xml_critica('Arquivo ' || vr_nmarquiv || ' - Quantidade registros atualizados: ' || sql%rowcount || chr(10));   
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_ERR_APCS101. ' ||SQLERRM;
  END pc_proc_ERR_APCS101;

  PROCEDURE pc_proc_XML_APCS102(pr_dsxmlarq  IN CLOB
                               ,pr_dscritic OUT VARCHAR2) IS
                               
    vr_dsapcsdoc     CONSTANT VARCHAR2(10) := 'APCS102';
    CURSOR cr_dadosret(pr_dsxmlarq CLOB) IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nridenti
           , nrnuport
           , nrcpfcgc
           , dsnomcli
           , dstelefo
           , dsdemail
           , nrispbfl
           , nrcnpjfl
           , tppesepr
           , nrdocepr
           , nmdoempr
           , nrispbdt
           , nrcnpjdt
           , cdtipcta
           , cdagedst
           , nrctadst
           , nrctapgt
        FROM DATA
           , XMLTABLE(('/APCSDOC/SISARQ/'||vr_dsapcsdoc||'/Grupo_'||vr_dsapcsdoc||'_PortddCtSalr')
                      PASSING XMLTYPE(xml)
                      COLUMNS nridenti  NUMBER       PATH 'IdentdPartAdmtd'
                            , nrnuport  NUMBER       PATH 'NUPortddPCS'
                            , nrcpfcgc  NUMBER       PATH 'Grupo_APCS102_Cli/CPFCli'
                            , dsnomcli  VARCHAR2(80) PATH 'Grupo_APCS102_Cli/NomCli'
                            , dstelefo  VARCHAR2(20) PATH 'Grupo_APCS102_Cli/TelCli'
                            , dsdemail  VARCHAR2(50) PATH 'Grupo_APCS102_Cli/EmailCli'
                            , nrispbfl  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/ISPBPartFolhaPgto'
                            , nrcnpjfl  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/CNPJPartFolhaPgto'
                            , tppesepr  VARCHAR2(5)  PATH 'Grupo_APCS102_FolhaPgto/TpPessoaEmprdr'
                            , nrdocepr  NUMBER       PATH 'Grupo_APCS102_FolhaPgto/CNPJ_CPFEmprdr'
                            , nmdoempr  VARCHAR2(50) PATH 'Grupo_APCS102_FolhaPgto/DenSocEmprdr'
                            , nrispbdt  NUMBER       PATH 'Grupo_APCS102_Dest/ISPBPartDest'
                            , nrcnpjdt  NUMBER       PATH 'Grupo_APCS102_Dest/CNPJPartDest'
                            , cdtipcta  VARCHAR2(5)  PATH 'Grupo_APCS102_Dest/TpCtDest'
                            , cdagedst  NUMBER       PATH 'Grupo_APCS102_Dest/AgCliDest'
                            , nrctadst  NUMBER       PATH 'Grupo_APCS102_Dest/CtCliDest'
                            , nrctapgt  NUMBER       PATH 'Grupo_APCS102_Dest/CtPagtoDest' );

    CURSOR cr_portab(pr_nrnuport  tbcc_portabilidade_envia.nrnu_portabilidade%TYPE) IS
      SELECT t.nrnu_portabilidade
           , ROWID   dsdrowid
        FROM cecred.tbcc_portabilidade_envia t
       WHERE t.nrnu_portabilidade = pr_nrnuport;
    rg_portab   cr_portab%ROWTYPE;
    
    CURSOR cr_crapass(pr_nrcpfcgc IN NUMBER) IS
      SELECT t.cdcooper
           , t.nrdconta
           , x.cdmodalidade_tipo cdmodali
           , COUNT(*) OVER (PARTITION BY 1) idqtdreg
        FROM cecred.tbcc_tipo_conta x 
           , cecred.crapass         t
       WHERE t.inpessoa = x.inpessoa
         AND t.cdtipcta = x.cdtipo_conta
         AND t.nrcpfcgc = pr_nrcpfcgc
         AND t.dtdemiss IS NULL;
     rg_crapass  cr_crapass%ROWTYPE;
    
    CURSOR cr_crapttl(pr_cdcooper  crapttl.cdcooper%TYPE
                     ,pr_nrdconta  crapttl.nrdconta%TYPE) IS
      SELECT t.nrcpfemp
           , t.nmextemp
        FROM cecred.crapttl t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.idseqttl = 1;
    rg_crapttl   cr_crapttl%ROWTYPE;
    
    vr_dsxmlarq     CLOB;
    vr_dscritic     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    vr_tppesepr     NUMBER;
    
    vr_cdcooper     cecred.crapass.cdcooper%TYPE;
    vr_nrdconta     cecred.crapass.nrdconta%TYPE;
    vr_cdagedst     cecred.tbcc_portabilidade_recebe.cdagencia_destinataria%TYPE;
    vr_nrctadst     cecred.tbcc_portabilidade_recebe.nrdconta_destinataria%TYPE;
    vr_idsituac     cecred.tbcc_portabilidade_recebe.idsituacao%TYPE;
    vr_dsdomrep     cecred.tbcc_portabilidade_recebe.dsdominio_motivo%TYPE;
    vr_cdcodrep     cecred.tbcc_portabilidade_recebe.cdmotivo%TYPE;
    vr_dtavalia     cecred.tbcc_portabilidade_recebe.dtavaliacao%TYPE;
    vr_cdoperad     cecred.tbcc_portabilidade_recebe.cdoperador%TYPE;
    vr_exc_erro     EXCEPTION;

    PROCEDURE pc_extrai_dados_arq(pr_dsxmlarq  IN CLOB
                                 ,pr_nmarquiv OUT VARCHAR2
                                 ,pr_dtarquiv OUT DATE) IS
      CURSOR cr_dados IS
        WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
        SELECT nmarquiv
             , to_date(dtarquiv, vr_datetimeformat) dtarquiv
          FROM DATA
             , XMLTABLE(('APCSDOC/BCARQ')
                        PASSING XMLTYPE(xml)
                        COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                              , dtarquiv  VARCHAR2(50)  PATH 'DtHrArq' );
     
    BEGIN
      OPEN  cr_dados;
      FETCH cr_dados INTO pr_nmarquiv 
                        , pr_dtarquiv;
      CLOSE cr_dados;                 
       
    END pc_extrai_dados_arq;
        
  BEGIN
    
    vr_dsxmlarq := fn_remove_xmlns(pr_dsxmlarq);
    
    pc_extrai_dados_arq(pr_dsxmlarq => vr_dsxmlarq
                       ,pr_nmarquiv => vr_nmarquiv
                       ,pr_dtarquiv => vr_dtarquiv);
    
    FOR rg_dadosret IN cr_dadosret(vr_dsxmlarq) LOOP
      vr_cdcooper := NULL;
      vr_nrdconta := NULL;
      vr_idsituac := 1;
      vr_dsdomrep := NULL;
      vr_cdcodrep := NULL; 
      vr_dtavalia := NULL;
      vr_cdoperad := NULL;
      rg_crapttl  := NULL;
    
      OPEN  cr_portab(rg_dadosret.nrnuport);
      FETCH cr_portab INTO rg_portab;
      
      IF cr_portab%FOUND THEN
        pc_escreve_xml_critica(to_char(sysdate,vr_dsmasklog)||' - '
                       || 'PCPS0002.pc_proc_xml_APCS104'
                       || ' >>> NU Portabilidade já existe na base de dados: '||rg_dadosret.nrnuport || chr(10));
        CLOSE cr_portab;
        CONTINUE;
      END IF;
      
      CLOSE cr_portab;
      
      OPEN  cr_crapass(rg_dadosret.nrcpfcgc);
      FETCH cr_crapass INTO rg_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        vr_cdcooper := 3;
        vr_nrdconta := 0;
        vr_idsituac := 3;
        vr_dsdomrep := vr_dsmotivoreprv;
        vr_cdcodrep := 2;
        vr_dtavalia := SYSDATE;
        vr_cdoperad := '1';
      END IF;

      CLOSE cr_crapass;
      
      IF NVL(rg_crapass.idqtdreg,0) = 0 OR NVL(rg_crapass.idqtdreg,0) > 1 THEN
        vr_cdcooper := 3;
        vr_nrdconta := 0;
      ELSE
                      
        vr_cdcooper := rg_crapass.cdcooper;
        vr_nrdconta := rg_crapass.nrdconta;
      
        OPEN  cr_crapttl(vr_cdcooper
                        ,vr_nrdconta);
        FETCH cr_crapttl INTO rg_crapttl;
        
        IF cr_crapttl%NOTFOUND OR rg_crapttl.nrcpfemp IS NULL THEN
          vr_idsituac := 3;
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 1;
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;       
        
        CLOSE cr_crapttl;   
        
        IF rg_crapttl.nrcpfemp <> rg_dadosret.nrdocepr  THEN
          vr_idsituac := 3;
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 3;
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;
        
        IF rg_crapass.cdmodali <> 2 THEN
          vr_idsituac := 3;
          vr_dsdomrep := vr_dsmotivoreprv;
          vr_cdcodrep := 7;
          vr_dtavalia := SYSDATE;
          vr_cdoperad := '1';
        END IF;
        
      END IF;
      
      IF rg_dadosret.cdtipcta = 'PG' THEN
        vr_cdagedst := 0;
        vr_nrctadst := rg_dadosret.nrctapgt;
      ELSE 
        vr_cdagedst := rg_dadosret.cdagedst;
        vr_nrctadst := rg_dadosret.nrctadst;
      END IF;
      
      IF rg_dadosret.tppesepr = 'F' THEN
        vr_tppesepr := 1;
      ELSE 
        vr_tppesepr := 2;
      END IF;
      
      BEGIN
        INSERT INTO cecred.tbcc_portabilidade_recebe
                          (nrnu_portabilidade
                          ,cdcooper
                          ,nrdconta
                          ,nrcpfcgc
                          ,nmprimtl
                          ,dstelefone
                          ,dsdemail
                          ,nrispb_banco_folha
                          ,nrcnpj_banco_folha
                          ,tppessoa_empregador
                          ,nrcnpj_empregador
                          ,dsnome_empregador
                          ,nrispb_destinataria
                          ,nrcnpj_destinataria
                          ,cdtipo_cta_destinataria
                          ,cdagencia_destinataria
                          ,nrdconta_destinataria
                          ,dtsolicitacao
                          ,idsituacao
                          ,dtavaliacao
                          ,dsdominio_motivo
                          ,cdmotivo
                          ,cdoperador
                          ,nmarquivo_solicitacao)
                   VALUES (rg_dadosret.nrnuport
                          ,vr_cdcooper         
                          ,vr_nrdconta         
                          ,rg_dadosret.nrcpfcgc
                          ,rg_dadosret.dsnomcli
                          ,rg_dadosret.dstelefo
                          ,rg_dadosret.dsdemail
                          ,rg_dadosret.nrispbfl
                          ,rg_dadosret.nrcnpjfl
                          ,vr_tppesepr         
                          ,rg_dadosret.nrdocepr
                          ,rg_dadosret.nmdoempr
                          ,rg_dadosret.nrispbdt
                          ,rg_dadosret.nrcnpjdt
                          ,rg_dadosret.cdtipcta
                          ,vr_cdagedst         
                          ,vr_nrctadst         
                          ,vr_dtarquiv         
                          ,vr_idsituac         
                          ,vr_dtavalia         
                          ,vr_dsdomrep         
                          ,vr_cdcodrep         
                          ,vr_cdoperad         
                          ,vr_nmarquiv);       
                 
      
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de portabilidade: '||SQLERRM;
          vr_dscritic := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_proc_xml_APCS102'
                           || ' >>> Erro ao incluir registro de portabilidade: '||rg_dadosret.nrnuport||' - ' ||SQLERRM;
          RAISE vr_exc_erro;
      END;
      pc_escreve_xml_critica('Arquivo ' || vr_nmarquiv || ' - Inserido ' || sql%rowcount || ' registro.' || chr(10));   
      pc_escreve_xml_rollback('DELETE FROM cecred.tbcc_portabilidade_recebe t where t.NRNU_PORTABILIDADE = ' || to_char(rg_dadosret.nrnuport) || ';' || chr(10));
    END LOOP;
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Erro na rotina PCPS.pc_proc_xml_APCS102. ' ||SQLERRM;
  END pc_proc_xml_APCS102;  
  
BEGIN
  
  vr_des_rollback_xml := NULL;
  dbms_lob.createtemporary(vr_des_rollback_xml, TRUE);
  dbms_lob.open(vr_des_rollback_xml, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_critic_xml := NULL;
  dbms_lob.createtemporary(vr_des_critic_xml, TRUE);
  dbms_lob.open(vr_des_critic_xml, dbms_lob.lob_readwrite);
  vr_texto_cri_completo := NULL;
  
  cecred.gene0001.pc_lista_arquivos(pr_path     => vr_arq_path
                                   ,pr_pesq     => vr_prefarq101
                                   ,pr_listarq  => vr_listaArq101
                                   ,pr_des_erro => vr_dscriticGeral);
  IF TRIM(vr_dscriticGeral) IS NOT NULL THEN
    vr_dscriticGeral := 'Erro na leitura dos arquivos -> '||vr_dscriticGeral;
    pc_escreve_xml_critica(vr_dscriticGeral || chr(10) || chr(10)); 
  END IF;
  
  vr_tab_arq101 := CECRED.GENE0002.fn_quebra_string(pr_string => vr_listaArq101);

  IF vr_tab_arq101.count > 0 THEN
    pc_escreve_xml_critica('###################### Início loop arquivos APCS101* - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));
    FOR idx IN vr_tab_arq101.FIRST..vr_tab_arq101.LAST LOOP
      vr_clob101 := cecred.gene0002.fn_arq_para_clob(pr_caminho => vr_arq_path, pr_arquivo => vr_tab_arq101(idx));
      pc_proc_ERR_APCS101(vr_clob101, vr_dscriticGeral);  
      IF vr_dscriticGeral IS NOT NULL THEN
        pc_escreve_xml_critica(vr_dscriticGeral); 
      END IF;    
    END LOOP;
    pc_escreve_xml_critica('###################### Fim loop arquivos APCS101* - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));
  ELSE
    pc_escreve_xml_critica('Sem arquivos APCS101'||chr(10)); 
  END IF;  

  pc_escreve_xml_critica('###################### Início loop Registros APCS103* - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));
  FOR rg_103 in (SELECT t.rowid
                       ,t.dtretorno
                       ,t.nrnu_portabilidade
                   FROM cecred.tbcc_portabilidade_recebe t
                  WHERE t.idsituacao  IN (2,3)
                    AND t.dtavaliacao is not NULL
                    AND t.nrnu_portabilidade in (202305150000260364251,202305150000260367533,202305110000260124049,202305110000260124261,202305110000260149942
                                                ,202305120000260206561,202305120000260207393,202305120000260210772,202305120000260214115,202305120000260237224
                                                ,202305120000260239253,202305080000259600387,202305080000259600129,202305110000260046529,202305110000260102303
                                                ,202305110000260103738,202305110000260112874,202305110000260163479,202305120000260245974,202305120000260305114
                                                ,202305150000260372589,202305150000260373098,202305090000259783177,202305150000260374550,202305150000260412723
                                                ,202305150000260461248,202305160000260550336,202305160000260550483,202305160000260550283,202305160000260551051
                                                ,202305160000260551830,202305160000260552016,202305160000260552102,202305160000260553324,202305190000261036350
                                                ,202305170000260708045,202305170000260708976,202305170000260709050,202305190000261031507,202305190000261031583
                                                ,202305190000261035230,202305170000260794132,202305170000260795210,202305170000260795672,202305170000260801560
                                                ,202305190000261072071,202305190000261074819,202305190000261075205,202305190000261075255,202305190000261077378
                                                ,202305190000261077381,202305190000261079297,202305190000261079611,202305160000260586412,202305160000260588245
                                                ,202305160000260588629,202305160000260590730,202305160000260592186,202305160000260634989,202305160000260635064
                                                ,202305160000260635645,202305160000260636237,202305160000260637967,202305160000260638103,202305160000260638172
                                                ,202305160000260595410,202305160000260596246,202305160000260597764,202305160000260639398,202305160000260539151
                                                ,202305160000260539819,202305160000260539875,202305160000260540359,202305160000260541816,202305160000260542346
                                                ,202305160000260543344,202305160000260544545,202305160000260544606,202305160000260545117,202305160000260545045
                                                ,202305160000260545446,202305160000260545548,202305160000260545663,202305160000260546844,202305160000260547158
                                                ,202305170000260731288,202305170000260732857,202305170000260735991,202305160000260548177,202305190000261108480
                                                ,202305190000261113118,202305170000260700618,202305170000260701079,202305170000260701295,202305170000260701323
                                                ,202305170000260705765,202305170000260705957,202305170000260707314,202305170000260707122,202305160000260570243
                                                ,202305160000260574519,202305160000260575832,202305160000260575888,202305170000260766220,202305170000260767249
                                                ,202305170000260768986,202305160000260602695,202305160000260604526,202305170000260775696,202305170000260777602
                                                ,202305170000260777283,202305170000260777388,202305180000260934260,202305180000260935172,202305190000261037221
                                                ,202305190000261039239,202305150000260487322,202305150000260487442,202305150000260488290,202305170000260757403
                                                ,202305170000260757980,202305170000260762774,202305170000260763832,202305170000260764037,202305170000260764975
                                                ,202305170000260764979,202305170000260765084,202305180000260960718,202305180000260961546,202305180000260962500
                                                ,202305170000260748772,202305170000260748792,202305170000260750269,202305170000260750913,202305170000260753395
                                                ,202305170000260753559,202305170000260753718,202305180000260913186,202305180000260915901,202305180000260916054
                                                ,202305180000260917594,202305180000260920559,202305170000260739564,202305170000260746159,202305160000260655360
                                                ,202305160000260655388,202305160000260655906,202305160000260656087,202305160000260629549,202305160000260632527
                                                ,202305190000261103774,202305180000260888329,202305180000260900021,202305180000260905474,202305180000260907926
                                                ,202305180000260909060,202305180000260910381,202305180000260910992,202305180000260911490,202305160000260609755
                                                ,202305160000260610171,202305160000260610185,202305160000260611088,202305160000260611145,202305160000260612728
                                                ,202305160000260612561,202305190000261044768,202305190000261046935,202305180000260922470,202305180000260926185
                                                ,202305180000260932661,202305190000261028141,202305190000261028774,202305190000261028904,202305170000260709054
                                                ,202305170000260709594,202305170000260710774,202305160000260577964,202305160000260581295,202305160000260581467
                                                ,202305160000260582404,202305180000260864952,202305180000260865261,202305180000260865370,202305180000260865636
                                                ,202305180000260866129,202305180000260866399,202305180000260867526,202305180000260867556,202305180000260868122
                                                ,202305180000260868126,202305180000260868322,202305180000260868280,202305180000260868627,202305180000260870094
                                                ,202305180000260870216,202305180000260871999,202305190000261087315,202305190000261089050,202305170000260818064
                                                ,202305170000260821037,202305170000260821022,202305170000260820140,202305170000260819957,202305170000260820704
                                                ,202305170000260820191,202305170000260823772,202305170000260824172,202305180000260969209,202305180000260970819
                                                ,202305190000261095274,202305190000261097738,202305170000260805632,202305170000260806636,202305170000260806804
                                                ,202305170000260808946,202305180000260943384,202305180000260943511,202305180000260945658,202305160000260646944
                                                ,202305160000260652085,202305160000260652440,202305160000260652966,202305160000260653039,202305180000260986360
                                                ,202305180000260987835,202305180000260873343,202305180000260874433,202305180000260874164,202305180000260874580
                                                ,202305180000260874794,202305180000260875498,202305190000261036988,202305190000261036826)) LOOP                                                              
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_recebe t' ||chr(10)||
                          case
                            when rg_103.dtretorno IS NULL THEN
                              '   SET t.dtretorno = NULL'
                            else
                              '   SET t.dtretorno = to_date('''||to_char(rg_103.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end ||chr(10)||
                          ' WHERE t.rowid = '''||rg_103.rowid||''';'||chr(10)||chr(10));
    UPDATE cecred.tbcc_portabilidade_recebe t
         SET t.dtretorno = NULL
       WHERE t.rowid = rg_103.rowid;
    pc_escreve_xml_critica('Registro Portabilidade ' || to_char(rg_103.nrnu_portabilidade) || ' - atualizado: ' || sql%rowcount || chr(10));    
  END LOOP;   
  pc_escreve_xml_critica('###################### Fim loop Registros APCS103* - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));
                                                              

  vr_dscriticGeral := null;
  cecred.gene0001.pc_lista_arquivos(pr_path     => vr_arq_path
                                   ,pr_pesq     => vr_prefarq102
                                   ,pr_listarq  => vr_listaArq102
                                   ,pr_des_erro => vr_dscriticGeral);
  IF TRIM(vr_dscriticGeral) IS NOT NULL THEN
    vr_dscriticGeral := 'Erro na leitura dos arquivos -> '||vr_dscriticGeral;
    dbms_output.put_line(vr_dscriticGeral); 
  END IF;
  
  vr_tab_arq102 := CECRED.GENE0002.fn_quebra_string(pr_string => vr_listaArq102);

  IF vr_tab_arq102.count > 0 THEN
    pc_escreve_xml_critica('###################### Início loop arquivos APCS102* - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));    
    FOR idx IN vr_tab_arq102.FIRST..vr_tab_arq102.LAST LOOP
      vr_clob102 := cecred.gene0002.fn_arq_para_clob(pr_caminho => vr_arq_path, pr_arquivo => vr_tab_arq102(idx));
      pc_proc_xml_APCS102(vr_clob102, vr_dscriticGeral);      
      IF vr_dscriticGeral IS NOT NULL THEN
        dbms_output.put_line(vr_dscriticGeral); 
      END IF;    
    END LOOP;
    pc_escreve_xml_critica('###################### Fim loop arquivos APCS102* - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));    
  ELSE
    pc_escreve_xml_critica('Sem arquivos APCS102' ||chr(10)); 
  END IF;         

  pc_escreve_xml_critica('###################### Início ajustes arquivo APCS104_05463212_20230519_00064' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10)); 

  vr_rollback104 := null;
  select 'UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
         '   SET t.idsituacao        = ' || to_char(t.idsituacao) || chr(10) ||
         '      ,t.dsdominio_motivo  = ''' || nvl(t.dsdominio_motivo,'') || '''' || chr(10) ||
         '      ,t.cdmotivo          = ''' || nvl(t.cdmotivo,'') || '''' || chr(10) ||
         case
           when t.dtretorno IS NULL THEN
             '      ,t.dtretorno = NULL'
           else
             '      ,t.dtretorno = to_date('''||to_char(t.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
         end || chr(10) ||
         ' ,t.nmarquivo_retorno = ''' || nvl(t.nmarquivo_retorno,'') || '''' || chr(10) ||
         ' WHERE t.nrnu_portabilidade = 202305120000260295561;'
    into vr_rollback104
    from cecred.tbcc_portabilidade_envia  t
   where t.nrnu_portabilidade = 202305120000260295561;
  pc_escreve_xml_rollback(vr_rollback104 || chr(10) ||chr(10));
   
  UPDATE cecred.tbcc_portabilidade_envia  t
     SET t.idsituacao        = 3
       , t.dsdominio_motivo  = NULL
       , t.cdmotivo          = NULL
       , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
       , t.nmarquivo_retorno = 'APCS104_05463212_20230519_00064'
   WHERE t.nrnu_portabilidade = 202305120000260295561;
  pc_escreve_xml_critica('Registro Portabilidade 202305120000260295561 - Atualizado ' || sql%rowcount || ' registros.' || chr(10));

  vr_rollback104 := null;
  select 'UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
         '   SET t.idsituacao        = ' || to_char(t.idsituacao) || chr(10) ||
         '      ,t.dsdominio_motivo  = ''' || nvl(t.dsdominio_motivo,'') || '''' || chr(10) ||
         '      ,t.cdmotivo          = ''' || nvl(t.cdmotivo,'') || '''' || chr(10) ||
         case
           when t.dtretorno IS NULL THEN
             '      ,t.dtretorno = NULL'
           else
             '      ,t.dtretorno = to_date('''||to_char(t.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
         end || chr(10) ||
         '      ,t.nmarquivo_retorno = ''' || nvl(t.nmarquivo_retorno,'') || '''' || chr(10) ||
         ' WHERE t.nrnu_portabilidade = 202305150000260434908;'
    into vr_rollback104
    from cecred.tbcc_portabilidade_envia  t
   where t.nrnu_portabilidade = 202305150000260434908;
  pc_escreve_xml_rollback(vr_rollback104 || chr(10) ||chr(10));   
  
  UPDATE cecred.tbcc_portabilidade_envia  t
     SET t.idsituacao        = 4
       , t.dsdominio_motivo  = vr_dsmotivoreprv
       , t.cdmotivo          = 6
       , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
       , t.nmarquivo_retorno = 'APCS104_05463212_20230519_00064'
   WHERE t.nrnu_portabilidade = 202305150000260434908;   
  pc_escreve_xml_critica('Registro Portabilidade 202305150000260434908 - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  
  pc_escreve_xml_critica('###################### Fim ajustes arquivo APCS104_05463212_20230519_00064' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10)); 

   
  pc_escreve_xml_critica('###################### Início ajustes arquivo APCS104_05463212_20230519_00065' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));
  
  for rg_104 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.nmarquivo_retorno
                   from cecred.tbcc_portabilidade_envia t 
                  where t.nrnu_portabilidade in (202305080000259546581
                                                ,202305080000259592682
                                                ,202305080000259592685
                                                ,202305080000259607157
                                                ,202305080000259607160
                                                ,202305080000259607162
                                                ,202305080000259607167
                                                ,202305080000259607168
                                                ,202305080000259607172
                                                ,202305080000259616108
                                                ,202305080000259616113
                                                ,202305080000259623006
                                                ,202305080000259637227
                                                ,202305080000259637248
                                                ,202305080000259637280
                                                ,202305080000259637434
                                                ,202305080000259646130
                                                ,202305080000259646134
                                                ,202305080000259646135
                                                ,202305080000259646139
                                                ,202305080000259646143
                                                ,202305080000259646147
                                                ,202305080000259659046
                                                ,202305080000259659047
                                                ,202305080000259670566)) loop   

  pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
                          '   SET t.idsituacao        = ' || to_char(rg_104.idsituacao) || chr(10) ||
                          '      ,t.dsdominio_motivo  = ''' || nvl(rg_104.dsdominio_motivo,'') || '''' || chr(10) ||
                          '      ,t.cdmotivo          = ''' || nvl(rg_104.cdmotivo,'') || '''' || chr(10) ||
                          case
                            when rg_104.dtretorno IS NULL THEN
                              '      ,t.dtretorno = NULL'
                            else
                              '      ,t.dtretorno = to_date('''||to_char(rg_104.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                          end || chr(10) ||
                          '      ,t.nmarquivo_retorno = ''' || nvl(rg_104.nmarquivo_retorno,'') || '''' || chr(10) ||
                          ' WHERE t.nrnu_portabilidade = ' || to_char(rg_104.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
  
    UPDATE cecred.tbcc_portabilidade_envia  t
       SET t.idsituacao        = 3
         , t.dsdominio_motivo  = NULL
         , t.cdmotivo          = NULL
         , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
         , t.nmarquivo_retorno = 'APCS104_05463212_20230519_00065'
     WHERE t.nrnu_portabilidade = rg_104.nrnu_portabilidade;
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_104.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));

  end loop;
  pc_escreve_xml_critica('###################### Fim ajustes arquivo APCS104_05463212_20230519_00065' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10)); 


  pc_escreve_xml_critica('###################### Início ajustes arquivo APCS104_05463212_20230519_00071' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));   
  for rg_104 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.nmarquivo_retorno
                   from cecred.tbcc_portabilidade_envia t 
                  where t.nrnu_portabilidade in (202305090000259803384
                                                ,202305090000259837365
                                                ,202305090000259827561
                                                ,202305090000259768095
                                                ,202305090000259768094
                                                ,202305090000259768089
                                                ,202305090000259768083
                                                ,202305090000259768077
                                                ,202305090000259760036
                                                ,202305090000259760010
                                                ,202305090000259751468
                                                ,202305090000259751462
                                                ,202305090000259803392
                                                ,202305090000259803372
                                                ,202305090000259803393
                                                ,202305090000259811958
                                                ,202305090000259787248
                                                ,202305090000259778523)) loop   

  pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
                          '   SET t.idsituacao        = ' || to_char(rg_104.idsituacao) || chr(10) ||
                          '      ,t.dsdominio_motivo  = ''' || nvl(rg_104.dsdominio_motivo,'') || '''' || chr(10) ||
                          '      ,t.cdmotivo          = ''' || nvl(rg_104.cdmotivo,'') || '''' || chr(10) ||
                          case
                            when rg_104.dtretorno IS NULL THEN
                              '      ,t.dtretorno = NULL'
                            else
                              '      ,t.dtretorno = to_date('''||to_char(rg_104.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                          end || chr(10) ||
                          '      ,t.nmarquivo_retorno = ''' || nvl(rg_104.nmarquivo_retorno,'') || '''' || chr(10) ||
                          ' WHERE t.nrnu_portabilidade = ' || to_char(rg_104.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
      UPDATE cecred.tbcc_portabilidade_envia  t
       SET t.idsituacao        = 3
         , t.dsdominio_motivo  = NULL
         , t.cdmotivo          = NULL
         , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
         , t.nmarquivo_retorno = 'APCS104_05463212_20230519_00071'
     WHERE t.nrnu_portabilidade = rg_104.nrnu_portabilidade;  
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_104.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop;  
  pc_escreve_xml_critica('###################### Fim ajustes arquivo APCS104_05463212_20230519_00071' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));   

  pc_escreve_xml_critica('###################### Início ajustes arquivo APCS104_05463212_20230519_00060' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));   
  for rg_104 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.nmarquivo_retorno
                   from cecred.tbcc_portabilidade_envia t 
                  where t.nrnu_portabilidade in (202305110000260107463
                                                ,202305110000260114965
                                                ,202305120000260259222
                                                ,202305120000260259227
                                                ,202305120000260266815
                                                ,202305120000260310028
                                                ,202305150000260372400
                                                ,202305150000260454801)) loop   

  pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
                          '   SET t.idsituacao        = ' || to_char(rg_104.idsituacao) || chr(10) ||
                          '      ,t.dsdominio_motivo  = ''' || nvl(rg_104.dsdominio_motivo,'') || '''' || chr(10) ||
                          '      ,t.cdmotivo          = ''' || nvl(rg_104.cdmotivo,'') || '''' || chr(10) ||
                          case
                            when rg_104.dtretorno IS NULL THEN
                              '      ,t.dtretorno = NULL'
                            else
                              '      ,t.dtretorno = to_date('''||to_char(rg_104.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                          end || chr(10) ||
                          '      ,t.nmarquivo_retorno = ''' || nvl(rg_104.nmarquivo_retorno,'') || '''' || chr(10) ||
                          ' WHERE t.nrnu_portabilidade = ' || to_char(rg_104.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
      UPDATE cecred.tbcc_portabilidade_envia  t
       SET t.idsituacao        = 3
         , t.dsdominio_motivo  = NULL
         , t.cdmotivo          = NULL
         , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
         , t.nmarquivo_retorno = 'APCS104_05463212_20230519_00060'
     WHERE t.nrnu_portabilidade = rg_104.nrnu_portabilidade;  
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_104.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop; 

  vr_rollback104 := null;
  select 'UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
         '   SET t.idsituacao        = ' || to_char(t.idsituacao) || chr(10) ||
         '      ,t.dsdominio_motivo  = ''' || nvl(t.dsdominio_motivo,'') || '''' || chr(10) ||
         '      ,t.cdmotivo          = ''' || nvl(t.cdmotivo,'') || '''' || chr(10) ||
         case
           when t.dtretorno IS NULL THEN
             '      ,t.dtretorno = NULL'
           else
             '      ,t.dtretorno = to_date('''||to_char(t.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
         end || chr(10) ||
         '      ,t.nmarquivo_retorno = ''' || nvl(t.nmarquivo_retorno,'') || '''' || chr(10) ||
         ' WHERE t.nrnu_portabilidade = 202305110000260134266;'
    into vr_rollback104
    from cecred.tbcc_portabilidade_envia  t
   where t.nrnu_portabilidade = 202305110000260134266;
  pc_escreve_xml_rollback(vr_rollback104 || chr(10) ||chr(10));   
   
  UPDATE cecred.tbcc_portabilidade_envia  t
     SET t.idsituacao        = 4
       , t.dsdominio_motivo  = vr_dsmotivoreprv
       , t.cdmotivo          = 11
       , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
       , t.nmarquivo_retorno = 'APCS104_05463212_20230519_00060'
   WHERE t.nrnu_portabilidade = 202305110000260134266;
  pc_escreve_xml_critica('Registro Portabilidade 202305110000260134266 - Atualizado ' || sql%rowcount || ' registros.' || chr(10));

  pc_escreve_xml_critica('###################### Fim ajustes arquivo APCS104_05463212_20230519_00060' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));   


  pc_escreve_xml_critica('###################### Início loop Registros APCS108_05463212_20230519_00073 - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
  for rg_108 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.dtavaliacao
                       ,t.nmarquivo_resposta
                    from cecred.tbcc_portabilidade_recebe t
                   where t.nrnu_portabilidade in (202305080000259529163
                                                 ,202305080000259531025
                                                 ,202305080000259535211
                                                 ,202305080000259535256
                                                 ,202305080000259545279
                                                 ,202305080000259548265
                                                 ,202305080000259548750
                                                 ,202305080000259550530
                                                 ,202305080000259550919
                                                 ,202305080000259586578
                                                 ,202305080000259591400
                                                 ,202305080000259592787
                                                 ,202305080000259592937
                                                 ,202305080000259599919
                                                 ,202305080000259600129
                                                 ,202305080000259600387
                                                 ,202305080000259624381
                                                 ,202305080000259625860
                                                 ,202305080000259646814
                                                 ,202305080000259664540
                                                 ,202305080000259670504)) loop
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_recebe  t' || chr(10) ||
                            ' SET t.idsituacao        = ' || nvl(to_char(rg_108.idsituacao),'NULL') || chr(10) ||
                            ' ,t.dsdominio_motivo  = ''' || nvl(rg_108.dsdominio_motivo,'') || '''' || chr(10) ||
                            ' ,t.cdmotivo          = ''' || nvl(rg_108.cdmotivo,'') || '''' || chr(10) ||
                            case
                              when rg_108.dtretorno IS NULL THEN
                                ' ,t.dtretorno = NULL'
                              else
                                ' ,t.dtretorno = to_date('''||to_char(rg_108.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) ||
                            case
                              when rg_108.dtavaliacao IS NULL THEN
                                ' ,t.dtavaliacao = NULL'
                              else
                                ' ,t.dtavaliacao = to_date('''||to_char(rg_108.dtavaliacao,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) ||
                            ' ,t.nmarquivo_resposta = ''' || nvl(rg_108.nmarquivo_resposta,'') || '''' || chr(10) ||
                            ' WHERE t.nrnu_portabilidade = ' || to_char(rg_108.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
    
    UPDATE cecred.tbcc_portabilidade_recebe t
      SET t.idsituacao         = 2
        , t.dsdominio_motivo   = vr_dsmotivoaceite
        , t.cdmotivo           = 1
        , t.dtretorno          = to_date('19/05/2023','dd/mm/yyyy') 
        , t.dtavaliacao        = to_date('19/05/2023','dd/mm/yyyy') 
        , t.nmarquivo_resposta = 'APCS108_05463212_20230519_00073'
    WHERE t.nrnu_portabilidade =rg_108.nrnu_portabilidade;
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_108.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop;
  
  for rg_108 in (select t.nrnu_portabilidade
                       ,t.idsituacao
                       ,t.dsdominio_motivo
                       ,t.cdmotivo
                       ,t.dtretorno
                       ,t.nmarquivo_retorno
                    from cecred.tbcc_portabilidade_envia t
                   where t.nrnu_portabilidade in (202305080000259529163
                                                 ,202305080000259531025
                                                 ,202305080000259535211
                                                 ,202305080000259535256
                                                 ,202305080000259545279
                                                 ,202305080000259548265
                                                 ,202305080000259548750
                                                 ,202305080000259550530
                                                 ,202305080000259550919
                                                 ,202305080000259586578
                                                 ,202305080000259591400
                                                 ,202305080000259592787
                                                 ,202305080000259592937
                                                 ,202305080000259599919
                                                 ,202305080000259600129
                                                 ,202305080000259600387
                                                 ,202305080000259624381
                                                 ,202305080000259625860
                                                 ,202305080000259646814
                                                 ,202305080000259664540
                                                 ,202305080000259670504)) loop
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portabilidade_envia  t' || chr(10) ||
                            ' SET t.idsituacao        = ' || nvl(to_char(rg_108.idsituacao),'NULL') || chr(10) ||
                            ' ,t.dsdominio_motivo  = ''' || nvl(rg_108.dsdominio_motivo,'') || '''' || chr(10) ||
                            ' ,t.cdmotivo          = ''' || nvl(rg_108.cdmotivo,'') || '''' || chr(10) ||
                            case
                              when rg_108.dtretorno IS NULL THEN
                                ' ,t.dtretorno = NULL'
                              else
                                ' ,t.dtretorno = to_date('''||to_char(rg_108.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) ||
                            ' ,t.nmarquivo_retorno = ''' || nvl(rg_108.nmarquivo_retorno,'') || '''' || chr(10) ||
                            ' WHERE t.nrnu_portabilidade = ' || to_char(rg_108.nrnu_portabilidade) || ';' || chr(10) ||chr(10));   
                                
  UPDATE cecred.tbcc_portabilidade_envia t
    SET t.idsituacao        = 3
      , t.dsdominio_motivo  = vr_dsmotivoaceite
      , t.cdmotivo          = 1
      , t.dtretorno         = to_date('19/05/2023','dd/mm/yyyy') 
      , t.nmarquivo_retorno = 'APCS108_05463212_20230519_00073'
  WHERE t.nrnu_portabilidade = rg_108.nrnu_portabilidade;   
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_108.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop;
  pc_escreve_xml_critica('###################### Fim loop Registros APCS108_05463212_20230519_00073 - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
                                
  pc_escreve_xml_critica('###################### Início loop Registros APCS201_05463212_20230519_00551 - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
  FOR rg_201 in cr_201 LOOP
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portab_env_contestacao t' || chr(10) ||
                            '   SET t.idsituacao = ' || NVL(to_char(rg_201.idsituacao),'NULL') || chr(10) ||
                            ' WHERE t.cdcooper = ' || to_char(rg_201.cdcooper) || chr(10) || 
                            '   AND t.nrdconta = ' || to_char(rg_201.nrdconta) || chr(10) ||
                            '   AND t.nrsolicitacao = ' || to_char(rg_201.nrsolicitacao) || ';' || chr(10) || chr(10));                               
    UPDATE cecred.tbcc_portab_env_contestacao t
       SET t.idsituacao = 1
     WHERE t.cdcooper = rg_201.cdcooper
       AND t.nrdconta = rg_201.nrdconta
       AND t.nrsolicitacao = rg_201.nrsolicitacao;
    pc_escreve_xml_critica('Registro de contestacao (Codigo Cooperativa/Conta/Numero Solicitacao): ' || 
                           to_char(rg_201.cdcooper) || '/' || 
                           to_char(rg_201.nrdconta) || '/' ||
                           to_char(rg_201.nrsolicitacao) || '/' ||
                           ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  END LOOP;                                                     
  pc_escreve_xml_critica('###################### Fim loop Registros APCS201_05463212_20230519_00551 - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
  
  pc_escreve_xml_critica('###################### Início loop Registros APCS301_05463212_20230519_00508 - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
  for rg_301 in (select t.idsituacao
                       ,t.dtretorno
                       ,t.nrnu_portabilidade
                    from cecred.tbcc_portab_regularizacao t
                   where t.nrnu_portabilidade in (202208230000239135781,202304170000257461011,202303200000255206525))loop
    pc_escreve_xml_rollback('UPDATE cecred.tbcc_portab_regularizacao t ' || chr(10) ||
                            '   SET t.idsituacao = ' || NVL(to_char(rg_301.idsituacao),'NULL') || chr(10) ||
                            case
                              when rg_301.dtretorno IS NULL THEN
                                '      ,t.dtretorno = NULL'
                              else
                                '      ,t.dtretorno = to_date('''||to_char(rg_301.dtretorno,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'
                            end || chr(10) || 
                            ' WHERE t.nrnu_portabilidade = ' || rg_301.nrnu_portabilidade || ';' || chr(10) || chr(10));
    UPDATE cecred.tbcc_portab_regularizacao t
       SET t.idsituacao = 1
          ,t.dtretorno = NULL
     WHERE t.nrnu_portabilidade = rg_301.nrnu_portabilidade;
    pc_escreve_xml_critica('Registro Portabilidade ' || rg_301.nrnu_portabilidade || ' - Atualizado ' || sql%rowcount || ' registros.' || chr(10));
  end loop;
  pc_escreve_xml_critica('###################### Fim loop Registros APCS301_05463212_20230519_00508 - ' || to_char(sysdate,'dd/mm/yyyy hh24:mm:ss') || chr(10));  
   
  pc_escreve_xml_rollback('COMMIT;');
  pc_escreve_xml_rollback(' ',TRUE);

  CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                pr_caminho  => vr_rollback_path,
                                pr_arquivo  => vr_nmarqbkp,
                                pr_des_erro => vr_des_erroGeral);
  IF (vr_des_erroGeral IS NOT NULL) THEN
    dbms_lob.close(vr_des_rollback_xml);
    dbms_lob.freetemporary(vr_des_rollback_xml);
    RAISE vr_exc_clob;
  END IF;   
  
  pc_escreve_xml_critica(' ',TRUE);
  CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                pr_caminho  => vr_rollback_path,
                                pr_arquivo  => vr_nmarqcri,
                                pr_des_erro => vr_des_erroGeral);
                                
  IF (vr_des_erroGeral IS NOT NULL) THEN
    dbms_lob.close(vr_des_critic_xml);
    dbms_lob.freetemporary(vr_des_critic_xml);
    RAISE vr_exc_clob;
  END IF;

  dbms_lob.close(vr_des_rollback_xml);
  dbms_lob.freetemporary(vr_des_rollback_xml);

  dbms_lob.close(vr_des_critic_xml);
  dbms_lob.freetemporary(vr_des_critic_xml);
  
  COMMIT;   
  
EXCEPTION
  WHEN OTHERS THEN
    CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback_xml,
                                pr_caminho  => vr_rollback_path,
                                pr_arquivo  => vr_nmarqbkp,
                                pr_des_erro => vr_des_erroGeral);
    IF (vr_des_erroGeral IS NOT NULL) THEN
      dbms_lob.close(vr_des_rollback_xml);
      dbms_lob.freetemporary(vr_des_rollback_xml);
      RAISE vr_exc_clob;
    END IF;   
    
    pc_escreve_xml_critica('Erro Geral: ' || sqlerrm);
    pc_escreve_xml_critica(' ',TRUE);
    CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_critic_xml,
                                  pr_caminho  => vr_rollback_path,
                                  pr_arquivo  => vr_nmarqcri,
                                  pr_des_erro => vr_des_erroGeral);
                                  
    IF (vr_des_erroGeral IS NOT NULL) THEN
      dbms_lob.close(vr_des_critic_xml);
      dbms_lob.freetemporary(vr_des_critic_xml);
      RAISE vr_exc_clob;
    END IF;

    dbms_lob.close(vr_des_rollback_xml);
    dbms_lob.freetemporary(vr_des_rollback_xml);

    dbms_lob.close(vr_des_critic_xml);
    dbms_lob.freetemporary(vr_des_critic_xml);
    
    ROLLBACK;
END;
