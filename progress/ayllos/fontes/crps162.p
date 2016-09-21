/* ..........................................................................

   Programa: Fontes/crps162.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/96.                          Ultima atualizacao: 09/09/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 4.
               Emite relatorio dos emprestimos em atraso e em credito em
               liquidacao (129).

   Alteracoes: 02/02/98 - Alterado de 2 para 3 copias (Deborah).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder  

               29/12/2006 - Efetuado acerto validacao leitura crapass(MIrtes)
               
               05/03/2008 - Tratamento para o caso de nao haver taxa no mes de
                            calculo e liberacao do imprim.p (Evandro).
               09/04/2008 - Alterado formato do campo "crapepr.qtpreemp" e da
                            variável "rel_qtpreemp"  
                            de "999" para "zz9" para visualização no FORM
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               09/10/2008 - Estava buscando taxa do mes novo (Magui).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps162"
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

RUN STORED-PROCEDURE pc_crps162 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps162 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps162.pr_cdcritic WHEN pc_crps162.pr_cdcritic <> ?
       glb_dscritic = pc_crps162.pr_dscritic WHEN pc_crps162.pr_dscritic <> ?
       glb_stprogra = IF pc_crps162.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps162.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
 
