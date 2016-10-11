/* ..........................................................................

   Programa: Fontes/crps290.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson        
   Data    : Maio/2000.                      Ultima atualizacao: 30/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 5.
               Efetuar os lancamentos automaticos no sistema de cheques em
               custodia e titulos compensaveis.
               Emite relatorio 238.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

   Alteracoes: 23/10/2000 - Desmembrar a critica 95 conforme a situacao do 
                            titular (Eduardo).

               17/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               08/10/2003 - Atualizar craplcm.dtrefere (Margarete). 

               30/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm e craprej (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               16/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
               
               02/11/2005 - Uso da procedure digbbx.p para conversao de campo
                            inteiro para caracter (SQLWorks - Andre).
                            
               11/11/2005 - Acertar leitura do crapfdc (Magui).       
                     
               10/12/2005 - Atualizar craprej.nrdctitg (Magui).
                     
               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.       
                 
               13/02/2007 - Alterar consultas com indice crapfdc1 (David).
                 
               07/03/2007 - Ajustes para o Bancoob (Magui).

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               17/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               24/10/2012 - Tratamento para os cheques das contas migradas
                            (Viacredi -> Alto Vale), realizado na procedure 
                            proc_trata_custodia. (Fabricio)
                            
               23/01/2013 - Criar de rejeicao para as criticas 680 e 681 apos
                            leitura da craplot (David).
                            
               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)
                            
               20/01/2014 - Efetuada correção na leitura da tabela craptco da 
                            procedure 'proc_trata_custodia' (Diego).           
               
               24/01/2014 - Incluir VALIDATE craplot, craplcm, craprej (Lucas R)
                            Incluido 'RELEASE craptco' para garantir que o 
                            programa nao pegue um registro lido anteriormente.
                            (Fabricio)
                            
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               28/09/2015 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).
                            
               30/05/2016 - Incluir criticas 251, 695, 410, 95 no relatorio e
                            atualizar o insitlau para 3(Cancelado) (Lucas Ranghetti #449799)
............................................................................. */

{ includes/var_batch.i} 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "CRPS290"
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

RUN STORED-PROCEDURE pc_crps290 aux_handproc = PROC-HANDLE
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
        
CLOSE STORED-PROCEDURE pc_crps290 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps290.pr_cdcritic WHEN pc_crps290.pr_cdcritic <> ?
       glb_dscritic = pc_crps290.pr_dscritic WHEN pc_crps290.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps290.pr_stprogra = 1 THEN
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps290.pr_infimsol = 1 THEN
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