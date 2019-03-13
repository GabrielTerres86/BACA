/* .............................................................................

   Programa: Fontes/crps427.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Dezembro/2004.                    Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario (Cadeia 1).

   Objetivo  : Atende a solicitacao 2.
               Emitir relatorio (391) da Conciliacao COBAN (Correspondente 
               Bancario).

   Alteracoes: 08/12/2004 - Gerar relatorio 397 (Evandro).
               
               13/12/2004 - Mudado o format da Hora Trans para HH:MM:SS
                            (Evandro).
                            
               10/01/2005 - Incluida a Agencia de Relacionamento de cada PAC
                            (Evandro).
                            
               07/03/2005 - Corrigida a forma de leitura para o relelatorio 397
                            e incluido comando de impressao do relatorio 397
                            (Evandro).

               01/07/2005 - Alimentado campo cdcooper da tabela craprcb (Diego).
               
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).    
               
               11/11/2005 - Desprezar tipo docto 3 (Recebimento INSS)(Mirtes)
                                                                 
               12/01/2006 - Tratar tipo docto 3- Recebto INSS(Mirtes)

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               19/06/2006 - Incluir tratamento para docto tipo 3 no
                            Relatorio 397 (David).
                            
               15/01/2007 - Substituido dados da craptab "CORRESPOND" por
                            valores da crapage.cdagecbn (Elton).
               
               04/11/2008 - Divisao de colunas do relatorio 397 (martin)      

               29/04/2009 - Incluir no crrl391 as diferencas por PAC (Gabriel).
                
               12/08/2009 - Verificar diferencas da tabela craprcb para crapcbb
                          - Algumas leituras estavam sem NO-LOCK(Guilherme).
                          
               08/05/2012 - Incluído campos de codigo de barra e hora de
                            atendimento no relatorio 391 no item de 
                            "diferencas de valores" (Guilherme Maba).
                            
               04/01/2013 - Listar todos os documentos quando der diferenca.
                            Retirar comentarios desnecessarios.
                            (Gabriel).             
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/10/2013 - Ajustes no crrl397, total do VLR.FAT estava errado,
                            ajustado cabecalho para 132col (Lucas R.)
                            
               14/10/2013 - Ajustes no crrl391, listar valores por PAs e nao
                            por cooperativa como estava (Lucas R.)
                            
               28/10/2013 - Incluir crapage.cdcooper = glb_cdcooper no FIND
                            do crapage do str_1 (Lucas R.)
                            
               20/11/2013 - Retirado NEXT do  relatorio str_1 crrl391, nao
                            usar NEXT em BREAK BY (Lucas R.)
                            
               24/01/2014 - Incluir VALIDATE craprcb (Lucas R.) 
               
               02/04/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO))
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)

............................................................................ */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps427"
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

RUN STORED-PROCEDURE pc_crps427 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps427 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps427.pr_cdcritic WHEN pc_crps427.pr_cdcritic <> ?
       glb_dscritic = pc_crps427.pr_dscritic WHEN pc_crps427.pr_dscritic <> ?
       glb_stprogra = IF pc_crps427.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps427.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
    INPUT "CRPS427.P",
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
    INPUT "CRPS427.P",
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
