/* ..........................................................................

   Programa: Fontes/crps201.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/97.                       Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch)
   Objetivo  : Atende a solicitacao .
               Gerar estatistica  de talonarios.

   Alteracoes: 03/10/97 - Alterado para utilizar rotina padrao de calculo de
                          talonarios e ler crapreq utilizando o dia do movi-
                          mento e tipo de requisicao igual 1.
                          
               03/09/98 - Alterar para colocar numero de folhas (Odair).        
               14/08/00 - Incluir atualizacao de 2 novos campos
                          .qtrttbc e .qtsltlbc (Margarete)

             22/10/2004 - Tratar conta de integracao (Margarete).

             08/06/2005 - Tratar tipo 17 e 18(Mirtes) 

             30/06/2005 - Alimentado campo cdcooper da tabela crapger (Diego).
             
             16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

             29/08/2008 - Comentar taloes retirados do log (Magui).
             
             22/01/2009 - Alteracao cdempres (Diego).
             
             08/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).
             
             17/05/2010 - Tratar crapger.cdempres com 9999 em vez de 999
                          (Diego).
             
             27/09/2010 - Acertar atuazicoes para IF CECRED (Magui).
             
             16/01/2014 - Inclusao de VALIDATE crapger (Carlos)

			 12/07/2016 - CONVERSAO PROGRESS - ORACLE, ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE! (Evandro - RKAM)
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps201"
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

RUN STORED-PROCEDURE pc_crps201 NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps201.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps201.pr_cdcritic WHEN pc_crps201.pr_cdcritic <> ?
       glb_dscritic = pc_crps201.pr_dscritic WHEN pc_crps201.pr_dscritic <> ?
       glb_stprogra = IF pc_crps201.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps201.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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