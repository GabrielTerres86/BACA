DECLARE
  PROCEDURE pc_atualizar_rating_carga(pr_cdcooper IN craptab.cdcooper%TYPE
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_idcarga  IN cecred.tbrating_contrato.nrdconta%TYPE) IS

    CURSOR cr_tbrating_contrato(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT co.skcontrato
            ,co.idcarga
            ,co.cdcooper
            ,co.nrdconta
            ,co.inpessoa
            ,co.tpctrato
            ,co.nrctrato
            ,co.nrcpfcnpj_base
            ,RISC0004.fn_traduz_nivel_risco(co.dsrisco_rating,2) inrisco_rating
            ,NVL(RATI0003.fn_traduz_nivel_rating(co.dsnivel_rating),2)  innivel_rating
            ,co.inscore_rating
            ,co.dssegmento_rating
            ,co.insituacao
            ,co.dssituacao
            ,co.inprocessado
            ,co.dtvigencia_rating
        FROM cecred.tbrating_contrato co
       WHERE co.cdcooper          = pr_cdcooper
         AND co.idcarga           = pr_idcarga
         AND co.nrdconta          = pr_nrdconta
         AND co.tpctrato          = -1;
      rw_tbrating_contrato cr_tbrating_contrato%ROWTYPE;

    CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT dat.dtmvtolt
            ,dat.dtmvtopr
            ,dat.dtmvtoan
            ,dat.inproces
            ,dat.qtdiaute
            ,dat.cdprgant
            ,dat.dtmvtocd
            ,dat.dtultdia
            ,trunc(dat.dtmvtolt,'mm')                 dtinimes -- Pri. Dia Mes Corr.
            ,trunc(add_months(dat.dtmvtolt, 1), 'mm') dtpridms -- Pri. Dia mes Seguinte
            ,last_day(add_months(dat.dtmvtolt,-1))    dtultdma -- Ult. Dia Mes Ant.
            ,ROWID
        FROM crapdat dat
       WHERE dat.cdcooper = pr_cdcooper;
    rw_crapdat cr_crapdat%ROWTYPE;

    CURSOR cr_crapcop(pr_cdcooper  crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1
         AND cop.cdcooper <> 3 -- Não deve rodar para a AILOS
         AND cop.cdcooper = pr_cdcooper
       ORDER BY cop.cdcooper DESC;
      rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_rating_adp(pr_cdcooper  IN tbrisco_operacoes.cdcooper%TYPE
                        ,pr_nrdconta  IN tbrisco_operacoes.nrdconta%TYPE) IS
      SELECT o.nrdconta
        FROM tbrisco_operacoes o
       WHERE o.cdcooper = pr_cdcooper
         AND o.nrdconta = pr_nrdconta
         AND o.nrctremp = pr_nrdconta -- No ADP o numero do contrato é a conta
         AND o.tpctrato = 11;  -- ADP
    rw_rating_adp cr_rating_adp%ROWTYPE;

    -- Parametros
    vr_modelo_rating  tbrat_param_geral.tpmodelo_rating%TYPE;

    vr_cdcritic       PLS_INTEGER;
    vr_dscritic       VARCHAR2(4000);

    vr_dtprocesso     DATE;
    vr_strating       tbrisco_operacoes.insituacao_rating%TYPE;
    vr_nrdconta       tbrating_contrato.nrdconta%TYPE;

  BEGIN

    FOR rw_crapcop IN cr_crapcop(pr_cdcooper) LOOP

      OPEN  cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH cr_crapdat INTO rw_crapdat;
      CLOSE cr_crapdat;

      vr_modelo_rating := RATI0003.fn_retorna_modelo_rating( pr_cdcooper => rw_crapcop.cdcooper ) ;

      IF vr_modelo_rating = 2 THEN

          vr_dtprocesso := SYSDATE;

          FOR rw_tbrating_contrato IN cr_tbrating_contrato(pr_cdcooper) LOOP


            vr_nrdconta := rw_tbrating_contrato.nrdconta;
            vr_strating := 4;

            OPEN cr_rating_adp(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrdconta => vr_nrdconta);
            FETCH cr_rating_adp INTO rw_rating_adp;
            IF cr_rating_adp%FOUND THEN
              RATI0003.pc_grava_rating_operacao
                                   (pr_cdcooper => rw_crapcop.cdcooper             --> Código da Cooperativa
                                   ,pr_nrdconta => vr_nrdconta                     --> Conta do associado
                                   ,pr_tpctrato => 11                              --> Tipo do contrato de rating
                                   ,pr_nrctrato => vr_nrdconta                     --> Número do contrato do rating

                                   ,pr_ntrating => rw_tbrating_contrato.inrisco_rating --> Nivel de Risco Rating EFETIVO
                                   ,pr_ntrataut => rw_tbrating_contrato.inrisco_rating  --> Nivel de Risco Rating retornado do MOTOR
                                   ,pr_dtrating => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating
                                   ,pr_dtrataut => rw_crapdat.dtmvtolt    --> Data do Rating retorn
                                   ,pr_strating => vr_strating    --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)

                                   ,pr_orrating           =>  5     --> Identificador da Origem do Rating (Dominio: tbgen_dominio_campo)
                                   ,pr_cdoprrat           =>  '1'   --> Codigo Operador que Efetivou o Ratingado do MOTOR
                                   ,pr_innivel_rating     => rw_tbrating_contrato.innivel_rating  --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                   ,pr_nrcpfcnpj_base     => rw_tbrating_contrato.nrcpfcnpj_base  --> Numero do CPF/CNPJ Base do associado
                                   ,pr_inpontos_rating    => rw_tbrating_contrato.inscore_rating  --> Pontuacao do Rating retornada do Motor

                                   ,pr_efetivacao_rating  => 1 -- Não deverá verificar a contingencia

                                   --Variáveis para gravar o histórico
                                   ,pr_cdoperad           => '1'           --> Operador que gerou historico de rating
                                   ,pr_dtmvtolt           => rw_crapdat.dtmvtolt  --> Data/Hora do historico de rating
                                   ,pr_justificativa      => 'Via LOTE BACA ADP - ' || to_char(SYSDATE, 'dd/mm/yyyy hh24:mi:ss') || ' [BACA pc_atualizar_rating_carga]' --> Justificativa do operador para alteracao do Rating
                                   ,pr_tpoperacao_rating  => NULL   --> Tipo de Operacao que gerou historico de rating (Dominio: tbgen_dominio_campo)
                                   --Variáveis de crítica
                                   ,pr_cdcritic           => vr_cdcritic     --> Critica encontrada no processo
                                   ,pr_dscritic           => vr_dscritic);   --> Descritivo do erro

              RATI0005.pc_grava_rating_detalhes(pr_cdcooper   => rw_crapcop.cdcooper,
                                   pr_nrdconta                => vr_nrdconta,
                                   pr_tpctrato                => 11,
                                   pr_nrctrato                => vr_nrdconta,

                                   pr_inrisco_rating_proposta => NULL,
                                   pr_inrisco_rating_manual   => NULL,

                                   pr_inrisco_rating          => NULL,
                                   pr_dtrisco_rating          => NULL,
                                   pr_dtvencto_rating         => NULL,
                                   pr_insituacao_rating       => NULL,
                                   pr_inorigem_rating         => NULL,
                                   pr_cdoperad_rating         => NULL,
                                   pr_innivel_rating          => NULL,
                                   pr_inpontos_rating         => NULL,
                                   pr_insegmento_rating       => NULL,
                                   pr_flintegrar_sas          => NULL,
                                   pr_flencerrado             => NULL,
                                   pr_flpermite_alterar       => NULL,
                                   pr_inmodelo                => NULL,
                                   pr_intipo_rating           => 2, -- 1-Concessao/Originacao / 2-Manutencao
                                   pr_justificativa           => 'Atualização Tipo Rating - Manutenção - Rating do limite',
                                   pr_cdcritic                => vr_cdcritic,
                                   pr_dscritic                => vr_dscritic);

              RATI0005.pc_altera_tprating_detalhes( pr_cdcooper      => rw_crapcop.cdcooper
                                                   ,pr_nrdconta      => vr_nrdconta
                                                   ,pr_nrctrato      => rw_tbrating_contrato.nrctrato
                                                   ,pr_tpctrato      => rw_tbrating_contrato.tpctrato
                                                   ,pr_intipo_rating => 2  -- 1-Concessao / 2-Manutencao / 3-Manual
                                                   ,pr_cdcritic      => vr_cdcritic
                                                   ,pr_dscritic      => vr_dscritic);

            END IF;
            CLOSE cr_rating_adp;

          END LOOP;
      END IF;
    END LOOP;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN

       vr_dscritic:= 'Erro na rotina pc_atualizar_rating_carga ' || SQLERRM;
       DBMS_OUTPUT.PUT_LINE(vr_dscritic);

       ROLLBACK;

  END pc_atualizar_rating_carga;

BEGIN
  pc_atualizar_rating_carga(13, 299944, 16487);
END;
/