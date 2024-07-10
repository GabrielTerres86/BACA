DECLARE
  
  pr_dsxmlarq CLOB := '<?xml version="1.0"?>
<APCSDOC>
  <BCARQ>
    <NomArq>APCS102_05463212_20240704_00159</NomArq>
    <NumCtrlEmis>20240704000000261525</NumCtrlEmis>
    <NumCtrlDestOr>APCS1012024070400616</NumCtrlDestOr>
    <ISPBEmissor>02992335</ISPBEmissor>
    <ISPBDestinatario>05463212</ISPBDestinatario>
    <DtHrArq>2024-07-04T17:36:56</DtHrArq>
    <DtRef>2024-07-04</DtRef>
  </BCARQ>
  <SISARQ>
    <APCS102>
      <Grupo_APCS102_PortddCtSalr>
        <IdentdPartAdmtd>05463212</IdentdPartAdmtd>
        <NUPortddPCS>202407040000324062595</NUPortddPCS>
        <Grupo_APCS102_Cli>
          <CPFCli>12964401926</CPFCli>
          <NomCli>Érik Castagneti de Medeiros</NomCli>
        </Grupo_APCS102_Cli>
        <Grupo_APCS102_FolhaPgto>
          <ISPBPartFolhaPgto>05463212</ISPBPartFolhaPgto>
          <CNPJPartFolhaPgto>05463212000129</CNPJPartFolhaPgto>
          <TpPessoaEmprdr>J</TpPessoaEmprdr>
          <CNPJ_CPFEmprdr>12213606000194</CNPJ_CPFEmprdr>
          <DenSocEmprdr>NASDAQ TRANSPORTES RODOVIARIOS DE CARGAS</DenSocEmprdr>
        </Grupo_APCS102_FolhaPgto>
        <Grupo_APCS102_Dest>
          <ISPBPartDest>18236120</ISPBPartDest>
          <CNPJPartDest>18236120000158</CNPJPartDest>
          <TpCtDest>PG</TpCtDest>
          <CtPagtoDest>507814145</CtPagtoDest>
        </Grupo_APCS102_Dest>
      </Grupo_APCS102_PortddCtSalr>
      <Grupo_APCS102_PortddCtSalr>
        <IdentdPartAdmtd>05463212</IdentdPartAdmtd>
        <NUPortddPCS>202407040000324062605</NUPortddPCS>
        <Grupo_APCS102_Cli>
          <CPFCli>12964401926</CPFCli>
          <NomCli>Érik Castagneti de Medeiros</NomCli>
        </Grupo_APCS102_Cli>
        <Grupo_APCS102_FolhaPgto>
          <ISPBPartFolhaPgto>05463212</ISPBPartFolhaPgto>
          <CNPJPartFolhaPgto>05463212000129</CNPJPartFolhaPgto>
          <TpPessoaEmprdr>J</TpPessoaEmprdr>
          <CNPJ_CPFEmprdr>18979249000156</CNPJ_CPFEmprdr>
          <DenSocEmprdr>STEFANY BRITAMENTO DE PEDRAS LTDA</DenSocEmprdr>
        </Grupo_APCS102_FolhaPgto>
        <Grupo_APCS102_Dest>
          <ISPBPartDest>18236120</ISPBPartDest>
          <CNPJPartDest>18236120000158</CNPJPartDest>
          <TpCtDest>PG</TpCtDest>
          <CtPagtoDest>507814145</CtPagtoDest>
        </Grupo_APCS102_Dest>
      </Grupo_APCS102_PortddCtSalr>
    </APCS102>
  </SISARQ>
</APCSDOC>';

  PROCEDURE pc_proc_XML_APCS102 IS 
  
    vr_dsapcsdoc       CONSTANT VARCHAR2(10) := 'APCS102';
    vr_datetimeformat  CONSTANT VARCHAR2(30) := 'YYYY-MM-DD"T"HH24:MI:SS';
    vr_dateformat      CONSTANT VARCHAR2(10) := 'YYYY-MM-DD';
    vr_dsmasklog       CONSTANT VARCHAR2(30) := 'dd/mm/yyyy hh24:mi:ss';
    vr_dsarqlg         CONSTANT VARCHAR2(30) := 'pcps_'||to_char(SYSDATE,'RRRRMM')||'.log';
    vr_dsmotivoreprv   CONSTANT VARCHAR2(30) := 'MOTVREPRVCPORTDDCTSALR';
  
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
    
    CURSOR cr_dados IS
      WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
      SELECT nmarquiv
           , to_date(dtarquiv, vr_datetimeformat) dtarquiv
        FROM DATA
           , XMLTABLE(('APCSDOC/BCARQ')
                      PASSING XMLTYPE(xml)
                      COLUMNS nmarquiv  VARCHAR2(100) PATH 'NomArq'
                            , dtarquiv  VARCHAR2(50)  PATH 'DtHrArq' );
    
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
    
    vr_dsxmlarq     CLOB := pr_dsxmlarq;
    vr_dsmsglog     VARCHAR2(1000);
    vr_dscritic     VARCHAR2(1000);
    vr_nmarquiv     VARCHAR2(100);
    vr_dtarquiv     DATE;
    vr_tppesepr     NUMBER;
    
    vr_cdcooper     crapass.cdcooper%TYPE;
    vr_nrdconta     crapass.nrdconta%TYPE;
    vr_cdagedst     tbcc_portabilidade_recebe.cdagencia_destinataria%TYPE;
    vr_nrctadst     tbcc_portabilidade_recebe.nrdconta_destinataria%TYPE;
    vr_idsituac     tbcc_portabilidade_recebe.idsituacao%TYPE;
    vr_dsdomrep     tbcc_portabilidade_recebe.dsdominio_motivo%TYPE;
    vr_cdcodrep     tbcc_portabilidade_recebe.cdmotivo%TYPE;
    vr_dtavalia     tbcc_portabilidade_recebe.dtavaliacao%TYPE;
    vr_cdoperad     tbcc_portabilidade_recebe.cdoperador%TYPE;
    
  BEGIN
    
    OPEN  cr_dados;
    FETCH cr_dados INTO vr_nmarquiv 
                      , vr_dtarquiv;
    CLOSE cr_dados;    
    
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
        BEGIN
          vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                         || 'PCPS0002.pc_proc_xml_APCS104'
                         || ' -'||'-> NU Portabilidade já existe na base de dados: '||rg_dadosret.nrnuport;
          
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log      => vr_dsmsglog
                                    ,pr_nmarqlog     => vr_dsarqlg);
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        
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
          
          BEGIN
            vr_dsmsglog := to_char(sysdate,vr_dsmasklog)||' - '
                           || 'PCPS0002.pc_proc_xml_APCS102'
                           || ' -'||'-> Erro ao incluir registro de portabilidade: '||rg_dadosret.nrnuport;
            
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log      => vr_dsmsglog
                                      ,pr_nmarqlog     => vr_dsarqlg);
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
          
          RAISE_APPLICATION_ERROR(-20002,'Erro na rotina PCPS.pc_proc_xml_APCS102. ' ||vr_dscritic);
      END;
    
    END LOOP;
        
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Erro na rotina PCPS.pc_proc_xml_APCS102. ' ||SQLERRM);
  END pc_proc_xml_APCS102;

BEGIN
  
  pc_proc_XML_APCS102;

  COMMIT;

END;
