CREATE OR REPLACE PACKAGE CECRED.EMPR0009 IS

  /* Type das parcelas em atraso */
  TYPE typ_reg_parcelas IS RECORD(
     nrparepr INTEGER
    ,dtvencto DATE
    ,vlatupar NUMBER(12,2));

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_parcelas IS TABLE OF typ_reg_parcelas INDEX BY BINARY_INTEGER;    
  
  PROCEDURE pc_efetiva_pag_atraso_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_nmdatela  IN crapprg.cdprogra%TYPE --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Contrato
                                    ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE --> Valor a pagar
                                    ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                                    ,pr_qtprecal  IN crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas
                                    ,pr_vlpagpar  IN crapepr.vlpreemp%TYPE --> Valor de pagamento da parcela
                                    ,pr_vlsldisp  IN NUMBER DEFAULT NULL   --> Valor Saldo Disponivel
                                    ,pr_cdhismul OUT INTEGER               --> Historico da Multa
                                    ,pr_vldmulta OUT NUMBER                --> Valor da Multa
                                    ,pr_cdhismor OUT INTEGER               --> Historico Juros de Mora
                                    ,pr_vljumora OUT NUMBER                --> Valor Juros de Mora
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

	PROCEDURE pc_efetiva_lcto_pendente_job;
  
    PROCEDURE pc_efetiva_pag_atraso_tr_prc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_nmdatela  IN crapprg.cdprogra%TYPE --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Contrato
                                    ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE --> Valor a pagar
                                    ,pr_nrparcela IN tbepr_tr_parcelas.nrparcela%TYPE --> Numero da parcela a pagar
                                    ,pr_dtdpagto  IN tbepr_tr_parcelas.dtdpagto%TYPE  --> Data de pagamento original - vencimento parcela
                                    ,pr_vlpagpar  IN crapepr.vlpreemp%TYPE --> Valor de pagamento da parcela
                                    ,pr_vlsldisp  IN NUMBER DEFAULT NULL   --> Valor Saldo Disponivel
                                    ,pr_cdhismul OUT INTEGER               --> Historico da Multa
                                    ,pr_vldmulta OUT NUMBER                --> Valor da Multa
                                    ,pr_cdhismor OUT INTEGER               --> Historico Juros de Mora
                                    ,pr_vljumora OUT NUMBER                --> Valor Juros de Mora
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica  

  --> Grava informações para resolver erro de programa/ sistema
  PROCEDURE pc_grava_erro_programa(pr_cdcooper IN PLS_INTEGER           --> Cooperativa
                                  ,pr_dstiplog IN VARCHAR2              --> Tipo Log
                                  ,pr_nmrotina IN VARCHAR2              --> Nome da Rotina
                                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                                  );
  
