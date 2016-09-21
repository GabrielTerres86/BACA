/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps196.p                | pc_crps196                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/



/* ..........................................................................
   Programa: Fontes/crps196.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/97                         Ultima atualizacao: 27/03/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Debitar em conta corrente referente aos convenios

   Alteracoes: 01/07/97 - Listar resumo final convenio 8 (Odair)

               28/07/97 - Listar resumo final para todos os convenios (Odair).

               27/08/97 - Alterado para tratar crapavs.flgproce (Deborah).

               09/09/97 - Acerto no resumo do repasse. (Deborah).

               06/11/97 - Desmembrar da parte de relatorios (Odair).

               16/02/98 - Alterar data final do CPMF (Odair)

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               21/05/98 - Tratar para descontar apenas integral (Odair).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               04/06/1999 - Tratar CPMF (Deborah).

               10/09/1999 - Desprezar se crapavs.flgproce for TRUE (Deborah).

               26/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               09/12/2003 - Tratamento erro evitando o duplicates no lcm (Ze).
               
               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot e
                            craplcm (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               19/10/2009 - Alteracao Codigo Historico (Kbase).                          
               
               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).
                            
               16/01/2014 - Inclusao de VALIDATE craplot e craplcm (Carlos)
               
               12/06/2014 - Alterado tipo da variavel aux_nrdocmto de INTE 
                            para DECI (Elton).
                            
               27/03/2015 - Adaptação para fonte hibrido, procedure chamar a              
                            rotina convertida para Oracle (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_batch.i {1} } 
{ sistema/generico/includes/var_oracle.i }

{ includes/var_cpmf.i } 

ASSIGN glb_cdprogra = "crps196"
       glb_cdcritic = 0
       glb_dscritic = "".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_crps196 aux_handproc = PROC-HANDLE
     (INPUT glb_cdcooper,                                                  
      INPUT INT(STRING(glb_flgresta,"1/0")),
      INPUT 0,
      INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps196 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps196.pr_cdcritic WHEN pc_crps196.pr_cdcritic <> ?
       glb_dscritic = pc_crps196.pr_dscritic WHEN pc_crps196.pr_dscritic <> ?
       glb_stprogra = IF pc_crps196.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps196.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

