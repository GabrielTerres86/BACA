/* ..........................................................................

   Programa: Fontes/crps160.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/96                        Ultima atualizacao: 13/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 067.
               Gerar os debitos referentes a poupanca programada Ceval de
               cheque salario
               Emite relatorio 127.

   Alteracoes: 09/09/96 - Alterado para tratar outrar empresas (Edson).

               17/07/97 - Tratar data crapavs.dtmvtolt dependendo do tpconven
                          (Odair).

               24/07/97 - Atualizar crapemp.inavsppr (Odair).

               31/07/97 - Acerto no for each das poupancas suspensas (Deborah)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               22/01/98 - Alterado para gerar cdsecext para Ceval Jaragua com
                          zeros (Deborah).

               24/03/98 - Cancelada a alteracao anterior (Deborah).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               10/09/98 - Tratar tipo de conta 7 (Deborah).

               08/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)
               
               29/06/2005 - Alimentado campo cdcooper da tabela crapavs (Diego).

               15/02/2006 - Unificacao dos bancos- SQLWorks - Eder
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               01/12/2010 - 001 - Alterado format "x(40)" para "x(50)"
                            KBASE - Kamila Ploharski de Oliveira

               13/12/2013 - Verificar se ja existe um aviso cadastrado para 
                            a data de referencia. Se existir, deletar o registro
                            e criar um novo (David).
               
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio de avisos  */

{ includes/var_batch.i {1} }  
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps160"
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

RUN STORED-PROCEDURE pc_crps160 aux_handproc = PROC-HANDLE
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps160 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps160.pr_cdcritic WHEN pc_crps160.pr_cdcritic <> ?
       glb_dscritic = pc_crps160.pr_dscritic WHEN pc_crps160.pr_dscritic <> ?
       glb_stprogra = IF pc_crps160.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps160.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


