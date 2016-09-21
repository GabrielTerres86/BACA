/* ..........................................................................

   Programa: Fontes/crps230.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Julho/98.                       Ultima atualizacao: 19/04/2011

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 34.
               Acumula dados para CPMF.

   Alteracoes: 27/01/99 - Colocar data final de CPMF (Odair)
   
               09/06/99 - Tratar ass.iniscpmf (Odair).

               28/06/99 - Tratar estorno nas contas da cooperativa (Odair)

               29/06/99 - Colocar nrdocmto < 8000051 para filtrar cheques 
                          salarios emitidos antes do inicio da cpmf e que 
                          foram creditados valores, pois estava dando diferenca
                          na base calculada (Odair)

               12/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).
               
               13/03/2000 - Atualizar novos campos (Odair)
               
               27/03/2000 - Tratar documentos de credito C (DOC C) (Odair)

               25/06/2001 - Tratar nova conta - cheque administrativo (Deborah)
               
               19/04/2002 - Tratar historico 43 - nao estava mandando quando
                            havia cobrado do associado (Deborah)

               31/03/2003 - Incluir c/c Administrativo Concredi (Ze Eduardo).
               
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               12/12/2007 - Incluidos valores do INSS - BANCOOB (Evandro).
               
               09/06/2008 - Incluída a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               13/03/2009 - Desprezar conta 254.137-8 da Biblioteca da
                            Viacredi (Magui).

               25/08/2009 - Nao criticar como conta invalida a conta dos empres-
                            timos com emissao de boletos (Fernando).

               19/10/2009 - Alteracao Codigo Historico (Kbase).                            

               08/03/2010 - Alteracao Historico (Gati)
               
               19/04/2011 - Corrigido valores que nao estavam sendo mostrados
                            devido ao valor ser maior do que o informado 
                            no format (Adriano).
               
............................................................................. */

DEF STREAM str_1.

{ includes/var_batch.i {1}} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps230"
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

RUN STORED-PROCEDURE pc_crps230 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps230 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps230.pr_cdcritic WHEN pc_crps230.pr_cdcritic <> ?
       glb_dscritic = pc_crps230.pr_dscritic WHEN pc_crps230.pr_dscritic <> ?
       glb_stprogra = IF pc_crps230.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps230.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

