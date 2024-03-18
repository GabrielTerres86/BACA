DECLARE

  vr_module_name CONSTANT VARCHAR2(200) := 'PAGAMENTO.enviarSolicitacaoBaixaNaoConciliada';
  vr_cdcritica NUMBER;
  vr_dscritica VARCHAR2(4000);

  PROCEDURE baixarPontaRecebedora(pr_nrtitulo_npc cecred.craptit.nrdident%TYPE) IS
  
    CURSOR cr_craptit(pr_nrtitulo_npc cecred.craptit.nrdident%TYPE) IS
      SELECT tit.cdcooper
            ,tit.dtmvtolt
            ,tit.cdagenci
            ,tit.cdbccxlt
            ,tit.nrdolote
            ,tit.dscodbar
            ,tit.progress_recid
        FROM cecred.craptit tit
       WHERE nvl(tit.nrdident, 0) = pr_nrtitulo_npc
       ORDER BY tit.progress_recid DESC;
  
    reg_tituloBO_array          cecred.paga0007.typ_tituloBO_array;
    vr_pgt_titulo_prm_job_array pagamento.typ_pgt_pagamento_prm_job_array := pagamento.typ_pgt_pagamento_prm_job_array();
    vr_xml_baixa_operacional    VARCHAR2(32000);
    vr_nrprogress_recid_craptit cecred.craptit.progress_recid%TYPE;
  
  BEGIN
  
    reg_tituloBO_array.delete;
  
    OPEN cr_craptit(pr_nrtitulo_npc);
    FETCH cr_craptit BULK COLLECT
      INTO reg_tituloBO_array;
    CLOSE cr_craptit;
  
    IF nvl(reg_tituloBO_array.count, 0) > 0 THEN
    
      vr_nrprogress_recid_craptit := reg_tituloBO_array(reg_tituloBO_array.first).nrprogress_craptit;
    
      BEGIN
        UPDATE cecred.craptit tit
           SET tit.cdctrbxo = ' '
         WHERE tit.progress_recid = vr_nrprogress_recid_craptit;
      EXCEPTION
        WHEN OTHERS THEN
          sistema.excecaoInterna(pr_compleme => 'update cecred.craptit - :' ||
                                                vr_nrprogress_recid_craptit);
          RAISE;
      END;
    
      BEGIN
        UPDATE pagamento.tb_baixa_pcr_remessa tbprem
           SET tbprem.nrprogress_craptit = NULL
         WHERE tbprem.nrprogress_craptit = vr_nrprogress_recid_craptit;
      EXCEPTION
        WHEN OTHERS THEN
          sistema.excecaoInterna(pr_compleme => 'update pagamento.tb_baixa_pcr_remessa - :' ||
                                                vr_nrprogress_recid_craptit);
          RAISE;
      END;
    
      cecred.paga0007.converterTituloBOXml(pr_tituloBO => reg_tituloBO_array(reg_tituloBO_array.first)
                                          ,pr_dsxml    => vr_xml_baixa_operacional);
    
      vr_pgt_titulo_prm_job_array.extend;
      vr_pgt_titulo_prm_job_array(1) := pagamento.typ_pagamento_prm_job(dsparametro => vr_xml_baixa_operacional);
    
      PAGAMENTO.consumirJobRemessaBoAimaro(pr_pgt_pagamento_prm_job_array => vr_pgt_titulo_prm_job_array
                                          ,pr_nomejob                     => vr_module_name
                                          ,pr_numero_job                  => 0);
    
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      sistema.excecaoInterna(pr_compleme => 'baixarPontaRecebedora - ' ||
                                            TRIM(to_char(pr_nrtitulo_npc)));
      RAISE;
  END baixarPontaRecebedora;

