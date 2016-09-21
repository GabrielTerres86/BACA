/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps184.p                | pc_crps184                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/










/* ..........................................................................

   Programa: fontes/crps184.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Fevereiro/2006                  Ultima atualizacao: 02/08/2013

   Dados referentes ao programa:

   Frequencia: Tela.
   Objetivo  : Atende a solicitacao 104.
               Emite relatorio da provisao para creditos de liquidacao duvidosa
               (227).

   Alteracoes: 16/02/2006 - Criadas variaveis p/ listagem de Riscos por PAC
                            (Diego).
                            
               04/12/2009 - Retirar o nao uso mais do buffer crabass 
                            e aux_recid (Gabriel).             

               24/08/2010 - Incluir w-crapris.qtatraso (Magui).
               
               25/08/2010 - Inclusao das variaveis aux_rel1725, aux_rel1726,
                            aux_rel1725_v, aux_rel1726_v. Devido a alteracao
                            na includes crps280.i (Adriano).
                            
               19/10/2012 - Incluido variaveis aux_rel1724 devido as alteracoes
                            na include crps280.i (Rafael).
                            
               22/04/2013 - Incluido os campos cdorigem, qtdiaatr na criacao 
                            da temp-table w-crapris (Adriano).   
                            
               21/06/2013 - Adicionado campo w-crapris.nrseqctr (Lucas)
               
               02/08/2013 - Removido a declaracao da temp-table w-crapris.
                            (Fabricio)
                            
............................................................................. */


{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

DEF SHARED VAR tel_dtrefere       AS DATE    FORMAT "99/99/9999"       NO-UNDO.

ASSIGN glb_cdprogra = "crps184"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

       /* Data informada na tela */
/*ASSIGN aux_dtrefere = tel_dtrefere.*/
       
       /* Variavel criada como local ("NEW") e alterada somente para data de
          referencia do relatorio. Sera destruida ao fim do programa */
     /* glb_dtmvtolt = tel_dtrefere.*/

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps184 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                 /*pr_cdcooper*/
    INPUT tel_dtrefere,                 /*pr_dtrefere*/
    OUTPUT 0,                           /*pr_stprogra*/
    OUTPUT 0,                           /*pr_infimsol*/
    OUTPUT 0,                           /*pr_cdcritic*/
    OUTPUT "").                         /*pr_dscritic*/

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    MESSAGE "Erro ao executar Stored Procedure pc_crps184: '" +
             aux_msgerora VIEW-AS ALERT-BOX.
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps184 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps184.pr_cdcritic WHEN pc_crps184.pr_cdcritic <> ?
       glb_dscritic = pc_crps184.pr_dscritic WHEN pc_crps184.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps184.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps184.pr_infimsol = 1 THEN
                         TRUE
                      ELSE
                         FALSE.

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        MESSAGE glb_dscritic VIEW-AS ALERT-BOX.
    END.                          

RUN fontes/fimprg.p.  
/* .......................................................................... */