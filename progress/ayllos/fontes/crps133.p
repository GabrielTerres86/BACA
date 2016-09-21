/* ..........................................................................

   Programa: Fontes/crps133.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/95                      Ultima atualizacao: 06/06/2013

   Dados referentes ao programa:

   Frequencia: Diario. Exclusivo.
   Objetivo  : Atende a solicitacao 5.
               Gerar cadastro de informacoes gerenciais.
               Ordem do programa na solicitacao 2.

   Alteracoes: 23/02/96 - Alterado para tratar campo crapacc.cdempres e
                          crapger.cdempres (Odair)

               02/04/96 - Alterado para tratar qtctrrpp, vlctrrpp, qtaplrpp,
                          vlaplrpp (Odair).

               03/05/96 - Alterado para desprezar as poupancas que ainda nao
                          tenham iniciado o desconto (Deborah).

               14/08/96 - Alterado para tratar qtassapl (Odair).

               11/09/96 - Alterado para desmembrar para 168 (Odair).

               06/01/97 - Acumular juros de emprestimos tpregist = 6 (Odair).
                
               10/09/98 - Tratar tipo de conta 7 (Deborah). 

               16/08/99 - Contar apenas qtd de associados com inmatric = 1
                          (Odair)

               02/07/2001 - Tratar contratos em prejuizo (Deborah).

               06/08/2001 - Tratar prejuizo de conta corrente (Margarete).

               21/10/2003 - Somente rodar se processo mensal(Mirtes).
               
               29/01/2004 - Contar apenas qtd de associados com saldo maior 
                            que saldo medio do mes (Junior).

               08/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)
               
               29/06/2005 - Alimentado campo cdcooper das tabelas crapacc
                            e crapger (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               20/01/2006 - Acerto na campo lancamentos e acresentada
                            leitura do campo cdcooper nas tabelas (Diego).
                            
               01/03/2006 - Acerto no programa - crapcbb (Ze).

               05/05/2006 - Acertos nos indices (Mirtes)
               
               08/11/2006 - Otimizacao do programa e juncao do crps143
                            (Evandro).
                            
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

                          - Contabilizar desconto de titulos e juros (Gabriel).
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               27/06/2011 - Consulta na crapltr desconsiderando alguns 
                            historicos, pois, os lancamentos referentes aos 
                            mesmos ja constam na craplcm. (Fabricio)
                            
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps133"
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps133 aux_handproc = PROC-HANDLE
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps133 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps133.pr_cdcritic WHEN pc_crps133.pr_cdcritic <> ?
       glb_dscritic = pc_crps133.pr_dscritic WHEN pc_crps133.pr_dscritic <> ?
       glb_stprogra = IF pc_crps133.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps133.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/* ........................................................................ */


