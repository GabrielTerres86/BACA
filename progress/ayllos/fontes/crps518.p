/*..............................................................................

    Programa: Fontes/crps518.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Gabriel
    Data    : Outubro/2008                   Ultima Atualizacao: 20/02/2019

    Dados referente ao programa:
    
    Frequencia: Diario.
    
    Objetivo  : Emitir a listagem de titulos descontados no dia, borderos
                ativos e detalhamento dos titulos em desconto.
                Solicitacao: 2
                Ordem:       18

    Alteracoes: 18/12/2008 - Incluido o saldo contabil no relatorio 495
                             conforme a tela TITCTO - opcao S, a pedido da
                             contabilidade (Evandro).
                       
                05/01/2009 - Alterado formato de campos para evitar estouros
                             (Gabriel)
                           - Corrigida contabilizacao do valor a apropriar
                             relatorio 495 - deve ser considerado o valor
                             total, inclusive o valor de abatimento (Evandro).
                             
                06/02/2009 - Correcao na contabilizacao da alteracao do Evandro
                             deve-se utilizar o ultimo dia util do mes na busca
                             do crapljt pois os juros sao gravados no ultimo 
                             dia do mes e nao no ultimo dia util do mes
                           - Utilizar a contabilizacao da correcao acima(pelo
                             Evandro) tambem no 494 
                           - Utilizar quebra no 494 pelo pac do associado e nao
                             pelo bordero, pois o cooperado pode mudar de pac
                             (Guilherme).
                             
               26/03/2009 - Na opcao "S" na baixa sem pagamentos, ignorar
                            os titulos de final de semana na segunda-feira
                            (Guilherme).
 
               01/04/2009 - Tratar titulos em Desconto pagos via internet como
                            CAIXA cob.indpagto = 3 cob.indpagto = 1
                            Tarefa 23393 
                          - Nao considerar titulos que foram pagos pela COMPE na
                            data atual em RISCO pois somente serao lancados na
                            contabilidade com D+1
                          - Alterado de exclusivo para paralelo
                            (Guilherme/Evandro)
                            
               21/05/2009 - Considerar em risco titulos que vencem em 
                            glb_dtmvtolt (Guilherme).
                            
               09/07/2009 - Acerto no display de totais de contratos ativos
                            pessoa juridica + pessoa fisica(Guilherme).
                            
               09/09/2009 - Nao considerar a data de vencimento nos titulos em
                            aberto porque a liquidacao esta rodando antes no
                            processo batch (Evandro).
               
               10/06/2010 - Tratamento para pagamento feito atraves de TAA 
                            (Elton).             
                            
               06/07/2011 - Realizado correcao para pegar o craplim correto
                            (Adriano).  
                            
               15/08/2012 - Alteração no layout do relatorio 494, 495 ref.
                            a tit. desc. da cob. registrada (David Kruger).

               30/10/2012 - Ajuste na rotina de Saldo de Títulos. Considerar
                            pagtos pela compe 085 em D-0 (Rafael).
                            
               13/02/2013 - Ajuste nas mensagens da proc_batch ref. a titulos
                            nao encontrados na crapcob (Rafael).

               25/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                             (Belli - Envolti - Chamado REQ0039739)

.............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps518"
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

RUN STORED-PROCEDURE pc_crps518 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps518 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps518.pr_cdcritic WHEN pc_crps518.pr_cdcritic <> ?
       glb_dscritic = pc_crps518.pr_dscritic WHEN pc_crps518.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps518.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps518.pr_infimsol = 1 THEN
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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS518.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS518.P",
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
