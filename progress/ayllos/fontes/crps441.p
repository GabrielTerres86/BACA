/* ............................................................................

   Programa: Fontes/crps441.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2005                        Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario (Batch). "Paralelo"
   Objetivo  : Fechamento dos seguros, tipo = 11.
               Atende a solicitacao 02, ordem 9, emite relatorio 418.

   Observacao: Embora paralelo este programa faz atualizacao do campo
               crapseg.indebito. Portanto existe uma transacao.
   
   Alteracoes: 18/08/2005 - Implementado o total geral para o relatorio (Julio)

               31/08/2005 - Alterar destinatario do e-mail do Jean para a 
                            Janeide (Julio)

               13/12/2005 - Alterado o programa para rodar diariamente, antes
                            era quinzenal (Julio)
                            
               10/01/2006 - Correcao da atualizacao do indicador de pagamento
                            e melhorias gerais no programa (Julio)
                            
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               03/04/2006 - Acerto na atualizacao do indicador de debito
                            (Julio).

               16/06/2006 - Alteracao no calculo da data inicial para
                            relacionar os seguros. Alterar situacao dos
                            seguros que estiverem em fim de vigencia (Julio)
                            
               12/07/2006 - Alteracoes na totalizacao das prestacoes pagas
                            e atualizacao do indicador de pagamento (Julio)
               
               06/08/2007 - Incluido envio de email para: 
                            rene.bnu@addmakler.com.br (Guilherme).

               04/09/2007 - Verificar atraves do craplcm se a prestacao do
                            seguro foi paga no periodo em questao (Julio)
                            
               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               09/04/2008 - Alteragco do campo "crapseg.qtprepag", de "99" para
                            "zz9" - Kbase it Solutions - Eduardo.
              
               28/01/2009 - Enviar email somente p/ aylloscecred@addmakler.com
                            .br (Gabriel).
                            
               25/02/2010 - Incluido coluna "PAC ASS" no relatorio (Elton).
               
               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
               
               20/09/2011 - Retirado seguros endossado inclusão dos seguros 
                            renovados. (Lauro)
                            
               02/02/2012 - Modificada extensao do arquivo crrl418 somente
                            para envio de e-mail (Diego).
                            
               22/05/2012 - Alterado busca na crapseg para não trazer seguros
                            com a data de contratração igual a data de 
                            cancelamento (Guilherme Maba). 
                            
              04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                           cecredseguros@cecred.coop.br (Daniele). 
                                       
              12/09/2013 - Conversao oracle, chamada da stored procedure
                            (Andre Euzebio / Supero).
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
               
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps441"
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

RUN STORED-PROCEDURE pc_crps441 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                         OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps441 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps441.pr_cdcritic WHEN pc_crps441.pr_cdcritic <> ?
       glb_dscritic = pc_crps441.pr_dscritic WHEN pc_crps441.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps441.pr_stprogra = 1 THEN 
                          TRUE 
                      ELSE 
                          FALSE
       glb_infimsol = IF  pc_crps441.pr_infimsol = 1 THEN 
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
    INPUT "CRPS441.P",
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
    INPUT "CRPS441.P",
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

