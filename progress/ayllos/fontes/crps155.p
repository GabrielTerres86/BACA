/* ..........................................................................

   Programa: Fontes/crps155.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Janeiro/95.                     Ultima atualizacao: 27/12/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 002.
               Emite listagem das POUPANCAS PROGRAMADAS RDCA por agencia.
               Relatorio 124

   Observacao: Para que haja o pedido de impressao do relatorio para a agencia
               devera existir a seguinte tabela CRED-GENERI-0-IMPREL124-agencia
               onde o texto da tabela informa os dias que deve ser impresso o
               relatorio.

   Alteracoes: 03/06/96 - Acerto no total (Deborah).

               09/07/96 - Alterado para listar tambem a agencia 3 (Deborah).

               17/09/96 - Alterado para listar somente as agencias cadastradas
                          na tabela de impressao (Odair).

               03/01/97 - Alterar a tabela de tratamento das poupancas programa-
                          das para tpregist = 2 para nao confiltar com programa
                          109 (Odair).

               26/01/2000 - Gerar pedidos de impressao (Deborah).
               
               02/10/2003 - Imprimir somente 1 via do relatorio (Ze Eduardo).

               06/10/2003 - Eliminar a tabela DESPESA (Deborah).
                
               17/10/2003 - Tratamento para calculo do VAR (Margarete).  

               28/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes).
               
               29/09/2004 - Gravacao de dados na tabela gninfpl do banco
                            generico, para relatorios gerenciais (Junior).
                            
               29/06/2005 - Alimentado campo cdcooper das tabelas crapvar e
                            craptab (Diego).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               31/03/2006 - Corrigir rotina de impressao do relatorio 124
                            (Junior).
                            
               09/04/2008 - Alterado formato do campo "craprpp.qtprepag" e da 
                            variável "apl_qtprepag" de "999" para "zz9" no FORM
                            (Kbase IT Solutions - Paulo Ricardo Maciel).       
                          - Situacao = 5 -> Resgate (Guilherme).
                            
              20/08/2008 - Desprezar poupancas para o VAR com saldo
                           zerado (Magui).
                           
              06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
              01/09/2017 - Inclusao de log de fim de execucao do programa 
                           (Carlos)
             
              27/12/2017 - Inclusao de novos paramentros na chamada da procedure
                           PC_CRPS155 no Oracle para tratar paralelismo - Projeto
                           Ligieirinho - Jonatas Jaqmam (AMcom)
............................................................................. */
/****** Decisoes sobre o VAR ************************************************
Poupanca programada sera mensal com taxa provisoria senao houver mensal
*****************************************************************************/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps155"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps155 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT 0,
    INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps155 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps155.pr_cdcritic WHEN pc_crps155.pr_cdcritic <> ?
       glb_dscritic = pc_crps155.pr_dscritic WHEN pc_crps155.pr_dscritic <> ?
       glb_stprogra = IF pc_crps155.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps155.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS155.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                  
RUN fontes/fimprg.p.

/* .......................................................................... */

