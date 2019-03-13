/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps212.p                | pc_crps212                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps212.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/97.                        Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 002.
               Gerar arquivo de estouro de convenios.

   Alteracoes: 03/11/97 - Mandar arquivos direto para Hering (Odair).

               05/11/97 - Por o campo nrdocmto no arquivo (Odair)

               15/12/97 - Gerar arquivo para os convenios 18 e 19 (Odair)

               09/03/98 - Gerar arquivo para os convenios 24 e 25
                          e passar novo parametro para o transrh (Deborah).

               14/09/98 - Alterado para transmitir os convenios 16 e 30 
                          (Deborah).

               08/10/98 - Alterado para transmitir os convenios 32 e 33
                          (Deborah).

               12/07/1999 - Melhorar o display de transmissao (Deborah).

               05/01/2000 - Padronizar as criticas (Deborah).
               
               12/12/2002 - Alterado para enviar arquivos de convenios
                            automaticamente (Junior).
                            
               20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder    
                        
               30/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).
               
               22/12/2006 - Alteracao envio de arquivos(Mirtes)  

               12/04/2007 - Retirar rotina de email em comentario (David).

               18/03/2008 - Retirado comentario da rotina de envio de email
                            (Sidnei - Precise)
                            
               22/01/2015 - Migracao PROGRESS/ORACLE - Adaptado para executar
                          a nova procedure no Oracle (Jéssica DB1)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                             (Belli - Envolti - Chamado REQ0039739)

............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps212"
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

RUN STORED-PROCEDURE pc_crps212 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps212 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps212.pr_cdcritic WHEN pc_crps212.pr_cdcritic <> ?
       glb_dscritic = pc_crps212.pr_dscritic WHEN pc_crps212.pr_dscritic <> ?
       glb_stprogra = IF pc_crps212.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps212.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
    INPUT "CRPS212.P",
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
    INPUT "CRPS212.P",
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

