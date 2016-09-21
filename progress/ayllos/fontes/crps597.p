/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps597.p                | pc_crps597                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 04/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/
/* ..........................................................................

   Programa: Fontes/crps597.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati - Diego
   Data    : Maio/2011                       Ultima atualizacao: 16/03/2015

   Dados referentes ao programa:

   Frequencia: Diario. Solicitacao 5 / Ordem 5 / Cadeia Exclusiva. 
               Tratado para rodar somente na segunda-feira.
   Objetivo  : Gerar relatorio crrl598 - Contas que efetuaram emprestimo na 
               ultima semana e nao contrataram seguro prestamista.
               
   Alterações: 30/06/2011 - Rodar com solicitacao 5 (Diego).
            
               05/07/2011 - Enviar e-mail para jeicy@cecred.coop.br (Henrique)
               
               07/07/2011 - Gerar relatorio por PAC (Henrique).
               
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Daniele). 
               
               28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               06/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                            
                            
               08/04/2014 - Inc. do email sergio.buzzi@mdsinsure.com (Carlos)
               
               04/09/2014 - Atualizar envio de e-mail para
                                emissao.cecred@mdsinsure.com
                            	daniella.ferreira@mdsinsure.com
                            	emissao.cecredseguros@mdsinsure.com
                            	cecredseguros@cecred.coop.br
                            (Douglas - Chamado 194868)
                            
              02/12/2014 - Atualizar envio de e-mail para
                                "sergio.buzzi@mdsinsure.com"                                "emissao.cecredseguros@mdsinsure.com,"
                                "daniella.ferreira@mdsinsure.com"
                                "ariana.barba@mdsinsure.com"
                                "pendencia.cecred@mdsinsure.com"
                                "cecredseguros@cecred.coop.br" 
                                (Felipe - Chamado 228940)     
                                
              16/03/2015 - Conversão Progress >> Oracle. (Reinert)
                           
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps597"
       glb_cdrelato = 598.       

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

RUN STORED-PROCEDURE pc_crps597 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps597 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps597.pr_cdcritic WHEN pc_crps597.pr_cdcritic <> ?
       glb_dscritic = pc_crps597.pr_dscritic WHEN pc_crps597.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps597.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps597.pr_infimsol = 1 THEN
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
