CREATE OR REPLACE PACKAGE CECRED.TELA_TAB096 IS

  --Tipo de Registro para Parametros da cobemp
  TYPE typ_reg_prm IS RECORD
    (nrconven       crapprm.dsvlrprm%TYPE
    ,nrdconta       crapprm.dsvlrprm%TYPE
    ,pzmaxvct       crapprm.dsvlrprm%TYPE
    ,pzbxavct       crapprm.dsvlrprm%TYPE
    ,vlrminpp       crapprm.dsvlrprm%TYPE
    ,vlrmintr       crapprm.dsvlrprm%TYPE
    ,vlrminpos      crapprm.dsvlrprm%TYPE
    ,dslinha1       crapprm.dsvlrprm%TYPE
    ,dslinha2       crapprm.dsvlrprm%TYPE
    ,dslinha3       crapprm.dsvlrprm%TYPE
    ,dslinha4       crapprm.dsvlrprm%TYPE
    ,dstxtsms       crapprm.dsvlrprm%TYPE
    ,dstxtema       crapprm.dsvlrprm%TYPE
    ,blqemibo       crapprm.dsvlrprm%TYPE
    ,qtmaxbol       crapprm.dsvlrprm%TYPE
    ,blqrsgcc       crapprm.dsvlrprm%TYPE
		,descprej       crapprm.dsvlrprm%TYPE);
    
  PROCEDURE pc_gravar_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                            ,pr_nrconven IN crapprm.dsvlrprm%TYPE --> Convênio de cobrança para empréstimo
                            ,pr_nrdconta IN crapprm.dsvlrprm%TYPE --> Conta/DV Beneficiária do Boleto
                            ,pr_prazomax IN crapprm.dsvlrprm%TYPE --> Prazo máximo de vencimento: xx dias út(il/eis)
                            ,pr_prazobxa IN crapprm.dsvlrprm%TYPE --> Prazo de baixa para o boleto após vencimento: xx dias út(il/eis)
                            ,pr_vlrminpp IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – PP
                            ,pr_vlrmintr IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – TR
                            ,pr_vlrminpos IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – POS
                            ,pr_dslinha1 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 1
                            ,pr_dslinha2 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 2
                            ,pr_dslinha3 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 3
                            ,pr_dslinha4 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 4
                            ,pr_dstxtsms IN crapprm.dsvlrprm%TYPE --> Texto SMS
                            ,pr_dstxtema IN crapprm.dsvlrprm%TYPE --> Texto EMAIL
                            ,pr_blqemiss IN crapprm.dsvlrprm%TYPE --> Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
                            ,pr_qtdmaxbl IN crapprm.dsvlrprm%TYPE --> Quantidade máxima de boletos por contrato: XX
                            ,pr_flgblqvl IN crapprm.dsvlrprm%TYPE --> Bloqueio de resgate de valores disponíveis em conta corrente
                            ,pr_descprej IN crapprm.dsvlrprm%TYPE --> Desconto maximo pagamento contrato prejuizo
                            ,pr_tpproduto IN INTEGER             --> Tipo do produto 0 = Empréstimo, 3 = Desconto de Título
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);
                            
  PROCEDURE pc_buscar_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_tpproduto IN INTEGER             --> Tipo do produto 0 = Empréstimo, 3 = Desconto de Título
														,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
														,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
														,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
														,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro OUT VARCHAR2);
