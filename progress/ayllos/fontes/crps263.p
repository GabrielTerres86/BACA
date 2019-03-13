/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps263.p                | pc_crps263                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/

/* ............................................................................

   Programa: Fontes/crps263.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah          
   Data    : Maio/99                             Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: QUINZENAL
   Objetivo  : Atende a solicitacao 089
               Ordem 4
               Relatorio 213 - Seguros de automoveis a vencer no mes seguinte.
                               
   Alteracoes: 24/08/2000 - Impressao em 2 vias (Deborah).
               
               11/10/2000 - Alterar para 20 posicoes fone (Margarete/Planner).

               16/02/2005 - Alterado para rodar sempre na primeira quinzena
                            do mes (Edson).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               22/02/2008 - Alterado para mostrar turno a partir da 
                            crapttl.cdturnos (Gabriel).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).
                        
                          - Excluir colunas EMP e TU, ajustar Telefone. Rel 213
                            (Gabriel).

               02/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).   
               
               01/10/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               04/10/2013 - Remocao de codigo depois do for each dos seguros.
                            Inclusao do total de seguros a vencer de todos os
                            PAs da cooperativa (Carlos)
                            
               12/02/2015 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Vanessa)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
							
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps263"
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

RUN STORED-PROCEDURE pc_crps263 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INTE(STRING(glb_flgresta,"1/0")),
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

CLOSE STORED-PROCEDURE pc_crps263 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps263.pr_cdcritic WHEN pc_crps263.pr_cdcritic <> ?
       glb_dscritic = pc_crps263.pr_dscritic WHEN pc_crps263.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps263.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps263.pr_infimsol = 1 THEN
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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS263.P",
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
    INPUT "CRPS263.P",
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
