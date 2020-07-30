PL/SQL Developer Test script 3.0
660
-- Created on 24/07/2020 by F0032386 
declare 

  vr_dtlanct_estorno DATE := to_date('22/07/2020','DD/MM/RRRR');
  vr_cdcritic             NUMBER(3);
  vr_dscritic             VARCHAR2(1000);
  vr_excerro              EXCEPTION;
  
  vr_nmcooper             VARCHAR2(2000);
  vr_nrdconta             NUMBER;
  vr_nrctremp             NUMBER;
  vr_tipo                 VARCHAR2(2000);
  
  TYPE typ_linhas IS TABLE OF varchar2(4000)
  INDEX BY PLS_INTEGER;
  
  vr_tab_linha  typ_linhas;          
  vr_tab_campos gene0002.typ_split;
  
  CURSOR cr_acordo  (pr_cdcooper   NUMBER,
                     pr_nrdconta   NUMBER,
                     pr_nrctremp   NUMBER) IS
    SELECT a.nracordo,a.cdsituacao
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c
     WHERE a.nracordo = c.nracordo      
       AND a.cdcooper = pr_cdcooper
       AND a.nrdconta = pr_nrdconta
       AND c.nrctremp = pr_nrctremp;
  
  rw_acordo cr_acordo%ROWTYPE;
  
  CURSOR cr_crapepr_2(pr_nmrescop VARCHAR2,
                      pr_nrdconta NUMBER,
                      pr_nrctremp NUMBER) IS
    SELECT e.*,
           decode(e.tpemprst,0,'TR',1,'PP',2,'POS') idtipo  
      FROM crapepr e,
           crapcop c
     WHERE e.cdcooper = c.cdcooper
       AND c.nmrescop = pr_nmrescop
       AND e.inprejuz = 1
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp; 
  rw_crapepr_2 cr_crapepr_2%ROWTYPE;
  
 CURSOR cr_acordo_epr  (pr_nmrescop   VARCHAR2,
                       pr_nrdconta   NUMBER,
                       pr_nrctremp   NUMBER) IS
    SELECT a.nracordo,a.cdsituacao,ass.inprejuz,a.cdcooper,a.nrdconta
      FROM tbrecup_acordo a,
           tbrecup_acordo_contrato c,
           crapcop cop,
           crapass ass
     WHERE a.cdcooper = cop.cdcooper
       AND cop.nmrescop = pr_nmrescop
       AND a.nracordo = c.nracordo 
       AND a.cdcooper = ass.cdcooper
       AND a.nrdconta = ass.nrdconta     
       AND a.nrdconta = pr_nrdconta
       --AND c.nrctremp = pr_nrctremp
       AND a.cdsituacao = 1
       AND c.cdorigem = 3
       ORDER BY a.nracordo DESC;
  rw_acordo_2 cr_acordo_epr%ROWTYPE;
  
  CURSOR cr_craplem (pr_cdcooper NUMBER,
                     pr_nrdconta NUMBER,
                     pr_nrctremp NUMBER,
                     pr_dtmvtolt DATE) IS
    SELECT l.*
      FROM craplem l
     WHERE l.cdcooper = pr_cdcooper
       AND l.dtmvtolt >= pr_dtmvtolt
       AND l.cdhistor = 2702
       AND l.nrdconta = pr_nrdconta
       AND l.nrctremp = pr_nrctremp; 
  rw_craplem cr_craplem%ROWTYPE;
  
  
  CURSOR cr_crapepr IS
    SELECT e.*,
           decode(e.tpemprst,0,'TR',1,'PP',2,'POS') idtipo  
      FROM crapepr e
     WHERE e.cdcooper = 1
       AND e.inprejuz = 1
       AND e.nrdconta = 2444810
       AND e.nrctremp = 95215; 

