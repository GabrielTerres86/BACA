/* .............................................................................

   Programa: Fontes/crps537.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme / Supero
   Data    : Novembro/2009.                   Ultima atualizacao: 10/10/2013
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar arquivos de Cheques da Nossa Remessa - Conciliacao.
               
   Alteracoes: 27/05/2010 - Alterar a data utilizada no FIND para a data que 
                            esta no HEADER do arquivo e incluir um resumo ao
                            fim do relatorio de Rejeitados, Integrados e
                            Recebidos (Guilherme/Supero)
                            
               28/05/2010 - Quando encontrar o registro Trailer dar LEAVE
                            e sair do laco de importacao do arquivo(Guilherme).                            
               04/06/2010 - Acertos Gerais (Ze).
               
               15/06/2010 - Alteração no layout do relatorio e detalhamento
                            quanto aos valores e quantidades dos cheques 
                            (Adriano). 

               23/06/2010 - Acertos Gerais (Ze).           
         
               06/07/2010 - Incluso Validacao para COMPEFORA (Jonatas/Supero)
               
               29/07/2010 - Acerto no nome do relatorio (Ze).

               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).
                            
               16/11/2010 - Incluir identificacao se eh Compe Nacional (Ze).
               
               15/08/2012 - Alterado posições do cdtipdoc de 52,2 para 148,3 
                            (Lucas R.).
               10/10/2013 - Chamada Stored Procedure do Oracle
                            (Andre Euzebio / Supero)
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps537"
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

RUN STORED-PROCEDURE pc_crps537 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT glb_nmtelant,
    OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps537 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps537.pr_cdcritic WHEN pc_crps537.pr_cdcritic <> ?
       glb_dscritic = pc_crps537.pr_dscritic WHEN pc_crps537.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps537.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps537.pr_infimsol = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_cdempres = pc_crps537.pr_cdempres.
     
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
