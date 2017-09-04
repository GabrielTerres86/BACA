 /* ..........................................................................
                                    
   Programa: Fontes/crps084.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson                   Ultima atualizacao: 01/09/2017
   Data    : Janeiro/94.

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 044.
               Emite relatorio com os 100 maiores devedores e 
               daqueles com dividas superiores a 50.000,00.

   Alteracoes: 01/12/95 - Acerto no numero de vias. (Deborah)

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               19/11/2004 - Gerar tambem relatorio com TODOS os devedores
                            (rl/crrl071_99.lst);
                            Mudado a logica de leitura e geracao dos arquivos
                            (Evandro).
                            
               09/05/2005 - Incluida a coluna de Saldo Desconto de Cheques;
                            Corrigido o display do total de todos os devedores;
                            Modificada a coluna DEPOSITO VISTA para o valor
                            UTILIZADO (Evandro).

               06/12/2005 - Gerar relatorio dos 100 maiores devedores sem
                            quebras de pagina e com envio de email 
                            (crrl071_ .txt) (Diego).
                    
               21/12/2005 - Dpv utilizado calculado de outra forma (Magui).

               03/02/2006 - Modificado nome relatorio(str_4), e alterado
                            para listar TODOS DEVEDORES (Diego).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               07/11/2006 - Incluido PAC do associado nos relatorios (Elton).
               
               09/04/2006 - Gerar arquivo com totais das operacoes por CPF
                            (David).
                            
               02/05/2007 - Incluido chave na TEMP-TABLE (Magui).
               
               13/07/2007 - Retirado envio de email. Alterado nome do arquivo
                            que e salvo na pasta 'rl/' crrl071 e sua extensao
                            para .lst (Guilherme).

               06/02/2008 - Lista os 100 maiores devedores e aqueles com dividas
                            maiores que 50.000,00 (Elton).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               15/10/2008 - Adaptacao para desconto de titulos (David).

               09/04/2009 - D+1 para titulos em desconto(Guilherme).

               14/04/2009 - Inclusao da coluna RISCO nos relatorios (Elton).

               21/05/2009 - Considerar em divida titulos que vencem em 
                            glb_dtmvtolt (Guilherme).
                            
               29/06/2009 - Corrigida limpeza da variavel dec_vldjuros para o
                            desconto de titulos (Evandro).
               
               10/06/2010 - Incluido tratamento para pagamento realizado atraves
                            de TAA (Elton).
                            
               30/11/2010 - (001) Alteração de format dos campos da tabela para
                            x(50) Leonardo Américo (Kbase).
                            
               27/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            (Diego).
                            
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
                                                                   
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps084"
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

RUN STORED-PROCEDURE pc_crps084 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps084 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps084.pr_cdcritic WHEN pc_crps084.pr_cdcritic <> ?
       glb_dscritic = pc_crps084.pr_dscritic WHEN pc_crps084.pr_dscritic <> ?
       glb_stprogra = IF pc_crps084.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps084.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS084.P",
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

