
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps283.p                | pc_crps283                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps283.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/2000.                       Ultima atualizacao:31/03/2015

   Dados referentes ao programa:

   Frequencia: Solicitacao (Batch - Background).
   Objetivo  : Atende a solicitacao 72.
               Ordem 1
               Emite relatorio dos associados admitidos no mes (230) 
               para as empresas

   Alteracao : 16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
   
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               31/03/2015 - Adaptaçao fonte hibrido, projeto Progress-> Oracle
                            (Odirlei-AMcom)
                            
............................................................................. */

DEF STREAM str_1.     /*  Para listagem dos admitidos no mes  */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR rel_dsmesano AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdempres AS INT                                   NO-UNDO.

glb_cdprogra = "crps283".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

     
     
ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps283 aux_handproc = PROC-HANDLE
     (INPUT glb_cdcooper,                                                  
      INPUT glb_dsparame,
      INPUT INT(STRING(glb_flgresta,"1/0")),
      INPUT 0,
      INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps283 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps283.pr_cdcritic WHEN pc_crps283.pr_cdcritic <> ?
       glb_dscritic = pc_crps283.pr_dscritic WHEN pc_crps283.pr_dscritic <> ?
       glb_stprogra = IF pc_crps283.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps283.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

