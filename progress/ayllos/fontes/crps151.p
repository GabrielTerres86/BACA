/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps151.p                | pc_crps151                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps151.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96.                        Ultima atualizacao: 06/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de contrato de cheque especial.

   Alteracoes: 23/08/96 - Alterado para desprezar lancamentos de limite
                          Credicad (Deborah).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               25/09/2003 - Selecionar apenas os limite tipo 1 (Edson).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e crapavs (Diego).
               
               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               12/04/2007 - Substituir tabela TRFACTRLIM pela craplrt. (Ze).
               
               15/09/2010 - Alterado historico 163 p/ 892. Demandas auditoria 
                            BACEN (Guilherme).
                            
               24/02/2011 - Alterar para utilizar o numero de documento = 
                            craplim.nrctrlim (Vitor)           
                            
               21/06/2011 - Controlar tarifas das linhas de credito através
                            da tabela CRATLR (Adriano).
                            
               11/07/2013 - Alterado processo de busca valor tarifa para 
                            utilizar rotinas da b1wgen0153, projeto tarifas.
                            (Daniel)             
                             
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               06/06/2014 - Conversão Progress >> Oracle PLSQL 
                            (Tiago Castro - RKAM).
............................................................................. */


{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps151"
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

RUN STORED-PROCEDURE pc_crps151 aux_handproc = PROC-HANDLE NO-ERROR
   (INPUT glb_cdcooper,
    INPUT glb_cdoperad,
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
        
CLOSE STORED-PROCEDURE pc_crps151 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps151.pr_cdcritic WHEN pc_crps151.pr_cdcritic <> ?
       glb_dscritic = pc_crps151.pr_dscritic WHEN pc_crps151.pr_dscritic <> ?
       glb_stprogra = IF pc_crps151.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps151.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       

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

