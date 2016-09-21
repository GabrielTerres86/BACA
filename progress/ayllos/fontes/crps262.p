/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps262.p                | pc_crps262                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 18/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/
/* ..........................................................................

   Programa: Fontes/crps262.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/99.                            Ultima atualizacao: 18/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Emitir relacao de cheque especial emitido no dia 212.
               Atende solicitacao 2, ordem  

   Alteracoes: 21/07/99 - Nao gerar pedido no MTSPOOL (Odair)
   
               17/12/1999 - Nao listar cancelamentos por transferencia
                            cdmotcan = 4 (Odair)

               25/04/2003 - Classificar tambem por pac e conta (Margarete).
               
               24/06/2003 - Dividir em duas listas <= 1000 (Margarete).
               
               22/07/2003 - Substituicao do valor fixo de 1000, pela variavel
                            aux_dstextab, no valor max do contrato (Julio).

               06/08/2003 - Inclusao da coluna TIPO no relatorio (Julio).
               
               25/11/2003 - Alteracao na mascara do campo valor (Junior).

               22/03/2005 - Listar apenas os limites cancelados (Edson).
                
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               25/01/2007 - Alterado as variaveis do tipo DATE de "99/99/99"
                            para "99/99/9999" (Elton).

               24/07/2008 - Alterado para acertar na hora de listar os limites
                            de cheques cancelados do relatorio 212 (Gabriel).

               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               14/01/2015 - Ajuste no limite de credito para verificar a situacao
                            e nao somente a craplim.dtfimvig. (James)
                            
               18/03/2015 - Conversao Progress >> Oracle. (Reinert)
............................................................................. */

{ includes/var_batch.i "NEW"}
{ sistema/generico/includes/var_oracle.i }
                                                               
ASSIGN glb_cdprogra = "crps262"
       glb_cdrelato = 212
       glb_flgbatch = false.

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps262 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps262 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps262.pr_cdcritic WHEN pc_crps262.pr_cdcritic <> ?
       glb_dscritic = pc_crps262.pr_dscritic WHEN pc_crps262.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps262.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps262.pr_infimsol = 1 THEN
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

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").


RUN fontes/fimprg.p.

/* .......................................................................... */
