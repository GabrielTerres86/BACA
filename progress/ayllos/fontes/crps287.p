/* ..........................................................................

   Programa: Fontes/crps287.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair 
   Data    : Maio/2000.                      Ultima atualizacao: 27/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Liberar cheques em custodia.
               Emite relatorio 234.

   Alteracoes: 17/05/2000 - Alterado para emitir resumo contabil (Edson).
   
               23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               06/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               07/06/2001 - Alterado para tratar tabela de custodia
                            (CRED-CUSTOD-00-nnnnnnnnnn-000) - Edson.

               10/07/2001 - Alterado para associar o cheque em custodia ao 
                            deposito efetuado (Edson).
 
               21/05/2002 - Permitir qualquer dia para custodia(Margarete).
               
               25/06/2002 - Quando segunda-feira saldo anterior nao sai 
                            correto (Margarete).

               28/10/2003 - Retirado use-index crapcst(Mirtes)

               30/10/2003 - Incluidas as informacoes referentes a desconto de
                            cheques. Substituicao da utilizacao do craprej por
                            uma TEMP-TABLE "crawtot" (Julio).
                             
               09/06/2004 - Incluido Total Cheques Comp (Evandro).

               29/06/2004 - Ajuste na rotina do saldo contabil (Edson).

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            craplcm e crapdpb (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               11/03/2008 - Incluir "(CONTA BLOQUEADA)" nos casos de critica 95
                            e nao cancelar o programa (Evandro).
               
               19/08/2008 - Tratar pracas de compensacao (Magui).
               
               14/10/2009 - Reestruturacao do programa para o CAF (Guilherme).
               
               01/03/2010 - Alterado descricao da critica no log da procedure 
                            calcula_bloqueio_cheque (Elton).
                            
               17/03/2010 - Acerto na geracao da crawtot (David).
               
               22/03/2010 - Acerto no incremento para numero de documento
                            da crapdpb (David).
               
               15/06/2010 - Tratar nossa IF (Magui).
               
               01/12/2010 - Alteracao de Format (Kbase/Willian).
                            001 - Alterado para 50 posições, valor anterior 40.
               
               27/07/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               27/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps287"
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

RUN STORED-PROCEDURE pc_crps287 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps287 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps287.pr_cdcritic WHEN pc_crps287.pr_cdcritic <> ?
       glb_dscritic = pc_crps287.pr_dscritic WHEN pc_crps287.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps287.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps287.pr_infimsol = 1 THEN
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

/* ......................................................................... */     

