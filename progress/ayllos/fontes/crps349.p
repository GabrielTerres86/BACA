/* ............................................................................

   Programa: fontes/crps349.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando Hilgenstieler
   Data    : Agosto/2003.                    Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Relatorio para acompanhamento dos valores aplicados 
               e resgatados no mes. 
               Solicitacao 02, ordem 7 e crrl294.

   Alteracoes:23/09/2003 - Colocar total no saldo (Margarete). 
   
              22/04/2004 - Acrescentar mais uma via no rel. 294 (Eduardo)
 
              22/06/2004 - Tratar historico 145 (Margarete)
               
              21/09/2004 - Incluidos historicos 497/498/499/500/501(CI)(Mirtes)

              29/09/2004 - Gravacao de dados na tabela gninfpl do banco
                           generico, para relatorios gerenciais (Junior).
                           
              09/11/2004 - Considerar Aplicacao proveniente da Conta de 
                           Investimento(craplci = historico 491)(Mirtes)

              09/12/2004 - Incluir quantidade de aplicadores/resgates (Edson).

              15/08/2005 - Alterado para exibir tambem "Movimentos do dia nos
                           PACS" ao relatorio crrl294_99 (Diego).
              
              05/09/2005 - Retirado rotina para gravacao de dados dos relato-
                           rios gerenciais (Junior).
                           
              08/09/2005 - Acerto no relatorio crrl294_99. (Ze).

              21/09/2005 - Modificado FIND FIRST para FIND na tabela
                           crapcop.cdcooper = glb_cdcooper (Diego).
                           
              03/10/2005 - Alterado para imprimir apena uma copia para
                           CredCrea (Diego).
                           
              30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).
              
              07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                           "fontes/iniprg.p" por causa da "glb_cdcooper"
                           (Evandro).
                           
              17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                           
              17/05/2006 - Alterado numero de vias do relatorio crrl294_99
                           para Viacredi (Diego).
                           
              14/11/2006 - Melhoria da performance (Evandro).

              01/08/2007 - Tratamento para aplicacoes RDC (David).
 
              19/11/2007 - Substituir chamada da include aplicacao.i pela
                           BO b1wgen0004.i. (Sidnei - Precise).
                            
              24/03/2008 - Incluir historicos 478 e 530 (Magui).
              
              31/03/2008 - Retirado historico 387 da lista de historicos que
                           compoe o valor de credito (aplicado) das aplicacoes;
                         - Incluido historico 490 na leitura da craplci para
                           acrescentar valores no campo "Valor Resgatado" do
                           relatorio crrl294 (Elton).
                           
              09/10/2009 - Alterado modo de somar o total das aplicacoes das
                           cooperativas (Elton).             
              
              14/12/2010 - Alterada da ordem 8 para a ordem 49. Para ver
                           se perdemos menos tempo com crps414, pois as
                           aplicacoes ja estao em buffer (Magui).

              21/02/2011 - Usar temp-table para guardar as aplicacoes lidas
                           para nao calcular o saldo novamente quando
                           geracao total (Magui).

              20/05/2011 - Melhorar performance (Magui).
              
              10/08/2011 - Melhoria de performance (Evandro).
              
              03/01/2012 - Aumentado o format de zz,zz9 para zzz,zz9 (Tiago).
              
              07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Andre Santos - SUPERO)
                           
              01/09/2017 - Inclusao de log de fim de execucao do programa 
                           (Carlos)

............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps349"
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

RUN STORED-PROCEDURE pc_crps349 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps349 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps349.pr_cdcritic WHEN pc_crps349.pr_cdcritic <> ?
       glb_dscritic = pc_crps349.pr_dscritic WHEN pc_crps349.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps349.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps349.pr_infimsol = 1 THEN
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

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS349.P",
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
