/* ..........................................................................

   Programa: fontes/crps433.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Janeiro/2005                       Ultima atualizacao: 24/01/2014
   Dados referentes ao programa:

   Frequencia: Anual.
   Objetivo  : Atende a solicitacao 103 ordem 1. 
               Importar as informacoes referentes a rendimentos e tributos 
               sobre as aplicacoes para DIRF

   Alteracoes: 04/07/2005 - Alimentado campo cdcooper da tabela crapdrf (Diego).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               23/01/2006 - Procurar pelo dir com a data do ultimo dia util
                            do ano calendario (Julio).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               14/02/2008 - Atualizar calculo de imposto com RDC-POS (Julio) 
               
               06/04/2011 - Atualizacao de nova tabela crapvir para os dados da
                            DIRF (GATI - Daniel Sousa)
                            
               20/04/2011 - Atualizacao da variavel crapvir.tporireg = 1;
                          - Criar registro na tabela crapvir, somente se o 
                            valor > 0. 
                          - A tabela crapdrf deverá criar registro somente se 
                            existir valor para algum mês. (GATI - Diego)
                            
               16/01/2012 - Tratamento Codigo de Retencao 5706 (Diego).
               
               13/02/2013 - Alterado valor de condicional do vlirfcot de 
                            >10 para >0.(Jorge)
               
               24/01/2014 - Incluir VALIDATE crapvir, crapdrf (Lucas R.)
               
               31/01/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)

............................................................................ */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps433"
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

RUN STORED-PROCEDURE pc_crps433 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps433 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps433.pr_cdcritic WHEN pc_crps433.pr_cdcritic <> ?
       glb_dscritic = pc_crps433.pr_dscritic WHEN pc_crps433.pr_dscritic <> ?
       glb_stprogra = IF pc_crps433.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps433.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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