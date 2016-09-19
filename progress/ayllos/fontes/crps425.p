/* .............................................................................

   Programa: Fontes/crps425.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2004.                    Ultima atualizacao: 16/08/2013

   Dados referentes ao programa:

   Frequencia: Mensal.

   Objetivo  : Atende a solicitacao 39.
               Emitir relatorio (379) do resumo mensal dos historicos por PAC.

   Alteracoes: 04/01/2004 - Referenciado STREAM no comando DOWN,
                            frame f_lanctos (Evandro).

               12/09/2005 - Alterado o endereco para envio do e-mail do 
                            Roberto para o Fabio (Julio)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               09/12/2005 - Considerar lancamentos COBAN - crapcbb (Evandro).
 
               17/02/2006 - Unificacao dos Bancos - Fernando - SQLWorks.

               25/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper =
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               13/10/2008 - Adaptacao para desconto de titulos (David).
                            
               12/06/2009 - Retirado e_mail Fabio(Mirtes)
               
               01/07/2009 - Melhoria de performance (Evandro).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               08/03/2010 - Alteracao Historico (Gati)
               
               06/09/2010 - Inclusao de indice na temp-table tt-hist para
                            melhoria de performance e ajuste de padrao de
                            escrita (Evandro).
                            
               28/03/2013 - Ajustes referentes ao Projeto de tarifas fase 2
                            Grupo de cheques (Lucas R.)
                            
              16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).              
............................................................................ */

{ includes/var_batch.i "NEW" }

{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps425"
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

RUN STORED-PROCEDURE pc_crps425 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps425 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps425.pr_cdcritic WHEN pc_crps425.pr_cdcritic <> ?
       glb_dscritic = pc_crps425.pr_dscritic WHEN pc_crps425.pr_dscritic <> ?
       glb_stprogra = IF pc_crps425.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps425.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


