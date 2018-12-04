/* ..........................................................................

   Programa: Fontes/crps002.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Novembro/91.                        Ultima atualizacao: 09/06/2008

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
               Liberar diariamente os depositos bloqueados para o dia seguinte.

   Alteracoes: 22/04/1998 - Tratamento para milenio e troca para V8 (Margarete).
               
               28/08/2003 - Incluir numero da conta na critica quando valor do
                            saldo bloqueado for negativo (Junior). 
                            
               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder      
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase). 
                      
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR aux_vlsdbloq AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlsdblpr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_vlsdblfp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.

DEF        VAR aux_inhistor AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "zzzz,zz9,9"           NO-UNDO.
DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.

ASSIGN glb_cdprogra = "crps002"
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

RUN STORED-PROCEDURE pc_crps002 NO-ERROR
    (
    INPUT glb_cdcooper,
    INPUT glb_dtmvtolt,
    INPUT 0,
    INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps002.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps002.pr_cdcritic WHEN pc_crps002.pr_cdcritic <> ?
       glb_dscritic = pc_crps002.pr_dscritic WHEN pc_crps002.pr_dscritic <> ?
       glb_stprogra = IF pc_crps002.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps002.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
                  
glb_cdcritic = 0.

RUN fontes/fimprg.p.
