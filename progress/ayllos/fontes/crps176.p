/* ..........................................................................

   Programa: Fontes/crps176.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/96.                    Ultima atualizacao: 22/07/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 5.
               Ordem na solicitacao: 10.
               Calcula as aplicacoes RDCA2 aniversariantes.
               Nao gera relatorio.


   Alteracoes: 25/04/2002 - Somar todas aa aplicacoes para poder definir
                            a taxa a ser usada (Margarete).

              10/12/2004 - Ajustes para tratar das novas aliquotas de 
                           IRRF (Margarete).
                           
              07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                           "fontes/iniprg.p" por causa da "glb_cdcooper"
                           (Evandro).
                           
              15/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
                           
              03/12/2007 - Substituir chamada da include rdca2s pela
                           b1wgen0004a.i (Sidnei - Precise).

              25/02/2008 - Quando aux_vltotrda < 0 zerar variavel (Magui). 

              10/12/2008 - Utilizar procedure "acumula_aplicacoes" (David).
              
              25/07/2012 - Ajustes para Oracle (Evandro).
              
              22/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Andre Santos - SUPERO)

............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps176"
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

RUN STORED-PROCEDURE pc_crps176 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps176 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps176.pr_cdcritic WHEN pc_crps176.pr_cdcritic <> ?
       glb_dscritic = pc_crps176.pr_dscritic WHEN pc_crps176.pr_dscritic <> ?
       glb_stprogra = IF pc_crps176.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps176.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       
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

/* .......................................................................... */