END EMPR0009;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0009 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : EMPR0009
  --  Sistema  : Conta-Corrente - Cooperativa de Credito
  --  Sigla    : CRED
  --  Autor    : Jaison Fernando
  --  Data     : Maio - 2016                 Ultima atualizacao: 22/09/2017
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas para calcular multa e juros de mora 
  --             para os contratos de emprestimo TR.
  --
  -- Alteracoes: 24/04/2017 - Nao considerar valores bloqueados na composicao de saldo disponivel
  --                          Heitor (Mouts) - Melhoria 440
  --
  --             22/09/2017 - Ajustar padrão de Logs
  --                          Ajustar padrão de Exception Others
  --                          Inclui nome do modulo logado
  --                          ( Belli - Envolti - Chamados 697089 758606 ) 
  --
  ---------------------------------------------------------------------------

  /* Calcular a quantidade de dias que o emprestimo está em atraso */
  FUNCTION fn_calc_qtde_parc_atraso(pr_qtpreemp  IN crapepr.qtpreemp%TYPE  --> Quantidade de prestacoes do emprestimo
                                   ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE  --> Quantidade de meses decorridos
                                   ,pr_qtprecal  IN crapepr.qtprecal%TYPE) --> Quantidade de prestacoes calculadas
   RETURN INTEGER IS
  BEGIN
    /* .............................................................................
    
       Programa: fn_calc_qtde_parc_atraso
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Julho/2016                        Ultima atualizacao:22/09/2017
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Calcular a quantidade de parcelas que estah em atraso para o emprestimo TR
    
       Alteracoes:          
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )
                                     
    ............................................................................. */
    DECLARE
      --Variaveis locais
      vr_nrparepr INTEGER := 0;
    
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.fn_calc_qtde_parc_atraso');
      -- Caso os meses decorridos for maior que a quantidade de prestacoes
      IF pr_qtmesdec >= pr_qtpreemp THEN
        vr_nrparepr := pr_qtpreemp - FLOOR(pr_qtprecal);
      -- Caso a quantidade de prestacoes for maior que 1  
      ELSE
        vr_nrparepr := pr_qtmesdec - FLOOR(pr_qtprecal);
      END IF;
        
      IF vr_nrparepr < 0 THEN
        vr_nrparepr := 0;
      END IF;     

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606       
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      --Retornar valor
      RETURN(vr_nrparepr);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception;   
        --Retornar zero
        RETURN(0);
    END;
  END;

  /* Calcular a quantidade de dias que o emprestimo está em atraso */
  FUNCTION fn_calc_data_prox_venc(pr_dtdpagto IN crapepr.dtdpagto%TYPE)  --> Data de Vencimento
   RETURN DATE IS
  BEGIN
    /* .............................................................................    
       Programa: fn_calc_data_prox_venc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Agosto/2016                        Ultima atualizacao:22/09/2017
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Calcular o proximo vencimento da parcela do emprestimo
    
       Alteracoes:     
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )
    ............................................................................. */
    DECLARE
      --Variaveis locais
      vr_dtdpagto crapepr.dtdpagto%TYPE;
      vr_des_erro VARCHAR2(1000);    
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.fn_calc_data_prox_venc');
      -- Adiciona um mês
      vr_dtdpagto := GENE0005.fn_calc_data(pr_dtmvtolt  => pr_dtdpagto  --> Data de entrada
                                          ,pr_qtmesano  => 1            --> 1 mês a acumular
                                          ,pr_tpmesano  => 'M'          --> Tipo Mes
                                          ,pr_des_erro  => vr_des_erro);
  
      IF vr_des_erro IS NOT NULL THEN
        RETURN(NULL);
      END IF;

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606      
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

      RETURN(vr_dtdpagto);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception;   
        --Retornar zero
        RETURN(NULL);
    END;
  END;  
  
  FUNCTION fn_calc_data_pagamento(pr_qtmesdec IN crapepr.qtmesdec%TYPE  --> Quantidade dos meses decorridos
                                 ,pr_qtprecal IN crapepr.qtprecal%TYPE  --> Quantidade de Prestacao Calculada
                                 ,pr_dtdpagto IN crapepr.dtdpagto%TYPE  --> Data de Pagamento
                                 ,pr_dtcalcul IN DATE)                  --> Data de Calculo
   RETURN DATE IS
  BEGIN
    /* .............................................................................    
       Programa: fn_calc_data_pagamento
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Agosto/2016                        Ultima atualizacao:22/09/2017
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Calcular a data real de pagamento
    
       Alteracoes: 25/08/2016 - Ajuste na vr_dtdpagto_result e remocao da pr_qtpreemp.
                                (Jaison/James)
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )
    ............................................................................. */
    DECLARE
      --Variaveis locais
      vr_dtdpagto        crapepr.dtdpagto%TYPE;
      vr_dtdpagto_result crapepr.dtdpagto%TYPE;
      vr_nrparepr        PLS_INTEGER;
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.fn_calc_data_pagamento');
      -- Quantidade de Parcelas em Atraso
      vr_nrparepr := CEIL(pr_qtmesdec - pr_qtprecal);
      -- 01/Mes/Ano                             
      vr_dtdpagto := to_date('01/'||(to_char(pr_dtcalcul,'MM'))||'/'||to_char(pr_dtcalcul,'RRRR'),'DD/MM/RRRR');
      -- Decrementa a quantidade de parcelas em atraso
      vr_dtdpagto := ADD_MONTHS(vr_dtdpagto, - vr_nrparepr);
      -- Calcula a nova data de pagamento
      BEGIN
        vr_dtdpagto_result := to_date(to_char(pr_dtdpagto,'DD')||'/'||to_char(vr_dtdpagto,'MM')||'/'||to_char(vr_dtdpagto,'RRRR'),'DD/MM/RRRR');
      EXCEPTION
        WHEN OTHERS THEN
          vr_dtdpagto_result := ADD_MONTHS(vr_dtdpagto, 1);
      END;
      
      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
         
      RETURN(vr_dtdpagto_result);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception;   
        --Retornar zero
        RETURN(NULL);
    END;
  END; 
    
  /* Calcular a quantidade de dias que o emprestimo está em atraso */
  FUNCTION fn_calc_meses_decorridos(pr_cdcooper  IN crapepr.cdcooper%TYPE  --> Codigo da Cooperativa
                                   ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE  --> Quantidade de meses decorridos
                                   ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE  --> Data de Pagamento
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE) --> Data de movimento
   RETURN INTEGER IS
  BEGIN
    /* .............................................................................    
       Programa: fn_calc_meses_decorridos
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : James Prust Junior
       Data    : Agosto/2016                        Ultima atualizacao:22/09/2017
    
       Dados referentes ao programa:
    
       Frequencia: Diaria - Sempre que for chamada
       Objetivo  : Calcular os meses decorridos
    
       Alteracoes:     
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )
    ............................................................................. */
    DECLARE
      --Variaveis locais
      vr_qtmesdec INTEGER := 0;
      vr_dtdpagto crapepr.dtdpagto%TYPE;
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.fn_calc_meses_decorridos');
      vr_dtdpagto := pr_dtdpagto;
      vr_qtmesdec := pr_qtmesdec;

      LOOP
        -- Adiciona um mês
        vr_dtdpagto := fn_calc_data_prox_venc(pr_dtdpagto => vr_dtdpagto);

        -- Sair quando chegar a data atual
        EXIT WHEN vr_dtdpagto >= pr_dtmvtolt;
        EXIT WHEN vr_dtdpagto IS NULL;
      END LOOP;
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.fn_calc_meses_decorridos');

      -- Condicao para verificar se foi possivel calcular o proximo vencimento
      IF vr_dtdpagto IS NULL THEN
        RETURN(0);
      END IF;
      
      -- Vamos verificar se eh um dia util
      vr_dtdpagto := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                ,pr_dtmvtolt => vr_dtdpagto);
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.fn_calc_meses_decorridos');

      -- Caso a data do proximo vencimento eh hoje, devemos remover 1 mes dos meses decorridos
      IF vr_dtdpagto = pr_dtmvtolt THEN
        RETURN(vr_qtmesdec - 1);
      END IF;

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606      
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      
      RETURN(vr_qtmesdec);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception;   
        --Retornar zero
        RETURN(0);
    END;
  END;
    
  PROCEDURE pc_gera_log(pr_cdcooper IN craplgm.cdcooper%TYPE --> Codigo da Cooperativa
                       ,pr_nmdatela IN craplgm.nmdatela%TYPE --> Nome da tela
                       ,pr_nrdconta IN craplgm.nrdconta%TYPE --> Numero da conta
                       ,pr_cdoperad IN craplgm.cdoperad%TYPE --> Codigo do Operador
                       ,pr_dscritic IN craplgm.dscritic%TYPE --> Descricao da critica
                       ,pr_idorigem IN PLS_INTEGER           --> Codigo da Origem
                       ,pr_nrdrowid OUT ROWID                --> rowid
                       ,pr_dscriout OUT VARCHAR2             --> Descricao da critica
                       ) IS 
    /* .............................................................................

       Programa: pc_gera_log
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : 
       Data    :                                    Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para gerar Log.

       Alteracoes: 
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

    ............................................................................. */     
  BEGIN
    DECLARE
      -- Variaveis
      vr_flgtrans craplgm.flgtrans%TYPE := 0;
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_gera_log');  
      
      pr_dscriout := NULL;   
      IF TRIM(pr_dscritic) IS NOT NULL THEN
        vr_flgtrans := 1;
      END IF; 
        
      -- Gera LOG
			GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                   pr_cdoperad => pr_cdoperad,
													 pr_dscritic => pr_dscritic,
													 pr_dsorigem => TRIM(GENE0001.vr_vet_des_origens(pr_idorigem)),
													 pr_dstransa => 'Pagamento Multa/Juros de Mora emprestimo TR',
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => vr_flgtrans,
													 pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => pr_nmdatela,
													 pr_nrdconta => pr_nrdconta,
													 pr_nrdrowid => pr_nrdrowid);

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
        pr_dscriout := 'pc_gera_log - ' || SQLERRM;
    END;
  END pc_gera_log;

	PROCEDURE pc_cria_lanc_futuro(pr_cdcooper IN craplau.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta IN craplau.nrdconta%TYPE --> Conta
                               ,pr_nrdctitg IN craplau.nrdctitg%TYPE --> Conta integracao
                               ,pr_cdagenci IN craplau.cdagenci%TYPE --> Numero do PA
                               ,pr_dtmvtolt IN craplau.dtmvtolt%TYPE --> Data do movimento
                               ,pr_cdhistor IN craplau.cdhistor%TYPE --> Historico do lancamento
                               ,pr_vllanaut IN craplau.vllanaut%TYPE --> Valor do lancamento
                               ,pr_nrctremp IN craplau.nrctremp%TYPE --> Contrato
                               ,pr_dscritic OUT VARCHAR2) IS         --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_cria_lanc_futuro
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para criacao de lancamentos futuros.

       Alteracoes: 
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

    ............................................................................. */
    DECLARE
      -- Variaveis
      vr_nrseqdig INTEGER;

    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_cria_lanc_futuro');
      vr_nrseqdig := fn_sequence('CRAPLAU','NRSEQDIG',''||pr_cdcooper||';'||TO_CHAR(pr_dtmvtolt,'DD/MM/RRRR')||'');

      BEGIN
        INSERT INTO craplau
                   (cdcooper
                   ,nrdconta
                   ,nrdctabb
                   ,nrdctitg
                   ,cdagenci
                   ,dtmvtolt
                   ,dtmvtopg
                   ,cdhistor
                   ,vllanaut
                   ,nrseqdig
                   ,nrdocmto
                   ,nrctremp
                   ,cdbccxlt
                   ,nrdolote
                   ,insitlau
                   ,dtdebito
                   ,dsorigem)
             VALUES(pr_cdcooper
                   ,pr_nrdconta
                   ,pr_nrdconta
                   ,pr_nrdctitg
                   ,pr_cdagenci
                   ,pr_dtmvtolt
                   ,pr_dtmvtolt
                   ,pr_cdhistor
                   ,pr_vllanaut
                   ,vr_nrseqdig
                   ,vr_nrseqdig
                   ,pr_nrctremp
                   ,100
                   ,600033
                   ,1
                   ,NULL
                   ,'TRMULTAJUROS');

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
          pr_dscritic := 'pc_cria_lanc_futuro - ' || SQLERRM;
      END;
    END;

  END pc_cria_lanc_futuro;

	PROCEDURE pc_efetiva_pag_atraso_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craplot.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_nmdatela  IN crapprg.cdprogra%TYPE --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Contrato
                                    ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE --> Valor a pagar
                                    ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE --> Quantidade de meses decorridos
                                    ,pr_qtprecal  IN crapepr.qtprecal%TYPE --> Quantidade de prestacoes calculadas
                                    ,pr_vlpagpar  IN crapepr.vlpreemp%TYPE --> Valor de pagamento da parcela
                                    ,pr_vlsldisp  IN NUMBER DEFAULT NULL   --> Valor Saldo Disponivel
                                    ,pr_cdhismul OUT INTEGER               --> Historico da Multa
                                    ,pr_vldmulta OUT NUMBER                --> Valor da Multa
                                    ,pr_cdhismor OUT INTEGER               --> Historico Juros de Mora
                                    ,pr_vljumora OUT NUMBER                --> Valor Juros de Mora
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pag_atraso_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Efetivacao do pagamento da Multa e Juros de Mora do emprestimo TR.

       Alteracoes: 
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

    ............................................................................. */
    DECLARE
      -- Busca o emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.dtdpagto
              ,crapepr.flgpagto
              ,crapepr.inprejuz
              ,crapepr.cdlcremp
              ,crapepr.vlpreemp
              ,crapepr.qtpreemp
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca a linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.perjurmo,
               craplcr.flgcobmu,
               craplcr.dsoperac
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.vllimcre
              ,crapass.nrdctitg
              ,crapass.cdagenci
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_dscriout VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_des_reto  VARCHAR2(3);
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_blnfound BOOLEAN;
      vr_vldmulta NUMBER;
      vr_vllanfut NUMBER;
      vr_vllanmto NUMBER;
      vr_vldjuros NUMBER;
      vr_vlsldisp NUMBER;
      vr_vlsldis2 NUMBER;
      vr_floperac BOOLEAN;
      vr_cdhistor INTEGER;
      vr_nrdolote INTEGER := 600033;
      vr_nrdrowid ROWID;
      vr_dtcalcul DATE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_qtmesdec crapepr.qtmesdec%TYPE;
      vr_dtdpagto crapepr.dtdpagto%TYPE;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;
      -- Tabela de parcelas
      vr_tab_parcelas typ_tab_parcelas;


	PROCEDURE pc_calcula_juros_mora_tr(pr_dtcalcul     IN crapdat.dtmvtolt%TYPE      --> Movimento atual
                                    ,pr_perjurmo     IN craplcr.perjurmo%TYPE      --> Percentual de juros de mora por atraso
                                    ,pr_vlpagpar     IN NUMBER                     --> Valor Pago da Parcela
                                    ,pr_tab_parcelas IN EMPR0009.typ_tab_parcelas  --> Temp-Table contendo as parcelas em atraso
                                    ,pr_vldjuros     OUT crapepr.vlemprst%TYPE) IS --> Valor calculado
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_juros_mora_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o juros de mora do emprestimo TR.

       Alteracoes: 

    ............................................................................. */
    DECLARE
    	-- Variaveis
      vr_qtdiamor    INTEGER;
      vr_indice      INTEGER;
      vr_txdiaria    NUMBER;
      vr_vlatupar    NUMBER(12,2);
      vr_vlpagpar    NUMBER(12,2);
    BEGIN
      -- Inclui nome do modulo logado  - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_calcula_juros_mora_tr');
      vr_vlpagpar := pr_vlpagpar;
      ------------------------------------------------------------------------------------
      -- Calculo da taxa de mora diaria
      ------------------------------------------------------------------------------------
      vr_txdiaria := ROUND((100 * (POWER((pr_perjurmo / 100) + 1,(1 / 30)) - 1)),10) / 100;

      -- Vamos percorrer todas as parcelas em atraso
      vr_indice := pr_tab_parcelas.FIRST;
      WHILE vr_indice IS NOT NULL LOOP
        ------------------------------------------------------------------------------------
        -- Calculo dos dias de atraso
        ------------------------------------------------------------------------------------
        vr_qtdiamor := pr_dtcalcul - pr_tab_parcelas(vr_indice).dtvencto;
        -- Valor atualizado da parcela
        vr_vlatupar := pr_tab_parcelas(vr_indice).vlatupar;        
        
        ------------------------------------------------------------------------------------
        -- Condicao para verificar se houve pagamento parcial do atraso
        ------------------------------------------------------------------------------------
        IF NVL(vr_vlatupar,0) > NVL(vr_vlpagpar,0) THEN
          vr_vlatupar := NVL(vr_vlpagpar,0);
        END IF;
        
        ------------------------------------------------------------------------------------
        -- Condicao para verificar se possui saldo disponivel para cobrar a parcela
        ------------------------------------------------------------------------------------
        IF vr_vlpagpar <= 0 THEN
          EXIT;
        END IF;

        ------------------------------------------------------------------------------------
        -- Calculo do Juros de Mora que sera cobrado
        ------------------------------------------------------------------------------------
        pr_vldjuros := NVL(pr_vldjuros,0) + ROUND((vr_vlatupar * vr_txdiaria * vr_qtdiamor),2);
        vr_vlpagpar := NVL(vr_vlpagpar,0) - vr_vlatupar;
        --Proximo Registro
        vr_indice:= pr_tab_parcelas.NEXT(vr_indice);
      END LOOP;  
      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);

    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
        vr_dscritic := 'pc_calcula_juros_mora_tr - ' || SQLERRM;  
        vr_cdcritic := 0;
        RAISE vr_exc_erro;  
    END;

  END pc_calcula_juros_mora_tr;

  /* Criar e Atualiza Tabela Temporaria de Parcelas  */
  PROCEDURE pc_cria_atualiza_ttparcelas(pr_nrparepr      IN INTEGER --> Numero da Parcela
                                       ,pr_dtvencto      IN DATE    --> Data de Vencimento
                                       ,pr_vlatupar      IN NUMBER  --> Valor atualizado da parcela
                                       ,pr_tab_parcelas  IN OUT EMPR0009.typ_tab_parcelas) IS --> Tabela de Parcelas
  BEGIN
    DECLARE
      vr_indice NUMBER;    
    BEGIN  
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_cria_atualiza_ttparcelas');
      vr_indice := pr_tab_parcelas.COUNT() + 1;
      -- Copiar as informações da tabela para a temp-table
      pr_tab_parcelas(vr_indice).nrparepr := pr_nrparepr;
      pr_tab_parcelas(vr_indice).dtvencto := pr_dtvencto;
      pr_tab_parcelas(vr_indice).vlatupar := pr_vlatupar;   

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
        vr_dscritic := 'pc_cria_atualiza_ttparcelas - ' || SQLERRM;  
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
    END;
  END pc_cria_atualiza_ttparcelas;
  
	PROCEDURE pc_calcula_atraso_tr(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa
                                ,pr_dtcalcul  IN crapdat.dtmvtolt%TYPE   --> Movimento atual
                                ,pr_dtdpagto  IN crapepr.dtdpagto%TYPE   --> Data do pagamento
                                ,pr_qtpreemp  IN crapepr.qtpreemp%TYPE   --> Quantidade de prestacoes do emprestimo
                                ,pr_qtmesdec  IN crapepr.qtmesdec%TYPE   --> Quantidade de meses decorridos
                                ,pr_qtprecal  IN crapepr.qtprecal%TYPE   --> Quantidade de prestacoes calculadas
                                ,pr_vlpreemp  IN crapepr.vlpreemp%TYPE   --> Valor da prestacao do emprestimo
                                ,pr_tab_parcelas IN OUT typ_tab_parcelas) IS --> Temp-table das parcelas
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_atraso_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor do atraso do emprestimo TR.

       Alteracoes: 
    ............................................................................. */
    DECLARE
    	-- Variaveis
      vr_nrparepr  INTEGER;
      vr_dtvencto  DATE;
      vr_dtdpagto  DATE;
      vr_vlatraso  NUMBER(12,2);
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_calcula_atraso_tr');
      vr_dtdpagto := pr_dtdpagto;
      
      -- Calculo para identificar quantas parcelas estao em atraso
      vr_nrparepr := fn_calc_qtde_parc_atraso(pr_qtpreemp => pr_qtpreemp
                                             ,pr_qtmesdec => pr_qtmesdec
                                             ,pr_qtprecal => pr_qtprecal); 
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_calcula_atraso_tr');     
      -- Calcular o valor do juros de mora para cada parcela
      FOR vr_indice IN 1 .. vr_nrparepr LOOP
        -- Condicao para a primeira parcela
        IF vr_indice = 1 THEN
          -- Data do primeiro vencimento
          vr_dtvencto := vr_dtdpagto;
          -- Calculo para verificar se jah foi pago alguma coisa da primeira parcela
          vr_vlatraso := NVL(pr_vlpreemp,0) - ROUND((NVL(pr_qtprecal,0) - FLOOR(NVL(pr_qtprecal,0))) * NVL(pr_vlpreemp,0),2);          
        ELSE          
          -- Busca o proximo vencimento da parcela
          vr_dtdpagto := fn_calc_data_prox_venc(pr_dtdpagto => vr_dtdpagto);
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'EMPR0009.pc_calcula_atraso_tr');                                                  
          -- Vamos verificar se eh um dia util
          vr_dtvencto := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => vr_dtdpagto);
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'EMPR0009.pc_calcula_atraso_tr');                                                       
          -- Valor do atraso sera o valor da parcela
          vr_vlatraso := NVL(pr_vlpreemp,0);
        END IF;        
        
        IF pr_dtcalcul > vr_dtvencto THEN
          -- Armazena na Temp-Table o valor atualizado da primeira parcela
          pc_cria_atualiza_ttparcelas(pr_nrparepr     => vr_nrparepr
                                     ,pr_dtvencto     => vr_dtdpagto
                                     ,pr_vlatupar     => vr_vlatraso
                                     ,pr_tab_parcelas => pr_tab_parcelas);
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'EMPR0009.pc_calcula_atraso_tr');   
        END IF;
      END LOOP;    
      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606  
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
        vr_dscritic := 'pc_calcula_atraso_tr - ' || SQLERRM;  
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
    END;
  END pc_calcula_atraso_tr;

	PROCEDURE pc_calcula_multa_tr(pr_cdcooper     IN crapcop.cdcooper%TYPE         --> Código da Cooperativa
                               ,pr_vlpagpar     IN NUMBER                        --> Valor Pago da Parcela
                               ,pr_tab_parcelas IN OUT EMPR0009.typ_tab_parcelas --> Temp-Table contendo as parcelas em atraso
                               ,pr_vldmulta     OUT NUMBER) IS  --> Valor calculado
  BEGIN
    /* .............................................................................

       Programa: pc_calcula_multa_tr
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao: 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para calcular o valor da multa do emprestimo TR.

       Alteracoes: 

    ............................................................................. */
    DECLARE
      -- Variaveis
      vr_vlperctl NUMBER;
      vr_indice   NUMBER;
      vr_vlatraso NUMBER := 0;
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_calcula_multa_tr');
      -- Carrega o percentual
      vr_vlperctl := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_cdacesso => 'PERCENTUAL_MULTA_TR');
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_calcula_multa_tr');
      
      vr_indice := pr_tab_parcelas.FIRST;
      WHILE vr_indice IS NOT NULL LOOP
        vr_vlatraso := NVL(vr_vlatraso,0) + NVL(pr_tab_parcelas(vr_indice).vlatupar,0);
        --Proximo Registro
        vr_indice:= pr_tab_parcelas.NEXT(vr_indice);
      END LOOP;
      
      -- Caso somente foi pago uma parte do valor de atraso, o valor de atraso sera o valor pago
      IF NVL(vr_vlatraso,0) > NVL(pr_vlpagpar,0) THEN
        vr_vlatraso := NVL(pr_vlpagpar,0);
      END IF;
      
      -- Calcula a multa
      pr_vldmulta := vr_vlatraso * (vr_vlperctl / 100);     

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
        vr_dscritic := 'pc_calcula_multa_tr - ' || SQLERRM;  
        vr_cdcritic := 0;
        RAISE vr_exc_erro;
    END;

  END pc_calcula_multa_tr;

    --                                         inicio do processo
          
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
      -- Limpa tabela saldos
      vr_tab_saldos.DELETE;
      vr_tab_parcelas.DELETE;
      
      -- Reseta os valores
      pr_cdhismul := 0;
      pr_vldmulta := 0;
      pr_cdhismor := 0;
      pr_vljumora := 0;
      
      -- Seta o operador
      vr_cdoperad := NVL(TRIM(pr_cdoperad), '1');
      IF vr_cdoperad = '0' THEN
        vr_cdoperad := '1';
      END IF;

      -- Caso NAO esteja habilitado a cobranca de multa e juros de mora
      IF GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_cdacesso => 'HABIL_COB_MULTA_JUROS_TR') <> '1' THEN
        RAISE vr_exc_saida;
      END IF;

      -- Caso NAO tenha valor a pagar
      IF NVL(pr_vlpreapg, 0) = 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a data esta cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Alimenta a booleana
      vr_blnfound := BTCH0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana
      vr_blnfound := cr_crapass%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapass;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Alimenta a booleana
      vr_blnfound := cr_crapepr%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapepr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 356;
        RAISE vr_exc_erro;
      END IF;

      -- Parcela precisa estar vencida
      IF ((rw_crapepr.dtdpagto > rw_crapdat.dtmvtoan AND rw_crapepr.dtdpagto <= rw_crapdat.dtmvtolt) OR 
          (rw_crapepr.dtdpagto >= rw_crapdat.dtmvtolt)) THEN
        RAISE vr_exc_saida;
      END IF;

      -- Emprestimo em Folha nao sera cobrado Juros de Mora e Multa
      IF rw_crapepr.flgpagto = 1 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Emprestimo em Prejuizo nao sera cobrado Juros de Mora e Multa
      IF rw_crapepr.inprejuz = 1 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se nao tem Valor de pagamento da parcela
      IF NVL(pr_vlpagpar, 0) = 0 THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Condicao para verificar se as prestacoes pagas é maior ou igual aos meses decorridos
      IF NVL(pr_qtprecal,0) > NVL(pr_qtmesdec,0) THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Condicao para verificar se as prestacoes pagas é maior ou igual a quantidade de prestacoes do emprestimo
      IF NVL(pr_qtprecal,0) >= NVL(rw_crapepr.qtpreemp,0) THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca a linha de credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Alimenta a booleana
      vr_blnfound := cr_craplcr%FOUND;
      -- Fechar o cursor
      CLOSE cr_craplcr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 55;
        RAISE vr_exc_erro;
      END IF;

      -- Verificar na linha de credito se possui cobranca de multa e juros de mora
      IF rw_craplcr.flgcobmu = 0 AND NVL(rw_craplcr.perjurmo,0) <= 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se foi passado o Saldo Disponivel
      IF pr_vlsldisp IS NOT NULL THEN
        vr_vlsldisp := ROUND(pr_vlsldisp,2);
      ELSE
        -- Obter Saldo do Dia
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => pr_cdagenci
                                   ,pr_nrdcaixa   => pr_nrdcaixa
                                   ,pr_cdoperad   => vr_cdoperad
                                   ,pr_nrdconta   => pr_nrdconta
                                   ,pr_flgcrass   => FALSE
                                   ,pr_vllimcre   => rw_crapass.vllimcre
                                   ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                   ,pr_des_reto   => vr_des_reto
                                   ,pr_tab_sald   => vr_tab_saldos
                                   ,pr_tipo_busca => 'A'
                                   ,pr_tab_erro   => vr_tab_erro);
        -- Buscar Indice
        vr_index := vr_tab_saldos.FIRST;
        IF vr_index IS NOT NULL THEN
          -- Saldo Disponivel
          vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index).vlsddisp, 0) +
                               NVL(vr_tab_saldos(vr_index).vlsdchsl, 0) +
                               NVL(vr_tab_saldos(vr_index).vllimcre, 0),2);
        END IF;
      END IF;
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

      -- Guarda o saldo antes dos debitos
      vr_vlsldis2 := vr_vlsldisp;
      -- Verifica se eh financiamento
      vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
      -- Pagamento de Emprestimo de Boleto POR FORA
      IF pr_nmdatela = 'COMPEFORA' THEN
        vr_dtcalcul := rw_crapdat.dtmvtoan;
      ELSE
        vr_dtcalcul := rw_crapdat.dtmvtolt;
      END IF;

      -- Fazer o calculo dos meses decorridos
      vr_qtmesdec := fn_calc_meses_decorridos(pr_cdcooper => pr_cdcooper
                                             ,pr_qtmesdec => pr_qtmesdec
                                             ,pr_dtdpagto => rw_crapepr.dtdpagto
                                             ,pr_dtmvtolt => vr_dtcalcul);  

      -- Condicao para verificar se foi possivel calcular os meses decorridos
      IF vr_qtmesdec = 0 THEN
        vr_dscritic := 'Nao foi possivel calcular os meses decorridos. Conta: ' || pr_nrdconta ||'. Contrato: '|| pr_nrctremp;
        -- Procedure para gravar o log
        pc_gera_log(pr_cdcooper => pr_cdcooper
                   ,pr_nmdatela => pr_nmdatela
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_cdoperad => pr_cdoperad
                   ,pr_dscritic => vr_dscritic
                   ,pr_idorigem => pr_idorigem
                   ,pr_nrdrowid => vr_nrdrowid
                   ,pr_dscriout => vr_dscriout);
        -- Se ocorreu erro
        IF vr_dscriout IS NOT NULL THEN
            vr_dscritic := vr_dscritic || ' - ' || vr_dscriout;
            RAISE vr_exc_erro;
        ELSE
            RAISE vr_exc_saida;
        END IF;
      END IF;
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
      
      -- Calcular a real data de pagamento
      vr_dtdpagto := fn_calc_data_pagamento(pr_qtmesdec => vr_qtmesdec
                                           ,pr_qtprecal => pr_qtprecal
                                           ,pr_dtdpagto => rw_crapepr.dtdpagto
                                           ,pr_dtcalcul => vr_dtcalcul);
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
                                             
      ------------------------------------------------------------------------------------------------
      --                           Calcula as parcelas em atraso
      ------------------------------------------------------------------------------------------------
      pc_calcula_atraso_tr(pr_cdcooper     => pr_cdcooper
                          ,pr_dtcalcul     => vr_dtcalcul
                          ,pr_dtdpagto     => vr_dtdpagto
                          ,pr_qtpreemp     => rw_crapepr.qtpreemp
                          ,pr_qtmesdec     => vr_qtmesdec
                          ,pr_qtprecal     => pr_qtprecal
                          ,pr_vlpreemp     => rw_crapepr.vlpreemp
                          ,pr_tab_parcelas => vr_tab_parcelas);
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
      ------------------------------------------------------------------------------------------------
      --                           Condicao para verificar se cobra multa
      ------------------------------------------------------------------------------------------------
      IF rw_craplcr.flgcobmu = 1 THEN
        -- Calcula o valor que sera cobrado da multa
        pc_calcula_multa_tr(pr_cdcooper     => pr_cdcooper
                           ,pr_vlpagpar     => pr_vlpagpar
                           ,pr_tab_parcelas => vr_tab_parcelas
                           ,pr_vldmulta     => vr_vldmulta);
        -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                              ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
          
        -- Se possuir multa para debitar
        IF vr_vldmulta > 0 THEN
          
          IF vr_floperac THEN
            vr_cdhistor := 2084; -- Financiamento
          ELSE
            vr_cdhistor := 2090; -- Emprestimo
          END IF;

          vr_vllanmto := 0;
          vr_vllanfut := 0;

          -- Cobrar valor integral
          IF vr_vlsldisp - vr_vldmulta >= 0 THEN
            vr_vllanmto := vr_vldmulta;
          -- Cobrar valor parcial
          ELSIF vr_vldmulta - vr_vlsldisp >= 0 AND vr_vlsldisp > 0 THEN
            vr_vllanmto := vr_vlsldisp;
            vr_vllanfut := vr_vldmulta - vr_vllanmto;
          ELSE
             vr_vllanfut := vr_vldmulta;
          END IF;
          
          -- Verifica se efetua o lancamento na conta
          IF vr_vllanmto > 0 THEN

            -- Criar o lancamento da Multa
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                          ,pr_cdbccxlt => 100                 --> Numero do caixa
                                          ,pr_cdoperad => vr_cdoperad         --> Codigo do Operador
                                          ,pr_cdpactra => pr_cdagenci         --> P.A. da transacao
                                          ,pr_nrdolote => vr_nrdolote         --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                          ,pr_cdhistor => vr_cdhistor         --> Codigo historico
                                          ,pr_vllanmto => vr_vllanmto         --> Valor da Multa
                                          ,pr_nrparepr => 0                   --> Numero parcelas emprestimo
                                          ,pr_nrctremp => pr_nrctremp         --> Numero do contrato de emprestimo
                                          ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela de erros
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento da Multa.';
              END IF;
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

          END IF;

          -- Verifica se lanca na tela LAUTOM
          IF vr_vllanfut > 0 THEN

            -- Criar o registro para exibir na tela LAUTOM
            EMPR0009.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdctitg => rw_crapass.nrdctitg
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_vllanaut => vr_vllanfut
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

          END IF;

          -- Diminuir a multa do saldo disponivel
          vr_vlsldisp := vr_vlsldisp - vr_vllanmto;
          
          -- Retorna os valores
          pr_cdhismul := vr_cdhistor;
          pr_vldmulta := vr_vllanmto;

        END IF; -- vr_vldmulta > 0

      END IF; -- rw_craplcr.flgcobmu = 1

      ------------------------------------------------------------------------------------------------
      --                           Condicao para verificar se cobra Juros de Mora
      ------------------------------------------------------------------------------------------------
      IF NVL(rw_craplcr.perjurmo,0) > 0 THEN      
        -- Calcular o valor do juros de mora
        pc_calcula_juros_mora_tr(pr_dtcalcul     => vr_dtcalcul
                                ,pr_perjurmo     => rw_craplcr.perjurmo
                                ,pr_vlpagpar     => pr_vlpagpar
                                ,pr_tab_parcelas => vr_tab_parcelas
                                ,pr_vldjuros     => vr_vldjuros);
        -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                              ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
        -- Se possuir Juros de Mora para debitar
        IF vr_vldjuros > 0 THEN
          IF vr_floperac THEN
            vr_cdhistor := 2087; -- Financiamento
          ELSE
            vr_cdhistor := 2093; -- Emprestimo
          END IF;

          vr_vllanmto := 0;
          vr_vllanfut := 0;

          -- Cobrar valor integral
          IF vr_vlsldisp - vr_vldjuros >= 0 THEN
            vr_vllanmto := vr_vldjuros;
          -- Cobrar valor parcial
          ELSIF vr_vldjuros - vr_vlsldisp >= 0 AND vr_vlsldisp > 0 THEN
            vr_vllanmto := vr_vlsldisp;
            vr_vllanfut := vr_vldjuros - vr_vllanmto;
          ELSE
             vr_vllanfut := vr_vldjuros;
          END IF;

          -- Verifica se efetua o lancamento na conta
          IF vr_vllanmto > 0 THEN
            -- Criar o lancamento do Juros de Mora
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                          ,pr_cdbccxlt => 100                 --> Numero do caixa
                                          ,pr_cdoperad => vr_cdoperad         --> Codigo do Operador
                                          ,pr_cdpactra => pr_cdagenci         --> P.A. da transacao
                                          ,pr_nrdolote => vr_nrdolote         --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                          ,pr_cdhistor => vr_cdhistor         --> Codigo historico
                                          ,pr_vllanmto => vr_vllanmto         --> Valor do Juros de Mora
                                          ,pr_nrparepr => 0                   --> Numero parcelas emprestimo
                                          ,pr_nrctremp => pr_nrctremp         --> Numero do contrato de emprestimo
                                          ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela de erros
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento do Juros de Mora.';
              END IF;
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
          END IF;

          -- Verifica se lanca na tela LAUTOM
          IF vr_vllanfut > 0 THEN

            -- Criar o registro para exibir na tela LAUTOM
            EMPR0009.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdctitg => rw_crapass.nrdctitg
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_vllanaut => vr_vllanfut
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dscritic => vr_dscritic);
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

          END IF;

          -- Diminuir a multa do saldo disponivel
          vr_vlsldisp := vr_vlsldisp - vr_vllanmto;

          -- Retorna os valores
          pr_cdhismor := vr_cdhistor;
          pr_vljumora := vr_vllanmto;

        END IF; -- vr_vldjuros > 0
        
      END IF;
      
      -- Procedure para gravar o log
      pc_gera_log(pr_cdcooper => pr_cdcooper
                 ,pr_nmdatela => pr_nmdatela
                 ,pr_nrdconta => pr_nrdconta
                 ,pr_cdoperad => pr_cdoperad
                 ,pr_dscritic => NULL
                 ,pr_idorigem => pr_idorigem
                 ,pr_nrdrowid => vr_nrdrowid
                 ,pr_dscriout => vr_dscriout);
      -- Se ocorreu erro
      IF vr_dscriout IS NOT NULL THEN
         vr_dscritic := vr_dscriout;
         RAISE vr_exc_erro;
      END IF;
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
                   
		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Contrato',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nrctremp);
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Data de Pagamento',
																pr_dsdadant => TO_CHAR(rw_crapepr.dtdpagto,'DD/MM/RRRR'),
																pr_dsdadatu => TO_CHAR(vr_dtdpagto,'DD/MM/RRRR'));
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Saldo Disponivel CC',
																pr_dsdadant => TO_CHAR(vr_vlsldis2,'fm999g999g999g990d00'),
																pr_dsdadatu => TO_CHAR(vr_vlsldisp,'fm999g999g999g990d00'));
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Pago',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(pr_vlpagpar,'fm999g999g999g990d00'));
      -- Inclui nome do modulo logado
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

      -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Meses Decorridos',
																pr_dsdadant => vr_qtmesdec,
																pr_dsdadatu => pr_qtmesdec);
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');
                        
      -- Gera item do LOG        
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Qtde. Prest. Pagas',
																pr_dsdadant => '',
																pr_dsdadatu => pr_qtprecal);  
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

      -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Multa',
																pr_dsdadant => '0',
																pr_dsdadatu => TO_CHAR(pr_vldmulta,'fm999g999g999g990d00'));
      -- Inclui nome do modulo logado
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr');

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Juros Mora',
																pr_dsdadant => '0',
																pr_dsdadatu => TO_CHAR(pr_vljumora,'fm999g999g999g990d00'));

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Grava informações para resolver erro de programa/ sistema - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => pr_cdcooper
                                       ,pr_dstiplog => 'E'
                                       ,pr_nmrotina => 'EMPR0009'
                                       ,pr_dscritic => 'pc_efetiva_pag_atraso_tr' ||
                                                       ' - pr_nmdatela: ' || pr_nmdatela ||
                                                       ' - pr_nrdconta: ' || pr_nrdconta ||
                                                       ' - pr_cdoperad: ' || pr_cdoperad ||
                                                       ' - pr_idorigem: ' || pr_idorigem ||
                                                       ' - pr_dscritic: ' || pr_dscritic);
      WHEN vr_exc_saida THEN
        NULL;

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela EMPR0009.pc_efetiva_pag_atraso_tr: ' || SQLERRM;
        -- Grava informações para resolver erro de programa/ sistema - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => pr_cdcooper
                                       ,pr_dstiplog => 'E'
                                       ,pr_nmrotina => 'EMPR0009'
                                       ,pr_dscritic => 'pc_efetiva_pag_atraso_tr' ||
                                                       ' - pr_nmdatela: ' || pr_nmdatela ||
                                                       ' - pr_nrdconta: ' || pr_nrdconta ||
                                                       ' - pr_cdoperad: ' || pr_cdoperad ||
                                                       ' - pr_idorigem: ' || pr_idorigem ||
                                                       ' - pr_dscritic: ' || pr_dscritic);
    END;

  END pc_efetiva_pag_atraso_tr;

	PROCEDURE pc_efetiva_lcto_pendente_job IS
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_lcto_pendente_job
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Jaison Fernando
       Data    : Maio/2016                         Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Procedure para efetivar o lancamento pendente via JOB.

       Alteracoes: 21/10/2016 - Incluir reset da variável de controle de log, pois
                                estava gerando o log de início apenas para a primeira
                                cooperativa executada ( Renato Darosci - Supero )
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

    ............................................................................. */
    DECLARE

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cdcooper
          FROM crapcop
         WHERE flgativo = 1;

      -- Cursor para retornar lancamentos automaticos
      CURSOR cr_craplau(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT nrdconta
              ,vllanaut
              ,dtmvtolt
              ,nrdolote
              ,nrseqdig
              ,cdhistor
              ,nrctremp
              ,cdbccxlt
              ,cdagenci
              ,ROW_NUMBER() OVER (PARTITION BY nrdconta ORDER BY nrdconta) AS numconta
          FROM craplau
         WHERE cdcooper = pr_cdcooper
           AND insitlau = 1 -- Pendente
           AND cdbccxlt = 100
           AND nrdolote = 600033
           AND dsorigem = 'TRMULTAJUROS';

      -- Busca dados do cooperado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdagenci
              ,vllimcre
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variaveis
      vr_index    PLS_INTEGER;
      vr_blnfound BOOLEAN;
      vr_flgerlog BOOLEAN := FALSE;
      vr_des_reto VARCHAR2(3);
      vr_vlsldisp NUMBER;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;

      -- 22/09/2017 - Ch 758606
      -- Substituida rotina pc_controla_log_batch pela pc_grava_erro_programa

    BEGIN      
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job');
      -- Listagem de cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP
        
        -- Deve resetar a variável para cada cooperativa
        vr_flgerlog := FALSE;
      
        -- Log de inicio de execucao - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dstiplog => 'I'
                                       ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                       ,pr_dscritic => NULL
                                       );
        -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => NULL
                              ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job'); 

        -- Verifica se a data esta cadastrada
        OPEN  BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        -- Alimenta a booleana
        vr_blnfound := BTCH0001.cr_crapdat%FOUND;
        -- Fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          -- Log de erro de execucao - 22/09/2017 - Ch 758606
          empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dstiplog => 'E'
                                         ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                         ,pr_dscritic => 'pc_efetiva_lcto_pendente_job - 1' ||
                                                         ' - cdcooper: ' || rw_crapcop.cdcooper ||
                                                         ' - dscritic: ' || 
                                                         GENE0001.fn_busca_critica(pr_cdcritic => 1));
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job'); 
          CONTINUE;
        END IF;

        -- Final de semana e Feriado nao pode ocorrer o debito
        IF TRUNC(SYSDATE) <> rw_crapdat.dtmvtolt and rw_crapdat.inproces = 1 THEN
          -- Log de final de execucao, antes de passar a proxima cooperativa - 22/09/2017 - Ch 758606
          empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dstiplog => 'F'
                                         ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                         ,pr_dscritic => NULL
                                         );
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job'); 
        
          CONTINUE;
        END IF;

        -- Condicao para verificar se o processo estah rodando
        IF NVL(rw_crapdat.inproces,0) <> 1 THEN
          -- Log de final de execucao, antes de passar a proxima cooperativa - 22/09/2017 - Ch 758606
          empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                         ,pr_dstiplog => 'F'
                                         ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                         ,pr_dscritic => NULL
                                         );
          -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
          GENE0001.pc_set_modulo(pr_module => NULL
                                ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job');                              
          CONTINUE;
        END IF;

        -- Busca todos os lancamentos pendentes
        FOR rw_craplau IN cr_craplau(pr_cdcooper => rw_crapcop.cdcooper) LOOP

          -- Se for a primeira vez de acesso da conta
          IF rw_craplau.numconta = 1 THEN
            
            -- Busca dados do cooperado
            OPEN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrdconta => rw_craplau.nrdconta);
            FETCH cr_crapass INTO rw_crapass;
            -- Fecha o cursor
            CLOSE cr_crapass;

            -- Limpa tabela saldos
            vr_tab_saldos.DELETE;
      		
            -- Buscar o saldo disponivel a vista		
            EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_crapcop.cdcooper
                                       ,pr_rw_crapdat => rw_crapdat
                                       ,pr_cdagenci   => rw_crapass.cdagenci
                                       ,pr_nrdcaixa   => 0
                                       ,pr_cdoperad   => '1'
                                       ,pr_nrdconta   => rw_craplau.nrdconta
                                       ,pr_flgcrass   => FALSE
                                       ,pr_vllimcre   => rw_crapass.vllimcre
                                       ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                       ,pr_des_reto   => vr_des_reto
                                       ,pr_tab_sald   => vr_tab_saldos
                                       ,pr_tipo_busca => 'A'
                                       ,pr_tab_erro   => vr_tab_erro);
            -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job'); 
            -- Buscar Indice
            vr_index := vr_tab_saldos.FIRST;
            IF vr_index IS NOT NULL THEN
              -- Saldo Disponivel
              vr_vlsldisp := ROUND(NVL(vr_tab_saldos(vr_index).vlsddisp, 0) +
                                   NVL(vr_tab_saldos(vr_index).vlsdchsl, 0) +
                                   NVL(vr_tab_saldos(vr_index).vllimcre, 0),2);
            END IF;
          END IF;

          -- Verificar se possui saldo disponivel
          IF NVL(vr_vlsldisp, 0) - rw_craplau.vllanaut >= 0 THEN
            -- Efetivar lancamento
            TELA_LAUTOM.pc_efetiva_lcto_pendente(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_dtrefere => rw_craplau.dtmvtolt
                                                ,pr_cdagenci => rw_craplau.cdagenci
                                                ,pr_cdbccxlt => rw_craplau.cdbccxlt
                                                ,pr_cdoperad => '1'
                                                ,pr_nrdolote => rw_craplau.nrdolote
                                                ,pr_nrdconta => rw_craplau.nrdconta
                                                ,pr_cdhistor => rw_craplau.cdhistor
                                                ,pr_nrctremp => rw_craplau.nrctremp
                                                ,pr_nrseqdig => rw_craplau.nrseqdig
                                                ,pr_vllanmto => rw_craplau.vllanaut
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic);
            -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job'); 
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              -- Log de erro de execucao - 22/09/2017 - Ch 758606
              empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                             ,pr_dstiplog => 'E'
                                             ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                             ,pr_dscritic => 'pc_efetiva_lcto_pendente_job - 2' ||
                                                             ' - cdcooper: ' || rw_crapcop.cdcooper ||
                                                             ' - dtmvtolt: ' || rw_craplau.dtmvtolt ||
                                                             ' - cdagenci: ' || rw_craplau.cdagenci ||
                                                             ' - cdbccxlt: ' || rw_craplau.cdbccxlt ||
                                                             ' - nrdolote: ' || rw_craplau.nrdolote ||
                                                             ' - nrdconta: ' || rw_craplau.nrdconta ||
                                                             ' - cdhistor: ' || rw_craplau.cdhistor ||
                                                             ' - nrctremp: ' || rw_craplau.nrctremp ||
                                                             ' - dtmvtolt: ' || rw_craplau.nrseqdig ||
                                                             ' - vllanaut: ' || rw_craplau.vllanaut ||
                                                             ' - cdcritic: ' || vr_cdcritic ||
                                                             ' - dscritic: ' || vr_dscritic);
              -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
              GENE0001.pc_set_modulo(pr_module => NULL
                                    ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job'); 
              ROLLBACK;
              CONTINUE;
            END IF;

            -- Para cada lancamento diminuir saldo disponivel
            vr_vlsldisp	:= vr_vlsldisp - rw_craplau.vllanaut;

          END IF;
          
          COMMIT;

        END LOOP; -- cr_craplau

        -- Log de final de execucao - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_dstiplog => 'F'
                                       ,pr_nmrotina => 'JBEPR_LCTO_MULTA_JUROS_TR'
                                       ,pr_dscritic => NULL);
        -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => NULL
                              ,pr_action => 'EMPR0009.pc_efetiva_lcto_pendente_job');    

      END LOOP; -- cr_crapcop

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_saida THEN
        NULL;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception;  
        vr_dscritic := 'Erro geral na rotina da tela EMPR0009.pc_efetiva_pag_atraso_tr: ' || SQLERRM;
        -- Grava informações para resolver erro de programa/ sistema - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => 3
                                       ,pr_dstiplog => 'E'
                                       ,pr_nmrotina => 'EMPR0009'
                                       ,pr_dscritic => 'pc_efetiva_lcto_pendente_job - OTHERS' ||
                                                       ' - vr_dscritic: ' || vr_dscritic); 
    END;

  END pc_efetiva_lcto_pendente_job;

	PROCEDURE pc_efetiva_pag_atraso_tr_prc(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_cdoperad  IN craplot.cdoperad%TYPE --> Operador
                                    ,pr_nmdatela  IN crapprg.cdprogra%TYPE --> Nome da Tela
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_nrdconta  IN crapepr.nrdconta%TYPE --> Conta
                                    ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Contrato
                                    ,pr_vlpreapg  IN crapepr.vlpreemp%TYPE --> Valor a pagar
                                    ,pr_nrparcela IN tbepr_tr_parcelas.nrparcela%TYPE --> Numero da parcela a pagar
                                    ,pr_dtdpagto  IN tbepr_tr_parcelas.dtdpagto%TYPE  --> Data de pagamento original - vencimento parcela
                                    ,pr_vlpagpar  IN crapepr.vlpreemp%TYPE --> Valor de pagamento da parcela
                                    ,pr_vlsldisp  IN NUMBER DEFAULT NULL   --> Valor Saldo Disponivel
                                    ,pr_cdhismul OUT INTEGER               --> Historico da Multa
                                    ,pr_vldmulta OUT NUMBER                --> Valor da Multa
                                    ,pr_cdhismor OUT INTEGER               --> Historico Juros de Mora
                                    ,pr_vljumora OUT NUMBER                --> Valor Juros de Mora
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
  BEGIN
    /* .............................................................................

       Programa: pc_efetiva_pag_atraso_tr_prc
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Everton Wilson de Soua
       Data    : Abril/2017                         Ultima atualizacao:22/09/2017 

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.

       Objetivo  : Efetivacao do pagamento da Multa e Juros de Mora do emprestimo TR por parcela.

       Alteracoes: 
                   22/09/2017 - Ajustar padrão de Logs
                                Ajustar padrão de Exception Others
                                Inclui nome do modulo logado
                                ( Belli - Envolti - Chamados 697089 758606 )

    ............................................................................. */
    DECLARE
      -- Busca o emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.dtdpagto
              ,crapepr.flgpagto
              ,crapepr.inprejuz
              ,crapepr.cdlcremp
              ,crapepr.vlpreemp
              ,crapepr.qtpreemp
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Busca a linha de credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.perjurmo,
               craplcr.flgcobmu,
               craplcr.dsoperac
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Busca o associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.vllimcre
              ,crapass.nrdctitg
              ,crapass.cdagenci
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_dscriout VARCHAR2(4000);

      -- Tratamento de erros
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
      vr_des_reto  VARCHAR2(3);
      vr_tab_erro  GENE0001.typ_tab_erro;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_vldmulta NUMBER;
      vr_vllanfut NUMBER;
      vr_vllanmto NUMBER;
      vr_vldjuros NUMBER;
      vr_vlsldisp NUMBER;
      vr_vlsldis2 NUMBER;
      vr_floperac BOOLEAN;
      vr_cdhistor INTEGER;
      vr_nrdolote INTEGER := 600033;
      vr_nrdrowid ROWID;
      vr_dtcalcul DATE;
      vr_cdoperad crapope.cdoperad%TYPE;
      vr_dtdpagto crapepr.dtdpagto%TYPE;
      vr_vlperctl NUMBER;
      vr_txdiaria NUMBER;
      vr_qtdiamor INTEGER;

      -- Tabela de Saldos
      vr_tab_saldos EXTR0001.typ_tab_saldos;
      -- Tabela de parcelas
      vr_tab_parcelas typ_tab_parcelas;
    BEGIN
      -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => NULL
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc');
      -- Limpa tabela saldos
      vr_tab_saldos.DELETE;
      vr_tab_parcelas.DELETE;
      
      -- Reseta os valores
      pr_cdhismul := 0;
      pr_vldmulta := 0;
      pr_cdhismor := 0;
      pr_vljumora := 0;
      
      -- Seta o operador
      vr_cdoperad := NVL(TRIM(pr_cdoperad), '1');
      IF vr_cdoperad = '0' THEN
        vr_cdoperad := '1';
      END IF;
      
      -- Caso NAO esteja habilitado a cobranca de multa e juros de mora
      IF GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_cdacesso => 'HABIL_COB_MULTA_JUROS_TR') <> '1' THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Caso NAO tenha valor a pagar
      IF NVL(pr_vlpreapg, 0) = 0 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Verifica se a data esta cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Alimenta a booleana
      vr_blnfound := BTCH0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Alimenta a booleana
      vr_blnfound := cr_crapass%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapass;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;

      -- Busca o emprestimo
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      -- Alimenta a booleana
      vr_blnfound := cr_crapepr%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapepr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 356;
        RAISE vr_exc_erro;
      END IF;

      -- Parcela precisa estar vencida
      IF ((pr_dtdpagto > rw_crapdat.dtmvtoan AND pr_dtdpagto <= rw_crapdat.dtmvtolt) OR 
          (pr_dtdpagto >= rw_crapdat.dtmvtolt)) THEN
        RAISE vr_exc_saida;
      END IF;

      -- Emprestimo em Folha nao sera cobrado Juros de Mora e Multa
      IF rw_crapepr.flgpagto = 1 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Emprestimo em Prejuizo nao sera cobrado Juros de Mora e Multa
      IF rw_crapepr.inprejuz = 1 THEN
        RAISE vr_exc_saida;
      END IF;

      -- Se nao tem Valor de pagamento da parcela
      IF NVL(pr_vlpagpar, 0) = 0 THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca a linha de credito
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      -- Alimenta a booleana
      vr_blnfound := cr_craplcr%FOUND;
      -- Fechar o cursor
      CLOSE cr_craplcr;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 55;
        RAISE vr_exc_erro;
      END IF;

      -- Verificar na linha de credito se possui cobranca de multa e juros de mora
      IF rw_craplcr.flgcobmu = 0 AND NVL(rw_craplcr.perjurmo,0) <= 0 THEN
        RAISE vr_exc_saida;
      END IF;
      -- Saldo Disponível
      vr_vlsldisp := ROUND(pr_vlsldisp,2);
      -- Guarda o saldo antes dos debitos
      vr_vlsldis2 := vr_vlsldisp;
      -- Verifica se eh financiamento
      vr_floperac := rw_craplcr.dsoperac = 'FINANCIAMENTO';
      -- 
      vr_dtcalcul := rw_crapdat.dtmvtolt;

      ------------------------------------------------------------------------------------------------
      --                           Condicao para verificar se cobra multa
      ------------------------------------------------------------------------------------------------
      IF rw_craplcr.flgcobmu = 1 THEN
        -- Carrega o percentual
        vr_vlperctl := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_cdacesso => 'PERCENTUAL_MULTA_TR');

        -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
        GENE0001.pc_set_modulo(pr_module => NULL
                              ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc');
        -- Calcula a multa
        vr_vldmulta := pr_vlpreapg * (vr_vlperctl / 100);

        -- Se possuir multa para debitar
        IF vr_vldmulta > 0 THEN
          
          IF vr_floperac THEN
            vr_cdhistor := 2084; -- Financiamento
          ELSE
            vr_cdhistor := 2090; -- Emprestimo
          END IF;

          vr_vllanmto := 0;
          vr_vllanfut := 0;

          -- Cobrar valor integral
          IF vr_vlsldisp - vr_vldmulta >= 0 THEN
            vr_vllanmto := vr_vldmulta;
          -- Cobrar valor parcial
          ELSIF vr_vldmulta - vr_vlsldisp >= 0 AND vr_vlsldisp > 0 THEN
            vr_vllanmto := vr_vlsldisp;
            vr_vllanfut := vr_vldmulta - vr_vllanmto;
          ELSE
             vr_vllanfut := vr_vldmulta;
          END IF;
          
          -- Verifica se efetua o lancamento na conta
          IF vr_vllanmto > 0 THEN

            -- Criar o lancamento da Multa
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                          ,pr_cdbccxlt => 100                 --> Numero do caixa
                                          ,pr_cdoperad => vr_cdoperad         --> Codigo do Operador
                                          ,pr_cdpactra => pr_cdagenci         --> P.A. da transacao
                                          ,pr_nrdolote => vr_nrdolote         --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                          ,pr_cdhistor => vr_cdhistor         --> Codigo historico
                                          ,pr_vllanmto => vr_vllanmto         --> Valor da Multa
                                          ,pr_nrparepr => pr_nrparcela        --> Numero parcelas emprestimo
                                          ,pr_nrctremp => pr_nrctremp         --> Numero do contrato de emprestimo
                                          ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela de erros
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento da Multa.';
              END IF;
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc');
          END IF;
          
          -- Verifica se lanca na tela LAUTOM
          IF vr_vllanfut > 0 THEN
            -- Criar o registro para exibir na tela LAUTOM
            EMPR0009.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdctitg => rw_crapass.nrdctitg
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_vllanaut => vr_vllanfut
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dscritic => vr_dscritic);

            -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc');
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Diminuir a multa do saldo disponivel
          vr_vlsldisp := vr_vlsldisp - vr_vllanmto;
          
          -- Retorna os valores
          pr_cdhismul := vr_cdhistor;
          pr_vldmulta := vr_vllanmto;

        END IF; -- vr_vldmulta > 0

      END IF; -- rw_craplcr.flgcobmu = 1

      ------------------------------------------------------------------------------------------------
      --                           Condicao para verificar se cobra Juros de Mora
      ------------------------------------------------------------------------------------------------
      IF NVL(rw_craplcr.perjurmo,0) > 0 THEN      
        -- Calculo da taxa de mora diaria
        vr_txdiaria := ROUND((100 * (POWER((rw_craplcr.perjurmo / 100) + 1,(1 / 30)) - 1)),10) / 100;

        -- Calculo dos dias de atraso
        vr_qtdiamor := vr_dtcalcul - pr_dtdpagto;

        -- Calculo do Juros de Mora que sera cobrado
        vr_vldjuros := ROUND((pr_vlpagpar * vr_txdiaria * vr_qtdiamor),2);
        --
        -- Se possuir Juros de Mora para debitar
        IF vr_vldjuros > 0 THEN
          IF vr_floperac THEN
            vr_cdhistor := 2087; -- Financiamento
          ELSE
            vr_cdhistor := 2093; -- Emprestimo
          END IF;

          vr_vllanmto := 0;
          vr_vllanfut := 0;

          -- Cobrar valor integral
          IF vr_vlsldisp - vr_vldjuros >= 0 THEN
            vr_vllanmto := vr_vldjuros;
          -- Cobrar valor parcial
          ELSIF vr_vldjuros - vr_vlsldisp >= 0 AND vr_vlsldisp > 0 THEN
            vr_vllanmto := vr_vlsldisp;
            vr_vllanfut := vr_vldjuros - vr_vllanmto;
          ELSE
             vr_vllanfut := vr_vldjuros;
          END IF;
          
          -- Verifica se efetua o lancamento na conta
          IF vr_vllanmto > 0 THEN
            -- Criar o lancamento do Juros de Mora
            EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                          ,pr_cdagenci => pr_cdagenci         --> Codigo da agencia
                                          ,pr_cdbccxlt => 100                 --> Numero do caixa
                                          ,pr_cdoperad => vr_cdoperad         --> Codigo do Operador
                                          ,pr_cdpactra => pr_cdagenci         --> P.A. da transacao
                                          ,pr_nrdolote => vr_nrdolote         --> Numero do Lote
                                          ,pr_nrdconta => pr_nrdconta         --> Numero da conta
                                          ,pr_cdhistor => vr_cdhistor         --> Codigo historico
                                          ,pr_vllanmto => vr_vllanmto         --> Valor do Juros de Mora
                                          ,pr_nrparepr => pr_nrparcela        --> Numero parcelas emprestimo
                                          ,pr_nrctremp => pr_nrctremp         --> Numero do contrato de emprestimo
                                          ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela de erros
            -- Se ocorreu erro
            IF vr_des_reto <> 'OK' THEN
              -- Se possui algum erro na tabela de erros
              IF vr_tab_erro.COUNT() > 0 THEN
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar o lancamento do Juros de Mora.';
              END IF;
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => NULL
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc');
          END IF;

          -- Verifica se lanca na tela LAUTOM
          IF vr_vllanfut > 0 THEN
            -- Criar o registro para exibir na tela LAUTOM
            EMPR0009.pc_cria_lanc_futuro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdctitg => rw_crapass.nrdctitg
                                        ,pr_cdagenci => rw_crapass.cdagenci
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_cdhistor => vr_cdhistor
                                        ,pr_vllanaut => vr_vllanfut
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dscritic => vr_dscritic);
            -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
            GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                                  ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc');
            -- Se ocorreu erro
            IF vr_dscritic IS NOT NULL THEN
              vr_cdcritic := 0;
              RAISE vr_exc_erro;
            END IF;
          END IF;

          -- Diminuir a multa do saldo disponivel
          vr_vlsldisp := vr_vlsldisp - vr_vllanmto;

          -- Retorna os valores
          pr_cdhismor := vr_cdhistor;
          pr_vljumora := vr_vllanmto;

        END IF; -- vr_vldjuros > 0
        
      END IF;
      
      -- Procedure para gravar o log
      pc_gera_log(pr_cdcooper => pr_cdcooper
                 ,pr_nmdatela => pr_nmdatela
                 ,pr_nrdconta => pr_nrdconta
                 ,pr_cdoperad => pr_cdoperad
                 ,pr_dscritic => NULL
                 ,pr_idorigem => pr_idorigem
                 ,pr_nrdrowid => vr_nrdrowid
                 ,pr_dscriout => vr_dscriout);
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc'); 
      -- Se ocorreu erro
      IF vr_dscriout IS NOT NULL THEN
         vr_dscritic := vr_dscriout;
         RAISE vr_exc_erro;
      END IF;                        
		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Contrato',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nrctremp);
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc'); 

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Data de Pagamento',
																pr_dsdadant => TO_CHAR(rw_crapepr.dtdpagto,'DD/MM/RRRR'),
																pr_dsdadatu => TO_CHAR(vr_dtdpagto,'DD/MM/RRRR'));
      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc'); 

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Saldo Disponivel CC',
																pr_dsdadant => TO_CHAR(vr_vlsldis2,'fm999g999g999g990d00'),
																pr_dsdadatu => TO_CHAR(vr_vlsldisp,'fm999g999g999g990d00'));

      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc'); 

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Pago',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(pr_vlpagpar,'fm999g999g999g990d00'));

      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc'); 

      -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Multa',
																pr_dsdadant => '0',
																pr_dsdadatu => TO_CHAR(pr_vldmulta,'fm999g999g999g990d00'));

      -- Retorna nome do modulo logado - 22/09/2017 - Ch 758606
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela
                            ,pr_action => 'EMPR0009.pc_efetiva_pag_atraso_tr_prc'); 

		  -- Gera item do LOG
			GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Valor Juros Mora',
																pr_dsdadant => '0',
																pr_dsdadatu => TO_CHAR(pr_vljumora,'fm999g999g999g990d00'));

      -- Inicializa nome do modulo logado - 22/09/2017 - Ch 758606                                
      GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Grava informações para resolver erro de programa/ sistema - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => pr_cdcooper
                                       ,pr_dstiplog => 'E'
                                       ,pr_nmrotina => 'EMPR0009'
                                       ,pr_dscritic => 'pc_efetiva_pag_atraso_tr_prc' ||
                                                       ' - pr_nmdatela: ' || pr_nmdatela ||
                                                       ' - pr_nrdconta: ' || pr_nrdconta ||
                                                       ' - pr_cdoperad: ' || pr_cdoperad ||
                                                       ' - pr_idorigem: ' || pr_idorigem ||
                                                       ' - pr_dscritic: ' || pr_dscritic);

      WHEN vr_exc_saida THEN
        NULL;

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 22/09/2017 - Ch 758606 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela EMPR0009.pc_efetiva_pag_atraso_tr: ' || SQLERRM;
        -- Grava informações para resolver erro de programa/ sistema - 22/09/2017 - Ch 758606
        empr0009.pc_grava_erro_programa(pr_cdcooper => pr_cdcooper
                                       ,pr_dstiplog => 'E'
                                       ,pr_nmrotina => 'EMPR0009'
                                       ,pr_dscritic => 'pc_efetiva_pag_atraso_tr_prc' ||
                                                       ' - pr_nmdatela: ' || pr_nmdatela ||
                                                       ' - pr_nrdconta: ' || pr_nrdconta ||
                                                       ' - pr_cdoperad: ' || pr_cdoperad ||
                                                       ' - pr_idorigem: ' || pr_idorigem ||
                                                       ' - pr_dscritic: ' || pr_dscritic);
    END;

  END pc_efetiva_pag_atraso_tr_prc;  

  --> Grava informações para resolver erro de programa/ sistema
  PROCEDURE pc_grava_erro_programa(pr_cdcooper IN PLS_INTEGER           --> Cooperativa
                                  ,pr_dstiplog IN VARCHAR2              --> Tipo Log
                                  ,pr_nmrotina IN VARCHAR2              --> Nome da Rotina
                                  ,pr_dscritic IN VARCHAR2 DEFAULT NULL --> Descricao da critica
                                  )
  IS
  -----------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_erro_programa
  --  Sistema  : Rotina Conta-Corrente
  --  Sigla    : CRED
  --  Autor    : Cesar Belli - Envolti 
  --  Data     : Setembro/2017.                   Ultima atualizacao:22/09/2017
  --  Chamado  : 697089 758606.
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Rotina executada em qualquer frequencia.
  -- Objetivo  : Grava informações para resolver erro de programa/ sistema.
  --
  -- Alteracoes:  
  --             22/09/2017 - Ajustar padrão de Logs
  --                          Ajustar padrão de Exception Others
  --                          Inclui nome do modulo logado
  --                          ( Belli - Envolti - Chamados 697089 758606 )
  --             
  ------------------------------------------------------------------------------------------------------------   
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    vr_tpocorrencia       tbgen_prglog_ocorrencia.tpocorrencia%type;
    --
  BEGIN         
    IF pr_dstiplog IN ('O', 'I', 'F') THEN
      vr_tpocorrencia     := 4; 
    ELSE
      vr_tpocorrencia     := 2;       
    END IF;      
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdprograma    => pr_nmrotina, 
                           pr_cdcooper      => pr_cdcooper, 
                           pr_tpexecucao    => 2, --job
                           pr_tpocorrencia  => vr_tpocorrencia,
                           pr_cdcriticidade => 0, --baixa
                           pr_dsmensagem    => pr_dscritic,                             
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception;                                                             
  END pc_grava_erro_programa;
  
END EMPR0009;
/