--  re_crapepr cr_crapepr%ROWTYPE;

  PROCEDURE pc_estorno_pagamento_b (pr_cdcooper IN NUMBER
                                   ,pr_nrdconta   IN NUMBER  -- Conta corrente
                                   ,pr_nrctremp IN NUMBER  -- contrato
                                   ,pr_dtmvtolt IN DATE
                                   ,pr_idtipo   IN varchar2
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   )IS

     /* .............................................................................

      Programa: pc_estorno_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Calão - Mout´S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o estorno de transferencias de contratos PP e TR para prejuízo
      Observacao: Rotina chamada pela tela Atenda / Prestações, botão "Desfazer Prejuízo"
                  Também é chamada pela tela ESTPRJ (Estorno de prejuízos).

      Alteracoes:

     ..............................................................................*/
     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_inprejuz    integer;

     -- Excessões
     vr_exc_erro         EXCEPTION;
     vr_des_reto             VARCHAR2(10);
     vr_tab_erro             gene0001.typ_tab_erro ;
     vr_cdcritic             NUMBER(3);
     vr_dscritic             VARCHAR2(1000);
  
     
     rw_crapdat              btch0001.cr_crapdat%rowtype;

  CURSOR cr_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT *
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;

     cursor c_busca_abono is
        select 1
        from   craplem lem
        where  lem.cdcooper = vr_cdcooper
        and    lem.nrdconta = pr_nrdconta
        and    lem.nrctremp = pr_nrctremp
        and    lem.dtmvtolt > rw_crapdat.dtultdma
        and    lem.dtmvtolt <= rw_crapdat.dtultdia
        and    lem.cdhistor = 2391
        and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.nrparepr = lem.nrdocmto
                             and t.cdhistor = 2395); -- abono


        vr_existe_abono integer := 0;

  BEGIN

    vr_cdcooper  := pr_cdcooper;  
    vr_nmdatela  := 'ESTPRJ';
    vr_cdagenci  := 1;
    vr_nrdcaixa  := 100;
    vr_idorigem  := 7;
    vr_cdoperad  := 1;
  
  
    open cr_crapope;
    fetch cr_crapope into vr_cddepart;
    close cr_crapope;

    /* Busca data de movimento */
    open btch0001.cr_crapdat(vr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    close btch0001.cr_crapdat;

    /*Busca informações do emprestimo */
    open cr_crapepr(pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta
                     , pr_nrctremp => pr_nrctremp);

    fetch cr_crapepr into rw_crapepr;
    if cr_crapepr%found then
       vr_inprejuz := rw_crapepr.inprejuz;
    end if;
    close cr_crapepr;

    if to_char(pr_dtmvtolt,'yyyymm') < to_char(rw_crapdat.dtmvtolt,'yyyymm') then
       pr_dscritic := 'Impossivel fazer estorno do contrato, pois este pagamento/abono foi feito antes do mes vigente';
       raise vr_exc_erro;
    end if;

    /* Verifica se possui abono ativo, não pode efetuar o estorno do pagamento */
    open c_busca_abono;
    fetch c_busca_abono into vr_existe_abono;
    close c_busca_abono;

    if nvl(vr_existe_abono,0) = 1 then
       if pr_idtipo not in ('PA','TA','CA') then
         pr_dscritic := 'Não é permitido efetuar o estorno do pagamento pois existe um lançamento de abono.';
         raise vr_exc_erro;
       end if;
    end if;

    /* Gerando Log de Consulta */
    vr_dstransa := 'PREJ0002-Efetuando estorno da transferencia para prejuizo, Cooper: ' || vr_cdcooper ||
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || rw_crapepr.tpemprst || ', Data: ' || pr_dtmvtolt || ', indicador: ' || pr_idtipo ;


    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => 'INTRANET'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
    if nvl(vr_inprejuz,2) = 1 then
      PREJ0002.pc_estorno_pagamento(pr_cdcooper => vr_cdcooper
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          pr_dscritic := 'Não foi possivel executar estorno do Pagamento do Prejuízo.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
    ELSE
       pr_dscritic := 'Contrato não está em prejuízo !';
       raise vr_exc_erro;
    END IF;

    vr_dstransa := 'PREJ0002-Estorno da transferência para prejuizo, referente contrato: ' || pr_nrctremp ||', realizada com sucesso.';
    -- Gerando Log de Consulta
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      if pr_dscritic is null then
         pr_dscritic := 'Erro na rotina pc_estorno_prejuizo: ';
      end if;
      pr_dscritic := pr_dscritic;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0002-Estorno transferencia para prejuizo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      pr_dscritic := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
      pr_dscritic := pr_dscritic;
      pr_cdcritic := 0;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'PREJ0002-Estorno da Transferência Prejuízo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
  END pc_estorno_pagamento_b;
  
   --> Rotina responsavel por cancelar acordo
  PROCEDURE pc_desbloq_valor_acordo (pr_nracordo    IN  NUMBER,       --> Numero do acordo                                             
                                     pr_cdcritic   OUT  NUMBER,       --> Código da Crítica
                                     pr_dscritic   OUT VARCHAR2,      --> Descrição da Crítica
                                     pr_dsdetcri   OUT VARCHAR2)  IS  --> Detalhe da critica
                                     
    
    ---------------> CURSORES <-------------
    rw_crapdat    BTCH0001.cr_crapdat%ROWTYPE; 
    
    --> Buscar situacao do acordo
    CURSOR cr_tbacordo IS
       SELECT aco.cdsituacao,
              aco.cdcooper,
              aco.nrdconta,
              aco.nracordo,
              aco.vlbloqueado
        FROM tbrecup_acordo aco
       WHERE nracordo = pr_nracordo;
    rw_tbacordo cr_tbacordo%ROWTYPE;  
    
		--> Buscar informações de IOF vinculado ao contrato (ADP)
		CURSOR cr_contrato IS
		   SELECT ctr.vliofdev
			      , ctr.vliofpag
			   FROM tbrecup_acordo_contrato ctr
				WHERE ctr.nracordo = pr_nracordo
				  AND cdorigem = 1;
		rw_contrato cr_contrato%ROWTYPE;
    
    --> Buscar cooperado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    ---------------> VARIAVEIS <------------
    -- Tratamento de erros
    vr_dscritic     VARCHAR2(10000);
    vr_cdcritic     INTEGER;    
    vr_exc_erro     EXCEPTION;
    vr_exc_erro_det EXCEPTION;
    vr_dsparame     VARCHAR2(4000);

       
    -- Pl/Table utilizada na procedure de baixa
    vr_tab_lat_consolidada     paga0001.typ_tab_lat_consolidada;      
    
    vr_des_reto     VARCHAR2(10);
    vr_tab_erro    gene0001.typ_tab_erro;
    
  BEGIN
    -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
   
    vr_dsparame := ' - pr_nracordo:'||pr_nracordo;
    
    --> Buscar situacao do acordo
    OPEN cr_tbacordo;
    FETCH cr_tbacordo INTO rw_tbacordo;
    IF cr_tbacordo%NOTFOUND THEN
      CLOSE cr_tbacordo;
      -- Retornar critica que o acordo não foi encontrado.
      vr_cdcritic := 1205;
      RAISE vr_exc_erro; 
    END IF;
    CLOSE cr_tbacordo;
    
    IF rw_tbacordo.cdsituacao = 2 THEN
       -- Retornar critica que o acordo esta quitado.
      vr_cdcritic := 986;
      RAISE vr_exc_erro;
    ELSIF rw_tbacordo.cdsituacao = 3 THEN
       -- Retornar critica que o acordo esta cancelado.
       vr_cdcritic := 984;
      RAISE vr_exc_erro;
    END IF;
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_tbacordo.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN      
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(1); --'Sistema sem data de movimento, tente novamente mais tarde';
      RAISE vr_exc_erro;
    ELSE
      CLOSE btch0001.cr_crapdat;
    END IF;
        
    IF nvl(rw_crapdat.inproces,0) <> 1 THEN
      vr_dscritic := gene0001.fn_busca_critica(1206); --'Processo da Cooperativa nao finalizou, tente novamente mais tarde';
      RAISE vr_exc_erro;
    END IF;
    
    -- Condicao para verificar se possui valor de acordo
    IF rw_tbacordo.vlbloqueado > 0 THEN

      OPEN cr_crapass(pr_cdcooper => rw_tbacordo.cdcooper
                     ,pr_nrdconta => rw_tbacordo.nrdconta);   

      FETCH cr_crapass INTO rw_crapass;               

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
    
      EMPR0001.pc_cria_lancamento_cc(pr_cdcooper => rw_crapass.cdcooper             --> Cooperativa conectada
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt     --> Movimento atual
                                    ,pr_cdagenci => rw_crapass.cdagenci     --> Código da agência
                                    ,pr_cdbccxlt => 100                     --> Número do caixa
                                    ,pr_cdoperad => '1'                     --> Código do Operador
                                    ,pr_cdpactra => rw_crapass.cdagenci     --> P.A. da transação
                                    ,pr_nrdolote => 650001                  --> Numero do Lote
                                    ,pr_nrdconta => rw_crapass.nrdconta             --> Número da conta
                                    ,pr_cdhistor => 2194                    --> Codigo historico 2194 - CR.DESB.ACORD
                                    ,pr_vllanmto => rw_tbacordo.vlbloqueado --> Valor da parcela emprestimo
                                    ,pr_nrparepr => 0                       --> Número parcelas empréstimo
                                    ,pr_nrctremp => 0                       --> Número do contrato de empréstimo
                                    ,pr_des_reto => vr_des_reto             --> Retorno OK / NOK
                                    ,pr_tab_erro => vr_tab_erro);           --> Tabela com possíves erros
      --Se Retornou erro
      IF vr_des_reto <> 'OK' THEN
        -- Se possui algum erro na tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- Atribui críticas às variaveis
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := gene0001.fn_busca_critica(1505); --'Erro ao criar o lancamento de desbloqueio de acordo';
        END IF;
        RAISE vr_exc_erro;
      END IF;

      -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'RECP0002.pc_cancelar_acordo');
    END IF;
    
    BEGIN
      -- Alterar a situação do acordo para cancelado
      UPDATE tbrecup_acordo SET
             vlbloqueado = 0 --> Zerar valor bloqueado que foi liberado 
       WHERE nracordo = rw_tbacordo.nracordo;
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception (pr_cdcooper => rw_tbacordo.cdcooper);

        --Erro ao atualizar acordo
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'tbrecup_acordo:'||
                        ' cdsituacao:'||'3'||
                        ' com nracordo:'||rw_tbacordo.nracordo||
                        '. '||sqlerrm;

        RAISE vr_exc_erro_det;   
    END;     
    -- Inclui nome do modulo logado - 15/08/2019 - PRB0041875
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL);
      
  EXCEPTION
    WHEN vr_exc_erro_det THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
      END IF;
      
      --> Apenas critica generica e detalhe critica em outro parametro        
      pr_cdcritic := 994;  --Nao foi possivel cancelar acordo.
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      pr_dsdetcri := vr_dscritic;

      

    WHEN vr_exc_erro THEN
      --> Buscar descrição critica
      IF nvl(vr_cdcritic,0) > 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
         
      ELSIF nvl(vr_cdcritic,0) = 0 AND vr_dscritic IS NULL THEN--Aqui não gravaria nada nas variáveis - ???
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
        pr_dsdetcri := vr_dscritic;
      END IF;
      
      IF NVL(vr_cdcritic,0) = 0 THEN
        vr_cdcritic := 994;  --Nao foi possivel cancelar acordo.
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_dsdetcri := nvl(pr_dsdetcri,vr_dscritic);
      
      
      
    WHEN OTHERS THEN
      pr_cdcritic := 994;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic); 
      pr_dsdetcri := SQLERRM; 

      CECRED.pc_internal_exception (pr_cdcooper => 3);

            
  END pc_desbloq_valor_acordo;
  

