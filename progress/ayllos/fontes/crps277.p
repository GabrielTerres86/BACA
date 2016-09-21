
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps277.p                | pc_crps277                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps277.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair 
   Data    : Outubro/1999                    Ultima atualizacao: 16/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Ordem 28.
               Debitar em conta corrente as faturas de VISA.
               Processa mas nao gera lcm dos craplau referente ao cartao BB.

   Alteracoes: 28/02/2005 - Concatenar codigo do historico com numero de seq.
                            do registro para controle de restart (Julio).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapdcd (Diego).
                                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.       
               
               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Tratamento para evitar o duplicates no create
                            da tabela craplcm (Ze).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. Adicionado tratamento para cartoes BB.
                            (Fabricio)
                            
               29/10/2012 - Desprezar os registros de lançamentos automaticos
                            se conta antiga for transferida 
                            (faturas Cecred Visa).(Irlan)
               
               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).         
                            
               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
               
               20/01/2014 - Incluir VALIDATE crapdcd, craplot, craplcm (Lucas R) 
               
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               16/04/2015 - Adaptação fonte hibrido Progress -> Oracle
                                                        (Odirlei-AMcom)
............................................................................. */

{ includes/var_batch.i {1} }
{ sistema/generico/includes/var_oracle.i }

glb_cdprogra = "crps277".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_inrestar = 0 THEN
     glb_nrctares = 0.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_crps277 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps277 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps277.pr_cdcritic WHEN pc_crps277.pr_cdcritic <> ?
       glb_dscritic = pc_crps277.pr_dscritic WHEN pc_crps277.pr_dscritic <> ?
       glb_stprogra = IF pc_crps277.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps277.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