END;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB096 IS

  PROCEDURE pc_gravar_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                            ,pr_nrconven IN crapprm.dsvlrprm%TYPE --> Convênio de cobrança para empréstimo
                            ,pr_nrdconta IN crapprm.dsvlrprm%TYPE --> Conta/DV Beneficiária do Boleto
                            ,pr_prazomax IN crapprm.dsvlrprm%TYPE --> Prazo máximo de vencimento: xx dias út(il/eis)
                            ,pr_prazobxa IN crapprm.dsvlrprm%TYPE --> Prazo de baixa para o boleto após vencimento: xx dias út(il/eis)
                            ,pr_vlrminpp IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – PP
                            ,pr_vlrmintr IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – TR
                            ,pr_vlrminpos IN crapprm.dsvlrprm%TYPE --> Valor mínimo do boleto – POS
                            ,pr_dslinha1 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 1
                            ,pr_dslinha2 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 2
                            ,pr_dslinha3 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 3
                            ,pr_dslinha4 IN crapprm.dsvlrprm%TYPE --> Instruções: Linha 4
                            ,pr_dstxtsms IN crapprm.dsvlrprm%TYPE --> Texto SMS
                            ,pr_dstxtema IN crapprm.dsvlrprm%TYPE --> Texto EMAIL
                            ,pr_blqemiss IN crapprm.dsvlrprm%TYPE --> Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
                            ,pr_qtdmaxbl IN crapprm.dsvlrprm%TYPE --> Quantidade máxima de boletos por contrato: XX
                            ,pr_flgblqvl IN crapprm.dsvlrprm%TYPE --> Bloqueio de resgate de valores disponíveis em conta corrente
                            ,pr_descprej IN crapprm.dsvlrprm%TYPE --> Desconto maximo pagamento contrato prejuizo
                            ,pr_tpproduto IN INTEGER             --> Tipo do produto 0 = Empréstimo, 3 = Desconto de Título
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    BEGIN
     /* .............................................................................
      Programa: pc_gravar_web
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Luis Fernando (GFT)
      Data    : 20/06/2018

      Dados referentes ao programa:
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina referente a gravação dos parametros de cobrança de empréstimos e desconto de título

      Observacao: Trazida da EMPR0007
      
    ..............................................................................*/
    DECLARE

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis conforme tipo do produto
    txt_nrconven          VARCHAR2(30);
    txt_nrdconta_bnf      VARCHAR2(30);
    txt_prz_max_vencto    VARCHAR2(30);
    txt_prz_bx_vencto     VARCHAR2(30);
    txt_vlr_min_pp        VARCHAR2(30);
    txt_vlr_min_tr        VARCHAR2(30);
    txt_vlr_min_pos       VARCHAR2(30);
    txt_instr_linha_1     VARCHAR2(30);
    txt_instr_linha_2     VARCHAR2(30);
    txt_instr_linha_3     VARCHAR2(30);
    txt_instr_linha_4     VARCHAR2(30);
    txt_txt_sms           VARCHAR2(30);
    txt_txt_email         VARCHAR2(30);
    txt_blq_emi_consec    VARCHAR2(30);
    txt_qtd_max_bol_epr   VARCHAR2(30);
    txt_blq_resg_cc       VARCHAR2(30);
    txt_dsc_max_preju     VARCHAR2(30);
    
    -------------------------------- CURSORES --------------------------------------

    -- Cursor para a tabela de emissão de bloquetos
    CURSOR cr_crapceb IS
      SELECT 1
        FROM crapceb ceb
       WHERE ceb.cdcooper = pr_cdcooper
         AND ceb.nrdconta = pr_nrdconta
         AND ceb.nrconven = pr_nrconven;
    rw_crapceb cr_crapceb%ROWTYPE;


    ----------------------------- SUBROTINAS INTERNAS ---------------------------
    -- Procedure para gravar os itens do LOG
    PROCEDURE pc_item_log(pr_cdcooper IN INTEGER --> Codigo da cooperativa
                         ,pr_cdoperad IN VARCHAR2 --> Codigo do operador
                         ,pr_dsdcampo IN VARCHAR2 --> Descricao do campo
                         ,pr_vldantes IN VARCHAR2 --> Valor antes
                         ,pr_vldepois IN VARCHAR2) IS  --> Valor depois
    BEGIN
      BEGIN
        -- Se for alteracao e nao tem diferenca, retorna
        IF pr_vldantes = pr_vldepois THEN
          RETURN;
        END IF;

        -- Geral LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'tab096.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Coop: ' || pr_cdcooper ||
                                                      ' - Operador ' || pr_cdoperad ||
                                                      ' alterou o parametro ' || pr_dsdcampo ||
                                                      ' de ' || pr_vldantes ||
                                                      ' para ' || pr_vldepois || '.');
      END;
    END pc_item_log;

    -- Procedure para criar/atualizar parametros de cobrança
    PROCEDURE atualiza_parametro(pr_cdacesso IN crapprm.cdacesso%TYPE
                                ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE
                                ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      BEGIN
      DECLARE

        -- Define cursor de parametros
        CURSOR cr_crapprm IS
          SELECT prm.dsvlrprm
           FROM crapprm prm
          WHERE prm.cdcooper = pr_cdcooper
            AND prm.nmsistem = 'CRED'
            AND prm.cdacesso = pr_cdacesso;
        rw_crapprm cr_crapprm%ROWTYPE;

        -- Define cursor de parametros
        CURSOR cr_crapprm_todos IS
          SELECT cop.cdcooper,
                 prm.dsvlrprm
           FROM crapcop cop,
                crapprm prm
          WHERE cop.cdcooper    = prm.cdcooper(+)
            AND prm.nmsistem(+) = 'CRED'
            AND prm.cdacesso(+) = pr_cdacesso
            AND cop.flgativo = 1
            AND cop.cdcooper <> 3;

      BEGIN
        -- Se cooperativa for 0 então são todas
        IF pr_cdcooper = 0 THEN
           -- Percorre a tabela de parametros de todas as cooperativas
           FOR rw_crapprm_todos IN cr_crapprm_todos LOOP
               -- Se possuir valor no campo de parametro atualiza
               IF pr_dsvlrprm IS NOT NULL THEN
                 UPDATE crapprm
                    SET dsvlrprm = pr_dsvlrprm
                  WHERE cdcooper = rw_crapprm_todos.cdcooper
                    AND nmsistem = 'CRED'
                    AND cdacesso = pr_cdacesso;
               ELSE
                  vr_cdcritic := 0;
                  vr_dscritic := 'Parametro ' || pr_cdacesso || ' nao pode ser nulo.';   
                  RAISE vr_exc_saida;               
               END IF;

               -- Grava o LOG
               pc_item_log(pr_cdcooper => rw_crapprm_todos.cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dsdcampo => pr_cdacesso
                          ,pr_vldantes => rw_crapprm_todos.dsvlrprm
                          ,pr_vldepois => pr_dsvlrprm);

           END LOOP;

        ELSE -- Cooperativa especifica

          -- Abre cursor de parametros
          OPEN cr_crapprm;
          FETCH cr_crapprm INTO rw_crapprm;

          -- Se não encontrou cria
          IF cr_crapprm%NOTFOUND THEN
            INSERT INTO crapprm(cdcooper
                               ,nmsistem
                               ,cdacesso
                               ,dsvlrprm)
                         VALUES(pr_cdcooper
                               ,'CRED'
                               ,pr_cdacesso
                               ,pr_dsvlrprm);
          ELSE -- Se encontrou atualiza
            UPDATE crapprm
               SET dsvlrprm = pr_dsvlrprm
             WHERE cdcooper = pr_cdcooper
               AND nmsistem = 'CRED'
               AND cdacesso = pr_cdacesso;
          END IF;
          -- Fecha cursor
          CLOSE cr_crapprm;

          -- Grava o LOG
          pc_item_log(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdoperad
                     ,pr_dsdcampo => pr_cdacesso
                     ,pr_vldantes => rw_crapprm.dsvlrprm
                     ,pr_vldepois => pr_dsvlrprm);

        END IF;
      END;
    END atualiza_parametro;

    BEGIN
    -- Extrai os dados vindos do XML
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
  
    IF (pr_tpproduto=3) THEN
      txt_nrconven        := 'COBTIT_NRCONVEN';
      txt_nrdconta_bnf    := 'COBTIT_NRDCONTA_BNF';
      txt_prz_max_vencto  := 'COBTIT_PRZ_MAX_VENCTO';
      txt_prz_bx_vencto   := 'COBTIT_PRZ_BX_VENCTO';
      txt_vlr_min_pp      := 'COBTIT_VLR_MIN';
      txt_instr_linha_1   := 'COBTIT_INSTR_LINHA_1';
      txt_instr_linha_2   := 'COBTIT_INSTR_LINHA_2';
      txt_instr_linha_3   := 'COBTIT_INSTR_LINHA_3';
      txt_instr_linha_4   := 'COBTIT_INSTR_LINHA_4';
      txt_txt_sms         := 'COBTIT_TXT_SMS';
      txt_txt_email       := 'COBTIT_TXT_EMAIL';
      txt_blq_emi_consec  := 'COBTIT_BLQ_EMI_CONSEC';
      txt_qtd_max_bol_epr := 'COBTIT_QTD_MAX_BOL_EPR';
      txt_blq_resg_cc     := 'COBTIT_BLQ_RESG_CC';
      txt_dsc_max_preju   := 'COBTIT_DSC_MAX_PREJU';
    ELSE
      txt_nrconven        := 'COBEMP_NRCONVEN';
      txt_nrdconta_bnf    := 'COBEMP_NRDCONTA_BNF';
      txt_prz_max_vencto  := 'COBEMP_PRZ_MAX_VENCTO';
      txt_prz_bx_vencto   := 'COBEMP_PRZ_BX_VENCTO';
      txt_vlr_min_pp      := 'COBEMP_VLR_MIN_PP';
      txt_vlr_min_tr      := 'COBEMP_VLR_MIN_TR';
      txt_vlr_min_pos     := 'COBEMP_VLR_MIN_POS';
      txt_instr_linha_1   := 'COBEMP_INSTR_LINHA_1';
      txt_instr_linha_2   := 'COBEMP_INSTR_LINHA_2';
      txt_instr_linha_3   := 'COBEMP_INSTR_LINHA_3';
      txt_instr_linha_4   := 'COBEMP_INSTR_LINHA_4';
      txt_txt_sms         := 'COBEMP_TXT_SMS';
      txt_txt_email       := 'COBEMP_TXT_EMAIL';
      txt_blq_emi_consec  := 'COBEMP_BLQ_EMI_CONSEC';
      txt_qtd_max_bol_epr := 'COBEMP_QTD_MAX_BOL_EPR';
      txt_blq_resg_cc     := 'COBEMP_BLQ_RESG_CC';
      txt_dsc_max_preju   := 'COBEMP_DSC_MAX_PREJU';
    END IF;
    IF (pr_cdcooper <> 0) THEN
      -- Convênio de cobrança para empréstimo
      IF trim(pr_nrconven) IS NOT NULL AND nvl(pr_nrconven,0)>0 THEN
         atualiza_parametro(pr_cdacesso => txt_nrconven
                           ,pr_dsvlrprm => pr_nrconven
                           ,pr_cdoperad => vr_cdoperad);
      END IF;

      -- Conta/DV Beneficiária do Boleto
      IF trim(pr_nrdconta) IS NOT NULL AND nvl(pr_nrdconta,0)>0 THEN
         atualiza_parametro(pr_cdacesso => txt_nrdconta_bnf
                           ,pr_dsvlrprm => pr_nrdconta
                           ,pr_cdoperad => vr_cdoperad);
      END IF;
    END IF;
    -- Prazo máximo de vencimento: xx dias út(il/eis)
     IF trim(pr_prazomax) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_prz_max_vencto
                         ,pr_dsvlrprm => pr_prazomax
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Prazo máximo de vencimento: xx dias út(il/eis)
     IF trim(pr_prazobxa) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_prz_bx_vencto
                         ,pr_dsvlrprm => pr_prazobxa
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Valor mínimo do boleto – PP
     IF trim(pr_vlrminpp) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_vlr_min_pp
                         ,pr_dsvlrprm => pr_vlrminpp
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Valor mínimo do boleto – TR
     IF trim(pr_vlrmintr) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_vlr_min_tr
                         ,pr_dsvlrprm => pr_vlrmintr
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Valor mínimo do boleto – POS
     IF trim(pr_vlrminpos) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_vlr_min_pos
                         ,pr_dsvlrprm => pr_vlrminpos
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Instruções: Linha 1
     IF trim(pr_dslinha1) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_instr_linha_1
                         ,pr_dsvlrprm => pr_dslinha1
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Instruções: Linha 2
     IF trim(pr_dslinha2) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_instr_linha_2
                         ,pr_dsvlrprm => pr_dslinha2
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Instruções: Linha 3
     IF trim(pr_dslinha3) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_instr_linha_3
                         ,pr_dsvlrprm => pr_dslinha3
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Instruções: Linha 4
     IF trim(pr_dslinha4) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_instr_linha_4
                         ,pr_dsvlrprm => pr_dslinha4
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Texto SMS
     IF trim(pr_dstxtsms) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_txt_sms
                         ,pr_dsvlrprm => pr_dstxtsms
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Texto EMAIL
     IF trim(pr_dstxtema) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_txt_email
                         ,pr_dsvlrprm => pr_dstxtema
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
     IF trim(pr_blqemiss) <> ';'       AND
       trim(pr_blqemiss) IS NOT NULL  THEN
       atualiza_parametro(pr_cdacesso => txt_blq_emi_consec
                         ,pr_dsvlrprm => pr_blqemiss
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Quantidade máxima de boletos por contrato: XX
     IF trim(pr_qtdmaxbl) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_qtd_max_bol_epr
                         ,pr_dsvlrprm => pr_qtdmaxbl
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Quantidade máxima de boletos por contrato: XX
     IF trim(pr_flgblqvl) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_blq_resg_cc
                         ,pr_dsvlrprm => pr_flgblqvl
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    -- Desconto maximo pagamento contrato prejuizo
     IF trim(pr_descprej) IS NOT NULL THEN
       atualiza_parametro(pr_cdacesso => txt_dsc_max_preju
                         ,pr_dsvlrprm => pr_descprej
                         ,pr_cdoperad => vr_cdoperad);
    END IF;

    IF (pr_cdcooper <> 0) THEN
      -- Verifica se convênio de cobrança existe
      OPEN cr_crapceb;
      FETCH cr_crapceb INTO rw_crapceb;

      IF cr_crapceb%NOTFOUND THEN
         -- Se não existir, cria
         INSERT INTO crapceb
                    (cdcooper,
                     nrdconta,
                     nrconven,
                     flcooexp,
                     flceeexp,
                     insitceb,
                     dtcadast,
                     inarqcbr,
                     nrcnvceb,
                     flgcruni,
                     flgcebhm)
             values (pr_cdcooper,
                     pr_nrdconta,
                     pr_nrconven,
                     1,
                     0,
                     1,
                     trunc(SYSDATE),
                     0,
                     0,
                     1,
                     0);
      END IF;
      -- Fecha cursor
      CLOSE cr_crapceb;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN

      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro nao tratado na TELA_TAB096.pc_gravar_web: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      ROLLBACK;
		END;
  END pc_gravar_web;
  
  PROCEDURE pc_buscar_web(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                          ,pr_tpproduto IN INTEGER             --> Tipo do produto 0 = Empréstimo, 3 = Desconto de Título
														,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
														,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
														,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
														,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
														,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
														,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
	BEGIN
	  /* .............................................................................

      Programa: pc_buscar_web
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Luis Fernando (GFT)
      Data    : 20/06/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina referente a busca dos parametros de cobrança

      Observacao: -----
    ..............................................................................*/
		DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variáveis locais
      vr_cdcooper crapcop.cdcooper%TYPE := pr_cdcooper;

			-- Pltable com os dados de cobrança de empréstimos
			vr_reg_cobemp typ_reg_prm;

		  -- Busca os convernios de emprestimo da cooperativa
		  CURSOR cr_crapprm (pr_cdcooper IN crapcop.cdcooper%TYPE
			                  ,pr_cdacesso IN crapprm.cdacesso%TYPE)IS
			  SELECT prm.dsvlrprm
				  FROM crapprm prm
				 WHERE prm.cdcooper = pr_cdcooper
				 	 AND prm.nmsistem = 'CRED'
					 AND prm.cdacesso = pr_cdacesso;

      -- Variaveis conforme tipo do produto
      txt_nrconven          VARCHAR2(30);
      txt_nrdconta_bnf      VARCHAR2(30);
      txt_prz_max_vencto    VARCHAR2(30);
      txt_prz_bx_vencto     VARCHAR2(30);
      txt_vlr_min_pp        VARCHAR2(30);
      txt_vlr_min_tr        VARCHAR2(30);
      txt_vlr_min_pos       VARCHAR2(30);
      txt_instr_linha_1     VARCHAR2(30);
      txt_instr_linha_2     VARCHAR2(30);
      txt_instr_linha_3     VARCHAR2(30);
      txt_instr_linha_4     VARCHAR2(30);
      txt_txt_sms           VARCHAR2(30);
      txt_txt_email         VARCHAR2(30);
      txt_blq_emi_consec    VARCHAR2(30);
      txt_qtd_max_bol_epr   VARCHAR2(30);
      txt_blq_resg_cc       VARCHAR2(30);
      txt_dsc_max_preju     VARCHAR2(30);
		BEGIN
      IF (pr_tpproduto=3) THEN
        txt_nrconven        := 'COBTIT_NRCONVEN';
        txt_nrdconta_bnf    := 'COBTIT_NRDCONTA_BNF';
        txt_prz_max_vencto  := 'COBTIT_PRZ_MAX_VENCTO';
        txt_prz_bx_vencto   := 'COBTIT_PRZ_BX_VENCTO';
        txt_vlr_min_pp      := 'COBTIT_VLR_MIN';
        txt_instr_linha_1   := 'COBTIT_INSTR_LINHA_1';
        txt_instr_linha_2   := 'COBTIT_INSTR_LINHA_2';
        txt_instr_linha_3   := 'COBTIT_INSTR_LINHA_3';
        txt_instr_linha_4   := 'COBTIT_INSTR_LINHA_4';
        txt_txt_sms         := 'COBTIT_TXT_SMS';
        txt_txt_email       := 'COBTIT_TXT_EMAIL';
        txt_blq_emi_consec  := 'COBTIT_BLQ_EMI_CONSEC';
        txt_qtd_max_bol_epr := 'COBTIT_QTD_MAX_BOL_EPR';
        txt_blq_resg_cc     := 'COBTIT_BLQ_RESG_CC';
        txt_dsc_max_preju   := 'COBTIT_DSC_MAX_PREJU';
      ELSE
        txt_nrconven        := 'COBEMP_NRCONVEN';
        txt_nrdconta_bnf    := 'COBEMP_NRDCONTA_BNF';
        txt_prz_max_vencto  := 'COBEMP_PRZ_MAX_VENCTO';
        txt_prz_bx_vencto   := 'COBEMP_PRZ_BX_VENCTO';
        txt_vlr_min_pp      := 'COBEMP_VLR_MIN_PP';
        txt_vlr_min_tr      := 'COBEMP_VLR_MIN_TR';
        txt_vlr_min_pos     := 'COBEMP_VLR_MIN_POS';
        txt_instr_linha_1   := 'COBEMP_INSTR_LINHA_1';
        txt_instr_linha_2   := 'COBEMP_INSTR_LINHA_2';
        txt_instr_linha_3   := 'COBEMP_INSTR_LINHA_3';
        txt_instr_linha_4   := 'COBEMP_INSTR_LINHA_4';
        txt_txt_sms         := 'COBEMP_TXT_SMS';
        txt_txt_email       := 'COBEMP_TXT_EMAIL';
        txt_blq_emi_consec  := 'COBEMP_BLQ_EMI_CONSEC';
        txt_qtd_max_bol_epr := 'COBEMP_QTD_MAX_BOL_EPR';
        txt_blq_resg_cc     := 'COBEMP_BLQ_RESG_CC';
        txt_dsc_max_preju   := 'COBEMP_DSC_MAX_PREJU';
      END IF;
      IF vr_cdcooper <> 0 THEN
        -- Convênio de cobrança para empréstimo
        OPEN cr_crapprm(vr_cdcooper
                       ,txt_nrconven);
        FETCH cr_crapprm INTO vr_reg_cobemp.nrconven;
        CLOSE cr_crapprm;

        -- Conta/DV Beneficiária do Boleto
        OPEN cr_crapprm(vr_cdcooper
                       ,txt_nrdconta_bnf);
        FETCH cr_crapprm INTO vr_reg_cobemp.nrdconta;
        CLOSE cr_crapprm;
      ELSE
        vr_reg_cobemp.nrconven := '0';
        vr_reg_cobemp.nrdconta := '0';
        vr_cdcooper := 1;
      END IF;

      -- Prazo máximo de vencimento: xx dias út(il/eis)
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_prz_max_vencto);
      FETCH cr_crapprm INTO vr_reg_cobemp.pzmaxvct;
      CLOSE cr_crapprm;

      -- Prazo de baixa para o boleto após vencimento: xx dias út(il/eis)
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_prz_bx_vencto);
      FETCH cr_crapprm INTO vr_reg_cobemp.pzbxavct;
      CLOSE cr_crapprm;

      -- Valor mínimo do boleto – PP
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_vlr_min_pp);
      FETCH cr_crapprm INTO vr_reg_cobemp.vlrminpp;
      CLOSE cr_crapprm;

      -- Valor mínimo do boleto – TR
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_vlr_min_tr);
      FETCH cr_crapprm INTO vr_reg_cobemp.vlrmintr;
      CLOSE cr_crapprm;

      -- Valor mínimo do boleto – POS
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_vlr_min_pos);
      FETCH cr_crapprm INTO vr_reg_cobemp.vlrminpos;
      CLOSE cr_crapprm;

      -- Desconto Máximo Contrato Prejuízo
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_dsc_max_preju);
      FETCH cr_crapprm INTO vr_reg_cobemp.descprej;
      CLOSE cr_crapprm;

      -- Instruções: (mensagem dentro do boleto)
      -- Linha 1
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_instr_linha_1);
      FETCH cr_crapprm INTO vr_reg_cobemp.dslinha1;
      CLOSE cr_crapprm;

      -- Linha 2
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_instr_linha_2);
      FETCH cr_crapprm INTO vr_reg_cobemp.dslinha2;
      CLOSE cr_crapprm;

      -- Linha 3
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_instr_linha_3);
      FETCH cr_crapprm INTO vr_reg_cobemp.dslinha3;
      CLOSE cr_crapprm;

      -- Linha 4
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_instr_linha_4);
      FETCH cr_crapprm INTO vr_reg_cobemp.dslinha4;
      CLOSE cr_crapprm;

      -- Texto SMS
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_txt_sms);
      FETCH cr_crapprm INTO vr_reg_cobemp.dstxtsms;
      CLOSE cr_crapprm;

      -- Texto EMAIL
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_txt_email);
      FETCH cr_crapprm INTO vr_reg_cobemp.dstxtema;
      CLOSE cr_crapprm;

      -- Bloqueio de emissão de boletos: XX dias para YY emissões consecutivas não pagas
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_blq_emi_consec);
      FETCH cr_crapprm INTO vr_reg_cobemp.blqemibo;
      CLOSE cr_crapprm;

      -- Quantidade máxima de boletos por contrato: XX
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_qtd_max_bol_epr);
      FETCH cr_crapprm INTO vr_reg_cobemp.qtmaxbol;
      CLOSE cr_crapprm;

      -- Bloqueio de resgate de valores disponíveis em conta corrente
      OPEN cr_crapprm(vr_cdcooper
                     ,txt_blq_resg_cc);
      FETCH cr_crapprm INTO vr_reg_cobemp.blqrsgcc;
      CLOSE cr_crapprm;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

			-- Insere as tags
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrconven', pr_tag_cont => vr_reg_cobemp.nrconven, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'nrdconta', pr_tag_cont => vr_reg_cobemp.nrdconta, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pzmaxvct', pr_tag_cont => vr_reg_cobemp.pzmaxvct, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'pzbxavct', pr_tag_cont => vr_reg_cobemp.pzbxavct, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vlrminpp', pr_tag_cont => vr_reg_cobemp.vlrminpp, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vlrmintr', pr_tag_cont => vr_reg_cobemp.vlrmintr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'vlrminpos', pr_tag_cont => vr_reg_cobemp.vlrminpos, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'descprej', pr_tag_cont => vr_reg_cobemp.descprej, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha1', pr_tag_cont => vr_reg_cobemp.dslinha1, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha2', pr_tag_cont => vr_reg_cobemp.dslinha2, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha3', pr_tag_cont => vr_reg_cobemp.dslinha3, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dslinha4', pr_tag_cont => vr_reg_cobemp.dslinha4, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dstxtsms', pr_tag_cont => vr_reg_cobemp.dstxtsms, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dstxtema', pr_tag_cont => vr_reg_cobemp.dstxtema, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'blqemibo', pr_tag_cont => vr_reg_cobemp.blqemibo, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtmaxbol', pr_tag_cont => vr_reg_cobemp.qtmaxbol, pr_des_erro => vr_dscritic);
			gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'blqrsgcc', pr_tag_cont => vr_reg_cobemp.blqrsgcc, pr_des_erro => vr_dscritic);

		EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

			WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na TELA_TAB096.pc_buscar_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
		END;
  END pc_buscar_web;
END;
/
