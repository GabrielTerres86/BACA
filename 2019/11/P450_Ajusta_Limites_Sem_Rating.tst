PL/SQL Developer Test script 3.0
170
declare 
  vr_retxml      xmltype;
  vr_cdcritic    crapcri.cdcritic%TYPE; --> cód. erro
  vr_dscritic    VARCHAR2(1000); --> desc. erro
  vr_retorno     BOOLEAN DEFAULT(FALSE);
  vr_contador    INTEGER;

     
  --Buscar todas as cooperativas ativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3 --Não deve rodar para a Central AILOS
     ORDER BY cop.cdcooper DESC;
  rw_crapcop   cr_crapcop%ROWTYPE;
  
  CURSOR cr_semRating (pr_cdcooper  IN crapcop.cdcooper%TYPE) IS
    SELECT t.cdcooper                  cdcooper          --Codigo que identifica a Cooperativa
          ,t.nrdconta                  nrdconta          --Numero da conta/dv do associado
          ,t.nrctrlim                  nrctremp          --Numero do contrato da operacao que gera rating
          ,t.tpctrlim                  tpctrato          --Tipo de contrato da operacao que gera rating
          ,NULL                        inrisco_rating    --Indicador de risco (AA ate HH)
          ,d.dtmvtolt                  dtrisco_rating    --Data de efetivacao do rating
          ,'1'                         cdoperad_rating   --Codigo do operador
          ,3                           insituacao_rating --Situacao do rating (3-Vencido)
          ,NULL                        inpontos_rating   --Nota atingida na soma dos itens do rating
          ,a.nrcpfcnpj_base            nrcpfcnpj_base    --Numero do CPF/CNPJ Base do associado
          ,a.inpessoa                  inpessoa          --Tipo Pessoa
          ,2                           innivel_rating    --Nível de Risco
          ,3                           inorigem_rating   --Origem do Rating (3-Regra Aimaro)
          ,(d.dtmvtolt + 180)          dtvencto_rating   -- Data vencimento rating
          ,1                           flintegrar_sas    --Flag para indicar se o contrato deve integrar com o SAS
      FROM craplim t, crapass a, crapdat d
     WHERE t.cdcooper = pr_cdcooper
       AND d.cdcooper = t.cdcooper
       AND a.cdcooper = t.cdcooper
       AND a.nrdconta = t.nrdconta
       AND t.tpctrlim = 1         -- LIMITE CREDITO
       AND t.insitlim <> 3       -- NÃO CANCELADOS
       AND NOT EXISTS (SELECT 1  -- QUE NÃO EXISTAM NA TBRISCO_OPERACOES
                         FROM tbrisco_operacoes w
                        WHERE w.cdcooper = t.cdcooper
                          AND w.nrdconta = t.nrdconta
                          AND w.nrctremp = t.nrctrlim
                          AND w.tpctrato = t.tpctrlim)
     ORDER BY t.cdcooper, t.nrdconta, t.nrctrlim;
  rw_semRating   cr_semRating%ROWTYPE;

  
BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP

    vr_contador := 0;
    FOR rw_semRating IN cr_semRating(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      vr_contador := vr_contador + 1;

      BEGIN      
        -------------------------------------------------
        --- Gravação do Rating para Limites Sem Rating
        -------------------------------------------------
         INSERT INTO tbrisco_operacoes
                   ( cdcooper
                    ,nrdconta
                    ,nrctremp
                    ,tpctrato
                    ,inrisco_rating
                    ,inrisco_rating_autom
                    ,dtrisco_rating
                    ,insituacao_rating
                    ,inorigem_rating
                    ,cdoperad_rating
                    ,dtrisco_rating_autom
                    ,innivel_rating
                    ,nrcpfcnpj_base
                    ,inpessoa
                    ,inpontos_rating
                    ,insegmento_rating
                    ,dtvencto_rating
                    ,qtdiasvencto_rating
                    ,flintegrar_sas)
             VALUES
                   ( rw_semRating.Cdcooper
                    ,rw_semRating.Nrdconta
                    ,rw_semRating.Nrctremp
                    ,rw_semRating.Tpctrato
                    ,rw_semRating.Inrisco_Rating
                    ,rw_semRating.Inrisco_Rating
                    ,rw_semRating.Dtrisco_Rating
                    ,rw_semRating.Insituacao_Rating
                    ,rw_semRating.Inorigem_Rating
                    ,rw_semRating.Cdoperad_Rating
                    ,rw_semRating.Dtrisco_Rating
                    ,rw_semRating.Innivel_Rating
                    ,rw_semRating.Nrcpfcnpj_Base
                    ,rw_semRating.Inpessoa
                    ,rw_semRating.Inpontos_Rating
                    ,NULL
                    ,rw_semRating.Dtvencto_Rating
                    ,180
                    ,rw_semRating.Flintegrar_Sas);

         --Deverá ser colocado o log aqui. Até o momento a tabela ainda não foi criada.
         vr_retorno := RATI0003.fn_registra_historico(pr_cdcooper    => rw_semRating.cdcooper
                                                     ,pr_cdoperad    => rw_semRating.Cdoperad_Rating
                                                     ,pr_nrdconta    => rw_semRating.nrdconta
                                                     ,pr_nrctro      => rw_semRating.Nrctremp
                                                     ,pr_dtmvtolt    => rw_semRating.Dtrisco_Rating
                                                     ,pr_valor       => NULL
                                                     ,pr_tpctrato     => rw_semRating.Tpctrato
                                                     ,pr_rating_sugerido      => NULL
                                                     ,pr_justificativa        => 'Re-Carga Inicial Limites Credito [SAS=1 / Rating=Nulo]'
                                                     ,pr_inrisco_rating       => rw_semRating.Inrisco_Rating
                                                     ,pr_inrisco_rating_autom => rw_semRating.Inrisco_Rating
                                                     ,pr_dtrisco_rating_autom => rw_semRating.Dtrisco_Rating
                                                     ,pr_dtrisco_rating       => rw_semRating.Dtrisco_Rating
                                                     ,pr_insituacao_rating    => rw_semRating.Insituacao_Rating
                                                     ,pr_inorigem_rating      => rw_semRating.Inorigem_Rating
                                                     ,pr_cdoperad_rating      => rw_semRating.Cdoperad_Rating
                                                     ,pr_tpoperacao_rating    => NULL
                                                     ,pr_retxml               => vr_retxml
                                                     ,pr_cdcritic             => vr_cdcritic
                                                     ,pr_dscritic             => vr_dscritic);

         IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 1, 
                                     pr_des_log      => 'Erro ao inserir/atualizar LOG Risco Operações: ' ||
                                                         ' [' || rw_semRating.Cdcooper || '|'||
                                                         rw_semRating.Nrdconta         || '|'||
                                                         rw_semRating.Nrctremp         || '|'||
                                                         rw_semRating.Tpctrato         || '] => '||
                                                         SQLERRM,
                                     pr_dstiplog     => NULL,
                                     pr_nmarqlog     => 'LOG_Limites_Erro_Carga',
                                     pr_cdprograma   => 'CARGAINI',
                                     pr_tpexecucao   => 2);
         END IF;
        -------------------------------------------------
      EXCEPTION
        WHEN OTHERS THEN

          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 1, 
                                     pr_des_log      => 'Erro ao inserir/atualizar Risco Operações: ' ||
                                                         ' [' || rw_semRating.Cdcooper || '|'||
                                                         rw_semRating.Nrdconta         || '|'||
                                                         rw_semRating.Nrctremp         || '|'||
                                                         rw_semRating.Tpctrato         || '] => '||
                                                         SQLERRM,
                                     pr_dstiplog     => NULL,
                                     pr_nmarqlog     => 'LOG_Limites_Erro_Carga',
                                     pr_cdprograma   => 'CARGAINI',
                                     pr_tpexecucao   => 2);
      END;

      -- COMMIT a cada 100 registros
      IF (vr_contador MOD 100) = 0 THEN
        COMMIT;
      END IF;

    END LOOP; -- fim dos registros da coop
    COMMIT;  -- Se ficou algum pendente fora do MOD 100

    dbms_output.put_line('Cop: ' || rw_crapcop.cdcooper || ' - QTD: ' || vr_contador);
  END LOOP; -- Fim das Coops
  COMMIT; -- Confirmar que tudo foi gravado

end;
0
0
