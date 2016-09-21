/* .............................................................................
                    ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps215.p                | pc_crps215                        |
  +---------------------------------+-----------------------------------+ 

   Programa: Fontes/crps215.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/97.                    Ultima atualizacao: 16/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Creditar em conta corrente os lancamentos de cobranca.

   Alteracoes: 24/09/2004 - Incluir mais duas posicoes do Nro Convenio (Ze).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (magui).
               
               18/01/2006 - Aumento no campo nrdocmto (Ze).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               27/03/2006 - Acerto no programa (Ze). 
               
               08/11/2006 - Aumentei o tamanho da mascara na atribuicao do 
                            craplcb.nrdocmto para o craplcm.cdpesqbb (Julio)
                            
               23/07/2008 - Correcao na atualizacao da capa de lote (Magui).     
               
               
               20/06/2013 - Retirado processo de geracao tarifa na craplcm e 
                            incluso processo de geracao tarifa usando b1wgen0153.
                            (Daniel)   
               
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               16/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel).  
............................................................................. */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps215"
       glb_cdcritic = 0
       glb_flgbatch = FALSE
       glb_dscritic = "". 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.
ERROR-STATUS:ERROR = FALSE.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps215 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT glb_cdoperad,
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

CLOSE STORED-PROCEDURE pc_crps215 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps215.pr_cdcritic WHEN pc_crps215.pr_cdcritic <> ?
       glb_dscritic = pc_crps215.pr_dscritic WHEN pc_crps215.pr_dscritic <> ?
       glb_stprogra = IF pc_crps215.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps215.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
