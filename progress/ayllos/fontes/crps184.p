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
                            
               28/09/2015 - Chamada do pc_crps184 do Oracle (Vanessa) 
                            
............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

DEF SHARED VAR tel_dtrefere       AS DATE    FORMAT "99/99/9999"       NO-UNDO.
DEF VAR aux_dscritic              AS CHAR                              NO-UNDO.

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps184 aux_handproc = PROC-HANDLE
                     (INPUT 9,                    
                      INPUT tel_dtrefere,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT 0,
                      OUTPUT "").

CLOSE STORED-PROC pc_crps184
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_dscritic = "".

ASSIGN aux_dscritic = pc_crps184.pr_dscritic
                      WHEN pc_crps184.pr_dscritic <> ?.


IF  aux_dscritic <> ""  THEN DO:
    BELL.
    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
END.

HIDE MESSAGE NO-PAUSE.

/* .......................................................................... */