BEGIN

  DECLARE
  
    CURSOR cr_liquidacao IS
      SELECT cob.nrdident       nrtitulo_npc
            ,cob.vldpagto
            ,ret.cdmotivo
            ,ret.cdbcorec       cdbanco_recebedor
            ,cob.progress_recid nrprogress_recid_crapcob
            ,cob.rowid          idrowid_crapcob
        FROM crapcco cco
       INNER JOIN crapret ret
          ON ret.cdcooper = cco.cdcooper
         AND ret.nrcnvcob = cco.nrconven
       INNER JOIN crapcob cob
          ON cob.cdcooper = ret.cdcooper
         AND cob.nrdconta = ret.nrdconta
         AND cob.nrcnvcob = ret.nrcnvcob
         AND cob.nrdocmto = ret.nrdocmto
         AND cob.nrnosnum = ret.nrnosnum
       INNER JOIN tbcobran_ocorrencia_liquidacao tol
          ON tol.nrboleto = cob.nrdocmto
         AND tol.nrconta_corrente = cob.nrdconta
         AND tol.nrconvenio = cob.nrcnvcob
         AND tol.nrconta_base = cob.nrdctabb
         AND tol.cdbanco_emissor = cob.cdbandoc
         AND tol.cdcooperativa = cob.cdcooper
       WHERE 1 = 1
         AND tol.idocorrencia_liquidacao IN
             (HEXTORAW('E26425116D8F441BA9D6B135001D8C84')
             ,HEXTORAW('74870C03B48445BFB242B135001DB65C')
             ,HEXTORAW('97FB00E1DDA4470AA0C2B135001D9A28')
             ,HEXTORAW('6D0FC1A7E61D496FBF4AB135001E543C')
             ,HEXTORAW('79765C8887AA4103A2E1B135001E8CC9')
             ,HEXTORAW('9366839816D44B4D9069B135001DE876')
             ,HEXTORAW('53742BB85B26418197C3B135001E1BE3')
             ,HEXTORAW('7D5DA8CC7994432BAE5CB135001DE5DA')
             ,HEXTORAW('A97E2F01822A4E8FAF32B135001E6FD9')
             ,HEXTORAW('20C2EEC42D4E4A4EB187B135001DF591'))
         AND COALESCE(cob.nrdident, 0) > 0
         AND ret.cdocorre IN (6, 17, 76, 77)
         AND ret.dtocorre < TRUNC(SYSDATE);
  
    vr_exc_erro EXCEPTION;
    vr_dtreferencia        cecred.crapdat.dtmvtolt%TYPE;
    vr_flbaixa_registrada  NUMBER(1);
    vr_cdbaixa_operacional pagamento.ta_baixa_operacional.cdbaixa_operacional%TYPE;
  
  BEGIN
  
    FOR rw_liquidacao IN cr_liquidacao LOOP
      
      vr_flbaixa_registrada := PAGAMENTO.verificarBaixaRegistradaAilos(pr_nrtitulo_npc => rw_liquidacao.nrtitulo_npc);
    
      IF COALESCE(vr_flbaixa_registrada, 0) = 1 THEN
        CONTINUE;
      END IF;
    
      vr_flbaixa_registrada := PAGAMENTO.verificarBaixaRegistradaAcmp615(pr_nrtitulo_npc => rw_liquidacao.nrtitulo_npc);
    
      IF COALESCE(vr_flbaixa_registrada, 0) = 1 THEN
        CONTINUE;
      END IF;
    
      vr_flbaixa_registrada := PAGAMENTO.verificarBaixaRegistradaRr2(pr_nrtitulo_npc => rw_liquidacao.nrtitulo_npc);
    
      IF COALESCE(vr_flbaixa_registrada, 0) = 1 THEN
        CONTINUE;
      END IF;
    
      IF rw_liquidacao.cdbanco_recebedor <> 85 THEN
      
        vr_cdbaixa_operacional := 8;
      
        pagamento.prepararRemessaBaixaAvulsaAimaro(pr_rowid_cob => rw_liquidacao.idrowid_crapcob
                                                  ,pr_tpdbaixa  => vr_cdbaixa_operacional
                                                  ,pr_cdcritic  => vr_cdcritica
                                                  ,pr_dscritic  => vr_dscritica);
      
        IF COALESCE(vr_cdcritica, 0) > 0 OR TRIM(vr_dscritica) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      ELSE
      
        baixarPontaRecebedora(pr_nrtitulo_npc => rw_liquidacao.nrtitulo_npc);
      
      END IF;
    
      COMMIT;
    
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF COALESCE(vr_cdcritica, 0) > 0 AND TRIM(vr_dscritica) IS NULL THEN
        vr_cdcritica := COALESCE(vr_cdcritica, 0);
        vr_dscritica := CECRED.gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritica);
      END IF;
      ROLLBACK;
      raise_application_error(-20001
                             ,vr_module_name || ':' || NVL(vr_cdcritica, 0) || '-' || vr_dscritica);
  END;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441');
      ROLLBACK;
      RAISE;
    END;
END;
