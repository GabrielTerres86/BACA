CREATE OR REPLACE PACKAGE CECRED.EMPR0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0002
  --  Sistema  : Rotinas referentes a tela PARPRE
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando - CECRED
  --  Data     : Junho - 2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela PARPRE

  -- Alteracoes: 03/08/2016 - Alterada estrutura da tela cadpre e outras rotinas
  --                          do pre aprovado para fase 3 do Projeto 299 
  --                          Pre aprovado.(Lombardi)
  --
  ---------------------------------------------------------------------------------------------------------------
   
  --temptable para retornar dados da cpa, antigo b1wgen188tt.i/tt-dados-cpa
  TYPE typ_rec_dados_cpa IS RECORD
      (cdcooper crapepr.cdcooper%TYPE,
       nrdconta crapepr.nrdconta%TYPE,
       inpessoa crapass.inpessoa%TYPE,
       vldiscrd crapcpa.vllimdis%TYPE,
       txmensal craplcr.txmensal%TYPE,
       vllimctr crappre.vllimctr%TYPE,
       msgmanua VARCHAR2(1000)
       );
  TYPE typ_tab_dados_cpa IS TABLE OF typ_rec_dados_cpa 
      INDEX BY PLS_INTEGER;
       
       
  PROCEDURE pc_valida_operador(pr_cdcooper  IN crapope.cdcooper%TYPE --> Codigo da Carga
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Descri��o da cr�tica
                              ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
  
  /* Rotina referente as acoes da tela PARPRE */
  PROCEDURE pc_tela_cadpre(pr_cddopcao   IN VARCHAR2              --> Tipo de acao que sera executada (C - Consulta / A - Alteracao)
                          ,pr_inpessoa   IN crappre.inpessoa%TYPE --> Codigo do tipo de pessoa
                          ,pr_nrmcotas   IN crappre.nrmcotas%TYPE --> Numero de vezes que as cotas serao multiplicadas
                          ,pr_vllimite_a IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco A
                          ,pr_vllimite_b IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco B
                          ,pr_vllimite_c IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco C
                          ,pr_vllimite_d IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco D
                          ,pr_vllimite_e IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco E
                          ,pr_vllimite_f IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco F
                          ,pr_vllimite_g IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco G
                          ,pr_vllimite_h IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco H
                          ,pr_cdlcremp_a IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco A
                          ,pr_cdlcremp_b IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco B
                          ,pr_cdlcremp_c IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco C
                          ,pr_cdlcremp_d IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco D
                          ,pr_cdlcremp_e IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco E
                          ,pr_cdlcremp_f IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco F
                          ,pr_cdlcremp_g IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco G
                          ,pr_cdlcremp_h IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco H
                          ,pr_dssitdop   IN crappre.dssitdop%TYPE --> Situa��o das Contas separados por (;)
                          ,pr_nrrevcad   IN crappre.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                          ,pr_vllimmin   IN crappre.vllimmin%TYPE --> Limite minimo
                          ,pr_vlpercom   IN crappre.vlpercom%TYPE  --> Porcentagem de comprometimento da Renda
                          ,pr_qtdiaver   IN crappre.qtdiaver%TYPE  --> Porcentagem de comprometimento da Renda
                          ,pr_vlmaxleg   IN crappre.vlmaxleg%TYPE  --> Porcentagem de Valor Maximo Legal
                          ,pr_qtmesblq   IN crappre.qtmesblq%TYPE  --> Porcentagem de Valor Maximo Legal
                          ,pr_vllimctr   IN crappre.vllimctr%TYPE --> Limite minimo para contratacao
                          ,pr_vlmulpli   IN crappre.vlmulpli%TYPE --> Valor multiplo
                          ,pr_cdfinemp   IN crappre.cdfinemp%TYPE --> Codigo da Finalidade
                          ,pr_qtmescta   IN crappre.qtmescta%TYPE --> Tempo de abertura da conta
                          ,pr_qtmesadm   IN crappre.qtmesadm%TYPE --> Tempo de admissao no emprego atual
                          ,pr_qtmesemp   IN crappre.qtmesemp%TYPE --> Tempo do fundacao da empresa
                          ,pr_dslstali   IN crappre.dslstali%TYPE --> Lista com codigos de alineas de devolucao de cheque
                          ,pr_qtdevolu   IN crappre.qtdevolu%TYPE --> Quantidade de devolucoes de cheque
                          ,pr_qtdiadev   IN crappre.qtdiadev%TYPE --> Quantidade de dias para calc. devolucao de cheque
                          ,pr_qtctaatr   IN crappre.qtctaatr%TYPE --> Quantidade de dias de conta corrente em atraso
                          ,pr_qtepratr   IN crappre.qtepratr%TYPE --> Quantidade de dias de emprestimo em atraso
                          ,pr_qtestour   IN crappre.qtestour%TYPE --> Quantidade de estouros de conta
                          ,pr_qtdiaest   IN crappre.qtdiaest%TYPE --> Quantidade de dias para calc. estouro de conta
                          ,pr_qtavlatr   IN crappre.qtavlatr%TYPE  --> Opera��es como avalista Quantidade de dias em atraso
                          ,pr_vlavlatr   IN crappre.vlavlatr%TYPE --> Opera��es como avalista Valor em atraso
                          ,pr_qtavlope   IN crappre.qtavlope%TYPE  --> Opera��es como avalista Quantidade de opera��es em atraso
                          ,pr_qtcjgatr   IN crappre.qtcjgatr%TYPE  --> Conjuge Quantidade de dias em atraso
                          ,pr_vlcjgatr   IN crappre.vlcjgatr%TYPE  --> Conjuge Valor em atraso
                          ,pr_qtcjgope   IN crappre.qtcjgope%TYPE  --> Conjuge Quantidade de opera��es em atraso 
                          ,pr_flgconsu   IN NUMBER                --> Flag para consulta
                          ,pr_xmllog     IN VARCHAR2              --> XML com informa��es de LOG
                          ,pr_cdcritic  OUT PLS_INTEGER          --> C�digo da cr�tica
                          ,pr_dscritic  OUT VARCHAR2             --> Descri��o da cr�tica
                          ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_consultar_carga (pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_busca_carga_ativa (pr_cdcooper  IN tbepr_carga_pre_aprv.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_nrdconta  IN crapcpa.nrdconta%TYPE                 --> Numero da conta
                                 ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE);   --> Codigo da carga
  
  PROCEDURE pc_exclui_carga_bloqueada (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_dscritic OUT VARCHAR2);                         --> Retorno de critica

  PROCEDURE pc_gerar_carga (pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  
   --> Procedimento para buscar dados do credito pr�-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_tab_dados_cpa OUT typ_tab_dados_cpa   --> Retorna dados do credito pre aprovado
                               ,pr_des_reto      OUT VARCHAR2            --> Retorno OK/NOK
                               ,pr_tab_erro      OUT gene0001.typ_tab_erro); --> Retorna os erros

  PROCEDURE pc_busca_dados_cpa_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                    ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                    ,pr_idorigem  IN INTEGER                  --> Id origem
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                                    ,pr_clob_cpa  OUT VARCHAR2            --> Retorna dados do credito pre aprovado
                                    ,pr_des_reto  OUT VARCHAR2            --> Retorno OK/NOK
                                    ,pr_clob_erro OUT VARCHAR2);              --> Retorna os erros
  
  PROCEDURE pc_busca_alinea(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_altera_carga(pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                           ,pr_acao     IN VARCHAR2                          --> Acao: B-Bloquear / L-Liberar
                           ,pr_xmllog   IN VARCHAR2                          --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                      --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2                         --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_inclui_carga (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                            ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE  --> Codigo da Carga
                            ,pr_dscritic OUT VARCHAR2);                         --> Retorno de critica

  PROCEDURE pc_limpeza_diretorio(pr_nmdireto IN VARCHAR2      --> Diretorio para limpeza
                                ,pr_dscritic OUT VARCHAR2);   --> Retorno de critica
                               
  -- Buscar as linhas de cr�dito.
  PROCEDURE pc_busca_linha_credito_prog(pr_cdcooper  IN crapcop.cdcooper%TYPE              --> Diretorio para limpeza
                                       ,pr_inpessoa  IN crapass.inpessoa%TYPE DEFAULT NULL --> Tipo de pessoa
                                       ,pr_cdrisco   IN craplcr.cdlcremp%TYPE DEFAULT NULL --> Codigo do risco
                                       ,pr_lslcremp OUT VARCHAR2                           --> Cdigos dos riscos
                                       ,pr_dscritic OUT VARCHAR2);                         --> Descricao da critica
  
  -- Busca per�odo de bloqueio de limite por refinanceamento.
  PROCEDURE pc_busca_periodo_bloq_refin(pr_inpessoa IN crappre.inpessoa%TYPE --> Tipo de pessoa
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                       ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  
  -- Mantem status do pre aprovado do cooperado
  PROCEDURE pc_mantem_param_conta (pr_cdcooper              IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta              IN crapass.nrdconta%TYPE
                                  ,pr_flgrenli              IN crapass.flgrenli%TYPE
                                  ,pr_flglibera_pre_aprv    IN NUMBER
                                  ,pr_dtatualiza_pre_aprv   IN DATE DEFAULT SYSDATE
                                  ,pr_idmotivo              IN NUMBER DEFAULT 0
                                  ,pr_cdoperad              IN VARCHAR2
                                  ,pr_idorigem              IN VARCHAR2
                                  ,pr_nmdatela              IN VARCHAR2
                                  ,pr_dtmvtolt              IN DATE
                                  ,pr_dscritic             OUT VARCHAR2             --> Descri��o da cr�tica
                                  ,pr_des_erro             OUT VARCHAR2);           --> Erros do processo

  -- Bloqueio de limite do pre aprovado por refinanceamento.
  PROCEDURE pc_bloqueia_pre_aprv_por_refin(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do cooperado
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                          ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
  
  -- Habilitar as contas bloqueadas por refinanciamento
  PROCEDURE pc_habilita_contas_suspensas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Conta do cooperado
                                        ,pr_inpessoa IN crappre.inpessoa%TYPE --> Tipo de pessoa
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_dscritic OUT VARCHAR2);           --> Descri��o da cr�tica

  -- Gerar tabela de historico dos bens das propostas de emprestimos. - JOB 
  PROCEDURE pc_carga_hist_bpr(pr_cdcooper IN crapcop.cdcooper%TYPE); --> Codigo da cooperativa

  -- Gerar a tabela de posi��o di�ria do pr�-aprovado e contratos. - JOB   (M441)
  PROCEDURE pc_carga_pos_diaria_epr ( pr_cdcooper       IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                     ,pr_qtddias_blq    IN NUMBER    --> Quantidade de dias bloqueado limite pr�-aprovado na TBERP_PARAM_CONTA
                                     ,pr_qtdias_manter  IN NUMBER);  --> Quantidade de dias para manter a tabela TBEPR_POS_DIARIA_CPA
                                   
  -- Consulta informa��es da carga vigente do associado para trazer na tela ATENDA/DEP.A VISTA/PRINCIPAL (M441)
  PROCEDURE pc_consultar_carga_vig_ass      ( pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                             ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencial do titular
                                             ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --> CPF do operador juridico
                                             ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
--											                       ,pr_des_reto OUT VARCHAR2             --> retorno (OK/NOK)
                                             ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                             ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                             ,pr_des_erro OUT VARCHAR2);
 
  -- M441 - Melhoria Pr�-Aprovado
  -- Gerar as informa��es de limite/carga vigente na crapsda
  -- Esta procedure ser� chamada no final da gera��o da crapsda (pc_cprs0001)
  -- Estas informa��es ser�o apresentadas na tela ATENDA > DEP�SITOS A VISTA > aba "Saldos Anteriores" 
  PROCEDURE pc_gerar_carga_vig_crapsda ( pr_cdcooper       IN crapcop.cdcooper%TYPE --> C�digo da cooperativa (0-processa todas)
                                        ,pr_DTMVTOLT       IN crapsda.dtmvtolt%type --> Data do movimento
                                        ,pr_dscritic      OUT VARCHAR2); 
                                    
   
    -- M441 - Melhoria Pr�-Aprovado
  -- Procedure para executar pc_crps682.
  -- Esta procedure ser� executada via JOB aos domingos.
  PROCEDURE pc_executar_crps682 (pr_cdcritic OUT PLS_INTEGER     --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2);      --> Descri��o da cr�tica
                                    
  -- Function para buscar os cooperados com cr�dito pr�-aprovado ativo - Utilizada para envio de Notifica��es/Push
  FUNCTION fn_sql_contas_com_preaprovado RETURN CLOB;
  
  --> Procedimento para validar dados do credito pr�-aprovado (crapcpa)
  PROCEDURE pc_valida_dados_cpa ( pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                 ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                 ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                 ,pr_idorigem  IN INTEGER                  --> Id origem
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                 ,pr_vlemprst  IN crapepr.vlemprst%TYPE    --> Valor do emprestimo
                                 ,pr_diapagto  IN INTEGER                  --> Dia de pagamento
                                 ,pr_nrcpfope  IN NUMBER                   --> CPF do operador
                                 ,pr_cdcritic OUT NUMBER                   --> Retorna codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                 --> Retorna descri��o da critica
                                 );
                                                     
  END EMPR0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0002 AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0002
  --  Sistema  : Rotinas referentes a tela CADPRE
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando - CECRED
  --  Data     : Junho - 2014.                   Ultima atualizacao: 13/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela CADPRE
  --
  -- Alteracoes: 13/11/2015 - Ajustado leitura na CRAPOPE incluindo upper (Odirlei-AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT cdcooper
        ,nmrescop
        ,vlmaxleg
    FROM crapcop 
   WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  /* Mostrar o texto dos motivos na tela de acordo com o ocorrido. */
  FUNCTION fn_busca_motivo(pr_idmotivo IN tbgen_motivo.idmotivo%TYPE) RETURN VARCHAR2 IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_busca_motivo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Lombardi
    --  Data     : Outubro/2016.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Mostrar o texto dos motivos na tela de acordo com o ocorrido.
    --
    --   Alteracoes: 
    -- .............................................................................

    DECLARE
      -- Efetuar a busca da descri��o na tabela
      CURSOR cr_tbgen_motivo IS
        SELECT mot.dsmotivo
          FROM tbgen_motivo mot
         WHERE mot.idmotivo = pr_idmotivo;
      vr_dsmotivo tbgen_motivo.dsmotivo%TYPE;
    BEGIN
      -- Busca descri��o da critica cfme par�metro passado
      OPEN cr_tbgen_motivo;
      FETCH cr_tbgen_motivo
       INTO vr_dsmotivo;
      -- Se n�o encontrou nenhum registro
      IF cr_tbgen_motivo%NOTFOUND THEN
        -- Montar descri��o padr�o
        vr_dsmotivo := pr_idmotivo || ' - Critica nao cadastrada!';
      END IF;
      -- Apenas fechar o cursor
      CLOSE cr_tbgen_motivo;
      -- Retornar a string montada
      RETURN vr_dsmotivo;
    END;
  END fn_busca_motivo;
  
  PROCEDURE pc_valida_operador(pr_cdcooper  IN crapope.cdcooper%TYPE --> Codigo da Carga
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Descri��o da cr�tica
                              ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
  BEGIN

    /* .............................................................................

     Programa: pc_valida_operador
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Valida o operador.

     Alteracoes: 29/11/2016 - P341 - Automatiza��o BACENJUD - Alterado para validar o departamento � partir
                              do c�digo e n�o mais pela descri��o (Renato Darosci - Supero)

     ..............................................................................*/ 
    DECLARE
      -- Busca o operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT cddepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Variaveis
      vr_blnfound BOOLEAN;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
     
    BEGIN
      -- Buscar Dados do Operador
      OPEN cr_crapope (pr_cdcooper => pr_cdcooper
                      ,pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapope%FOUND;
      -- Fecha cursor
      CLOSE cr_crapope;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 67;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;

      -- Somente o departamento credito ir� ter acesso para alterar as informacoes
      IF rw_crapope.cddepart NOT IN (14,20) THEN
        vr_cdcritic := 36;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
    END;
    
  END pc_valida_operador;

  /* Rotina referente as acoes da tela CADPRE */
  PROCEDURE pc_tela_cadpre(pr_cddopcao   IN VARCHAR2               --> Tipo de acao que sera executada (C - Consulta / A - Alteracao)
                          ,pr_inpessoa   IN crappre.inpessoa%TYPE  --> Codigo do tipo de pessoa
                          ,pr_nrmcotas   IN crappre.nrmcotas%TYPE  --> Numero de vezes que as cotas serao multiplicadas
                          ,pr_vllimite_a IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco A
                          ,pr_vllimite_b IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco B
                          ,pr_vllimite_c IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco C
                          ,pr_vllimite_d IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco D
                          ,pr_vllimite_e IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco E
                          ,pr_vllimite_f IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco F
                          ,pr_vllimite_g IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco G
                          ,pr_vllimite_h IN tbepr_linha_pre_aprv.vllimite%TYPE  --> Limite contas risco H
                          ,pr_cdlcremp_a IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco A
                          ,pr_cdlcremp_b IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco B
                          ,pr_cdlcremp_c IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco C
                          ,pr_cdlcremp_d IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco D
                          ,pr_cdlcremp_e IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco E
                          ,pr_cdlcremp_f IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco F
                          ,pr_cdlcremp_g IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco G
                          ,pr_cdlcremp_h IN tbepr_linha_pre_aprv.cdlcremp%TYPE  --> Limite contas risco H
                          ,pr_dssitdop   IN crappre.dssitdop%TYPE  --> Situa��o das Contas separados por (;)
                          ,pr_nrrevcad   IN crappre.nrrevcad%TYPE  --> Numero de meses da revisao cadastral
                          ,pr_vllimmin   IN crappre.vllimmin%TYPE  --> Limite minimo
                          ,pr_vlpercom   IN crappre.vlpercom%TYPE  --> Porcentagem de comprometimento da Renda
                          ,pr_qtdiaver   IN crappre.qtdiaver%TYPE  --> Porcentagem de comprometimento da Renda
                          ,pr_vlmaxleg   IN crappre.vlmaxleg%TYPE  --> Porcentagem de Valor Maximo Legal
                          ,pr_qtmesblq   IN crappre.qtmesblq%TYPE  --> Porcentagem de Valor Maximo Legal
                          ,pr_vllimctr   IN crappre.vllimctr%TYPE  --> Limite minimo para contratacao
                          ,pr_vlmulpli   IN crappre.vlmulpli%TYPE  --> Valor multiplo
                          ,pr_cdfinemp   IN crappre.cdfinemp%TYPE  --> Codigo da Finalidade
                          ,pr_qtmescta   IN crappre.qtmescta%TYPE  --> Tempo de abertura da conta
                          ,pr_qtmesadm   IN crappre.qtmesadm%TYPE  --> Tempo de admissao no emprego atual
                          ,pr_qtmesemp   IN crappre.qtmesemp%TYPE  --> Tempo do fundacao da empresa
                          ,pr_dslstali   IN crappre.dslstali%TYPE  --> Lista com codigos de alineas de devolucao de cheque
                          ,pr_qtdevolu   IN crappre.qtdevolu%TYPE  --> Quantidade de devolucoes de cheque
                          ,pr_qtdiadev   IN crappre.qtdiadev%TYPE  --> Quantidade de dias para calc. devolucao de cheque
                          ,pr_qtctaatr   IN crappre.qtctaatr%TYPE  --> Quantidade de dias de conta corrente em atraso
                          ,pr_qtepratr   IN crappre.qtepratr%TYPE  --> Quantidade de dias de emprestimo em atraso
                          ,pr_qtestour   IN crappre.qtestour%TYPE  --> Quantidade de estouros de conta
                          ,pr_qtdiaest   IN crappre.qtdiaest%TYPE  --> Quantidade de dias para calc. estouro de conta
                          ,pr_qtavlatr   IN crappre.qtavlatr%TYPE  --> Opera��es como avalista Quantidade de dias em atraso
                          ,pr_vlavlatr   IN crappre.vlavlatr%TYPE --> Opera��es como avalista Valor em atraso
                          ,pr_qtavlope   IN crappre.qtavlope%TYPE  --> Opera��es como avalista Quantidade de opera��es em atraso
                          ,pr_qtcjgatr   IN crappre.qtcjgatr%TYPE  --> Conjuge Quantidade de dias em atraso
                          ,pr_vlcjgatr   IN crappre.vlcjgatr%TYPE  --> Conjuge Valor em atraso
                          ,pr_qtcjgope   IN crappre.qtcjgope%TYPE  --> Conjuge Quantidade de opera��es em atraso 
                          ,pr_flgconsu   IN NUMBER                 --> Flag para consulta
                          ,pr_xmllog     IN VARCHAR2               --> XML com informa��es de LOG
                          ,pr_cdcritic  OUT PLS_INTEGER           --> C�digo da cr�tica
                          ,pr_dscritic  OUT VARCHAR2              --> Descri��o da cr�tica
                          ,pr_retxml     IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                          ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                          ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_tela_cadpre
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Junho/14.                    Ultima atualizacao: 08/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela CADPRE.

     Observacao: -----

     Alteracoes: 01/10/2014 - Somente permitir alterar os parametros caso o departamento
                              do operador for "PRODUTOS". (James)

                 08/01/2016 - Inclusao/Exclusao de campos PRJ261 - Pre-Aprovado fase II.
                              (Jaison/Anderson)

                 07/07/2016 - Inclusao/Exclusao de campos PRJ299 - Pre-Aprovado fase III.
                              (Lombardi)

     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crappre(pr_cdcooper IN crappre.cdcooper%TYPE
                       ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
        SELECT inpessoa, nrmcotas, dssitdop, nrrevcad, vllimmin,
               vlpercom, qtdiaver, vlmaxleg, qtmesblq, vllimctr,
               vlmulpli, cdfinemp, cdlcremp, qtmescta, qtmesadm,
               qtmesemp, dslstali, qtdevolu, qtdiadev, qtctaatr,
               qtepratr, qtestour, qtdiaest, qtavlatr, vlavlatr,
               qtavlope, qtcjgatr, vlcjgatr, qtcjgope
          FROM crappre 
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;

      -- Selecionar os dados da Finalidade
      CURSOR cr_crapfin (pr_cdcooper IN crapfin.cdcooper%TYPE
                        ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT cdfinemp
            ,dsfinemp
            ,flgstfin
        FROM crapfin 
       WHERE cdcooper = pr_cdcooper
         AND cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;

      -- Selecionar os dados da Linha de Credito
      CURSOR cr_craplcr (pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT cdlcremp
            ,dslcremp
            ,flgstlcr
        FROM craplcr 
       WHERE cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Verifica se a Linha de Credito pertence a Finalidade
      CURSOR cr_craplch (pr_cdcooper IN craplch.cdcooper%TYPE
                        ,pr_cdfinemp IN craplch.cdfinemp%TYPE
                        ,pr_cdlcrhab IN craplch.cdlcrhab%TYPE) IS
      SELECT cdfinemp
        FROM craplch 
       WHERE cdcooper = pr_cdcooper
         AND cdfinemp = pr_cdfinemp
         AND cdlcrhab = pr_cdlcrhab;
      rw_craplch cr_craplch%ROWTYPE;

      -- Verifica a ultima carga gerada bloqueada
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE
                      ,pr_inpessoa IN NUMBER) IS
        SELECT NVL(carga.vltotal_pre_aprv_pf,0) +
               NVL(carga.vltotal_pre_aprv_pj,0) vlsomado
          FROM tbepr_carga_pre_aprv carga 
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga = 1 -- Gerada
           AND carga.flgcarga_bloqueada = 1 -- Bloqueada
           AND ROWNUM = 1
        ORDER BY carga.idcarga DESC;
      
      CURSOR cr_riscos(pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE
                      ,pr_inpessoa IN NUMBER) IS
        SELECT ris.dsrisco
              ,nvl(epr.vllimite,0) vllimite
              ,nvl(epr.cdlcremp,0) cdlcremp
              ,lcr.dslcremp
              ,lcr.txmensal
          FROM (SELECT LEVEL AS cdrisco
                       ,decode(level
                               ,1,'AA'
                               ,2,'A'
                               ,3,'B'
                               ,4,'C'
                               ,5,'D'
                               ,6,'E'
                               ,7,'F'
                               ,8,'G'
                               ,9,'H'
                               ,10,'HH') as dsrisco
                   FROM dual
                  WHERE LEVEL NOT IN (1,10)
                CONNECT BY LEVEL <= 10) ris
      LEFT JOIN tbepr_linha_pre_aprv epr
             ON epr.cdrisco = ris.cdrisco
            AND epr.cdcooper = pr_cdcooper
            AND epr.inpessoa = pr_inpessoa
      LEFT JOIN craplcr lcr
             ON lcr.cdcooper = epr.cdcooper
            AND lcr.cdlcremp = epr.cdlcremp ORDER BY dsrisco;
      
      CURSOR cr_risco(pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE
                     ,pr_inpessoa IN NUMBER
                     ,pr_dsrisco  IN VARCHAR2) IS      
        SELECT cdrisco
          FROM tbepr_linha_pre_aprv 
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND cdrisco = decode(pr_dsrisco,'AA',1
                                           ,'A',2
                                           ,'B',3
                                           ,'C',4
                                           ,'D',5
                                           ,'E',6
                                           ,'F',7
                                           ,'G',8
                                           ,'H',9
                                           ,'HH',10);
      rw_risco cr_risco%ROWTYPE;
      
      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_null          EXCEPTION;

      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      vr_vlmaximo      crapcop.vlmaxleg%TYPE; --> Valor Maximo Legal
      vr_dtaltcad      VARCHAR2(20);          --> Data de alteracao do cadastro
      vr_dsclinha      VARCHAR2(4000);        --> Linha a ser inserida no LOG
      vr_dsdireto      VARCHAR2(400);         --> Diret�rio do arquivo de LOG
      vr_utlfileh      utl_file.file_type;    --> Handle para arquivo de LOG
      vr_vlsomado      NUMBER;                --> Valor total calculado
      vr_contador      NUMBER;                --> Contador auxiliar
      vr_vllimite      NUMBER(15,2);
      vr_cdlcremp      NUMBER;

      BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF pr_cddopcao = 'A' THEN
          
          -- Valida o operador
          EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
          -- Se possui critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
           
        END IF;

        -- Cursor com os dados da Regra
        OPEN cr_crappre(pr_cdcooper => vr_cdcooper
                       ,pr_inpessoa => pr_inpessoa);
        FETCH cr_crappre 
         INTO rw_crappre;

        -- Se nao encontrar
        IF cr_crappre%NOTFOUND THEN
          -- Fecha o cursor
          CLOSE cr_crappre;
          vr_dscritic := 'Regra nao encontrada.';
          RAISE vr_exc_saida;
        END IF;

        -- Fecha o cursor
        CLOSE cr_crappre;

        -- Busca cooperativa
        OPEN cr_crapcop(vr_cdcooper);
        FETCH cr_crapcop 
         INTO rw_crapcop;

        -- Fecha o cursor
        CLOSE cr_crapcop;

        vr_vlmaximo := (rw_crapcop.vlmaxleg * (rw_crappre.vlmaxleg / 100));

        -- Criar cabe�alho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crappre.inpessoa, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrmcotas', pr_tag_cont => rw_crappre.nrmcotas, pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'riscos', pr_tag_cont => '', pr_des_erro => vr_dscritic);
        
        vr_contador := 0;
        FOR rw_riscos IN cr_riscos(vr_cdcooper, pr_inpessoa) LOOP
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'riscos', pr_posicao => 0, pr_tag_nova => 'risco', pr_tag_cont => '', pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'risco', pr_posicao => vr_contador, pr_tag_nova => 'dsrisco',  pr_tag_cont => rw_riscos.dsrisco,  pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'risco', pr_posicao => vr_contador, pr_tag_nova => 'vllimite', pr_tag_cont => rw_riscos.vllimite, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'risco', pr_posicao => vr_contador, pr_tag_nova => 'cdlcremp', pr_tag_cont => rw_riscos.cdlcremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'risco', pr_posicao => vr_contador, pr_tag_nova => 'dslcremp', pr_tag_cont => rw_riscos.dslcremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'risco', pr_posicao => vr_contador, pr_tag_nova => 'txmensal', pr_tag_cont => rw_riscos.txmensal, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;
        END LOOP;
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dssitdop', pr_tag_cont => rw_crappre.dssitdop, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrrevcad', pr_tag_cont => rw_crappre.nrrevcad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimmin', pr_tag_cont => rw_crappre.vllimmin, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlpercom', pr_tag_cont => rw_crappre.vlpercom, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaver', pr_tag_cont => rw_crappre.qtdiaver, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmaxleg', pr_tag_cont => rw_crappre.vlmaxleg, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmesblq', pr_tag_cont => rw_crappre.qtmesblq, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmaximo', pr_tag_cont => vr_vlmaximo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimctr', pr_tag_cont => rw_crappre.vllimctr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmulpli', pr_tag_cont => rw_crappre.vlmulpli, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crappre.cdfinemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdlcremp', pr_tag_cont => rw_crappre.cdlcremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmescta', pr_tag_cont => rw_crappre.qtmescta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmesadm', pr_tag_cont => rw_crappre.qtmesadm, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmesemp', pr_tag_cont => rw_crappre.qtmesemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dslstali', pr_tag_cont => rw_crappre.dslstali, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdevolu', pr_tag_cont => rw_crappre.qtdevolu, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiadev', pr_tag_cont => rw_crappre.qtdiadev, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtctaatr', pr_tag_cont => rw_crappre.qtctaatr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtepratr', pr_tag_cont => rw_crappre.qtepratr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtestour', pr_tag_cont => rw_crappre.qtestour, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaest', pr_tag_cont => rw_crappre.qtdiaest, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtavlatr', pr_tag_cont => rw_crappre.qtavlatr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlavlatr', pr_tag_cont => rw_crappre.vlavlatr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtavlope', pr_tag_cont => rw_crappre.qtavlope, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcjgatr', pr_tag_cont => rw_crappre.qtcjgatr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlcjgatr', pr_tag_cont => rw_crappre.vlcjgatr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtcjgope', pr_tag_cont => rw_crappre.qtcjgope, pr_des_erro => vr_dscritic);

        -- Cursor com o valor total gerado
        OPEN cr_carga(pr_cdcooper => vr_cdcooper
                     ,pr_inpessoa => pr_inpessoa);
        FETCH cr_carga INTO vr_vlsomado;
        CLOSE cr_carga;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlsomado', pr_tag_cont => vr_vlsomado, pr_des_erro => vr_dscritic);

        -- Cursor com os dados da Finalidade
        OPEN cr_crapfin(pr_cdcooper => vr_cdcooper
                       ,pr_cdfinemp => rw_crappre.cdfinemp);
        FETCH cr_crapfin INTO rw_crapfin;
        CLOSE cr_crapfin;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsfinemp', pr_tag_cont => rw_crapfin.dsfinemp, pr_des_erro => vr_dscritic);

        -- Cursor com os dados da Linha de Credito
        OPEN cr_craplcr(pr_cdlcremp => rw_crappre.cdlcremp);
        FETCH cr_craplcr INTO rw_craplcr;
        CLOSE cr_craplcr;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dslcremp', pr_tag_cont => rw_craplcr.dslcremp, pr_des_erro => vr_dscritic);

        -- Efetua a manipula��o do registro
        IF pr_flgconsu = 0 THEN

          -- Cursor com os dados da Finalidade
          OPEN cr_crapfin(pr_cdcooper => vr_cdcooper
                         ,pr_cdfinemp => pr_cdfinemp);
          FETCH cr_crapfin 
           INTO rw_crapfin;

          -- Se nao encontrar
          IF cr_crapfin%NOTFOUND THEN
            -- Fecha o cursor
            CLOSE cr_crapfin;
            vr_cdcritic := 362;
            RAISE vr_exc_saida;
          ELSE
            -- Fecha o cursor
            CLOSE cr_crapfin;
            -- Se a Finalidade estiver bloqueada
            IF rw_crapfin.flgstfin = 0 THEN
              vr_cdcritic := 469;
              RAISE vr_exc_saida;
            END IF;
          END IF;

          FOR vr_risco IN 1..8 LOOP
            CASE vr_risco
                    WHEN 1 THEN 
                      vr_cdlcremp := pr_cdlcremp_a;
                    WHEN 2 THEN 
                      vr_cdlcremp := pr_cdlcremp_b;
                    WHEN 3 THEN 
                      vr_cdlcremp := pr_cdlcremp_c;
                    WHEN 4 THEN 
                      vr_cdlcremp := pr_cdlcremp_d;
                    WHEN 5 THEN 
                      vr_cdlcremp := pr_cdlcremp_e;
                    WHEN 6 THEN 
                      vr_cdlcremp := pr_cdlcremp_f;
                    WHEN 7 THEN 
                      vr_cdlcremp := pr_cdlcremp_g;
                    WHEN 8 THEN 
                      vr_cdlcremp := pr_cdlcremp_h;
            END CASE;
            IF vr_cdlcremp > 0 THEN
          -- Cursor com os dados da Linha de Credito
              OPEN cr_craplcr(pr_cdlcremp => vr_cdlcremp);
          FETCH cr_craplcr 
           INTO rw_craplcr;

          -- Se nao encontrar
          IF cr_craplcr%NOTFOUND THEN
            -- Fecha o cursor
            CLOSE cr_craplcr;
            vr_dscritic := 'Linha de Credito nao cadastrada.';
            RAISE vr_exc_saida;
          ELSE
            -- Fecha o cursor
            CLOSE cr_craplcr;
            -- Se a Linha de Credito estiver bloqueada
            IF rw_craplcr.flgstlcr = 0 THEN
              vr_dscritic := 'Linha de Credito esta bloqueada.';
              RAISE vr_exc_saida;
            ELSE
              -- Verifica se a Linha de Credito pertence a Finalidade
              OPEN cr_craplch(pr_cdcooper => vr_cdcooper
                             ,pr_cdfinemp => pr_cdfinemp
                                 ,pr_cdlcrhab => vr_cdlcremp);
              FETCH cr_craplch 
               INTO rw_craplch;

              -- Se nao encontrar
              IF cr_craplch%NOTFOUND THEN
                -- Fecha o cursor
                CLOSE cr_craplch;
                vr_dscritic := 'Linha de Credito nao pertence a Finalidade escolhida.';
                RAISE vr_exc_saida;
              END IF;
              -- Fecha o cursor
              CLOSE cr_craplch;
            END IF;
          END IF;
          END IF;
          END LOOP;

          -- Alteracao
          IF pr_cddopcao = 'A' THEN

              BEGIN
                vr_dtaltcad := to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss');
                vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                    ,pr_cdcooper => vr_cdcooper
                                                    ,pr_nmsubdir => '/log');

                -- Abrir arquivo em modo de adi��o
                gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                                        ,pr_nmarquiv => 'cadpre.log'
                                        ,pr_tipabert => 'A'
                                        ,pr_utlfileh => vr_utlfileh
                                        ,pr_des_erro => vr_dscritic);

                -- Verifica se ocorreram erros
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;

                IF rw_crappre.cdfinemp <> pr_cdfinemp THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Codigo da Finalidade de ' 
                                 || rw_crappre.cdfinemp || ' para ' || pr_cdfinemp;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.nrmcotas <> pr_nrmcotas THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Multiplicar Cotas Capital de ' 
                                 || rw_crappre.nrmcotas || ' para ' || pr_nrmcotas;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.dssitdop <> pr_dssitdop THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Situacao das Contas de ' 
                                 || rw_crappre.dssitdop || ' para ' || pr_dssitdop;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtmescta <> pr_qtmescta THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Tempo de Conta de ' 
                                 || rw_crappre.qtmescta || ' para ' || pr_qtmescta;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtmesadm <> pr_qtmesadm THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Tempo Admissao Emprego Atual de ' 
                                 || rw_crappre.qtmesadm || ' para ' || pr_qtmesadm;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtmesemp <> pr_qtmesemp THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Tempo Fundacao Empresa de ' 
                                 || rw_crappre.qtmesemp || ' para ' || pr_qtmesemp;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.nrrevcad <> pr_nrrevcad THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Revisao Cadastral de ' 
                                 || rw_crappre.nrrevcad || ' para ' || pr_nrrevcad;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimmin <> pr_vllimmin THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Minimo Ofertado de ' 
                                 || rw_crappre.vllimmin || ' para ' || pr_vllimmin;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimctr <> pr_vllimctr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Minimo Contratacao de ' 
                                 || rw_crappre.vllimctr || ' para ' || pr_vllimctr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vlmulpli <> pr_vlmulpli THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Valores Multiplos de ' 
                                 || rw_crappre.vlmulpli || ' para ' || pr_vlmulpli;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vlpercom <> pr_vlpercom THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Comprometimento de Renda de ' 
                                 || rw_crappre.vlpercom || ' para ' || pr_vlpercom;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;


                IF rw_crappre.qtdiaver <> pr_qtdiaver THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Verificar operacoes inclusas de ' 
                                 || rw_crappre.qtdiaver || ' para ' || pr_qtdiaver;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                
                IF rw_crappre.vlmaxleg <> pr_vlmaxleg THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Multiplicar Valor Max. Legal de ' 
                                 || rw_crappre.vlmaxleg || ' para ' || pr_vlmaxleg;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                
                IF rw_crappre.qtmesblq <> pr_qtmesblq THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Per�odo de Bloqueio de Limite por Refinanciamento de ' 
                                 || rw_crappre.qtmesblq || ' para ' || pr_qtmesblq;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                -- dsrisco, vllimite, cdlcremp, dslcremp, txmensal
                FOR rw_riscos IN cr_riscos(vr_cdcooper, pr_inpessoa) LOOP
                  
                  vr_vllimite := 0.00;
                  vr_cdlcremp := 0;
                  
                  CASE rw_riscos.dsrisco
                    WHEN 'A' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_a THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco A de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_a;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_a THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_a;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_a;
                      vr_cdlcremp := pr_cdlcremp_a;

                    WHEN 'B' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_b THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco B de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_b;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_b THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_b;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_b;
                      vr_cdlcremp := pr_cdlcremp_b;

                    WHEN 'C' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_c THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco C de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_c;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_c THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_c;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_c;
                      vr_cdlcremp := pr_cdlcremp_c;

                    WHEN 'D' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_d THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco D de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_d;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_d THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_d;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_d;
                      vr_cdlcremp := pr_cdlcremp_d;

                    WHEN 'E' THEN
                      IF rw_riscos.vllimite <> pr_vllimite_e THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco E de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_e;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_e THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_e;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_e;
                      vr_cdlcremp := pr_cdlcremp_e;

                    WHEN 'F' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_f THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco F de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_f;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_f THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_f;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_f;
                      vr_cdlcremp := pr_cdlcremp_f;

                    WHEN 'G' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_g THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco G de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_g;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_g THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_g;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_g;
                      vr_cdlcremp := pr_cdlcremp_g;

                    WHEN 'H' THEN 
                      IF rw_riscos.vllimite <> pr_vllimite_h THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco H de ' 
                                       || rw_riscos.vllimite || ' para ' || pr_vllimite_h;
                        -- Gravar linha no arquivo
                        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                      ,pr_des_text => vr_dsclinha);
                      END IF;
                      IF rw_riscos.cdlcremp <> pr_cdlcremp_h THEN
                        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                       || ' alterou o campo Codigo da Linha Credito de ' 
                                       || rw_riscos.cdlcremp || ' para ' || pr_cdlcremp_h;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                      vr_vllimite := pr_vllimite_h;
                      vr_cdlcremp := pr_cdlcremp_h;
                      
                  END CASE;
                  
                  IF rw_riscos.vllimite <> vr_vllimite OR
                     rw_riscos.cdlcremp <> vr_cdlcremp THEN
                    
                    OPEN cr_risco(pr_cdcooper => vr_cdcooper
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_dsrisco  => rw_riscos.dsrisco);
                    FETCH cr_risco INTO rw_risco;
                    IF cr_risco%FOUND THEN
                      IF vr_vllimite > 0 THEN
                        BEGIN
                          UPDATE tbepr_linha_pre_aprv
                             SET vllimite = vr_vllimite
                                ,cdlcremp = vr_cdlcremp
                           WHERE cdcooper = vr_cdcooper
                             AND inpessoa = pr_inpessoa
                             AND cdrisco  = rw_risco.cdrisco;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Problema ao atualizar limite de risco ' || rw_riscos.dsrisco || ': ' || sqlerrm;
                            RAISE vr_exc_saida;
                        END;
                      ELSE
                        BEGIN
                          DELETE FROM tbepr_linha_pre_aprv
                           WHERE cdcooper = vr_cdcooper
                             AND inpessoa = pr_inpessoa
                             AND cdrisco  = rw_risco.cdrisco;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Problema ao deletar limite de risco ' || rw_riscos.dsrisco || ': ' || sqlerrm;
                            RAISE vr_exc_saida;
                        END;
                      END IF;
                    ELSE
                      IF vr_vllimite > 0 THEN
                        BEGIN
                          INSERT INTO tbepr_linha_pre_aprv
                                 (idlinha,cdcooper,inpessoa,cdrisco,vllimite,cdlcremp)
                          VALUES (nvl((SELECT MAX(pre.idlinha) FROM tbepr_linha_pre_aprv pre),0) + 1
                                 ,vr_cdcooper,pr_inpessoa,decode(rw_riscos.dsrisco,'AA',1
                                 ,'A',2,'B',3,'C',4,'D',5,'E',6,'F',7,'G',8,'H',9,'HH',10)
                                 ,vr_vllimite,vr_cdlcremp);
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Problema ao criar limite de risco ' || rw_riscos.dsrisco || ': ' || sqlerrm;
                            RAISE vr_exc_saida;
                        END;
                      END IF;
                    END IF;
                    CLOSE cr_risco;
                  END IF;
                END LOOP;

                IF rw_crappre.dslstali <> pr_dslstali THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Alineas de Devolucoes de ' 
                                 || rw_crappre.dslstali || ' para ' || pr_dslstali;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtdevolu <> pr_qtdevolu THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Quantidade de devolucoes de ' 
                                 || rw_crappre.qtdevolu || ' para ' || pr_qtdevolu;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtdiadev <> pr_qtdiadev THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Periodo de devolucoes de ' 
                                 || rw_crappre.qtdiadev || ' para ' || pr_qtdiadev;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtctaatr <> pr_qtctaatr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Conta Corrente em Atraso de ' 
                                 || rw_crappre.qtctaatr || ' para ' || pr_qtctaatr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtepratr <> pr_qtepratr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Emprestimo em Atraso de ' 
                                 || rw_crappre.qtepratr || ' para ' || pr_qtepratr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtestour <> pr_qtestour THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Quantidade de Estouro de ' 
                                 || rw_crappre.qtestour || ' para ' || pr_qtestour;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtdiaest <> pr_qtdiaest THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Periodo de Estouro de ' 
                                 || rw_crappre.qtdiaest || ' para ' || pr_qtdiaest;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtavlatr <> pr_qtavlatr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Qtd. dias em Atraso em Operacoes como Avalista de ' 
                                 || rw_crappre.qtavlatr || ' para ' || pr_qtavlatr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                

                IF rw_crappre.vlavlatr <> pr_vlavlatr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Valor em Atraso em Operacoes como Avalista de ' 
                                 || rw_crappre.vlavlatr || ' para ' || pr_vlavlatr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                

                IF rw_crappre.qtavlope <> pr_qtavlope THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Qtd. Operacoes em Atraso em Operacoes como Avalista  de ' 
                                 || rw_crappre.qtavlope || ' para ' || pr_qtavlope;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                

                IF rw_crappre.qtcjgatr <> pr_qtcjgatr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Qtd. dias em Atraso em Operacoes de Conjuge de ' 
                                 || rw_crappre.qtcjgatr || ' para ' || pr_qtcjgatr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                

                IF rw_crappre.vlcjgatr <> pr_vlcjgatr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Valor em Atraso em Operacoes de Conjuge de ' 
                                 || rw_crappre.vlcjgatr || ' para ' || pr_vlcjgatr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                

                IF rw_crappre.qtcjgope <> pr_qtcjgope THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Qtd. Operacoes em Atraso em Operacoes de Conjuge de ' 
                                 || rw_crappre.qtcjgope || ' para ' || pr_qtcjgope;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;
                
                -- Fechar arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

                UPDATE crappre SET 
                  cdfinemp = pr_cdfinemp, nrmcotas = pr_nrmcotas, dssitdop = pr_dssitdop,
                  qtmescta = pr_qtmescta, qtmesadm = pr_qtmesadm, qtmesemp = pr_qtmesemp, 
                  nrrevcad = pr_nrrevcad, vllimmin = pr_vllimmin, vllimctr = pr_vllimctr, 
                  vlmulpli = pr_vlmulpli, vlpercom = pr_vlpercom, qtdiaver = pr_qtdiaver,
                  vlmaxleg = pr_vlmaxleg, qtmesblq = pr_qtmesblq, 
                  dslstali = pr_dslstali, qtdevolu = pr_qtdevolu, qtdiadev = pr_qtdiadev, 
                  qtctaatr = pr_qtctaatr, qtepratr = pr_qtepratr, qtestour = pr_qtestour, 
                  qtdiaest = pr_qtdiaest, qtavlatr = pr_qtavlatr, vlavlatr = pr_vlavlatr, 
                  qtavlope = pr_qtavlope, qtcjgatr = pr_qtcjgatr, vlcjgatr = pr_vlcjgatr, 
                  qtcjgope = pr_qtcjgope
                WHERE cdcooper = vr_cdcooper
                  AND inpessoa = pr_inpessoa;

                COMMIT;

              EXCEPTION
                WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar Regra: ' || sqlerrm;
                RAISE vr_exc_saida;
              END;

          END IF;

        END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_tela_cadpre;
  
  PROCEDURE pc_consultar_carga (pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                               ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_consultar_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : James Prust Junior
     Data    : Junho/14.                    Ultima atualizacao: 11/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela CADPRE.

     Observacao: -----

     Alteracoes: 11/01/2016 - Reformulacao para buscar as cargas da tabela 
                              TBEPR_CARGA_PRE_APRV - Pre-Aprovado fase II.
                              (Jaison/Anderson)
                 24/03/2016 - Altera��o para trazer apenas as �ltimas 3 cargas,
                              sendo que entre elas, obrigatoriamente deve estar
                              a carga liberada.
                 07/07/2017 - Alterado para n�o buscar as cargas que estiverem
                              com bloqueio definitivo, isto �, cargas que j� estiveram
                              um dia liberadas por�m depois foram bloqueadas.
                              M441 - Melhorias Pr�-aprovado (Roberto Holz).

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga,
               TO_CHAR(carga.dtcalculo,'DD/MM/RRRR') dtcalculo,
               TO_CHAR(carga.dtcalculo,'HH24:MI:SS') hora,
               DECODE(carga.flgcarga_bloqueada,0,'Liberada','Bloqueada') situacao,
               CASE carga.indsituacao_carga
                 WHEN 1 THEN 'Gerada'
                 WHEN 2 THEN 'Solicitada'
                 WHEN 3 THEN 'Executando'
               END status,
               TO_CHAR(NVL(carga.vltotal_pre_aprv_pf,0) + 
                       NVL(carga.vltotal_pre_aprv_pj,0),'FM999G999G999G990D00') vltotal
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           /* Trazer as �ltimas tr�s cargas e entre elas tem que estar a carga liberada */
           AND carga.idcarga in (select idcarga
                                   from(
                                        SELECT epr.idcarga
                                          FROM tbepr_carga_pre_aprv epr
                                         WHERE epr.cdcooper = pr_cdcooper
                                           /* M441v1.1 - somente trazer a carga ativa e
                                              as bloqueadas que nunca foram liberadas algum dia  */
                                           and nvl(epr.flgbloq_definitivo,0) = 0
                                      ORDER BY epr.flgcarga_bloqueada, epr.dtcalculo DESC
                                       ) origem
                                   where rownum <= 3);
    
      -- Variaveis de log
      vr_cdcooper  NUMBER;
      vr_cdoperad  VARCHAR2(100);
      vr_nmdatela  VARCHAR2(100);
      vr_nmeacao   VARCHAR2(100);
      vr_cdagenci  VARCHAR2(100);
      vr_nrdcaixa  VARCHAR2(100);
      vr_idorigem  VARCHAR2(100);

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_dscritic VARCHAR2(10000);
      
      BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => pr_dscritic);
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        -- Busca as cargas
        FOR rw_carga IN cr_carga (pr_cdcooper => vr_cdcooper) LOOP
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'carga'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'idcarga'
                                ,pr_tag_cont => rw_carga.idcarga
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dtcalculo'
                                ,pr_tag_cont => rw_carga.dtcalculo
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'hora'
                                ,pr_tag_cont => rw_carga.hora
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'situacao'
                                ,pr_tag_cont => rw_carga.situacao
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'status'
                                ,pr_tag_cont => rw_carga.status
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'vltotal'
                                ,pr_tag_cont => rw_carga.vltotal
                                ,pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END LOOP;

      EXCEPTION        
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;
    
  END pc_consultar_carga;
  
  PROCEDURE pc_busca_carga_ativa (pr_cdcooper  IN tbepr_carga_pre_aprv.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_nrdconta  IN crapcpa.nrdconta%TYPE                 --> Numero da conta
                                 ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE) IS --> Codigo da carga
  BEGIN

    /* .............................................................................

     Programa: pc_busca_carga_ativa
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison
     Data    : Janeiro/2016                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Busca a carga ativa.

     Observacao: -----

     Alteracoes: 29/07/2016 - Inclusao do par�metro pr_nrdconta na chamada 
                              da procedure e alterado cursor cr_carga.

     ..............................................................................*/

    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.tpcarga
              ,carga.dtcalculo
              ,carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper           = pr_cdcooper
           AND carga.indsituacao_carga  = 1 -- Gerada
           AND carga.flgcarga_bloqueada = 0 -- Liberada
           AND carga.tpcarga            = 2 -- Autom�tica
           AND (carga.dtfinal_vigencia IS NULL
            OR  carga.dtfinal_vigencia >= TRUNC(SYSDATE))
           AND EXISTS (SELECT 1 -- Cargas que a conta est� relacionada
                         FROM crapcpa cpa
                        WHERE cpa.cdcooper = carga.cdcooper
                          AND cpa.nrdconta = pr_nrdconta
                          AND cpa.iddcarga = carga.idcarga)
         UNION
        SELECT carga.tpcarga
              ,carga.dtcalculo
              ,carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper           = 3
           AND carga.indsituacao_carga  = 1 -- Gerada
           AND carga.flgcarga_bloqueada = 0 -- Liberada
           AND carga.tpcarga            = 1 -- Manual
           AND (carga.dtfinal_vigencia IS NULL
            OR  carga.dtfinal_vigencia >= TRUNC(SYSDATE))
           AND EXISTS (SELECT 1 -- Cargas que a conta est� relacionada
                         FROM crapcpa cpa
                        WHERE cpa.cdcooper = pr_cdcooper
                          AND cpa.nrdconta = pr_nrdconta
                          AND cpa.iddcarga = carga.idcarga)
      ORDER BY tpcarga   ASC  -- Priorizar as cargas 1 - Manual
              ,dtcalculo DESC; -- Priorizar as cargas recentes
      rw_carga cr_carga%ROWTYPE;

      -- Variaveis
      vr_blnfound BOOLEAN;

    BEGIN
      -- Efetua a busca do registro
      OPEN cr_carga(pr_cdcooper => pr_cdcooper);
      FETCH cr_carga INTO rw_carga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se achou
      IF vr_blnfound THEN
        pr_idcarga := rw_carga.idcarga;
      ELSE
        pr_idcarga := 0;
      END IF;
    END;
    
  END pc_busca_carga_ativa;
  
  PROCEDURE pc_exclui_carga_bloqueada (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_dscritic OUT VARCHAR2) IS                       --> Retorno de critica

  BEGIN

    /* .............................................................................

     Programa: pc_exclui_carga_bloqueada
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Excluir as cargas bloqueadas.

     Alteracoes: 24/03/2016 - Altera��o para excluir apenas as cargas que possuem
                              mais do que 20 dias, para evitar que cargas sejam
                              exclu�das sem que tenham sido importadas no BI.
                              Obs.: Na interface ser� apresentada apenas as �ltimas
                              3 cargas. (Anderson Fossa).
                 10/07/2017 - Alterado para excluir tamb�m as cargas manuais pois a
                              op��o de Exclus�o de carga foi retirada da tela IMPPPRE.
                              M441 - Melhorias Pre-aprovado (Roberto Holz - Mouts)

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.cdcooper,carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           /* Vamos apagar apenas os registros que tenham mais do que 20 dias 
              para evitar apagar dados que ainda n�o foram importados para o BI */
           AND carga.dtcalculo <= trunc(sysdate - 20)
           AND carga.flgcarga_bloqueada = 1
           AND carga.tpcarga = 2 -- autom�tica
         UNION ALL
        SELECT carga.cdcooper,carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = 3 -- carga manual fixa 3
         -- eliminando cargas que j� foram ativas mas que j� foram bloqueadas a mais de 90 dias
           AND carga.dtfinal_vigencia <= trunc(sysdate - 90)
           AND carga.flgcarga_bloqueada = 1
           AND carga.flgbloq_definitivo = 1
           AND carga.tpcarga = 1 -- manual
         UNION ALL
        SELECT carga.cdcooper,carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = 3 -- carga manual fixa 3
         -- eliminando cargas que est�o bloqueadas e nunca foram liberadas e c�lculo foi a mais de 90 dias
           AND carga.dtcalculo <= trunc(sysdate - 90)
           AND carga.flgcarga_bloqueada = 1
           AND carga.flgbloq_definitivo = 0
           AND carga.tpcarga = 1; -- manual                    

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);
     
    BEGIN
      -- Percorre todas as cargas bloqueadas
      FOR rw_carga IN cr_carga(pr_cdcooper => pr_cdcooper) LOOP
        BEGIN
          -- Exclui os detalhes dos n�o aprovados (M441)
          DELETE 
            FROM TBEPR_CARGA_PRE_APRV_DET detalhe
           WHERE detalhe.cdcooper = rw_carga.cdcooper
             AND detalhe.idcarga = rw_carga.idcarga;          
          -- Exclui os motivos
          DELETE 
            FROM tbepr_motivo_nao_aprv motivo
           WHERE motivo.cdcooper = rw_carga.cdcooper
             AND motivo.idcarga = rw_carga.idcarga;
          -- Exclui os creditos
          DELETE 
            FROM crapcpa 
           WHERE crapcpa.cdcooper = rw_carga.cdcooper
             AND crapcpa.iddcarga = rw_carga.idcarga;
          -- Exclui a carga
          DELETE 
            FROM tbepr_carga_pre_aprv carga 
           WHERE carga.cdcooper = rw_carga.cdcooper
             AND carga.idcarga = rw_carga.idcarga;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir a Carga. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em tbepr_carga_pre_aprv: ' || SQLERRM;
    END;
    
  END pc_exclui_carga_bloqueada;
  
  PROCEDURE pc_gerar_carga (pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_gerar_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : James Prust Junior
     Data    : Junho/14.                    Ultima atualizacao: 12/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela CADPRE.

     Alteracoes: 26/11/2014 - Ajustado para somente permitir gerar a carga quando o departamento 
                              do usuario for Produtos ou TI. (James)

                 12/01/2016 - Reformulacao para gerar as cargas - Pre-Aprovado fase II.
                              (Jaison/Anderson)

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga,
               carga.indsituacao_carga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga IN (2,3); -- 2-Solicitada / 3�Executando
      rw_carga cr_carga%ROWTYPE;
    
      -- Vari�vel de cr�ticas
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper  NUMBER;
      vr_cdoperad  VARCHAR2(100);
      vr_nmdatela  VARCHAR2(100);
      vr_nmeacao   VARCHAR2(100);
      vr_cdagenci  VARCHAR2(100);
      vr_nrdcaixa  VARCHAR2(100);
      vr_idorigem  VARCHAR2(100);
      
      -- Variaveis de geracao
      vr_blnfound  BOOLEAN;
      vr_dsplsql   VARCHAR2(4000); -- Bloco PLSQL para chamar a execu��o paralela do pc_crps682
      vr_jobname   VARCHAR2(30);   -- Job name dos processos criados
      vr_idcarga   tbepr_carga_pre_aprv.idcarga%TYPE;
     
      BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => pr_dscritic);

        -- Valida o operador
        EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_dscritic => pr_dscritic);
        -- Se possui critica
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Efetua a busca do registro
        OPEN cr_carga(pr_cdcooper => vr_cdcooper);
        FETCH cr_carga INTO rw_carga;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_carga%FOUND;
        -- Fecha cursor
        CLOSE cr_carga;

        -- Se achou
        IF vr_blnfound THEN
          pr_dscritic := 'Gera��o n�o permitida, pois existe carga Solicitada ou Executando.';
          RAISE vr_exc_saida;
        END IF;

        -- Exclui as cargas bloqueadas
        EMPR0002.pc_exclui_carga_bloqueada (pr_cdcooper => vr_cdcooper
                                           ,pr_dscritic => pr_dscritic);
        -- Se possui critica
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Cria a carga
        EMPR0002.pc_inclui_carga (pr_cdcooper => vr_cdcooper
                                 ,pr_idcarga  => vr_idcarga
                                 ,pr_dscritic => pr_dscritic);
        -- Se possui critica
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        COMMIT;
        
        -- Chamar o JOB
        -- Montar o bloco PLSQL que ser� executado
        -- Ou seja, executaremos a gera��o dos dados
        -- para a ag�ncia atual atraves de Job no banco
        vr_dsplsql := 'DECLARE'||chr(13)
                   || '  vr_stprogra NUMBER;'||chr(13)
                   || '  vr_infimsol NUMBER;'||chr(13)
                   || '  vr_cdcritic NUMBER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)                   
                   || 'BEGIN'||chr(13)
                   || '  pc_crps682('||vr_cdcooper||',0,0,0,0,0,vr_stprogra,vr_infimsol,vr_cdcritic,vr_dscritic);'||chr(13)
                   || 'END;';
                   
        -- Montar o prefixo do c�digo do programa para o jobname
        vr_jobname := 'crps682_'||vr_cdcooper||'$';
        -- Faz a chamada ao programa paralelo atraves de JOB
        GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> C�digo da cooperativa
                              ,pr_cdprogra  => 'CRPS682'    --> C�digo do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva   => NULL         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exce�ao
          RAISE vr_exc_saida;
        END IF;
        
      EXCEPTION        
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas c�digo
          IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
            -- Buscar a descri��o
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
          END IF;
        
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;
    
  END pc_gerar_carga;

  --> Procedimento para buscar dados do credito pr�-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_tab_dados_cpa OUT typ_tab_dados_cpa   --> Retorna dados do credito pre aprovado
                               ,pr_des_reto      OUT VARCHAR2            --> Retorno OK/NOK
                               ,pr_tab_erro      OUT gene0001.typ_tab_erro) IS --> Retorna os erros

    /* .............................................................................

     Programa: pc_busca_dados_cpa        antigo: b1wgen0188.p/busca_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Odirlei Busana(AMcom)
     Data    : Outubro/2015.                    Ultima atualizacao: 13/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Procedimento para buscar dados do credito pr�-aprovado (crapcpa)

     Alteracoes: 19/10/2015 - Convers�o Progress -> Oracle (Odirlei/AMcom)

                 13/01/2016 - Verificacao de carga ativa - Pre-Aprovado fase II.
                              (Jaison/Anderson)

    ..............................................................................*/ 

    ---------------> CURSORES <-----------------

    -- Verifica se esta na tabela do pre-aprovado
    CURSOR cr_crapcpa (pr_cdcooper IN crapcpa.cdcooper%TYPE,
                       pr_nrdconta IN crapcpa.nrdconta%TYPE,
                       pr_idcarga  IN crapcpa.iddcarga%TYPE) IS
      SELECT cpa.vllimdis
            ,cpa.vlcalpre
            ,cpa.vlctrpre
            ,cpa.cdlcremp
        FROM crapcpa cpa
       WHERE cpa.cdcooper = pr_cdcooper
         AND cpa.nrdconta = pr_nrdconta
         AND cpa.iddcarga = pr_idcarga;
    rw_crapcpa cr_crapcpa%rowtype;

    CURSOR cr_carga_manual(pr_iddcarga IN crapcpa.iddcarga%TYPE) IS
      SELECT to_char(carga.dsmensagem_aviso) || ' Limite: R$ ' mensagem
        FROM tbepr_carga_pre_aprv carga 
       WHERE carga.idcarga = pr_iddcarga
         AND carga.tpcarga = 1 -- Manual
       ORDER BY carga.dtcalculo DESC;
    rw_carga_manual cr_carga_manual%ROWTYPE;
    
    CURSOR cr_param_conta (pr_cdcooper IN crapcpa.cdcooper%TYPE
                          ,pr_nrdconta IN crapcpa.nrdconta%TYPE) IS 
      SELECT conta.flglibera_pre_aprv
        FROM tbepr_param_conta conta
       WHERE conta.cdcooper  = pr_cdcooper
         AND conta.nrdconta  = pr_nrdconta;
    rw_param_conta cr_param_conta%ROWTYPE;
    
    --> Verifica se o associado pode obter o credido pre-aprovado
    CURSOR cr_crapass IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Verifica se esta bloqueado o pre-aprovado 
    CURSOR cr_crappre (pr_cdcooper IN crappre.cdcooper%TYPE,
                       pr_inpessoa IN crappre.inpessoa%TYPE)IS
      SELECT pre.cdcooper
            ,pre.vllimctr
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;     

    --> Buscar linha de credito
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%TYPE,
                       pr_cdlcremp craplcr.cdlcremp%TYPE)IS
      SELECT lcr.txmensal
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    ---------------> VARIAVEIS <----------------       

    --> Tratamento de erros
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);

    vr_idx       PLS_INTEGER;
    vr_idcarga   tbepr_carga_pre_aprv.idcarga%TYPE;
    vr_flgmanual BOOLEAN;
    vr_flgfound  BOOLEAN;

  BEGIN

    pr_tab_erro.delete;
    pr_tab_dados_cpa.delete;

    --> Somente o primeiro titular pode contratrar o pre-aprovado e nao 
    --  pode ser operador de conta juridica 
    IF pr_idseqttl > 1 OR pr_nrcpfope > 0 THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    -- Busca a carga ativa
    EMPR0002.pc_busca_carga_ativa(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idcarga  => vr_idcarga);
    --  Caso nao possua carga ativa
    IF vr_idcarga = 0 THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    --> Verifica se esta na tabela do pre-aprovado
    OPEN cr_crapcpa(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idcarga  => vr_idcarga);
    FETCH cr_crapcpa INTO rw_crapcpa;

    -- caso nao esteja, aborta com ok
    IF cr_crapcpa%NOTFOUND THEN
      CLOSE cr_crapcpa;
      pr_des_reto := 'OK';
      RETURN;  
    ELSE
      CLOSE cr_crapcpa;
    END IF; 

    --> Verifica se o associado pode obter o credido pre-aprovado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --> Associado nao cadastrado
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Na tela de contas nao podemos verificar a flag 
    IF pr_nmdatela <> 'CONTAS' THEN
      
      --> Verifica se esta o pre-aprovado esta liberado
      OPEN cr_param_conta(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
      FETCH cr_param_conta INTO rw_param_conta;
      vr_flgfound := cr_param_conta%FOUND;
      CLOSE cr_param_conta;
      
      -- Caso nao exista registro, conta como liberado
      IF vr_flgfound AND
         rw_param_conta.flglibera_pre_aprv = 0 THEN
      pr_des_reto := 'OK';
      RETURN; 
    END IF;

    END IF;
    
    --> Verifica se esta bloqueado o pre-aprovado 
    OPEN cr_crappre(pr_cdcooper => rw_crapass.cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_crappre INTO rw_crappre;

    IF cr_crappre%NOTFOUND THEN
      CLOSE cr_crappre;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros pre-aprovado nao cadastrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crappre;
    END IF;

    --> Buscar linha de credito
    OPEN cr_craplcr (pr_cdcooper => rw_crappre.cdcooper,
                     pr_cdlcremp => rw_crapcpa.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;

    IF cr_craplcr%NOTFOUND THEN
       CLOSE cr_craplcr;
      vr_cdcritic := 363; --> Linha nao cadastrada.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplcr;
    END IF;

     --> Buscar carga manual
    OPEN cr_carga_manual (pr_iddcarga => vr_idcarga);
    FETCH cr_carga_manual INTO rw_carga_manual;
    vr_flgmanual := cr_carga_manual%FOUND;
    CLOSE cr_carga_manual;
    
    --> Carregar temptable
    vr_idx := pr_tab_dados_cpa.count + 1;
    pr_tab_dados_cpa(vr_idx).cdcooper := rw_crapass.cdcooper;
    pr_tab_dados_cpa(vr_idx).nrdconta := rw_crapass.nrdconta;
    pr_tab_dados_cpa(vr_idx).inpessoa := rw_crapass.inpessoa;
    pr_tab_dados_cpa(vr_idx).vldiscrd := rw_crapcpa.vllimdis;
    pr_tab_dados_cpa(vr_idx).txmensal := rw_craplcr.txmensal;
    pr_tab_dados_cpa(vr_idx).vllimctr := rw_crappre.vllimctr;

    IF vr_flgmanual THEN
      pr_tab_dados_cpa(vr_idx).msgmanua := rw_carga_manual.mensagem || to_char(rw_crapcpa.vllimdis,'FM999G999G990D00MI');
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro); 
    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro na rotina EMPR0002.pc_busca_dados_cpa: ' ||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_busca_dados_cpa;

  PROCEDURE pc_busca_dados_cpa_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                    ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                    ,pr_idorigem  IN INTEGER                  --> Id origem
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                                    ,pr_clob_cpa  OUT VARCHAR2            --> Retorna dados do credito pre aprovado
                                    ,pr_des_reto  OUT VARCHAR2            --> Retorno OK/NOK
                                    ,pr_clob_erro OUT VARCHAR2) IS            --> Retorna os erros
  BEGIN

    /* .............................................................................

     Programa: pc_busca_dados_cpa_prog        antigo: b1wgen0188.p/busca_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison
     Data    : Janeiro/2016                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Busca dados do credito pr�-aprovado (crapcpa) pelo Progress.

     Alteracoes: 

    ..............................................................................*/ 

    DECLARE
      -- Variaveis
      vr_tab_erro      GENE0001.typ_tab_erro;
      vr_tab_dados_cpa EMPR0002.typ_tab_dados_cpa;
      vr_dscritic      VARCHAR2(4000);
      vr_idx           PLS_INTEGER;
      vr_xml_temp      VARCHAR2(32767);
      vr_clob_cpa      CLOB;
      vr_clob_erro     CLOB;

    BEGIN
      -- Procedimento para buscar dados do credito pr�-aprovado (crapcpa)
      EMPR0002.pc_busca_dados_cpa (pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                  ,pr_cdagenci  => pr_cdagenci   --> C�digo da agencia
                                  ,pr_nrdcaixa  => pr_nrdcaixa   --> Numero do caixa
                                  ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                  ,pr_nmdatela  => pr_nmdatela   --> Nome da tela
                                  ,pr_idorigem  => pr_idorigem   --> Id origem
                                  ,pr_nrdconta  => pr_nrdconta   --> Numero da conta do cooperado
                                  ,pr_idseqttl  => pr_idseqttl   --> Sequencial do titular
                                  ,pr_nrcpfope  => pr_nrcpfope   --> CPF do operador juridico
                                  ------ OUT --------
                                  ,pr_tab_dados_cpa => vr_tab_dados_cpa  --> Retorna dados do credito pre aprovado
                                  ,pr_des_reto      => pr_des_reto       --> Retorno OK/NOK
                                  ,pr_tab_erro      => vr_tab_erro);     --> Retorna os erros

      -- Gerar xml a partir da temptable
      IF vr_tab_erro.count > 0 THEN
        
        GENE0001.pc_xml_tab_erro(pr_tab_erro => vr_tab_erro, --> TempTable de erro
                                 pr_xml_erro => vr_clob_erro, --> XML dos registros da temptable de erro
                                 pr_tipooper => 1,           --> Tipo de opera��o, 1 - Gerar XML, 2 --Gerar pltable
                                 pr_dscritic => vr_dscritic);
                                 
      END IF;
      
      -- Chave inicial
      vr_idx := vr_tab_dados_cpa.FIRST;
      -- Se existir e possuir valor
      IF vr_tab_dados_cpa.EXISTS(vr_idx) AND 
         vr_tab_dados_cpa(vr_idx).vldiscrd > 0 THEN

        -- Criar documento XML
        dbms_lob.createtemporary(vr_clob_cpa, TRUE);
        dbms_lob.open(vr_clob_cpa, dbms_lob.lob_readwrite);

        -- Insere o cabe�alho do XML 
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob_cpa 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');
                               
        -- Escreve o registro
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob_cpa
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '<registro>'||
                                                   '<cdcooper>'||vr_tab_dados_cpa(vr_idx).cdcooper||'</cdcooper>'||
                                                   '<nrdconta>'||vr_tab_dados_cpa(vr_idx).nrdconta||'</nrdconta>'||
                                                   '<inpessoa>'||vr_tab_dados_cpa(vr_idx).inpessoa||'</inpessoa>'||
                                                   '<vldiscrd>'||vr_tab_dados_cpa(vr_idx).vldiscrd||'</vldiscrd>'||
                                                   '<txmensal>'||vr_tab_dados_cpa(vr_idx).txmensal||'</txmensal>'||
                                                   '<vllimctr>'||vr_tab_dados_cpa(vr_idx).vllimctr||'</vllimctr>'||
                                                 '</registro>');

        -- Encerrar a tag raiz 
        GENE0002.pc_escreve_xml(pr_xml            => vr_clob_cpa 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</raiz>' 
                               ,pr_fecha_xml      => TRUE);

      END IF;
      pr_clob_cpa := to_char(vr_clob_cpa);
      pr_clob_erro := to_char(vr_clob_erro);
    END;

  END pc_busca_dados_cpa_prog;
  
  PROCEDURE pc_busca_alinea(pr_xmllog   IN VARCHAR2           --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2          --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_busca_alinea
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar os dados da Alineas.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_crapali IS
        SELECT cdalinea
              ,dsalinea
              ,COUNT(1) OVER() qtregist
          FROM crapali
      ORDER BY cdalinea;

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_dscritic VARCHAR2(10000);
     
    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Busca as Alineas
      FOR rw_crapali IN cr_crapali LOOP
        -- Cria atributo
        IF vr_auxconta = 0 THEN
          GENE0007.pc_gera_atributo(pr_xml      => pr_retxml
                                   ,pr_tag      => 'Dados'
                                   ,pr_atrib    => 'qtregist'
                                   ,pr_atval    => rw_crapali.qtregist
                                   ,pr_numva    => 0
                                   ,pr_des_erro => vr_dscritic);
        END IF;

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'alinea'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'alinea'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdalinea'
                              ,pr_tag_cont => rw_crapali.cdalinea
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'alinea'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsalinea'
                              ,pr_tag_cont => rw_crapali.dsalinea
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;
      END LOOP;
        
    EXCEPTION        
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;
    
  END pc_busca_alinea;
  
  PROCEDURE pc_altera_carga(pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                           ,pr_acao     IN VARCHAR2                          --> Acao: B-Bloquear / L-Liberar
                           ,pr_xmllog   IN VARCHAR2                          --> XML com informa��es de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                      --> C�digo da cr�tica
                           ,pr_dscritic OUT VARCHAR2                         --> Descri��o da cr�tica
                           ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_altera_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Bloquear/Liberar a Carga.

     Alteracoes: 10/07/2017 - - Atualizar vigencia da carga e o indicador de 
                                bloqueio definitivo quando estiver bloqueando uma carga.
                              - Atualizar vigencia da carga quando estiver liberando uma carga
                              M441 - Melhorias do Pr�-aprovado - Roberto Holz (Mout�s)

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_idcarga IN tbepr_carga_pre_aprv.idcarga%TYPE) IS
        SELECT carga.idcarga
              ,carga.indsituacao_carga
              ,carga.flgcarga_bloqueada
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.idcarga = pr_idcarga;
      rw_carga cr_carga%ROWTYPE;

      CURSOR cr_carga_ant(pr_cdcooper in tbepr_carga_pre_aprv.cdcooper%TYPE
                         ,pr_idcarga  in tbepr_carga_pre_aprv.idcarga%TYPE ) IS
         select max(ult.idcarga) idcarga_anterior
           from tbepr_carga_pre_aprv ult
          where ult.cdcooper = pr_cdcooper
            and ult.idcarga <> pr_idcarga
            and ult.flgcarga_bloqueada = 0
            and ult.tpcarga = 2;
      rw_carga_ant cr_carga_ant%ROWTYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_blnfound_ant BOOLEAN;
      vr_flbloque INTEGER;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);
     
    BEGIN
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Valida o operador
      EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_dscritic => vr_dscritic);
      -- Se possui critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a busca do registro
      OPEN cr_carga(pr_idcarga => pr_idcarga);
      FETCH cr_carga INTO rw_carga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        vr_dscritic := 'Carga n�o encontrada.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_acao = 'B' THEN
        vr_flbloque := 1; -- Bloquear
      ELSE
        vr_flbloque := 0; -- Liberar
      END IF;

      -- Se ja estiver bloqueada(1) / liberada(0)
      IF rw_carga.flgcarga_bloqueada = vr_flbloque THEN
        IF pr_acao = 'B' THEN
          vr_dscritic := 'Carga selecionada j� esta Bloqueada.';
        ELSE
          vr_dscritic := 'Carga selecionada j� esta Liberada.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      -- Se nao estiver gerada(1)
      IF rw_carga.indsituacao_carga > 1 THEN
        vr_dscritic := 'Libera��o n�o permitida, sistema esta calculando o pr�-aprovado, aguarde o t�rmino da execu��o.';
        RAISE vr_exc_saida;
      END IF;
      
      BEGIN
        -- Se for uma liberacao
        IF pr_acao = 'L' THEN
           -- pesquisa qual � a carga anterior n�o bloqueada da cooperativa
           -- isso porque o update de bloquear est� fazendo sobre todas as cargas
           -- inclusive a atual (M441)
           OPEN cr_carga_ant( pr_cdcooper => vr_cdcooper
                             ,pr_idcarga  => rw_carga.idcarga);
           FETCH cr_carga_ant INTO rw_carga_ant;
           -- Alimenta a booleana se achou ou nao
           vr_blnfound_ant := cr_carga_ant%FOUND;
           -- Fecha cursor
           CLOSE cr_carga_ant;
           IF vr_blnfound_ant then
              -- seta o final de vigencia na carga anterior que no update seguinte ser� bloqueada
              UPDATE tbepr_carga_pre_aprv
                 SET tbepr_carga_pre_aprv.dtfinal_vigencia = 
                     decode(tbepr_carga_pre_aprv.dtfinal_vigencia,null,sysdate,tbepr_carga_pre_aprv.dtfinal_vigencia)
                    ,tbepr_carga_pre_aprv.flgbloq_definitivo = 1 -- Bloquear definitivo --
                    ,tbepr_carga_pre_aprv.flgcarga_bloqueada = 1 -- Bloquear --
               WHERE tbepr_carga_pre_aprv.cdcooper = vr_cdcooper
                 and tbepr_carga_pre_aprv.idcarga  = rw_carga_ant.idcarga_anterior;
           END IF; -- achou carga anterior
           -- atualizou o fim de vigencia somente na anterior
          -- Bloquear a carga antiga da cooperativa
          UPDATE tbepr_carga_pre_aprv
             SET tbepr_carga_pre_aprv.flgcarga_bloqueada = 1 
           WHERE tbepr_carga_pre_aprv.cdcooper = vr_cdcooper;
        END IF;
        -- Bloquear/Liberar a carga passada
        UPDATE tbepr_carga_pre_aprv
           SET tbepr_carga_pre_aprv.flgcarga_bloqueada = vr_flbloque
              ,tbepr_carga_pre_aprv.dtliberacao = decode(vr_flbloque,0,sysdate,tbepr_carga_pre_aprv.dtliberacao)
              ,tbepr_carga_pre_aprv.dtfinal_vigencia = decode(vr_flbloque,1,sysdate,NULL)
              ,tbepr_carga_pre_aprv.flgbloq_definitivo = decode(vr_flbloque,1,1,0)
         WHERE tbepr_carga_pre_aprv.idcarga = rw_carga.idcarga;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar carga: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      COMMIT;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;
    
  END pc_altera_carga;
  
  PROCEDURE pc_inclui_carga (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                            ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE  --> Codigo da Carga
                            ,pr_dscritic OUT VARCHAR2) IS                       --> Retorno de critica

  BEGIN

    /* .............................................................................

     Programa: pc_inclui_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Incluir a Carga.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga = 2  -- Solicitada
           AND carga.flgcarga_bloqueada = 1 -- Bloqueada
           AND carga.tpcarga = 2;           -- Automatica

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_idcarga  tbepr_carga_pre_aprv.idcarga%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);
     
    BEGIN
      -- Efetua a busca do registro
      OPEN cr_carga (pr_cdcooper => pr_cdcooper);
      FETCH cr_carga INTO vr_idcarga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        -- Inclui uma nova carga
        BEGIN
          INSERT INTO tbepr_carga_pre_aprv
                     (cdcooper
                     ,dtcalculo
                     ,indsituacao_carga
                     ,flgcarga_bloqueada
                     ,tpcarga)
              VALUES (pr_cdcooper
                     ,SYSDATE
                     ,2 -- Solicitada
                     ,1 -- Bloqueada
                     ,2)-- Automatica
           RETURNING idcarga 
                INTO vr_idcarga;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir a carga de Credito Pre Aprovado: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      pr_idcarga := vr_idcarga;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
    END;
    
  END pc_inclui_carga;

  PROCEDURE pc_limpeza_diretorio(pr_nmdireto IN VARCHAR2      --> Diretorio para limpeza
                                ,pr_dscritic OUT VARCHAR2) IS --> Retorno de critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_limpeza_diretorio
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Jaison
    --  Data     : Janeiro/2016                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Fazer limpeza de diretorio quando a data eh anterior ao periodo de 4 meses da data atual.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_typ_said VARCHAR2(3);        -- Saida da rotina de chamada ao OS
      vr_dslista  VARCHAR2(4000);     -- Lista de arquivos do diretorio
      vr_lstarqre GENE0002.typ_split; -- Lista de arquivos
      vr_lstnome  GENE0002.typ_split; -- Lista de nomes
      vr_dtlimite DATE;
      vr_dtarquiv DATE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Subtrai 4 meses
      vr_dtlimite := ADD_MONTHS(TRUNC(rw_crapdat.dtmvtolt), - 4);

      -- Primeiro testamos se o diret�rio j� n�o est� vazio
      GENE0001.pc_lista_arquivos(pr_path => pr_nmdireto         --> Dir a limpar
                                ,pr_pesq => NULL                --> Qualquer arquivo
                                ,pr_listarq => vr_dslista       --> Lista encontrada
                                ,pr_des_erro => pr_dscritic);   --> Erro encontrado
      -- Se houve erro ja na listagem
      IF pr_dscritic IS NOT NULL THEN
        -- Incrementar a mensagem
        pr_dscritic := 'Erro Ao verificar arquivos do dir para limpeza '||pr_nmdireto||' --> '||pr_dscritic;
        RETURN;
      END IF;
      -- Se houverem arquivos
      IF vr_dslista IS NOT NULL THEN
        -- Separar a lista de arquivos encontradas com funcao existente
        vr_lstarqre := GENE0002.fn_quebra_string(pr_string => vr_dslista, pr_delimit => ',');
        -- Se nao encontrou nenhum arquivo sair
        IF vr_lstarqre.COUNT() = 0 THEN
          RETURN;
        END IF;
        -- Para cada arquivo encontrado no DIR
        FOR vr_idx IN 1..vr_lstarqre.COUNT LOOP
          -- Separa o nome da data
          vr_lstnome := GENE0002.fn_quebra_string(pr_string => vr_lstarqre(vr_idx), pr_delimit => '_');
          IF vr_lstnome.COUNT() < 2 THEN
            CONTINUE;
          ELSE
            vr_dtarquiv := TO_DATE(SUBSTR(vr_lstnome(2),1,8),'DDMMRRRR');
          END IF;
          -- Se a data de limite for maior que a do arquivo
          IF vr_dtlimite > vr_dtarquiv THEN
            -- Remover o arquivo
            GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm "'||pr_nmdireto||'/'||vr_lstarqre(vr_idx)||'"'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);
            -- Testar retorno de erro
            IF vr_typ_said = 'ERR' THEN
              pr_dscritic := 'Erro ao limpar dir '||pr_nmdireto||' --> Ao remover arquivo "'||vr_lstarqre(vr_idx)||'"--> '||pr_dscritic;
              RETURN;
            END IF;
          END IF;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> na rotina CYBE0002.pc_limpeza_diretorio -->  '||SQLERRM;
    END;
  END pc_limpeza_diretorio;
  
  -- Buscar as linhas de cr�dito.
  PROCEDURE pc_busca_linha_credito_prog(pr_cdcooper  IN crapcop.cdcooper%TYPE              --> Diretorio para limpeza
                                       ,pr_inpessoa  IN crapass.inpessoa%TYPE DEFAULT NULL --> Tipo de pessoa
                                       ,pr_cdrisco   IN craplcr.cdlcremp%TYPE DEFAULT NULL --> Codigo do risco
                                       ,pr_lslcremp OUT VARCHAR2                           --> Cdigos dos riscos
                                       ,pr_dscritic OUT VARCHAR2) IS                       --> Descricao da critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_linha_credito_prog
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao: 12/04/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar as linhas de cr�dito usadas pelos riscos da CADPRE.
    --
    -- Alteracoes: 12/04/2017 - Realizado ajuste onde n�o estava sendo poss�vel lan�ar contratos 
    --                          de emprestimos com a linha 70, conforme solicitado no chamado 644168. (Kelvin)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_typ_said VARCHAR2(3);        -- Saida da rotina de chamada ao OS
      vr_dslista  VARCHAR2(4000);     -- Lista de arquivos do diretorio
      vr_lstarqre GENE0002.typ_split; -- Lista de arquivos
      vr_lstnome  GENE0002.typ_split; -- Lista de nomes
      vr_dtlimite DATE;
      vr_dtarquiv DATE;

      -- Cursor generico de calendario
      CURSOR cr_linha_pre_aprv (pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_inpessoa IN crapass.inpessoa%TYPE
                               ,pr_cdrisco  IN VARCHAR2) IS
        SELECT DISTINCT cdlcremp
          FROM tbepr_linha_pre_aprv lin
         WHERE lin.cdcooper = pr_cdcooper
           AND lin.inpessoa = NVL(pr_inpessoa,lin.inpessoa)
           AND lin.cdrisco  = nvl(decode(pr_cdrisco
                                         ,'AA',1
                                         ,'A',2
                                         ,'B',3
                                         ,'C',4
                                         ,'D',5
                                         ,'E',6
                                         ,'F',7
                                         ,'G',8
                                         ,'H',9
                                         ,'HH',10),lin.cdrisco);
    BEGIN
      pr_lslcremp := ';';
      FOR rw_linha_pre_aprv IN cr_linha_pre_aprv(pr_cdcooper
                                                ,pr_inpessoa
                                                ,pr_cdrisco) LOOP
        pr_lslcremp := pr_lslcremp || rw_linha_pre_aprv.cdlcremp || ';';
      END LOOP;
      
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_busca_linha_credito_prog -->  '||SQLERRM;
    END;
  END pc_busca_linha_credito_prog;
  
  -- Busca per�odo de bloqueio de limite por refinanceamento.
  PROCEDURE pc_busca_periodo_bloq_refin(pr_inpessoa IN crappre.inpessoa%TYPE --> Tipo de pessoa
                                       ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                       ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_periodo_bloq_refin 
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Busca per�odo de bloqueio de limite por refinanceamento da CADPRE.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      
      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      --Variaveis auxiliares
      vr_qtmesblq crappre.qtmesblq%TYPE;
      
      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      
      -- Busca per�odo de bloqueio de limite por refinanceamento
      CURSOR cr_crappre (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
        SELECT qtmesblq
          FROM crappre
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      
    BEGIN
      
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Inicializa variavel
      vr_qtmesblq := 0;
      
      -- Busca per�odo de bloqueio de limite por refinanceamento
      OPEN cr_crappre(vr_cdcooper, pr_inpessoa);
      FETCH cr_crappre INTO vr_qtmesblq;
      CLOSE cr_crappre;
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>' || vr_qtmesblq || '</Dados></Root>');
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_busca_periodo_bloq_refin -->  '||SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_busca_periodo_bloq_refin;
  
  -- Mantem status do pre aprovado do cooperado
  PROCEDURE pc_mantem_param_conta (pr_cdcooper              IN crapcop.cdcooper%TYPE
                                  ,pr_nrdconta              IN crapass.nrdconta%TYPE
                                  ,pr_flgrenli              IN crapass.flgrenli%TYPE
                                  ,pr_flglibera_pre_aprv    IN NUMBER
                                  ,pr_dtatualiza_pre_aprv   IN DATE DEFAULT SYSDATE
                                  ,pr_idmotivo              IN NUMBER DEFAULT 0
                                  ,pr_cdoperad              IN VARCHAR2
                                  ,pr_idorigem              IN VARCHAR2
                                  ,pr_nmdatela              IN VARCHAR2
                                  ,pr_dtmvtolt              IN DATE
                                  ,pr_dscritic             OUT VARCHAR2             --> Descri��o da cr�tica
                                  ,pr_des_erro             OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_mantem_param_conta 
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Mantem status do pre aprovado do cooperado
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      
    -- buscar parametros de emprestimo da conta
      CURSOR cr_param_conta (pr_cdcooper crapcop.cdcooper%TYPE
                            ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT flglibera_pre_aprv
              ,dtatualiza_pre_aprv
              ,idmotivo
          FROM tbepr_param_conta
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_param_conta cr_param_conta%ROWTYPE;
      
      -- buscar parametros de emprestimo da conta
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT flgrenli
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      --Variaveis Auxiliares
      vr_nrdrowid            ROWID;
      vr_dtatualiza_pre_aprv DATE;
      vr_flgrenli            crapass.flgrenli%TYPE;
      
      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      
    BEGIN
      pr_des_erro := 'OK';
      
      IF pr_dtatualiza_pre_aprv IS NULL THEN
        vr_dtatualiza_pre_aprv := trunc(SYSDATE);
      ELSE
        vr_dtatualiza_pre_aprv := pr_dtatualiza_pre_aprv;
      END IF;
      
      OPEN cr_crapass (pr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      
      IF pr_flgrenli IS NOT NULL THEN
        vr_flgrenli := pr_flgrenli;
      ELSE
        vr_flgrenli := rw_crapass.flgrenli;
      END IF;
      
      -- Cria registro para bloquear pre aprovado do cooperado
      BEGIN
        
        INSERT INTO tbepr_param_conta (cdcooper
                                      ,nrdconta
                                      ,flglibera_pre_aprv
                                      ,dtatualiza_pre_aprv
                                      ,idmotivo)
                                  VALUES (pr_cdcooper
                                         ,pr_nrdconta
                                         ,pr_flglibera_pre_aprv
                                         ,vr_dtatualiza_pre_aprv
                                         ,pr_idmotivo);

        /* Inclus�o de log com retorno do rowid */
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ''
                            ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                            ,pr_dstransa => 'Criacao dos parametros de emprestimo da conta'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 0
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
        
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Codigo da cooperativa'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => pr_cdcooper);
                                  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Numero da conta'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => pr_nrdconta);
                                  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Liberacao de pre-aprovado'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => CASE pr_flglibera_pre_aprv
                                                   WHEN 1 THEN 'Liberado'
                                                   ELSE 'Bloqueado'
                                                 END);
                                  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Data da atualizacao da flag pre-aprovado'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => to_char(vr_dtatualiza_pre_aprv,'DD/MM/RRRR'));
                                  
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Motivo do bloqueio do pre-aprovado.'
                                 ,pr_dsdadant => NULL
                                 ,pr_dsdadatu => fn_busca_motivo(pr_idmotivo));
                                 
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Renova Limite Credito Automatico.'
                                 ,pr_dsdadant => CASE rw_crapass.flgrenli
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END
                                 ,pr_dsdadatu => CASE vr_flgrenli
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END);
        
      EXCEPTION
        WHEN dup_val_on_index THEN
          
          OPEN cr_param_conta (pr_cdcooper, pr_nrdconta);
          FETCH cr_param_conta INTO rw_param_conta;
          CLOSE cr_param_conta;
          
          -- Se j� existir registro, faz update 
          BEGIN 
            UPDATE tbepr_param_conta
               SET flglibera_pre_aprv  = pr_flglibera_pre_aprv
                  ,dtatualiza_pre_aprv = vr_dtatualiza_pre_aprv
                  ,idmotivo            = pr_idmotivo
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro --> na rotina EMPR0002.pc_mantem_param_conta -->  '||SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          /* Inclus�o de log com retorno do rowid */
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Alteracao dos parametros de emprestimo da conta'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => 0
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Liberacao de pre-aprovado'
                                   ,pr_dsdadant => CASE rw_param_conta.flglibera_pre_aprv
                                                     WHEN 1 THEN 'Liberado'
                                                     ELSE 'Bloqueado'
                                                   END
                                   ,pr_dsdadatu => CASE pr_flglibera_pre_aprv
                                                     WHEN 1 THEN 'Liberado'
                                                     ELSE 'Bloqueado'
                                                   END);
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Data da atualizacao da flag pre-aprovado'
                                   ,pr_dsdadant => to_char(rw_param_conta.dtatualiza_pre_aprv,'DD/MM/RRRR')
                                   ,pr_dsdadatu => to_char(vr_dtatualiza_pre_aprv,'DD/MM/RRRR'));
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Motivo do bloqueio do pre-aprovado.'
                                   ,pr_dsdadant => fn_busca_motivo(rw_param_conta.idmotivo)
                                   ,pr_dsdadatu => fn_busca_motivo(pr_idmotivo));
                                   
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                   ,pr_nmdcampo => 'Renova Limite Credito Automatico.'
                                   ,pr_dsdadant => CASE rw_crapass.flgrenli
                                                     WHEN 1 THEN 'Sim'
                                                     ELSE 'Nao'
                                                   END
                                   ,pr_dsdadatu => CASE vr_flgrenli
                                                     WHEN 1 THEN 'Sim'
                                                     ELSE 'Nao'
                                                   END);
      END;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_des_erro := 'NOK';
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_mantem_param_conta -->  '||SQLERRM;
    END;
  END pc_mantem_param_conta;
  
  -- Bloqueio de limite do pre aprovado por refinanceamento.
  PROCEDURE pc_bloqueia_pre_aprv_por_refin(pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do cooperado
                                          ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                          ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_periodo_bloq_refin 
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Bloqueio de limite do pre aprovado por refinanceamento.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      
      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      vr_idseqttl      VARCHAR2(100);
      
      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      
      -- Busca per�odo de bloqueio de limite por refinanceamento
      CURSOR cr_crappre (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
        SELECT qtmesblq
          FROM crappre
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;
      
      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
    BEGIN
      
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      -- Bloqueia pre aprovado na conta do cooperado
      EMPR0002.pc_mantem_param_conta (pr_cdcooper => vr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_flgrenli => NULL
                                     ,pr_flglibera_pre_aprv =>  0
                                     ,pr_dtatualiza_pre_aprv => NULL
                                     ,pr_idmotivo => 32 -- Refinanciamento
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_idorigem => vr_idorigem
                                     ,pr_nmdatela => vr_nmdatela
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_dscritic => vr_dscritic
                                     ,pr_des_erro => pr_des_erro);
      
      IF pr_des_erro = 'NOK' THEN
        RAISE vr_exc_saida;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_busca_periodo_bloq_refin -->  '||SQLERRM;
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_bloqueia_pre_aprv_por_refin;
  
  -- Habilitar as contas bloqueadas por refinanciamento
  PROCEDURE pc_habilita_contas_suspensas(pr_cdcooper IN crapcop.cdcooper%TYPE --> Conta do cooperado
                                        ,pr_inpessoa IN crappre.inpessoa%TYPE --> Tipo de pessoa
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data do movimento
                                        ,pr_dscritic OUT VARCHAR2) IS         --> Descri��o da cr�tica

  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_habilita_contas_suspensas 
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Lombardi
    --  Data     : Julho/2016                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Habilitar as contas bloqueadas por refinanciamento, quando o
    --             tempo configurado para bloqueio acabar.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca per�odo de bloqueio de limite por refinanceamento
      CURSOR cr_crappre (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
        SELECT qtmesblq
          FROM crappre
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;
      
      -- Variaveis auxiliares
      vr_qtd_mes INTEGER;
      
      -- Variaveis de Erro
      vr_dscritic  VARCHAR2(1000);
      vr_exc_saida EXCEPTION;
      
    BEGIN
      
      -- Busca o mes do parametro da cadpre
      OPEN cr_crappre(pr_cdcooper, pr_inpessoa);
      FETCH cr_crappre INTO rw_crappre;
      IF cr_crappre%NOTFOUND THEN
        vr_dscritic := 'Parametros pre-aprovado nao cadastrados.';
        RAISE vr_exc_saida;
      END IF;
      CLOSE cr_crappre;
      
      -- Recebe o mes do parametro da cadpre
      vr_qtd_mes := rw_crappre.qtmesblq;
      
      BEGIN
        -- Habilita as contas
        UPDATE tbepr_param_conta prm
           SET flglibera_pre_aprv  = 1
              ,dtatualiza_pre_aprv = pr_dtmvtolt
              ,idmotivo            = null
           WHERE prm.cdcooper = pr_cdcooper
             AND prm.flglibera_pre_aprv  = 0
             AND prm.idmotivo            IS NOT NULL -- Indica que � por refinanciamento 
             AND prm.dtatualiza_pre_aprv IS NOT NULL
             AND ADD_MONTHS(TRUNC(prm.dtatualiza_pre_aprv), vr_qtd_mes) <= pr_dtmvtolt
             AND EXISTS(SELECT 1 
                          FROM crapass ass
                         WHERE ass.cdcooper = prm.cdcooper
                           AND ass.nrdconta = prm.nrdconta
                           AND ass.inpessoa = pr_inpessoa);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao habilitar as contas bloqueadas por refinanciamento. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro --> na rotina EMPR0002.pc_habilita_contas_suspensas -->  '||SQLERRM;
        ROLLBACK;
    END;
  END pc_habilita_contas_suspensas;

  -- Gerar tabela de historico dos bens das propostas de emprestimos. - JOB 
  PROCEDURE pc_carga_hist_bpr(pr_cdcooper IN crapcop.cdcooper%TYPE) IS --> Codigo da cooperativa

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_carga_hist_bpr 
    Sistema  : Emprestimo 
    Sigla    : EMPR
    Autor    : Odirlei Busana - AMcom
    Data     : Abril/2017                   Ultima atualizacao: 
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo  : Gerar tabela de historico dos bens das propostas de emprestimos. - JOB 
               
               
    Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/    
  
    --> Buscar coops ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             dat.dtmvtolt
        FROM crapcop cop,
             crapdat dat   
       WHERE cop.cdcooper = dat.cdcooper
         AND cop.flgativo = 1
         AND cop.cdcooper = decode(nvl(pr_cdcooper,0),0,cop.cdcooper,pr_cdcooper);
      
    -- Vari�veis de controle de calend�rio
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;
    vr_datdodia  DATE;  
    
    -- Variaveis de Erro
    vr_dscritic  VARCHAR2(1000);
    vr_exc_erro  EXCEPTION;
    
    vr_cdprogra  CONSTANT VARCHAR2(80) := 'PC_CARGA_HIST_BPR';
    vr_nomdojob  CONSTANT VARCHAR2(80) := 'JBEPR_CARGA_HIST_BPR';
    vr_flgerlog  BOOLEAN := FALSE;
    
    --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN

      --> Controlar gera��o de log de execu��o dos jobs
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

    END pc_controla_log_batch;
    
    
    PROCEDURE pc_alerta_email (pr_cdcooper IN crapcop.cdcooper%TYPE,
                               pr_dscritic IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      
      vr_conteudo   VARCHAR2(4000);
      vr_email_dest VARCHAR2(4000);
    BEGIN
    
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || pr_dscritic,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB_BPR');
    
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('Erro ao realizar carga de base historica de  bens da proposta de emprestimo (crapbpr)' ||
                     '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||                      
                     '<br>Critica: '         || pr_dscritic,1,4000);
                      
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'Falha Carga Bens proposta' 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      
      IF TRIM(vr_dscritic) IS NOT NULL THEN  
        RAISE vr_exc_erro;
      END IF;
      COMMIT;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        /* Se aconteceu erro, gera o log e envia o erro por e-mail */
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                           pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        ROLLBACK;
      WHEN OTHERS THEN
      
        vr_dscritic := 'Erro ao enviar alerta: '||SQLERRM;
        /* Se aconteceu erro, gera o log e envia o erro por e-mail */
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                           pr_ind_tipo_log => 2, --> erro tratado
                                           pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                              ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                           pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        ROLLBACK;
      
    END pc_alerta_email;
      
  BEGIN
    
    -- Verifica��o do calend�rio
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;  
  
    vr_datdodia := trunc(SYSDATE);

    --> Apenas realizar a copia se for o ultimo dia de processo do m�s   
    IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtopr,'MM') AND
        rw_crapdat.dtmvtolt = vr_datdodia THEN
  
  
      pc_controla_log_batch(pr_dstiplog => 'I');
  
      --> Listar coops ativas
      FOR rw_crapcop IN cr_crapcop LOOP 
        BEGIN
          INSERT INTO tbepr_bens_hst
            (dtrefere
            ,cdcooper
            ,nrdconta
            ,tpctrpro
            ,nrctrpro
            ,flgalien
            ,dtmvtolt
            ,cdoperad
            ,dsrelbem
            ,persemon
            ,qtprebem
            ,vlrdobem
            ,vlprebem
            ,dscatbem
            ,nranobem
            ,nrmodbem
            ,dscorbem
            ,dschassi
            ,nrdplaca
            ,flgalfid
            ,flgsegur
            ,dtvigseg
            ,flglbseg
            ,tpchassi
            ,ufdplaca
            ,uflicenc
            ,nrrenava
            ,nrcpfbem
            ,vlmerbem
            ,idseqbem
            ,dsbemfin
            ,flgrgcar
            ,vlperbem
            ,cdsitgrv
            ,nrgravam
            ,dtatugrv
            ,flginclu
            ,dtdinclu
            ,dsjstinc
            ,tpinclus
            ,flgalter
            ,dtaltera
            ,tpaltera
            ,flcancel
            ,dtcancel
            ,tpcancel
            ,flgbaixa
            ,dtdbaixa
            ,dsjstbxa
            ,tpdbaixa
            ,nrplnovo
            ,ufplnovo
            ,nrrenovo
            ,flblqjud
            ,dstipbem)
            SELECT rw_crapdat.dtultdia
                  ,bpr.cdcooper
                  ,bpr.nrdconta
                  ,bpr.tpctrpro
                  ,bpr.nrctrpro
                  ,bpr.flgalien
                  ,bpr.dtmvtolt
                  ,bpr.cdoperad
                  ,bpr.dsrelbem
                  ,bpr.persemon
                  ,bpr.qtprebem
                  ,bpr.vlrdobem
                  ,bpr.vlprebem
                  ,bpr.dscatbem
                  ,bpr.nranobem
                  ,bpr.nrmodbem
                  ,bpr.dscorbem
                  ,bpr.dschassi
                  ,bpr.nrdplaca
                  ,bpr.flgalfid
                  ,bpr.flgsegur
                  ,bpr.dtvigseg
                  ,bpr.flglbseg
                  ,bpr.tpchassi
                  ,bpr.ufdplaca
                  ,bpr.uflicenc
                  ,bpr.nrrenava
                  ,bpr.nrcpfbem
                  ,bpr.vlmerbem
                  ,bpr.idseqbem
                  ,bpr.dsbemfin
                  ,bpr.flgrgcar
                  ,bpr.vlperbem
                  ,bpr.cdsitgrv
                  ,bpr.nrgravam
                  ,bpr.dtatugrv
                  ,bpr.flginclu
                  ,bpr.dtdinclu
                  ,bpr.dsjstinc
                  ,bpr.tpinclus
                  ,bpr.flgalter
                  ,bpr.dtaltera
                  ,bpr.tpaltera
                  ,bpr.flcancel
                  ,bpr.dtcancel
                  ,bpr.tpcancel
                  ,bpr.flgbaixa
                  ,bpr.dtdbaixa
                  ,bpr.dsjstbxa
                  ,bpr.tpdbaixa
                  ,bpr.nrplnovo
                  ,bpr.ufplnovo
                  ,bpr.nrrenovo
                  ,bpr.flblqjud
                  ,bpr.dstipbem
              FROM crapbpr bpr
             WHERE bpr.flgalien = 1
               AND bpr.cdcooper = rw_crapcop.cdcooper;
        
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'N�o foi possivel replicar dados para a coop: '||rw_crapcop.cdcooper||' -> '||SQLERRM;
            pc_alerta_email(pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dscritic => vr_dscritic);
                            
            vr_dscritic := NULL;                        
        END;
        
        COMMIT;
      END LOOP; --> Fim loop coop
      
      pc_controla_log_batch(pr_dstiplog => 'F');
      
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
    -- Efetuar rollback
    ROLLBACK;

    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);

    pc_alerta_email(pr_cdcooper => 3,
                    pr_dscritic => vr_dscritic);
            
    
    COMMIT;
    
    raise_application_error(-20501,vr_dscritic);
    
  WHEN OTHERS THEN

    vr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;

    pc_controla_log_batch(pr_dstiplog => 'E',
                          pr_dscritic => vr_dscritic);

    pc_alerta_email(pr_cdcooper => 3,
                    pr_dscritic => vr_dscritic);
    
    
    COMMIT;
    raise_application_error(-20501,vr_dscritic); 
                          
  END pc_carga_hist_bpr;

  
  PROCEDURE pc_carga_pos_diaria_epr ( pr_cdcooper      IN CRAPCOP.CDCOOPER%TYPE -- c�digo da cooperativa (0-processa todas)
                                     ,pr_qtddias_blq   IN NUMBER    --> Quantidade de dias bloqueado limite pr�-aprovado na TBERP_PARAM_CONTA
                                     ,pr_qtdias_manter IN NUMBER) IS  --> Quantidade de dias para manter a tabela TBBI_CPA_POSICAO_DIARIA
 /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_carga_pos_diaria_epr 
    Sistema  : Emprestimo 
    Sigla    : EMPR
    Autor    : Roberto Holz - Mout�s 
    Data     : Junho/2017                   Ultima atualizacao: 
  
    Dados referentes ao programa:
  
    Frequencia: -----
    Objetivo  : Gerar a tabela de posi��o di�ria do pr�-aprovado e contratos. - JOB 
               
               
    Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/    
  
    
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = DECODE(pr_cdcooper,0,cop.cdcooper,pr_cdcooper)
         AND cop.cdcooper <> 3
         AND cop.flgativo = 1
       order by cop.cdcooper;
    
    CURSOR cr_pos_diaria (pr_cdcooper       IN TBBI_CPA_POSICAO_DIARIA.CDCOOPER%TYPE,
                          pr_dtbase         IN date,
                          pr_dias_bloqueado IN number) IS
     SELECT TAB.CDCOOPER,
       TAB.NRDCONTA,
       TAB.TIPO_REG,
       TAB.IDDCARGA,
       TAB.VL_LIMITE,
       TAB.VL_DISPONIVEL,
       QT_CONTRATOS,
       TAB.VLEMPRST,
       TAB.vlsdevat,
       TAB.VLPREEMP,
       DTLIBERACAO,
       FLGLIBERA_PRE_APRV,
       DTATUALIZA_PRE_APRV
  FROM (select 9 tipo_reg, -- Busca os emprestimos com finalidade 68 e com saldo
               epr.cdcooper,
               epr.nrdconta,
               0 iddcarga,
               0 tp_carga,
               0 vl_limite,
               0 vl_disponivel,
               count(*) qt_contratos,
               sum(epr.vlemprst) vlemprst,
               sum(epr.vlsdevat) vlsdevat,
               sum(epr.vlpreemp) vlpreemp,
               NULL dtliberacao,
               NULL flglibera_pre_aprv,
               NULL dtatualiza_pre_aprv
          from crapepr epr
         where -- emmprestimos com idcarga > 0 consomem limite do pr�-aprovado
               -- por�m esta regra somente come�ou no final de 2016 e existem
               -- emprestimos antigos (idcarga = 0) que devem ser selecionados pela finalidade 68  
              (epr.cdfinemp = 68 or epr.iddcarga > 0)
           and epr.vlsdevat > 0
           and epr.inliquid = 0
           and epr.inprejuz = 0
         group by epr.cdcooper, epr.nrdconta
        UNION ALL
        -- Busca as cargas ativas tanto manual como autom�tica --
        select 0                      tipo_reg,
               wt.cdcooper,
               wt.nrdconta,
               wt.idcarga,
               wt.tpcarga,
               wt.vlcalpre,
               wt.vllimdis,
               0                      QT_CONTRATOS,
               0,
               0,
               0,
               wt.dtliberacao,
               wt.flglibera_pre_aprv,
               wt.dtatualiza_pre_aprv
          from (SELECT carga.tpcarga,
                       carga.dtcalculo,
                       carga.cdcooper cdcooper_carga,
                       carga.idcarga,
                       nvl(carga.dtliberacao, carga.dtcalculo) dtliberacao,
                       carga.dtfinal_vigencia,
                       cpa.cdcooper,
                       cpa.nrdconta,
                       cpa.vlcalpre,
                       cpa.vllimdis,
                       cpa.vlcalpre - cpa.vllimdis,
                       param.flglibera_pre_aprv,
                       param.dtatualiza_pre_aprv
                  FROM tbepr_carga_pre_aprv carga,
                       crapcpa              cpa,
                       tbepr_param_conta    param
                 WHERE carga.indsituacao_carga = 1 -- Gerada
                   AND carga.flgcarga_bloqueada = 0 -- Liberada
                   AND carga.tpcarga = 2 -- Autom�tica
                   AND (carga.dtfinal_vigencia IS NULL OR
                       carga.dtfinal_vigencia >= TRUNC(SYSDATE))
                   and cpa.iddcarga = carga.idcarga
                   and param.cdcooper(+) = cpa.cdcooper
                   and param.nrdconta(+) = cpa.nrdconta
                UNION ALL
                SELECT carga.tpcarga,
                       carga.dtcalculo,
                       carga.cdcooper cdcooper_carga,
                       carga.idcarga,
                       nvl(carga.dtliberacao, carga.dtcalculo),
                       carga.dtfinal_vigencia,
                       cpa.cdcooper,
                       cpa.nrdconta,
                       cpa.vlcalpre,
                       cpa.vllimdis,
                       cpa.vlcalpre - cpa.vllimdis,
                       param.flglibera_pre_aprv,
                       param.dtatualiza_pre_aprv
                  FROM tbepr_carga_pre_aprv carga,
                       crapcpa              cpa,
                       tbepr_param_conta    param
                 WHERE carga.cdcooper = 3
                   AND carga.indsituacao_carga = 1 -- Gerada
                   AND carga.flgcarga_bloqueada = 0 -- Liberada
                   AND carga.tpcarga = 1 -- Manual
                   AND (carga.dtfinal_vigencia IS NULL OR
                       carga.dtfinal_vigencia >= TRUNC(SYSDATE))
                   AND cpa.iddcarga = carga.idcarga
                   and param.cdcooper(+) = cpa.cdcooper
                   and param.nrdconta(+) = cpa.nrdconta
                 order by cdcooper, nrdconta, tpcarga, dtcalculo desc) wt
         where (wt.vllimdis <> 0)
           and ((wt.flglibera_pre_aprv = 1 or wt.flglibera_pre_aprv is null) or
               (wt.flglibera_pre_aprv = 0 and
               wt.dtatualiza_pre_aprv >= trunc(pr_dtbase - pr_dias_bloqueado)))) TAB
 WHERE TAB.CDCOOPER = pr_cdcooper
 order by 1, 2, 3;
  
    -- Cursor generico de calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE; 
    
    vr_flgachou BOOLEAN;
    
    -- Variaveis
    vr_qtdias_manter      NUMBER(3);
    vr_salvo_cdcooper     CECRED.TBBI_CPA_POSICAO_DIARIA.CDCOOPER%TYPE;
    vr_salvo_nrdconta     CECRED.TBBI_CPA_POSICAO_DIARIA.NRDCONTA%TYPE;
    vr_salvo_qtcontratos  CECRED.TBBI_CPA_POSICAO_DIARIA.QTEPR_ATIVOS_PRE_APRV%TYPE;
    vr_salvo_vlemprst     CECRED.TBBI_CPA_POSICAO_DIARIA.VLEPR_ATIVOS_PRE_APRV%TYPE;
    vr_salvo_vlsdevat     CECRED.TBBI_CPA_POSICAO_DIARIA.VLSALDO_EPR_ATIVOS_PRE_APRV%TYPE;
    vr_salvo_vlpreemp     CECRED.TBBI_CPA_POSICAO_DIARIA.VLPREST_EPR_ATIVOS_PRE_APRV%TYPE;
          
    vr_salvo_vigente          NUMBER(1);
    vr_vig_iddcarga           CECRED.TBBI_CPA_POSICAO_DIARIA.IDCARGA%TYPE;        
    vr_vig_dtliberacao        CECRED.TBBI_CPA_POSICAO_DIARIA.DTLIB_CARGA_PRE_APRV%TYPE;
    vr_vig_flglibera_pre_aprv CECRED.TBBI_CPA_POSICAO_DIARIA.FLGLIBERA_PRE_APRV%TYPE;
    vr_vig_dtatualiza_pre_aprv CECRED.TBBI_CPA_POSICAO_DIARIA.DTATUALIZA_PRE_APRV%TYPE;
    vr_vig_vl_limite          CECRED.TBBI_CPA_POSICAO_DIARIA.VLLIM_PRE_APRV_TOTAL%TYPE;
    vr_vig_vl_disponivel      CECRED.TBBI_CPA_POSICAO_DIARIA.VLLIM_PRE_APRV_DISPONIVEL%TYPE;
    
   
    -- Variaveis de erro

    vr_exc_erro_diaria exception;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    vr_cdprogra  CONSTANT VARCHAR2(80) := 'PC_CARGA_POS_DIARIA_EPR';
    vr_nomdojob  CONSTANT VARCHAR2(80) := 'JBEPR_CARGA_POS_DIARIA_EPR';
    vr_flgerlog  BOOLEAN := FALSE;
    
    PROCEDURE pc_controla_log(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                              pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN

      --> Controlar gera��o de log de execu��o dos jobs
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

    END pc_controla_log;

    PROCEDURE pc_limpeza_pos_diaria( pr_tipo_excl     IN NUMBER  -- (0 = elimina data base sen�o elimina antigos)
                                    ,pr_qtdias_manter IN NUMBER
                                    ,pr_cdcooper      IN CRAPCOP.CDCOOPER%TYPE
                                    ,pr_dtbase        IN CRAPDAT.DTMVTOLT%TYPE) IS
                                    
    BEGIN
        IF  pr_tipo_excl = 0 then
            DELETE FROM TBBI_CPA_POSICAO_DIARIA
             WHERE TBBI_CPA_POSICAO_DIARIA.DTMVTOLT = pr_dtbase
               AND TBBI_CPA_POSICAO_DIARIA.CDCOOPER = pr_cdcooper;
         ELSE
            DELETE FROM TBBI_CPA_POSICAO_DIARIA
             WHERE TBBI_CPA_POSICAO_DIARIA.DTMVTOLT <= pr_dtbase - pr_qtdias_manter
               AND TBBI_CPA_POSICAO_DIARIA.CDCOOPER = pr_cdcooper;            
         END IF;
    EXCEPTION
      WHEN OTHERS THEN
           vr_dscritic := 'Problema ao excluir Posi��o Di�ria Pr�-Aprovado: ' || SQLERRM;      
                   
    END pc_limpeza_pos_diaria;
    
    PROCEDURE PC_GRV_TBBI_CPA_POSICAO_DIARIA IS
     BEGIN
      INSERT INTO TBBI_CPA_POSICAO_DIARIA
         ( DTMVTOLT
          ,CDCOOPER
          ,NRDCONTA
          ,IDCARGA
          ,VLLIM_PRE_APRV_TOTAL
          ,VLLIM_PRE_APRV_DISPONIVEL
          ,QTEPR_ATIVOS_PRE_APRV
          ,VLEPR_ATIVOS_PRE_APRV
          ,VLSALDO_EPR_ATIVOS_PRE_APRV
          ,VLPREST_EPR_ATIVOS_PRE_APRV
          ,DTLIB_CARGA_PRE_APRV
          ,FLGLIBERA_PRE_APRV
          ,DTATUALIZA_PRE_APRV
         ) VALUES
         ( rw_crapdat.dtmvtolt
          ,vr_salvo_cdcooper
          ,vr_salvo_nrdconta
          ,vr_vig_iddcarga
          --  quando o associado est� bloqueado n�o grava os limites, s� a carga ativa (M441)
          ,DECODE(vr_vig_flglibera_pre_aprv,0,NULL,vr_vig_vl_limite)
          ,DECODE(vr_vig_flglibera_pre_aprv,0,NULL,vr_vig_vl_disponivel)
          ,vr_salvo_qtcontratos
          ,vr_salvo_vlemprst
          ,vr_salvo_vlsdevat
          ,vr_salvo_vlpreemp
          ,vr_vig_dtliberacao
          ,vr_vig_flglibera_pre_aprv
          ,vr_vig_dtatualiza_pre_aprv
         );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir Posi��o Di�ria Pr�-Aprovado: ' || SQLERRM;
        
    END PC_GRV_TBBI_CPA_POSICAO_DIARIA;
    
    BEGIN
      pc_controla_log(pr_dstiplog => 'I');
      vr_qtdias_manter := pr_qtdias_manter;

      FOR rw_crapcop IN cr_crapcop(pr_cdcooper => pr_cdcooper) LOOP -- buscando todas as cooperativas
          --> Buscar a data base da cooperativa
          OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
          FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
          vr_flgachou := BTCH0001.cr_crapdat%FOUND;
          CLOSE BTCH0001.cr_crapdat;
          -- Se nao achou
          IF NOT vr_flgachou THEN
             vr_cdcritic := 1;
             RAISE vr_exc_erro_diaria;
          END IF;

          -- Valida��es iniciais do programa
/*
          BTCH0001.pc_valida_iniprg(pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_flgbatch => 1
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_cdcritic => vr_cdcritic);
          -- Se possui erro
          IF vr_cdcritic <> 0 THEN
             RAISE vr_exc_erro_diaria;
           END IF;   
*/       
          ---------------------------------------
          
          
          -- Executar limpeza da TBBI_CPA_POSICAO_DIARIA da data que ser� gerada;
          pc_limpeza_pos_diaria( pr_tipo_excl => 0
                                ,pr_qtdias_manter => vr_qtdias_manter
                                ,pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_dtbase   => rw_crapdat.dtmvtolt);

          vr_salvo_cdcooper := 0;
          vr_salvo_nrdconta := 0;
          vr_salvo_qtcontratos := 0;
          vr_salvo_vlemprst := 0;
          vr_salvo_vlsdevat := 0;
          vr_salvo_vlpreemp := 0;
          
          vr_salvo_vigente := 0;
          vr_vig_iddcarga := NULL;          
          vr_vig_dtliberacao :=  NULL;
          vr_vig_flglibera_pre_aprv := NULL;
          vr_vig_dtatualiza_pre_aprv := NULL;
          vr_vig_vl_limite := NULL;
          vr_vig_vl_disponivel := NULL;

          FOR rw_pos_diaria IN cr_pos_diaria ( pr_cdcooper => rw_crapcop.cdcooper
                                              ,pr_dtbase   => rw_crapdat.dtmvtolt
                                              ,pr_dias_bloqueado => pr_qtddias_blq ) LOOP -- busca posi��o di�ria
              if (   rw_pos_diaria.cdcooper <> vr_salvo_cdcooper
                  or rw_pos_diaria.nrdconta <> vr_salvo_nrdconta)
              and vr_salvo_cdcooper > 0 then
                  PC_GRV_TBBI_CPA_POSICAO_DIARIA;
                  if vr_dscritic is not null then
                     RAISE vr_exc_erro_diaria;
                  end if;
                  vr_salvo_vigente := 0;
                  vr_vig_iddcarga := NULL;
                  vr_vig_dtliberacao :=  NULL;
                  vr_vig_flglibera_pre_aprv := NULL;
                  vr_vig_dtatualiza_pre_aprv := NULL;
                  vr_vig_vl_limite := NULL;
                  vr_vig_vl_disponivel := NULL;
              END IF; 
              
              vr_salvo_cdcooper := rw_pos_diaria.cdcooper;
              vr_salvo_nrdconta := rw_pos_diaria.nrdconta;
              
              -- no primeiro registro tipo = 0 salva os valores da carga vigente
              -- a partir da segunda carga, despreza pois n�o � vigente
              if   rw_pos_diaria.tipo_reg = 0 THEN
                   if  vr_salvo_vigente = 0 THEN
                       vr_salvo_vigente := 1;
                       vr_vig_iddcarga := rw_pos_diaria.iddcarga;
                       vr_vig_dtliberacao :=  rw_pos_diaria.dtliberacao;
                       vr_vig_flglibera_pre_aprv := rw_pos_diaria.flglibera_pre_aprv;
                       vr_vig_dtatualiza_pre_aprv := rw_pos_diaria.dtatualiza_pre_aprv;
                       vr_vig_vl_limite := rw_pos_diaria.vl_limite;
                       vr_vig_vl_disponivel := rw_pos_diaria.vl_disponivel;
                   ELSE
                       CONTINUE;
                   END IF;
              END IF;
              -- salva valores do tipo de registro 9 que somente
              -- existe um por conta;
              vr_salvo_qtcontratos := rw_pos_diaria.qt_contratos;
              vr_salvo_vlemprst := rw_pos_diaria.vlemprst;
              vr_salvo_vlsdevat := rw_pos_diaria.vlsdevat;
              vr_salvo_vlpreemp := rw_pos_diaria.vlpreemp;
                                              
          END LOOP; -- busca posi��o di�ria
          
          IF vr_salvo_cdcooper > 0 then -- gravar o ultimo registro da cooperativa
             PC_GRV_TBBI_CPA_POSICAO_DIARIA;
             if  vr_dscritic is not null then
                 RAISE vr_exc_erro_diaria;
             end if;
          END IF;
          
          IF vr_qtdias_manter > 0 then
             -- Executar limpeza da TBBI_CPA_POSICAO_DIARIA retendo n dias
             pc_limpeza_pos_diaria( pr_tipo_excl => 1
                                   ,pr_qtdias_manter => vr_qtdias_manter
                                   ,pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_dtbase   => rw_crapdat.dtmvtolt);
          END IF;                                       
 
      END LOOP; -- buscando todas as cooperativas
      
      pc_controla_log(pr_dstiplog => 'F');

      COMMIT;
    
    EXCEPTION
      WHEN vr_exc_erro_diaria THEN
           ROLLBACK;
           -- Se foi retornado apenas c�digo
           IF  vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descri��o
             vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
           END IF;
           pc_controla_log(pr_dstiplog => 'E',
                           pr_dscritic => vr_dscritic);
           btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
           COMMIT;
           raise_application_error(-20501,vr_dscritic);          

  END pc_carga_pos_diaria_epr;
  
  -- Consulta informa��es da carga vigente do associado para trazer na tela ATENDA/DEP.A VISTA/PRINCIPAL (M441)
  PROCEDURE pc_consultar_carga_vig_ass       (pr_nrdconta  IN crapcpa.nrdconta%TYPE --> Conta do cooperado
                                             ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Sequencial do titular
                                             ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE --> CPF do operador juridico
                                             ,pr_xmllog    IN VARCHAR2              --> XML com informa��es de LOG
--											                       ,pr_des_reto OUT VARCHAR2             --> retorno (OK/NOK)
                                             ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                             ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                             ,pr_des_erro OUT VARCHAR2)  IS

    /* .............................................................................

     Programa: pc_consultar_carga_vig_associado
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Roberto Holz
     Data    : Julho/2017.                    Ultima atualizacao: 05/07/2017

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina para retornar dados para a tela ATENDA (Dep�sitos � Vista , aba Principal )

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 
    ---------------> CURSORES <-----------------

    -- Verifica se esta na tabela do pre-aprovado
    CURSOR cr_crapcpa (pr_cdcooper IN crapcpa.cdcooper%TYPE,
                       pr_nrdconta IN crapcpa.nrdconta%TYPE,
                       pr_idcarga  IN crapcpa.iddcarga%TYPE) IS
      SELECT cpa.vllimdis
            ,cpa.vlcalpre
            ,cpa.vlctrpre
            ,cpa.cdlcremp
        FROM crapcpa cpa
       WHERE cpa.cdcooper = pr_cdcooper
         AND cpa.nrdconta = pr_nrdconta
         AND cpa.iddcarga = pr_idcarga;
    rw_crapcpa cr_crapcpa%rowtype;

    CURSOR cr_carga_con (pr_iddcarga IN crapcpa.iddcarga%TYPE) IS
      SELECT nvl(carga.dtliberacao,carga.dtcalculo) dtliberacao
        FROM tbepr_carga_pre_aprv carga 
       WHERE carga.idcarga = pr_iddcarga;
    rw_carga_con cr_carga_con%ROWTYPE;
    
    CURSOR cr_param_conta (pr_cdcooper IN crapcpa.cdcooper%TYPE
                          ,pr_nrdconta IN crapcpa.nrdconta%TYPE) IS 
      SELECT conta.flglibera_pre_aprv
        FROM tbepr_param_conta conta
       WHERE conta.cdcooper  = pr_cdcooper
         AND conta.nrdconta  = pr_nrdconta;
    rw_param_conta cr_param_conta%ROWTYPE;
    
    --> Verifica se o associado pode obter o credido pre-aprovado
    CURSOR cr_crapass (pr_cdcooper IN crapcpa.cdcooper%TYPE
                      ,pr_nrdconta IN crapcpa.nrdconta%TYPE) IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Verifica se esta bloqueado o pre-aprovado 
    CURSOR cr_crappre (pr_cdcooper IN crappre.cdcooper%TYPE,
                       pr_inpessoa IN crappre.inpessoa%TYPE)IS
      SELECT pre.cdcooper
            ,pre.vllimctr
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;     

    --> Buscar linha de credito
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%TYPE,
                       pr_cdlcremp craplcr.cdlcremp%TYPE)IS
      SELECT lcr.txmensal
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --> Tratamento de erros
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);
    
      -- Variaveis de log
      vr_cdcooper  NUMBER;
      vr_cdoperad  VARCHAR2(100);
      vr_nmdatela  VARCHAR2(100);
      vr_nmeacao   VARCHAR2(100);
      vr_cdagenci  VARCHAR2(100);
      vr_nrdcaixa  VARCHAR2(100);
      vr_idorigem  VARCHAR2(100);

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_idcarga  tbepr_carga_pre_aprv.idcarga%type;
      vr_flgfound BOOLEAN;
      vr_flgcon   BOOLEAN;
      vr_vlctrpre crapepr.vlemprst%type;
      
    BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => pr_dscritic);
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

                          
    --> Somente o primeiro titular pode contratrar o pre-aprovado e nao 
    --  pode ser operador de conta juridica 
    IF pr_idseqttl > 1 OR pr_nrcpfope > 0 THEN
--      pr_des_reto := 'OK';
      RETURN;
    END IF;

    -- Busca a carga ativa
    EMPR0002.pc_busca_carga_ativa(pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idcarga  => vr_idcarga);
    --  Caso nao possua carga ativa
    IF vr_idcarga = 0 THEN
--      pr_des_reto := 'OK';
      RETURN;
    END IF;

    --> Verifica se esta na tabela do pre-aprovado
    OPEN cr_crapcpa(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idcarga  => vr_idcarga);
    FETCH cr_crapcpa INTO rw_crapcpa;

    -- caso nao esteja, aborta com ok
    IF cr_crapcpa%NOTFOUND THEN
      CLOSE cr_crapcpa;
--      pr_des_reto := 'OK';
      RETURN;  
    ELSE
      CLOSE cr_crapcpa;
    END IF; 

    --> Verifica se o associado pode obter o credido pre-aprovado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --> Associado nao cadastrado
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

          
      --> Verifica se esta o pre-aprovado esta liberado
    OPEN cr_param_conta(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
    FETCH cr_param_conta INTO rw_param_conta;
    vr_flgfound := cr_param_conta%FOUND;
    CLOSE cr_param_conta;
      
    -- Caso nao exista registro, conta como liberado
    IF vr_flgfound AND
       rw_param_conta.flglibera_pre_aprv = 0 THEN
--       pr_des_reto := 'OK';
       RETURN; 
    END IF;
    
    --> Verifica se esta bloqueado o pre-aprovado 
    OPEN cr_crappre(pr_cdcooper => rw_crapass.cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_crappre INTO rw_crappre;

    IF cr_crappre%NOTFOUND THEN
      CLOSE cr_crappre;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros pre-aprovado nao cadastrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crappre;
    END IF;

    --> Buscar linha de credito
    OPEN cr_craplcr (pr_cdcooper => rw_crappre.cdcooper,
                     pr_cdlcremp => rw_crapcpa.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;

    IF cr_craplcr%NOTFOUND THEN
       CLOSE cr_craplcr;
      vr_cdcritic := 363; --> Linha nao cadastrada.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplcr;
    END IF;

	--> Buscar data da carga
    OPEN cr_carga_con (pr_iddcarga => vr_idcarga);
    FETCH cr_carga_con INTO rw_carga_con;
    vr_flgcon := cr_carga_con%FOUND;
    CLOSE cr_carga_con;	
	
	  if  NOT vr_flgcon THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Carga Pr�-aprovado n�o encontrada';
	      RAISE vr_exc_erro;
    END IF;
    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'Dados'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Dados'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'carga'
                          ,pr_tag_cont => NULL
                          ,pr_des_erro => vr_dscritic);

    
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'carga'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'idcarga'
                          ,pr_tag_cont => vr_idcarga
                          ,pr_des_erro => vr_dscritic);    
 	
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'carga'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'vllimdis'
                          ,pr_tag_cont => rw_crapcpa.vllimdis
                          ,pr_des_erro => vr_dscritic);

     GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'carga'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dtliberacao'
                          ,pr_tag_cont => TO_CHAR(rw_carga_con.dtliberacao,'DD/MM/RRRR HH24:MI')
                          ,pr_des_erro => vr_dscritic);
                          
--     pr_des_reto := 'OK';
						  
    EXCEPTION
        WHEN vr_exc_erro THEN
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
          -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
          -- Existe para satisfazer exig�ncia da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_consultar_carga_vig_ass;

  -- M441 - Melhoria Pr�-Aprovado
  -- Gerar as informa��es de limite/carga vigente na crapsda
  -- Esta procedure ser� chamada no final da gera��o da crapsda (pc_cprs0001)
  -- Estas informa��es ser�o apresentadas na tela ATENDA > DEP�SITOS A VISTA > aba "Saldos Anteriores" 
  PROCEDURE pc_gerar_carga_vig_crapsda ( pr_cdcooper       IN crapcop.cdcooper%TYPE      --> C�digo da cooperativa (0-processa todas)
                                        ,pr_DTMVTOLT       IN crapsda.dtmvtolt%type      --> Data do movimento
                                        ,pr_dscritic      OUT VARCHAR2) IS               --> Descricao de erro.
    /* .............................................................................

     Programa: pc_gerar_carga_vig_crapsda
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Roberto Holz
     Data    : Julho/2017.                    Ultima atualizacao: 07/07/2017

     Dados referentes ao programa:

     Frequencia: Chamado no final do programa pc_cprs0001 (executa na di�ria)

     Objetivo  : Grava na tabela crapsda as informa��es de carga e valor de limites dispon�vel 
                 para o associado no momento da execu��o.

     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 

    ---------------> CURSORES <-----------------  
    CURSOR cr_limites_vig (pr_cdcooper       IN crapsda.cdcooper%TYPE,
                           pr_dtmvtolt       IN crapsda.dtmvtolt%TYPE) IS
    SELECT *
    FROM
    (
    SELECT
    SDA.DTMVTOLT,
    SDA.CDCOOPER,
    SDA.NRDCONTA,
    TAB.vllimdis,
    TAB.IDCARGA,
    TAB.TPCARGA,
    TAB.DTCALCULO,
    ROW_NUMBER()
      OVER (PARTITION BY SDA.CDCOOPER,SDA.NRDCONTA
            ORDER BY SDA.CDCOOPER,SDA.NRDCONTA) SEQ
    from
    CRAPSDA SDA,
    (
    SELECT 
    WT.CDCOOPER,
    WT.NRDCONTA,
    WT.VLLIMDIS,
    WT.IDCARGA,
    WT.TPCARGA,
    WT.DTCALCULO
    FROM
    (
                 SELECT carga.tpcarga,
                        carga.dtcalculo,
                        carga.idcarga,
                        cpa.cdcooper,
                        cpa.nrdconta,
                        cpa.vllimdis ,
                        param.flglibera_pre_aprv,
                        param.dtatualiza_pre_aprv
                   FROM tbepr_carga_pre_aprv carga,
                        crapcpa              cpa,
                        tbepr_param_conta    param
                  WHERE carga.indsituacao_carga = 1 -- Gerada
                    AND carga.flgcarga_bloqueada = 0 -- Liberada
                    AND carga.tpcarga = 2 -- Autom�tica
                    AND (carga.dtfinal_vigencia IS NULL OR
                        carga.dtfinal_vigencia >= TRUNC(SYSDATE))
                    and cpa.iddcarga = carga.idcarga
                    and param.cdcooper(+) = cpa.cdcooper
                    and param.nrdconta(+) = cpa.nrdconta
                 UNION ALL
                 SELECT carga.tpcarga,
                        carga.dtcalculo,
                        carga.idcarga,
                        cpa.cdcooper,
                        cpa.nrdconta,
                        cpa.vllimdis,
                        param.flglibera_pre_aprv,
                        param.dtatualiza_pre_aprv
                   FROM tbepr_carga_pre_aprv carga,
                        crapcpa              cpa,
                        tbepr_param_conta    param
                  WHERE carga.cdcooper = 3
                    AND carga.indsituacao_carga = 1 -- Gerada
                    AND carga.flgcarga_bloqueada = 0 -- Liberada
                    AND carga.tpcarga = 1 -- Manual
                    AND (carga.dtfinal_vigencia IS NULL OR
                        carga.dtfinal_vigencia >= TRUNC(SYSDATE))
                    AND cpa.iddcarga = carga.idcarga
                    and param.cdcooper(+) = cpa.cdcooper
                    and param.nrdconta(+) = cpa.nrdconta
          order by cdcooper, nrdconta , tpcarga , dtcalculo desc ) wt
    where 
         (wt.vllimdis <> 0)
     and (wt.flglibera_pre_aprv = 1 or wt.flglibera_pre_aprv is null) 
    ) TAB
    WHERE 
    SDA.DTMVTOLT = pr_DTMVTOLT   AND
    SDA.CDCOOPER = pr_cdcooper   AND 
    TAB.CDCOOPER = SDA.CDCOOPER  AND
    TAB.NRDCONTA = SDA.NRDCONTA 
    ORDER BY TAB.TPCARGA, TAB.DTCALCULO DESC
    ) XXX
    WHERE XXX.SEQ = 1;
    
    -- Variaveis de erro

    vr_exc_erro_diaria exception;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    vr_cdprogra  CONSTANT VARCHAR2(80) := 'PC_GERAR_CARGA_VIG_CRAPSDA';
    vr_nomdojob  CONSTANT VARCHAR2(80) := 'JBEPR_GERAR_CARGA_VIG_CRAPSDA';
    vr_flgerlog  BOOLEAN := FALSE;
    
    BEGIN
                     
      FOR rw_limites_vig IN cr_limites_vig(pr_cdcooper => pr_cdcooper,
                                           pr_DTMVTOLT => pr_DTMVTOLT) LOOP -- busca todos os registros em saldo e sua carga vigente
          UPDATE crapsda
             set crapsda.vllimcpa  = rw_limites_vig.vllimdis
           WHERE
                 crapsda.cdcooper = rw_limites_vig.cdcooper
             and crapsda.dtmvtolt = rw_limites_vig.dtmvtolt
             and crapsda.nrdconta = rw_limites_vig.nrdconta;                               
      end loop; -- busca todos os registros em saldo e sua carga vigente
      
    EXCEPTION
      WHEN OTHERS THEN
           vr_dscritic := 'Problema ao alterar crapsda (EMPR0002.PC_GERAR_CARGA_VIG_CRAPSDA ) : ' || SQLERRM;
           pr_dscritic := vr_dscritic;
  
  END pc_gerar_carga_vig_crapsda;
  
  PROCEDURE pc_executar_crps682 (pr_cdcritic OUT PLS_INTEGER     --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2) IS      --> Descri��o da cr�tica
    /* .............................................................................

     Programa: pc_executar_crps682
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Roberto Holz
     Data    : Agosto/2017.                    Ultima atualizacao: 05/08/2017

     Dados referentes ao programa:

     Frequencia: Chamado via JOB que executa aos domingos.

     Objetivo  : fazer execu��o do pc_crps682
     Observacao: -----

     Alteracoes: 
     ..............................................................................*/ 
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper <> 3
         AND cop.flgativo = 1
       ORDER BY 1;
    
    -- Variaveis de erro

    vr_exc_erro_crps682 exception;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    -- variaveis                                  
    vr_stprogra  PLS_INTEGER;
    vr_infimsol  PLS_INTEGER;

    vr_cdprogra  CONSTANT VARCHAR2(80) := 'PC_EXECUTAR_CRPS682';
    vr_nomdojob  CONSTANT VARCHAR2(80) := 'JBEPR_EXECUTAR_CRPS682';
    vr_flgerlog  BOOLEAN := FALSE;
    
    PROCEDURE pc_controla_log(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                              pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN

      --> Controlar gera��o de log de execu��o dos jobs
      BTCH0001.pc_log_exec_job( pr_cdcooper  => 3              --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                               ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

    END pc_controla_log;
              
    BEGIN
      pc_controla_log(pr_dstiplog => 'I');
      
      FOR rw_crapcop IN cr_crapcop LOOP  -- busca as cooperativas <> 3
        pc_crps682(pr_cdcooper => rw_crapcop.cdcooper,
                   pr_cdagenci => 0,
                   pr_iddcarga => 0,
                   pr_idparale => 0,
                   pr_flgresta => 0,
                   pr_flgexpor => 0,
                   pr_stprogra => vr_stprogra,
                   pr_infimsol => vr_infimsol,
                   pr_cdcritic => vr_cdcritic,
                   pr_dscritic => vr_dscritic);
                   
        IF  vr_cdcritic IS NOT NULL OR
           vr_dscritic IS NOT NULL THEN
           raise vr_exc_erro_crps682;
        END IF;
          
      END LOOP;  
      
      pc_controla_log(pr_dstiplog => 'F');
                                    
    EXCEPTION
      WHEN vr_exc_erro_crps682 THEN
           ROLLBACK;
           -- Se foi retornado apenas c�digo
           IF  vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descri��o
             vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
           END IF;
           pc_controla_log(pr_dstiplog => 'E',
                           pr_dscritic => vr_dscritic);
           btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
           COMMIT;
           raise_application_error(-20501,vr_dscritic);          
      
      WHEN OTHERS THEN
           vr_dscritic := 'Problema ao executar pc_executar_crps682 : ' || SQLERRM;
           pr_dscritic := vr_dscritic;
           ROLLBACK;
           -- Se foi retornado apenas c�digo
           IF  vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
             -- Buscar a descri��o
             vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
           END IF;
           pc_controla_log(pr_dstiplog => 'E',
                           pr_dscritic => vr_dscritic);
           btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                            ' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
           COMMIT;
           raise_application_error(-20501,vr_dscritic);          
                              
  END pc_executar_crps682;

  -- Function para buscar os cooperados com cr�dito pr�-aprovado ativo - Utilizada para envio de Notifica��es/Push
  FUNCTION fn_sql_contas_com_preaprovado RETURN CLOB IS
  BEGIN
    RETURN 'SELECT usu.cdcooper
                  ,usu.nrdconta
                  ,usu.idseqttl
                  ,''#valorcalculado='' || to_char(val.vlcalpre, ''fm99g999g990d00'') || '';'' ||
                   ''#valorcontratado='' || to_char(val.vlctrpre, ''fm99g999g990d00'') || '';'' ||
                   ''#valordisponivel='' || to_char(val.vllimdis, ''fm99g999g990d00'') dsvariaveis
              FROM (SELECT *
                      FROM (SELECT cpa.cdcooper
                                  ,cpa.nrdconta
                                  ,cpa.vlcalpre -- Valor Total Calculado
                                  ,cpa.vlctrpre -- Valor Contratado
                                  ,cpa.vllimdis -- Valor Dispon�vel
                                  ,row_number() OVER(PARTITION BY cpa.cdcooper, cpa.nrdconta ORDER BY car.tpcarga ASC, car.dtcalculo DESC) prioridade -- Prioriza as Manuais e mais recentes
                              FROM crapcpa              cpa
                                  ,tbepr_carga_pre_aprv car
                                  ,tbepr_param_conta    par
                             WHERE cpa.iddcarga = car.idcarga
                               AND cpa.cdcooper = par.cdcooper(+)
                               AND cpa.nrdconta = par.nrdconta(+)
                               AND car.indsituacao_carga = 1 -- Gerada
                               AND car.flgcarga_bloqueada = 0 -- Liberada
                               AND (car.dtfinal_vigencia IS NULL OR
                                   car.dtfinal_vigencia >= TRUNC(SYSDATE)) -- Vigente
                               AND NVL(par.flglibera_pre_aprv, 1) = 1 -- Valida se Pr�-Aprovado est� liberado para a conta espec�fica
                            )
                     WHERE prioridade = 1) val
                  ,vw_usuarios_internet usu
             WHERE val.cdcooper = usu.cdcooper
               AND val.nrdconta = usu.nrdconta
               AND val.vllimdis > 0';
  END fn_sql_contas_com_preaprovado;
  
  --> Procedimento para validar dados do credito pr�-aprovado (crapcpa)
  PROCEDURE pc_valida_dados_cpa ( pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                 ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                 ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                 ,pr_idorigem  IN INTEGER                  --> Id origem
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                 ,pr_vlemprst  IN crapepr.vlemprst%TYPE    --> Valor do emprestimo
                                 ,pr_diapagto  IN INTEGER                  --> Dia de pagamento
                                 ,pr_nrcpfope  IN NUMBER                   --> CPF do operador
                                 ,pr_cdcritic OUT NUMBER                   --> Retorna codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                 --> Retorna descri��o da critica
                                 ) IS
    /* .............................................................................

     Programa: pc_valida_dados_cpa        antigo: b1wgen0188.p/valida_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Odirlei Busana(AMcom)
     Data    : Junho/2018.                    Ultima atualizacao: 28/06/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Procedimento para validar dados do credito pr�-aprovado (crapcpa)

     Alteracoes: 19/10/2015 - Convers�o Progress -> Oracle (Odirlei/AMcom)


    ..............................................................................*/ 

    ---------------> CURSORES <-----------------

    -- Verifica se esta na tabela do pre-aprovado
    CURSOR cr_crapcpa (pr_cdcooper IN crapcpa.cdcooper%TYPE,
                       pr_nrdconta IN crapcpa.nrdconta%TYPE,
                       pr_idcarga  IN crapcpa.iddcarga%TYPE) IS
      SELECT cpa.vllimdis
            ,cpa.vlcalpre
            ,cpa.vlctrpre
            ,cpa.cdlcremp
        FROM crapcpa cpa
       WHERE cpa.cdcooper = pr_cdcooper
         AND cpa.nrdconta = pr_nrdconta
         AND cpa.iddcarga = pr_idcarga;
    rw_crapcpa cr_crapcpa%rowtype;

    CURSOR cr_carga_manual(pr_iddcarga IN crapcpa.iddcarga%TYPE) IS
      SELECT to_char(carga.dsmensagem_aviso) || ' Limite: R$ ' mensagem
        FROM tbepr_carga_pre_aprv carga 
       WHERE carga.idcarga = pr_iddcarga
         AND carga.tpcarga = 1 -- Manual
       ORDER BY carga.dtcalculo DESC;
    rw_carga_manual cr_carga_manual%ROWTYPE;
    
    CURSOR cr_param_conta (pr_cdcooper IN crapcpa.cdcooper%TYPE
                          ,pr_nrdconta IN crapcpa.nrdconta%TYPE) IS 
      SELECT conta.flglibera_pre_aprv
        FROM tbepr_param_conta conta
       WHERE conta.cdcooper  = pr_cdcooper
         AND conta.nrdconta  = pr_nrdconta;
    rw_param_conta cr_param_conta%ROWTYPE;
    
    --> Verifica se o associado pode obter o credido pre-aprovado
    CURSOR cr_crapass IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Verifica se esta bloqueado o pre-aprovado 
    CURSOR cr_crappre (pr_cdcooper IN crappre.cdcooper%TYPE,
                       pr_inpessoa IN crappre.inpessoa%TYPE)IS
      SELECT pre.cdcooper
            ,pre.vllimctr
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;     

    -- Cursor generico de calendario
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    ---------------> VARIAVEIS <----------------       

    --> Tratamento de erros
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(4000);

    vr_idx       PLS_INTEGER;
    vr_idxcpa    PLS_INTEGER;
    vr_idcarga   tbepr_carga_pre_aprv.idcarga%TYPE;
    vr_tab_dados_cpa typ_tab_dados_cpa;
    vr_des_reto      VARCHAR2(100);
    vr_tab_erro      gene0001.typ_tab_erro;
    vr_flgmanual BOOLEAN;
    vr_flgfound  BOOLEAN;
    
    vr_dstextab  craptab.dstextab%TYPE;
    vr_hhsicini  NUMBER;               
    vr_hhsicfim  NUMBER;
    
    

  BEGIN
  
    IF pr_vlemprst = 0 THEN
      vr_dscritic := 'Valor da contratacao nao informado';
      RAISE vr_exc_erro;
    END IF; --> IF par_vlemprst = 0 
    
    IF pr_diapagto <= 0 OR 
       pr_diapagto >= 28 THEN
      vr_dscritic := 'Dia do vencimento nao permitido';
      RAISE vr_exc_erro;  
       
    END IF; 
    
    --> Somente o primeiro titular irar poder contratar 
    IF pr_idseqttl > 1 THEN
      vr_cdcritic := 79;
      RAISE vr_exc_erro;    
    END IF;
    
    pc_busca_dados_cpa( pr_cdcooper => pr_cdcooper,
                        pr_cdagenci => pr_cdagenci,
                        pr_nrdcaixa => pr_nrdcaixa,
                        pr_cdoperad => pr_cdoperad,
                        pr_nmdatela => pr_nmdatela,
                        pr_idorigem => pr_idorigem,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => pr_idseqttl,
                        pr_nrcpfope => pr_nrcpfope,
                        pr_tab_dados_cpa => vr_tab_dados_cpa,
                        pr_des_reto => vr_des_reto,
                        pr_tab_erro => vr_tab_erro
                        );
                                                
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN 
      IF vr_tab_erro.count > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Erro ao buscar dados do credito pre-aprovado.';
      END IF;
      
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxcpa := vr_tab_dados_cpa.first;
    
    IF nvl(vr_idxcpa,0) = 0 THEN
      vr_dscritic := 'Associado nao possui credito pre-aprovado.';
      RAISE vr_exc_erro;
    END IF;  
    
    --> Valor a ser contratado nao pode ser maior que o limite disponivel 
    IF pr_vlemprst > vr_tab_dados_cpa(vr_idxcpa).vldiscrd THEN
      vr_dscritic := 'Valor informado para contratacao maior que o valor do limite pre-aprovado '||
                     'disponivel. Valor disponivel: '|| 
                     gene0002.fn_mask(vr_tab_dados_cpa(vr_idxcpa).vldiscrd,'zzz,zzz,zz9.99');
      RAISE vr_exc_erro;               
    END IF;   
    
    --> Verifica se esta bloqueado o pre-aprovado 
    OPEN cr_crappre(pr_cdcooper => vr_tab_dados_cpa(vr_idxcpa).cdcooper,
                    pr_inpessoa => vr_tab_dados_cpa(vr_idxcpa).inpessoa);
    FETCH cr_crappre INTO rw_crappre;

    IF cr_crappre%NOTFOUND THEN
      CLOSE cr_crappre;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros pre-aprovado nao cadastrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crappre;
    END IF;   
    
    --> Caso a origem for Internet Banking ou TAA
    IF pr_idorigem IN(3,4) THEN
      --> Valor a ser contratado nao pode ser menor que limite contratado
      IF pr_vlemprst < rw_crappre.vllimctr THEN
        vr_dscritic := 'Valor informado para contratacao nao pode ser menor que R$ '|| 
                       gene0002.fn_mask(rw_crappre.vllimctr,'zzz,zzz,zz9.99');          
    
      END IF;
    
    
    
      -- Busca dstextab
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'HRCTRPREAPROV'
                                               ,pr_tpregist => 00);
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := 'Parametros de Horario nao cadastrado';
        RAISE vr_exc_erro;
      END IF;        
      
      vr_hhsicini := gene0002.fn_busca_entrada( pr_postext => 1,
                                                pr_dstext  => vr_dstextab,
                                                pr_delimitador => ' ');
      vr_hhsicfim := gene0002.fn_busca_entrada( pr_postext => 2,
                                                pr_dstext  => vr_dstextab,
                                                pr_delimitador => ' ');
      IF gene0002.fn_busca_time < vr_hhsicini OR 
         gene0002.fn_busca_time > vr_hhsicfim THEN
        vr_dscritic := 'Horario nao permitido para efetuar o pre-aprovado';
        RAISE vr_exc_erro;
      END IF;
      
      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      IF rw_crapdat.inproces >= 3 THEN
        vr_dscritic := 'Horario nao permitido para efetuar o pre-aprovado';
      END IF;  
    END IF; -- pr_idorigem IN(3,4)

  EXCEPTION
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, 
                                                 pr_dscritic => vr_dscritic);
      
      END IF;
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      -- Retorno n�o OK
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro na rotina EMPR0002.pc_valida_dados_cpa: ' ||sqlerrm;
      
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
      
  END pc_valida_dados_cpa;

  
END EMPR0002;
/
