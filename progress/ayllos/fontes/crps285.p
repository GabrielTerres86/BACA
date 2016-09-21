/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps285.p                | pc_crps285                        |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - DANIEL ZIMMERMANN    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* ..........................................................................

   Programa: Fontes/crps285.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/2000.                     Ultima atualizacao: 05/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de tarifas Cheque Admin, Debito Conta.
                
   Alteracoes: 24/05/2002 - Alterado para tratar o historico 103 (DOC D).
                            Liberado a partir de 01/06/2002 (Edson).

               25/10/2002 - Alterado para tratar historicos 555 e 503 (TEDs)
                            a partir de 24/10/2002 (Deborah).

               01/11/2002 - Tratar tarifa de pre-deposito (Deborah).

               20/12/2002 - Tratar tarifa de cheque administrativo (Deborah).
               
               03/02/2003 - Acrescentar 2 digitos no PreDeposito (Ze Eduardo)
               
              31/03/2003 - Incluir o historico 153 da Comp da Concredi(Deborah)  
              12/04/2004 - Alterado p/obter tarifas tab.VLTARIFDIV(Mirtes)

              30/06/2005 - Alimentado campo cdcooper das tabelas craplot e 
                           craplcm (Diego).

              10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

              16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.  
              
              09/06/2008 - Incluído o mecanismo de pesquisa no "for each" na 
                           tabela CRAPHIS para buscar primeiro pela chave de
                           acesso (craphis.cdcooper = glb_cdcooper). 
                           - Kbase IT Solutions - Paulo Ricardo Maciel.
                           
              11/12/2008 - Isentar tarifa para Pessoa Fisica (Diego).
               
              08/01/2010 - Acrescentar historicos 469 e 572 na variavel
                           aux_lshistor (Guilherme/Precise)

              02/03/2010 - Alterar historicos 469 para 524 (Guilherme/Precise).
              
              08/07/2011 - Nao efetuar os lancamentos de doc/ted aqui.
                           Efetuar eles na rotina 20 do caixa Online (Gabriel).
                           
              22/11/2012 - Inclusao de tratamento de registro duplicado (Diego).
              
              19/03/2013 - Ajustes do Projeto de tarifas fase 2 - Grupo de 
                           Cheque (Lucas R.).
                           
              24/07/2013 - Alterado tratamento tarifa SPB "Pre-deposito" para
                           utilizar rotinas da b1wgen0153.p (Daniel)    
                           
              21/08/2013 - Alterado parametro dtmvtolt no lancamento tarifa (Daniel).    
                           
              11/10/2013 - Incluido parametro cdprogra nas procedures da 
                           b1wgen0153 que carregam dados de tarifas (Tiago).
                           
              20/01/2014 - Incluir VALIDATE craplcm, craplot (Lucas R.)
              
              12/02/2014 - Retirado "Return" quando havia chamada da b1wgen0153
                           e não devia abortar a execucao do programa (Tiago).
                           
              05/03/2015 - Conversão Progress >> Oracle PL-Sql (Daniel).             
............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps285"
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

RUN STORED-PROCEDURE pc_crps285 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps285 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps285.pr_cdcritic WHEN pc_crps285.pr_cdcritic <> ?
       glb_dscritic = pc_crps285.pr_dscritic WHEN pc_crps285.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps285.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps285.pr_infimsol = 1 THEN
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


