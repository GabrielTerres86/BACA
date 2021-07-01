DECLARE
  -- Local variables
  vr_qtdiajur NUMBER;
  vr_vlrtarif NUMBER;
  vr_cdcritic INTEGER;
  vr_tab_erro gene0001.typ_tab_erro;
  vr_contador_atualizados INTEGER := 0;
  vr_contador_cursor_contratos INTEGER := 0;
  vr_qtd_parcelas_restantes INTEGER := 0;
  vr_dtrefjur DATE;
  vr_diarefju crapepr.diarefju%TYPE;
  vr_mesrefju crapepr.mesrefju%TYPE;
  vr_anorefju crapepr.anorefju%TYPE;
      
  -- Variável genérica de calendário com base no cursor da btch0001
  rw_crapdat         btch0001.cr_crapdat%ROWTYPE;  
  vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
  vr_tab_calculado   empr0001.typ_tab_calculado;
  vr_vlparepr        NUMBER(25,2);
    
  -- Variaveis sistemas
  vr_vljurmes        NUMBER(25,2);
  vr_taxa_diaria     NUMBER(25,2);
  vr_vlr_ajust_car   NUMBER(25,2);
  vr_nova_prestacao  NUMBER(25,2);
  vr_texto_completo  CLOB;
  vr_des_log         CLOB;
  vr_dsdireto VARCHAR2(1000);
    
  -- Variavel tratamento de erro
  vr_dscritic        VARCHAR2(1000);
  vr_exc_erro        EXCEPTION;
  vr_des_reto        VARCHAR2(10);
      
  /*Cursor com as respectivas cooperativas, contas e contratos a serem atualizadas*/
  CURSOR cr_coop_conta_contrato_atualizar IS
    SELECT REGEXP_SUBSTR('138088,90053990','[^,]+', 1, LEVEL) AS PR_NRDCONTA,
           REGEXP_SUBSTR('164085,2432357','[^,]+', 1, LEVEL) AS PR_NRCTRATO,
           REGEXP_SUBSTR('16,1','[^,]+', 1, LEVEL) AS PR_CDCOOPER
    FROM DUAL 
  CONNECT BY REGEXP_SUBSTR('138088,90053990','[^,]+', 1, LEVEL) IS NOT NULL;
  
  CURSOR cr_tbepr_adiamento_contrato (pr_dtmvtoan IN crapdat.dtmvtoan%TYPE, pr_cooperativa IN NUMBER, pr_conta IN NUMBER, pr_contrato IN NUMBER)IS
    SELECT DISTINCT 
      crapepr.cdcooper, 
      crapepr.nrdconta, 
      crapepr.nrctremp,
      crapepr.dtdpagto,
      crapepr.diarefju,
      crapepr.mesrefju,
      crapepr.anorefju,
      crawepr.dtlibera,
      crawepr.txdiaria,
      crawepr.txmensal,
      crapepr.vlsdeved,
      crapepr.vlpreemp,
      crapepr.txjuremp,
      (select max(crappep.nrparepr)       
       from crappep
       where crappep.cdcooper = crapepr.cdcooper
         and crappep.nrdconta = crapepr.nrdconta
         and crappep.nrctremp = crapepr.nrctremp
         and crappep.inliquid = 0) ultima_parcela, 
      crawepr.qtpreemp  
    FROM crapepr
    JOIN crawepr
      ON crawepr.cdcooper = crapepr.cdcooper
     AND crawepr.nrdconta = crapepr.nrdconta
     AND crawepr.nrctremp = crapepr.nrctremp
    WHERE crapepr.inliquid = 0
      AND crapepr.cdcooper = pr_cooperativa 
      AND crapepr.nrdconta = pr_conta 
      AND crapepr.nrctremp = pr_contrato;
      
