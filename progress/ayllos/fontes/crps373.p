/* ..........................................................................

   Programa: Fontes/crps373.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Dezembro/2003.                  Ultima atualizacao: 23/08/2013
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 102.(Cadeia 3/ Execucao em Paralelo)
              (Para CENTRAL - solicitacao 70 - Cadeia 1/Execucao em Paralelo)
               Efetuar os debitos do IPMF nas contas.
               Relatorio 323

   /*** No gnarrec.inpessoa = 3 vamos guardar os lancamentos do codigo de
        DARF igual a 5706, que contem o imposto de renda pago sobre os
        rendimentos do cotas capital tanto de pessoa fisica como
        juridica ***/
   Alteracao: 27/01/2004 - Prever novo histor de IR (Margarete).
              16/12/2004 - Incluidos hist. 875/877/876(Ajuste IR)(Mirtes)
              
              08/12/2005 - Controle para rodar de 10 em 10 dias e fazer o
                           recolhimento no 3o. dia util apos o fim do
                           periodo (Evandro).
                           
              17/02/2006 - Unificacao dos bancos - SQLWorks - Eder    
                       
              09/06/2006 - Para o controle de 10 em 10 dias, se estiver no 
                           ultimo decendio, atribuir ultimo dia do mes
                           (glb_dtultdia) para o final do periodo. (Julio)
              
              09/11/2007 - Incluir 533(rdcpos) e 476(rdcpre) (Magui).

              17/06/2008 - Incluir historicos 475 e 532 vindos do craplap
                           (Gabriel).
                           
              25/09/2009 - Precise - Paulo - Alterado programa para gravar 
                           em tabela generica total dos impostos quando for
                           cooperativa diferente de 3 (diferenciando total
                           pessoa fisica de juridica). Quando for a Cecred (3)
                           lista relatorio adicional totalizando os impostos
                           de cada cooperativa.

              03/11/2009 - Precise - Guilherme - Correcao da funcao Impostos
                           para processar a tabela crapcop. Correcao de
                           atribuicao de valores para aux_vlapagar e
                           aux_vlarecol e no aux_vlapagar recebendo o buffer
                       
              22/12/2009 - Inclusao da string "DO PERIODO" nas colunas
                           "IR A RECOLHER" de PF e  PJ (Guilherme/Precise)
                           
              25/02/2010 - Totalizar IOF a Pagar e IOF do Periodo (David).
              
              23/02/2011 - Incluir os historicos 922 e 926 da craplct, e o
                           novo codigo de DARF 5706 (Vitor).
                           
                         - Criar gnarrec.inpessoa = 3 quando valor for 
                           <> 0 (Vitor).  
                           
              22/10/2011 - Alterado a mascara do histor no FOR EACH (Ze).
              
              05/12/2011 - Acerto no CAN-DO do historico 476 (Ze).
              
              21/06/2012 - Substituido gncoper por crapcop (Tiago).
              
              30/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
              
              23/08/2013 - Incluido o total de isenção tributária.
              
............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps373"
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

RUN STORED-PROCEDURE pc_crps373 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps373 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps373.pr_cdcritic WHEN pc_crps373.pr_cdcritic <> ?
       glb_dscritic = pc_crps373.pr_dscritic WHEN pc_crps373.pr_dscritic <> ?
       glb_stprogra = IF pc_crps373.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps373.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


