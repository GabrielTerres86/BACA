/* ............................................................................

   Programa: Fontes/crps315.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior.
   Data    : Julho/2001                         Ultima atualizacao: 12/09/2013

   Dados referentes ao programa:

   Frequencia : Diario.
   Objetivo   : Atende a solicitacao 002.
                Listar as contas que tiveram abertura de conta corrente ou
                recadastramento no dia.
                Emite relatorio 267.
               
   Alteracaoes: 20/02/2002 - Incluir novo relatorio por PAC q sera impresso
                             na IMPREL. (Ze Eduardo).
                             
                08/04/2002 - Fazer relatorios em paginas separadas para as 
                             pessoas juridicas (Junior).
                             
                22/05/2002 - Mostrar o operador da transacao no relatorio
                             (Junior).

                18/06/2002 - Corrigir a alteracao acima (Edson).

                23/07/2002 - Pular linha entre as contas (Deborah).

                05/08/2003 - So ira mandar para o relatorio os associados que 
                             nao estiverem como revisao cadastral. (Julio)

                28/02/2005 - Tratar o termo ADMISSAO DE SOCIO (Edson).
                
                04/10/2005 - Inclusao contas que tiveram impresso TERMO CI
                             (Mirtes)
                             
                05/10/2005 - Impressao contas que tiverem impresso TERMO CI   
                             independente de recadastramento(Mirtes)
                             
                14/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                
                28/06/2006 - Inclusao "SFN"(Mirtes)

                17/10/2006 - Inclusao do PAC do Operador nos relatorios (Elton)
                
                26/10/2006 - Ajustar leitura do crapneg para ser mais perfor-
                             matica (Edson).
                
                21/02/2007 - Listar contas que tiverem impressao Termo BANCOOB
                             (Diego).

                30/04/2008 - Incluida na rotina de verificacao de documentos
                             para arquivar a "Impressao do Contrato Poupanca
                             Programada (Gabriel).
                
                18/05/2009 - Mostrar relatorios crrl272_* na intranet
                             (Fernando).

                22/05/2009 - Alteracao CDOPERAD (Kbase).
                
                11/11/2009 - Ajuste para o novo Termo de Adesao - retirar o 
                             antigo Termo CI e Termo BANCCOB (Fernando). 
                             
                27/04/2010 - Desconsisderar a tabela temporaria das poupanças
                             (Gabriel).
                             
                15/07/2010 - Implementacao de listagem de contas que fizeram
                             impressao de carta na tela MANCCF (GATI - Eder)
                             
                02/08/2010 - Implementacoes na Listagem de contas que efetuaram
                             impressao de cartas - Emissao Cartas de CCF:
                             * Exibicao do Nome e PAC do Operador que efetuou 
                               a impressao de cartas (cdopeimp);
                             * Separacao por Tipo de Pessoa.
                           - Alteracao da listagem "Abertura/Recadastramento 
                             de Conta Corrente" para imprimir por Tipo de 
                             Pessoa
                           - Exclusao do nome e PAC do operador da listagem
                             de Emissao de Cartas CCF - mantido apenas dados
                             do operador que efetuou impressao
                           - Nao apresentar totais quando estiverem com valor 0
                           
                10/08/2012 - Inclusão do campo nrdocmto - Numero cheque para o
                             relatorio 267 Emissao Cartas de CCF. (Lucas R.)
                
                12/09/2013 - Conversao oracle, chamada da stored procedure
                            (Andre Euzebio / Supero).             
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps315"
       glb_flgbatch = FALSE
       glb_cdempres = 11
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps315 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps315 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps315.pr_cdcritic WHEN pc_crps315.pr_cdcritic <> ?
       glb_dscritic = pc_crps315.pr_dscritic WHEN pc_crps315.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps315.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps315.pr_infimsol = 1 THEN
                         TRUE
                      ELSE
                         FALSE.

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.


