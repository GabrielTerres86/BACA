/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps280.p                | pc_crps280                        |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/




/* ..........................................................................

   Programa: Fontes/crps280.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah      
   Data    : Fevereiro/2000                      Ultima atualizacao: 01/09/2017

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 4.
               Emite relatorio da provisao para creditos de liquidacao duvidosa
               (227).

   Alteracoes: 24/03/2000 - Acerto para imprimir os totais mesmo quando nao
                            houver emprestimos em atraso. (Deborah).

               17/11/2000 - Ajuste para auditoria (Edson).
               
               28/12/2000 - Acerto no total em atraso - limitar ao saldo
                            devedor (Deborah).

               11/11/2003 - Alterado para enviar por email o relatorio gerado
                            (Edson).

               19/11/2003 - Calcula Provisao pelo Risco - Arq.crapris(Mirtes)

               20/05/2004 - Gerar relatorio para  Auditoria(354). Todos os
                            contratos(e nao apenas os em atraso)(Mirtes).
                            
               03/05/2005 - Alterado numero de copias para impressao na
                            Viacredi (Diego).
                                         
               02/06/2005 - Gera arq.Texto(Daniela) com contratos com nivel
                            de risco <> 2("A") e em dia(Mirtes)

               19/07/2005 - Incluido PAC no arquivo texto(Mirtes)

               30/08/2005 - Incluido no arquivo texto  - flag indicando se
                            Rating pode ou nao ser atualizado(Mirtes)
                            
               03/02/2006 - Trocados os valores da coluna "Parcela" com a
                            coluna "Saldo Devedor" e incluida a coluna "Risco"
                            (Evandro).
                            
               08/02/2006 - Separado o programa em uma include (crps280.i) para
                            poder ser chamado tambem pela tela RISCO (Evandro).
                            
               16/02/2006 - Criadas variaveis p/ listagem de Riscos por PAC
                            (Diego).
                            
               04/12/2009 - Retirar o nao uso mais do buffer crabass e
                            aux_recid (Gabriel).   
                            
               09/08/2010 - Incluido campo "qtatraso" na Temp-Table w-crapris
                            (Elton).  
                            
               25/08/2010 - Inclusao das variaveis aux_rel1725, aux_rel1726,
                            aux_rel1725_v, aux_rel1726_v. Devido a alteracao
                            na includes crps280.i (Adriano).
                
               27/08/2010 - Inserir na crapbnd total de provisoes e dividas sem
                            prejuizo. Tarefa 34667. (Henrique)
                            
               14/05/2012 - Incluido tratamento de LOCK na atualizacao do 
                            registro da tabela crapbnd. (Fabricio)
                            
               09/10/2012 - Novas variaveis para ajustar os relatorios 227 
                            e 354 - Desc. Tit. Cob. Registrada. (Rafael)
                            
               18/04/2013 - Incluido o campo cdorigem na temp-table
                            w-crapris (Adriano).             

               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
                                                 
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps280"
       glb_cdcritic = 0
       glb_dscritic = "".

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

RUN STORED-PROCEDURE pc_crps280 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INTE(STRING(glb_flgresta,"1/0")),
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

CLOSE STORED-PROCEDURE pc_crps280 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps280.pr_cdcritic WHEN pc_crps280.pr_cdcritic <> ?
       glb_dscritic = pc_crps280.pr_dscritic WHEN pc_crps280.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps280.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps280.pr_infimsol = 1 THEN
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

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS280.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                  
RUN fontes/fimprg.p.

/* .......................................................................... */

