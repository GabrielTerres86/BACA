/* .............................................................................

   Programa: Fontes/crps540.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Precise
   Data    : Dezembro/2009.                      Ultima atualizacao: 12/09/2013
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos de DEVOLUCAO de CHEQUES da SR - Conciliacao.

   Alteracoes: 04/06/2010 - Acertos Gerais (Ze).
   
               16/06/2010 - Inclusao do campo gncptit.dtliquid (Ze).
                           
               07/07/2010 - Incluso Validacao para COMPEFORA e Acertos na 
                            Alinea (Jonatas/Supero e Ze)
               
               23/08/2010 - Acerto no registro de controle (Ze).             
               
               02/09/2010 - Acerto no campo nrdconta (Vitor/Ze).
               
               13/09/2010 - Acerto p/ gerar relatorio no diretorio rlnsv 
                            (Vitor)
               
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).
                            
               15/08/2012 - Alterado posigues do gncpdev.cdtipdoc de 52,2 
                            para 148,3 (Lucas R.).
                            
               17/08/2012 - Tratamento para cheques VLB (Fabricio).
               
               17/01/2013 - FIND na gncpdev com cdcooper = craptco.cdcooper,
                            para cheques de contas migradas. (Fabricio)
                            
               12/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps540"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps540 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT glb_cdoperad,
    INPUT glb_nmtelant,
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

CLOSE STORED-PROCEDURE pc_crps540 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps540.pr_cdcritic WHEN pc_crps540.pr_cdcritic <> ?
       glb_dscritic = pc_crps540.pr_dscritic WHEN pc_crps540.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps540.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps540.pr_infimsol = 1 THEN
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
