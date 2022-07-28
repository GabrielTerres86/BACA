-- Created on 26/07/2022 by T0034436 
DECLARE
  -- Local variables here
  vr_cdcritic pls_integer;
  vr_dscritic varchar2(10000);  
  vr_dtmvtopg date;  
 
  PROCEDURE pc_gera_ret_tit_pago (pr_cdcooper      IN cecred.crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN cecred.crapope.cdoperad%TYPE  -- Operador
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

     CURSOR cr_crapdpt(pr_cdcooper IN cecred.crapdpt.cdcooper%TYPE
                      ,pr_dtmvtopg IN cecred.crapdpt.dtmvtopg%TYPE) IS
        SELECT cdcooper,
               nrdconta,
               nrconven,
               intipmvt,
               nrremret,
               nrseqarq,
               cdtipmvt,
               cdinsmvt,
               dscodbar,
               nmcedent,
               vltitulo,
               vldescto,
               vlacresc,
               dtdpagto,
               vldpagto,
               dsusoemp,
               dsnosnum,
               cdocorre,
               intipreg,
               inpessoa_pagador,
               nrcpfcgc_pagador,
               nmpagador,
               nrcpfcgc_beneficiario,
               nmbeneficiario,
               insitlau,
               dtmvtopg,
               dtvencto,
               idlancto,
               nmarquiv,
               row_number() OVER(PARTITION BY nrdconta ORDER BY nrdconta) sqatureg,
               COUNT(1) OVER(PARTITION BY nrdconta) qtregtot
          FROM (
                /*select que retorna os registros incluídos antes da melhoria 271.3*/
                SELECT dpt.cdcooper,
                       dpt.nrdconta,
                       dpt.nrconven,
                       dpt.intipmvt,
                       dpt.nrremret,
                       dpt.nrseqarq,
                       dpt.cdtipmvt,
                       dpt.cdinsmvt,
                       dpt.dscodbar,
                       dpt.nmcedent,
                       dpt.vltitulo,
                       dpt.vldescto,
                       dpt.vlacresc,
                       dpt.dtdpagto,
                       dpt.vldpagto,
                       dpt.dsusoemp,
                       dpt.dsnosnum,
                       dpt.cdocorre,
                       dpt.intipreg,
                       dpt.inpessoa_pagador,
                       dpt.nrcpfcgc_pagador,
                       dpt.nmpagador,
                       dpt.nrcpfcgc_beneficiario,
                       dpt.nmbeneficiario,
                       lau.insitlau,
                       lau.dtmvtopg,
                       lau.dtvencto,
                       lau.idlancto,
                       hpt.nmarquiv
                  FROM cecred.craplau lau, cecred.craphpt hpt, cecred.crapdpt dpt
                 WHERE lau.dscodbar = dpt.dscodbar || ''
                   AND lau.cdtiptra = 2 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.cdhistor = 508 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.nrdctabb = 0 -- fixo pgta0001.pc_cadastrar_agend_pgto insere null e assume valor default
                   AND lau.nrdolote = 11900 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.cdbccxlt = 100 -- fixo pgta0001.pc_cadastrar_agend_pgto
                   AND lau.cdagenci = 90 -- fixo pgta0001.pc_processar_arq_pgto
                   AND lau.dtmvtolt >= hpt.dtmvtolt + 0
                   AND lau.nrdconta = dpt.nrdconta + 0
                   AND lau.cdcooper = dpt.cdcooper + 0
                   AND lau.insitlau IN (2, 4) -- 2-efetivado ou 4-nao efetivado
                      --
                   AND hpt.nrremret = dpt.nrremret + 0
                   AND hpt.intipmvt = dpt.intipmvt + 0
                   AND hpt.nrconven = dpt.nrconven + 0
                   AND hpt.nrdconta = dpt.nrdconta + 0
                   AND hpt.cdcooper = dpt.cdcooper + 0
                      --
                   AND dpt.idlancto IS NULL
                   AND dpt.intipmvt = 2 -- retorno
                   AND dpt.cdtipmvt = 0 -- inclusao
                   AND dpt.cdocorre = 'BD' -- inclusao sucesso
                   AND dpt.dtmvtopg = pr_dtmvtopg
                   AND dpt.cdcooper = pr_cdcooper
                UNION ALL
                /*select que retorna os registros incluídos após a melhoria 271.3*/
                SELECT dpt.cdcooper,
                       dpt.nrdconta,
                       dpt.nrconven,
                       dpt.intipmvt,
                       dpt.nrremret,
                       dpt.nrseqarq,
                       dpt.cdtipmvt,
                       dpt.cdinsmvt,
                       dpt.dscodbar,
                       dpt.nmcedent,
                       dpt.vltitulo,
                       dpt.vldescto,
                       dpt.vlacresc,
                       dpt.dtdpagto,
                       dpt.vldpagto,
                       dpt.dsusoemp,
                       dpt.dsnosnum,
                       dpt.cdocorre,
                       dpt.intipreg,
                       dpt.inpessoa_pagador,
                       dpt.nrcpfcgc_pagador,
                       dpt.nmpagador,
                       dpt.nrcpfcgc_beneficiario,
                       dpt.nmbeneficiario,
                       lau.insitlau,
                       lau.dtmvtopg,
                       lau.dtvencto,
                       lau.idlancto,
                       hpt.nmarquiv
                  FROM cecred.craplau lau, cecred.crapdpt dpt, cecred.craphpt hpt
                 WHERE lau.insitlau IN (2, 4) -- 2-efetivado ou 4-nao efetivado
                   AND lau.idlancto = dpt.idlancto + 0
                      --
                   AND hpt.nrremret = dpt.nrremret + 0
                   AND hpt.intipmvt = dpt.intipmvt + 0
                   AND hpt.nrconven = dpt.nrconven + 0
                   AND hpt.nrdconta = dpt.nrdconta + 0
                   AND hpt.cdcooper = dpt.cdcooper + 0
                      --
                   AND dpt.idlancto IS NOT NULL
                   AND dpt.intipmvt = 2 -- retorno
                   AND dpt.cdtipmvt = 0 -- inclusao
                   AND dpt.cdocorre = 'BD' -- inclusao sucesso
                   AND dpt.dtmvtopg = pr_dtmvtopg
                   AND dpt.cdcooper = pr_cdcooper
                UNION ALL
                /*select que retorna os registros pagos/rejeitados de transacoes pendentes*/
                SELECT dpt.cdcooper,
                       dpt.nrdconta,
                       dpt.nrconven,
                       dpt.intipmvt,
                       dpt.nrremret,
                       dpt.nrseqarq,
                       dpt.cdtipmvt,
                       dpt.cdinsmvt,
                       dpt.dscodbar,
                       dpt.nmcedent,
                       dpt.vltitulo,
                       dpt.vldescto,
                       dpt.vlacresc,
                       dpt.dtdpagto,
                       dpt.vldpagto,
                       dpt.dsusoemp,
                       dpt.dsnosnum,
                       decode(gen.idsituacao_transacao,2,'00','03') cdocorre,
                       dpt.intipreg,
                       dpt.inpessoa_pagador,
                       dpt.nrcpfcgc_pagador,
                       dpt.nmpagador,
                       dpt.nrcpfcgc_beneficiario,
                       dpt.nmbeneficiario,
                       decode(gen.idsituacao_transacao,2,2,3) insitlau, -- lau.insitlau,
                       pag.dtdebito dtmvtopg, -- lau.dtmvtopg,
                       pag.dtvencimento dtvencto, -- lau.dtvencto,
                       NULL idlancto, -- lau.idlancto,
                       hpt.nmarquiv
                  FROM cecred.tbgen_trans_pend gen, cecred.tbpagto_trans_pend pag, cecred.crapdpt dpt, cecred.craphpt hpt
                 WHERE 
                       gen.cdcooper = pr_cdcooper
                   and gen.dtmvtolt = pr_dtmvtopg
                   and gen.tptransacao = 2 -- pagamentos
                   and gen.idsituacao_transacao in (2,3,4,5,6) -- (1 ¿ Pendente / 2 ¿ Aprovada / 3 ¿ Excluida / 4 ¿ Expirada / 5 ¿ Parcialmente Aprovada / 6 ¿ Reprovada)
                   --
                   and pag.cdtransacao_pendente = gen.cdtransacao_pendente
                   and pag.idagendamento = 1 -- online 
                   --
                   and dpt.cdcooper = pag.cdcooper
                   and dpt.nrdconta = pag.nrdconta
                   and dpt.dtmvtopg = pr_dtmvtopg
                   and dpt.dscodbar = pag.dscodigo_barras
                   AND dpt.intipmvt = 2 -- retorno
                   AND dpt.cdtipmvt = 0 -- inclusao                  
                   and dpt.cdocorre = 'BD'
                   and dpt.idlancto is null                  
                      --
                   AND hpt.nrremret = dpt.nrremret + 0
                   AND hpt.intipmvt = dpt.intipmvt + 0
                   AND hpt.nrconven = dpt.nrconven + 0
                   AND hpt.nrdconta = dpt.nrdconta + 0
                   AND hpt.cdcooper = dpt.cdcooper + 0)                                  
         ORDER BY nrdconta;      
     rw_crapdpt cr_crapdpt%ROWTYPE;

     -- Buscar ultimo numero de retorno utilizado
     CURSOR cr_craphpt(pr_cdcooper IN cecred.craphpt.cdcooper%TYPE     --> Código da cooperativa
                      ,pr_nrdconta IN cecred.craphpt.nrdconta%TYPE     --> Numero da Conta
                      ,pr_nrconven IN cecred.craphpt.nrconven%TYPE) IS --> Numero do Convenio
      SELECT NVL(MAX(nrremret),0) nrremret
        FROM cecred.craphpt
       WHERE cecred.craphpt.cdcooper = pr_cdcooper
         AND cecred.craphpt.nrdconta = pr_nrdconta
         AND cecred.craphpt.nrconven = pr_nrconven
         AND cecred.craphpt.intipmvt = 2 -- Retorno
       ORDER BY cecred.craphpt.cdcooper,
                cecred.craphpt.nrdconta,
                cecred.craphpt.nrconven,
                cecred.craphpt.intipmvt;
     rw_craphpt cr_craphpt%ROWTYPE;

     vr_cdcritic_aux cecred.crapcri.cdcritic%TYPE;
     vr_dscritic_aux VARCHAR2(4000);

     vr_nrremret cecred.craphpt.nrremret%TYPE;
     vr_nmarquiv cecred.craphpt.nmarquiv%TYPE;
     vr_cdtipmvt cecred.crapdpt.cdtipmvt%TYPE;
     vr_cdinsmvt cecred.crapdpt.cdinsmvt%TYPE;
     vr_cdocorre VARCHAR2(5);
     vr_nrseqarq cecred.crapdpt.nrseqarq%TYPE;

     vr_exc_critico EXCEPTION;
     vr_dtmvtolt DATE;
     
     --Tipo de Dados para cursor data
     rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

     BEGIN
       
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Se não encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
          RAISE vr_exc_critico;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;
              
        -- Armazenar a data de movimento do dia
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
     
        -- Gerar Informação de Retorno ao Cooperado - Efetivacao do Pagametno (.RET)

        -- Ler todos os registros da crapdpt (Retorno) e gravar na crapdpt (Liquidado)
        FOR rw_crapdpt IN cr_crapdpt(pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtopg => pr_dtmvtolt) LOOP

           IF rw_crapdpt.sqatureg = 1 THEN  -- Primeiro Registro - FIRST-OF do NrdConta

              vr_nrremret := 0;
              vr_nrseqarq := 0;
              vr_nmarquiv := '';

              -- Buscar o Último Lote de Retorno do Cooperado
              OPEN cr_craphpt(pr_cdcooper => rw_crapdpt.cdcooper
                             ,pr_nrdconta => rw_crapdpt.nrdconta
                             ,pr_nrconven => rw_crapdpt.nrconven);
              FETCH cr_craphpt INTO rw_craphpt;
              -- Verifica se a retornou registro
              IF cr_craphpt%NOTFOUND THEN
                 CLOSE cr_craphpt;
                 -- Numero de Retorno
                 vr_nrremret := 1;
              ELSE
                 CLOSE cr_craphpt;
                 -- Numero de Retorno
                 vr_nrremret := rw_craphpt.nrremret + 1;
              END IF;

              vr_nmarquiv := 'PGT_' || TRIM(to_char(rw_crapdpt.nrdconta,'00000000'))  || '_' ||
                                       TRIM(to_char(vr_nrremret,'000000000')) || '.RET';

              -- Criar Lote de Informações de Retorno (craphpt)
              BEGIN
                 INSERT INTO cecred.craphpt
                     (cdcooper,
                      nrdconta,
                      nrconven,
                      intipmvt,
                      nrremret,
                      dtmvtolt,
                      nmarquiv,
                      idorigem,
                      dtdgerac,
                      hrdgerac,
                      insithpt,
                      cdoperad)
                   VALUES
                     (rw_crapdpt.cdcooper,
                      rw_crapdpt.nrdconta,
                      rw_crapdpt.nrconven,
                      2, -- Retorno
                      vr_nrremret,
                      pr_dtmvtolt,
                      vr_nmarquiv,
                      pr_idorigem,
                      TRUNC(SYSDATE),
                      to_char(SYSDATE,'HH24MISS'),
                      2, -- Processado
                      pr_cdoperad);

              IF SQL%ROWCOUNT = 0 THEN
                 RAISE vr_exc_critico;
              END IF;

              EXCEPTION
                 WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'PGTA0001.pc_gera_retorno_tit_pago: ' ||
                                   'Erro ao inserir CRAPHPT: ' || SQLERRM;

                    cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                                ,pr_compleme => vr_dscritic);
         
                    -- Gerar o LOG do erro que aconteceu durante o processamento
                    PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                                 ,pr_nrdconta => rw_crapdpt.nrdconta
                                                 ,pr_nrconven => rw_crapdpt.nrconven
                                                 ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                                 ,pr_nrremret => rw_crapdpt.nrremret -- Numero da Remessa do Cooperado
                                                 ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                                 ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                                 ,pr_cdprograma => 'pc_gera_retorno_tit_pago'
                                                 ,pr_nmtabela => 'CRAPHPT'
                                                 ,pr_nmarquivo => rw_crapdpt.nmarquiv
                                                 ,pr_dsmsglog => vr_dscritic
                                                 ,pr_cdcritic => vr_cdcritic_aux
                                                 ,pr_dscritic => vr_dscritic_aux);                    

                    pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                                  ,pr_nrdconta => rw_crapdpt.nrdconta
                                                  ,pr_nmarquiv => 'PGTA0001.PC_GERA_RETORNO_TIT_PAGO'
                                                  ,pr_textolog => vr_dscritic
                                                  ,pr_cdcritic => vr_cdcritic_aux
                                                  ,pr_dscritic => vr_dscritic_aux);

                    RAISE vr_exc_critico;
              END;
           END IF;

           vr_nrseqarq := nvl(vr_nrseqarq,0) + 1;

           IF rw_crapdpt.insitlau = 2 THEN -- PAGO
              vr_cdtipmvt := 7; -- LIQUIDADO
              vr_cdinsmvt := 0;
              vr_cdocorre := '00';
           ELSIF rw_crapdpt.insitlau = 3 THEN  -- CANCELADO
              vr_cdtipmvt := 3; -- ESTORNO
              vr_cdinsmvt := 33;
              vr_cdocorre := '02';              
           ELSIF rw_crapdpt.insitlau = 4  THEN -- SALDO INFERIOR
              vr_cdtipmvt := 3; -- ESTORNO
              vr_cdinsmvt := 33;
              vr_cdocorre := '01';
           END IF;

           -- Insere dados na tabela crapdpt
           BEGIN
              INSERT INTO cecred.crapdpt
                 (cdcooper,
                 nrdconta,
                 nrconven,
                 intipmvt,
                 nrremret,
                 nrseqarq,
                 cdtipmvt,
                 cdinsmvt,
                 dscodbar,
                 nmcedent,
                 dtvencto,
                 vltitulo,
                 vldescto,
                 vlacresc,
                 dtdpagto,
                 vldpagto,
                 dsusoemp,
                 dsnosnum,
                 cdocorre,
                 dtmvtopg,
                 intipreg,
                 tpmvtorg,
                 nrmvtorg,
                 nrarqorg,
                 idlancto,
                 inpessoa_pagador,
                 nrcpfcgc_pagador,
                 nmpagador,
                 nrcpfcgc_beneficiario,
                 nmbeneficiario)
              VALUES
                (rw_crapdpt.cdcooper,
                 rw_crapdpt.nrdconta,
                 rw_crapdpt.nrconven,
                 2, -- Retorno
                 vr_nrremret,
                 vr_nrseqarq,
                 vr_cdtipmvt,
                 vr_cdinsmvt,
                 rw_crapdpt.dscodbar,
                 rw_crapdpt.nmcedent,
                 rw_crapdpt.dtvencto,
                 rw_crapdpt.vltitulo,
                 rw_crapdpt.vldescto,
                 rw_crapdpt.vlacresc,
                 rw_crapdpt.dtdpagto,
                 rw_crapdpt.vldpagto,
                 rw_crapdpt.dsusoemp,
                 rw_crapdpt.dsnosnum,
                 vr_cdocorre,
                 rw_crapdpt.dtmvtopg,
                 rw_crapdpt.intipreg,
                 rw_crapdpt.intipmvt,
                 rw_crapdpt.nrremret,
                 rw_crapdpt.nrseqarq,
                 rw_crapdpt.idlancto,
                 rw_crapdpt.inpessoa_pagador,
                 rw_crapdpt.nrcpfcgc_pagador,
                 rw_crapdpt.nmpagador,
                 rw_crapdpt.nrcpfcgc_beneficiario,
                 rw_crapdpt.nmbeneficiario);

           IF SQL%ROWCOUNT = 0 THEN
               RAISE vr_exc_critico;
           END IF;

           EXCEPTION
              WHEN OTHERS THEN
                 vr_cdcritic := 0;
                 vr_dscritic := 'PGTA0001.pc_gera_retorno_tit_pago: ' ||
                                'Erro ao inserir CRAPDPT: '||SQLERRM;
                 cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                             ,pr_compleme => vr_dscritic);
         
                 -- Gerar o LOG do erro que aconteceu durante o processamento
                 PGTA0001.pc_gera_log_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                              ,pr_nrdconta => rw_crapdpt.nrdconta
                                              ,pr_nrconven => rw_crapdpt.nrconven
                                              ,pr_tpmovimento => 2 -- Movimento de RETORNO
                                              ,pr_nrremret => rw_crapdpt.nrremret -- Numero da Remessa do Cooperado
                                              ,pr_cdoperad => '1' -- SUPER USUÁRIO
                                              ,pr_nmoperad_online => NULL -- Nao existe operador logado
                                              ,pr_cdprograma => 'pc_gera_retorno_tit_pago'
                                              ,pr_nmtabela => 'CRAPHPT'
                                              ,pr_nmarquivo => rw_crapdpt.nmarquiv
                                              ,pr_dsmsglog => vr_dscritic
                                              ,pr_cdcritic => vr_cdcritic_aux
                                              ,pr_dscritic => vr_dscritic_aux);                    

                 pgta0001.pc_logar_cst_arq_pgto(pr_cdcooper => rw_crapdpt.cdcooper
                                               ,pr_nrdconta => rw_crapdpt.nrdconta
                                               ,pr_nmarquiv => 'PGTA0001.PC_GERA_RETORNO_TIT_PAGO'
                                               ,pr_textolog => vr_dscritic
                                               ,pr_cdcritic => vr_cdcritic_aux
                                               ,pr_dscritic => vr_dscritic_aux);

                 RAISE vr_exc_critico;
           END;

        END LOOP;

        -- Salva Alterações Efetuadas
        --COMMIT; -- Controlado pelo CRPS509

    EXCEPTION
       WHEN vr_exc_critico THEN
          -- Atualiza campo de erro
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic  || SQLERRM;
          -- ROLLBACK; -- Controlado pelo CRPS509
       WHEN OTHERS THEN
          -- Atualiza campo de erro
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic  || SQLERRM;
          --- ROLLBACK; -- Controlado pelo CRPS509

    END pc_gera_ret_tit_pago;  

BEGIN
    dbms_output.put_line(to_char(sysdate, 'dd/mm/rrrr hh24:mi:ss') || 
                         ' >> Inicio da geração arquivos de pagamento.'||chr(13));                         

    vr_dtmvtopg:= to_date('13/07/2022');

    pc_gera_ret_tit_pago(pr_cdcooper => 1
                       , pr_dtmvtolt => vr_dtmvtopg
                       , pr_idorigem => 3
                       , pr_cdoperad => '1'
                       , pr_cdcritic => vr_cdcritic
                       , pr_dscritic => vr_dscritic );
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
       --Levantar Excecao
       dbms_output.put_line('Erro ao executar PGTA0001.pc_gera_retorno_tit_pago: '|| vr_dscritic||chr(13));
    END IF;
  
    dbms_output.put_line(to_char(sysdate, 'dd/mm/rrrr hh24:mi:ss') || 
                         ' >> Final da geração arquivos de pagamento.');

    COMMIT;
EXCEPTION
 WHEN OTHERS THEN
   RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);    
END;
