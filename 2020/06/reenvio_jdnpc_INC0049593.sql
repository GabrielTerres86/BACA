DECLARE
  --
  CURSOR cr_boletos IS
    SELECT cob.rowid
          ,cob.dtvencto
          ,cob.vldescto
          ,cob.vlabatim
          ,cob.flgdprot
      FROM crapcob cob
     INNER JOIN crapcol col
        ON cob.cdcooper = col.cdcooper
       AND cob.nrdconta = col.nrdconta
       AND cob.nrdocmto = col.nrdocmto
       AND cob.nrcnvcob = col.nrcnvcob
     INNER JOIN crapass ass
        ON cob.cdcooper = ass.cdcooper
       AND cob.nrdconta = ass.nrdconta
     INNER JOIN cecredleg.vwjdddabnf_sit_beneficiario@jdnpcsql vwjd
        ON ass.nrcpfcgc = vwjd."CNPJ_CPFBenfcrio"
     WHERE cob.dtvencto > trunc(SYSDATE)
       AND cob.incobran = 0
       AND col.dtaltera BETWEEN
           to_date('10/05/2020 23:59:00'
                  ,'DD/MM/YYYY HH24:MI:SS') AND SYSDATE
       AND col.dslogtit LIKE '%EDDA0814%'
       AND vwjd."SITCIP" IS NULL;
  --
  TYPE typ_boleto IS RECORD(
     rowidcob ROWID
    ,dtvencto crapcob.dtvencto%TYPE
    ,vldescto crapcob.vldescto%TYPE
    ,vlabatim crapcob.vlabatim%TYPE
    ,flgdprot crapcob.flgdprot%TYPE
    ,cdcooper crapcob.cdcooper%TYPE);
  TYPE typ_boletos IS TABLE OF typ_boleto INDEX BY BINARY_INTEGER;
  vr_boletos typ_boletos;
  --
  vr_tab_remessa_dda ddda0001.typ_tab_remessa_dda;
  vr_tab_retorno_dda ddda0001.typ_tab_retorno_dda;
  vr_cdcritic        NUMBER;
  vr_dscritic        VARCHAR2(32000);
  --
  PROCEDURE pc_raise_error(pr_dsmensag IN VARCHAR2
                          ,pr_cdcritic IN crapcri.cdcritic%TYPE
                          ,pr_dscritic IN VARCHAR2
                          ,pr_idempilh IN BOOLEAN) IS
    --
    /*recebe a critica como parametro trata a descricao e o código e executa um raise*/
    --
    vr_cdcritic NUMBER(5) := pr_cdcritic;
    vr_dscritic VARCHAR2(4000) := pr_dscritic;
    --
  BEGIN
    --
    IF nvl(vr_cdcritic
          ,0) > 0
       OR TRIM(vr_dscritic) IS NOT NULL THEN
      IF nvl(vr_cdcritic
            ,0) > 0
         AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      raise_application_error(-20001
                             ,pr_dsmensag || vr_dscritic
                             ,pr_idempilh);
    END IF;
    --
  END pc_raise_error;
  --
  PROCEDURE pc_atualiza_status_envio_dda(pr_tab_remessa_dda IN OUT ddda0001.typ_tab_remessa_dda) IS
    --
    vr_index    INTEGER;
    vr_dscmplog VARCHAR2(200);
    vr_des_erro VARCHAR2(10);
    vr_dscritic VARCHAR2(4000);
    --
  BEGIN
    --
    vr_index := pr_tab_remessa_dda.first;
    --
    WHILE vr_index IS NOT NULL LOOP
      -- Verifica se ocorreu erro
      IF TRIM(pr_tab_remessa_dda(vr_index).dscritic) IS NOT NULL THEN
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 0 -- FALSE
                ,insitpro = 0
                ,idtitleg = 0
                ,idopeleg = 0
                ,inenvcip = 0 -- não enviar
                ,dhenvcip = NULL
           WHERE ROWID = pr_tab_remessa_dda(vr_index).rowidcob;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20001
                                   ,'update crapcob 01'
                                   ,TRUE);
        END;
      ELSE
        -- Atualizar CRAPCOB 
        BEGIN
          UPDATE crapcob
             SET flgcbdda = 1 -- TRUE
                ,insitpro = 2 -- recebido JD
                ,inenvcip = 2 -- enviado
                ,dhenvcip = SYSDATE
           WHERE ROWID = pr_tab_remessa_dda(vr_index).rowidcob;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20001
                                   ,'update crapcob 02'
                                   ,TRUE);
        END;
        -- Incluir o log do boleto
        paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_tab_remessa_dda(vr_index).rowidcob
                                     ,pr_cdoperad => 1
                                     ,pr_dtmvtolt => SYSDATE
                                     ,pr_dsmensag => 'Titulo enviado a CIP manualmente'
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        -- se ocorrer erro
        IF vr_des_erro <> 'OK' THEN
          raise_application_error(-20001
                                 ,'Cria log: ' || vr_dscritic);
        END IF;
        --
      END IF;
      --
      vr_index := pr_tab_remessa_dda.next(vr_index);
      --
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      pc_internal_exception;
  END pc_atualiza_status_envio_dda;
  --
BEGIN
  OPEN cr_boletos;
  FETCH cr_boletos BULK COLLECT
    INTO vr_boletos;
  CLOSE cr_boletos;
  --
  COMMIT;
  --
  FOR vr_index IN 1 .. vr_boletos.count LOOP
    --
    ddda0001.pc_cria_remessa_dda(pr_rowid_cob       => vr_boletos(vr_index).rowidcob
                                ,pr_tpoperad        => 'I'
                                ,pr_tpdbaixa        => NULL
                                ,pr_dtvencto        => vr_boletos(vr_index).dtvencto
                                ,pr_vldescto        => vr_boletos(vr_index).vldescto
                                ,pr_vlabatim        => vr_boletos(vr_index).vlabatim
                                ,pr_flgdprot        => (CASE
                                                        vr_boletos(vr_index).flgdprot
                                                         WHEN 0 THEN
                                                          FALSE
                                                         ELSE
                                                          TRUE
                                                       END)
                                ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);
    --
  END LOOP;
  --
  BEGIN
    --
    IF nvl(vr_tab_remessa_dda.count
          ,0) > 0 THEN
      --
      ddda0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                     ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                     ,pr_cdcritic        => vr_cdcritic
                                     ,pr_dscritic        => vr_dscritic);
      -- Verificar se ocorreu erro
      pc_raise_error('ddda0001.pc_remessa_tit_tab_dda:'
                    ,vr_cdcritic
                    ,vr_dscritic
                    ,FALSE);
      --
      -- Atualizar status da remessa de títulos DDA      
      pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tab_remessa_dda);
      --
      COMMIT;
      --
    END IF;
    --
  EXCEPTION
    WHEN OTHERS THEN
      pc_internal_exception;
      ROLLBACK;
  END;
  --
END;
