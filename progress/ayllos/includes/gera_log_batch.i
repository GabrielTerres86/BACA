/* ..........................................................................

   Programa:iIncludes/gera_log_batch.i
   Sistema : CECRED
   Sigla   : CRED
   Autor   : Carlos Henrique
   Data    : Maio/2017.                     Ultima atualizacao: 11/12/2017

   Dados referentes ao programa:

   Frequencia: Diario (On-line/Batch)
   Objetivo  : Executar a rotina de log no proc_batch desenvolvida em oracle.

   Alteracoes:
   
   11/12/2017 - Inclusão do parametro par_cdmensagem - Codigo da mensagem ou critica (Origem crapcri.cdcritic)
                (Belli - Envolti - Chamado 786752)
............................................................................. */

PROCEDURE gera_log_batch_prog:
    DEF INPUT PARAM par_dstiplog     AS CHAR.
    DEF INPUT PARAM par_ind_tipo_log AS INTE.
    DEF INPUT PARAM par_des_log      AS CHAR.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_gera_log_batch aux_handproc = PROC-HANDLE
        (INPUT glb_cdcooper,
         INPUT par_ind_tipo_log, /* ind_tipo_log 1-mensagem / 2-erro de negócio / 3-erro nao tratado / alerta */
         input par_des_log,      /* des_log */
         input ?,      /* nmarqlog - nulo para proc_batch */
         input "N",    /* flnovlog - criar novo arquivo? */
         input "S",    /* flfinmsg - inserir string '[PL/SQL]' no final da mensagem? */
         input ?,      /* dsdirlog - nulo para /usr/coop/nmrescop/log */
         input par_dstiplog, /* dstiplog - I inicio, F fim, E erro */
         input glb_cdprogra, /* cdprograma */
         input 1,      /* tpexecucao 0-Outro/ 1-Batch/ 2-Job/ 3-Online */
         input 1,      /* cdcriticidade 0-Baixa/1-Media/2-Alta/3-Critica */
         input 0,      /* flgsucesso 0/1 */
		 input 0       /* Codigo da mensagem ou critica (Origem crapcri.cdcritic) - 11/12/2017 - Chamado 786752 */
         ).
    CLOSE STORED-PROCEDURE pc_gera_log_batch WHERE PROC-HANDLE = aux_handproc.
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }    
END PROCEDURE.
