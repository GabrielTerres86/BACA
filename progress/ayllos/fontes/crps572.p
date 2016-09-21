/* ........................................................................... 
   
   Programa: Fontes/crps572.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Irlan
   Data    : Jun/2009.                     Ultima atualizacao: 06/05/2013 

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Importar arquivos XML 3046 referente a consulta de Op. Finan_
               ceiras no SFN.
               Solicitacao : 86
               Ordem do programa na solicitacao = 55
               Paralelo
   
   Observacoes: .
   
   Alteracoes:  02/08/2010 - Incluir a chamada ao fimprg.p quando nao tiver
                             arquivo a ser importado (Irlan).
                             
                22/08/2010 - Ajuste no tratamento da importação de 
                             múltiplos arquivos (Irlan).
                             
                01/03/2011 - Ajuste da conversao da data do XML para a data
                             de referencia da tabela (Henrique).
                             
                30/09/2011 - Ajuste para atender ao novo layout "3046" 
                             (Adriano).
                
                08/03/2012 - Incluído execucao do fimprg.p quando entrar na
                             critica "Arquivo ja importado" (Irlan)
                             
                09/08/2012 - Alterações no processamento do documento 3046
                             (Gabriel).     
                        
                06/05/2013 - Incluso tratamento para efetuar commit ao processar 
                             10000 registros na procedure cria_crapvop e 
                             cria_crapopf (Daniel).                                        
 ........................................................................... */

{ includes/var_batch.i  "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps572"
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

RUN STORED-PROCEDURE pc_crps572 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps572 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps572.pr_cdcritic WHEN pc_crps572.pr_cdcritic <> ?
       glb_dscritic = pc_crps572.pr_dscritic WHEN pc_crps572.pr_dscritic <> ?
       glb_stprogra = IF pc_crps572.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps572.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
                  
RUN fontes/fimprg.p.