BEGIN
  vr_tab_linha(vr_tab_linha.count) := 'VIACREDI;7230770;527707;;baca;360;Sai dinheiro da transitoria e recuperou prejuízo de cc';
  vr_tab_linha(vr_tab_linha.count) := 'CREVISC;122319;122319;;Desbloqueio;360;Sai dinheiro da transitoria e recuperou prejuízo de cc';

FOR i IN vr_tab_linha.first..vr_tab_linha.count-1 LOOP
  
  vr_tab_campos := gene0002.fn_quebra_string(pr_string => vr_tab_linha(i), 
                                             pr_delimit => ';');
                                             
                            
  vr_nmcooper := vr_tab_campos(1);
  vr_nrdconta := vr_tab_campos(2);
  vr_nrctremp := vr_tab_campos(3);
  vr_tipo     := vr_tab_campos(5);
  
  IF upper(vr_tipo) = 'BACA' THEN
    OPEN cr_crapepr_2(pr_nmrescop => vr_nmcooper,
                      pr_nrdconta => vr_nrdconta,
                      pr_nrctremp => vr_nrctremp);
    FETCH cr_crapepr_2 INTO rw_crapepr_2;                    
    IF cr_crapepr_2%NOTFOUND THEN
      dbms_output.put_line('NAO ENCONTRADO -->'||vr_tab_linha(i));  
      CLOSE cr_crapepr_2;
      continue;
    ELSE      
      dbms_output.put_line(vr_tab_linha(i));   
      CLOSE cr_crapepr_2;
      
      IF rw_crapepr_2.vlsdprej <= 0 THEN
        dbms_output.put_line('Saldo Prejuizo zerado -->'||vr_tab_linha(i));  
        continue; 
      END IF;  
      
      OPEN cr_craplem (pr_cdcooper => rw_crapepr_2.cdcooper,
                       pr_nrdconta => rw_crapepr_2.nrdconta,
                       pr_nrctremp => rw_crapepr_2.nrctremp,
                       pr_dtmvtolt => vr_dtlanct_estorno);
      FETCH cr_craplem INTO rw_craplem;
      IF cr_craplem%FOUND THEN
        CLOSE cr_craplem;
        dbms_output.put_line('Ja estornado -->'||vr_tab_linha(i));  
        continue; 
      ELSE
        CLOSE cr_craplem;
      END IF;  
    END IF;
    
    rw_acordo := NULL;
    OPEN cr_acordo  (pr_cdcooper   => rw_crapepr_2.cdcooper,
                     pr_nrdconta   => rw_crapepr_2.nrdconta,
                     pr_nrctremp   => rw_crapepr_2.nrctremp);
    FETCH cr_acordo INTO rw_acordo;
    CLOSE cr_acordo;
    /*
    BEGIN
      UPDATE tbrecup_acordo a  
         SET a.cdsituacao = 3 -- mudar para cancelado temporariamente
       WHERE a.nracordo = rw_acordo.nracordo;  
    END;
        
    pc_estorno_pagamento_b (pr_cdcooper => rw_crapepr_2.cdcooper
                           ,pr_nrdconta => rw_crapepr_2.nrdconta
                           ,pr_nrctremp => rw_crapepr_2.nrctremp
                           ,pr_dtmvtolt => vr_dtlanct_estorno
                           ,pr_idtipo   => rw_crapepr_2.idtipo  
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                                     );

    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_excerro;
    END IF; 
    
     BEGIN
      UPDATE tbrecup_acordo a  
         SET a.cdsituacao = rw_acordo.cdsituacao -- voltar para o valor original
       WHERE a.nracordo = rw_acordo.nracordo;  
    END;*/
  
  ELSIF upper(vr_tipo) = 'DESBLOQUEIO' THEN
      dbms_output.put_line(vr_tab_linha(i));  
      OPEN cr_acordo_epr ( pr_nmrescop  => vr_nmcooper,
                         pr_nrdconta  => vr_nrdconta,
                         pr_nrctremp  => vr_nrctremp);
      FETCH cr_acordo_epr INTO rw_acordo_2;
      
      IF cr_acordo_epr%NOTFOUND THEN
        CLOSE cr_acordo_epr; 
        dbms_output.put_line('  --> NAO ENCONTRADO');  
        continue;
      ELSE
        CLOSE cr_acordo_epr;
        IF rw_acordo_2.cdsituacao <> 1 THEN
          dbms_output.put_line('  --> ACORDO NAO ESTA ATIVO');      
        END IF;      
      
      END IF;   
    /*
      pc_desbloq_valor_acordo (pr_nracordo   => rw_acordo_2.nracordo, --> Numero do acordo                                             
                               pr_cdcritic   => vr_cdcritic,           --> Código da Crítica
                               pr_dscritic   => vr_dscritic,           --> Descrição da Crítica
                               pr_dsdetcri   => vr_dsdetcri );         --> Detalhe da critica 
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_excerro;
      END IF; */
      
  END IF;
      
  
END LOOP;
  COMMIT;
  
  
EXCEPTION
   WHEN vr_excerro THEN    
     ROLLBACK; 
     raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic);
end;
0
6
pr_dtmvtolt
rw_crapdat.dtmvtolt
pr_nrdconta
r_craplem.nrdocmto
pr_nrctremp
pr_nrdolote
