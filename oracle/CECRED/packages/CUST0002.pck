CREATE OR REPLACE PACKAGE CECRED.CUST0002 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : CUST0002
--  Sistema  : Rotinas genericas focando nas funcionalidades da custodia de cheque
--             no InternetBank
--  Sigla    : CUST
--  Autor    : Lombardi
--  Data     : Setembro/2016.                   Ultima atualizacao: --/--/----
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
--
-- Alteracoes: 
--             30/10/2018 - SCTASK0033039 - Alteração do periodo da custodia de cheques de 3 para 5 anos -- Jefferson Gubetti - Mouts
---------------------------------------------------------------------------------------------------------------
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_lista_remessa_custodia(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_dtmvtini  IN crapdat.dtmvtolt%TYPE --> Data inicial do periodo
                                     ,pr_dtmvtfin  IN crapdat.dtmvtolt%TYPE --> Data final do periodo
                                     ,pr_insithcc  IN craphcc.insithcc%TYPE --> Indicador de situacao (1=Pendente , 2=Processado).
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_lista_detalhe_custodia(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrconven  IN crapdcc.nrconven%TYPE --> Nr do convenio
                                     ,pr_nrremret  IN crapdcc.nrremret%TYPE --> Data final do periodo
                                     ,pr_nriniseq  IN INTEGER               --> Paginação - Inicio de sequencia
                                     ,pr_nrregist  IN INTEGER               --> Paginação - Número de registros
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_excluir_cheque_remessa(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrconven  IN crapdcc.nrconven%TYPE --> Nr do convenio
                                     ,pr_intipmvt  IN crapdcc.intipmvt%TYPE --> 
                                     ,pr_nrremret  IN crapdcc.nrremret%TYPE --> 
                                     ,pr_nrseqarq  IN crapdcc.nrseqarq%TYPE --> 
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_excluir_remessa(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                              ,pr_nrconven  IN crapdcc.nrconven%TYPE --> Nr do convenio
                              ,pr_intipmvt  IN crapdcc.intipmvt%TYPE --> 
                              ,pr_nrremret  IN crapdcc.nrremret%TYPE --> 
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Validar os cheques para a custódia
  PROCEDURE pc_valida_custodia(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                              ,pr_dtlibera  IN VARCHAR2              --> Lista Data Boa
                              ,pr_dtdcaptu  IN VARCHAR2              --> Lista Data Emissao
                              ,pr_vlcheque  IN VARCHAR2              --> Lista Valor Cheque
                              ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  

  -- Validar os cheques para a custódia
  PROCEDURE pc_cadastra_emitentes(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
  -- Cadastrar custodia e emitentes
  PROCEDURE pc_custodia_cheque(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                              ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Número do Titular
                              ,pr_dtlibera  IN VARCHAR2              --> Lista Data Boa
                              ,pr_dtdcaptu  IN VARCHAR2              --> Lista Data Emissao
                              ,pr_vlcheque  IN VARCHAR2              --> Lista Valor Cheque
                              ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   OUT CLOB);                --> Arquivo de retorno do XML
  
END CUST0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CUST0002 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : CUST0002
--  Sistema  : Rotinas genericas focando nas funcionalidades da custodia de cheque 
--             no InternetBank.
--  Sigla    : CUST
--  Autor    : Lombardi
--  Data     : Setembro/2016.                   Ultima atualizacao: --/--/----
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle
--
-- Alteracoes: 
---------------------------------------------------------------------------------------------------------------
  
  -- Validação do Cheque para saber se ele pode ser custodiado
  PROCEDURE pc_valida_cheque_ib(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                               ,pr_dsdocmc7  IN crapdcc.dsdocmc7%TYPE --> CMC-7 do Cheque
                               ,pr_cdbanchq  IN NUMBER                --> Banco do Cheque
                               ,pr_cdagechq  IN NUMBER                --> Agência do Cheque
                               ,pr_cdcmpchq  IN NUMBER                --> COMPE do Cheque
                               ,pr_nrctachq  IN NUMBER                --> Conta do Cheque
                               ,pr_nrcheque  IN NUMBER                --> Número do Cheque
                               ,pr_dtlibera  IN DATE                  --> Data de Liberação do Cheque
                               ,pr_vlcheque  IN NUMBER                --> Valor do Cheque
                               ,pr_dtmvtolt  IN DATE                  --> Data de Movimentação
                               ,pr_dtdcaptu  IN DATE DEFAULT NULL     --> Data de emissão
                               ,pr_inchqcop OUT NUMBER                --> Tipo de cheque recebido (0=Outros bancos, 1=Cooperativa)
                               ,pr_cdtipmvt OUT wt_custod_arq.cdtipmvt%TYPE --> Codigo do Tipo de Movimento
                               ,pr_cdocorre OUT wt_custod_arq.cdocorre%TYPE --> Codigo da Ocorrencia
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de erros

  BEGIN
    /* .............................................................................
    Programa: pc_valida_cheque_simples
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 24/10/2016                        Ultima atualizacao: 03/01/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para realizar as validação do CMC-7 do cheque
               (Validação mais simples para o IB).
               
    Alteracoes: 03/01/2019 - Nova regra para bloquear bancos. (Andrey Formigari - #SCTASK0035990)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;

      vr_nrdcampo NUMBER;
      vr_lsdigctr VARCHAR2(2000);
      vr_nrdconta_ver_cheque NUMBER;
      vr_dsdaviso VARCHAR2(4000);

      vr_dtminimo DATE;
      vr_qtddmini NUMBER;
      vr_prazo_custod NUMBER;
	  vr_cdbancos crapprm.dsvlrprm%TYPE;

      -- Identifica o ultimo dia Util do ANO
      vr_dtultdia DATE;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      --CURSOR
      -- Seleciona Dados Folha de Cheque
      CURSOR cr_crapfdc (pr_cdcooper IN crapfdc.cdcooper%TYPE
                        ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                        ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                        ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                        ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
        SELECT crapfdc.tpcheque
          FROM crapfdc crapfdc
         WHERE crapfdc.cdcooper = pr_cdcooper 
           AND crapfdc.cdbanchq = pr_cdbanchq 
           AND crapfdc.cdagechq = pr_cdagechq 
           AND crapfdc.nrctachq = pr_nrctachq 
           AND crapfdc.nrcheque = pr_nrcheque;
      rw_crapfdc cr_crapfdc%ROWTYPE;

      -- Seleciona Dados Custodia em todas as cooperativas
      CURSOR cr_crapcst (pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcst.cdagechq%TYPE
                        ,pr_nrctachq IN crapcst.nrctachq%TYPE
                        ,pr_nrcheque IN crapcst.nrcheque%TYPE) IS
        -- Validar se o cheque está custodiado utilizando os campos do indice CRAPCST##CRAPCST5
        SELECT crapcst.nrcheque
          FROM crapcst crapcst
         WHERE crapcst.cdcmpchq = pr_cdcmpchq 
           AND crapcst.cdbanchq = pr_cdbanchq 
           AND crapcst.cdagechq = pr_cdagechq 
           AND crapcst.nrctachq = pr_nrctachq 
           AND crapcst.nrcheque = pr_nrcheque 
           AND crapcst.dtdevolu IS NULL;
      rw_crapcst cr_crapcst%ROWTYPE;
      
      -- Selecionar dados Desconto
      CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE
                        ,pr_cdcmpchq IN crapcdb.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcdb.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcdb.cdagechq%TYPE
                        ,pr_nrctachq IN crapcdb.nrctachq%TYPE
                        ,pr_nrcheque IN crapcdb.nrcheque%TYPE
                        ,pr_dtmvtolt IN crapcdb.dtlibera%TYPE) IS
        SELECT crapcdb.nrcheque
          FROM crapcdb crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper 
           AND crapcdb.cdcmpchq = pr_cdcmpchq
           AND crapcdb.cdbanchq = pr_cdbanchq 
           AND crapcdb.cdagechq = pr_cdagechq 
           AND crapcdb.nrctachq = pr_nrctachq 
           AND crapcdb.nrcheque = pr_nrcheque 
           AND crapcdb.dtdevolu IS NULL
           AND crapcdb.dtlibbdc IS NOT NULL
           AND crapcdb.dtlibera >= pr_dtmvtolt     
           AND (crapcdb.insitchq = 0
             OR crapcdb.insitchq = 2);
      rw_crapcdb cr_crapcdb%ROWTYPE;

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      --Selecionar feriados
      CURSOR cr_crapfer (pr_cdcooper IN crapfer.cdcooper%TYPE
                        ,pr_dtferiad IN crapfer.dtferiad%TYPE) IS
        SELECT crapfer.dtferiad
        FROM crapfer
        WHERE crapfer.cdcooper = pr_cdcooper
        AND   crapfer.dtferiad = pr_dtferiad;
      rw_crapfer cr_crapfer%ROWTYPE;
      
    BEGIN
      vr_dsdaviso := NULL;
      
      -- Validar Digito CMC7
      CHEQ0001.pc_dig_cmc7(pr_dsdocmc7 => pr_dsdocmc7,
                           pr_nrdcampo => vr_nrdcampo,
                           pr_lsdigctr => vr_lsdigctr);
       
      -- Se o vr_nrdcampo > 0, então cheque com Dígito Inválido
      IF vr_nrdcampo > 0 THEN
        -- (21,08) CMC7/Linha1 Inválida
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'08');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
      -- Validacao generica de Banco e Agencia
      IF pr_cdbanchq = 0 OR pr_cdbanchq = 999 THEN
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'01');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
	  /* Bancos que não podemos mais aceitar o recebimento de cheques. */
      vr_cdbancos := gene0001.fn_param_sistema('CRED',0,'BANCOS_BLQ_CHQ');
      
      -- Validação de bancos que está na LANCSTI.p
      /* Não permitir a inclusão de cheques para os bancos 012, 231, 353, 356, 409, 479 e 399 */
      IF INSTR(','||vr_cdbancos||',',','||pr_cdbanchq||',') > 0 THEN
        -- (21,01) Banco Invalido 
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'01');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
      CCAF0001.pc_valida_banco_agencia (pr_cdbanchq => pr_cdbanchq   --Codigo Banco cheque
                                       ,pr_cdagechq => pr_cdagechq   --Codigo Agencia cheque
                                       ,pr_cdcritic => vr_cdcritic   --Codigo erro
                                       ,pr_dscritic => vr_dscritic   --Descricao erro
                                       ,pr_tab_erro => pr_tab_erro); --Tabela de erros;
      -- Se ocorreu erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        IF substr(vr_dscritic,1,3) = '057' THEN
          -- (21,01) Banco Invalido 
          pr_cdtipmvt := nvl(pr_cdtipmvt,21);
          pr_cdocorre := nvl(pr_cdocorre,'01');
        ELSE
          -- (21,16) Agencia Invalido 
          pr_cdtipmvt := nvl(pr_cdtipmvt,21);
          pr_cdocorre := nvl(pr_cdocorre,'16');  
        END IF;
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
      -- Verificar se o cheque está no prazo mínimo de custódia 
      vr_dtminimo := pr_dtmvtolt;
      vr_qtddmini := 0;
        
      LOOP
        vr_dtminimo := vr_dtminimo + 1;
             
        -- Verifica se é Sabado ou Domingo
        IF to_char(vr_dtminimo,'D') = '1' OR to_char(vr_dtminimo,'D') = '7' THEN
          CONTINUE;             
        END IF;
             
        -- Abre Cursor
        OPEN cr_crapfer(pr_cdcooper => pr_cdcooper 
                       ,pr_dtferiad => vr_dtminimo);
        --Posicionar no proximo registro
        FETCH cr_crapfer INTO rw_crapfer;
             
        --Se nao encontrar
        IF cr_crapfer%FOUND THEN
          -- Fecha Cursor
          CLOSE cr_crapfer;
          CONTINUE;
        ELSE
          -- Fecha Cursor
          CLOSE cr_crapfer;    
        END IF;       
             
        vr_qtddmini := vr_qtddmini + 1;      

        EXIT WHEN vr_qtddmini = 2;
      END LOOP;

      -- Busca prazo máximo da custódia
      vr_prazo_custod := gene0001.fn_param_sistema('CRED',0,'PRAZO_CUSTODIA_CHEQUES');

      -- Se o cheque não estiver no prazo mínimo ou no 
      -- prazo máximo (vr_prazo_custod)
      IF   pr_dtlibera <= vr_dtminimo OR
           pr_dtlibera > (pr_dtmvtolt + vr_prazo_custod)   THEN
        -- Data para Deposito invalida
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'12');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
        
      -- Se data de emissão for maior que data atual
      IF pr_dtdcaptu > pr_dtmvtolt THEN
        -- Data da captura no cliente inválida
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'13');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;            
      END IF;
      
      -- Buscar o ultimo dia do ANO
      vr_dtultdia:= add_months(TRUNC(pr_dtlibera,'RRRR'),12)-1;
      -- Atualizar para o ultimo dia util do ANO, considerando 31/12
      vr_dtultdia:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtolt => vr_dtultdia
                                               ,pr_tipo => 'A' -- Dia Anterior
                                               ,pr_feriado => TRUE -- Validar Feriados
                                               ,pr_excultdia => TRUE); -- Considerar o dia 31/12
      
      -- Nao permitir que as custodias de cheques tenham data de liberacao no ultimo dia util do ano
      IF pr_dtlibera = vr_dtultdia THEN
        -- Data para Deposito invalida
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'12');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Numero da conta do cheque 
      IF pr_cdbanchq = 085 AND pr_cdagechq = rw_crapcop.cdagectl THEN
                
        OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper
                       ,pr_cdbanchq => pr_cdbanchq
                       ,pr_cdagechq => pr_cdagechq
                       ,pr_nrctachq => pr_nrctachq
                       ,pr_nrcheque => pr_nrcheque);
        FETCH cr_crapfdc
          INTO rw_crapfdc;
                
        -- Se não Encontrar Registro
        IF cr_crapfdc%FOUND THEN
          -- Fechar o cursor
          CLOSE cr_crapfdc;   
          IF rw_crapfdc.tpcheque = 2 THEN
            -- (21,17) Conta do Cheque Invalida
            pr_cdtipmvt := nvl(pr_cdtipmvt,21);
            pr_cdocorre := nvl(pr_cdocorre,'17'); 
            -- Se possui critica de Tipo de Movimentação e Ocorrencia
            -- Executa RAISE para sair das validações
            RAISE vr_exc_saida;
          END IF;  
        ELSE
          -- Fechar o cursor
          CLOSE cr_crapfdc;
          -- (21,17) Conta do Cheque Invalida
          pr_cdtipmvt := nvl(pr_cdtipmvt,21);
          pr_cdocorre := nvl(pr_cdocorre,'17');
          -- Se possui critica de Tipo de Movimentação e Ocorrencia
          -- Executa RAISE para sair das validações
          RAISE vr_exc_saida;
        END IF;             
      END IF;
            
      -- Verificar se Cheque já Custodiado
      OPEN cr_crapcst(pr_cdcmpchq => pr_cdcmpchq
                     ,pr_cdbanchq => pr_cdbanchq
                     ,pr_cdagechq => pr_cdagechq
                     ,pr_nrctachq => pr_nrctachq
                     ,pr_nrcheque => pr_nrcheque);
      FETCH cr_crapcst INTO rw_crapcst;
             
      -- Se encontrar cheque já custodiado
      IF cr_crapcst%FOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcst;  
        -- (21,80) Cheque já Custodiado
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'80');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;  
             
      -- Fechar o cursor
      CLOSE cr_crapcst;  
                                      
      -- Verificar se Cheque já Descontado
      OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper
                     ,pr_cdcmpchq => pr_cdcmpchq
                     ,pr_cdbanchq => pr_cdbanchq
                     ,pr_cdagechq => pr_cdagechq
                     ,pr_nrctachq => pr_nrctachq
                     ,pr_nrcheque => pr_nrcheque
                     ,pr_dtmvtolt => pr_dtmvtolt);
      FETCH cr_crapcdb INTO rw_crapcdb;
             
      -- Se encontrar registro
      IF cr_crapcdb%FOUND THEN
        -- Fechar o cursor
        CLOSE cr_crapcdb;  
        -- (21,83) Cheque já Descontado
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        pr_cdocorre := nvl(pr_cdocorre,'83');
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
              
      -- Fechar o cursor
      CLOSE cr_crapcdb;  
                          
      -- Verificar Cheque
      CUST0001.pc_ver_cheque(pr_cdcooper => pr_cdcooper 
                            ,pr_nrcustod => pr_nrdconta
                            ,pr_cdbanchq => pr_cdbanchq
                            ,pr_cdagechq => pr_cdagechq
                            ,pr_nrctachq => pr_nrctachq
                            ,pr_nrcheque => pr_nrcheque
                            ,pr_nrddigc3 => 1
                            ,pr_vlcheque => pr_vlcheque
                            ,pr_nrdconta => vr_nrdconta_ver_cheque
                            ,pr_dsdaviso => vr_dsdaviso
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
      
      IF vr_nrdconta_ver_cheque > 0 THEN
        pr_inchqcop := 1; -- Cheque de Cooperado da Cooperativa
      ELSE
        pr_inchqcop := 0; -- Cheque de Terceiro
      END IF;
               
      IF NVL(vr_cdcritic,0) > 0 THEN
        pr_cdocorre := CUST0001.fn_ocorrencia_cnab(pr_cdocorre => vr_cdcritic);
        -- Recusa Inclusao
        pr_cdtipmvt := nvl(pr_cdtipmvt,21);
        vr_cdcritic := 0;
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Não existe crítica, apenas para a execução das validações
        NULL;

      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'Erro geral em pc_validar_cheque: ' || SQLERRM;
    END;
  END pc_valida_cheque_ib;
  
  PROCEDURE pc_valida_custodia_ib(pr_cdcooper       IN crapass.cdcooper%TYPE        --> Cooperativa
                                 ,pr_nrdconta       IN crapass.nrdconta%TYPE        --> Número da conta
                                 ,pr_dtlibera       IN VARCHAR2                     --> Lista Data Boa 
                                 ,pr_dtdcaptu       IN VARCHAR2                     --> Lista Data Emissao 
                                 ,pr_vlcheque       IN VARCHAR2                     --> Lista Valor Cheque 
                                 ,pr_dsdocmc7       IN VARCHAR2                     --> Lista CMC7 
                                 ,pr_tab_cust_cheq OUT CUST0001.typ_cheque_custodia --> Tabela com cheques para custódia
                                 ,pr_tab_erro_cust OUT CUST0001.typ_erro_custodia   --> Tabela de cheques com erros
                                 ,pr_cdcritic      OUT PLS_INTEGER                  --> Código da crítica
                                 ,pr_dscritic      OUT VARCHAR2) IS                 --> Descrição da crítica

  BEGIN
    /* .............................................................................
    Programa: pc_valida_custodia_simples
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 27/10/2016                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar os cheques para a custódia
                (Validação mais simples para o IB).
    Alteracoes: 
    ............................................................................. */
    DECLARE
      -- Tratamento de erros
      vr_exc_erro  EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_erro_custodia VARCHAR2(4000);
      
      -- Variáveis auxiliares
      vr_cdtipmvt wt_custod_arq.cdtipmvt%TYPE;
      vr_cdocorre wt_custod_arq.cdocorre%TYPE;
      vr_auxcont  INTEGER := 0;
      vr_inchqcop NUMBER;
      vr_qtmaxchq NUMBER;
      
      vr_ret_all_dtlibera gene0002.typ_split;
      vr_ret_all_dtdcaptu gene0002.typ_split;
      vr_ret_all_vlcheque gene0002.typ_split;
      vr_ret_all_dsdocmc7 gene0002.typ_split;
      
      -- Informações do Cheque
      vr_dtchqbom DATE;
      vr_dtemissa DATE;
      vr_vlcheque NUMBER(25,2);
      vr_dsdocmc7 crapdcc.dsdocmc7%TYPE;
      -- Informações do emitente
      vr_inemiten INTEGER;
      vr_nrinsemi crapdcc.nrinsemi%TYPE;
      vr_cdtipemi crapdcc.cdtipemi%TYPE;
      vr_stsnrcal BOOLEAN;
      -- Campos do CMC7
      vr_dsdocmc7_formatado VARCHAR2(40);
      vr_cdbanchq NUMBER; 
      vr_cdagechq NUMBER;
      vr_cdcmpchq NUMBER;
      vr_nrctachq NUMBER;
      vr_nrcheque NUMBER;

      -- typ_tab_erro Generica
      pr_tab_erro GENE0001.typ_tab_erro;
      
      -- CURSORES
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.nrdconta
              ,cop.cdagectl
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      --Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdagenci
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
              ,crapass.nmprimtl
        FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 

      -- Ocorrencias da Custódia de Cheque
      CURSOR cr_crapocc (pr_cdtipmvt IN crapocc.cdtipmvt%TYPE
                        ,pr_cdocorre IN crapocc.cdocorre%TYPE) IS
        SELECT crapocc.dsocorre
          FROM crapocc
         WHERE crapocc.intipmvt = 2 -- Retorno
           AND crapocc.cdtipmvt = pr_cdtipmvt
           AND UPPER(crapocc.cdocorre) = UPPER(pr_cdocorre);
      rw_crapocc cr_crapocc%ROWTYPE;             
      
      -- Busca Dados Custodia em todas as cooperativas
      CURSOR cr_crapcst (pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcst.cdagechq%TYPE
                        ,pr_nrctachq IN crapcst.nrctachq%TYPE
                        ,pr_nrcheque IN crapcst.nrcheque%TYPE) IS
        SELECT crapcst.nrcheque, crapcop.nmrescop, crapcst.nrdconta
          FROM crapcst crapcst, crapcop crapcop
         WHERE crapcst.cdcooper = crapcop.cdcooper
           AND crapcst.cdcmpchq = pr_cdcmpchq
           AND crapcst.cdbanchq = pr_cdbanchq
           AND crapcst.cdagechq = pr_cdagechq
           AND crapcst.nrctachq = pr_nrctachq
           AND crapcst.nrcheque = pr_nrcheque
           AND crapcst.dtdevolu IS NULL;
      rw_crapcst cr_crapcst%ROWTYPE;
      -- Busca informações do emitente
      CURSOR cr_crapcec (pr_cdcooper IN crapcec.cdcooper%TYPE
                        ,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcec.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcec.cdagechq%TYPE
                        ,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
        SELECT cec.nrcpfcgc
          FROM crapcec cec
         WHERE cec.cdcooper = pr_cdcooper
           AND cec.cdcmpchq = pr_cdcmpchq
           AND cec.cdbanchq = pr_cdbanchq
           AND cec.cdagechq = pr_cdagechq
           AND cec.nrctachq = pr_nrctachq
           AND cec.nrdconta = 0;
      rw_crapcec cr_crapcec%ROWTYPE;
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

      /* Vetor para armazenar as informac?es de erro */
      vr_tab_custodia_erro CUST0001.typ_erro_custodia;
      vr_index_erro INTEGER;

      /* Vetor para armazenar as informacoes dos cheques que estao sendo custodiados */
      vr_tab_cheque_custodia CUST0001.typ_cheque_custodia;
      vr_index_cheque INTEGER;

    BEGIN
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
    
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => pr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;
      
      vr_qtmaxchq := to_number(gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                         pr_cdcooper => 0, /* cecred */
                                                         pr_cdacesso => 'QTD_CHQ_REM_IB'));
      
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_dtlibera := gene0002.fn_quebra_string(pr_dtlibera, '_');
      vr_ret_all_dtdcaptu := gene0002.fn_quebra_string(pr_dtdcaptu, '_');
      vr_ret_all_vlcheque := gene0002.fn_quebra_string(pr_vlcheque, '_');
      vr_ret_all_dsdocmc7 := gene0002.fn_quebra_string(pr_dsdocmc7, '_');
      
      IF vr_ret_all_dsdocmc7.count > vr_qtmaxchq THEN
        vr_dscritic := 'A quantidade máxima de cheques foi ultrapassada.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_dsdocmc7.count LOOP
        -- Zerar as informações do Tipo de Movimentação e da Ocorrencia
        vr_cdtipmvt := NULL;
        vr_cdocorre := NULL;
        vr_erro_custodia := NULL;

        vr_dtchqbom := to_date(vr_ret_all_dtlibera(vr_auxcont),'dd/mm/RRRR');
        vr_dtemissa := to_date(vr_ret_all_dtdcaptu(vr_auxcont),'dd/mm/RRRR');
        vr_vlcheque := to_number(vr_ret_all_vlcheque(vr_auxcont));
        vr_dsdocmc7 := vr_ret_all_dsdocmc7(vr_auxcont);
        
        -- Formatar o CMC-7
        vr_dsdocmc7_formatado := gene0002.fn_mask(vr_dsdocmc7,'<99999999<9999999999>999999999999:');
        -- Desmontar as informações do CMC-7
        -- Banco
        vr_cdbanchq := to_number(SUBSTR(vr_dsdocmc7,01,03)); 
        -- Agencia
        vr_cdagechq := to_number(SUBSTR(vr_dsdocmc7,04,04)); 
        -- Compe
        vr_cdcmpchq := to_number(SUBSTR(vr_dsdocmc7,09,03));
        -- Numero do Cheque
        vr_nrcheque := to_number(SUBSTR(vr_dsdocmc7,12,06));
        -- Conta do Cheque
        IF vr_cdbanchq = 1 THEN
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,22,08));   
        ELSE 
          vr_nrctachq := to_number(SUBSTR(vr_dsdocmc7,20,10)); 
        END IF;
        
        -- Utiliza a validação para IB para saber a situação do cheque
        pc_valida_cheque_ib(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_dsdocmc7 => vr_dsdocmc7_formatado
                           ,pr_cdbanchq => vr_cdbanchq
                           ,pr_cdagechq => vr_cdagechq
                           ,pr_cdcmpchq => vr_cdcmpchq
                           ,pr_nrctachq => vr_nrctachq
                           ,pr_nrcheque => vr_nrcheque
                           ,pr_dtlibera => vr_dtchqbom
                           ,pr_vlcheque => vr_vlcheque
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                           ,pr_dtdcaptu => rw_crapdat.dtmvtolt
                           ,pr_inchqcop => vr_inchqcop
                           ,pr_cdtipmvt => vr_cdtipmvt
                           ,pr_cdocorre => vr_cdocorre
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
        
        -- Se possuir alguma ocorrencia ou tipo de movimentação, gera crítica                  
        IF vr_cdtipmvt IS NOT NULL OR vr_cdocorre IS NOT NULL THEN
          OPEN cr_crapocc(pr_cdtipmvt => vr_cdtipmvt
                         ,pr_cdocorre => vr_cdocorre);  
        
          FETCH cr_crapocc INTO rw_crapocc;
          -- Se não encontrar
          IF cr_crapocc%NOTFOUND THEN
            -- Fechar o cursor pois haverá raise
            CLOSE cr_crapocc;
            -- Monta critica
            vr_erro_custodia := '';
          ELSE
            -- Apenas fechar o cursor
            CLOSE cr_crapocc;
            vr_erro_custodia := rw_crapocc.dsocorre;
            IF vr_cdtipmvt = 21 AND vr_cdocorre = '80' THEN -- Cheque já custodiado
              -- Busca cheque já custodiado em todas as cooperativas
              OPEN cr_crapcst(pr_cdcmpchq => vr_cdcmpchq
                             ,pr_cdbanchq => vr_cdbanchq
                             ,pr_cdagechq => vr_cdagechq
                             ,pr_nrctachq => vr_nrctachq
                             ,pr_nrcheque => vr_nrcheque);
              FETCH cr_crapcst INTO rw_crapcst;
              -- Se encontrar cheque já custodiado
              IF cr_crapcst%FOUND THEN
                -- Fechar o cursor
                CLOSE cr_crapcst;
                vr_erro_custodia := vr_erro_custodia ||
                  '. ' || rw_crapcst.nmrescop || ' - Conta: '
                  || gene0002.fn_mask_conta(rw_crapcst.nrdconta);
              END IF;
              IF cr_crapcst%ISOPEN THEN
                CLOSE cr_crapcst;
              END IF;
            END IF;
          END IF;
          
          vr_index_erro := vr_tab_custodia_erro.count + 1;  
          vr_tab_custodia_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
          vr_tab_custodia_erro(vr_index_erro).dscritic := vr_erro_custodia;
        ELSIF vr_vlcheque <= 0 THEN
          vr_index_erro := vr_tab_custodia_erro.count + 1;  
          vr_tab_custodia_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
          vr_tab_custodia_erro(vr_index_erro).dscritic := 'Cheque com valor zerado';
        END IF;
          
        -- Verificar se possui emitente cadastrado
        OPEN cr_crapcec(pr_cdcooper => pr_cdcooper
                       ,pr_cdcmpchq => vr_cdcmpchq
                       ,pr_cdbanchq => vr_cdbanchq
                       ,pr_cdagechq => vr_cdagechq
                       ,pr_nrctachq => vr_nrctachq);
        FETCH cr_crapcec INTO rw_crapcec;
        
        -- Se não encontrou emitente 
        IF cr_crapcec%NOTFOUND THEN
          -- Atribui valor 0 - Emitente não cadastrado
          vr_inemiten := 0;
          vr_nrinsemi := 0;
          vr_cdtipemi := 0;
        ELSE
          vr_inemiten := 1;          
          vr_nrinsemi := rw_crapcec.nrcpfcgc;
          -- Busca indicador de pessoa baseando-se no CPF/CNPJ do Emitente
          gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => vr_nrinsemi
                                     ,pr_stsnrcal => vr_stsnrcal
                                     ,pr_inpessoa => vr_cdtipemi);
        END IF;
        -- Fecha cursor
        CLOSE cr_crapcec;
        
        -- Carrega as informações do cheque para custodiar
        vr_index_cheque := vr_tab_cheque_custodia.count + 1;  
        vr_tab_cheque_custodia(vr_index_cheque).dsdocmc7 := vr_dsdocmc7_formatado;
        vr_tab_cheque_custodia(vr_index_cheque).cdcmpchq := vr_cdcmpchq;
        vr_tab_cheque_custodia(vr_index_cheque).cdbanchq := vr_cdbanchq;
        vr_tab_cheque_custodia(vr_index_cheque).cdagechq := vr_cdagechq;
        vr_tab_cheque_custodia(vr_index_cheque).nrctachq := vr_nrctachq;
        vr_tab_cheque_custodia(vr_index_cheque).nrcheque := vr_nrcheque;
        vr_tab_cheque_custodia(vr_index_cheque).vlcheque := vr_vlcheque;
        vr_tab_cheque_custodia(vr_index_cheque).dtlibera := vr_dtchqbom;
        vr_tab_cheque_custodia(vr_index_cheque).inchqcop := vr_inchqcop;
        vr_tab_cheque_custodia(vr_index_cheque).dtdcaptu := vr_dtemissa;        
        vr_tab_cheque_custodia(vr_index_cheque).inemiten := vr_inemiten;        
        vr_tab_cheque_custodia(vr_index_cheque).nrinsemi := vr_nrinsemi;
        vr_tab_cheque_custodia(vr_index_cheque).cdtipemi := vr_cdtipemi;
      END LOOP;
      
      -- Atribui PlTables para os parametros
      pr_tab_cust_cheq := vr_tab_cheque_custodia;
			pr_tab_erro_cust := vr_tab_custodia_erro;
      			
    EXCEPTION
      WHEN vr_exc_erro THEN
				-- Se não preencheu dscritic
				IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
				-- Atribui críticas
        pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
      WHEN OTHERS THEN
				-- Atribui críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_valida_custodia_manual: ' || SQLERRM;

        ROLLBACK;
    END;

  END pc_valida_custodia_ib;
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_lista_remessa_custodia(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_dtmvtini  IN crapdat.dtmvtolt%TYPE --> Data inicial do periodo
                                     ,pr_dtmvtfin  IN crapdat.dtmvtolt%TYPE --> Data final do periodo
                                     ,pr_insithcc  IN craphcc.insithcc%TYPE --> Indicador de situacao (1=Pendente , 2=Processado).
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_lista_remessa_custodia
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 28/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de remessas de custodias.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      -- Busca Remessas de custódias
      CURSOR cr_craphcc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_dtmvtini IN crapdat.dtmvtolt%TYPE
                        ,pr_dtmvtfin IN crapdat.dtmvtolt%TYPE
                        ,pr_insithcc IN craphcc.insithcc%TYPE) IS
        SELECT hcc.nrconven
              ,hcc.intipmvt
              ,hcc.nrremret
              ,to_char(hcc.dtmvtolt,'DD/MM/RRRR') dtmvtolt
              ,hcc.insithcc
              ,to_char(hcc.dtcustod,'DD/MM/RRRR') dtcustod
              ,hcc.idorigem
              ,to_char(nvl((SELECT SUM(dcc.vlcheque)
                  FROM crapdcc dcc
                 WHERE dcc.cdcooper = hcc.cdcooper
                   AND dcc.nrdconta = hcc.nrdconta
                   AND dcc.nrconven = hcc.nrconven
                   AND dcc.intipmvt = hcc.intipmvt
                   AND dcc.nrremret = hcc.nrremret),0) ,'FM999G999G999G999G990D00') vlcheque
              ,(SELECT COUNT(*)
                  FROM crapdcc dcc
                 WHERE dcc.cdcooper = hcc.cdcooper
                   AND dcc.nrdconta = hcc.nrdconta
                   AND dcc.nrconven = hcc.nrconven
                   AND dcc.intipmvt = hcc.intipmvt
                   AND dcc.nrremret = hcc.nrremret) qtcheque
          FROM craphcc hcc
         WHERE hcc.cdcooper = pr_cdcooper 
           AND hcc.nrdconta = pr_nrdconta
           AND hcc.dtmvtolt >= pr_dtmvtini
           AND hcc.dtmvtolt <= pr_dtmvtfin
           AND (pr_insithcc = 0
            OR hcc.insithcc = pr_insithcc)
           AND hcc.intipmvt = 3
         ORDER BY hcc.nrremret DESC;
      
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis auxiliares
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_retxml        XMLType;
      
    BEGIN
      
      
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<inproces>' || rw_crapdat.inproces || '</inproces>');  -- Flag Processo Noturno
      
      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<custodias>');

      -- Percorre remessas
      FOR rw_craphcc IN cr_craphcc (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtini => pr_dtmvtini
                                   ,pr_dtmvtfin => pr_dtmvtfin
                                   ,pr_insithcc => pr_insithcc) LOOP
          
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_pgto_temp
                               ,pr_texto_novo     => '<custodia>'
                                                  || '<nrconven>'||rw_craphcc.nrconven||'</nrconven>'
                                                  || '<intipmvt>'||rw_craphcc.intipmvt||'</intipmvt>'
                                                  || '<nrremret>'||rw_craphcc.nrremret||'</nrremret>'
                                                  || '<dtmvtolt>'||rw_craphcc.dtmvtolt||'</dtmvtolt>'
                                                  || '<insithcc>'||rw_craphcc.insithcc||'</insithcc>'
                                                  || '<dtcustod>'||rw_craphcc.dtcustod||'</dtcustod>'
                                                  || '<vlcheque>'||rw_craphcc.vlcheque||'</vlcheque>'
                                                  || '<qtcheque>'||rw_craphcc.qtcheque||'</qtcheque>'
                                                  || '<idorigem>'||rw_craphcc.idorigem||'</idorigem>'
                                                  || '</custodia>');
        
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</custodias>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_lista_remessa_custodia: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_lista_remessa_custodia;
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_lista_detalhe_custodia(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrconven  IN crapdcc.nrconven%TYPE --> Nr do convenio
                                     ,pr_nrremret  IN crapdcc.nrremret%TYPE --> Data final do periodo
                                     ,pr_nriniseq  IN INTEGER               --> Paginação - Inicio de sequencia
                                     ,pr_nrregist  IN INTEGER               --> Paginação - Número de registros
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_lista_remessa_custodia
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 28/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de remessas de custodias.

    Alteracoes: 21/08/2019 - Ajuste para retornar insithcc. RITM0011937(Lombardi)
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      -- Busca Remessas de custódias
      CURSOR cr_crapdcc (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrconven IN crapdcc.nrconven%TYPE
                        ,pr_nrremret IN crapdcc.nrremret%TYPE) IS
        SELECT x.* 
          FROM (SELECT dcc.nrconven
                      ,dcc.intipmvt
                      ,dcc.nrremret
                      ,to_char(dcc.dtlibera,'DD/MM/RRRR') dtlibera
                      ,to_char(dcc.dtdcaptu,'DD/MM/RRRR') dtdcaptu
                      ,dcc.cdbanchq
                      ,dcc.cdagechq
                      ,dcc.nrctachq
                      ,dcc.nrcheque
                      ,to_char(dcc.vlcheque,'FM999G999G999G999G990D00') vlcheque
                      ,dcc.inconcil
                      ,dcc.nrseqarq
                      ,translate(dcc.dsdocmc7,
                                 '[0-9]<>:',
                                 '[0-9]') dsdocmc7
                      ,hcc.idorigem
                      ,hcc.insithcc
                      ,rownum rnum
                      ,COUNT(*) over() qtregist
                  FROM crapdcc dcc
                      ,craphcc hcc
                 WHERE dcc.cdcooper = pr_cdcooper
                   AND dcc.nrdconta = pr_nrdconta
                   AND dcc.nrconven = pr_nrconven
                   AND dcc.intipmvt = 3
                   AND dcc.nrremret = pr_nrremret
                   AND hcc.cdcooper = dcc.cdcooper
                   AND hcc.nrdconta = dcc.nrdconta
                   AND hcc.nrconven = dcc.nrconven
                   AND hcc.intipmvt = dcc.intipmvt
                   AND hcc.nrremret = dcc.nrremret) x
         WHERE rnum >= pr_nriniseq
           AND rnum < (pr_nriniseq + pr_nrregist);
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- Variaveis auxiliares
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      vr_retxml        XMLType;
      vr_nrctachq      VARCHAR2(100);
      vr_qtregist      INTEGER;
      vr_insithcc      craphcc.insithcc%TYPE;
      
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<custodias>');
      
      vr_qtregist := 0;
      vr_insithcc := 0;
      
      -- Percorre remessas
      FOR rw_crapdcc IN cr_crapdcc (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrconven => pr_nrconven
                                   ,pr_nrremret => pr_nrremret) LOOP
        
        IF rw_crapdcc.cdbanchq = 1 THEN
          vr_nrctachq := gene0002.fn_mask(rw_crapdcc.nrctachq,'zzzz.zzz-z');
        ELSE
          vr_nrctachq := gene0002.fn_mask(rw_crapdcc.nrctachq,'zzzzzz.zzz-z');
        END IF;
        gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                               ,pr_texto_completo => vr_xml_pgto_temp
                               ,pr_texto_novo     => '<custodia>'
                                                  || '<nrconven>'||rw_crapdcc.nrconven||'</nrconven>'
                                                  || '<intipmvt>'||rw_crapdcc.intipmvt||'</intipmvt>'
                                                  || '<nrremret>'||rw_crapdcc.nrremret||'</nrremret>'
                                                  || '<dtlibera>'||rw_crapdcc.dtlibera||'</dtlibera>'
                                                  || '<dtdcaptu>'||rw_crapdcc.dtdcaptu||'</dtdcaptu>'
                                                  || '<cdbanchq>'||rw_crapdcc.cdbanchq||'</cdbanchq>'
                                                  || '<cdagechq>'||rw_crapdcc.cdagechq||'</cdagechq>'
                                                  || '<nrctachq>'||    vr_nrctachq     ||'</nrctachq>'
                                                  || '<nrcheque>'||rw_crapdcc.nrcheque||'</nrcheque>'
                                                  || '<vlcheque>'||rw_crapdcc.vlcheque||'</vlcheque>'
                                                  || '<inconcil>'||rw_crapdcc.inconcil||'</inconcil>'
                                                  || '<nrseqarq>'||rw_crapdcc.nrseqarq||'</nrseqarq>'
                                                  || '<dsdocmc7>'||rw_crapdcc.dsdocmc7||'</dsdocmc7>'
                                                  || '<idorigem>'||rw_crapdcc.idorigem||'</idorigem>'
                                                  || '</custodia>');
        IF vr_qtregist = 0 THEN
          vr_qtregist := rw_crapdcc.qtregist;
          vr_insithcc := rw_crapdcc.insithcc;
        END IF;
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '</custodias>');
                             
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<qtregist>' || vr_qtregist || '</qtregist>'
                             ,pr_fecha_xml      => TRUE);
                             
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<insithcc>'||vr_insithcc||'</insithcc>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_lista_detalhe_custodia: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_lista_detalhe_custodia;
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_excluir_cheque_remessa(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                                     ,pr_nrconven  IN crapdcc.nrconven%TYPE --> Nr do convenio
                                     ,pr_intipmvt  IN crapdcc.intipmvt%TYPE --> 
                                     ,pr_nrremret  IN crapdcc.nrremret%TYPE --> 
                                     ,pr_nrseqarq  IN crapdcc.nrseqarq%TYPE --> 
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_excluir_cheque_remessa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 28/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de remessas de custodias.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      --------- CURSOR ---------
      -- Busca Remessas de custódias
      CURSOR cr_crapdcc (pr_cdcooper  IN crapcop.cdcooper%TYPE 
                        ,pr_nrdconta  IN crapass.nrdconta%TYPE 
                        ,pr_nrconven  IN crapdcc.nrconven%TYPE 
                        ,pr_intipmvt  IN crapdcc.intipmvt%TYPE 
                        ,pr_nrremret  IN crapdcc.nrremret%TYPE 
                        ,pr_nrseqarq  IN crapdcc.nrseqarq%TYPE) IS
        SELECT dcc.inconcil
              ,hcc.insithcc
              ,dcc.cdbccxlt
              ,dcc.cdagenci
              ,dcc.dsdocmc7
          FROM crapdcc dcc
              ,craphcc hcc
         WHERE dcc.cdcooper = pr_cdcooper
           AND dcc.nrdconta = pr_nrdconta
           AND dcc.nrconven = pr_nrconven
           AND dcc.intipmvt = pr_intipmvt
           AND dcc.nrremret = pr_nrremret
           AND dcc.nrseqarq = pr_nrseqarq
           AND hcc.cdcooper = dcc.cdcooper
           AND hcc.nrdconta = dcc.nrdconta
           AND hcc.nrconven = dcc.nrconven
           AND hcc.intipmvt = dcc.intipmvt
           AND hcc.nrremret = dcc.nrremret;
      rw_crapdcc cr_crapdcc%ROWTYPE;
      
      -- Busca Remessas de custódias
      CURSOR cr_craphcc (pr_cdcooper  IN crapcop.cdcooper%TYPE 
                        ,pr_nrdconta  IN crapass.nrdconta%TYPE 
                        ,pr_nrconven  IN crapdcc.nrconven%TYPE 
                        ,pr_intipmvt  IN crapdcc.intipmvt%TYPE 
                        ,pr_nrremret  IN crapdcc.nrremret%TYPE) IS
        SELECT count(1) qtcheque
          FROM crapdcc dcc
         WHERE dcc.cdcooper = pr_cdcooper
           AND dcc.nrdconta = pr_nrdconta
           AND dcc.nrconven = pr_nrconven
           AND dcc.intipmvt = pr_intipmvt
           AND dcc.nrremret = pr_nrremret;
      rw_craphcc cr_craphcc%ROWTYPE;
      
      -- Busca cheques descontado		
		  CURSOR cr_crapcdb(pr_cdcooper IN crapcop.cdcooper%TYPE
			                 ,pr_dsdocmc7 IN VARCHAR2) IS
			  SELECT cdb.nrborder
				  FROM crapcdb cdb
				 WHERE cdb.cdcooper = pr_cdcooper
				   AND cdb.nrdconta = pr_nrdconta
				   AND UPPER(cdb.dsdocmc7) = UPPER(pr_dsdocmc7)
				   AND cdb.dtdevolu IS NULL;
			rw_crapcdb cr_crapcdb%ROWTYPE; 
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis auxiliares
      vr_flgfound      BOOLEAN;
      vr_dstransa      VARCHAR2(100);
      vr_rowid_log     ROWID;
      vr_retxml        XMLType;
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      -- Verifica se existe o registro
      OPEN cr_crapdcc (pr_cdcooper => pr_cdcooper 
                      ,pr_nrdconta => pr_nrdconta 
                      ,pr_nrconven => pr_nrconven 
                      ,pr_intipmvt => pr_intipmvt 
                      ,pr_nrremret => pr_nrremret 
                      ,pr_nrseqarq => pr_nrseqarq);
      FETCH cr_crapdcc INTO rw_crapdcc;
      vr_flgfound := cr_crapdcc%FOUND;
      CLOSE cr_crapdcc;
      -- Se encontrar registro
      IF vr_flgfound THEN
        
        IF rw_crapdcc.inconcil <> 0 THEN
          vr_dscritic := 'Cheque deve estar com situação Pendente de Entrega.';
          RAISE vr_exc_erro;
        END IF;
        
        IF rw_crapdcc.insithcc <> 1 THEN
          vr_dscritic := 'Remessa deve estar com Status Pendente.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Verifica se cheque foi custodiado e não foi resgatado			
        OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper
                       ,pr_dsdocmc7 => rw_crapdcc.dsdocmc7);
        FETCH cr_crapcdb INTO rw_crapcdb;
  			
        -- Se não encontrou
        IF cr_crapcdb%FOUND THEN
          vr_dscritic := 'Cheque esta incluso em Bordero de Desconto.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Exclui o resgitro
        BEGIN
          DELETE 
            FROM crapdcc
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrconven = pr_nrconven
             AND intipmvt = pr_intipmvt
             AND nrremret = pr_nrremret
             AND nrseqarq = pr_nrseqarq;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na exclusão do cheque. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        vr_dstransa := 'Exclusao do cheque ' || 
                       'Banco: '      || rw_crapdcc.cdbccxlt || ' ' ||
                       'Agencia: '    || rw_crapdcc.cdagenci || ' ' ||
                       'Conta: '      || gene0002.fn_mask_conta(pr_nrdconta) || ' ' ||
                       'Nro.: '       || pr_nrconven || ' ' ||
                       'da Remessa: ' || pr_nrremret;
          
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => 996
                              ,pr_dscritic => ' '
                              ,pr_dsorigem => 'INTERNET'
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => trunc(SYSDATE)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => ' '
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_rowid_log);
        
      ELSE
        vr_dscritic := 'Cheque não localizado.';
      END IF;
      
      -- Busca quantidade de cheques da remessa
      OPEN cr_craphcc (pr_cdcooper => pr_cdcooper 
                      ,pr_nrdconta => pr_nrdconta 
                      ,pr_nrconven => pr_nrconven 
                      ,pr_intipmvt => pr_intipmvt 
                      ,pr_nrremret => pr_nrremret);
      FETCH cr_craphcc INTO rw_craphcc;
      CLOSE cr_craphcc;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>' || rw_craphcc.qtcheque || '</raiz>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_excluir_cheque_remessa: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_excluir_cheque_remessa;
  
  -- Buscar lista de remessas de custodias.
  PROCEDURE pc_excluir_remessa(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Nr. da Conta
                              ,pr_nrconven  IN crapdcc.nrconven%TYPE --> Nr do convenio
                              ,pr_intipmvt  IN crapdcc.intipmvt%TYPE --> 
                              ,pr_nrremret  IN crapdcc.nrremret%TYPE --> 
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML


  BEGIN
    /* .............................................................................
    Programa: pc_excluir_remessa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 28/09/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar lista de remessas de custodias.

    Alteracoes: 
    ............................................................................. */
    DECLARE
      
      --------- CURSOR ---------
      
      -- Busca Remessas de custódias
      CURSOR cr_craphcc (pr_cdcooper  IN crapcop.cdcooper%TYPE 
                        ,pr_nrdconta  IN crapass.nrdconta%TYPE 
                        ,pr_nrconven  IN crapdcc.nrconven%TYPE 
                        ,pr_intipmvt  IN crapdcc.intipmvt%TYPE 
                        ,pr_nrremret  IN crapdcc.nrremret%TYPE) IS
        SELECT hcc.insithcc
              ,hcc.idorigem
              ,(SELECT COUNT(*)
                  FROM crapdcc dcc
                 WHERE dcc.cdcooper = hcc.cdcooper
                   AND dcc.nrdconta = hcc.nrdconta
                   AND dcc.nrconven = hcc.nrconven
                   AND dcc.intipmvt = hcc.intipmvt
                   AND dcc.nrremret = hcc.nrremret) qtcheque
          FROM craphcc hcc
         WHERE hcc.cdcooper = pr_cdcooper
           AND hcc.nrdconta = pr_nrdconta
           AND hcc.nrconven = pr_nrconven
           AND hcc.intipmvt = pr_intipmvt
           AND hcc.nrremret = pr_nrremret;
      rw_craphcc cr_craphcc%ROWTYPE;
      
      --------- Variaveis ---------
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Variaveis auxiliares
      vr_flgfound      BOOLEAN;
      vr_dstransa      VARCHAR2(100);
      vr_rowid_log     ROWID;
      vr_retxml        XMLType;
      vr_xml_pgto_temp VARCHAR2(32726) := '';
      
    BEGIN
      
      -- Monta documento XML
      dbms_lob.createtemporary(pr_retxml, TRUE);
      dbms_lob.open(pr_retxml, dbms_lob.lob_readwrite);

      -- Verifica se existe o registro
      OPEN cr_craphcc (pr_cdcooper => pr_cdcooper 
                      ,pr_nrdconta => pr_nrdconta 
                      ,pr_nrconven => pr_nrconven 
                      ,pr_intipmvt => pr_intipmvt 
                      ,pr_nrremret => pr_nrremret);
      FETCH cr_craphcc INTO rw_craphcc;
      vr_flgfound := cr_craphcc%FOUND;
      CLOSE cr_craphcc;
      -- Se encontrar registro
      IF vr_flgfound THEN
        
        IF rw_craphcc.insithcc <> 1 THEN
          vr_dscritic := 'Remessa deve estar com Status Pendente.';
          RAISE vr_exc_erro;
        END IF;
        
        IF rw_craphcc.idorigem <> 3 THEN
          vr_dscritic := 'Remessa não foi criada pelo Cooperado.';
          RAISE vr_exc_erro;
        END IF;
        
        IF rw_craphcc.qtcheque <> 0 THEN
          vr_dscritic := 'Existem cheques na remessa.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Exclui o resgitro
        BEGIN
          DELETE 
            FROM craphcc
           WHERE cdcooper = pr_cdcooper
             AND nrdconta = pr_nrdconta
             AND nrconven = pr_nrconven
             AND intipmvt = pr_intipmvt
             AND nrremret = pr_nrremret;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na exclusão da remessa. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        vr_dstransa := 'Exclusao da remessa ' || 'Nro.: ' || pr_nrremret;
          
          -- Efetua os inserts para apresentacao na tela VERLOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => 996
                              ,pr_dscritic => ' '
                              ,pr_dsorigem => 'INTERNET'
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => trunc(SYSDATE)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => ' '
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_rowid_log);
        
      ELSE
        vr_dscritic := 'Remessa não localizada.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_retxml
                             ,pr_texto_completo => vr_xml_pgto_temp
                             ,pr_texto_novo     => '<raiz>OK</raiz>'
                             ,pr_fecha_xml      => TRUE);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_excluir_cheque_remessa: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
  END pc_excluir_remessa;
  
  -- Validar os cheques para a custódia
  PROCEDURE pc_valida_custodia(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                              ,pr_dtlibera  IN VARCHAR2              --> Lista Data Boa 
                              ,pr_dtdcaptu  IN VARCHAR2              --> Lista Data Emissao 
                              ,pr_vlcheque  IN VARCHAR2              --> Lista Valor Cheque 
                              ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7 
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_valida_custodia
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 07/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar os cheques para a custódia

    Alteracoes: 
    
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_exc_emiten EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      vr_retxml            XMLType;
      vr_xml_emitentes     VARCHAR2(32726);
      vr_contas_existentes VARCHAR2(32726) := '';
      vr_conta_atual       VARCHAR2(200);
      
      -- Vetor para armazenar as informac?es de erro
      vr_tab_custodia_erro CUST0001.typ_erro_custodia;
      vr_index_erro        INTEGER;
      vr_xml_erro_custodia VARCHAR2(32726);
      
      -- Vetor para armazenar as informacoes dos cheques que estao sendo custodiados
      vr_tab_cheque_custodia CUST0001.typ_cheque_custodia;
      
    BEGIN
      
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_valida_custodia'
                                ,pr_action => NULL);
      
      -- Validar cheques
      pc_valida_custodia_ib(pr_cdcooper => pr_cdcooper                  --> Cooperativa
												   ,pr_nrdconta => pr_nrdconta                  --> Número da conta
                           ,pr_dtlibera => pr_dtlibera                  --> Codigo do Indexador 
                           ,pr_dtdcaptu => pr_dtdcaptu                  
                           ,pr_vlcheque => pr_vlcheque                  
                           ,pr_dsdocmc7 => pr_dsdocmc7                  
                           ,pr_tab_cust_cheq => vr_tab_cheque_custodia  --> Tabela com cheques para custódia
                           ,pr_tab_erro_cust => vr_tab_custodia_erro    --> Tabela de cheques com erros
                           ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                           ,pr_dscritic => vr_dscritic);                --> Descrição da crítica      
			
			-- Se retornou erro												 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			  --Levantar Excecao
			  RAISE vr_exc_erro;
		  END IF;
		  
      -- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_custodia_erro.count > 0 THEN
        vr_xml_erro_custodia := '';
        FOR vr_index_erro IN 1..vr_tab_custodia_erro.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_custodia := vr_xml_erro_custodia || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <dsdocmc7>' || vr_tab_custodia_erro(vr_index_erro).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <dscritic>' || vr_tab_custodia_erro(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
        RAISE vr_exc_saida;
      END IF;
      
      -- Verificar se possui algum emitente não cadastrado
			IF vr_tab_cheque_custodia.count > 0 THEN
				vr_xml_emitentes := '';
				FOR vr_index_cheque IN 1..vr_tab_cheque_custodia.count LOOP
          -- Monta chave do emitente
          vr_conta_atual := vr_tab_cheque_custodia(vr_index_cheque).cdbanchq ||
                            vr_tab_cheque_custodia(vr_index_cheque).cdagechq ||
                            vr_tab_cheque_custodia(vr_index_cheque).nrctachq;
          -- Verifica se emitente ta conta ja foi pedido
          IF INSTR(vr_contas_existentes, vr_conta_atual) = 0  OR 
             vr_contas_existentes IS NULL                     THEN
            vr_contas_existentes := vr_contas_existentes || ';' || vr_conta_atual;
            
            -- Se exister algum cheque sem emitente
            IF vr_tab_cheque_custodia(vr_index_cheque).inemiten = 0 AND
               vr_tab_cheque_custodia(vr_index_cheque).cdbanchq <> 85 THEN
               -- Passar flag de falta de cadastro de emitente
               vr_xml_emitentes := vr_xml_emitentes ||
                                   '<emitente'|| vr_index_cheque || '>' ||
                                      '<cdbanchq>' || vr_tab_cheque_custodia(vr_index_cheque).cdbanchq || '</cdbanchq>' ||
                                      '<cdagechq>' || vr_tab_cheque_custodia(vr_index_cheque).cdagechq || '</cdagechq>' ||
                                      '<nrctachq>' || vr_tab_cheque_custodia(vr_index_cheque).nrctachq || '</nrctachq>' ||
                                      '<cdcmpchq>' || vr_tab_cheque_custodia(vr_index_cheque).cdcmpchq || '</cdcmpchq>' ||
                                      '<dsdocmc7>' || regexp_replace(vr_tab_cheque_custodia(vr_index_cheque).dsdocmc7,'[^0-9]') || '</dsdocmc7>' ||
                                   '</emitente'|| vr_index_cheque || '>';
            END IF;
          END IF;
				END LOOP;
				IF trim(vr_xml_emitentes) IS NOT NULL THEN
					RAISE vr_exc_emiten;
				END IF;
			END IF;					

    EXCEPTION
      WHEN vr_exc_emiten THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Emitentes>' || vr_xml_emitentes || '</Emitentes></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_saida THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_CMC7>' || vr_xml_erro_custodia || '</Validar_CMC7></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_valida_custodia: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;

  END pc_valida_custodia;
  
  -- Validar os cheques para a custódia
  PROCEDURE pc_cadastra_emitentes(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                 ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_cadastra_emitentes
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 20/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar os emitentes para os cheques da custódia

    Alteracoes: 
    
    ............................................................................. */
    DECLARE
      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_erro VARCHAR2(3);

      -- Tratamento de erros
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
  		
      vr_ret_all_cheques gene0002.typ_split;
      vr_ret_cheque gene0002.typ_split;
      vr_index_erro INTEGER;
      vr_xml_erro_emitente VARCHAR2(32726);
      vr_retxml        XMLType;

      -- Variáveis utilizadas para passar os parametros da rotina		
      vr_cdbanchq crapcec.cdbanchq%TYPE; 
      vr_cdagechq crapcec.cdagechq%TYPE;
      vr_cdcmpchq crapcec.cdcmpchq%TYPE;
      vr_nrctachq crapcec.nrctachq%TYPE;
      vr_nrcpfcgc crapcec.nrcpfcgc%TYPE;
      vr_nmcheque crapcec.nmcheque%TYPE;
  		
      -- Criar registro de erro de emitente
      TYPE typ_reg_erro_emitente IS
      RECORD(idemiten VARCHAR2(100)
            ,dscritic VARCHAR2(4000));
      TYPE typ_erro_emitente IS
        TABLE OF typ_reg_erro_emitente
        INDEX BY BINARY_INTEGER;
      vr_tab_erro_emitente typ_erro_emitente;
      
    BEGIN
      
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
        			
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
        -- Criando um array com todas as informações do cheque
        vr_ret_cheque := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');

		vr_ret_cheque(5) := translate( vr_ret_cheque(5),' .-',' ');

        vr_cdcmpchq := to_number(vr_ret_cheque(1));			-- Compe
        vr_cdbanchq := to_number(vr_ret_cheque(2));			-- Banco
        vr_cdagechq := to_number(vr_ret_cheque(3));			-- Agencia
        vr_nrctachq := to_number(vr_ret_cheque(4));			-- Conta do Cheque
        vr_nrcpfcgc := vr_ret_cheque(5);                -- CPF/CNPJ Emitente
        vr_nmcheque := vr_ret_cheque(6);                -- Nome do emitente
        
        -- Validar Emitente
        CUST0001.pc_validar_emitente(pr_cdcooper => pr_cdcooper  --> Cooperativa
                                    ,pr_cdcmpchq => vr_cdcmpchq  --> Cód. da compe
                                    ,pr_cdbanchq => vr_cdbanchq  --> Cód. do banco
                                    ,pr_cdagechq => vr_cdagechq  --> Cód. da agência
                                    ,pr_nrctachq => vr_nrctachq  --> Número da conta do cheque
                                    ,pr_nrcpfcgc => vr_nrcpfcgc  --> Número do cpf do emitente
                                    ,pr_nmcheque => vr_nmcheque  --> Nome do emitente
                                    ,pr_cdcritic => vr_cdcritic  --> Cód da crítica
                                    ,pr_dscritic => vr_dscritic  --> Descrição da crítica
                                    ,pr_des_erro => vr_des_erro);--> Retorno "OK"/"NOK"
  		
        -- Se retornou erro
        IF NVL(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se não foi erro tratado
          IF vr_des_erro <> 'OK' THEN
            -- Levanta exceção
            RAISE vr_exc_erro;	
          ELSE
            -- Incrementa indice
            vr_index_erro := vr_tab_erro_emitente.count + 1;
            -- Cria registro de erro
            vr_tab_erro_emitente(vr_index_erro).idemiten := to_char(vr_cdcmpchq)
                                                         || to_char(vr_cdbanchq)
                                                         || to_char(vr_cdagechq)
                                                         || to_char(vr_nrctachq);
            vr_tab_erro_emitente(vr_index_erro).dscritic := vr_dscritic;
          END IF;
        END IF;
  		    
      END LOOP;
  		
      -- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_erro_emitente.count > 0 THEN
        vr_xml_erro_emitente := '';
        FOR vr_index_erro IN 1..vr_tab_erro_emitente.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_emitente := vr_xml_erro_emitente || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <idemiten>' || vr_tab_erro_emitente(vr_index_erro).idemiten || '</idemiten>' ||
                                  '  <dscritic>' || vr_tab_erro_emitente(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
        RAISE vr_exc_saida;
  		ELSE
        -- Percorre todos os cheques para processá-los
        FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
          -- Criando um array com todas as informações do cheque
          vr_ret_cheque := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');

		  vr_ret_cheque(5) := translate( vr_ret_cheque(5),' .-',' ');

          vr_cdcmpchq := to_number(vr_ret_cheque(1));			-- Compe
          vr_cdbanchq := to_number(vr_ret_cheque(2));			-- Banco
          vr_cdagechq := to_number(vr_ret_cheque(3));			-- Agencia
          vr_nrctachq := to_number(vr_ret_cheque(4));			-- Conta do Cheque
          vr_nrcpfcgc := vr_ret_cheque(5);                -- CPF/CNPJ Emitente
          vr_nmcheque := vr_ret_cheque(6);                -- Nome do emitente

          -- Cadastrar emitente
          CUST0001.pc_cadastra_emitente(pr_cdcooper => pr_cdcooper
                                       ,pr_cdcmpchq => vr_cdcmpchq
                                       ,pr_cdbanchq => vr_cdbanchq
                                       ,pr_cdagechq => vr_cdagechq
                                       ,pr_nrctachq => vr_nrctachq
                                       ,pr_nrcpfcgc => vr_nrcpfcgc
                                       ,pr_nmcheque => vr_nmcheque
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_des_erro => vr_des_erro);
  														
          -- Se retornou erro
          IF NVL(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
             vr_dscritic := 'Erro ao cadastrar emitente: ' || vr_dscritic;
            RAISE vr_exc_erro;	 
          END IF;														
        END LOOP;
      END IF;
      
      COMMIT;
      pr_retxml := '<Root>OK</Root>';
  
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_Emiten>' || vr_xml_erro_emitente || '</Validar_Emiten></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_cadastra_emitentes: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;

  END pc_cadastra_emitentes;
  
  -- Cadastrar custodia e emitentes
  PROCEDURE pc_custodia_cheque(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                              ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                              ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Número do Titular
                              ,pr_dtlibera  IN VARCHAR2              --> Lista Data Boa
                              ,pr_dtdcaptu  IN VARCHAR2              --> Lista Data Emissao
                              ,pr_vlcheque  IN VARCHAR2              --> Lista Valor Cheque
                              ,pr_dsdocmc7  IN VARCHAR2              --> Lista CMC7
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   OUT CLOB) IS              --> Arquivo de retorno do XML
  
  BEGIN
    /* .............................................................................
    Programa: pc_cadastra_custodia
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lombardi
    Data    : 20/10/2016                        Ultima atualizacao: --/--/----

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para cadastrar a custodia dos cheques

    Alteracoes: 
    
    ............................................................................. */
    DECLARE
      -- Variaveis de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_erro   EXCEPTION;
      vr_exc_emiten EXCEPTION;
  		vr_exc_custod EXCEPTION;
      
      -- Variaveis auxiliares
      vr_index_erro        INTEGER;
      vr_xml_erro_emitente VARCHAR2(32726);
      vr_xml_erro_custodia VARCHAR2(32726);
      vr_retxml            XMLType;
      vr_nrremret          craphcc.nrremret%TYPE;
      vr_nrdrowid          ROWID;
      vr_vlcustot          NUMBER := 0;
      
      vr_tab_custodia_erro   CUST0001.typ_erro_custodia;
      vr_tab_cheque_custodia CUST0001.typ_cheque_custodia;
      
      
      -- Header do Arquivo de Custódia de Cheques
      CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_nrdconta IN craphcc.nrdconta%TYPE) IS --> Numero da Conta
        SELECT NVL(MAX(nrremret),0) nrremret
          FROM craphcc
         WHERE craphcc.cdcooper = pr_cdcooper 
           AND craphcc.nrdconta = pr_nrdconta
           AND craphcc.nrconven = 1 -- Fixo
           AND craphcc.intipmvt = 3 -- Manual
         ORDER BY craphcc.cdcooper,
                  craphcc.nrdconta,
                  craphcc.nrconven,
                  craphcc.intipmvt;              
      rw_craphcc cr_craphcc%ROWTYPE;
       
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Não é pode cadastrar no processo noturno
      IF rw_crapdat.inproces <> 1 THEN
        vr_dscritic := 'Desconto de cheques indisponível no momento. Tente mais tarde.';
        RAISE vr_exc_erro;
      END IF;
      
      -- Validar cheques
      pc_valida_custodia_ib(pr_cdcooper => pr_cdcooper                  --> Cooperativa
												   ,pr_nrdconta => pr_nrdconta                  --> Número da conta
                           ,pr_dtlibera => pr_dtlibera                  --> Codigo do Indexador 
                           ,pr_dtdcaptu => pr_dtdcaptu
                           ,pr_vlcheque => pr_vlcheque
                           ,pr_dsdocmc7 => pr_dsdocmc7
                           ,pr_tab_cust_cheq => vr_tab_cheque_custodia  --> Tabela com cheques para custódia
                           ,pr_tab_erro_cust => vr_tab_custodia_erro    --> Tabela de cheques com erros
                           ,pr_cdcritic => vr_cdcritic                  --> Código da crítica
                           ,pr_dscritic => vr_dscritic);                --> Descrição da crítica      
			
			-- Se retornou erro												 
		  IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			  --Levantar Excecao
			  RAISE vr_exc_erro;
		  END IF;
		  
      -- Verifica se foram encontrados erros durante o processamento
      IF vr_tab_custodia_erro.count > 0 THEN
        vr_xml_erro_custodia := '';
        FOR vr_index_erro IN 1..vr_tab_custodia_erro.count LOOP
          -- Gera o XML com os erros
          vr_xml_erro_custodia := vr_xml_erro_custodia || 
                                  '<erro'|| vr_index_erro || '>' ||
                                  '  <dsdocmc7>' || vr_tab_custodia_erro(vr_index_erro).dsdocmc7 || '</dsdocmc7>' ||
                                  '  <dscritic>' || vr_tab_custodia_erro(vr_index_erro).dscritic || '</dscritic>' ||
                                  '</erro'|| vr_index_erro || '>';
        END LOOP;
        RAISE vr_exc_custod;
      END IF;
      
      -- Se não possuir nenhuma crítica, insere os dados na craphcc e crapdcc
      -- Buscar o Último Lote de Retorno do Cooperado
      OPEN cr_craphcc(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_craphcc INTO rw_craphcc;

      -- Verifica se a retornou registro
      IF cr_craphcc%NOTFOUND THEN
        CLOSE cr_craphcc;
        -- Numero de Retorno
        vr_nrremret := 1; 
      ELSE
        CLOSE cr_craphcc;
        -- Numero de Retorno
        vr_nrremret := rw_craphcc.nrremret + 1;
      END IF;
      
      -- Insere na tabela craphcc os dados do Header do Arquivo
      -- Criar Lote de Informações de Retorno (craphcc) 
      BEGIN
        INSERT INTO craphcc
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
           insithcc,
           cdoperad)
        VALUES
          (pr_cdcooper,
           pr_nrdconta,
           1, -- nrconven -> Fixo 1
           3, -- Manual
           vr_nrremret,
           rw_crapdat.dtmvtolt,
           ' ', -- Não possui nome de arquivo
           3,   -- Internet Bank
           trunc(SYSDATE),
           to_char(SYSDATE,'HH24MISS'),
           1, -- insithcc -> Pendente
           '996'); -- cdoperad PERGUNTAR PARA O DANIEL
      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir CRAPHCC: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      -- Percorre todos os cheques para inserir na crapdcc
      FOR vr_index_cheque IN 1..vr_tab_cheque_custodia.count LOOP
        -- Insere dados na tabela crapdcc
        BEGIN
          INSERT INTO crapdcc
            (cdcooper,
             nrdconta,
             nrconven,
             intipmvt,
             nrremret,
             nrseqarq,
             cdtipmvt,
             cdfinmvt,
             cdentdad,
             dsdocmc7,
             cdcmpchq,
             cdbanchq,
             cdagechq,
             nrctachq,
             nrcheque,
             vlcheque,
             dtlibera,
             cdocorre,
             inconcil,
             inchqcop,
						 dtdcaptu,
						 nrinsemi,
						 cdtipemi)
          VALUES
            (pr_cdcooper,
             pr_nrdconta,
             1, -- nrconven -> Fixo 1
             3, -- intipmvt -> 3 - Retorno
             vr_nrremret,
             vr_index_cheque, -- nrseqarq -> Contador
             1, -- cdtipmvt -> 1 - Inclusão
             1, -- cdfinmvt -> 1 - Custódia Simples,
             1, -- cdentdad -> 1 - CMC-7
             vr_tab_cheque_custodia(vr_index_cheque).dsdocmc7,
             vr_tab_cheque_custodia(vr_index_cheque).cdcmpchq,
             vr_tab_cheque_custodia(vr_index_cheque).cdbanchq,
             vr_tab_cheque_custodia(vr_index_cheque).cdagechq,
             vr_tab_cheque_custodia(vr_index_cheque).nrctachq,
             vr_tab_cheque_custodia(vr_index_cheque).nrcheque,
             vr_tab_cheque_custodia(vr_index_cheque).vlcheque,
             vr_tab_cheque_custodia(vr_index_cheque).dtlibera, 
             ' ', -- cdocorre-> Vazio, pois não é gerado enquanto possuir erros
             0,   -- inconcil -> Fixo 0,
             vr_tab_cheque_custodia(vr_index_cheque).inchqcop,
						 vr_tab_cheque_custodia(vr_index_cheque).dtdcaptu,
 						 vr_tab_cheque_custodia(vr_index_cheque).nrinsemi,
 						 vr_tab_cheque_custodia(vr_index_cheque).cdtipemi);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir CRAPDCC: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        vr_vlcustot := vr_vlcustot + vr_tab_cheque_custodia(vr_index_cheque).vlcheque;
      END LOOP; 
      
      -- Gerar log
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 996
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'INTERNET'
                          ,pr_dstransa => 'Inclusão de custódia.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 -- TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => 'INTERNETBANK'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Remessa'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => vr_nrremret);
                                 
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Valor Total'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => 'R$ ' || to_char(vr_vlcustot,'FM999G999G999G999G990D00'));
      
      -- Percorre todos os cheques para inserir na crapdcc
      FOR vr_index_cheque IN 1..vr_tab_cheque_custodia.count LOOP
        
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Cheque ' || vr_index_cheque
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => vr_tab_cheque_custodia(vr_index_cheque).dsdocmc7);
      END LOOP; 
      
      pr_retxml := '<Root>OK</Root>';
			
      -- Commita as alterações;
      COMMIT;
  
    EXCEPTION
      WHEN vr_exc_emiten THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_Emiten>' || vr_xml_erro_emitente || '</Validar_Emiten></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_custod THEN
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<Root><Validar_CMC7>' || vr_xml_erro_custodia || '</Validar_CMC7></Root>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em pc_cadastra_custodia: ' || SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        vr_retxml := XMLType.createXML('<DSMSGERR>' || pr_dscritic || '</DSMSGERR>');
        ROLLBACK;
          
        -- Converter o XML
        pr_retxml := vr_retxml.getClobVal();
    END;
    
  END pc_custodia_cheque;
  
END CUST0002;
/
