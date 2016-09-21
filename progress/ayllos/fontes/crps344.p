/* ..........................................................................
                    ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps344.p                | pc_crps344                        |
  +---------------------------------+-----------------------------------+


   Programa: Fontes/crps344.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Maio/2003                       Ultima atualizacao: 30/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamentos de tarifas do desconto de cheques.

   Alteracoes: 24/10/2003 - Alterado para incluir a cobranca da tarifa de res-
                            gate de cheque descontado (Edson).

               02/04/2004 - Corrigir erro na cobranca do resgate de cheque 
                            descontado (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).
                            
               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               24/10/2008 - Corrigir atualizacao do lote (Magui).
               
               15/10/2010 - Alterado historico 434 p/ 893. Demandas Auditoria
                            BACEN (Guilherme).
                            
               10/07/2013 - Alterado processo de geracao tarifas para utilizar
                            rotinas da b1wgen0153, projeto Tarifas. (Daniel) 
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               30/04/2014 - Adaptado a rotina carrega_tabela_tarifas para
                            carregar temp table com o valor correto da faixa
                            da tarifa (Tiago/Rodrigo SD141136).     
                                    
              05/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel).             
............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps344"
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

RUN STORED-PROCEDURE pc_crps344 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps344 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps344.pr_cdcritic WHEN pc_crps344.pr_cdcritic <> ?
       glb_dscritic = pc_crps344.pr_dscritic WHEN pc_crps344.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps344.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps344.pr_infimsol = 1 THEN
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

        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/* .......................................................................... */

