
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps455.p                | pc_crps455                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/* .............................................................................

   Programa: Fontes/crps455.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor(a): Diego/Mirtes
   Data    : Agosto/2005.                      Ultima atualizacao: 20/02/2019
   
   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Emite relatorio para acompanhamento e analise dos cheques
               de outros Bancos devolvidos fora do prazo regular de 
               liberacao (380) - Solicitacao 2.

   Alteracoes: 12/09/2005 - Acrescentados campos PAC, BANCO, AGENCIA e
                            SALDO (Diego).                           
                            
               17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               15/03/2006 - Efetuar acerto indice/leitura crapchd(Mirtes)
               
               29/01/2007 - Alterado formato dos campos do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton).

               23/01/2009 - Incluir codigo da alinea (Gabriel). 
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               08/10/2014 - Efetuado tratamento para depositos intercooperativas
                            (Reinert).
               
               30/03/2015 - Adaptaçao fonte hibrido, projeto Progress-> Oracle
                            (Odirlei-AMcom)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
                                         
............................................................................. */

DEF STREAM str_1. /* Relatorio */

{ includes/var_batch.i "NEW"} 
{ sistema/generico/includes/var_oracle.i }


DEF    VAR rel_nmempres    AS CHAR                               NO-UNDO.
DEF    VAR rel_nmrelato    AS CHAR                   EXTENT 5    NO-UNDO.
DEF    VAR rel_nrmodulo    AS INT                                NO-UNDO.
DEF    VAR rel_nmmodulo    AS CHAR    FORMAT "x(15)" EXTENT 5    NO-UNDO.

DEF    VAR aux_qtdchequ    AS DECIMAL FORMAT "zz,zzz,zz9"        NO-UNDO.
DEF    VAR aux_contvlrt    LIKE craplcm.vllanmto                 NO-UNDO.
DEF    VAR i-nrdocmto      AS INTE                               NO-UNDO.

 
ASSIGN glb_cdprogra = "crps455".

RUN fontes/iniprg.p.  

{ includes/cabrel132_1.i }                       
                         
IF   glb_cdcritic > 0 THEN
     QUIT.  

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_crps455 aux_handproc = PROC-HANDLE
     (INPUT glb_cdcooper,                                                  
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
    QUIT.
END.     

CLOSE STORED-PROCEDURE pc_crps455 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps455.pr_cdcritic WHEN pc_crps455.pr_cdcritic <> ?
       glb_dscritic = pc_crps455.pr_dscritic WHEN pc_crps455.pr_dscritic <> ?
       glb_stprogra = IF pc_crps455.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps455.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
    INPUT "CRPS455.P",
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
    INPUT "CRPS455.P",
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
