/* ..........................................................................
                       ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps136.p                | pc_crps136                        |
  +---------------------------------+-----------------------------------+
 

   Programa: Fontes/crps136.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/95.                     Ultima atualizacao: 16/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de taxa de cadastramento de contra
               ordem.

   Alteracoes: 27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               11/12/98 - Alterado para permitir cobranca diferenciada para
                          cheques em branco (hist 825). (Deborah).

               18/12/98 - Tratar historico 835 da mesma forma que o 825
                          (Deborah).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).

               10/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
                            
               30/01/2007 - Ler crapcor por dtmvtolt e nao dtemscor (Magui).
               
               21/07/2008 - Inclusao do cdcooper no FIND craphis (Julio)
               
               08/12/2009 - Retiradas variaveis que nao estao sendo utilizadas:
                            res_nrdctabb, res_nrdocmto, res_cdhistor (Diego).
                            
               09/06/2011 - Nao tarifar histório 818 (Diego). 
               
               12/12/2011 - Sustação provisória (André R./Supero).
               
               09/05/2012 - Ajuste na cobranca de tarifas - Sustacao Prov. (Ze).
               
               09/01/2013 - Tratamento para contas migradas 
                            Viacredi -> AltoVale. (Fabricio)
                            
               08/05/2013 - Incluir ajustes referentes ao Projeto de Tarifas
                            Fase 2 (Lucas R.)
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               16/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel).              
............................................................................. */


{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps136"
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

RUN STORED-PROCEDURE pc_crps136 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps136 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps136.pr_cdcritic WHEN pc_crps136.pr_cdcritic <> ?
       glb_dscritic = pc_crps136.pr_dscritic WHEN pc_crps136.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps136.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps136.pr_infimsol = 1 THEN
                          TRUE
                      ELSE
                          FALSE.
       
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
