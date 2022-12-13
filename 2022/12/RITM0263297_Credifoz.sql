DECLARE
  CURSOR cr_crapass(pr_cdcooper cecred.crapass.cdcooper%type,
                    pr_nrdconta cecred.crapass.nrdconta%type) IS
    SELECT a.inpessoa
          ,decode(a.inpessoa,1,'PF','PJ') as ds_inpessoa
          ,a.cdagenci
          ,a.dtdemiss
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta;
  rw_crapass                cr_crapass%ROWTYPE;

  rw_crapdat                cecred.btch0001.cr_crapdat%ROWTYPE;  
  
  vc_dstransa               CONSTANT VARCHAR2(4000) := 'Reversao ao fundo de Reserva de Valores a Devolver por script - RITM0263297';  
  vc_tpDevolucaoDepVista    CONSTANT cecred.tbcotas_devolucao.tpdevolucao%type := 4;
  vc_tpDevolucaoCotaCapital CONSTANT cecred.tbcotas_devolucao.tpdevolucao%type := 3;
  vc_cdHistorPF             CONSTANT cecred.craphis.cdhistor%type := 4058;
  vc_cdHistorPJ             CONSTANT cecred.craphis.cdhistor%type := 4062;
  vc_cdHistorEstornoPF      CONSTANT cecred.craphis.cdhistor%type := 4059;
  vc_cdHistorEstornoPJ      CONSTANT cecred.craphis.cdhistor%type := 4061;

  vr_exc_erro               EXCEPTION;
  vr_exc_clob               EXCEPTION;
  vr_exc_conta              EXCEPTION;
  vr_cdcritic               cecred.crapcri.cdcritic%type;
  vr_dscritic               cecred.crapcri.dscritic%type;
  vr_des_erro               VARCHAR2(4000);

  vc_cdcooper               CONSTANT cecred.crapcop.cdcooper%type := 11;
  vc_nrdcontaAdm            CONSTANT cecred.crapass.nrdconta%type := 99501112;
  vr_nmarqbkp               VARCHAR2(100) := 'ROLLBACK_RITM0263297_Credifoz.sql';
  vr_nmarqcri               VARCHAR2(100) := 'ArquivoRetorno_Credifoz.csv';  
  vr_arq_path               VARCHAR2(1000):= gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/ritm0263297'; 
  vr_nmarquiv               VARCHAR2(100) := 'Contas.csv'; 
    
  vr_hutlfile               utl_file.file_type; 
  vr_dstxtlid               VARCHAR2(1000);
  vr_contador               INTEGER := 0;
  vr_tab_linhacsv           cecred.gene0002.typ_split;
  vr_cdcooper               cecred.crapass.cdcooper%TYPE;
  vr_nrdconta               cecred.crapass.nrdconta%TYPE;
  vr_tpPessoa               varchar2(2);
  vr_valor                  NUMBER(15,2);
  vr_dtInicioCredCota       cecred.tbcotas_devolucao.dtinicio_credito%type;
  vr_dtInicioCredDepVista   cecred.tbcotas_devolucao.dtinicio_credito%type;
  vr_vlCapitalDepVista      cecred.tbcotas_devolucao.vlcapital%type;
  vr_vlPagoDepVista         cecred.tbcotas_devolucao.vlpago%type;
  vr_vlCapitalCotaCapital   cecred.tbcotas_devolucao.vlcapital%type;
  vr_vlPagoCotaCapital      cecred.tbcotas_devolucao.vlpago%type;
  vr_vlDevolverDepVista     NUMBER(15,2); 
  vr_vlDevolverCotaCapital  NUMBER(15,2);
  vr_vlTotalDevolver        NUMBER(15,2);
  vr_vlrTransfCota          NUMBER(15,2);
  vr_vlrTransfSobras        NUMBER(15,2);
  vr_vlrTransfPF            NUMBER(15,2);
  vr_vlrTransfPJ            NUMBER(15,2);
  vr_cdagenciAdm            cecred.crapass.cdagenci%type;
  vr_nrdocmto               cecred.craplcm.nrdocmto%type;
  vr_tab_retorno            cecred.lanc0001.typ_reg_retorno;
  vr_incrineg               NUMBER;
  
  vr_dttransa               cecred.craplgm.dttransa%type;
  vr_hrtransa               cecred.craplgm.hrtransa%type;
  vr_cdoperad               cecred.craplgm.cdoperad%TYPE;
  vr_nrdrowid               ROWID;
  vr_des_reto               VARCHAR2(3);

  vr_des_rollback           CLOB;
  vr_texto_rb_completo      VARCHAR2(32600);
  
  vr_des_retorno            CLOB;
  vr_texto_ret_completo     VARCHAR2(32600); 
    
  PROCEDURE pc_escreve_xml_rollback(pr_des_dados IN VARCHAR2,
                                    pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    cecred.gene0002.pc_escreve_xml(vr_des_rollback, vr_texto_rb_completo, pr_des_dados, pr_fecha_xml);
  END;

  PROCEDURE pc_escreve_xml_retorno(pr_des_dados IN VARCHAR2,
                                   pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    cecred.gene0002.pc_escreve_xml(vr_des_retorno, vr_texto_ret_completo, pr_des_dados, pr_fecha_xml);
  END;  
  
BEGIN
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => vc_cdcooper);
  FETCH cecred.btch0001.cr_crapdat
   INTO rw_crapdat;
  IF cecred.btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE cecred.btch0001.cr_crapdat;
    vr_cdcritic := 1;
    RAISE vr_exc_erro;
  ELSE
    CLOSE cecred.btch0001.cr_crapdat;
  END IF;  

  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := cecred.GENE0002.fn_busca_time;  
  
  vr_des_rollback := NULL;
  dbms_lob.createtemporary(vr_des_rollback, TRUE);
  dbms_lob.open(vr_des_rollback, dbms_lob.lob_readwrite);
  vr_texto_rb_completo := NULL;

  vr_des_retorno := NULL;
  dbms_lob.createtemporary(vr_des_retorno, TRUE);
  dbms_lob.open(vr_des_retorno, dbms_lob.lob_readwrite);
  vr_texto_ret_completo := NULL;
    
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path
                                 ,pr_nmarquiv => vr_nmarquiv   
                                 ,pr_tipabert => 'R'           
                                 ,pr_utlfileh => vr_hutlfile   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na leitura do arquivo -> '||vr_dscritic;
    pc_escreve_xml_retorno(vr_dscritic || chr(10));
    RAISE vr_exc_erro;
  END IF; 
  
  pc_escreve_xml_retorno('Cooperativa; PA; Data Base; Tipo; Conta; Data Transferencia Fundo; Valor devolver; Origem; Demissao; Resultado;' || chr(10));
  
  vr_vlrTransfPF := 0;
  vr_vlrTransfPJ := 0;
  
  IF utl_file.IS_OPEN(vr_hutlfile) THEN
    BEGIN   
      LOOP
        vr_cdcooper := 0;
        vr_nrdconta := 0;

        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_hutlfile 
                                           ,pr_des_text => vr_dstxtlid); 
       
        IF length(vr_dstxtlid) <= 1 THEN 
          continue;
        END IF;
        
        vr_contador := vr_contador + 1; 
        vr_tab_linhacsv := gene0002.fn_quebra_string(vr_dstxtlid,';');
        vr_cdcooper := cecred.gene0002.fn_char_para_number(vr_tab_linhacsv(1));
        vr_nrdconta := cecred.gene0002.fn_char_para_number(vr_tab_linhacsv(2));
        vr_valor    := cecred.gene0002.fn_char_para_number(vr_tab_linhacsv(3));
        
        IF nvl(vr_cdcooper,0) <> vc_cdcooper OR
           nvl(vr_valor,0) = 0 OR
           nvl(vr_nrdconta,0) = 0 
        THEN
          CONTINUE;
        END IF;
        
        vr_vlrTransfCota := 0;
        vr_vlrTransfSobras := 0;
        
        OPEN cr_crapass(vr_cdcooper, vr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 9;
          vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
          CLOSE cr_crapass;
          pc_escreve_xml_retorno(vr_cdcooper || 
                                 ';' || 
                                 ' ' || 
                                 ';' || 
                                 to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                 ';' ||
                                 ' ' ||
                                 ';' ||
                                 vr_nrdconta ||
                                 ';' ||
                                 to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                 ';' ||
                                 trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                 ';' ||
                                 ' ' ||
                                 ';' ||
                                 ' ' ||
                                 ';' ||
                                 'Erro ao buscar Dados da Conta.' ||
                                 ';' ||
                                 chr(10));
          CONTINUE;                       
        END IF;
        CLOSE cr_crapass;
        
        CADA0004.pc_buscar_tbcota_devol(pr_cdcooper         => vr_cdcooper,
                                        pr_nrdconta         => vr_nrdconta,
                                        pr_tpdevolucao      => vc_tpDevolucaoDepVista,
                                        pr_vlcapital        => vr_vlCapitalDepVista,
                                        pr_dtinicio_credito => vr_dtInicioCredDepVista,
                                        pr_vlpago           => vr_vlPagoDepVista,
                                        pr_cdcritic         => vr_cdcritic,
                                        pr_dscritic         => vr_dscritic);
        
        IF nvl(vr_cdcritic,0) > 0 THEN
          vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
          pc_escreve_xml_retorno(vr_cdcooper || 
                                 ';' || 
                                 rw_crapass.cdagenci || 
                                 ';' || 
                                 to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                 ';' ||
                                 rw_crapass.ds_inpessoa ||
                                 ';' ||
                                 vr_nrdconta ||
                                 ';' ||
                                 to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                 ';' ||
                                 trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                 ';' ||
                                 '061' ||
                                 ';' ||
                                 to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                 ';' ||
                                 'Erro ao Buscar Valor a Devolver Dep. Vista: ' || vr_dscritic ||
                                 ';' ||
                                 chr(10));
          CONTINUE;
        END IF;
        vr_dscritic := null;
        
        CADA0004.pc_buscar_tbcota_devol(pr_cdcooper         => vr_cdcooper,
                                        pr_nrdconta         => vr_nrdconta,
                                        pr_tpdevolucao      => vc_tpDevolucaoCotaCapital,
                                        pr_vlcapital        => vr_vlCapitalCotaCapital,
                                        pr_dtinicio_credito => vr_dtInicioCredCota,
                                        pr_vlpago           => vr_vlPagoCotaCapital,
                                        pr_cdcritic         => vr_cdcritic,
                                        pr_dscritic         => vr_dscritic);
        
        IF nvl(vr_cdcritic,0) > 0 THEN
          vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
          pc_escreve_xml_retorno(vr_cdcooper || 
                                 ';' || 
                                 rw_crapass.cdagenci || 
                                 ';' || 
                                 to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                 ';' ||
                                 rw_crapass.ds_inpessoa ||
                                 ';' ||
                                 vr_nrdconta ||
                                 ';' ||
                                 to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                 ';' ||
                                 trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                 ';' ||
                                 '060' ||
                                 ';' ||
                                 to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                 ';' ||
                                 'Erro ao Buscar Valor a Devolver Cota Capital: ' || vr_dscritic ||
                                 ';' ||
                                 chr(10));
          CONTINUE;
        END IF;
        vr_dscritic := null;
        
        vr_vlDevolverDepVista    := nvl(vr_vlCapitalDepVista,0) - nvl(vr_vlPagoDepVista,0);
        vr_vlDevolverCotaCapital := nvl(vr_vlCapitalCotaCapital,0) - nvl(vr_vlPagoCotaCapital,0);
        vr_vlTotalDevolver       := vr_vlDevolverDepVista + vr_vlDevolverCotaCapital;    
        
        CASE
          when vr_vlTotalDevolver = 0 THEN
            pc_escreve_xml_retorno(vr_cdcooper || 
                                   ';' || 
                                   rw_crapass.cdagenci || 
                                   ';' || 
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   rw_crapass.ds_inpessoa ||
                                   ';' ||
                                   vr_nrdconta ||
                                   ';' ||
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                   ';' ||
                                   '060' ||
                                   ';' ||
                                   to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                   ';' ||
                                   'Nao ha Valor a Devolver Cota Capital.' ||
                                   ';' ||
                                   chr(10));
           
            pc_escreve_xml_retorno(vr_cdcooper || 
                                   ';' || 
                                   rw_crapass.cdagenci || 
                                   ';' || 
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   rw_crapass.ds_inpessoa ||
                                   ';' ||
                                   vr_nrdconta ||
                                   ';' ||
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                   ';' ||
                                   '061' ||
                                   ';' ||
                                   to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                   ';' ||
                                   'Nao ha Valor a Devolver Dep. Vista.' ||
                                   ';' ||
                                   chr(10));
            CONTINUE;
             
          when vr_vlTotalDevolver < vr_valor THEN
            pc_escreve_xml_retorno(vr_cdcooper || 
                                   ';' || 
                                   rw_crapass.cdagenci || 
                                   ';' || 
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   rw_crapass.ds_inpessoa ||
                                   ';' ||
                                   vr_nrdconta ||
                                   ';' ||
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                   ';' ||
                                   '060' ||
                                   ';' ||
                                   to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                   ';' ||
                                   'Valor Sumarizado (Cota + Dep. Vista) menor que o solicitado no arquivo' ||
                                   ';' ||
                                   chr(10));
           
            pc_escreve_xml_retorno(vr_cdcooper || 
                                   ';' || 
                                   rw_crapass.cdagenci || 
                                   ';' || 
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   rw_crapass.ds_inpessoa ||
                                   ';' ||
                                   vr_nrdconta ||
                                   ';' ||
                                   to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                   ';' ||
                                   trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                   ';' ||
                                   '061' ||
                                   ';' ||
                                   to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                   ';' ||
                                   'Valor Sumarizado (Cota + Dep. Vista) menor que o solicitado no arquivo' ||
                                   ';' ||
                                   chr(10));
            CONTINUE;
            
          when vr_vlTotalDevolver >= vr_valor THEN
            
            IF vr_valor <= vr_vlDevolverCotaCapital THEN
              vr_vlrTransfCota := vr_valor;
              vr_vlrTransfSobras := 0;
            ELSE
              vr_vlrTransfCota := vr_vlDevolverCotaCapital;
              vr_vlrTransfSobras := vr_valor - vr_vlDevolverCotaCapital;
            END IF;
            
            IF vr_vlrTransfCota > 0 THEN
              CECRED.CADA0004.pc_atualizar_tbcota_devol(pr_cdcooper    => vr_cdcooper,
                                                        pr_nrdconta    => vr_nrdconta,
                                                        pr_tpdevolucao => vc_tpDevolucaoCotaCapital,
                                                        pr_vlpago      => vr_vlrTransfCota,
                                                        pr_cdcritic    => vr_cdcritic,
                                                        pr_dscritic    => vr_dscritic);
                                                          
              IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
                pc_escreve_xml_retorno(vr_cdcooper || 
                                       ';' || 
                                       rw_crapass.cdagenci || 
                                       ';' || 
                                       to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                       ';' ||
                                       rw_crapass.ds_inpessoa ||
                                       ';' ||
                                       vr_nrdconta ||
                                       ';' ||
                                       to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                       ';' ||
                                       trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                       ';' ||
                                       '060' ||
                                       ';' ||
                                       to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                       ';' ||
                                       'Erro ao atualizar Valor a Devolver Cota Capital: ' || vr_dscritic ||
                                       ';' ||
                                       chr(10));
                CONTINUE;
              END IF;
              
              vr_nrdrowid := null;
              CECRED.GENE0001.pc_gera_log(pr_cdcooper => vc_cdcooper,
                                          pr_cdoperad => vr_cdoperad,
                                          pr_dscritic => 'Cota Capital (TPDEVOLUCAO = 3)',
                                          pr_dsorigem => 'AIMARO',
                                          pr_dstransa => vc_dstransa || ' - Cota Capital (TPDEVOLUCAO = 3)',
                                          pr_dttransa => vr_dttransa,
                                          pr_flgtrans => 1,
                                          pr_hrtransa => vr_hrtransa,
                                          pr_idseqttl => 0,
                                          pr_nmdatela => NULL,
                                          pr_nrdconta => vr_nrdconta,
                                          pr_nrdrowid => vr_nrdrowid);
        
              CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                               pr_nmdcampo => 'TBCOTAS_DEVOLUCAO.VLPAGO',
                                               pr_dsdadant => trim(to_char(nvl(vr_vlPagoCotaCapital,0),'99999999990D00')),
                                               pr_dsdadatu => trim(to_char((nvl(vr_vlPagoCotaCapital,0) + vr_vlrTransfCota),'99999999990D00')));

              CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                               pr_nmdcampo => 'TBCOTAS_DEVOLUCAO.DTINICIO_CREDITO',
                                               pr_dsdadant => to_char(vr_dtInicioCredCota,'dd/mm/yyyy'),
                                               pr_dsdadatu => to_char(sysdate,'dd/mm/yyyy'));
              
              IF trim(vr_dtInicioCredCota) IS NULL THEN
                pc_escreve_xml_rollback('UPDATE CECRED.TBCOTAS_DEVOLUCAO' ||
                                        ' SET VLPAGO = ' || trim(to_char(nvl(vr_vlPagoCotaCapital,0),'99999999990.00')) || 
                                        ' ,DTINICIO_CREDITO = NULL' ||
                                        ' WHERE cdcooper = ' ||vr_cdcooper ||
                                        ' AND nrdconta = ' || vr_nrdconta ||
                                        ' AND tpdevolucao = ' || vc_tpDevolucaoCotaCapital ||
                                        ';' || chr(10)); 
              ELSE
                pc_escreve_xml_rollback('UPDATE CECRED.TBCOTAS_DEVOLUCAO' ||
                                        ' SET VLPAGO = ' || trim(to_char(nvl(vr_vlPagoCotaCapital,0),'99999999990.00')) || 
                                        ' ,DTINICIO_CREDITO = to_date(''' || to_char(vr_dtInicioCredCota,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ||
                                        ' WHERE cdcooper = ' ||vr_cdcooper ||
                                        ' AND nrdconta = ' || vr_nrdconta ||
                                        ' AND tpdevolucao = ' || vc_tpDevolucaoCotaCapital ||
                                        ';' || chr(10));
              END IF;

              pc_escreve_xml_retorno(vr_cdcooper || 
                                     ';' || 
                                     rw_crapass.cdagenci || 
                                     ';' || 
                                     to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                     ';' ||
                                     rw_crapass.ds_inpessoa ||
                                     ';' ||
                                     vr_nrdconta ||
                                     ';' ||
                                     to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                     ';' ||
                                     trim(to_char(nvl(vr_vlrTransfCota,0),'99999999990.00')) || 
                                     ';' ||
                                     '060' ||
                                     ';' ||
                                     to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                     ';' ||
                                     'Sucesso' ||
                                     ';' ||
                                     chr(10));
              
            END IF;
            
            IF vr_vlrTransfSobras > 0 THEN
              CECRED.CADA0004.pc_atualizar_tbcota_devol(pr_cdcooper    => vr_cdcooper,
                                                        pr_nrdconta    => vr_nrdconta,
                                                        pr_tpdevolucao => vc_tpDevolucaoDepVista,
                                                        pr_vlpago      => vr_vlrTransfSobras,
                                                        pr_cdcritic    => vr_cdcritic,
                                                        pr_dscritic    => vr_dscritic);
                                                          
              IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
                pc_escreve_xml_retorno(vr_cdcooper || 
                                       ';' || 
                                       rw_crapass.cdagenci || 
                                       ';' || 
                                       to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                       ';' ||
                                       rw_crapass.ds_inpessoa ||
                                       ';' ||
                                       vr_nrdconta ||
                                       ';' ||
                                       to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                       ';' ||
                                       trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                       ';' ||
                                       '060' ||
                                       ';' ||
                                       to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                       ';' ||
                                       'Erro ao atualizar Valor a Devolver Sobras/Dep. Vista: ' || vr_dscritic ||
                                       ';' ||
                                       chr(10));
                CONTINUE;
              END IF;
              
              vr_nrdrowid := null;
              CECRED.GENE0001.pc_gera_log(pr_cdcooper => vc_cdcooper,
                                          pr_cdoperad => vr_cdoperad,
                                          pr_dscritic => 'Sobras/Dep. Vista (TPDEVOLUCAO = 4)',
                                          pr_dsorigem => 'AIMARO',
                                          pr_dstransa => vc_dstransa || ' - Sobras/Dep. Vista (TPDEVOLUCAO = 4)',
                                          pr_dttransa => vr_dttransa,
                                          pr_flgtrans => 1,
                                          pr_hrtransa => vr_hrtransa,
                                          pr_idseqttl => 0,
                                          pr_nmdatela => NULL,
                                          pr_nrdconta => vr_nrdconta,
                                          pr_nrdrowid => vr_nrdrowid);
            
              CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                               pr_nmdcampo => 'TBCOTAS_DEVOLUCAO.VLPAGO',
                                               pr_dsdadant => trim(to_char(nvl(vr_vlPagoDepVista,0),'99999999990D00')),
                                               pr_dsdadatu => trim(to_char((nvl(vr_vlPagoDepVista,0) + vr_vlrTransfSobras),'99999999990D00')));
                                           
              CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                               pr_nmdcampo => 'TBCOTAS_DEVOLUCAO.DTINICIO_CREDITO',
                                               pr_dsdadant => to_char(vr_dtInicioCredDepVista,'dd/mm/yyyy'),
                                               pr_dsdadatu => to_char(sysdate,'dd/mm/yyyy'));

              IF trim(vr_dtInicioCredDepVista) IS NULL THEN
                pc_escreve_xml_rollback('UPDATE CECRED.TBCOTAS_DEVOLUCAO' ||
                                        ' SET VLPAGO = ' || trim(to_char(nvl(vr_vlPagoDepVista,0),'99999999990.00')) || 
                                        ' ,DTINICIO_CREDITO = NULL' ||
                                        ' WHERE cdcooper = ' ||vr_cdcooper ||
                                        ' AND nrdconta = ' || vr_nrdconta ||
                                        ' AND tpdevolucao = ' || vc_tpDevolucaoDepVista ||
                                        ';' || chr(10)); 
              ELSE
                pc_escreve_xml_rollback('UPDATE CECRED.TBCOTAS_DEVOLUCAO' ||
                                        ' SET VLPAGO = ' || trim(to_char(nvl(vr_vlPagoDepVista,0),'99999999990.00')) || 
                                        ' ,DTINICIO_CREDITO = to_date(''' || to_char(vr_dtInicioCredDepVista,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ||
                                        ' WHERE cdcooper = ' ||vr_cdcooper ||
                                        ' AND nrdconta = ' || vr_nrdconta ||
                                        ' AND tpdevolucao = ' || vc_tpDevolucaoDepVista ||
                                        ';' || chr(10));
              END IF;
              
              pc_escreve_xml_retorno(vr_cdcooper || 
                                     ';' || 
                                     rw_crapass.cdagenci || 
                                     ';' || 
                                     to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                     ';' ||
                                     rw_crapass.ds_inpessoa ||
                                     ';' ||
                                     vr_nrdconta ||
                                     ';' ||
                                     to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                                     ';' ||
                                     trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                                     ';' ||
                                     '061' ||
                                     ';' ||
                                     to_char(rw_crapass.dtdemiss,'dd/mm/yyyy') ||
                                     ';' ||
                                     'Sucesso' ||
                                     ';' ||
                                     chr(10));
                                           
            END IF;        
                    
            IF rw_crapass.inpessoa = 1 THEN
              vr_vlrTransfPF := vr_vlrTransfPF + vr_valor;
            ELSE
              vr_vlrTransfPJ := vr_vlrTransfPJ + vr_valor;  
            END IF;
            
        END CASE;
      END LOOP;
    EXCEPTION 
      WHEN no_data_found THEN 
        CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_hutlfile);
        
      WHEN OTHERS THEN
        pc_escreve_xml_retorno(vr_cdcooper || 
                       ';' || 
                       nvl(rw_crapass.cdagenci,0) || 
                       ';' || 
                       to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                       ';' ||
                       nvl(rw_crapass.ds_inpessoa,' ') ||
                       ';' ||
                       nvl(vr_nrdconta,0) ||
                       ';' ||
                       to_char(rw_crapdat.dtmvtolt,'dd/mm/yyyy') || 
                       ';' ||
                       trim(to_char(nvl(vr_vlrTransfSobras,0),'99999999990.00')) || 
                       ';' ||
                       ' ' ||
                       ';' ||
                       to_char(nvl(rw_crapass.dtdemiss,' '),'dd/mm/yyyy') ||
                       ';' ||
                       'Erro inesperado: ' || SQLERRM ||
                       ';' ||
                       chr(10));

        cecred.pc_internal_exception;
    END;
  END IF;      
  
  SELECT CDAGENCI
    INTO vr_cdagenciAdm
    FROM CECRED.CRAPASS A
   WHERE a.nrdconta = vc_nrdcontaAdm
     AND a.cdcooper = vc_cdcooper;
   
     
   IF nvl(vr_vlrTransfPF,0) > 0 THEN
     vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
    cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                             ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                             ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                             ,pr_cdbccxlt    => 1
                                             ,pr_nrdolote    => vc_cdHistorPF
                                             ,pr_nrdctabb    => vc_nrdcontaAdm
                                             ,pr_nrdocmto    => vr_nrdocmto
                                             ,pr_cdhistor    => vc_cdHistorPF
                                             ,pr_vllanmto    => vr_vlrTransfPF
                                             ,pr_nrdconta    => vc_nrdcontaAdm
                                             ,pr_hrtransa    => gene0002.fn_busca_time
                                             ,pr_inprolot    => 1 
                                             ,pr_tab_retorno => vr_tab_retorno 
                                             ,pr_incrineg    => vr_incrineg      
                                             ,pr_cdcritic    => vr_cdcritic      
                                             ,pr_dscritic    => vr_dscritic);    

      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      pc_escreve_xml_rollback('DELETE FROM CECRED.CRAPLCM' ||
                              ' WHERE CDCOOPER = ' || vc_cdcooper ||
                              ' AND DTMVTOLT = to_date(''' || to_char(rw_crapdat.DTMVTOLT,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ||
                              ' AND CDAGENCI = ' || nvl(vr_cdagenciAdm,0) ||
                              ' AND CDBCCXLT = 1 ' ||
                              ' AND NRDOLOTE = ' || vc_cdHistorPF ||
                              ' AND NRDCTABB = ' || vc_nrdcontaAdm ||
                              ' AND NRDOCMTO = ' || vr_nrdocmto ||
                              ';' || chr(10));
      
      vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
      cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                               ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                               ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                               ,pr_cdbccxlt    => 1
                                               ,pr_nrdolote    => vc_cdHistorEstornoPF
                                               ,pr_nrdctabb    => vc_nrdcontaAdm
                                               ,pr_nrdocmto    => vr_nrdocmto
                                               ,pr_cdhistor    => vc_cdHistorEstornoPF
                                               ,pr_vllanmto    => vr_vlrTransfPF
                                               ,pr_nrdconta    => vc_nrdcontaAdm
                                               ,pr_hrtransa    => gene0002.fn_busca_time
                                               ,pr_inprolot    => 1 
                                               ,pr_tab_retorno => vr_tab_retorno 
                                               ,pr_incrineg    => vr_incrineg      
                                               ,pr_cdcritic    => vr_cdcritic      
                                               ,pr_dscritic    => vr_dscritic);    

      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      pc_escreve_xml_rollback('DELETE FROM CECRED.CRAPLCM' ||
                              ' WHERE CDCOOPER = ' || vc_cdcooper ||
                              ' AND DTMVTOLT = to_date(''' || to_char(rw_crapdat.DTMVTOLT,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ||
                              ' AND CDAGENCI = ' || nvl(vr_cdagenciAdm,0) ||
                              ' AND CDBCCXLT = 1 ' ||
                              ' AND NRDOLOTE = ' || vc_cdHistorEstornoPF ||
                              ' AND NRDCTABB = ' || vc_nrdcontaAdm ||
                              ' AND NRDOCMTO = ' || vr_nrdocmto ||
                              ';' || chr(10));
      
   END IF;  
   
   IF nvl(vr_vlrTransfPJ,0) > 0 THEN 
     vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
     cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                              ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                              ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                              ,pr_cdbccxlt    => 1
                                              ,pr_nrdolote    => vc_cdHistorPJ
                                              ,pr_nrdctabb    => vc_nrdcontaAdm
                                              ,pr_nrdocmto    => vr_nrdocmto
                                              ,pr_cdhistor    => vc_cdHistorPJ
                                              ,pr_vllanmto    => vr_vlrTransfPJ
                                              ,pr_nrdconta    => vc_nrdcontaAdm
                                              ,pr_hrtransa    => gene0002.fn_busca_time
                                              ,pr_inprolot    => 1 
                                              ,pr_tab_retorno => vr_tab_retorno 
                                              ,pr_incrineg    => vr_incrineg      
                                              ,pr_cdcritic    => vr_cdcritic      
                                              ,pr_dscritic    => vr_dscritic);    

     IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;
      
      pc_escreve_xml_rollback('DELETE FROM CECRED.CRAPLCM' ||
                              ' WHERE CDCOOPER = ' || vc_cdcooper ||
                              ' AND DTMVTOLT = to_date(''' || to_char(rw_crapdat.DTMVTOLT,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ||
                              ' AND CDAGENCI = ' || nvl(vr_cdagenciAdm,0) ||
                              ' AND CDBCCXLT = 1 ' ||
                              ' AND NRDOLOTE = ' || vc_cdHistorPJ ||
                              ' AND NRDCTABB = ' || vc_nrdcontaAdm ||
                              ' AND NRDOCMTO = ' || vr_nrdocmto ||
                              ';' || chr(10));
      
     vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
     cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                              ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                              ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                              ,pr_cdbccxlt    => 1
                                              ,pr_nrdolote    => vc_cdHistorEstornoPJ
                                              ,pr_nrdctabb    => vc_nrdcontaAdm
                                              ,pr_nrdocmto    => vr_nrdocmto
                                              ,pr_cdhistor    => vc_cdHistorEstornoPJ
                                              ,pr_vllanmto    => vr_vlrTransfPJ
                                              ,pr_nrdconta    => vc_nrdcontaAdm
                                              ,pr_hrtransa    => gene0002.fn_busca_time
                                              ,pr_inprolot    => 1 
                                              ,pr_tab_retorno => vr_tab_retorno 
                                              ,pr_incrineg    => vr_incrineg      
                                              ,pr_cdcritic    => vr_cdcritic      
                                              ,pr_dscritic    => vr_dscritic);    

     IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;
     
     pc_escreve_xml_rollback('DELETE FROM CECRED.CRAPLCM' ||
                             ' WHERE CDCOOPER = ' || vc_cdcooper ||
                             ' AND DTMVTOLT = to_date(''' || to_char(rw_crapdat.DTMVTOLT,'dd/mm/yyyy') || ''',''dd/mm/yyyy'')' ||
                             ' AND CDAGENCI = ' || nvl(vr_cdagenciAdm,0) ||
                             ' AND CDBCCXLT = 1 ' ||
                             ' AND NRDOLOTE = ' || vc_cdHistorEstornoPJ ||
                             ' AND NRDCTABB = ' || vc_nrdcontaAdm ||
                             ' AND NRDOCMTO = ' || vr_nrdocmto ||
                             ';' || chr(10));
     
   END IF;  

   pc_escreve_xml_rollback('COMMIT;');
   pc_escreve_xml_rollback(' ',TRUE);
   CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_rollback,
                                        pr_caminho  => vr_arq_path,
                                        pr_arquivo  => vr_nmarqbkp,
                                        pr_des_erro => vr_des_erro);
   IF (vr_des_erro IS NOT NULL) THEN
     dbms_lob.close(vr_des_rollback);
     dbms_lob.freetemporary(vr_des_rollback);
     RAISE vr_exc_clob;
   END IF;
   dbms_lob.close(vr_des_rollback);
   dbms_lob.freetemporary(vr_des_rollback);        

   pc_escreve_xml_retorno(' ',TRUE);
   CECRED.GENE0002.pc_clob_para_arquivo(pr_clob     => vr_des_retorno,
                                        pr_caminho  => vr_arq_path,
                                        pr_arquivo  => vr_nmarqcri,
                                        pr_des_erro => vr_des_erro);
   IF (vr_des_erro IS NOT NULL) THEN
     dbms_lob.close(vr_des_retorno);
     dbms_lob.freetemporary(vr_des_retorno);
     RAISE vr_exc_clob;
   END IF;
   dbms_lob.close(vr_des_retorno);
   dbms_lob.freetemporary(vr_des_retorno);   
   
   
   COMMIT;
    
EXCEPTION
  WHEN vr_exc_clob THEN
    cecred.pc_internal_exception;
    ROLLBACK;
  WHEN vr_exc_erro THEN      
    IF (vr_dscritic IS NULL) THEN
      vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro - vr_cdcritic: ' || vr_cdcritic || ' - ' || vr_dscritic); 
        
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro: ' || sqlerrm);
END;
