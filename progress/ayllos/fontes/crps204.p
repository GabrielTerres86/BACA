/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps204.p                | pc_crps204                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps204.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/97                        Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 002.
               Listar as capas de lotes de determinados tipos do mes.
               Emite relatorio 161.

   Alteracoes: 21/10/97 - Alterar solicitacao de 39 para 46 e datas de inicio
                          e fim de leitura (Odair).
                          
               19/07/99 - Alterar a solicitacao de 46 (quinzenal) para
                          02 - diario (Odair) e nao gerar pedido de impressao
                          (Edson).
             
             07/08/2001 - Alterar para nao selecionar mais os lotes tipo 4
                          (Junior).
                          
             10/04/2002 - Mostrar os lotes de c/c referentes a credito de 
                          capital - faixa 1300 (Deborah).

             05/01/2006 - Cancelar impressao da Coope 1 (Magui).
             
             16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
             
             25/05/2007 - Retirado vinculacao da execucao do fontes/imprim.p   
                          ao codigo da cooperativa vinculada (Guilherme).
                          
             03/04/2012 - Acerto no estouro de campo em f_lanctos (Ze).
             
             09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                          a escrita será PA (André Euzébio - Supero).
                          
             09/12/2014 - Migracao PROGRESS/ORACLE - Adaptado para executar
                          a nova procedure no Oracle (Jéssica DB1)
                             
             20/02/2019 - Inclusao de log de fim de execucao do programa 
                          (Belli - Envolti - Chamado REQ0039739)
							 
............................................................................. */


DEF STREAM str_1.  

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps204"
       glb_cdcritic = 0
       glb_flgbatch = FALSE
       glb_flgresta = FALSE
       glb_dscritic = "". 

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " +
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    QUIT.
END.
ERROR-STATUS:ERROR = FALSE.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps204 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps204 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps204.pr_cdcritic WHEN pc_crps204.pr_cdcritic <> ?
       glb_dscritic = pc_crps204.pr_dscritic WHEN pc_crps204.pr_dscritic <> ?
       glb_stprogra = IF pc_crps204.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps204.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
    INPUT "CRPS204.P",
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
    INPUT "CRPS204.P",
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