BEGIN
   -- Inicializar o CLOB
   vr_texto_completo := NULL;
   vr_des_log        := NULL;
   dbms_lob.createtemporary(vr_des_log, TRUE);
   dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);
  --Cabeçalho para geração do arquivo de log
  gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,'Cooperativa;Conta;Contrato;Parcela atual;Parcela nova;Saldo devedor atual;Novo saldo devedor'|| chr(10));
  --set serveroutput on size unlimited
  DBMS_OUTPUT.ENABLE (buffer_size => NULL);
  -- Loop no cursor de 222 contratos apontados com necessidade de atualização 
  FOR ret_contrato_atualizacao IN cr_coop_conta_contrato_atualizar LOOP   
    vr_contador_cursor_contratos := vr_contador_cursor_contratos + 1;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => ret_contrato_atualizacao.PR_CDCOOPER);
    FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      RETURN;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    FOR rw_tbepr_adiamento_contrato IN cr_tbepr_adiamento_contrato (pr_dtmvtoan => rw_crapdat.dtmvtoan, 
                                                                    pr_cooperativa => ret_contrato_atualizacao.PR_CDCOOPER, 
                                                                    pr_conta => ret_contrato_atualizacao.PR_NRDCONTA, 
                                                                    pr_contrato => ret_contrato_atualizacao.PR_NRCTRATO) LOOP
      vr_tab_erro.DELETE;
      vr_tab_pgto_parcel.DELETE;
      vr_tab_calculado.DELETE;
      vr_vlparepr := 0;
      --------------------------------------------------------------------------------------------------      
      -- Calcular Juros Remuneratorio ate hoje para compor o saldo
      --------------------------------------------------------------------------------------------------                  
      --Data referencia recebe movimento
      vr_dtrefjur := rw_crapdat.dtmvtolt;
          
      --Retornar Dia/mes/ano de referencia
      vr_diarefju := to_number(to_char(vr_dtrefjur, 'DD'));
      vr_mesrefju := to_number(to_char(vr_dtrefjur, 'MM'));
      vr_anorefju := to_number(to_char(vr_dtrefjur, 'YYYY'));
          
      --Calcular Quantidade dias
      empr0001.pc_calc_dias360(pr_ehmensal => FALSE -- Indica se juros esta rodando na mensal
                              ,pr_dtdpagto => to_char(rw_tbepr_adiamento_contrato.dtdpagto, 'DD') -- Dia do primeiro vencimento do emprestimo
                              ,pr_diarefju => rw_tbepr_adiamento_contrato.diarefju -- Dia da data de referência da última vez que rodou juros
                              ,pr_mesrefju => rw_tbepr_adiamento_contrato.mesrefju -- Mes da data de referência da última vez que rodou juros
                              ,pr_anorefju => rw_tbepr_adiamento_contrato.anorefju -- Ano da data de referência da última vez que rodou juros
                              ,pr_diafinal => vr_diarefju -- Dia data final
                              ,pr_mesfinal => vr_mesrefju -- Mes data final
                              ,pr_anofinal => vr_anorefju -- Ano data final
                              ,pr_qtdedias => vr_qtdiajur); -- Quantidade de dias calculada
      --------------------------------------------------------------------------------------------------      
      -- Calcula saldo devedor atualizado
      --------------------------------------------------------------------------------------------------
      empr0001.pc_busca_pgto_parcelas(pr_cdcooper => rw_tbepr_adiamento_contrato.cdcooper
                                     ,pr_cdagenci => 0
                                     ,pr_nrdcaixa => 0
                                     ,pr_cdoperad => '1'
                                     ,pr_nmdatela => 'ATENDA'
                                     ,pr_idorigem => 5
                                     ,pr_nrdconta => rw_tbepr_adiamento_contrato.nrdconta
                                     ,pr_idseqttl => 1
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_flgerlog => 0
                                     ,pr_nrctremp => rw_tbepr_adiamento_contrato.nrctremp
                                     ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                     ,pr_nrparepr => 0
                                     ,pr_des_reto => vr_des_reto
                                     ,pr_tab_erro => vr_tab_erro
                                     ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                     ,pr_tab_calculado   => vr_tab_calculado);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;            
        ELSE
          vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
        END IF;      
        RAISE vr_exc_erro;
      END IF;
      --------------------------------------------------------------------------------------------------      
      -- Calculo do residuo (nova parcela)
      --------------------------------------------------------------------------------------------------
      vr_qtd_parcelas_restantes := rw_tbepr_adiamento_contrato.qtpreemp - vr_tab_calculado(1).qtprecal;
      -- Calcula taxa diária
      vr_taxa_diaria := round((100 * (POWER((rw_tbepr_adiamento_contrato.txmensal / 100) + 1, (1 / 30)) - 1)), 10);
      -- Valor presente com ajuste da carencia
      vr_vlr_ajust_car := NVL(vr_tab_calculado(1).vlsdeved,0) * POWER(1 + (vr_taxa_diaria / 100), vr_qtdiajur - 30);
      -- Valor da Prestacao
      vr_nova_prestacao := (vr_vlr_ajust_car * rw_tbepr_adiamento_contrato.txmensal / 100) / 
                           (1 - POWER((1 + rw_tbepr_adiamento_contrato.txmensal / 100), (-1 * vr_qtd_parcelas_restantes)));
      --Registro das alterações que serão realizdas
      dbms_output.put_line('Cooperativa/Conta/Contrato: ' || ret_contrato_atualizacao.PR_CDCOOPER || '/' || ret_contrato_atualizacao.PR_NRDCONTA || '/' || ret_contrato_atualizacao.PR_NRCTRATO);
      dbms_output.put_line('Valor atual parcela: '||rw_tbepr_adiamento_contrato.vlpreemp||' -- Saldo devedor: '||rw_tbepr_adiamento_contrato.vlsdeved);
      dbms_output.put_line('Novo valor parcela: '||vr_nova_prestacao||' -- Novo saldo devedor: '||  vr_tab_calculado(1).vlsdeved);
      --------------------------------------------------------------------------------------------------------
      -- Atualiza o valor da parcela com o valor do residuo, caso o cálculo da nova seja menor que a anterior
      --------------------------------------------------------------------------------------------------------
      IF vr_nova_prestacao < rw_tbepr_adiamento_contrato.vlpreemp THEN
        BEGIN
          UPDATE crappep SET 
            vlparepr = NVL(vr_nova_prestacao,rw_tbepr_adiamento_contrato.vlpreemp), --> Valor da parcela
            vlsdvpar = NVL(vr_nova_prestacao,rw_tbepr_adiamento_contrato.vlpreemp), --> Contem o valor do saldo devedor da parcela.
            vlsdvsji = NVL(vr_nova_prestacao,rw_tbepr_adiamento_contrato.vlpreemp)  --> Contem o saldo devedor da parcela sem juros de inadimplencia.
          WHERE crappep.cdcooper = rw_tbepr_adiamento_contrato.cdcooper
            AND crappep.nrdconta = rw_tbepr_adiamento_contrato.nrdconta
            AND crappep.nrctremp = rw_tbepr_adiamento_contrato.nrctremp
            AND crappep.inliquid = 0
            AND crappep.vlparepr = rw_tbepr_adiamento_contrato.vlpreemp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
        
      -- Registrar log
      --Cabeçalho: 'Cooperativa;Conta;Contrato;Parcela atual;Parcela nova;Saldo devedor atual;Novo saldo devedor'
      gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,rw_tbepr_adiamento_contrato.cdcooper||';'||
                                                           rw_tbepr_adiamento_contrato.nrdconta||';'||
                                                           rw_tbepr_adiamento_contrato.nrctremp||';'||
                                                           REPLACE(rw_tbepr_adiamento_contrato.vlpreemp,',','.')||';'||
                                                           REPLACE(vr_nova_prestacao,',','.')||';'||
                                                           REPLACE(rw_tbepr_adiamento_contrato.vlsdeved,',','.')||';'||
                                                           REPLACE(vr_tab_calculado(1).vlsdeved,',','.')||';'||chr(10));
      
      vr_contador_atualizados := vr_contador_atualizados + 1;
    END LOOP;
  END LOOP;
  
  -- Fecha o arquivo
  gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,' ' || chr(10),TRUE);
    
  vr_dsdireto := SISTEMA.obternomedirectory(GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cecred/matheusklug');
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log,vr_dsdireto,'contratos_PESE.csv',NLS_CHARSET_ID('UTF8'));
    
  dbms_lob.close(vr_des_log);
  dbms_lob.freetemporary(vr_des_log);

  -- Sucesso
  dbms_output.put_line('Quantidade de contratos analisados: '|| vr_contador_cursor_contratos);
  dbms_output.put_line('Quantidade de contratos atualizados: '|| vr_contador_atualizados);
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line(vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    dbms_output.put_line('Erro na atualização dos contratos de PESE. Operação abortada. Causa: ' || sqlerrm);
    ROLLBACK;
END;
