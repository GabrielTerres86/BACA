/* ..........................................................................

   Programa: Fontes/crps362.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Outubro/2003                        Ultima atualizacao: 10/10/2013

   Dados referentes ao programa:

   Frequencia: Diario. Paralelo.
   Objetivo  : Atende a solicitacao 88(Processa sempre dia anterior e nao roda
               no primeiro dia util do mes).
               Gerar cadastro de informacoes gerenciais(Diario). - p/agencia
               Ordem do programa na solicitacao 227.

   Alteracoes: 30/06/2005 - Alimentado campo cdcooper da tabela crapacc (Diego).
   
               29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapacc (Diego).
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                            
               03/03/2006 - Acerto em lancamentos (Diego).

               20/03/2006 - Ajustes para melhorar a performance (Edson).
               
               14/11/2006 - Otimizacao do programa e juncao do crps363
                            (Evandro).
                            
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                          - Contablizar desconto de titulos e juros do
                            desconto de titulos (Gabriel).
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               08/03/2010 - Alteracao Historico (Gati)               
               
               27/06/2011 - Consulta na crapltr desconsiderando alguns 
                            historicos, pois, os lancamentos referentes aos 
                            mesmos ja constam na craplcm. (Fabricio)
                            
               26/04/2012 - Limpar variavel glb_cdcritic apos uso (David).
               
               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas)
              
               10/10/2013 - Chamada Stored Procedure do Oracle
                            (Andre Euzebio / Supero)
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps362"
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

RUN STORED-PROCEDURE pc_crps362 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps362 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps362.pr_cdcritic WHEN pc_crps362.pr_cdcritic <> ?
       glb_dscritic = pc_crps362.pr_dscritic WHEN pc_crps362.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps362.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps362.pr_infimsol = 1 THEN
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

/* .......................................................................... */
