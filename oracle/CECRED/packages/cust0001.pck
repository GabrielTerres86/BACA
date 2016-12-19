 CREATE OR REPLACE PACKAGE CECRED.CUST0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : CUST0001
--  Sistema  : Rotinas genericas focando nas funcionalidades da custodia de cheque
--  Sigla    : CUST
--  Autor    : Daniel Zimmermann
--  Data     : Abril/2014.                   Ultima atualizacao: 01/09/2015
--
-- Dados referentes ao programa:
--
-- Frequencia: -----
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle

-- Alteracoes: 11/06/2014 - Alterada pc_ver_cheque para somente emitir a crítica 950 se a 
--                          crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli )
--              
--             12/06/2014 - Adicionado os campos na craplot que estavam faltando (Rafael).
--                        - Ajuste no cursor cr_crapdcc para buscar somente registros de
--                          retorno (crapdcc.intipmvt = 2). (Rafael)
--
--             13/06/2014 - Alterado procedure pc_ver_cheque e pc_contra_ordem. Open em
--                          dois cursores sem fetch. (Rafael)
--
--             21/05/2015 - Adicionar a procedure pc_custodia_cheque_manual e a 
--                          pc_valida_conta_custodiar, e realizar as alterações necessárias 
--                          para validar o cheque e custodiar os os cheques.
--                          (Douglas - Melhoria 060 - Custódia de Cheques)
--
--             11/06/2015 - Corrigir condição de IF na rotina pc_ver_cheque, afim de evitar erro
--                          relatado no chamado 294466 (Kelvin) 
--
--              26/08/2015 - Inclusao do parametro pr_nrcheque na procedure pc_tarifa_resgate_cheq_custod
--                           e alterado o parametro pr_cdpesqbb da procedure 
--                           TARI0001.pc_cria_lan_auto_tarifa (Jean Michel).
--
--             01/09/2015 - Adicionado cursor na pc_validar_cheque para utilizar a data 
--                          da craphcc na validação de 8 dias úteis quando recebido por
--                          arquivo (Douglas - Chamado 324178)     
--
--	           19/12/2016 - Ajuste incorporação Transulcred (Daniel)        
---------------------------------------------------------------------------------------------------------------

  -- Função para converter ocorrencia para padrão CNAB
  FUNCTION fn_ocorrencia_cnab(pr_cdocorre IN NUMBER)
                                   RETURN NUMBER; 

  -- Procedure para validar arquivo de custodia de cheque
  PROCEDURE pc_validar_arquivo  (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                ,pr_nrremess     OUT craphcc.nrremret%TYPE
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro
                                
      
  /* Procedure para verificar valor dos convenios */
  PROCEDURE pc_rejeitar_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado  
                                ,pr_nrconven      IN CRAPHCC.NRCONVEN%TYPE  -- Numero do Convenio
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento  
                                ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro                          
   
                             
   /* Procedure para gerar arquivo de retorno */               
   PROCEDURE pc_gerar_arquivo_retorno (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                      ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                      ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                      ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                      ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                      ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                      ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                      ,pr_nmarquiv     OUT VARCHAR2               -- Nome do Arquivo
                                      ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                      ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro
    
    -- Procedure para processar os registos na wt_crapdcc                
    PROCEDURE pc_processar_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                   ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                   ,pr_nrremess      IN craphcc.nrremret%TYPE
                                   ,pr_nrremret     OUT craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                   ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro 
       
    
    -- Procedure para conciliar cheques             
    PROCEDURE pc_conciliar_cheque_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                          ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                          ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                          ,pr_dsdocmc7      IN crapdcc.dsdocmc7%TYPE  -- CMC7
                                          ,pr_nrseqarq      IN crapdcc.nrseqarq%TYPE  -- Numero Sequencial
                                          ,pr_intipmvt      IN crapdcc.intipmvt%TYPE  -- Tipo de Movimento (1-Arquivo/3-Manual)
                                          ,pr_inconcil      IN crapdcc.inconcil%TYPE  -- Indicador de conciliar (0-Pendente, 1-OK, 2-Sem físico)
                                          ,pr_dtmvtolt      IN crapass.dtmvtolt%TYPE
                                          ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                          ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro                               

    -- Procedure para custodiar cheques               
    PROCEDURE pc_custodiar_cheques (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                   ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                   ,pr_intipmvt      IN craphcc.intipmvt%TYPE  -- Tipo de Movimento (1-Arquivo/3-Manual)
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                   ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro                                  
    
    -- Procedure para logar no arquivo cst_arquivo.log
    PROCEDURE pc_logar_cst_arquivo(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_textolog      IN VARCHAR2               -- Texto a ser Incluso Log
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro 
                                  

    PROCEDURE pc_gerar_arquivo_log(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_descerro      IN VARCHAR2               -- Descrição do Erro
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2);             -- Descricao do erro   
                                  
                                                       
    PROCEDURE pc_ver_cheque(pr_cdcooper      IN crapcop.cdcooper%TYPE
                           ,pr_nrcustod      IN crapass.nrdconta%TYPE     -- Numero Conta do cooperado  
                           ,pr_cdbanchq      IN crapcst.cdbanchq%TYPE
                           ,pr_cdagechq      IN crapcst.cdagechq%TYPE
                           ,pr_nrctachq      IN crapcst.nrctachq%type
                           ,pr_nrcheque      IN crapcst.nrcheque%TYPE
                           ,pr_nrddigc3      IN crapcst.nrddigc3%TYPE
                           ,pr_vlcheque      IN crapcst.vlcheque%TYPE
                           ,pr_nrdconta     OUT crapass.nrdconta%TYPE
                           ,pr_dsdaviso     OUT VARCHAR2                         
                           ,pr_cdcritic     OUT INTEGER               -- Código do erro
                           ,pr_dscritic     OUT VARCHAR2);          -- Descricao do erro
    
    PROCEDURE pc_contra_ordem(pr_cdcooper      IN crapcop.cdcooper%TYPE
                             ,pr_cdbanchq      IN crapcst.cdbanchq%TYPE
                             ,pr_cdagechq      IN crapcst.cdagechq%TYPE
                             ,pr_nrctachq      IN crapcst.nrctachq%TYPE
                             ,pr_nrcheque      IN crapcst.nrcheque%TYPE
                             ,pr_incheque      IN crapfdc.incheque%TYPE
                             ,pr_dsdaviso     OUT VARCHAR2
                             ,pr_cdcritic     OUT INTEGER               -- Código do erro
                             ,pr_dscritic     OUT VARCHAR2);
                          
    PROCEDURE pc_ver_associado(pr_cdcooper      IN crapcop.cdcooper%TYPE
                              ,pr_nrdconta      IN crapass.nrdconta%TYPE
                              ,pr_dsdaviso     OUT VARCHAR2
                              ,pr_cdcritic     OUT INTEGER            -- Código do erro
                              ,pr_dscritic     OUT VARCHAR2);
                              
    PROCEDURE pc_custodia_cheque_manual(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                       ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador 
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

    PROCEDURE pc_valida_conta_custodiar(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);            --> Erros do processo


    PROCEDURE pc_tarifa_resgate_cheq_custod(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Cooperativa
                                           ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- Conta do cooperado
                                     	     ,pr_inpessoa  IN crapass.inpessoa%TYPE  -- Tipo de pessoa
                                           ,pr_nrcheque  IN crapcst.nrcheque%TYPE  -- Numero do Cheque
                                           ,pr_cdcritic OUT INTEGER                -- Codigo do erro
                                           ,pr_dscritic OUT VARCHAR2);             -- Descricao erro
                                       
END CUST0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CUST0001 IS

---------------------------------------------------------------------------------------------------------------
--
--  Programa : CUST0001
--  Sistema  : Rotinas genericas focando nas funcionalidades da custodia de cheque
--  Sigla    : CUST
--  Autor    : Daniel Zimmermann
--  Data     : Abril/2014.                   Ultima atualizacao: 11/01/2016
--
-- Dados referentes ao programa:
--
-- Frequencia: Sempre que Chamado
-- Objetivo  : Agrupar rotinas genéricas dos sistemas Oracle

-- Alteracoes:  11/06/2014 - Alterada pc_ver_cheque para somente emitir a crítica 950 se a 
--                           crapfdc.dtlibtic >= data do movimento (SD. 163588 - Lunelli)
--              
--              12/06/2014 - Adicionado os campos na craplot que estavam faltando (Rafael).
--                         - Ajuste no cursor cr_crapdcc para buscar somente registros de
--                           retorno (crapdcc.intipmvt = 2). (Rafael)
--
--              13/06/2014 - Alterado procedure pc_ver_cheque e pc_contra_ordem. Open em
--                           dois cursores sem fetch. (Rafael)
--                           
--              30/10/2014 - Alterado recebimento de parametro da procedure 
--                           gene0005.pc_existe_conta_integracao na pc_ver_cheque. (Reinert)
--
--              04/02/2015 - Tratamento na procedure pc_ver_cheque ref a migracao 
--                           e incorporacao. (SD 238692 - Rafael).
--
--              04/05/2015 - Nao permitir conciliar cheques já custodiados (SD 269758 - Rafael).
--
--              21/05/2015 - Adicionar a procedure pc_custodia_cheque_manual e a 
--                           pc_valida_conta_custodiar. Criar procedure com as validações
--                           do cheque, e ajustar para que seja utilizado pelas procedures
--                           de validação do arquivo e concilisção do cheque
--                           (Douglas - Melhoria 060 - Custódia de Cheques)
--
--              11/06/2015 - Corrigir condição de IF na rotina pc_ver_cheque, afim de evitar erro
--                           relatado no chamado 294466 (Kelvin) 
--
--              25/06/2015 - Ajustado a quantidade de dias para a custódia de cheques. 
--                         - Adicionado validação dos bancos que não podem ser custodiados, 
--                           conforme tela lancsti.p
--                         - Removido a criação de registro de retorno para os cheques 
--                           custodiados manualmente. (Douglas - Chamado 300777)
--
--              26/06/2015 - Criado cursor para identificar o intipmvt na custódia de cheque
--                           (Douglas - 301650)
--
--              26/08/2015 - Inclusao do parametro pr_nrcheque na procedure pc_tarifa_resgate_cheq_custod
--                           e alterado o parametro pr_cdpesqbb da procedure 
--                           TARI0001.pc_cria_lan_auto_tarifa (Jean Michel).
--
--              04/01/2016 - Ajuste na leitura da tabela CRAPOCC para utilizar UPPER nos campos VARCHAR
--                           pois será incluido o UPPER no indice desta tabela - SD 375854
--                           (Adriano).  
--
--              11/01/2016 - Ajuste na leitura da tabela CRAPOCC para utilizar UPPER nos campos VARCHAR
--                           pois será incluido o UPPER no indice desta tabela - SD 375854
--                           (Adriano).  
--
--              11/01/2016 - Ajuste no cursor da crapcdb na validacao para colocar cheque em custodia
--                           'pc_validar_cheque' (Tiago/Elton SD343909).
--
--              11/04/2016 - Ajuste para adicionar o arquivo no FTP apenas quando possuir informacao
--                           no arquivo de retorno 'pc_gerar_arquivo_retorno' (Douglas - Chamado 397933)
--
--              17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)
---------------------------------------------------------------------------------------------------------------

  -- Descricao e codigo da critica 
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  
  -- Função para converter ccocorrencia do sistema para 
  -- padrão CNAB.
  FUNCTION fn_ocorrencia_cnab(pr_cdocorre IN NUMBER)
                                   RETURN NUMBER IS

  vr_cdocorre NUMBER := 0;

  BEGIN     
    
    IF NVL(pr_cdocorre,0) > 0 THEN
     -- Retorno ver_cheque -> Para (CNAB)
     CASE pr_cdocorre 
       WHEN 9 THEN
         vr_cdocorre := 17; -- Conta do Cheque Inválida;
       WHEN 97 THEN
         vr_cdocorre := 81; -- Cheque ja compensado;
       WHEN 121 THEN
         vr_cdocorre := 84; -- Cheque do custodiante;
       WHEN 108 THEN 
         vr_cdocorre := 85; -- Talonário não emitido;
       WHEN 109 THEN 
         vr_cdocorre := 86; -- Talonário não retirado;
       WHEN 96 THEN 
         vr_cdocorre := 87; -- Cheque com contra-ordem;
       WHEN 101 THEN 
         vr_cdocorre := 87; -- Cheque com contra-ordem;
       WHEN 320 THEN 
         vr_cdocorre := 88; -- Cheque cancelado;
       WHEN 646 THEN 
         vr_cdocorre := 89; -- Cheque transferência (TB);
       WHEN 286 THEN 
         vr_cdocorre := 90; -- Cheque salário não existe;
       WHEN 91 THEN 
         vr_cdocorre := 11; -- Valor do cheque errado;
       WHEN 950 THEN 
         vr_cdocorre := 92; -- Cheque cst/descto em outra IF;
       WHEN 95 THEN 
         vr_cdocorre := 93; -- Conta bloqueada/excluída;
       WHEN 410 THEN 
         vr_cdocorre := 93; -- Conta bloqueada/excluída;
       ELSE
         vr_cdocorre := 99; -- Erro Validação;  
       END CASE;
    
    RETURN vr_cdocorre;
    
    END IF;
  
  END fn_ocorrencia_cnab;
  
  -- Validação do Cheque para saber se ele pode ser custodiado
  PROCEDURE pc_validar_cheque(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                             ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                             ,pr_dsdocmc7  IN crapdcc.dsdocmc7%TYPE --> CMC-7 do Cheque
                             ,pr_cdbanchq  IN NUMBER                --> Banco do Cheque
                             ,pr_cdagechq  IN NUMBER                --> Agência do Cheque
                             ,pr_cdcmpchq  IN NUMBER                --> COMPE do Cheque
                             ,pr_nrctachq  IN NUMBER                --> Conta do Cheque
                             ,pr_nrcheque  IN NUMBER                --> Número do Cheque
                             ,pr_dtlibera  IN DATE                  --> Data de Liberação do Cheque
                             ,pr_vlcheque  IN NUMBER                --> Valor do Cheque
                             ,pr_nrremret  IN crapdcc.nrremret%TYPE --> Número da Remessa
                             ,pr_dtmvtolt  IN DATE                  --> Data de Movimentação
                             ,pr_intipmvt  IN craphcc.intipmvt%TYPE --> Tipo de Movimento (1-remessa/2-retorno/3-manual)
                             ,pr_inchqcop OUT NUMBER                --> Tipo de cheque recebido (0=Outros bancos, 1=Cooperativa)
                             ,pr_cdtipmvt OUT wt_custod_arq.cdtipmvt%TYPE --> Codigo do Tipo de Movimento
                             ,pr_cdocorre OUT wt_custod_arq.cdocorre%TYPE --> Codigo da Ocorrencia
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de erros

  BEGIN
    /* .............................................................................
    Programa: pc_validar_cheque
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 15/05/2015                        Ultima atualizacao: 09/03/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para realizar as validação do CMC-7 do cheque

    Alteracoes: 25/06/2015 - Adicionado validação dos bancos que não podem ser custodiados
                           - Ajustar a validação de datas para a custódia por arquivo e a 
                             custódia manual. (Douglas - Chamado 300777)
                             
                01/09/2015 - Adicionado cursor para utilizar a data da craphcc na validação de 8 dias
                             úteis quando recebido por arquivo (Douglas - Chamado 324178)             
                             
                11/01/2016 - Ajuste no cursor da crapcdb na validacao para colocar cheque em custodia
                             'pc_validar_cheque' (Tiago/Elton SD343909)

                09/03/2016 - Adicionar validacao para nao permitir a liberacao de custodia de cheque
                             no ultimo dia util do ano (Douglas - Chamado 391928)
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;

      vr_nrdcampo NUMBER;
      vr_lsdigctr VARCHAR2(2000);
      vr_nrdconta_ver_cheque NUMBER;
      vr_dsdaviso VARCHAR2(4000);

      vr_dtmvtolt DATE;
      vr_auxdata  DATE;
      vr_auxqtd   NUMBER;
      vr_dtminimo DATE;
      vr_qtddmini NUMBER;

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

      -- Seleciona Dados Custodia
      CURSOR cr_crapcst (pr_cdcooper IN crapcst.cdcooper%TYPE
                        ,pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
                        ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
                        ,pr_cdagechq IN crapcst.cdagechq%TYPE
                        ,pr_nrctachq IN crapcst.nrctachq%TYPE
                        ,pr_nrcheque IN crapcst.nrcheque%TYPE) IS
        -- Validar se o cheque está custodiado utilizando os campos do indice CRAPCST##CRAPCST5
        SELECT crapcst.nrcheque
          FROM crapcst crapcst
         WHERE crapcst.cdcooper = pr_cdcooper 
           AND crapcst.cdcmpchq = pr_cdcmpchq 
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

      -- Dados Detalhe Custodia de Cheque
      CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
                       ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                       ,pr_nrremret IN crapdcc.nrremret%TYPE
                       ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE) IS
        SELECT 
          COUNT(*) qtdCheques
        FROM crapdcc crapdcc
        WHERE crapdcc.cdcooper = pr_cdcooper 
          AND crapdcc.nrdconta = pr_nrdconta
          AND crapdcc.nrremret = pr_nrremret
          AND crapdcc.dsdocmc7 = pr_dsdocmc7
          AND crapdcc.intipmvt in (1,3); -- 1 - Remessa / 3 - Retorno
      rw_crapdcc cr_crapdcc%ROWTYPE; 

     CURSOR cr_craphcc (pr_cdcooper IN craphcc.cdcooper%TYPE
                       ,pr_nrdconta IN craphcc.nrdconta%TYPE
                       ,pr_nrremret IN craphcc.nrremret%TYPE) IS
       SELECT craphcc.dtmvtolt
       FROM craphcc craphcc
       WHERE craphcc.cdcooper = pr_cdcooper AND
             craphcc.nrdconta = pr_nrdconta AND
             craphcc.nrremret = pr_nrremret AND
             craphcc.intipmvt = 1; -- REM
     rw_craphcc cr_craphcc%ROWTYPE;

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
      
      -- Validação de bancos que está na LANCSTI.p
      /* Não permitir a inclusão de cheques para os bancos 012, 231, 353, 356, 409 e 479 */
      IF pr_cdbanchq IN (012,231,353,356,409,479) THEN
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
          pr_cdocorre := nvl(pr_cdocorre,'01');  
        END IF;
        -- Se possui critica de Tipo de Movimentação e Ocorrencia
        -- Executa RAISE para sair das validações
        RAISE vr_exc_saida;
      END IF;
      
      -- Validar o tipo de custódia Arquivo/Manual
      IF pr_intipmvt = 1 THEN
        -- Buscar as informações do Header do arquivo
        OPEN cr_craphcc(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrremret => pr_nrremret);
        FETCH cr_craphcc INTO rw_craphcc;
        IF cr_craphcc%FOUND THEN
          -- Se encontrar o headre, utilizar a data do arquivo
          vr_dtmvtolt := rw_craphcc.dtmvtolt;
        ELSE 
          -- Caso não encontre utilizamos a data do parâmetro
          vr_dtmvtolt := pr_dtmvtolt;
        END IF;
        CLOSE cr_craphcc;
        
        -- Se a custódia é por arquivo, validar 8 dias
        -- Validar a data 
        vr_auxdata := vr_dtmvtolt;
        vr_auxqtd  := 0;
        -- Bloco de repetição para calcular a data atual + 8 dias uteis
        LOOP  
                   
          vr_auxdata := vr_auxdata + 1;
          vr_auxqtd  := vr_auxqtd  + 1;
                                   
          vr_auxdata := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper,
                                                    pr_dtmvtolt  => vr_auxdata,
                                                    pr_tipo      => 'P',    -- Proxima
                                                    pr_feriado   => TRUE,
                                                    pr_excultdia => FALSE);
                                                             
          EXIT WHEN vr_auxqtd = 8;  -- 8 Dias Uteis                                          
        END LOOP;  
                 
        IF ( pr_dtlibera < vr_auxdata ) THEN
          -- (21,12) Data para Deposito do Cheque Invalida 
          pr_cdtipmvt := nvl(pr_cdtipmvt,21);
          pr_cdocorre := nvl(pr_cdocorre,'12'); 
          -- Se possui critica de Tipo de Movimentação e Ocorrencia
          -- Executa RAISE para sair das validações
          RAISE vr_exc_saida;
        END IF; 
      ELSE 
        /* Se o tipo de movimento for diferente de ARQUIVO, validamos 2 dias úteis para custódia */
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

        -- Se o cheque não estiver no prazo mínimo ou no 
        -- prazo máximo (1095 dias)
        IF   pr_dtlibera <= vr_dtminimo OR
             pr_dtlibera > (pr_dtmvtolt + 1095)   THEN
          -- Data para Deposito invalida
          pr_cdtipmvt := nvl(pr_cdtipmvt,21);
          pr_cdocorre := nvl(pr_cdocorre,'12');
          -- Se possui critica de Tipo de Movimentação e Ocorrencia
          -- Executa RAISE para sair das validações
          RAISE vr_exc_saida;
        END IF;
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
      OPEN cr_crapcst(pr_cdcooper => pr_cdcooper
                     ,pr_cdcmpchq => pr_cdcmpchq
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
      
      -- Validar se o cheque já foi inserido nesta remessa
      OPEN cr_crapdcc(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrremret => pr_nrremret
                     ,pr_dsdocmc7 => pr_dsdocmc7);
        FETCH cr_crapdcc
          INTO rw_crapdcc;
        -- Se não encontrar
        IF cr_crapdcc%FOUND THEN
          CLOSE cr_crapdcc;
          IF nvl(rw_crapdcc.qtdCheques,0) > 1 THEN
            -- (21,09) Cheque em Duplicidade
            pr_cdtipmvt := nvl(pr_cdtipmvt,21);
            pr_cdocorre := nvl(pr_cdocorre,'09');
            -- Se possui critica de Tipo de Movimentação e Ocorrencia
            -- Executa RAISE para sair das validações
            RAISE vr_exc_saida;
          END IF;
        END IF; 
        
        -- Fecha o cursor
        CLOSE cr_crapdcc;
      
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
  END pc_validar_cheque;
  
  -- Procedure para validar arquivo custodia
  PROCEDURE pc_validar_arquivo  (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                ,pr_nrremess     OUT craphcc.nrremret%TYPE
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro

  BEGIN
    
  DECLARE
  
     -- CURSORES
     
     --Selecionar os dados da tabela de Associados
     CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
       SELECT crapass.nrdconta
             ,crapass.cdagenci
             ,crapass.nrcpfcgc
             ,crapass.inpessoa
       FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND   crapass.nrdconta = pr_nrdconta;
     rw_crapass cr_crapass%ROWTYPE; 
     
     -- Seleciona os dados da Cooperativa
     CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
       SELECT crapcop.nrdconta
             ,crapcop.cdagectl
       FROM crapcop crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
     rw_crapcop cr_crapcop%ROWTYPE; 
     
     -- Seleciona os dados do Convenio
     CURSOR cr_crapccc (pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapcop.nrdconta%TYPE
                       ,pr_nrconven IN crapccc.nrconven%TYPE) IS
       SELECT crapccc.flghomol
       FROM crapccc crapccc
       WHERE crapccc.cdcooper = pr_cdcooper AND
             crapccc.nrdconta = pr_nrdconta AND
             crapccc.nrconven = pr_nrconven;
     rw_crapccc cr_crapccc%ROWTYPE;
     
     -- Selecionar os dados da Remessa
     CURSOR cr_craphcc (pr_cdcooper IN craphcc.cdcooper%TYPE
                       ,pr_nrdconta IN craphcc.nrdconta%TYPE
                       ,pr_nrconven IN craphcc.nrconven%TYPE
                       ,pr_nrremret IN craphcc.nrremret%TYPE) IS
       SELECT craphcc.nrremret
       FROM craphcc craphcc
       WHERE craphcc.cdcooper = pr_cdcooper AND
             craphcc.nrdconta = pr_nrdconta AND
             craphcc.nrconven = pr_nrconven AND
             craphcc.nrremret = pr_nrremret AND
             craphcc.intipmvt = 1; -- REM
     rw_craphcc cr_craphcc%ROWTYPE;
     
     -- Dados da Work-Table wt_custod_arq
     CURSOR cr_wt_custod_arq (pr_dsdocmc7 IN wt_custod_arq.dsdocmc7%TYPE) IS
       SELECT wt_custod_arq.dsdocmc7
         FROM wt_custod_arq wt_custod_arq
        WHERE wt_custod_arq.dsdocmc7 = pr_dsdocmc7;
     rw_wt_custod_arq cr_wt_custod_arq%ROWTYPE;
     
     -- Declarando handle do Arquivo
     vr_ind_arquivo utl_file.file_type;
     vr_des_erro VARCHAR2(4000);
     
     -- Variaveis para Tratamento erro
     vr_exc_saida EXCEPTION;
     vr_exc_erro  EXCEPTION;
     
     -- Nome do Arquivo
     vr_nmarquiv  VARCHAR2(200);
     vr_nmdireto  VARCHAR2(4000);
     
     vr_des_linha VARCHAR2(1000);
     
     -- Numero Remessa/Retorno
     vr_nrremret craphcc.nrremret%TYPE;
     
     -- Contador Registros Detalhe
     vr_contador NUMBER;
     
     vr_stsnrcal BOOLEAN;
     
     -- Tipo de Pessoa
     vr_inpessoa NUMBER;
     
     -- Campos do CMC7
     vr_dsdocmc7 VARCHAR2(40);
     vr_cdbanchq NUMBER; 
     vr_cdagechq NUMBER;
     vr_cdcmpchq NUMBER;
     vr_nrctachq NUMBER;
     vr_nrcheque NUMBER;
     
     -- typ_tab_erro Generica
     pr_tab_erro GENE0001.typ_tab_erro;
     
     -- Controle se Arquivo possui Trailer Arquivo e Lote
     vr_trailer_lot BOOLEAN;
     vr_trailer_arq BOOLEAN;
     vr_header_lot BOOLEAN;
     vr_header_arq BOOLEAN;
     
     vr_cdtipmvt wt_custod_arq.cdtipmvt%TYPE;
     vr_cdocorre wt_custod_arq.cdocorre%TYPE;
     
     vr_wt_cdfinmvt wt_custod_arq.cdfinmvt%TYPE;
     vr_wt_cdentdad wt_custod_arq.cdentdad%TYPE;
     vr_wt_cdtipemi wt_custod_arq.cdtipemi%TYPE;
     vr_wt_vlcheque wt_custod_arq.vlcheque%TYPE;
     vr_wt_dtdcaptu wt_custod_arq.dtdcaptu%TYPE;
     vr_wt_dtlibera wt_custod_arq.dtlibera%TYPE;
     vr_wt_dsusoemp wt_custod_arq.dsusoemp%TYPE;
     vr_wt_nrinsemi wt_custod_arq.nrinsemi%TYPE;
     
     vr_nrseqarq NUMBER;
     
     -- Indicativo Cheque Cooperativa
     vr_inchqcop NUMBER;
  
  BEGIN
     vr_nmarquiv := pr_nmarquiv;
     
     vr_nrseqarq := 0;
     vr_contador := 0;
     
     vr_trailer_lot := FALSE;
     vr_trailer_arq := FALSE;
     vr_header_lot  := FALSE;
     vr_header_arq  := FALSE;
     
     -- Define o diretório do arquivo
     vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/upload') ;
  
     -- Abrir Arquivo
     gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto            --> Diretório do arquivo
                             ,pr_nmarquiv => vr_nmarquiv            --> Nome do arquivo
                             ,pr_tipabert => 'R'                    --> Modo de abertura (R,W,A)
                             ,pr_utlfileh => vr_ind_arquivo         --> Handle do arquivo aberto
                             ,pr_des_erro => vr_des_erro);          --> Erro
     IF vr_des_erro IS NOT NULL THEN
       --Levantar Excecao
       RAISE vr_exc_saida;
     END IF;
     
     -- Se o arquivo estiver aberto
     IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN

       -- Percorrer as linhas do arquivo
       BEGIN
         LOOP
           
           gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquivo
                                       ,pr_des_text => vr_des_linha);
                            
           -- Validação Header do Arquivo
           
           IF SUBSTR(vr_des_linha,08,01) = '0' THEN -- Header do Arquivo    
             
             -- Contador Registros Processados
             vr_contador := vr_contador + 1;
             
             -- Verifica se o cooperado esta cadastrada
             OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);
             FETCH cr_crapass
              INTO rw_crapass;
             -- Se não encontrar
             IF cr_crapass%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapass;
               vr_des_erro := 'Cooperado nao cadastrado.'; 
               RAISE vr_exc_saida;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapass;
            END IF;  
            
            -- Verifica se a cooperativa esta cadastrada
             OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
             FETCH cr_crapcop
              INTO rw_crapcop;
             -- Se não encontrar
             IF cr_crapcop%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapcop;
               vr_des_erro := 'Cooperativa nao cadastrada.'; 
               RAISE vr_exc_saida;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapcop;
             END IF;    
            
             -- Verifica se o convenio esta cadastrada
             OPEN cr_crapccc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrconven);
             FETCH cr_crapccc
              INTO rw_crapccc;
             -- Se não encontrar
             IF cr_crapccc%NOTFOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_crapccc;
               vr_des_erro := 'Convenio nao cadastrado.';  
               RAISE vr_exc_saida;
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_crapccc;
             END IF;
             
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,158,06)) = FALSE ) THEN
               vr_des_erro := 'Numero Sequencial do Arquivo Invalido.';
               RAISE vr_exc_saida;
             ELSE
               vr_nrremret := to_number(SUBSTR(vr_des_linha,158,06)); 
               pr_nrremess := vr_nrremret;
             END IF;  
             
             -- Verifica sequencial do Arquivo (NSU)
             OPEN cr_craphcc(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrconven => pr_nrconven
                            ,pr_nrremret => vr_nrremret);
             FETCH cr_craphcc
              INTO rw_craphcc;
             -- Se encontrar arquivo
             IF cr_craphcc%FOUND THEN
               -- Fechar o cursor pois haverá raise
               CLOSE cr_craphcc;
               vr_des_erro := 'Numero Sequencial do Arquivo já Processado.';  
               RAISE vr_exc_saida; 
             ELSE
               -- Fechar o cursor
               CLOSE cr_craphcc;  
             END IF;
           
             -- 01.0 Codigo do banco na compensacao
             IF SUBSTR(vr_des_linha,01,03) <> '085' THEN
               vr_des_erro := 'Codigo do banco na compensacao invalido';
               RAISE vr_exc_saida;
             END IF;
               
             -- 02.0 Lote de Servico
             IF SUBSTR(vr_des_linha,04,04) <> '0000' THEN
               vr_des_erro := 'Lote de Servico Invalido.';
               RAISE vr_exc_saida;
             END IF;
               
             -- 03.0 Tipo de Registro
             IF SUBSTR(vr_des_linha,08,01) <> '0' THEN
               vr_des_erro := 'Tipo de Registro Invalido.';
               RAISE vr_exc_saida;
             END IF;
               
             -- 05.0 Tipo de Inscricao do Cooperado
             IF SUBSTR(vr_des_linha,18,01) <> '1' AND   -- Pessoa Fisica   
                SUBSTR(vr_des_linha,18,01) <> '2' THEN  -- Pessoa Juridica 
               vr_des_erro := 'Tipo de Inscricao Invalida.';
               RAISE vr_exc_saida;
             END IF;
               
             -- 06.0 Numero de Inscricao do Cooperado
             IF ( gene0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,19,14))) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo Invalido.';
               RAISE vr_exc_saida;
             ELSIF rw_crapass.nrcpfcgc <> to_number(SUBSTR(vr_des_linha,19,14),'99999999999999') THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo Invalido.';
               RAISE vr_exc_saida;
             ELSIF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,01)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo Inscricao.';
               RAISE vr_exc_saida;
             ELSIF rw_crapass.inpessoa <> to_number(SUBSTR(vr_des_linha,18,01)) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header Arquivo incompativel com Tipo Inscricao.';
               RAISE vr_exc_saida;
             END IF;
               
             -- 07.0 Código do Convênio no Banco  
             IF ( gene0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,37,03))) = FALSE ) THEN
                vr_des_erro := 'Codigo do Convenio Invalida.';
                RAISE vr_exc_saida;
             ELSIF pr_nrconven <> to_number(SUBSTR(vr_des_linha,37,03)) THEN 
                vr_des_erro := 'Codigo do Convenio Invalida.';
                RAISE vr_exc_saida;
             ELSIF rw_crapccc.flghomol = 0 THEN
                vr_des_erro := 'Convenio nao Homologado.';
                RAISE vr_exc_saida;
             END IF;
               
             -- 08.0 a 09.0 Agência Mantenedora da Conta  
             IF ( gene0002.fn_numerico(pr_vlrteste => trim(SUBSTR(vr_des_linha,53,05))) = FALSE ) THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida.';
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,53,05)) <> rw_crapcop.cdagectl THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida.';
               RAISE vr_exc_saida;
             END IF;              

             -- 10.0 a 11.0 Conta/DV 
             IF ( gene0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,59,13))) = FALSE ) THEN
               vr_des_erro := 'Conta/DV Header Arquivo Invalida.';
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,59,13)) <> pr_nrdconta THEN
               vr_des_erro := 'Conta/DV Header Arquivo Invalida.';
               RAISE vr_exc_saida;
             END IF;
               
             -- 16.0 Codigo Remessa/Retorno 
             IF SUBSTR(vr_des_linha,143,01) <> '1' THEN -- '1' = Remessa (Cliente -> Banco) 
               vr_des_erro := 'Codigo de Remessa nao encontrado no segmento header do arquivo.';
               RAISE vr_exc_saida;
             END IF;              

             -- 17.0 Data de Geracao de Arquivo
             IF ( gene0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,144,08)
                                  ,pr_formato  => 'DD/MM/RRRR') = FALSE ) THEN
               vr_des_erro := 'Data de geracao do arquivo fora do periodo permitido.';
               RAISE vr_exc_saida;
             ELSE  
               IF ( TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR') > pr_dtmvtolt ) OR
                  ( TO_DATE(SUBSTR(vr_des_linha,144,08), 'DD/MM/RRRR') < (pr_dtmvtolt - 30)) THEN
                 vr_des_erro := 'Data de geracao do arquivo fora do periodo permitido.'; 
                 RAISE vr_exc_saida;
               END IF;   
             END IF;  
             
             -- Controle se arquivo possui Header de Arquivo
             vr_header_arq := TRUE;
             
           END IF; -- Header do Arquivo 
           
           -- Incluir tratamento para garantir que arquivo tenha Header de Arquivo
           IF vr_header_arq = FALSE THEN
             vr_des_erro := 'Arquivo nao possui Header de Arquivo.'; 
             RAISE vr_exc_saida;
           END IF;
           
           -- HEADER DO LOTE --
           IF SUBSTR(vr_des_linha,08,01) = '1' THEN -- Header do Lote
             
             vr_contador := vr_contador + 1;
             
             -- 09.1 a 10.1  Numero de Inscricao do Cooperado
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,19,14)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote Invalido.';
               RAISE vr_exc_saida;
             ELSIF rw_crapass.nrcpfcgc <> to_number(SUBSTR(vr_des_linha,19,14),'99999999999999') THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote Invalido.';
               RAISE vr_exc_saida;
             ELSIF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,18,01)) = FALSE ) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote incompativel com Tipo Inscricao.';
               RAISE vr_exc_saida;
             ELSIF rw_crapass.inpessoa <> to_number(SUBSTR(vr_des_linha,18,01)) THEN
               vr_des_erro := 'CPF/CNPJ Informado Header do Lote incompativel com Tipo Inscricao.';
               RAISE vr_exc_saida;
             END IF;  
               
             -- 14.1 a 15.1 Conta/DV 
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,59,13)) = FALSE ) THEN
               vr_des_erro := 'Conta/DV Header do Lote Invalida.';
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,59,13)) <> pr_nrdconta THEN
               vr_des_erro := 'Conta/DV Header do Lote Invalida.';
               RAISE vr_exc_saida;  
             END IF;
               
             -- 12.1 Agência Mantenedora da Conta  
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,53,05)) = FALSE ) THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida.';
               RAISE vr_exc_saida;
             ELSIF to_number(SUBSTR(vr_des_linha,53,05)) <> rw_crapcop.cdagectl THEN
               vr_des_erro := 'Agencia Mantenedora da Conta Invalida.';
               RAISE vr_exc_saida;
             END IF;
               
             -- 11.1 Código do Convênio no Banco  
             IF ( gene0002.fn_numerico(pr_vlrteste => TRIM(SUBSTR(vr_des_linha,37,03))) = FALSE ) THEN
                vr_des_erro := 'Codigo do Convenio Header do Lote Invalida.';
                RAISE vr_exc_saida;
             ELSIF pr_nrconven <> to_number(SUBSTR(vr_des_linha,37,03)) THEN 
                vr_des_erro := 'Codigo do Convenio Header do Lote Invalida.';
                RAISE vr_exc_saida;
             END IF;
             
             -- Controle se o Arquivo Possui Header de Lote 
             vr_header_lot := TRUE;
             
           END IF;  -- Header do Lote 
           
           -- Tratamento para garantir que arquivo tenha Header do Lote
           IF vr_contador > 1 AND -- Já Processou Header de Arquivo
              vr_header_lot = FALSE THEN
             vr_des_erro := 'Arquivo nao possui Header de Lote.';
             RAISE vr_exc_saida;
           END IF;
           
           IF SUBSTR(vr_des_linha,08,01) = '3' THEN -- Registro Detalhe
             
             -- Qauntidade Registros Processados
             vr_contador := vr_contador + 1;
             
             -- Quantidade Registros Detalhe
             vr_nrseqarq := vr_nrseqarq + 1;
             
             -- Inicializa Variaveis
             vr_cdtipmvt    := NULL;
             vr_cdocorre    := NULL;
             vr_wt_cdfinmvt := NULL;
             vr_wt_cdentdad := NULL;
             vr_cdcmpchq    := 0;
             vr_cdbanchq    := 0;
             vr_cdagechq    := 0;
             vr_nrctachq    := 0;
             vr_nrcheque    := 0;
             vr_wt_cdtipemi := NULL;
             vr_wt_vlcheque := 0;
             vr_wt_dtdcaptu := NULL;
             vr_wt_dtlibera := NULL;
             vr_wt_nrinsemi := NULL;
             
             -- 07.3D Tipo de Movimento Remessa/Retorno
             IF SUBSTR(vr_des_linha,16,02) <> '01' THEN -- 1 = Inclusão
               -- (21,05) Tipo de Movimento Invalido 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'05');
             END IF;
             
             -- 08.3D Codigo da Finalidade do Movimento
             IF SUBSTR(vr_des_linha,18,02) <> '01' THEN -- 1 = Custódia Simples
               -- (21,06) Codigo da Finalidade Invalido 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'06');
             ELSE
               vr_wt_cdfinmvt := 1;
             END IF;  
               
             -- 09.3D Forma de Entrada Dados do Cheque
             IF SUBSTR(vr_des_linha,20,01) <> '1' AND  -- 1 = CMC7
                SUBSTR(vr_des_linha,20,01) <> '2' THEN -- 2 = Linha 1 (digitação dos dados pré-impressos na primeira linha do cheque)
               -- (21,07) Forma de Entrada Invalido 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'07');
             ELSE
               vr_wt_cdentdad := to_number(SUBSTR(vr_des_linha,20,01));  
             END IF;  
             
             -- 10.3D - CMC7
             -- Verifica se Cheque já Existe no Arquivo
             vr_dsdocmc7 := SUBSTR(vr_des_linha,21,34);
             
             OPEN cr_wt_custod_arq(pr_dsdocmc7 => vr_dsdocmc7);
             FETCH cr_wt_custod_arq
              INTO rw_wt_custod_arq;
             -- Se encontrar registro
             IF cr_wt_custod_arq%FOUND THEN
               -- Fechar o cursor
               CLOSE cr_wt_custod_arq;
               -- (21,09) Cheque em Duplicidade 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'09');
             ELSE
               -- Apenas fechar o cursor
               CLOSE cr_wt_custod_arq;
             END IF;
             
             -- Validar Campos CMC7
             -- Compe
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,31,03)) = FALSE ) THEN
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'08');
             ELSE
               vr_cdcmpchq := to_number(SUBSTR(vr_des_linha,31,03));
             END IF;
             
             -- Banco
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,22,03)) = FALSE ) THEN
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'08');
             ELSE
               vr_cdbanchq := to_number(SUBSTR(vr_des_linha,22,03)); 
             END IF;
             
             -- Agencia
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,25,04)) = FALSE ) THEN
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'08');
             ELSE
               vr_cdagechq := to_number(SUBSTR(vr_des_linha,25,04)); 
             END IF;
             
             IF vr_cdbanchq = 1 THEN -- Banco do Brasil
               -- Conta do Cheque
               IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,45,08)) = FALSE ) THEN
                 vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                 vr_cdocorre := nvl(vr_cdocorre,'08');
               ELSE
                 vr_nrctachq := to_number(SUBSTR(vr_des_linha,45,08)); 
               END IF;
             ELSE
               -- Conta do Cheque
               IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,43,10)) = FALSE ) THEN
                 vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                 vr_cdocorre := nvl(vr_cdocorre,'08');
               ELSE
                 vr_nrctachq := to_number(SUBSTR(vr_des_linha,43,10)); 
               END IF;
             END IF;  
             
             -- Numero do Cheque
             IF ( gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,34,06)) = FALSE ) THEN
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'08');
             ELSE
               vr_nrcheque := to_number(SUBSTR(vr_des_linha,34,06));
             END IF;

             -- 13.3D Valor do Cheque
             IF (gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,70,15)) = FALSE ) THEN
               -- (21,11) Valor do Cheque Invalido 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'11');
             ELSE
               vr_wt_vlcheque := to_number(SUBSTR(vr_des_linha,70,15),'999999999999999') / 100;  
             END IF; 

             -- 15.3D Data para Deposito do Cheque
             IF GENE0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,93,08)
                                       ,pr_formato => 'DD/MM/RRRR') = FALSE THEN
                -- (21,12) Data para Deposito do Cheque Invalida
                vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                vr_cdocorre := nvl(vr_cdocorre,'12');   
             ELSE
               vr_wt_dtlibera := to_date(SUBSTR(vr_des_linha,93,08),'DD/MM/RRRR'); 
             END IF;
                          
             -- Apos recuperar os campos do CMC-7
             -- Utilizar a validação do cheque
             pc_validar_cheque(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dsdocmc7 => vr_dsdocmc7
                              ,pr_cdbanchq => vr_cdbanchq
                              ,pr_cdagechq => vr_cdagechq
                              ,pr_cdcmpchq => vr_cdcmpchq
                              ,pr_nrctachq => vr_nrctachq
                              ,pr_nrcheque => vr_nrcheque
                              ,pr_dtlibera => vr_wt_dtlibera
                              ,pr_vlcheque => vr_wt_vlcheque
                              ,pr_nrremret => pr_nrremess
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_intipmvt => 1 /* Arquivo */
                              ,pr_inchqcop => vr_inchqcop
                              ,pr_cdtipmvt => vr_cdtipmvt
                              ,pr_cdocorre => vr_cdocorre
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic
                              ,pr_tab_erro => pr_tab_erro);

             -- 11.3D Tipo de Inscrição do Emitente
             IF SUBSTR(vr_des_linha,55,01) <> '1' AND  -- 1 = Pessoa Fisica
                SUBSTR(vr_des_linha,55,01) <> '2' THEN -- 2 = Pessoa Juridica
               -- (21,10) Tipo/Numero de Inscrição do Emitente Invalido 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'10');
             ELSE
               vr_wt_cdtipemi := to_number(SUBSTR(vr_des_linha,55,01));  
             END IF;
             
             -- 12.3D Numero de Inscrição do Emitente
             IF (gene0002.fn_numerico(pr_vlrteste => SUBSTR(vr_des_linha,56,14)) = FALSE ) THEN
               -- (21,10) Tipo/Numero de Inscrição do Emitente Invalido 
               vr_cdtipmvt := nvl(vr_cdtipmvt,21);
               vr_cdocorre := nvl(vr_cdocorre,'10');
             ELSE
               GENE0005.pc_valida_cpf_cnpj(pr_nrcalcul => to_number(SUBSTR(vr_des_linha,56,14))
                                          ,pr_stsnrcal => vr_stsnrcal
                                          ,pr_inpessoa => vr_inpessoa);
                                          
               IF vr_stsnrcal = FALSE THEN   
                 -- (21,10) Tipo/Numero de Inscrição do Emitente Invalido 
                 vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                 vr_cdocorre := nvl(vr_cdocorre,'10');
               ELSE  
                 IF ( vr_wt_cdtipemi <> vr_inpessoa ) THEN
                      -- (21,10) Tipo/Numero de Inscrição do Emitente Invalido 
                      vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                      vr_cdocorre := nvl(vr_cdocorre,'10');
                 ELSE
                   vr_wt_nrinsemi := to_number(SUBSTR(vr_des_linha,56,14));    
                 END IF;
               END IF;  
               
             END IF; -- 12.3D Numero de Inscrição do Emitente                              
             
             -- 14.3D Data da Captura do Cheque no Cliente
             IF GENE0002.fn_data(pr_vlrteste => SUBSTR(vr_des_linha,85,08)
                                       ,pr_formato => 'DD/MM/RRRR') = FALSE THEN
                -- (21,13) Data da Captura do Cheque no Cliente Invalida 
                vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                vr_cdocorre := nvl(vr_cdocorre,'13');   
             ELSE
               IF ( to_date(SUBSTR(vr_des_linha,85,08),'DD/MM/RRRR') > pr_dtmvtolt ) THEN
                 -- (21,13) Data da Captura do Cheque no Cliente Invalida 
                 vr_cdtipmvt := nvl(vr_cdtipmvt,21);
                 vr_cdocorre := nvl(vr_cdocorre,'13'); 
               END IF;
               
               vr_wt_dtdcaptu := to_date(SUBSTR(vr_des_linha,85,08),'DD/MM/RRRR');  
                                    
             END IF;                                         
             
             -- 17.3D Numero Atribuido pelo Cliente
             vr_wt_dsusoemp := SUBSTR(vr_des_linha,109,20);
           
             -- Caso não tenha error assume como inclusão
             vr_cdtipmvt := nvl(vr_cdtipmvt,31);  -- 31  = Inclusão pendente de processamento
             vr_cdocorre := nvl(vr_cdocorre,' '); -- ' ' = Sem Ocorrencia
             
             -- Insere registro na work-table
             BEGIN
             INSERT INTO wt_custod_arq
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
                cdtipemi, 
                nrinsemi, 
                dtdcaptu, 
                dtlibera, 
                dsusoemp, 
                inconcil, 
                cdocorre,
                inchqcop)
              VALUES
               (pr_cdcooper, 
                pr_nrdconta, 
                pr_nrconven, 
                1, -- Remessa (intipmvt) 
                vr_nrremret, 
                vr_nrseqarq, 
                1, -- Inclusão (cdtipmvt)
                NVL(vr_wt_cdfinmvt,0), 
                NVL(vr_wt_cdentdad,0), 
                vr_dsdocmc7, 
                NVL(vr_cdcmpchq,0), 
                NVL(vr_cdbanchq,0), 
                NVL(vr_cdagechq,0), 
                NVL(vr_nrctachq,0),
                NVL(vr_nrcheque,0), 
                NVL(vr_wt_vlcheque,0), 
                NVL(vr_wt_cdtipemi,0), 
                vr_wt_nrinsemi, 
                vr_wt_dtdcaptu, 
                vr_wt_dtlibera, 
                vr_wt_dsusoemp, 
                0, -- Conciliação Pendente 
                NVL(vr_cdocorre,' '),
                vr_inchqcop); 
             EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir wt_custod_arq(CUST0001.pc_validar_arquivo): '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_erro;
             END;      
               
           END IF; -- Registro Detalhe  
           
           IF SUBSTR(vr_des_linha,08,01) = '5' THEN -- Trailer de Lote
             vr_trailer_lot := TRUE;
           END IF; -- Trailer de Lote
           
           IF SUBSTR(vr_des_linha,08,01) = '9' THEN -- Trailer de Arquivo
             vr_trailer_arq := TRUE;
           END IF; -- Trailer de Arquivo
           
         END LOOP; -- Fim LOOP linhas do arquivo  
       EXCEPTION
         WHEN no_data_found THEN
           -- Acabou a leitura
           NULL;
       END;
     
        -- Fechar o arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); --> Handle do arquivo aberto;
        
        -- Caso não tenha Trailer de Lote Rejeita Arquivo
        IF vr_trailer_lot = FALSE THEN
          vr_des_erro := 'Arquivo nao possui Trailer de Lote.'; 
          RAISE vr_exc_saida;
        END IF;
        
        -- Caso não tenha Trailer de Arquivo Rejeita Arquivo
        IF vr_trailer_arq = FALSE THEN
           vr_des_erro := 'Arquivo nao possui Trailer de Arquivo.';  
           RAISE vr_exc_saida;
        END IF;
             
     END IF; -- vr_arquivo.count() > 0
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Fechar Handle do Arquivo Aberto
      -- Se o arquivo estiver aberto
      IF  utl_file.IS_OPEN(vr_ind_arquivo) THEN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
      END IF;  
      
      -- Rotina para gerar <arquivo> .LOG
      CUST0001.pc_gerar_arquivo_log(pr_cdcooper => pr_cdcooper
                                   ,pr_nmarquiv => vr_nmarquiv
                                   ,pr_descerro => vr_des_erro
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);
                                   
      -- Arquivo possui erros criticos, aborta processo de validação
      CUST0001.pc_rejeitar_arquivo(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrconven => pr_nrconven
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_nmarquiv => vr_nmarquiv
                                  ,pr_idorigem => pr_idorigem
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_cdcritic => pr_cdcritic
                                  ,pr_dscritic => pr_dscritic);
      
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_des_erro;
    WHEN OTHERS THEN
      -- Fechar Handle do Arquivo Aberto
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);
    
      -- Apenas retornar a variável de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro CUST0001.pc_validar_arquivo: ' || SQLERRM;
        
  END;
  
  END pc_validar_arquivo;
  
  -- Procedure para rejeitar arquivo de remessa
  PROCEDURE pc_rejeitar_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado
                                ,pr_nrconven      IN craphcc.nrconven%TYPE  -- Numero do Convenio  
                                ,pr_dtmvtolt      IN DATE                   -- Data do Movimento  
                                ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro
                                
  BEGIN
    
  DECLARE
   
    -- Verificar qual Tipo de Retorno o Cooperado Possui
    CURSOR cr_crapccc (pr_cdcooper IN crapccc.cdcooper%TYPE
                      ,pr_nrdconta IN crapccc.nrdconta%TYPE
                      ,pr_nrconven IN crapccc.nrconven%TYPE) IS
      SELECT crapccc.idretorn
      FROM crapccc crapccc
      WHERE crapccc.cdcooper = pr_cdcooper AND
            crapccc.nrdconta = pr_nrdconta AND
            crapccc.nrconven = pr_nrconven;
    rw_crapccc cr_crapccc%ROWTYPE;
    
    -- Busca dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapccc.cdcooper%TYPE) IS
      SELECT crapcop.dsdircop
      FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Nome do Arquivo .ERR
    vr_nmarquivo_err VARCHAR2(4000);
    
    -- Nome do Arquivo .LOG
    vr_nmarquivo_log VARCHAR2(4000);
     
    vr_exc_erro EXCEPTION; 
    vr_nrdrowid ROWID;
    
    -- Descrição da Origem
    vr_dsorigem VARCHAR2(100);
    
    vr_diretorio_log VARCHAR2(4000);
    vr_diretorio_err VARCHAR2(4000);
    vr_dir_coop VARCHAR2(4000);
    
    vr_serv_ftp VARCHAR2(100);
    vr_user_ftp VARCHAR2(100);
    vr_pass_ftp VARCHAR2(100);
    
    vr_comando VARCHAR2(4000);
    
    vr_typ_saida VARCHAR2(3);
    
    vr_dir_retorno varchar2(4000);
    
    vr_script_cust varchar2(4000);
  
  BEGIN
    -- Inicializa Variaveis
    vr_cdcritic:= 0;
    vr_dscritic:= NULL;
    
    -- Monta nome do Arquivo de Erro (.ERR)
    vr_nmarquivo_err := REPLACE(UPPER(pr_nmarquiv),'.REM','.ERR');
    
    -- Monta nome do Arquivo de Log (.LOG)
    vr_nmarquivo_log := REPLACE(UPPER(pr_nmarquiv),'.REM','.LOG');
    
    -- Verificar qual Tipo de Retorno o Cooperado Possui
    OPEN cr_crapccc(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven);
    FETCH cr_crapccc INTO rw_crapccc;
    --Se nao encontrou
    IF cr_crapccc%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapccc;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperado sem Tipo de Retorno Cadastrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapccc;  
    END IF;
    
    -- Busca nome resumido da cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic := 0;
      vr_dscritic := 'Cooperativa nao Cadastrada.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    ELSE
      --Fechar Cursor
      CLOSE cr_crapcop;  
    END IF;
    
    -- Diretório da Cooperativa
    vr_dir_coop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);
    
    -- Diretório do arquivo de Log (.LOG)
    vr_diretorio_log := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/arq') ;                                   
        
    -- Diretório do arquivo de Erro (.ERR)
    vr_diretorio_err := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => '/upload') ;  
      
    -- Renomeia o Arquivo .REM para .ERR
    gene0001.pc_OScommand_Shell('mv ' || vr_diretorio_err || '/' || pr_nmarquiv || ' ' || 
                                vr_diretorio_err || '/' || vr_nmarquivo_err); 
     
    IF rw_crapccc.idretorn = 2 THEN -- Retorno via FTP
      
      -- Caminho script que envia/recebe via FTP os arquivos de custodia cheque
      vr_script_cust := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');
      
      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP'); 
                                                
      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');
                                              
      vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');   
                                              
      vr_dir_retorno := '/' ||TRIM(rw_crapcop.dsdircop)   ||
                        '/' || TRIM(to_char(pr_nrdconta)) || '/RETORNO';                                                                              
            
      -- Copia Arquivo .ERR para Servidor FTP
      vr_comando := vr_script_cust                                 || ' ' ||
      '-envia'                                                     || ' ' || 
      '-srv '         || vr_serv_ftp                               || ' ' || -- Servidor
      '-usr '         || vr_user_ftp                               || ' ' || -- Usuario
      '-pass '        || vr_pass_ftp                               || ' ' || -- Senha
      '-arq '         || CHR(39) || vr_nmarquivo_err || CHR(39)    || ' ' || -- .ERR
      '-dir_local '   || vr_diretorio_err                          || ' ' || -- /usr/coop/<cooperativa>/upload
      '-dir_remoto '  || vr_dir_retorno                            || ' ' || -- /<conta do cooperado>/RETORNO 
      '-salvar '      || vr_dir_coop || '/salvar'                  || ' ' || -- /usr/coop/<cooperativa>/salvar  
      '-log '         || vr_dir_coop || '/log/cst_por_arquivo.log';          -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log
      
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => pr_dscritic
                           ,pr_flg_aguard  => 'S');
                           
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_erro;
      END IF;                    
                           
      
      -- Copia Arquivo .LOG para Servidor FTP
      vr_comando := vr_script_cust                                 || ' ' ||
      '-envia'                                                     || ' ' || 
      '-srv '         || vr_serv_ftp                               || ' ' || -- Servidor
      '-usr '         || vr_user_ftp                               || ' ' || -- Usuario
      '-pass '        || vr_pass_ftp                               || ' ' || -- Senha
      '-arq '         || vr_nmarquivo_log                          || ' ' || -- .LOG
      '-dir_local '   || vr_diretorio_log                          || ' ' || -- /usr/coop/<cooperativa>/arq
      '-dir_remoto '  || vr_dir_retorno                            || ' ' || -- /<coop>/<conta do cooperado>/RETORNO 
      '-salvar '      || vr_dir_coop || '/salvar'                  || ' ' || -- /usr/coop/<cooperativa>/salvar 
      '-log '         || vr_dir_coop || '/log/cst_por_arquivo.log';          -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log
      
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => pr_dscritic
                           ,pr_flg_aguard  => 'S');
                           
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_erro;
      END IF;
   
    ELSE -- rw_crapccc.idretorn = 1 (InternetBanking)
      
      -- Verifica a existência do arquivo .LOG
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_diretorio_log || '/' || vr_nmarquivo_log) THEN
        -- Verifica se nome do arquivo foi informado 
        IF LENGTH(TRIM(vr_nmarquivo_log)) > 0 THEN 
           -- Deletar arquivo .LOG
           gene0001.pc_OScommand_Shell('rm ' || vr_diretorio_log || '/' || vr_nmarquivo_log);
        END IF;   
      END IF;
      
      -- Verifica a existência do arquivo .ERR
      IF gene0001.fn_exis_arquivo(pr_caminho => vr_diretorio_err || '/' || vr_nmarquivo_err) THEN
        -- Verifica se nome do arquivo foi informado 
        IF length(vr_nmarquivo_err) > 0 THEN 
           -- Deletar arquivo .ERR
           gene0001.pc_OScommand_Shell('rm ' || vr_diretorio_err || '/' || vr_nmarquivo_err);
        END IF;   
      END IF;
      
      vr_cdcritic := 0;
      vr_dscritic := 'Arquivo Invalido. Erro de Estrutura!';
    END IF;
    
    -- Verifica Qual a Origem
    CASE pr_idorigem 
      WHEN 1 THEN vr_dsorigem := 'AYLLOS';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      WHEN 3 THEN vr_dsorigem := 'FTP';
      ELSE vr_dsorigem := ' ';
    END CASE; 
      
    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Arquivo ' || pr_nmarquiv || ' de custódia de cheques foi rejeitado'
                        ,pr_dttransa => pr_dtmvtolt
                        ,pr_flgtrans => 0 -- TRUE
                        ,pr_hrtransa => to_number(to_char(pr_dtmvtolt,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                        
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorna variaveis de saida
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      -- Atualiza campo de erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro CUST0001.pc_rejeitar_arquivo: ' || SQLERRM;
  END;
  
  
  END pc_rejeitar_arquivo;     
  
  
  -- Procedure para gerar arquivo de retorno               
  PROCEDURE pc_gerar_arquivo_retorno (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                     ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                     ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                     ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                     ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                     ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                     ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                     ,pr_nmarquiv     OUT VARCHAR2               -- Nome do Arquivo
                                     ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                     ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro                        
   
  BEGIN
    
  DECLARE
  
    -- CURSORES
    -- Busca do diretório conforme a cooperativa conectada
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.dsdircop
            ,crapcop.cdagectl
            ,crapcop.nmrescop
            ,crapcop.nmextcop
      FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;
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
          
    -- Selecionar os Detalhamentos dos Cheques
    CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
                     ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                     ,pr_nrconven IN crapdcc.nrconven%TYPE
                     ,pr_nrremret IN crapdcc.nrremret%TYPE) IS
      SELECT crapdcc.cdcooper
            ,crapdcc.nrdconta
            ,crapdcc.nrconven
            ,crapdcc.intipmvt
            ,crapdcc.nrremret
            ,crapdcc.nrseqarq
            ,crapdcc.cdtipmvt
            ,crapdcc.cdfinmvt     
            ,crapdcc.cdentdad     
            ,crapdcc.dsdocmc7     
            ,crapdcc.cdcmpchq     
            ,crapdcc.cdbanchq     
            ,crapdcc.cdagechq     
            ,crapdcc.nrctachq     
            ,crapdcc.nrcheque     
            ,crapdcc.vlcheque     
            ,crapdcc.cdtipemi     
            ,crapdcc.nrinsemi     
            ,crapdcc.dtdcaptu     
            ,crapdcc.dtlibera     
            ,crapdcc.dtcredit     
            ,crapdcc.dsusoemp     
            ,crapdcc.cdocorre     
            ,crapdcc.cdagenci     
      FROM crapdcc crapdcc
      WHERE crapdcc.cdcooper = pr_cdcooper AND
            crapdcc.nrdconta = pr_nrdconta AND
            crapdcc.nrconven = pr_nrconven AND
            crapdcc.nrremret = pr_nrremret AND
            crapdcc.intipmvt = 2;
    rw_crapdcc cr_crapdcc%ROWTYPE;
    
    -- Verificar qual Tipo de Retorno o Cooperado Possui
    CURSOR cr_crapccc (pr_cdcooper IN crapccc.cdcooper%TYPE
                      ,pr_nrdconta IN crapccc.nrdconta%TYPE
                      ,pr_nrconven IN crapccc.nrconven%TYPE) IS
      SELECT crapccc.idretorn
      FROM crapccc crapccc
      WHERE crapccc.cdcooper = pr_cdcooper AND
            crapccc.nrdconta = pr_nrdconta AND
            crapccc.nrconven = pr_nrconven;
    rw_crapccc cr_crapccc%ROWTYPE;
    
    -- Nome do Arquivo
    vr_nmarquiv  VARCHAR2(100);
     
    vr_utlfileh VARCHAR2(4000);
     
    -- Declarando handle do Arquivo
    vr_ind_arquivo utl_file.file_type;
    
    vr_exc_saida   EXCEPTION;
    vr_exc_erro    EXCEPTION;
    vr_erro_update EXCEPTION;
    vr_exc_critico EXCEPTION;
    
    vr_setlinha VARCHAR2(400);
    
    -- Agencia Mantedora
    vr_cdageman NUMBER;
    
    -- Hora Geração
    vr_horagera VARCHAR2(100);
    
    -- Variaveis Acumuladoras
    vr_qtd_registro NUMBER :=0 ;
    vr_qtd_cheque   NUMBER :=0 ;
    vr_vlr_tot_chq  NUMBER :=0 ;
    vr_qtd_reg_lote NUMBER :=0 ;
    vr_existe_dcc   INTEGER :=0;
    
    vr_nr_sequencial NUMBER := 0;
    
    vr_aux_cdocorre VARCHAR2(2);
    
    vr_nrdrowid ROWID;
    
    vr_dsorigem VARCHAR2(10);
    
    vr_serv_ftp VARCHAR2(100);
    vr_user_ftp VARCHAR2(100);
    vr_pass_ftp VARCHAR2(100);
    
    vr_comando  VARCHAR2(4000);
    vr_dir_coop VARCHAR2(4000);
    
    vr_typ_saida VARCHAR2(3);
    
    vr_dir_retorno varchar2(4000);
    
    vr_script_cust varchar2(4000);
  
  BEGIN
    --Inicializar variaveis retorno
    pr_cdcritic:= 0;
    pr_dscritic:= NULL;
    
    --Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    --Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Registro de cooperativa nao encontrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapcop;
    
    -- Montando nome arquivo retorno.
    vr_nmarquiv := 'CST_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_'
                          || TRIM(to_char(pr_nrremret,'000000000')) || '.RET';
                          
    -- Define o diretório do arquivo
    vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/arq') ;
    
    -- Abre arquivo em modo de escrita (W)
    GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                            ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                            ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                            ,pr_des_erro => vr_dscritic);       --> Erro  
                            
                                      
    IF vr_dscritic IS NOT NULL THEN
      -- Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    -- Localizar Cooperado
    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    --Fechar Cursor
    CLOSE cr_crapass; 
    
    -- Agencia Mantenedora
    vr_cdageman:= to_number(gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||'0');
    
    --Hora geracao
    vr_horagera:= to_char(pr_dtmvtolt,'HH24MISS');
    
    -- Quantidade de Registros Lote
    vr_qtd_registro := 0;
    -- Quantidade de Cheques
    vr_qtd_cheque   := 0;
    -- Valor Total Cheques
    vr_vlr_tot_chq  := 0;
    -- Identifica se existem registros na crapdcc para gerar o arquivo no FTP
    vr_existe_dcc := 0;
    
    
    ------------- HEADER DO ARQUIVO -------------
    vr_qtd_registro := vr_qtd_registro + 1;
    
    vr_setlinha:= '085'                                                     || -- 01.0 - Banco
                  '0000'                                                    || -- 02.0 - Lote 
                  '0'                                                       || -- 03.0 - Tipo Registro
                  LPAD(' ',9,' ')                                           || -- 04.0 - Brancos
                  rw_crapass.inpessoa                                       || -- 05.0 - Tp Inscricao 
                  gene0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999999')    || -- 06.0 - CNPJ/CPF 
                  'CUST' || gene0002.fn_mask(pr_nrconven,'999')             || -- 07.0 - Convenio
                  LPAD(' ', 13,' ')                                         || 
                  gene0002.fn_mask(vr_cdageman,'999999')                    || -- 08.0 - Age Mantenedora
                  gene0002.fn_mask(rw_crapass.nrdconta,'9999999999999')     || -- 10.0 - Conta/Digito
                  LPAD(' ',1,' ')                                           || -- 12.0 - Dig Verf Age/Cta
                  substr(rpad(rw_crapass.nmprimtl,30,' '),1,30)             || -- 13.0 - Nome Empresa
                  substr(rpad(rw_crapcop.nmextcop,30,' '),1,30)             || -- 14.0 - Nome Banco
                  LPAD(' ',10,' ')                                          || -- 15.0 - Brancos
                  '2'                                                       || -- 16.0 - Código Remessa/Retorno
                  to_char(SYSDATE,'DDMMYYYY')                               || -- 17.0 - Data de Geração do Arquivo
                  gene0002.fn_mask(vr_horagera,'999999')                    || -- 18.0 - Hora de Geração do Arquivo
                  gene0002.fn_mask(pr_nrremret,'999999')                    || -- 19.0 - Numero Sequencial do Arquivo
                  '088'                                                     || -- 20.0 - Layout do Arquivo
                  '00000'                                                   || -- 21.0 - Densidade de Gravação do Arquivo
                  LPAD(' ',20,' ')                                          || -- 22.0 - Uso Reservado do Banco
                  LPAD(' ',20,' ')                                          || -- 23.0 - Uso Reservado da Empresa
                  LPAD(' ',29,' ')                                          || -- 24.0 - Uso Exclusivo FEBRABAN
                  CHR(13);
    
    -- Escrever Linha do Header do Arquivo CNAB240 - Item 1.0
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
    
    ------------- HEADER DO LOTE -------------
    vr_qtd_registro := vr_qtd_registro + 1;
    
    vr_setlinha:= '085'                                                    || -- 01.1 - Banco
                  '0001'                                                   || -- 02.1 - Lote 
                  '1'                                                      || -- 03.1 - Tipo Registro
                  'T'                                                      || -- 04.1 - Tipo de Operação
                  '06'                                                     || -- 05.1 - Tipo de Serviço        
                  LPAD(' ',2,' ')                                          || -- 06.1 - Uso Exclusivo FEBRABAN
                  '010'                                                    || -- 07.1 - Versao do Arquivo
                  LPAD(' ',1,' ')                                          || -- 08.1 - Uso Exclusivo FEBRABAN
                  rw_crapass.inpessoa                                      || -- 09.1 - Tipo de Inscricao Empresa 
                  gene0002.fn_mask(rw_crapass.nrcpfcgc,'99999999999999')   || -- 10.1 - CNPJ/CPF da Empresa
                  'CUST' || gene0002.fn_mask(pr_nrconven,'999')            || -- 11.1 - Convenio
                  LPAD(' ',13,' ')                                         ||   
                  gene0002.fn_mask(vr_cdageman,'999999')                   || -- 12.1 - Agencia Mantenedora da Conta
                  gene0002.fn_mask(rw_crapass.nrdconta,'9999999999999')    || -- 14.1 - Conta/Digito
                  LPAD(' ',1,' ')                                          || -- 16.1 - Digito Verfificador Ag/Conta
                  substr(rpad(rw_crapass.nmprimtl,30,' '),1,30)            || -- 17.1 - Nome da Empresa
                  LPAD(' ',20,' ')                                         || -- 18.1 - Uso Reservado Banco Remetente
                  LPAD(' ',108,' ')                                        || -- 15.1 - Uso Exclusivo FEBRABAN
                  LPAD(' ',10,' ')                                         || -- 24.1 - Ocorrencias Lote
                  CHR(13);
    
    -- Escreve Linha do header do Lote CNAB240 - Item 1.1
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
    
    ------------- SEGMENTO D -------------
    FOR rw_crapdcc IN cr_crapdcc(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrconven => pr_nrconven
                                ,pr_nrremret => pr_nrremret) LOOP
                                
      -- Existe informacao na dcc
      vr_existe_dcc := 1;
                                
      vr_nr_sequencial := vr_nr_sequencial + 1;  
      
      IF TRIM(rw_crapdcc.cdocorre) IS NULL THEN
        vr_aux_cdocorre := LPAD(' ',02,' ');
      ELSE       
        vr_aux_cdocorre := LPAD(rw_crapdcc.cdocorre,02,' ');
      END IF;       
      
      -- Regra para que no primeiro retorno não seja enviado critica
      -- dos registros detalhe, apenas sera enviado no segundo retorno.
      IF rw_crapdcc.cdtipmvt = '31' THEN
        vr_aux_cdocorre := LPAD(' ',02,' ');
      END IF;                  
                                
      vr_setlinha:= '085'                                                   || -- 01.3D - Banco
                    '0001'                                                  || -- 02.3D - Lote 
                    '3'                                                     || -- 03.3D - Tipo Registro
                    gene0002.fn_mask(vr_nr_sequencial,'99999')              || -- 04.3D - Nro. Sequencial Reg. no Lote
                    'D'                                                     || -- 05.3D - Codigo Segmento Detalhe
                    LPAD(' ',1,' ')                                         || -- 06.3D - Uso exclusivo FEBRABAN
                    gene0002.fn_mask(rw_crapdcc.cdtipmvt,'99')              || -- 07.3D - Tipo de Moviemnto (REM/RET) 
                    gene0002.fn_mask(rw_crapdcc.cdfinmvt,'99')              || -- 08.3D - Codigo Finalidade
                    gene0002.fn_mask(rw_crapdcc.cdentdad,'9')               || -- 09.3D - Forma de Entrada dos Dados
                    rw_crapdcc.dsdocmc7                                     || -- 10.3D - Identificação do Cheque (CMC7) 
                    gene0002.fn_mask(rw_crapdcc.cdtipemi,'9')               || -- 11.3D - Tipo Inscrição Emitente
                    gene0002.fn_mask(rw_crapdcc.nrinsemi,'99999999999999')  || -- 12.3D - Numero Inscrição do Emitente
                    gene0002.fn_mask(NVL(rw_crapdcc.vlcheque,0) * 100,'999999999999999') || -- 13.3D - Valor do Cheque
                    to_char(rw_crapdcc.dtdcaptu,'DDMMRRRR')                 || -- 14.3D - Data Captura do Cheque no Cliente 
                    to_char(rw_crapdcc.dtlibera,'DDMMRRRR')                 || -- 15.3D - Data para Deposito do Cheque
                    NVL(to_char(rw_crapdcc.dtcredit,'DDMMRRRR'),'00000000') || -- 16.3D - Data Prevista para Debito/Credito
                    RPAD(rw_crapdcc.dsusoemp,20,' ')                        || -- 17.3D - Numero Atribuido pelo Cliente
                    LPAD(' ',15,' ')                                        || -- 18.3D - Uso Exclusivo do Banco
                    LPAD(' ',74,'0')                                        || -- 19.3D  a 25.3D -- Sera Enviado Zeros
                    LPAD(' ',13,' ')                                        || -- 26.3D - Uso exclusivo FEBRABAN
                    NVL(vr_aux_cdocorre,'00') || LPAD(' ',08,' ')           || -- 27.3D - Codigo das Ocorrencias
                    CHR(13);       
    
      -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);                          
                                
      -- Quantidade de Cheques Processados (Usado no Trailer)                          
      vr_qtd_cheque   := vr_qtd_cheque + 1;
      
      -- Quantidade de Registros do Lote (Usado no Trailer)
      vr_qtd_registro := vr_qtd_registro + 1;
    
      
    END LOOP;
    
    ------------- TRAILER DO LOTE -------------
    vr_qtd_registro := vr_qtd_registro + 1;
    
    -- Quantidade de Registros do Lote (Soma da Qtd. Cheques mais Header de Lote e Trailer de Lote)
    vr_qtd_reg_lote := vr_qtd_cheque + 2;
    
    vr_setlinha:= '085'                                                       || -- 01.5 - Banco
                  '0001'                                                      || -- 02.5 - Lote de Serviço
                  '5'                                                         || -- 03.5 - Registro Trailer de Lote
                  LPAD(' ',9,' ')                                             || -- 04.5 - Uso Exclusivo FEBRABAN
                  gene0002.fn_mask(vr_qtd_reg_lote,'999999')                  || -- 05.5 - Qtd Registros do Lote
                  gene0002.fn_mask(vr_vlr_tot_chq * 100,'999999999999999999') || -- 06.5 - Valor Total dos Cheques
                  gene0002.fn_mask(vr_qtd_cheque,'999999')                    || -- 07.5 - Quantidade Cheques do Lote
                  LPAD('0',18,'0')                                            || -- 08.5 - Valot Total Juros
                  LPAD('0',15,'0')                                            || -- 09.5 - Valot Total IOF
                  LPAD('0',15,'0')                                            || -- 10.5 - Valot Total Outros
                  LPAD(' ',135,' ')                                           || -- 11.5 - Uso Exclusivo FEBRABAN
                  LPAD(' ',10,' ')                                            || -- 12.5 - Ocorrencias Lote
                  CHR(13);
    
    -- Escreve Linha do Trailer de Lote CNAB240 - Item 1.5
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
    
    
    ------------- TRAILER DO ARQUIVO -------------
    vr_qtd_registro := vr_qtd_registro + 1;
    
    vr_setlinha:= '085'                                      || -- 01.9 - Banco
                  '9999'                                     || -- 02.9 - Lote de Serviço 
                  '9'                                        || -- 03.9 - Tipo Registro
                  LPAD(' ',9,' ')                            || -- 04.9 - Uso Exclusivo FEBRABAN
                  '000001'                                   || -- 05.9 - Qtd de Lotess do Arquivo
                  gene0002.fn_mask(vr_qtd_registro,'999999') || -- 06.9 - Qtd Registros do Arquivo
                  '000001'                                   || -- 07.9 - Qtd Contas p/ Conciliar
                  LPAD(' ',205,' ')                          || -- 08.9 - Uso Exclusivo FEBRABAN
                  CHR(13);
    
    -- Escreve Linha do Trailer de Arquivo CNAB240 - Item 1.9
    GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
    
                                                 
    -- Fechar o arquivo
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);                                              
    
    -- Verificar qual Tipo de Retorno o Cooperado Possui
    OPEN cr_crapccc(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven);
    FETCH cr_crapccc INTO rw_crapccc;
    --Se nao encontrou
    IF cr_crapccc%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapccc;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Cooperado sem Tipo de Retorno Cadastrado.';
      
      -- Registrar Log;
      CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nmarquiv => vr_nmarquiv
                                   ,pr_textolog => 'Cooperado sem Tipo de Retorno Cadastrado'
                                   ,pr_cdcritic => pr_cdcritic
                                   ,pr_dscritic => pr_dscritic);
      
      --Levantar Excecao
      RAISE vr_exc_critico;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapccc;
    
    IF rw_crapccc.idretorn = 2 AND  -- FTP
       vr_existe_dcc = 1       THEN -- Somente gerar se existir informacao na DCC
      -- Nome do Servidor FTP Custodia
      vr_serv_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_SERV_FTP'); 
      -- Usuario do Servidor FTP Custodia                                          
      vr_user_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_USER_FTP');
      -- Senha do Servidor FTP Custodia                                        
      vr_pass_ftp := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => '0'
                                              ,pr_cdacesso => 'CUST_CHQ_ARQ_PASS_FTP');
                                              
        
      -- Caminho script que envia/recebe via FTP os arquivos de custodia cheque
      vr_script_cust := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => '0'
                                                 ,pr_cdacesso => 'SCRIPT_ENV_REC_ARQ_CUST');                                      
                                              
      -- Diretório da Cooperativa
      vr_dir_coop := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper);   
      
      -- Diretorio de Retorno /<coop>/<conta>/RETORNO                                    
      vr_dir_retorno := '/' || TRIM(rw_crapcop.dsdircop)  ||
                        '/' || TRIM(to_char(pr_nrdconta)) || '/RETORNO';                                     
                                           
                                                                              
      vr_comando := vr_script_cust                                 || ' ' || -- Script Shell
      '-envia'                                                     || ' ' || -- Enviar/Receber
      '-srv '         || vr_serv_ftp                               || ' ' || -- Servidor
      '-usr '         || vr_user_ftp                               || ' ' || -- Usuario
      '-pass '        || vr_pass_ftp                               || ' ' || -- Senha
      '-arq '         || CHR(39) || vr_nmarquiv || CHR(39)         || ' ' || -- Nome do Arquivo .RET
      '-dir_local '   || vr_utlfileh                               || ' ' || -- /usr/coop/<cooperativa>/arq
      '-dir_remoto '  || vr_dir_retorno                            || ' ' || -- /<conta do cooperado>/RETORNO 
      '-salvar '      || vr_dir_coop || '/salvar'                  || ' ' || -- /usr/coop/<cooperativa>/salvar 
      '-log '         || vr_dir_coop || '/log/cst_por_arquivo.log';          -- /usr/coop/<cooperativa>/log/cst_por_arquivo.log
      
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => pr_dscritic
                           ,pr_flg_aguard  => 'S');
       
       -- Se ocorreu erro dar RAISE
       IF vr_typ_saida = 'ERR' THEN
         vr_dscritic:= 'Nao foi possivel executar comando unix. ' || vr_comando;
         RAISE vr_exc_critico;
       END IF; 
    END IF;
    
    -- Registrar Log;
    CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nmarquiv => vr_nmarquiv
                                 ,pr_textolog => 'Arquivo de Retorno Gerado com Sucesso'
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic);
                                     
    
    -- Verifica Qual a Origem
    CASE pr_idorigem 
      WHEN 1 THEN vr_dsorigem := 'AYLLOS';
      WHEN 3 THEN vr_dsorigem := 'INTERNET';
      WHEN 3 THEN vr_dsorigem := 'FTP';
      ELSE vr_dsorigem := ' ';
    END CASE; 
           
    -- Gerar registro de log (craplgm)
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => 'Gerado arquivo de retorno de custódia de cheques: ' || vr_nmarquiv
                        ,pr_dttransa => pr_dtmvtolt
                        ,pr_flgtrans => 0 -- TRUE
                        ,pr_hrtransa => to_number(to_char(pr_dtmvtolt,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ' '
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                      
      -- Retorna nome do Arquivo  
      pr_nmarquiv := vr_nmarquiv;                    
    
      -- Efetua a Atualizacao do Registro do Arquivo para Processado
      BEGIN
        UPDATE craphcc
           SET insithcc = 2 -- Processado
       WHERE craphcc.cdcooper = pr_cdcooper
         AND craphcc.nrdconta = pr_nrdconta
         AND craphcc.nrconven = pr_nrconven
         AND craphcc.intipmvt = 2 -- Retorno
         AND craphcc.nrremret = pr_nrremret;
         
       IF SQL%ROWCOUNT = 0 THEN
         RAISE vr_erro_update;
       END IF;
         
      EXCEPTION
        WHEN vr_erro_update THEN
          -- Atualiza campo de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar dados na CRAPHCC: ' || SQLERRM;
          RAISE vr_exc_critico;
        WHEN OTHERS THEN
          -- Atualiza campo de erro
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar dados na CRAPHCC: ' || SQLERRM;
          RAISE vr_exc_critico;
      END;
      
      -- Salva Alterações
      COMMIT;
  
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Atualiza campo de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic; 
      WHEN vr_exc_critico THEN
        -- Atualiza campo de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;  
        ROLLBACK;
      WHEN OTHERS THEN
        -- Atualiza campo de erro
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_gerar_arquivo_retorno: ' || SQLERRM;
        ROLLBACK;  
    END;
   
   END pc_gerar_arquivo_retorno;        
   
   
   -- Procedure para processar os registos na wt_custod_arq                
   PROCEDURE pc_processar_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                  ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                  ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                  ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Operador
                                  ,pr_nrremess      IN craphcc.nrremret%TYPE  -- Numero da Remessa do Cooperado
                                  ,pr_nrremret     OUT craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro 
   BEGIN
     
     DECLARE
       -- CURSORES
       
       -- Dados wt_custod_arq
       CURSOR cr_wt_custod_arq IS
         SELECT wt_custod_arq.cdcooper 
               ,wt_custod_arq.nrdconta 
               ,wt_custod_arq.nrconven 
               ,wt_custod_arq.intipmvt 
               ,wt_custod_arq.nrremret 
               ,wt_custod_arq.nrseqarq 
               ,wt_custod_arq.cdtipmvt 
               ,wt_custod_arq.cdfinmvt 
               ,wt_custod_arq.cdentdad 
               ,wt_custod_arq.dsdocmc7 
               ,wt_custod_arq.cdcmpchq 
               ,wt_custod_arq.cdbanchq 
               ,wt_custod_arq.cdagechq 
               ,wt_custod_arq.nrctachq 
               ,wt_custod_arq.nrcheque 
               ,wt_custod_arq.vlcheque 
               ,wt_custod_arq.cdtipemi 
               ,wt_custod_arq.nrinsemi 
               ,wt_custod_arq.dtdcaptu 
               ,wt_custod_arq.dtlibera 
               ,wt_custod_arq.dtcredit 
               ,wt_custod_arq.dsusoemp 
               ,wt_custod_arq.cdagedev 
               ,wt_custod_arq.nrctadev 
               ,wt_custod_arq.cdalinea 
               ,wt_custod_arq.inconcil 
               ,wt_custod_arq.cdocorre 
               ,wt_custod_arq.dsdoerro 
               ,wt_custod_arq.inchqcop
         FROM wt_custod_arq wt_custod_arq
        WHERE wt_custod_arq.cdtipmvt = 1; -- Remessa
       rw_wt_custod_arq cr_wt_custod_arq%ROWTYPE;
       
       -- Buscar ultimo numero de retorno utilizado
       CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE     --> Código da cooperativa
                        ,pr_nrdconta IN craphcc.nrdconta%TYPE     --> Numero da Conta
                        ,pr_nrconven IN craphcc.nrconven%TYPE) IS --> Numero do Convenio
         SELECT NVL(MAX(nrremret),0) nrremret
         FROM craphcc
         WHERE craphcc.cdcooper = pr_cdcooper 
           AND craphcc.nrdconta = pr_nrdconta
           AND craphcc.nrconven = pr_nrconven
           AND craphcc.intipmvt = 2 -- Retorno 
         ORDER BY craphcc.cdcooper,
                  craphcc.nrdconta,
                  craphcc.nrconven,
                  craphcc.intipmvt;              
       rw_craphcc cr_craphcc%ROWTYPE;
       
       vr_nrremret craphcc.nrremret%TYPE;
       vr_nmarquiv craphcc.nmarquiv%TYPE;
       
       vr_cdtipmvt crapdcc.cdtipmvt%TYPE;
       
       vr_exc_critico EXCEPTION;
       
       vr_utlfileh    VARCHAR2(4000);
       vr_origem_arq  VARCHAR2(4000);
       vr_destino_arq VARCHAR2(4000);
       
       BEGIN
         
       -- Insere na tabela craphcc os dados do Header do Arquivo
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
            pr_nrconven,
            1, -- Remessa
            pr_nrremess,
            pr_dtmvtolt,
            pr_nmarquiv,
            pr_idorigem,
            pr_dtmvtolt,
            to_char(SYSDATE,'HH24MISS'),
            1, -- Pendente
            pr_cdoperad);
       EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao inserir CRAPHCC: ' || SQLERRM;
           RAISE vr_exc_critico;
       END;  
       
       -- Ler todos os registros da wt_custod_arq e gravar na crapdcc
       FOR rw_wt_custod_arq IN cr_wt_custod_arq LOOP 
         
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
              cdtipemi,
              nrinsemi,
              dtdcaptu,
              dtlibera,
              dtcredit,
              dsusoemp,
              cdagedev,
              nrctadev,
              cdalinea,
              cdocorre,
              inconcil,
              inchqcop)
           VALUES
             (rw_wt_custod_arq.cdcooper,
              rw_wt_custod_arq.nrdconta,
              rw_wt_custod_arq.nrconven,
              rw_wt_custod_arq.intipmvt,
              rw_wt_custod_arq.nrremret,
              rw_wt_custod_arq.nrseqarq,
              rw_wt_custod_arq.cdtipmvt,
              rw_wt_custod_arq.cdfinmvt,
              rw_wt_custod_arq.cdentdad,
              rw_wt_custod_arq.dsdocmc7,
              rw_wt_custod_arq.cdcmpchq,
              rw_wt_custod_arq.cdbanchq,
              rw_wt_custod_arq.cdagechq,
              rw_wt_custod_arq.nrctachq,
              rw_wt_custod_arq.nrcheque,
              rw_wt_custod_arq.vlcheque,
              rw_wt_custod_arq.cdtipemi,
              rw_wt_custod_arq.nrinsemi,
              rw_wt_custod_arq.dtdcaptu,
              rw_wt_custod_arq.dtlibera,
              rw_wt_custod_arq.dtcredit,
              rw_wt_custod_arq.dsusoemp,
              rw_wt_custod_arq.cdagedev,
              rw_wt_custod_arq.nrctadev,
              rw_wt_custod_arq.cdalinea,
              NVL(rw_wt_custod_arq.cdocorre,' '),
              rw_wt_custod_arq.inconcil,
              rw_wt_custod_arq.inchqcop);
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao inserir CRAPDCC: '||SQLERRM;
             RAISE vr_exc_critico;
         END;
         
       END LOOP;
       
       -- Gerar Informação de Retorno ao Cooperado (.RET)
     
       -- Buscar o Último Lote de Retorno do Cooperado
       OPEN cr_craphcc(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrconven => pr_nrconven);
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
       
       vr_nmarquiv := 'CST_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_' ||
                                TRIM(to_char(vr_nrremret,'000000000')) || '.RET';
       
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
              pr_nrconven,
              2, -- Retorno
              vr_nrremret,
              pr_dtmvtolt,
              vr_nmarquiv,
              pr_idorigem,
              pr_dtmvtolt,
              to_char(SYSDATE,'HH24MISS'),
              1, -- Pendente
              pr_cdoperad);
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao inserir CRAPHCC: '||SQLERRM;
             RAISE vr_exc_critico;
         END;
         
       -- Gravar Variavel de Saída com o Numero do Retorno
       pr_nrremret := vr_nrremret;
       
       -- Incluir todos os Registros da wt_custod_arq Usando Lote de Retorno (vr_nrremret)
      
       -- Ler todos os registros da wt_custod_arq e gravar na crapdcc
       FOR rw_wt_custod_arq IN cr_wt_custod_arq LOOP 
         
       --  IF TRIM(rw_wt_custod_arq.cdocorre) IS NULL THEN
           vr_cdtipmvt := 31; -- Inclusão Pendente
       --  ELSE
       --   vr_cdtipmvt := 21; -- Inclusão Rejeitada
       --  END IF;
              
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
              cdtipemi,
              nrinsemi,
              dtdcaptu,
              dtlibera,
              dtcredit,
              dsusoemp,
              cdagedev,
              nrctadev,
              cdalinea,
              cdocorre,
              inconcil,
              inchqcop)
           VALUES
             (rw_wt_custod_arq.cdcooper,
              rw_wt_custod_arq.nrdconta,
              rw_wt_custod_arq.nrconven,
              2, -- Retorno
              vr_nrremret,
              rw_wt_custod_arq.nrseqarq,
              vr_cdtipmvt,
              rw_wt_custod_arq.cdfinmvt,
              rw_wt_custod_arq.cdentdad,
              rw_wt_custod_arq.dsdocmc7,
              rw_wt_custod_arq.cdcmpchq,
              rw_wt_custod_arq.cdbanchq,
              rw_wt_custod_arq.cdagechq,
              rw_wt_custod_arq.nrctachq,
              rw_wt_custod_arq.nrcheque,
              rw_wt_custod_arq.vlcheque,
              rw_wt_custod_arq.cdtipemi,
              rw_wt_custod_arq.nrinsemi,
              rw_wt_custod_arq.dtdcaptu,
              rw_wt_custod_arq.dtlibera,
              rw_wt_custod_arq.dtcredit,
              rw_wt_custod_arq.dsusoemp,
              rw_wt_custod_arq.cdagedev,
              rw_wt_custod_arq.nrctadev,
              rw_wt_custod_arq.cdalinea,
              NVL(rw_wt_custod_arq.cdocorre,' '),
              rw_wt_custod_arq.inconcil,
              rw_wt_custod_arq.inchqcop);
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao inserir CRAPDCC: '||SQLERRM;
             RAISE vr_exc_critico;
         END;
         
       END LOOP;    
       
       -- Rotina para mover o arquivo processado para a pasta
       -- <cooperativa>/salvar
       
       -- Define o diretório do arquivo
       vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                           ,pr_cdcooper => pr_cdcooper);
       -- Local Origem Arquivo                                 
       vr_origem_arq  := vr_utlfileh || '/upload/' || pr_nmarquiv;      
       
       -- Local Destino Arquivo
       vr_destino_arq := vr_utlfileh || '/salvar/' || pr_nmarquiv;                             
    
          
      -- Verifica se nome do arquivo foi informado 
      IF LENGTH(pr_nmarquiv) > 0 THEN 
        -- Move o Arquivo Processado para Pasta Salvar
        gene0001.pc_OScommand_Shell('mv ' || vr_origem_arq || ' ' || vr_destino_arq);
      END IF;
     
     EXCEPTION
       WHEN vr_exc_critico THEN
         -- Atualiza campo de erro
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;  
         ROLLBACK;
       WHEN OTHERS THEN
         -- Atualiza campo de erro
         pr_cdcritic := 0;
         pr_dscritic := 'Erro CUST0001.pc_processar_arquivo: ' || SQLERRM;
         ROLLBACK;
     END;
     
     -- Salva Alterações Efetuadas
     COMMIT; 
     
   END pc_processar_arquivo;              
                                       
   
   PROCEDURE pc_conciliar_cheque_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                         ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                         ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                         ,pr_dsdocmc7      IN crapdcc.dsdocmc7%TYPE  -- CMC7
                                         ,pr_nrseqarq      IN crapdcc.nrseqarq%TYPE  -- Numero Sequencial
                                         ,pr_intipmvt      IN crapdcc.intipmvt%TYPE  -- Tipo de Movimento (1-Arquivo/3-Manual)
                                         ,pr_inconcil      IN crapdcc.inconcil%TYPE  -- Indicador de conciliar (0-Pendente, 1-OK, 2-Sem físico)
                                         ,pr_dtmvtolt      IN crapass.dtmvtolt%TYPE
                                         ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                         ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro                               

    BEGIN
      
    DECLARE
        
      -- CURSORES
      
      -- Dados Detalhe Custodia de Cheque
      CURSOR cr_crapdcc(pr_cdcooper IN crapdcc.cdcooper%TYPE
                       ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                       ,pr_nrremret IN crapdcc.nrremret%TYPE
                       ,pr_dsdocmc7 IN crapdcc.dsdocmc7%TYPE
                       ,pr_nrseqarq IN crapdcc.nrseqarq%TYPE
                       ,pr_intipmvt IN crapdcc.intipmvt%TYPE) IS
        SELECT 
          crapdcc.cdocorre,
          crapdcc.cdcooper,
          crapdcc.nrdconta,
          crapdcc.cdcmpchq,
          crapdcc.cdbanchq,
          crapdcc.cdagechq,
          crapdcc.nrctachq,
          crapdcc.nrcheque,
          crapdcc.vlcheque,
          crapdcc.dtlibera,
          crapdcc.nrseqarq,
          crapdcc.dsdocmc7,
          crapdcc.nrremret,
          crapdcc.inchqcop,
          crapdcc.intipmvt
        FROM crapdcc crapdcc
        WHERE crapdcc.cdcooper = pr_cdcooper 
          AND crapdcc.nrdconta = pr_nrdconta
          AND crapdcc.nrremret = pr_nrremret
          AND crapdcc.dsdocmc7 = pr_dsdocmc7
          AND crapdcc.nrseqarq = pr_nrseqarq
          AND crapdcc.intipmvt = pr_intipmvt
          AND crapdcc.cdtipmvt = 1; -- Remessa          
      rw_crapdcc cr_crapdcc%ROWTYPE; 
      
      -- Dados Detalhe Custodia de Cheque
      CURSOR cr_crapocc(pr_cdocorre IN crapocc.cdocorre%TYPE) IS
        SELECT crapocc.dsocorre
        FROM crapocc crapocc
        WHERE crapocc.cdtipmvt = 21 -- Inclusao Rejeitada
          AND crapocc.intipmvt = 2  -- Retorno
          AND UPPER(crapocc.cdocorre) = UPPER(pr_cdocorre);             
      rw_crapocc cr_crapocc%ROWTYPE; 
      
      vr_exc_erro    EXCEPTION;
      vr_erro_update EXCEPTION;
      vr_ocorrencia  EXCEPTION;
      
      vr_cdtipmvt crapocc.cdtipmvt%TYPE;
      vr_cdocorre crapocc.cdocorre%TYPE;

      -- typ_tab_erro Generica
      pr_tab_erro GENE0001.typ_tab_erro;

      BEGIN
        
      BEGIN
      
        -- Verifica o cheque possui ocorrencia
        OPEN cr_crapdcc(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrremret => pr_nrremret
                       ,pr_dsdocmc7 => pr_dsdocmc7
                       ,pr_nrseqarq => pr_nrseqarq
                       ,pr_intipmvt => pr_intipmvt);
        FETCH cr_crapdcc
          INTO rw_crapdcc;
        -- Se não encontrar
        IF cr_crapdcc%NOTFOUND THEN
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapdcc;
          vr_dscritic := 'Registro nao Encontrado.'; 
          RAISE vr_exc_erro;
        ELSE
          vr_cdocorre := rw_crapdcc.cdocorre;
          -- Apenas fechar o cursor
          CLOSE cr_crapdcc;
        END IF; 
        
        -- Utiliza a validação padrão para saber a situação do cheque
        pc_validar_cheque(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsdocmc7 => pr_dsdocmc7
                         ,pr_cdbanchq => rw_crapdcc.cdbanchq
                         ,pr_cdagechq => rw_crapdcc.cdagechq
                         ,pr_cdcmpchq => rw_crapdcc.cdcmpchq
                         ,pr_nrctachq => rw_crapdcc.nrctachq
                         ,pr_nrcheque => rw_crapdcc.nrcheque
                         ,pr_dtlibera => rw_crapdcc.dtlibera
                         ,pr_vlcheque => rw_crapdcc.vlcheque
                         ,pr_nrremret => rw_crapdcc.nrremret
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_intipmvt => rw_crapdcc.intipmvt
                         ,pr_inchqcop => rw_crapdcc.inchqcop
                         ,pr_cdtipmvt => vr_cdtipmvt
                         ,pr_cdocorre => vr_cdocorre
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         ,pr_tab_erro => pr_tab_erro);
        
        -- Se encontrar cheque já custodiado
        IF nvl(vr_cdtipmvt,0) > 0 AND TRIM(vr_cdocorre) IS NOT NULL THEN
          RAISE vr_ocorrencia;          
        END IF;  

        -- Atualizar campo inconcil na tabela crapdcc
        UPDATE crapdcc
           SET inconcil = pr_inconcil -- Altera para Conciliado
              ,cdocorre = ' '
         WHERE crapdcc.cdcooper = pr_cdcooper
           AND crapdcc.nrdconta = pr_nrdconta
           AND crapdcc.nrremret = pr_nrremret
           AND crapdcc.dsdocmc7 = pr_dsdocmc7
           AND crapdcc.nrseqarq = pr_nrseqarq
           AND crapdcc.intipmvt = pr_intipmvt;
               
        IF SQL%ROWCOUNT = 0 THEN
          RAISE vr_erro_update;
        END IF;
                 
      EXCEPTION
        WHEN vr_ocorrencia  THEN
          IF TRIM(NVL(vr_cdocorre,' ')) IS NOT NULL THEN
               
            UPDATE crapdcc
               SET crapdcc.cdocorre = vr_cdocorre,
                   crapdcc.inconcil = 0
             WHERE crapdcc.cdcooper = rw_crapdcc.cdcooper
               AND crapdcc.nrdconta = rw_crapdcc.nrdconta
               AND crapdcc.nrremret = rw_crapdcc.nrremret
               AND crapdcc.dsdocmc7 = rw_crapdcc.dsdocmc7
               AND crapdcc.nrseqarq = rw_crapdcc.nrseqarq
               AND crapdcc.intipmvt = rw_crapdcc.intipmvt;
	                 
            IF SQL%ROWCOUNT = 0 THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar CRAPDCC: '||SQLERRM;
                 
              -- Registrar Log;
              CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nmarquiv => 'REMRET: ' || TRIM(to_char(pr_nrremret))
                                           ,pr_textolog => 'Cheque Nao Conciliado'
                                           ,pr_cdcritic => pr_cdcritic
                                           ,pr_dscritic => pr_dscritic);
                 
              RAISE vr_exc_erro;
            END IF;   
             
            -- Verifica o cheque possui ocorrencia
            OPEN cr_crapocc(pr_cdocorre => nvl(vr_cdocorre,rw_crapdcc.cdocorre));
            FETCH cr_crapocc
              INTO rw_crapocc;
            -- Se não encontrar
            IF cr_crapocc%NOTFOUND THEN
              -- Fechar o cursor pois haverá raise
              CLOSE cr_crapocc;
              vr_dscritic := 'Descritivo da Ocorrencia nao Encontrado.'; 
              RAISE vr_exc_erro;
            ELSE
              -- Fechar o cursor
              CLOSE cr_crapocc;
              vr_dscritic := rw_crapocc.dsocorre;
              RAISE vr_exc_erro;
            END IF;
          END IF; 
             
        WHEN vr_erro_update THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao atualizar CRAPDCC: '||SQLERRM;
             
          -- Registrar Log;
          CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nmarquiv => 'REMRET: ' || TRIM(to_char(pr_nrremret))
                                       ,pr_textolog => 'Cheque Nao Conciliado'
                                       ,pr_cdcritic => pr_cdcritic
                                       ,pr_dscritic => pr_dscritic);
             
          RAISE vr_exc_erro;
        END;
         
        -- Salva Alterações
        COMMIT;
        
      EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro ao efetuar conciliacao: ' || SQLERRM;
      END;
      
    END pc_conciliar_cheque_arquivo;       
    
    -- Procedure para custodiar cheques               
    PROCEDURE pc_custodiar_cheques (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                   ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                   ,pr_nrconven      IN crapccc.nrconven%TYPE  -- Numero do Convenio
                                   ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                   ,pr_intipmvt      IN craphcc.intipmvt%TYPE  -- Tipo de Movimento (1-Arquivo/3-Manual)
                                   ,pr_dtmvtolt      IN DATE                   -- Data do Movimento
                                   ,pr_idorigem      IN INTEGER                -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                                   ,pr_cdoperad      IN crapope.cdoperad%TYPE  -- Codigo Operador
                                   ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                   ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro                                  
      /* .............................................................................
      Programa: pc_custodiar_cheques
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : 
      Data    :                                   Ultima atualizacao: 27/04/2016

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar a custódia de cheque por arquivo e de forma manual

      Alteracoes: 25/06/2015 - Ajustado a criação de registro de retorno para os 
                               cheques custodiados manualmente, permitindo gerar apenas 
                               para os arquivos de remessa. (Douglas - Chamado 300777)

                  26/06/2015 - Criado cursor para identificar o intipmvt na custódia de cheque
                               (Douglas - 301650)

                  13/08/2015 - Projeto Melhorias de Tarifas. (Jaison/Diego)

                  27/04/2016 - Adicionado o parametro de tipo de movimento (1-Arquivo/3-Manual)
                               e ajustado para utilizar o parametro (Douglas - Chamado 441428)
                  
      ............................................................................. */
    
     BEGIN
       
     DECLARE
       -- Cursor generico de calendario
       rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
     
       -- Buscar ultimo numero de retorno utilizado
       CURSOR cr_craphcc(pr_cdcooper IN craphcc.cdcooper%TYPE     --> Código da cooperativa
                        ,pr_nrdconta IN craphcc.nrdconta%TYPE     --> Numero da Conta
                        ,pr_nrconven IN craphcc.nrconven%TYPE) IS --> Numero do Convenio
         SELECT NVL(MAX(nrremret),0) nrremret
         FROM craphcc
         WHERE craphcc.cdcooper = pr_cdcooper 
           AND craphcc.nrdconta = pr_nrdconta
           AND craphcc.nrconven = pr_nrconven
           AND craphcc.nrremret > 0 
           AND craphcc.intipmvt = 2 -- Retorno 
         ORDER BY craphcc.cdcooper,
                  craphcc.nrdconta,
                  craphcc.nrconven,
                  craphcc.intipmvt;              
       rw_craphcc cr_craphcc%ROWTYPE; 
       
       -- Cursor para verificar se o Arquivo já foi processado
       CURSOR cr_craphcc_1(pr_cdcooper IN craphcc.cdcooper%TYPE     --> Código da cooperativa
                          ,pr_nrdconta IN craphcc.nrdconta%TYPE     --> Numero da Conta
                          ,pr_nrconven IN craphcc.nrconven%TYPE     --> Numero do Convenio
                          ,pr_nrremret IN craphcc.nrremret%TYPE     --> Numero do Arquivo
                          ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS --> Tipo de Movimento (1-Arquivo/3-Manual)
         SELECT insithcc
         FROM craphcc
         WHERE craphcc.cdcooper = pr_cdcooper 
           AND craphcc.nrdconta = pr_nrdconta
           AND craphcc.nrconven = pr_nrconven
           AND craphcc.nrremret = pr_nrremret
           AND craphcc.intipmvt = pr_intipmvt -- 1 - Remessa / 3 - Manual
           AND craphcc.insithcc = 2; -- Processado
       rw_craphcc_1 cr_craphcc_1%ROWTYPE;
       
       -- Cursor para buscar o situação do header do arquivo
       CURSOR cr_craphcc_2(pr_cdcooper IN craphcc.cdcooper%TYPE     --> Código da cooperativa
                          ,pr_nrdconta IN craphcc.nrdconta%TYPE     --> Numero da Conta
                          ,pr_nrconven IN craphcc.nrconven%TYPE     --> Numero do Convenio
                          ,pr_nrremret IN craphcc.nrremret%TYPE     --> Numero do Arquivo
                          ,pr_intipmvt IN craphcc.intipmvt%TYPE) IS --> Tipo de Movimento (1-Arquivo/3-Manual)
         SELECT craphcc.intipmvt
         FROM craphcc
         WHERE craphcc.cdcooper = pr_cdcooper 
           AND craphcc.nrdconta = pr_nrdconta
           AND craphcc.nrconven = pr_nrconven
           AND craphcc.nrremret = pr_nrremret
           AND craphcc.intipmvt = pr_intipmvt; -- 1 - Remessa / 3 - Manual
       rw_craphcc_2 cr_craphcc_2%ROWTYPE;

       --Selecionar os dados Detalhamento Custodia de Cheque
       CURSOR cr_crapdcc_1 (pr_cdcooper IN crapdcc.cdcooper%TYPE
                           ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                           ,pr_nrconven IN crapdcc.nrconven%TYPE
                           ,pr_nrremret IN crapdcc.nrremret%TYPE 
                           ,pr_intipmvt IN crapdcc.intipmvt%TYPE) IS
         SELECT crapdcc.dtlibera
               ,COUNT(*) qtinfoln
               ,SUM(crapdcc.vlcheque) vlcheque
         FROM crapdcc crapdcc
         WHERE crapdcc.cdcooper = pr_cdcooper
         AND   crapdcc.nrdconta = pr_nrdconta
         AND   crapdcc.nrconven = pr_nrconven
         AND   crapdcc.nrremret = pr_nrremret
         AND   crapdcc.cdtipmvt = 1           -- Solicitação de Inclusão
         AND   TRIM(crapdcc.cdocorre) IS NULL -- Sem Ocorrencias
         AND   crapdcc.inconcil = 1           -- Cheque Conciliado
         AND   crapdcc.intipmvt = pr_intipmvt -- 1 - Remessa / 3 - Manual
         GROUP BY crapdcc.dtlibera;
       rw_crapdcc_1 cr_crapdcc_1%ROWTYPE; 
       
       CURSOR cr_crapdcc_2 (pr_cdcooper IN crapdcc.cdcooper%TYPE
                           ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                           ,pr_nrconven IN crapdcc.nrconven%TYPE
                           ,pr_nrremret IN crapdcc.nrremret%TYPE
                           ,pr_dtlibera IN crapdcc.dtlibera%TYPE
                           ,pr_intipmvt IN crapdcc.intipmvt%TYPE) IS
         SELECT crapdcc.dtlibera
               ,crapdcc.cdcmpchq
               ,crapdcc.cdbanchq
               ,crapdcc.cdagechq
               ,crapdcc.nrctachq
               ,crapdcc.nrcheque
               ,crapdcc.vlcheque
               ,crapdcc.dsdocmc7
               ,crapdcc.nrdconta
               ,crapdcc.cdbccxlt
               ,crapdcc.cdagenci
               ,crapdcc.nrseqarq
               ,crapdcc.nrremret
               ,crapdcc.intipmvt
               ,crapdcc.inchqcop
         FROM crapdcc crapdcc
         WHERE crapdcc.cdcooper = pr_cdcooper
         AND   crapdcc.nrdconta = pr_nrdconta
         AND   crapdcc.nrconven = pr_nrconven
         AND   crapdcc.nrremret = pr_nrremret
         AND   crapdcc.dtlibera = pr_dtlibera
         AND   crapdcc.cdtipmvt = 1           -- Solicitação de Inclusão
         AND   TRIM(crapdcc.cdocorre) IS NULL -- Sem Ocorrencias
         AND   crapdcc.inconcil = 1           -- Cheque Conciliado
         AND   crapdcc.intipmvt = pr_intipmvt;-- 1 - Remessa / 3 - Manual
       rw_crapdcc_2 cr_crapdcc_2%ROWTYPE;
       
       CURSOR cr_crapdcc_3 (pr_cdcooper IN crapdcc.cdcooper%TYPE
                           ,pr_nrdconta IN crapdcc.nrdconta%TYPE
                           ,pr_nrconven IN crapdcc.nrconven%TYPE
                           ,pr_nrremret IN crapdcc.nrremret%TYPE 
                           ,pr_intipmvt IN crapdcc.intipmvt%TYPE) IS
         SELECT * -- Serão Usado Todos os Campos
         FROM crapdcc crapdcc
         WHERE crapdcc.cdcooper = pr_cdcooper
         AND   crapdcc.nrdconta = pr_nrdconta
         AND   crapdcc.nrconven = pr_nrconven
         AND   crapdcc.nrremret = pr_nrremret
         AND   crapdcc.intipmvt = pr_intipmvt; -- 1 - Remessa / 3 - Manual
       rw_crapdcc_3 cr_crapdcc_3%ROWTYPE; 
       
       -- Cursor generico de parametrizacao
       CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                        ,pr_nmsistem IN craptab.nmsistem%TYPE
                        ,pr_tptabela IN craptab.tptabela%TYPE
                        ,pr_cdempres IN craptab.cdempres%TYPE
                        ,pr_cdacesso IN craptab.cdacesso%TYPE
                        ,pr_tpregist IN craptab.tpregist%TYPE) IS
         SELECT craptab.dstextab
           FROM craptab craptab
          WHERE craptab.cdcooper = pr_cdcooper
            AND upper(craptab.nmsistem) = pr_nmsistem
            AND upper(craptab.tptabela) = pr_tptabela
            AND craptab.cdempres = pr_cdempres
            AND upper(craptab.cdacesso) = pr_cdacesso
            AND craptab.tpregist = pr_tpregist;
       rw_craptab cr_craptab%ROWTYPE;
       
       -- Cursor para buscar ultimo numero de Lote
       CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE) IS
         SELECT NVL(MAX(craplot.nrdolote),4500) ultimo_lote
			     FROM craplot craplot
          WHERE craplot.cdcooper  = pr_cdcooper 
            AND craplot.dtmvtolt  = pr_dtmvtolt
            AND craplot.cdagenci  = pr_cdagenci
            AND craplot.cdbccxlt  = 600 
            AND craplot.nrdolote >= 4500
            AND craplot.tplotmov  = 19;
       rw_craplot cr_craplot%ROWTYPE;     
       
       -- Cursor Operador
       CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                        ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
          SELECT crapope.cdagenci
            FROM crapope crapope
           WHERE crapope.cdcooper = pr_cdcooper
             AND crapope.cdoperad = pr_cdoperad;
       rw_crapope cr_crapope%ROWTYPE;

       -- Cursor para tipo de pessoa
       CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
          SELECT crapass.inpessoa
            FROM crapass crapass
           WHERE crapass.cdcooper = pr_cdcooper
             AND crapass.nrdconta = pr_nrdconta;

       -- typ_tab_erro Generica
       vr_tab_erro GENE0001.typ_tab_erro;                     
       
       vr_nmarquiv craphcc.nmarquiv%TYPE;
       vr_nrremret craphcc.nrremret%TYPE;
       
       vr_exc_erro    EXCEPTION;
       vr_erro_update EXCEPTION;
       
       -- Valor Cheque Maior
       vr_vlchqmai NUMBER;
       
       vr_nrcalcul NUMBER;
       vr_flgdigok1 BOOLEAN;
       vr_flgdigok2 BOOLEAN;
       vr_flgdigok3 BOOLEAN;
       
       vr_nrddigc1 NUMBER; 
       vr_nrddigc2 NUMBER;
       vr_nrddigc3 NUMBER;
       
       vr_nrseqdig NUMBER;
       
       vr_inchqcop NUMBER;
       
       vr_nrdolote NUMBER;
       
       -- Variaveis para acumular valores craplot
       vr_qtcompcc NUMBER := 0;
       vr_vlcompcc NUMBER := 0;
       vr_qtcompci NUMBER := 0;
       vr_vlcompci NUMBER := 0;
       vr_qtcompcs NUMBER := 0;
       vr_vlcompcs NUMBER := 0;
       
       vr_nrdocmto NUMBER;
       
       vr_cdtipmvt crapdcc.cdtipmvt%TYPE;
       vr_intipmvt craphcc.intipmvt%TYPE;
       
       vr_qtdconfi NUMBER;
       vr_qtdrejei NUMBER;
       
       vr_nrdrowid ROWID;
       
       vr_dsdctitg VARCHAR2(8);
       vr_stsnrcal NUMBER;
       
       vr_dsorigem VARCHAR2(10);
       
       vr_cdocorre crapdcc.cdocorre%TYPE; 
       
       vr_dstextab VARCHAR2(4000);
       
       vr_dtcredit DATE;
       
       vr_nrdconta_ver_cheque NUMBER;
       vr_dsdaviso VARCHAR2(4000);       
       
       vr_inpessoa crapass.inpessoa%TYPE;
       vr_cdbattar VARCHAR2(100);
       vr_cdhistor INTEGER;
       vr_cdhisest INTEGER;
       vr_vltarifa NUMBER;
       vr_dtdivulg DATE;
       vr_dtvigenc DATE;
       vr_cdfvlcop INTEGER;
       vr_vltottar NUMBER := 0;
       vr_nrqtddcc INTEGER := 0;
       vr_rowid    ROWID;
     
       BEGIN
         -- Leitura do calendario da cooperativa
         OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
         FETCH btch0001.cr_crapdat INTO rw_crapdat;
         -- Fechar o cursor
         CLOSE btch0001.cr_crapdat;

         -- Verifica se o Arquivo já Foi Processado
         OPEN cr_craphcc_1(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrconven => pr_nrconven
                          ,pr_nrremret => pr_nrremret
                          ,pr_intipmvt => pr_intipmvt);
         FETCH cr_craphcc_1 INTO rw_craphcc_1;
         
         -- Verifica se a retornou registro
         IF cr_craphcc_1%NOTFOUND THEN
           -- Apenas Fecha cursor
           CLOSE cr_craphcc_1;
         ELSE
           -- Fecha Cursor
           CLOSE cr_craphcc_1;
           -- Gera critica
           vr_cdcritic := 0;
           vr_dscritic := 'Remessa ja Processada!';
           RAISE vr_exc_erro;
         END IF;
         
         vr_nrremret := 0;
         
         -- Buscar o Último Lote de Retorno do Cooperado
         OPEN cr_craphcc(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrconven => pr_nrconven);
         FETCH cr_craphcc INTO rw_craphcc;

         -- Verifica se a retornou registro
         IF cr_craphcc%NOTFOUND THEN
           CLOSE cr_craphcc;
           -- Atribui valor
           vr_nrremret := 1;
         ELSE
           CLOSE cr_craphcc;
           -- Atribui valor
           vr_nrremret := rw_craphcc.nrremret + 1;
          
         END IF;
         
         IF vr_nrremret = 0 THEN
            vr_nrremret := 1;
         END IF;
                           
         vr_nmarquiv := 'CST_' || TRIM(to_char(pr_nrdconta,'00000000'))  || '_' ||
                                  TRIM(to_char(vr_nrremret,'000000000')) || '.RET';
                        
         -- Buscar Dados do Operador
         OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad);
         FETCH cr_crapope INTO rw_crapope;

         -- Verifica se a retornou registro
         IF cr_crapope%NOTFOUND THEN
           CLOSE cr_crapope;
           vr_cdcritic := 0;
           vr_dscritic := 'Registro Operador nao Disponivel!';
           RAISE vr_exc_erro;
         ELSE
           -- Apenas Fecha o Cursor
           CLOSE cr_crapope;
         END IF;               

         -- Busca a informação do header do arquivo que está sendo processado
         OPEN cr_craphcc_2(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrconven => pr_nrconven
                          ,pr_nrremret => pr_nrremret
                          ,pr_intipmvt => pr_intipmvt);
         FETCH cr_craphcc_2 INTO rw_craphcc_2;
         
         -- Verifica se a retornou registro
         IF cr_craphcc_2%NOTFOUND THEN
           -- Apenas Fecha cursor
           CLOSE cr_craphcc_2;
           -- Gera critica
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao buscar CRAPHCC(CUST0001.pc_custodiar_cheques)';
           RAISE vr_exc_erro;
         END IF;
         
         CLOSE cr_craphcc_2;

         -- Somente Gerar as informações de retorno quando o tipo de movimentaçã o for 1 - Remessa
         IF rw_craphcc_2.intipmvt = 1 THEN
         
           -- Criar Lote de Informações de Retorno (craphcc) 
           BEGIN
             INSERT INTO craphcc
               (cdcooper
               ,nrdconta
               ,nrconven
               ,intipmvt
               ,nrremret
               ,dtmvtolt
               ,nmarquiv
               ,idorigem
               ,dtdgerac
               ,hrdgerac
               ,insithcc)
             VALUES
               (pr_cdcooper
               ,pr_nrdconta
               ,pr_nrconven
               ,2 -- Retorno
               ,vr_nrremret
               ,pr_dtmvtolt
               ,vr_nmarquiv
               ,pr_idorigem
               ,pr_dtmvtolt
               ,to_char(SYSDATE,'HH24MISS')
               ,1); -- Pendente
           EXCEPTION
             WHEN OTHERS THEN
               vr_cdcritic := 0;
               vr_dscritic := 'Erro ao inserir CRAPHCC: '||SQLERRM;
               RAISE vr_exc_erro;
           END;  -- Fim - Criar Lote de Informações de Retorno (craphcc)
         END IF;
           
         -- Busca valor dos Cheques Maiores
         OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                        ,pr_nmsistem => 'CRED'
                        ,pr_tptabela => 'USUARI'
                        ,pr_cdempres => 11
                        ,pr_cdacesso => 'MAIORESCHQ'
                        ,pr_tpregist => 1);
         FETCH cr_craptab INTO rw_craptab;

         -- Verifica se a retornou registro
         IF cr_craptab%NOTFOUND THEN
           CLOSE cr_craptab;
           -- Atribui valor
           vr_vlchqmai := 1;
           vr_dstextab := ' ';
         ELSE
           CLOSE cr_craptab;
           -- Atribui valor
           vr_vlchqmai := to_number(SUBSTR(rw_craptab.dstextab,01,15));
           vr_dstextab := rw_craptab.dstextab;
          
         END IF;
         
         -- Ler Registros da crapdcc
         FOR rw_crapdcc_1 IN cr_crapdcc_1(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrconven => pr_nrconven
                                         ,pr_nrremret => pr_nrremret
                                         ,pr_intipmvt => pr_intipmvt) LOOP
           -- Inicializa variaveis                            
           vr_nrseqdig := 0;
           vr_qtcompcc := 0;
           vr_vlcompcc := 0;
           vr_qtcompci := 0;
           vr_vlcompci := 0;
           vr_qtcompcs := 0;
           vr_vlcompcs := 0;  
           vr_nrdolote := 0;
           
           -- Buscar o Último Lote de Retorno do Cooperado
           OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdagenci => rw_crapope.cdagenci);
           FETCH cr_craplot INTO rw_craplot;
           CLOSE cr_craplot;
           
           vr_nrdolote := rw_craplot.ultimo_lote + 1;
           
           BEGIN 
             INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,qtinfoln
               ,vlinfocr
               ,vlinfodb
               ,tplotmov
               ,dtmvtopg
               ,cdoperad
               ,cdhistor
               ,cdbccxpg
               ,cdcooper)
             VALUES
               (pr_dtmvtolt
               ,rw_crapope.cdagenci
               ,600
               ,vr_nrdolote
               ,rw_crapdcc_1.qtinfoln
               ,rw_crapdcc_1.vlcheque
               ,rw_crapdcc_1.vlcheque
               ,19 -- Tipo de Movimento
               ,rw_crapdcc_1.dtlibera
               ,pr_cdoperad
               ,0
               ,0
               ,pr_cdcooper);     
           EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir CRAPLOT(CUST0001.pc_custodiar_cheques): '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
           END;  
           
           FOR rw_crapdcc_2 IN cr_crapdcc_2(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_nrconven => pr_nrconven
                                           ,pr_nrremret => pr_nrremret
                                           ,pr_dtlibera => rw_crapdcc_1.dtlibera
                                           ,pr_intipmvt => pr_intipmvt) LOOP

             vr_nrseqdig := vr_nrseqdig + 1;  
             vr_nrqtddcc := vr_nrqtddcc + 1;
             
             vr_inchqcop := rw_crapdcc_2.inchqcop;
             
             -- Calcula primeiro digito de controle
             vr_nrcalcul := to_number(gene0002.fn_mask(rw_crapdcc_2.cdcmpchq,'999')  ||
                                      gene0002.fn_mask(rw_crapdcc_2.cdbanchq,'999')  || 
                                      gene0002.fn_mask(rw_crapdcc_2.cdagechq,'9999') || '0');
                                   
             vr_flgdigok1 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
             
             vr_nrddigc1 := to_number(SUBSTR(to_char(vr_nrcalcul),LENGTH(to_char(vr_nrcalcul))));
              
             -- Calcula segundo digito de controle
             vr_nrcalcul :=  rw_crapdcc_2.nrctachq * 10;
             vr_flgdigok2 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
                  
             vr_nrddigc2 := to_number(SUBSTR(to_char(vr_nrcalcul),LENGTH(to_char(vr_nrcalcul))));   
         
             -- Calcula terceiro digito de controle   
             vr_nrcalcul := rw_crapdcc_2.nrcheque * 10;                             
             vr_flgdigok3 := GENE0005.fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
                  
             vr_nrddigc3 := to_number(SUBSTR(to_char(vr_nrcalcul),LENGTH(to_char(vr_nrcalcul))));  
                                                  
             -- Insere registro na tabela CRAPCST
             BEGIN
               INSERT INTO crapcst
                 (cdcooper,
                  dtmvtolt,
                  cdagenci,
                  cdbccxlt,
                  nrdolote,
                  cdcmpchq,
                  cdbanchq,
                  nrctachq,
                  nrcheque,
                  cdagechq,
                  cdopedev,
                  cdoperad,
                  dsdocmc7,
                  dtdevolu,
                  dtlibera,
                  insitchq,
                  nrdconta,
                  nrddigc1,
                  nrddigc2,
                  nrddigc3,
                  nrseqdig,
                  vlcheque,
                  inchqcop,
                  cdopeori,
                  cdageori,
                  dtinsori,
                  flcstarq)
               VALUES
                 (pr_cdcooper
                 ,pr_dtmvtolt
                 ,rw_crapope.cdagenci
                 ,600
                 ,vr_nrdolote
                 ,rw_crapdcc_2.cdcmpchq
                 ,rw_crapdcc_2.cdbanchq
                 ,rw_crapdcc_2.nrctachq
                 ,rw_crapdcc_2.nrcheque
                 ,rw_crapdcc_2.cdagechq
                 ,' '
                 ,pr_cdoperad
                 ,rw_crapdcc_2.dsdocmc7
                 ,NULL
                 ,rw_crapdcc_2.dtlibera
                 ,0
                 ,rw_crapdcc_2.nrdconta -- Custodiante
                 ,vr_nrddigc1
                 ,vr_nrddigc2
                 ,vr_nrddigc3
                 ,vr_nrseqdig
                 ,rw_crapdcc_2.vlcheque
                 ,rw_crapdcc_2.inchqcop
                 ,pr_cdoperad -- INICIO - Alteracoes referentes a M181 - Rafael Maciel (RKAM)"
                 ,NVL(rw_crapope.cdagenci, 0)
                 ,SYSDATE -- FIM - Alteracoes referentes a M181 - Rafael Maciel (RKAM)"
                 ,1); -- Flag para Informar que o Cheque foi Custodiado por Arquivo (TRUE)
             EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir CRAPCST(CUST0001.pc_custodiar_cheques): '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_erro;
             END;
               
             -- Rotina para totalizar alguns campos da craplot 
             IF vr_inchqcop = 1 THEN
               vr_qtcompcc := vr_qtcompcc + 1;
               vr_vlcompcc := vr_vlcompcc + rw_crapdcc_2.vlcheque;
             ELSE
               IF rw_crapdcc_2.vlcheque < vr_vlchqmai THEN
                 vr_qtcompci := vr_qtcompci + 1;
                 vr_vlcompci := vr_vlcompci + rw_crapdcc_2.vlcheque;
               ELSE
                 vr_qtcompcs := vr_qtcompcs + 1;
                 vr_vlcompcs := vr_vlcompcs + rw_crapdcc_2.vlcheque;
               END IF;  
             END IF; 
             
             -- Se o emitente do cheque for da cooperativa, gerar craplau
             -- para que, no dia do vencimento do cheque (dtlibera), seja
             -- debitado de sua conta
             
             IF vr_inchqcop = 1 THEN -- Cheque Cooperativa
               
               vr_nrdocmto := to_number(to_char(rw_crapdcc_2.nrcheque) ||
                                        to_char(vr_nrddigc3) );
                                    
               -- Retorna a conta integracão com digito convertido (Antiga fontes/digbbx.p)
               gene0005.pc_conta_itg_digito_x(pr_nrcalcul => rw_crapdcc_2.nrctachq,
                                              pr_dscalcul => vr_dsdctitg,
                                              pr_stsnrcal => vr_stsnrcal,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic);
                                              
               -- Verifica se ocorreu erro na execucao
               IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
               END IF;
               
               vr_dsdaviso := NULL;               
               vr_nrdconta_ver_cheque := 0;               
               
               -- Verificar Cheque
               CUST0001.pc_ver_cheque(pr_cdcooper => pr_cdcooper 
                                     ,pr_nrcustod => pr_nrdconta
                                     ,pr_cdbanchq => rw_crapdcc_2.cdbanchq
                                     ,pr_cdagechq => rw_crapdcc_2.cdagechq
                                     ,pr_nrctachq => rw_crapdcc_2.nrctachq
                                     ,pr_nrcheque => rw_crapdcc_2.nrcheque
                                     ,pr_nrddigc3 => 1
                                     ,pr_vlcheque => rw_crapdcc_2.vlcheque
                                     ,pr_nrdconta => vr_nrdconta_ver_cheque
                                     ,pr_dsdaviso => vr_dsdaviso
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);               
                                     
               -- Verifica se ocorreu erro na execucao
               IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
               END IF;                                     
                                                             
               BEGIN
                 -- Incluir tratamento erro
                 INSERT INTO craplau                          
                   (dtmvtolt
                   ,cdagenci
                   ,cdbccxlt
                   ,nrdolote
                   ,nrdconta
                   ,nrdocmto
                   ,vllanaut
                   ,cdhistor
                   ,nrseqdig
                   ,nrdctabb
                   ,cdbccxpg
                   ,dtmvtopg   
                   ,tpdvalor
                   ,insitlau
                   ,cdcritic
                   ,nrcrcard
                   ,nrseqlan
                   ,dtdebito
                   ,cdcooper
                   ,cdseqtel
                   ,nrdctitg)
                 VALUES
                   (pr_dtmvtolt
                   ,rw_crapope.cdagenci
                   ,600
                   ,vr_nrdolote
                   ,vr_nrdconta_ver_cheque -- rw_crapdcc_2.nrctachq -- vr_nrdconta
                   ,vr_nrdocmto
                   ,rw_crapdcc_2.vlcheque
                   ,21
                   ,vr_nrseqdig
                   ,rw_crapdcc_2.nrctachq
                   ,011
                   ,rw_crapdcc_2.dtlibera    
                   ,1
                   ,1
                   ,0
                   ,0
                   ,0
                   ,NULL
                   ,pr_cdcooper
                   ,to_char(pr_dtmvtolt,'DD/MM/RRRR')                           || ' ' ||
                    gene0002.fn_mask(to_char(rw_crapope.cdagenci),'999')        || ' ' ||
                    '600'                                                       || ' ' ||
                    gene0002.fn_mask(to_char(vr_nrdolote),'999999')             || ' ' ||
                    gene0002.fn_mask(to_char(rw_crapdcc_2.cdcmpchq),'999')      || ' ' ||
                    gene0002.fn_mask(to_char(rw_crapdcc_2.cdbanchq),'999')      || ' ' ||
                    gene0002.fn_mask(to_char(rw_crapdcc_2.cdagechq),'9999')     || ' ' ||
                    gene0002.fn_mask(to_char(rw_crapdcc_2.nrctachq),'99999999') || ' ' ||
                    gene0002.fn_mask(to_char(rw_crapdcc_2.nrcheque),'999999')
                   ,vr_dsdctitg);
               EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao inserir CRAPLAU(CUST0001.pc_custodiar_cheques): '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END;  
             END IF;     
             
             -- Atualiza Registro craphcc como processado
             BEGIN
               UPDATE crapdcc
                 SET cdagenci = rw_crapope.cdagenci -- Agencia
                    ,cdbccxlt = 600                 -- Banco Caixa 
                    ,nrdolote = vr_nrdolote         -- Lote
                 WHERE crapdcc.cdcooper = pr_cdcooper
                   AND crapdcc.nrdconta = pr_nrdconta
                   AND crapdcc.nrconven = pr_nrconven
                   AND crapdcc.intipmvt = rw_crapdcc_2.intipmvt
                   AND crapdcc.nrremret = rw_crapdcc_2.nrremret
                   AND crapdcc.nrseqarq = rw_crapdcc_2.nrseqarq;
                   
               IF SQL%ROWCOUNT = 0 THEN
                 RAISE vr_erro_update;
               END IF;   
                   
             EXCEPTION
               WHEN vr_erro_update THEN
                 -- Registrar Log;
                 CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nmarquiv => 'REMRET: ' || TRIM(to_char(pr_nrremret))
                                              ,pr_textolog => 'Erro ao atualizar CRAPDCC. '
                                              ,pr_cdcritic => pr_cdcritic
                                              ,pr_dscritic => pr_dscritic);
                                              
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao atualizar CRAPDCC: '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               WHEN OTHERS THEN
                 -- Registrar Log;
                 CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_nmarquiv => 'REM/RET: ' || to_char(pr_nrremret)
                                              ,pr_textolog => 'Erro ao atualizar CRAPDCC. '
                                              ,pr_cdcritic => pr_cdcritic
                                              ,pr_dscritic => pr_dscritic);
                                              
                 pr_cdcritic := 0;
                 pr_dscritic := 'Erro ao atualizar CRAPDCC: '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
                 
             END;
               
           END LOOP;      
           
           BEGIN
             UPDATE craplot SET       
               craplot.qtinfocc = vr_qtcompcc,
               craplot.vlinfocc = vr_vlcompcc,
               craplot.qtcompcc = vr_qtcompcc,
               craplot.vlcompcc = vr_vlcompcc,               
               craplot.qtinfoci = vr_qtcompci,
               craplot.vlinfoci = vr_vlcompci,
               craplot.qtcompci = vr_qtcompci,
               craplot.vlcompci = vr_vlcompci,
               craplot.qtinfocs = vr_qtcompcs,
               craplot.vlinfocs = vr_vlcompcs,
               craplot.qtcompcs = vr_qtcompcs,
               craplot.vlcompcs = vr_vlcompcs,
               -- Totais
               craplot.qtcompln = vr_qtcompcc + vr_qtcompci + vr_qtcompcs,
               craplot.vlcompdb = vr_vlcompcc + vr_vlcompci + vr_vlcompcs,
               craplot.vlcompcr = vr_vlcompcc + vr_vlcompci + vr_vlcompcs
               
             WHERE craplot.cdcooper = pr_cdcooper 
               AND craplot.dtmvtolt = pr_dtmvtolt
               AND craplot.cdagenci = rw_crapope.cdagenci
               AND craplot.cdbccxlt = 600
               AND craplot.nrdolote = vr_nrdolote
               AND craplot.tplotmov = 19;   
             
             IF SQL%ROWCOUNT = 0 THEN
               RAISE vr_erro_update;
             END IF;  
               
           EXCEPTION
           WHEN vr_erro_update THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar CRAPLOT: ' || SQLERRM;
             --Levantar Excecao
             RAISE vr_exc_erro;  
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar CRAPLOT: ' || SQLERRM;
             --Levantar Excecao
             RAISE vr_exc_erro;
           END;    
                                  
         END LOOP; -- Fim LOOP rw_crapdcc_1   

         -- Selecionar o tipo de pessoa
         OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta);
         FETCH cr_crapass INTO vr_inpessoa;
         CLOSE cr_crapass;

         -- Codigo da tarifa
         IF vr_inpessoa = 1 THEN
           vr_cdbattar := 'CUSTDCTOPF';
         ELSE
           vr_cdbattar := 'CUSTDCTOPJ';
         END IF;

         -- Busca o valor da tarifa
         TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                               ,pr_cdbattar  => vr_cdbattar   -- Codigo Tarifa
                                               ,pr_vllanmto  => 0             -- Valor Lancamento
                                               ,pr_cdprogra  => 'CUST0001'    -- Codigo Programa
                                               ,pr_cdhistor  => vr_cdhistor   -- Codigo Historico
                                               ,pr_cdhisest  => vr_cdhisest   -- Historico Estorno
                                               ,pr_vltarifa  => vr_vltarifa   -- Valor tarifa
                                               ,pr_dtdivulg  => vr_dtdivulg   -- Data Divulgacao
                                               ,pr_dtvigenc  => vr_dtvigenc   -- Data Vigencia
                                               ,pr_cdfvlcop  => vr_cdfvlcop   -- Codigo faixa valor cooperativa
                                               ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                               ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                               ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
         -- Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           -- Se possui erro no vetor
           IF vr_tab_erro.Count > 0 THEN
             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
           ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'Nao foi possivel carregar a tarifa.';
           END IF;
           -- Levantar Excecao
           RAISE vr_exc_erro;
         END IF;
         
         -- O valor sera baseado na quantidade(crapdcc) de cheques, multiplicado pelo valor da tarifa
         vr_vltottar := vr_vltarifa * vr_nrqtddcc;

         -- Criar Lancamento automatico tarifa
         TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                         ,pr_nrdconta      => pr_nrdconta
                                         ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                         ,pr_cdhistor      => vr_cdhistor
                                         ,pr_vllanaut      => vr_vltottar
                                         ,pr_cdoperad      => '1'
                                         ,pr_cdagenci      => 1
                                         ,pr_cdbccxlt      => 100
                                         ,pr_nrdolote      => 10133
                                         ,pr_tpdolote      => 1
                                         ,pr_nrdocmto      => 0
                                         ,pr_nrdctabb      => pr_nrdconta
                                         ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                         ,pr_cdpesqbb      => ' '
                                         ,pr_cdbanchq      => 0
                                         ,pr_cdagechq      => 0
                                         ,pr_nrctachq      => 0
                                         ,pr_flgaviso      => FALSE
                                         ,pr_tpdaviso      => 0
                                         ,pr_cdfvlcop      => vr_cdfvlcop
                                         ,pr_inproces      => rw_crapdat.inproces
                                         ,pr_rowid_craplat => vr_rowid
                                         ,pr_tab_erro      => vr_tab_erro
                                         ,pr_cdcritic      => vr_cdcritic
                                         ,pr_dscritic      => vr_dscritic);
         -- Se ocorreu erro
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           -- Se possui erro no vetor
           IF vr_tab_erro.Count > 0 THEN
             vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
             vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
           ELSE
             vr_cdcritic := 0;
             vr_dscritic := 'Erro no lancamento tarifa de custodia de cheque.';
           END IF;
           -- Levantar Excecao
           RAISE vr_exc_erro;
         END IF;

         -- Inicializar variaveis
         vr_qtdconfi := 0;
         vr_qtdrejei := 0;	
         
	       -- Processo para Gerar Informações de Retorno ao Cooperado	  
         FOR rw_crapdcc_3 IN cr_crapdcc_3(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrconven => pr_nrconven
                                         ,pr_nrremret => pr_nrremret
                                         ,pr_intipmvt => pr_intipmvt) LOOP 
                                         
           -- Para cada cheque custodiado, Gerar Informações de Retorno  
           
           vr_cdocorre:= NVL(rw_crapdcc_3.cdocorre,' ');                            
                                         
           IF rw_crapdcc_3.cdtipmvt = 1           AND 
              TRIM(rw_crapdcc_3.cdocorre) IS NULL AND
              rw_crapdcc_3.inconcil = 1           THEN
             vr_cdtipmvt := 11; -- Inclusão Confirmada
             vr_qtdconfi := vr_qtdconfi + 1;
           ELSE
             vr_cdtipmvt := 21; -- Inclusão Rejeitada			
             vr_qtdrejei := vr_qtdrejei + 1;	
             
             IF rw_crapdcc_3.inconcil = 0 AND
                TRIM(rw_crapdcc_3.cdocorre) IS NULL THEN
               vr_cdocorre := '82';  -- Cheque Não Encontrado/Não Conciliado 
             END IF;  	
                 
           END IF; 
           
           -- Caso não tenha ocorrencia deve buscar Data de Credito
           IF TRIM(vr_cdocorre) IS NULL THEN 
           
             -- Cheque de Terceiro
             IF rw_crapdcc_3.inchqcop = 0 THEN
               
               CCAF0001.pc_calcula_bloqueio_cheque (pr_cdcooper => rw_crapdcc_3.cdcooper -- Codigo Cooperativa
                                                   ,pr_dtrefere => rw_crapdcc_3.dtlibera -- Data Deposito Cheque
                                                   ,pr_cdagenci => rw_crapope.cdagenci   -- Codigo Agencia
                                                   ,pr_cdbanchq => rw_crapdcc_3.cdbanchq -- Codigo Banco cheque
                                                   ,pr_cdagechq => rw_crapdcc_3.cdagechq -- Codigo Agencia cheque
                                                   ,pr_vlcheque => rw_crapdcc_3.vlcheque -- Valor Cheque
                                                   ,pr_dstextab => vr_dstextab           -- Parametro Maiores Cheques
                                                   ,pr_dtblqchq => vr_dtcredit           -- Data Liberacao Bloq. Cheque
                                                   ,pr_cdcritic => vr_cdcritic           -- Codigo erro
                                                   ,pr_dscritic => vr_dscritic           -- Descricao erro
                                                   ,pr_tab_erro => vr_tab_erro);         -- Tabela de erros                                    
                                                  
               IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END IF;
             
             ELSE
               -- Cheque é de um Cooperado da Cooperativa deve usar data Liberação
               vr_dtcredit := rw_crapdcc_3.dtlibera;
             END IF;
           ELSE
             -- Possui ocorrencia, grava Data de Credito nula 
             vr_dtcredit := NULL;      
           END IF;  
           
           -- Semonte gerar o registro de retorno (2) quando o original for remessa (1)
           IF rw_crapdcc_3.intipmvt = 1 THEN
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
                  cdtipemi, 
                  nrinsemi, 
                  dtdcaptu, 
                  dtlibera, 
                  dtcredit, 
                  dsusoemp, 
                  cdagedev, 
                  nrctadev, 
                  cdalinea, 
                  cdocorre, 
                  inconcil, 
                  cdagenci, 
                  cdbccxlt, 
                  nrdolote,
                  inchqcop)
               VALUES
                 (rw_crapdcc_3.cdcooper
                 ,rw_crapdcc_3.nrdconta
                 ,rw_crapdcc_3.nrconven
                 ,2 -- Retorno
                 ,vr_nrremret
                 ,rw_crapdcc_3.nrseqarq
                 ,vr_cdtipmvt
                 ,rw_crapdcc_3.cdfinmvt
                 ,rw_crapdcc_3.cdentdad
                 ,rw_crapdcc_3.dsdocmc7 
                 ,rw_crapdcc_3.cdcmpchq 
                 ,rw_crapdcc_3.cdbanchq 
                 ,rw_crapdcc_3.cdagechq 
                 ,rw_crapdcc_3.nrctachq 
                 ,rw_crapdcc_3.nrcheque 
                 ,rw_crapdcc_3.vlcheque 
                 ,rw_crapdcc_3.cdtipemi 
                 ,rw_crapdcc_3.nrinsemi 
                 ,rw_crapdcc_3.dtdcaptu 
                 ,rw_crapdcc_3.dtlibera 
                 ,vr_dtcredit 
                 ,rw_crapdcc_3.dsusoemp 
                 ,rw_crapdcc_3.cdagedev 
                 ,rw_crapdcc_3.nrctadev 
                 ,rw_crapdcc_3.cdalinea 
                 ,NVL(vr_cdocorre,' ') 
                 ,rw_crapdcc_3.inconcil 
                 ,rw_crapdcc_3.cdagenci 
                 ,rw_crapdcc_3.cdbccxlt 
                 ,rw_crapdcc_3.nrdolote
                 ,rw_crapdcc_3.inchqcop);
             EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir CRAPDCC(CUST0001.pc_custodiar_cheques): '||SQLERRM;
               --Levantar Excecao
               RAISE vr_exc_erro;
             END;
           END IF;
           
           IF vr_cdocorre = '82' THEN
             
             -- Atualiza Ocorrencia no Registro de Remessa (REM)
             UPDATE crapdcc
             SET crapdcc.cdocorre = NVL(vr_cdocorre,' ')
             WHERE crapdcc.cdcooper = pr_cdcooper
               AND crapdcc.nrdconta = pr_nrdconta
               AND crapdcc.nrconven = pr_nrconven
               AND crapdcc.intipmvt = rw_crapdcc_3.intipmvt
               AND crapdcc.nrremret = rw_crapdcc_3.nrremret
               AND crapdcc.nrseqarq = rw_crapdcc_3.nrseqarq;
               
           END IF;    
               
                 
         END LOOP rw_crapdcc_3;
         
         -- Registrar Log;
         CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nmarquiv => 'REMRET: ' || TRIM(to_char(pr_nrremret))
                                      ,pr_textolog => 'Cheques Custodiados. ' ||
                                                      'Confirmados: ' || to_char(vr_qtdconfi) ||
                                                      ' Rejeitados: ' || to_char(vr_qtdrejei)
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic);
         
         -- Verifica Qual a Origem
         CASE pr_idorigem 
           WHEN 1 THEN vr_dsorigem := 'AYLLOS';
           WHEN 3 THEN vr_dsorigem := 'INTERNET';
           WHEN 7 THEN vr_dsorigem := 'FTP';
           ELSE vr_dsorigem := ' ';
         END CASE;

         -- Atualiza Registro craphcc como processado
         BEGIN
           UPDATE craphcc
             SET insithcc = 2           -- Processado/Custodiado
                ,dtcustod = pr_dtmvtolt -- Data Quando Cheques Foram Custodiados 
                ,cdoperad = pr_cdoperad -- Operador que Custodiou os Cheques
             WHERE craphcc.cdcooper = pr_cdcooper
               AND craphcc.nrdconta = pr_nrdconta
               AND craphcc.nrremret = pr_nrremret
               AND craphcc.intipmvt = pr_intipmvt -- 1 - Remessa / 3 - Manual
           RETURNING intipmvt INTO vr_intipmvt;
               
           IF SQL%ROWCOUNT = 0 THEN
             RAISE vr_erro_update;
           END IF;    
               
         EXCEPTION
           WHEN vr_erro_update THEN
             -- Registrar Log;
             CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nmarquiv => 'REM/RET: ' || to_char(pr_nrremret)
                                          ,pr_textolog => 'Erro ao atualizar CRAPHCC. '
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar CRAPHCC: ' || SQLERRM;
             RAISE vr_exc_erro;                        
             
           WHEN no_data_found THEN
             -- Registrar Log;
             CUST0001.pc_logar_cst_arquivo(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nmarquiv => 'REM/RET: ' || to_char(pr_nrremret)
                                          ,pr_textolog => 'Erro ao atualizar CRAPHCC. '
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar CRAPHCC: ' || SQLERRM;
             RAISE vr_exc_erro;
             
         END;
         
         -- Gerar o arquivo de retorno apenas quando o tipo de movimento for 1 (Remessa)
         IF vr_intipmvt = 1 THEN
           -- Gerar Arquivo de Retorno (.RET)
           CUST0001.pc_gerar_arquivo_retorno(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_nrconven => pr_nrconven
                                            ,pr_nrremret => vr_nrremret
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_idorigem => pr_idorigem
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nmarquiv => vr_nmarquiv
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);

           -- Se ocorreu erro na geracao do arquivo de retorno para a custodia
           IF NVL(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
           END IF;

         END IF;
         
         -- Gerar log ao cooperado (b1wgen0014 - gera_log)
         GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_dscritic => ' '
                             ,pr_dsorigem => vr_dsorigem
                             ,pr_dstransa => 'Cheques custodiados. ' ||
                                             'Remessa: '      || to_char(pr_nrremret) ||                     
                                             ' Confirmados: ' || to_char(vr_qtdconfi) ||
                                             ' Rejeitados:  ' || to_char(vr_qtdrejei)
                             ,pr_dttransa => pr_dtmvtolt
                             ,pr_flgtrans => 0 -- TRUE
                             ,pr_hrtransa => to_number(to_char(SYSDATE,'SSSSS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => ' '
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrdrowid => vr_nrdrowid);
       
       -- Salva Alterações                      
       COMMIT;                      			 
                             
     EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic := NVL(vr_cdcritic,0) ;
         pr_dscritic := vr_dscritic;
         ROLLBACK;
       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao Custodiar Cheque(pc_custodiar_cheques): ' || SQLERRM;
         ROLLBACK;
       END;
       
    END pc_custodiar_cheques;  
    
    
    PROCEDURE pc_logar_cst_arquivo(pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                  ,pr_nmarquiv      IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_textolog      IN VARCHAR2               -- Texto a ser Incluso Log
                                  ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                  ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro 
   
    BEGIN
    
    DECLARE
      
      -- Variaveis Log
      vr_nmarqlog   VARCHAR2(100);

      vr_nmdirlog   VARCHAR2(4000);
      vr_input_file utl_file.file_type;
      vr_datdodia   DATE;    
      
      -- Descrição do Erro
      vr_des_erro VARCHAR2(4000);
      
      vr_exc_erro EXCEPTION;  
      
      vr_setlinha VARCHAR2(4000);                     
        
      BEGIN
        
        -- Nome do Arquivo de Log
        vr_nmarqlog := 'cst_por_arquivo.log';
        
        --Buscar diretorio padrao cooperativa
        vr_nmdirlog := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => '/log') || '/' ; --> Ir para diretorio log
                                           
        --Abrir arquivo modo append
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirlog    --> Diretorio do arquivo
                                ,pr_nmarquiv => vr_nmarqlog    --> Nome do arquivo
                                ,pr_tipabert => 'A'            --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                ,pr_des_erro => vr_des_erro);  --> Erro
                                
        IF vr_des_erro IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Buscar data do dia
        vr_datdodia:= PAGA0001.fn_busca_datdodia (pr_cdcooper => pr_cdcooper);
        
        -- Montar linha que sera gravada no log
        -- <data/hora> <conta> <arquivo> - Arquivo de Retorno Gerado com Sucesso
        vr_setlinha:= to_char(vr_datdodia,'DD/MM/YYYY')       || ' '||
                      to_char(SYSDATE,'HH24:MI:SS')           || ' --> '||
                      GENE0002.fn_mask_conta(pr_nrdconta)     || ' | ';
        IF TRIM(pr_nmarquiv) IS NOT NULL THEN               
          vr_setlinha:= vr_setlinha || pr_nmarquiv            || ' | ';
        END IF;              
          vr_setlinha:= vr_setlinha || pr_textolog;
        
        --Escrever linha log
        gene0001.pc_escr_linha_arquivo(vr_input_file,vr_setlinha);
        
        -- Fechar Arquivo
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
                
      EXCEPTION
        WHEN vr_exc_erro THEN
          -- Retorna Erro
          pr_cdcritic := 0;
          pr_dscritic := vr_des_erro;          
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro na Rotina CUST0001.pc_logar_cst_arquivo. Erro: ' || SQLERRM;
      END;
        
    END pc_logar_cst_arquivo;   
    
    
    PROCEDURE pc_gerar_arquivo_log(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                  ,pr_nmarquiv  IN VARCHAR2               -- Nome do Arquivo
                                  ,pr_descerro  IN VARCHAR2               -- Descrição do Erro
                                  ,pr_cdcritic OUT INTEGER                -- Código do erro
                                  ,pr_dscritic OUT VARCHAR2) IS           -- Descricao do erro                        
    
    BEGIN
      
    DECLARE
    
      -- Nome do Arquivo
      vr_nmarquiv  VARCHAR2(100);
      
      vr_setlinha VARCHAR2(400);
       
      vr_utlfileh VARCHAR2(4000);
       
      -- Declarando Handle do Arquivo
      vr_ind_arquivo utl_file.file_type;
      vr_exc_saida  EXCEPTION;
      vr_exc_erro   EXCEPTION;
      
    BEGIN
        
      --Inicializar variaveis retorno
      pr_cdcritic:= 0;
      pr_dscritic:= NULL;
          
      -- Define nome do arquivo .LOG com base nome do Arquivo de Remessa
      vr_nmarquiv := REPLACE(UPPER(pr_nmarquiv),'.REM','.LOG');
      
      -- Define o diretório do arquivo
      vr_utlfileh := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/arq') ;
      
      -- Abre arquivo em modo de Escrita (W)
      GENE0001.pc_abre_arquivo(pr_nmdireto => vr_utlfileh         --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nmarquiv         --> Nome do arquivo
                              ,pr_tipabert => 'W'                 --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arquivo      --> Handle do arquivo aberto
                              ,pr_des_erro => vr_dscritic);       --> Erro  
                              
                                        
      IF vr_dscritic IS NOT NULL THEN
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      -- Linha do Erro Apresentado
      vr_setlinha:= to_char(SYSDATE,'DD/MM/RRRR')     || ' - ' ||
                    to_char(SYSDATE,'HH24:MI:SS')     || ' - ' ||
                    TRIM(pr_descerro)                 || CHR(13);
    
      -- Escrever Erro Apresentado no Arquivo
      GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_setlinha);
      
      -- Fechar o arquivo
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo); 
      
    EXCEPTION
      WHEN vr_exc_erro THEN  
        pr_cdcritic := 0; 
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0; 
        pr_dscritic := 'Erro CUST0001.pc_gerar_arquivo_log: ' || SQLERRM;
    END;
    
    END pc_gerar_arquivo_log;   
    
    PROCEDURE pc_ver_cheque(pr_cdcooper     IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                           ,pr_nrcustod     IN crapass.nrdconta%TYPE    -- Numero Conta do cooperado
                           ,pr_cdbanchq     IN crapcst.cdbanchq%TYPE    -- Banco do Cheque
                           ,pr_cdagechq     IN crapcst.cdagechq%TYPE    -- Agencia do Cheque
                           ,pr_nrctachq     IN crapcst.nrctachq%TYPE    -- Numero Conta do Cheque 
                           ,pr_nrcheque     IN crapcst.nrcheque%TYPE    -- Numero do Cheque
                           ,pr_nrddigc3     IN crapcst.nrddigc3%TYPE
                           ,pr_vlcheque     IN crapcst.vlcheque%TYPE    -- Valor do Cheque
                           ,pr_nrdconta    OUT crapass.nrdconta%TYPE    -- Conta do Cooperado
                           ,pr_dsdaviso    OUT VARCHAR2                 -- Mensagem de Aviso   
                           ,pr_cdcritic    OUT INTEGER                  -- Código do Erro
                           ,pr_dscritic    OUT VARCHAR2) IS             -- Descrição do Erro
    
    BEGIN

    DECLARE
      
      -- Busca Dados Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper,
			       crapcop.cdagebcb,
             crapcop.cdagectl,
             crapcop.cdbcoctl 
        FROM crapcop crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
			
			-- Cursor genérico de calendário			
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      
      -- Busca Dados Folha de Cheque      
      CURSOR cr_crapfdc(pr_cdcooper IN crapfdc.cdcooper%TYPE
                       ,pr_cdbanchq IN crapfdc.cdbanchq%TYPE
                       ,pr_cdagechq IN crapfdc.cdagechq%TYPE
                       ,pr_nrctachq IN crapfdc.nrctachq%TYPE
                       ,pr_nrcheque IN crapfdc.nrcheque%TYPE) IS
      SELECT crapfdc.nrdconta
            ,crapfdc.nrdctabb
            ,crapfdc.dtemschq      
            ,crapfdc.dtretchq
            ,crapfdc.incheque
            ,crapfdc.cdbantic 
            ,crapfdc.cdagetic 
            ,crapfdc.nrctatic
            ,crapfdc.vlcheque
						,crapfdc.dtlibtic
        FROM crapfdc
       WHERE crapfdc.cdcooper = pr_cdcooper 
         AND crapfdc.cdbanchq = pr_cdbanchq 
         AND crapfdc.cdagechq = pr_cdagechq 
         AND crapfdc.nrctachq = pr_nrctachq 
         AND crapfdc.nrcheque = pr_nrcheque;
      rw_crapfdc cr_crapfdc%ROWTYPE;
          
      -- Verificar Conta Migrada
      CURSOR cr_craptco(pr_cdcopant IN crapcop.cdcooper%TYPE
                       ,pr_nrctaant IN crapcst.nrctachq%TYPE) IS
      SELECT craptco.cdcopant
        FROM craptco
       WHERE craptco.cdcopant = pr_cdcopant
         AND craptco.nrctaant = to_number(pr_nrctaant)
         AND craptco.flgativo = 1 --> TRUE
         AND craptco.tpctatrf = 1;
      rw_craptco cr_craptco%ROWTYPE;
      
      -- Verificar Conta Migrada a partir de agectl
      CURSOR cr_craptco_chq(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_cdagectl IN crapcop.cdagectl%TYPE
                           ,pr_nrctaant IN crapcst.nrctachq%TYPE) IS
      SELECT tco.nrdconta
        FROM crapcop cop, craptco tco
       WHERE cop.cdagectl = pr_cdagectl
         AND tco.cdcooper = pr_cdcooper
         AND tco.cdcopant = cop.cdcooper
         AND tco.nrctaant = to_number(pr_nrctaant)
         AND tco.flgativo = 1 --> TRUE
         AND tco.tpctatrf = 1;
      rw_craptco_chq cr_craptco_chq%ROWTYPE;
      
           
      vr_nrdconta crapass.nrdconta%TYPE;
			vr_nrctaass crapass.nrdconta%TYPE;
      vr_nrdctitg crapass.nrdctitg%TYPE;
      vr_nrdocmto NUMBER;
           
      vr_dscalcul VARCHAR2(4000);
      
      vr_stsnrcal NUMBER; -- 1 = TRUE  0 = FALSE
           
      vr_lsconta1 VARCHAR2(4000);
      vr_lsconta2 VARCHAR2(4000);
      vr_lsconta3 VARCHAR2(4000);			
           
      -- Variaveis para Tratamento erro
      vr_exc_saida EXCEPTION;
            
    BEGIN

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Fecha Cursor
      CLOSE cr_crapcop;   
			
			-- Leitura do calendario da cooperativa
			OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
			FETCH btch0001.cr_crapdat INTO rw_crapdat;
			-- Fechar o cursor
			CLOSE btch0001.cr_crapdat;

      vr_cdcritic := 0;
      vr_nrdconta := 0;
      vr_nrdocmto := to_number(to_char(pr_nrcheque) || to_char(pr_nrddigc3));
          
      -- Verificar a existencia de conta de integracao
      gene0005.pc_existe_conta_integracao(pr_cdcooper => pr_cdcooper
                                         ,pr_ctpsqitg => pr_nrctachq
                                         ,pr_nrdctitg => vr_nrdctitg
                                         ,pr_nrctaass => vr_nrctaass
                                         ,pr_des_erro => vr_dscritic);         
          
      IF (pr_cdbanchq = 1 AND pr_cdagechq = 3420) OR        
         -- Conta Integracao
         (TRIM(vr_nrdctitg) IS NOT NULL AND 
          TRIM(to_char(pr_cdagechq)) = '3420' ) THEN
               
        gene0005.pc_conta_itg_digito_x(pr_nrcalcul => to_number(pr_nrctachq)
                                      ,pr_dscalcul => vr_dscalcul
                                      ,pr_stsnrcal => vr_stsnrcal -- 1 - Verdadeiro  0 - Falso
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
                             
         IF vr_stsnrcal = 1 THEN                
           vr_cdcritic := 8; -- Digito Invalido
           RAISE vr_exc_saida;
         END IF;                    

         vr_lsconta1 := gene0005.fn_busca_conta_centralizadora (pr_cdcooper => pr_cdcooper
                                                               ,pr_tpregist => 1);
                                   
         vr_lsconta2 := gene0005.fn_busca_conta_centralizadora (pr_cdcooper => pr_cdcooper
                                                               ,pr_tpregist => 2);

         vr_lsconta3 := gene0005.fn_busca_conta_centralizadora (pr_cdcooper => pr_cdcooper
                                                               ,pr_tpregist => 3);  
                                   
         -- Se Conta Integracao
         IF (INSTR(vr_lsconta1, to_char(pr_nrctachq)) > 0) OR             
            (TRIM(vr_nrdctitg) IS NOT NULL AND
             TRIM(to_char(pr_cdagechq)) = '3420' ) THEN 

           OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper,
                           pr_cdbanchq => pr_cdbanchq,
                           pr_cdagechq => pr_cdagechq,
                           pr_nrctachq => pr_nrctachq,
                           pr_nrcheque => pr_nrcheque);
           FETCH cr_crapfdc 
             INTO rw_crapfdc;                                                                
                 
           IF cr_crapfdc%NOTFOUND  THEN             
             vr_cdcritic := 108; -- Talonario não Emitido.
             CLOSE cr_crapfdc;
             RAISE vr_exc_saida;
           END IF;
           
           CLOSE cr_crapfdc;

           vr_nrdconta := rw_crapfdc.nrdconta;
                                 
           IF rw_crapfdc.dtemschq IS NULL THEN
             vr_cdcritic := 108; -- Talonario não Emitido.
             RAISE vr_exc_saida;
           END IF;

           IF rw_crapfdc.dtretchq IS NULL THEN
             vr_cdcritic := 109; -- Talonario não Retirado.
             RAISE vr_exc_saida;
           END IF;
                            
           IF NVL(rw_crapfdc.incheque,0) <> 0 THEN
                    
             IF rw_crapfdc.incheque = 1 THEN
               vr_cdcritic := 96; -- Cheque com Contra-Ordem.
               RAISE vr_exc_saida;
                        
             ELSIF rw_crapfdc.incheque = 2 THEN
               CUST0001.pc_contra_ordem(pr_cdcooper => pr_cdcooper
                                       ,pr_cdbanchq => pr_cdbanchq
                                       ,pr_cdagechq => pr_cdagechq
                                       ,pr_nrctachq => pr_nrctachq
                                       ,pr_nrcheque => vr_nrdocmto
                                       ,pr_incheque => rw_crapfdc.incheque
                                       ,pr_dsdaviso => pr_dsdaviso
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                                             
             ELSIF rw_crapfdc.incheque = 5 THEN
               vr_cdcritic := 97; -- Cheque já Compensado
               RAISE vr_exc_saida;
             ELSIF rw_crapfdc.incheque = 8 THEN
               vr_cdcritic := 320; -- Cheque Cancelado
               RAISE vr_exc_saida;                          
             ELSE
               -- 1000 - Tratamento era utilizado no Progress
               vr_cdcritic := 1000;
               RAISE vr_exc_saida;                                    
             END IF;
                       
           END IF;
         
         ELSIF (INSTR(vr_lsconta2,to_char(pr_nrctachq)) > 0)  THEN
         
           -- 646 - Cheque de transferencia.
           vr_cdcritic := 646; -- Cheque TB
           RAISE vr_exc_saida;
           
         ELSIF (INSTR(vr_lsconta3,to_char(pr_nrctachq)) > 0) THEN

           OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper,
                           pr_cdbanchq => pr_cdbanchq,
                           pr_cdagechq => pr_cdagechq,
                           pr_nrctachq => pr_nrctachq,
                           pr_nrcheque => pr_nrcheque);
           FETCH cr_crapfdc 
             INTO rw_crapfdc;           

           IF cr_crapfdc%NOTFOUND THEN
             vr_cdcritic := 286; -- Cheque Salario não Existe.
             CLOSE cr_crapfdc;
             RAISE vr_exc_saida;
           END IF;
           
           CLOSE cr_crapfdc;

           IF rw_crapfdc.vlcheque = pr_vlcheque THEN
             
             vr_nrdconta := rw_crapfdc.nrdconta;
                                            
             IF rw_crapfdc.incheque <> 0 THEN

               IF rw_crapfdc.incheque = 1 THEN
                 vr_cdcritic := 96; -- Cheque com Contra-Ordem.               
               ELSIF rw_crapfdc.incheque = 2 THEN
               
                 pc_contra_ordem(pr_cdcooper => pr_cdcooper
                                ,pr_cdbanchq => pr_cdbanchq
                                ,pr_cdagechq => pr_cdagechq
                                ,pr_nrctachq => pr_nrctachq
                                ,pr_nrcheque => pr_nrcheque
                                ,pr_incheque => rw_crapfdc.incheque
                                ,pr_dsdaviso => pr_dsdaviso
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                       
               ELSIF rw_crapfdc.incheque = 5 THEN
                 vr_cdcritic := 97; -- Cheque já Compensado
               ELSIF  rw_crapfdc.incheque = 8 THEN
                 vr_cdcritic := 320; -- Cheque Cancelado
               ELSE
                 -- 1000 - Tratamento era utilizado no Progress
                 vr_cdcritic := 1000;
               END IF;
                                          
               RAISE vr_exc_saida;
               
             END IF;
             
           ELSE
             pr_cdcritic := 91; -- Valor do Lançamento Errado
             RAISE vr_exc_saida;             
           END IF;       
           
         ELSE
           RETURN; -- Qualquer outra conta da agencia 95/3420
         END IF;
                        
         CUST0001.pc_ver_associado(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_nrdconta
                                  ,pr_dsdaviso => pr_dsdaviso
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
                 
         IF NVL(vr_cdcritic,0) > 0 THEN
           RAISE vr_exc_saida;
         END IF;
        
       ELSIF (pr_cdbanchq = 756 AND  pr_cdagechq = rw_crapcop.cdagebcb) OR
             (pr_cdbanchq = rw_crapcop.cdbcoctl AND pr_cdagechq = rw_crapcop.cdagectl) THEN

         -- Verifica Conta Migrada
         IF pr_cdcooper = 1 OR
            pr_cdcooper = 2 THEN
                        
           OPEN cr_craptco(pr_cdcopant => pr_cdcooper,
                           pr_nrctaant => pr_nrctachq);
           FETCH cr_craptco INTO rw_craptco;            

           IF cr_craptco%FOUND THEN
             vr_nrdconta := 0;
           ELSE
             vr_nrdconta := to_number(pr_nrctachq);
           END IF;
           
           -- Fecha Cursor
           CLOSE cr_craptco;

         ELSE
           vr_nrdconta := to_number(pr_nrctachq);
         END IF;
                  
         -- Se valor > 0 então é conta de cooperado e deve
         -- buscar informações do cooperado 
         IF vr_nrdconta > 0 THEN
      
           pc_ver_associado(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrctachq
                           ,pr_dsdaviso => pr_dsdaviso
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                        
           IF NVL(vr_cdcritic,0) > 0   THEN
             RAISE vr_exc_saida;
           END IF;
            
         END IF;
              
         gene0005.pc_conta_itg_digito_x((CASE WHEN vr_nrdconta > 0 THEN 
                                           vr_nrdconta 
                                         ELSE 
                                           pr_nrctachq 
                                         END),
                                         vr_dscalcul,
                                         vr_stsnrcal, -- 1 - True  0 - False
                                         vr_cdcritic, 
                                         vr_dscritic);         
         
         IF vr_stsnrcal = 0  THEN -- Falso        
           vr_cdcritic := 8; -- Digito Errado.
           RAISE vr_exc_saida;
         END IF;

         -- Verifica Folha de Cheque
         OPEN cr_crapfdc (pr_cdcooper => pr_cdcooper,
                          pr_cdbanchq => pr_cdbanchq,
                          pr_cdagechq => pr_cdagechq,
                          pr_nrctachq => pr_nrctachq,
                          pr_nrcheque => pr_nrcheque);
				 FETCH cr_crapfdc INTO rw_crapfdc;	
                   
         IF cr_crapfdc%NOTFOUND  THEN
					 CLOSE cr_crapfdc;		
           vr_cdcritic := 108; -- Talonario não Emitido.
           RAISE vr_exc_saida;
         END IF;
				 
				 CLOSE cr_crapfdc;		
                    
         IF rw_crapfdc.dtemschq IS NULL THEN
           vr_cdcritic := 108; -- Talonario não Emitido.
           RAISE vr_exc_saida;
         END IF;

         IF (rw_crapfdc.cdbantic <> 0                   OR 
             rw_crapfdc.cdagetic <> 0                   OR
             rw_crapfdc.nrctatic <> 0)                  AND
						(rw_crapfdc.dtlibtic >= rw_crapdat.dtmvtolt OR
             rw_crapfdc.dtlibtic IS NULL)               THEN
            vr_cdcritic := 950; -- Cheque Custodiado/Descontado em outra IF.
            RAISE vr_exc_saida;       
         END IF;

         IF rw_crapfdc.dtretchq IS NULL THEN                  
           vr_cdcritic := 109; -- Talonario não Retirado.
           RAISE vr_exc_saida;
         END IF;
                         
         IF rw_crapfdc.incheque <> 0 THEN
         
           IF rw_crapfdc.incheque = 1 THEN
             vr_cdcritic := 96; -- Cheque com Contra-Ordem.
           ELSIF  rw_crapfdc.incheque = 2 THEN
             CUST0001.pc_contra_ordem(pr_cdcooper => pr_cdcooper
                                     ,pr_cdbanchq => pr_cdbanchq
                                     ,pr_cdagechq => pr_cdagechq
                                     ,pr_nrctachq => pr_nrctachq
                                     ,pr_nrcheque => vr_nrdocmto
                                     ,pr_incheque => rw_crapfdc.incheque
                                     ,pr_dsdaviso => pr_dsdaviso
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                     
           ELSIF rw_crapfdc.incheque = 5 THEN
             vr_cdcritic := 97; -- Cheque já Compensado
           ELSIF rw_crapfdc.incheque = 8 THEN
             vr_cdcritic := 320; -- Cheque Cancelado
           ELSE
             -- 1000 - Tratamento era utilizado no Progress
             vr_cdcritic := 1000;
           END IF;          
          
           RAISE vr_exc_saida;
          
         END IF;
            
       ELSIF pr_cdbanchq = rw_crapcop.cdbcoctl  AND
            ((pr_cdagechq = 101  AND  pr_cdcooper = 16)  OR
             (pr_cdagechq = 102  AND  pr_cdcooper = 1)   OR
			 (pr_cdagechq = 116  AND  pr_cdcooper = 9 AND ( SYSDATE > to_date('30/12/2016','DD/MM/YYYY') )   OR
             (pr_cdagechq = 103  AND  pr_cdcooper = 1)   OR    /* Incorporacao Concredi */
             (pr_cdagechq = 114  AND  pr_cdcooper = 13)) THEN  /* Incorporacao Credimilsul */
       
         -- Tratamento para as contas migradas
         OPEN cr_craptco_chq (pr_cdcooper => pr_cdcooper
                             ,pr_cdagectl => pr_cdagechq
                             ,pr_nrctaant => to_number(pr_nrctachq));
         FETCH cr_craptco_chq 
          INTO rw_craptco_chq;

         IF cr_craptco_chq%FOUND THEN
            vr_nrdconta := to_number(rw_craptco_chq.nrdconta);
         ELSE
           vr_nrdconta := 0;
         END IF;
         
         CLOSE cr_craptco_chq;
                   
         IF vr_nrdconta > 0 THEN 
             
           pc_ver_associado(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => vr_nrdconta
                           ,pr_dsdaviso => pr_dsdaviso
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic);
                        
           IF NVL(vr_cdcritic,0) > 0   THEN
             RAISE vr_exc_saida;
           END IF;
           
         END IF;
                            
         gene0005.pc_conta_itg_digito_x (CASE WHEN vr_nrdconta > 0 THEN 
                                           vr_nrdconta 
                                         ELSE 
                                           pr_nrctachq 
                                         END,
                                           vr_dscalcul,
                                           vr_stsnrcal, -- 1 - True 0 - False
                                           vr_cdcritic,
                                           vr_dscritic);         
       
         IF  vr_stsnrcal = 0  THEN     
             vr_cdcritic := 8; -- Digito Invalido
             RAISE vr_exc_saida;       
         END IF;
         
         IF (pr_cdcooper = 1 AND pr_cdagechq = 102)  OR    /* migracao */
            pr_cdcooper = 16 THEN
             OPEN cr_crapfdc(pr_cdcooper => rw_craptco.cdcopant,
                             pr_cdbanchq => pr_cdbanchq,
                             pr_cdagechq => pr_cdagechq,
                             pr_nrctachq => pr_nrctachq,
                             pr_nrcheque => pr_nrcheque);
             FETCH cr_crapfdc 
              INTO rw_crapfdc;                                                                
         ELSIF (pr_cdcooper = 1  AND pr_cdagechq = 103) OR  /* incorporacao */              
               (pr_cdcooper = 9  AND pr_cdagechq = 116 AND ( SYSDATE > to_date('30/12/2016','DD/MM/YYYY') ) OR
			   (pr_cdcooper = 13 AND pr_cdagechq = 114) THEN

             OPEN cr_crapfdc(pr_cdcooper => pr_cdcooper,
                             pr_cdbanchq => pr_cdbanchq,
                             pr_cdagechq => pr_cdagechq,
                             pr_nrctachq => pr_nrctachq,
                             pr_nrcheque => pr_nrcheque);
             FETCH cr_crapfdc 
              INTO rw_crapfdc;
           
         END IF;
                   
         IF  cr_crapfdc%NOTFOUND  THEN
             vr_nrdconta := 0;
             CLOSE cr_crapfdc;
         ELSE
             CLOSE cr_crapfdc;    

             IF rw_crapfdc.dtemschq IS NULL   THEN                 
               vr_cdcritic := 108; -- Talonario não Emitido.
               RAISE vr_exc_saida;
             END IF;

             IF (rw_crapfdc.cdbantic <> 0                   OR 
                 rw_crapfdc.cdagetic <> 0                   OR
                 rw_crapfdc.nrctatic <> 0)                  AND 
                (rw_crapfdc.dtlibtic >= rw_crapdat.dtmvtolt OR
                 rw_crapfdc.dtlibtic IS NULL)               THEN						 
                 vr_cdcritic := 950; -- Cheque Custodiado/Descontado em outra IF.
                 RAISE vr_exc_saida;
             END IF;

             IF rw_crapfdc.dtretchq IS NULL THEN
               vr_cdcritic := 109; -- Talonario não Retirado.
               RAISE vr_exc_saida;
             END IF;
                         
             IF rw_crapfdc.incheque <> 0 THEN

               IF  rw_crapfdc.incheque = 1   OR
                   rw_crapfdc.incheque = 2   THEN
                 vr_cdcritic := 96; -- Cheque com Contra-Ordem.
               ELSIF  rw_crapfdc.incheque = 5   THEN
                 vr_cdcritic := 97; -- Cheque já Compensado
               ELSIF  rw_crapfdc.incheque = 8   THEN
                 vr_cdcritic := 320; -- Cheque Cancelado
               ELSE
                 -- 1000 - Tratamento era utilizado no Progress
                 vr_cdcritic := 1000;
               END IF;                
               
               RAISE vr_exc_saida;
             END IF;               
                 
         END IF;
          
        END IF;
              
        -- Não Permitir Cheque do Proprio Custodiante     
        IF pr_nrcustod = vr_nrdconta  THEN
          vr_cdcritic := 121; -- Cheque do Custodiante
          RAISE vr_exc_saida;
        END IF;
        
        pr_nrdconta := vr_nrdconta;
        
    EXCEPTION
      WHEN vr_exc_saida THEN      
        -- Arquivo possui erros criticos, aborta processo de validação    
        -- Efetuar retorno do erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    WHEN OTHERS THEN
      -- Apenas retornar a variável de saida
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na Rotina CUST0001.pc_ver_cheque. Erro: ' || SQLERRM;        
    END;    

  END pc_ver_cheque;

  PROCEDURE pc_contra_ordem(pr_cdcooper     IN crapcop.cdcooper%TYPE
                           ,pr_cdbanchq     IN crapcst.cdbanchq%TYPE
                           ,pr_cdagechq     IN crapcst.cdagechq%TYPE
                           ,pr_nrctachq     IN crapcst.nrctachq%TYPE
                           ,pr_nrcheque     IN crapcst.nrcheque%TYPE
                           ,pr_incheque     IN crapfdc.incheque%TYPE 
                           ,pr_dsdaviso     OUT VARCHAR2
                           ,pr_cdcritic     OUT INTEGER               -- Código do erro
                           ,pr_dscritic     OUT VARCHAR2) IS          -- Descricao do erro
                  
  BEGIN
    
  DECLARE
        
    CURSOR cr_crapcor (pr_cdcooper in crapcor.cdcooper%TYPE
                      ,pr_cdbanchq in crapcor.cdbanchq%TYPE
                      ,pr_cdagechq in crapcor.cdagechq%TYPE
                      ,pr_nrctachq in crapcor.nrctachq%TYPE
                      ,pr_nrcheque in crapcor.nrcheque%TYPE) IS
    SELECT crapcor.dtemscor
          ,crapcor.cdhistor
      FROM crapcor crapcor
     WHERE crapcor.cdcooper = pr_cdcooper
       AND crapcor.cdbanchq = pr_cdbanchq
       AND crapcor.cdagechq = pr_cdagechq
       AND crapcor.nrctachq = pr_nrctachq
       AND crapcor.nrcheque = pr_nrcheque
       AND crapcor.flgativo = 1;
    rw_crapcor cr_crapcor%ROWTYPE;
    
    CURSOR cr_craphis (pr_cdcooper in craphis.cdcooper%TYPE
                      ,pr_cdhistor in craphis.cdhistor%TYPE) IS
      SELECT craphis.dshistor
        FROM craphis 
       WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdhistor = pr_cdhistor;
    rw_craphis cr_craphis%ROWTYPE;              
    
    -- Variaveis para Tratamento erro
    vr_exc_saida EXCEPTION;
    vr_exc_erro  EXCEPTION;    
    
  BEGIN
    
    IF pr_incheque = 1 OR
       pr_incheque = 2 THEN
     
      OPEN cr_crapcor(pr_cdcooper => pr_cdcooper,
                      pr_cdbanchq => pr_cdbanchq,
                      pr_cdagechq => pr_cdagechq,
                      pr_nrctachq => pr_nrctachq,
                      pr_nrcheque => pr_nrcheque);
      FETCH cr_crapcor
       INTO rw_crapcor;
                  
      IF cr_crapcor%NOTFOUND THEN
        -- 101 - Contra ordem de aviso inexistente (Lanc. nao foi aceito).
        vr_cdcritic := 101;
        CLOSE cr_crapcor;
        RAISE vr_exc_saida;
      END IF;
       
      CLOSE cr_crapcor;
                  
      OPEN cr_craphis (pr_cdcooper => pr_cdcooper,
                       pr_cdhistor => rw_crapcor.cdhistor);                  
      FETCH cr_craphis 
       INTO rw_craphis;
       
      IF  cr_craphis%NOTFOUND THEN
        vr_dscritic := lpad(' ',50,'*');
      ELSE 
        vr_dscritic := rw_craphis.dshistor;
      END IF;  
       
      CLOSE cr_craphis;         
         
      pr_dsdaviso := 'Aviso de ' || to_char(rw_crapcor.dtemscor,'DD/MM/RRRR') || ' -> ' || vr_dscritic;
      pr_dscritic := vr_dscritic;
     
    END IF;
     
  EXCEPTION
    
    WHEN vr_exc_saida THEN      
      -- Arquivo possui erros criticos, aborta processo de validação    
      -- Efetuar retorno do erro
      pr_cdcritic := NVL(vr_cdcritic,0);
    WHEN OTHERS THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := 0;     
        vr_dscritic := 'Erro CUST0001.pc_contra_ordem: '||SQLERRM;   
  END;    
     

  END pc_contra_ordem;


  PROCEDURE pc_ver_associado(pr_cdcooper      IN crapcop.cdcooper%TYPE -- Código da cooperativa
                            ,pr_nrdconta      IN crapass.nrdconta%TYPE -- Numero Conta do cooperado
                            ,pr_dsdaviso     OUT VARCHAR2              -- Mensagem de Aviso   
                            ,pr_cdcritic     OUT INTEGER               -- Código do erro
                            ,pr_dscritic     OUT VARCHAR2) IS          -- Descricao do erro
  BEGIN

  DECLARE 

    -- Busca Dados Associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta,
           crapass.cdsitdtl,
           crapass.dtelimin
      FROM crapass crapass
     WHERE crapass.cdcooper = pr_cdcooper 
       AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Busca Dados
    CURSOR cr_craptrf(pr_cdcooper in craptrf.cdcooper%TYPE,
                      pr_nrdconta in craptrf.nrdconta%TYPE) IS
      SELECT craptrf.nrsconta, craptrf.nrdconta
        FROM craptrf
       WHERE craptrf.cdcooper = pr_cdcooper
         AND craptrf.nrdconta = pr_nrdconta
         AND craptrf.tptransa = 1;
    rw_craptrf cr_craptrf%ROWTYPE;          
    
    -- Numero da Conta       
    vr_nrdconta crapass.nrdconta%TYPE;    

  BEGIN  

    vr_nrdconta := pr_nrdconta;
      
    WHILE TRUE LOOP
    
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => vr_nrdconta );
      FETCH cr_crapass
       INTO rw_crapass;

      IF cr_crapass%NOTFOUND  THEN       
        vr_cdcritic := 9; -- Associado Não Cadastrado
        CLOSE cr_crapass;
        EXIT;    
      END IF;
      
      CLOSE cr_crapass;

      IF to_char(rw_crapass.cdsitdtl) IN ('5','6','7','8')  THEN
        vr_cdcritic := 695; -- ATENCAO! Houve prejuizo nessa conta       
        EXIT;
      END IF;

      IF to_char(rw_crapass.cdsitdtl) IN ('2','4') THEN

        OPEN cr_craptrf(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => vr_nrdconta );
                  
        FETCH cr_craptrf INTO rw_craptrf;

        IF cr_craptrf%NOTFOUND THEN
          vr_cdcritic := 95; -- Titular da conta Bloqueado.
          CLOSE cr_craptrf;
          EXIT;       
        END IF;
         
        CLOSE cr_craptrf;
                
        vr_cdcritic := 156; -- Conta Transferida do Numero
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

        pr_dsdaviso := vr_dscritic || to_char(rw_craptrf.nrdconta,'zzzz,zzz,9')
                                   || ' para o número ' 
                                   || to_char(rw_craptrf.nrsconta,'zzzz,zzz,9');

         vr_nrdconta := rw_craptrf.nrsconta;
         pr_cdcritic := 0;
       
         CONTINUE;
       
      END IF;       

      IF rw_crapass.dtelimin IS NOT NULL THEN       
        vr_cdcritic := 410; -- Associado Excluido
        EXIT;
      END IF;      
      
      EXIT;

    END LOOP;  -- Fim do DO WHILE LOOP
    
    IF NVL(vr_cdcritic,0) > 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END IF;  
  
  END;

  END pc_ver_associado;    
  
  PROCEDURE pc_custodia_cheque_manual(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                     ,pr_dscheque  IN VARCHAR2              --> Codigo do Indexador 
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  BEGIN
    /* .............................................................................
    Programa: pc_custodia_cheque_manual
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 12/05/2015                        Ultima atualizacao: 11/01/2016

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para cadastrar os cheques para a custódia

    Alteracoes: 09/07/2015 - Ajustar a identificação da conta do cheque quando desmontar o CMC-7
                             pois para o banco do brasil são 8 posições e os demais são 10
                             (Douglas - Chamado 306393)
                             
                04/01/2016 - Ajuste na leitura da tabela crapocc para utilizar UPPER nos campos VARCHAR
                             pois será incluido o UPPER no indice desta tabela - SD 375854
                             (Adriano).    
                             
                11/01/2016 - Ajuste na leitura da tabela crapocc para utilizar UPPER nos campos VARCHAR
                             pois será incluido o UPPER no indice desta tabela - SD 375854
                             (Adriano).    
                                                     
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      vr_erro_custodia VARCHAR2(4000);
  
      vr_cdtipmvt wt_custod_arq.cdtipmvt%TYPE;
      vr_cdocorre wt_custod_arq.cdocorre%TYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      vr_ret_all_cheques gene0002.typ_split;
      vr_ret_cheque      gene0002.typ_split;
      
      vr_auxcont  INTEGER := 0;
      vr_inchqcop NUMBER;
      
      -- Informações do Cheque
      vr_dtchqbom DATE;
      vr_vlcheque NUMBER(25,2);
      vr_dsdocmc7 crapdcc.dsdocmc7%TYPE;
      -- Campos do CMC7
      vr_dsdocmc7_formatado VARCHAR2(40);
      vr_cdbanchq NUMBER; 
      vr_cdagechq NUMBER;
      vr_cdcmpchq NUMBER;
      vr_nrctachq NUMBER;
      vr_nrcheque NUMBER;

      vr_nrremret craphcc.nrremret%TYPE;

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

      TYPE typ_reg_erro_custodia IS
        RECORD(dsdocmc7 crapdcc.dsdocmc7%TYPE
              ,dscritic VARCHAR2(4000));
      TYPE typ_erro_custodia IS
        TABLE OF typ_reg_erro_custodia
        INDEX BY BINARY_INTEGER;
      /* Vetor para armazenar as informac?es de erro */
      vr_tab_custodia_erro typ_erro_custodia;
      vr_index_erro INTEGER;
      vr_xml_erro_custodia VARCHAR2(32726);

      TYPE typ_reg_cheque_custodia IS
        RECORD(dsdocmc7 crapdcc.dsdocmc7%TYPE
              ,cdcmpchq crapdcc.cdcmpchq%TYPE
              ,cdbanchq crapdcc.cdbanchq%TYPE
              ,cdagechq crapdcc.cdagechq%TYPE
              ,nrctachq crapdcc.nrctachq%TYPE
              ,nrcheque crapdcc.nrcheque%TYPE
              ,vlcheque crapdcc.vlcheque%TYPE
              ,dtlibera crapdcc.dtlibera%TYPE
              ,inchqcop crapdcc.inchqcop%TYPE);
      TYPE typ_cheque_custodia IS
        TABLE OF typ_reg_cheque_custodia
        INDEX BY BINARY_INTEGER;
      /* Vetor para armazenar as informacoes dos cheques que estao sendo custodiados */
      vr_tab_cheque_custodia typ_cheque_custodia;
      vr_index_cheque INTEGER;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);


      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop( pr_cdcooper => vr_cdcooper);
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
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
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
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
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
      
      -- Criando um Array com todos os cheques que vieram como parametro
      vr_ret_all_cheques := gene0002.fn_quebra_string(pr_dscheque, '|');
      
      -- Percorre todos os cheques para processá-los
      FOR vr_auxcont IN 1..vr_ret_all_cheques.count LOOP
        -- Zerar as informações do Tipo de Movimentação e da Ocorrencia
        vr_cdtipmvt := NULL;
        vr_cdocorre := NULL;
        vr_erro_custodia := NULL;

        -- Criando um array com todas as informações do cheque
        vr_ret_cheque := gene0002.fn_quebra_string(vr_ret_all_cheques(vr_auxcont), ';');

        vr_dtchqbom := to_date(vr_ret_cheque(1),'dd/mm/RRRR');
        vr_vlcheque := to_number(vr_ret_cheque(2));
        vr_dsdocmc7 := vr_ret_cheque(3);
        
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
        
        -- Utiliza a validação padrão para saber a situação do cheque
        pc_validar_cheque(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_dsdocmc7 => vr_dsdocmc7_formatado
                         ,pr_cdbanchq => vr_cdbanchq
                         ,pr_cdagechq => vr_cdagechq
                         ,pr_cdcmpchq => vr_cdcmpchq
                         ,pr_nrctachq => vr_nrctachq
                         ,pr_nrcheque => vr_nrcheque
                         ,pr_dtlibera => vr_dtchqbom
                         ,pr_vlcheque => vr_vlcheque
                         ,pr_nrremret => 0 -- Não temos uma remessa criada ainda
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_intipmvt => 3 /* Manual */
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
          END IF;
        
          vr_index_erro := vr_tab_custodia_erro.count + 1;  
          vr_tab_custodia_erro(vr_index_erro).dsdocmc7 := vr_dsdocmc7;
          vr_tab_custodia_erro(vr_index_erro).dscritic := vr_erro_custodia;
        END IF;
        
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
        
      END LOOP;

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
      
      -- Se não possuir nenhuma crítica, insere os dados na craphcc e crapdcc
      -- Buscar o Último Lote de Retorno do Cooperado
      OPEN cr_craphcc(pr_cdcooper => vr_cdcooper
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
          (vr_cdcooper,
           pr_nrdconta,
           1, -- nrconven -> Fixo 1
           3, -- Manual
           vr_nrremret,
           rw_crapdat.dtmvtolt,
           ' ', -- nmarquiv -> Não possui nome de arquivo
           5,   -- idorigem -> Ayllos WEB
           rw_crapdat.dtmvtolt,
           to_char(SYSDATE,'HH24MISS'),
           1, -- insithcc -> Pendente
           vr_cdoperad);
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
             inchqcop)
          VALUES
            (vr_cdcooper,
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
             vr_tab_cheque_custodia(vr_index_cheque).inchqcop);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir CRAPDCC: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
      END LOOP; 
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := 0;
        pr_dscritic := '';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Validar_CMC7>' || vr_xml_erro_custodia || '</Validar_CMC7></Root>');
        ROLLBACK;
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_custodia_cheque_manual: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_custodia_cheque_manual;
  
  
  PROCEDURE pc_valida_conta_custodiar(pr_nrdconta  IN crapass.nrdconta%TYPE --> Codigo do Indexador
                                     ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo

  BEGIN
    /* .............................................................................
    Programa: pc_valida_conta_custodiar
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Douglas Quisinski
    Data    : 26/05/2015                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar se pode ser executada a custódia para a conta informada

    Alteracoes:
    ............................................................................. */
    DECLARE
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;

      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
  
      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- CURSORES
      --Selecionar os dados da tabela de Associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT 
          crapass.nrdconta,
          crapass.cdagenci,
          crapass.nrcpfcgc,
          crapass.inpessoa,
          crapass.nmprimtl,
          crapass.dtdemiss
         FROM crapass
        WHERE crapass.cdcooper = pr_cdcooper
          AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE; 

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapass( pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapass;
        -- Monta critica
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
      -- Apenas fechar o cursor
      CLOSE cr_crapass;
      
      IF rw_crapass.dtdemiss IS NOT NULL THEN
        -- Se estiver demitido não permite custodis
        vr_cdcritic := 75;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
      
      -- Retorna o nome do cooperado      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados><nmprimtl>' || rw_crapass.nmprimtl || '</nmprimtl></Dados></Root>');

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em pc_valida_conta_custodiar: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_valida_conta_custodiar;


  PROCEDURE pc_tarifa_resgate_cheq_custod(pr_cdcooper  IN crapcop.cdcooper%TYPE  -- Cooperativa
                                         ,pr_nrdconta  IN crapass.nrdconta%TYPE  -- Conta do cooperado
                                   	     ,pr_inpessoa  IN crapass.inpessoa%TYPE  -- Tipo de pessoa
                                         ,pr_nrcheque  IN crapcst.nrcheque%TYPE  -- Numero do Cheque
                                         ,pr_cdcritic OUT INTEGER                -- Codigo do erro
                                         ,pr_dscritic OUT VARCHAR2) IS           -- Descricao erro

  BEGIN
    /* .............................................................................
    Programa: pc_tarifa_resgate_cheq_custod
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jaison
    Data    : 18/08/2015                        Ultima atualizacao: 26/08/2015

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Automatizar lancamento de tarifa de resgate de cheque custodiado

    Alteracoes: 26/08/2015 - Inclusao do parametro pr_nrcheque e alterado o parametro
                             pr_cdpesqbb da procedure TARI0001.pc_cria_lan_auto_tarifa
                             (Jean Michel).
    ............................................................................. */
    DECLARE
      -- Cursor generico de calendario
      rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
      
      -- Variaveis de erro
      vr_exc_erro  EXCEPTION;
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      -- PLTABLE de erro generica
      vr_tab_erro GENE0001.typ_tab_erro;
  
      -- Variaveis
      vr_cdbattar VARCHAR2(100);
      vr_cdhistor INTEGER;
      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_rowid    ROWID;

    BEGIN
      -- Leitura do calendario da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;

      -- Codigo da tarifa
      IF pr_inpessoa = 1 THEN
        vr_cdbattar := 'RESGCUSTPF';
      ELSE
        vr_cdbattar := 'RESGCUSTPJ';
      END IF;

      -- Busca o valor da tarifa
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper   -- Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbattar   -- Codigo Tarifa
                                            ,pr_vllanmto  => 0             -- Valor Lancamento
                                            ,pr_cdprogra  => 'CUST0001'    -- Codigo Programa
                                            ,pr_cdhistor  => vr_cdhistor   -- Codigo Historico
                                            ,pr_cdhisest  => vr_cdhisest   -- Historico Estorno
                                            ,pr_vltarifa  => vr_vltarifa   -- Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg   -- Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc   -- Data Vigencia
                                            ,pr_cdfvlcop  => vr_cdfvlcop   -- Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                            ,pr_dscritic  => vr_dscritic   -- Descricao Critica
                                            ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Nao foi possivel carregar a tarifa.';
        END IF;
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Criar Lancamento automatico tarifa
      TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper      => pr_cdcooper
                                      ,pr_nrdconta      => pr_nrdconta
                                      ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                      ,pr_cdhistor      => vr_cdhistor
                                      ,pr_vllanaut      => vr_vltarifa
                                      ,pr_cdoperad      => '1'
                                      ,pr_cdagenci      => 1
                                      ,pr_cdbccxlt      => 100
                                      ,pr_nrdolote      => 10134
                                      ,pr_tpdolote      => 1
                                      ,pr_nrdocmto      => 0
                                      ,pr_nrdctabb      => pr_nrdconta
                                      ,pr_nrdctitg      => GENE0002.fn_mask(pr_nrdconta,'99999999')
                                      ,pr_cdpesqbb      => 'Fato gerador tarifa:' || TO_CHAR(pr_nrcheque)
                                      ,pr_cdbanchq      => 0
                                      ,pr_cdagechq      => 0
                                      ,pr_nrctachq      => 0
                                      ,pr_flgaviso      => FALSE
                                      ,pr_tpdaviso      => 0
                                      ,pr_cdfvlcop      => vr_cdfvlcop
                                      ,pr_inproces      => rw_crapdat.inproces
                                      ,pr_rowid_craplat => vr_rowid
                                      ,pr_tab_erro      => vr_tab_erro
                                      ,pr_cdcritic      => vr_cdcritic
                                      ,pr_dscritic      => vr_dscritic);
      -- Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        -- Se possui erro no vetor
        IF vr_tab_erro.Count > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_dscritic := 'Erro no lancamento tarifa de resgate de cheque custodiado.';
        END IF;
        -- Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Efetua o commit
      COMMIT;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic := NVL(vr_cdcritic,0) ;
         pr_dscritic := vr_dscritic; 
         ROLLBACK;
       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao resgatar cheque custodiado(pc_tarifa_resgate_cheq_custod): ' || SQLERRM;
         ROLLBACK;
    END;

  END pc_tarifa_resgate_cheq_custod;
  
  
END CUST0001;
/
