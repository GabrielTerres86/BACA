/* ............................................................................

   Programa: Fontes/crps310.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Margarete
   Data    : Maio/2001                       Ultima atualizacao: 07/06/2013
   
   Dados referentes ao programa:

   Frequencia: Mensal
   Objetivo  : Gerar arquivo com saldo devedor dos emprestimos - Risco.
               
   Alteracoes: 20/08/2001 - Tratar pagamentos dos prejuizos (Margarete).
    
               09/11/2001 - Alterar forma dos 12 meses ou mais (Margarete).
                
               02/01/2002 - Corrigir prejuizo no mesmo mes (Margarete).
                 
               14/06/2002 - Incluir prejuizo a +48 meses (Margarete).   

               13/05/2003 - Desprezar os contratos em prejuizo que nao tenham
                            mais saldo (Deborah).

               16/06/2003 - Eliminar if do CL (Margarete).

               30/07/2003 - Tratar o desconto de cheques e o restart (Edson).
               
               12/08/2003 - Nao considerar bloqueado como disponivel (Deborah).

               08/09/2003 - Novo tratamento do risco para o desconto de cheques
                            (Edson).

               04/11/2003 - Substituido comando QUIT pelo RETURN(Mirtes)

               05/11/2003 - Gerar informacoes(inddocto = 1) Arq.3020(Mirtes)

               02/12/2003 - Diminuir 1 do campo mes decorrido , se vencimento
                            do contrato cair apos final de mes - dia nao util
                            (Mirtes).

               27/02/2004 - Novo calculo do risco para os cheques descontados
                            (Edson).

               19/04/2004 - Alterado para assumir menor risco(Arrasto)
                            (Somente p/3020/3010)(Mirtes)
              
               03/05/2004 - Utilizar (novo) campo data credito liquicao risco
                            (Substituido campo crapsld.dtdsdclq pelo
                             campo crapsld.dtrisclq)(Mirtes)

               07/06/2004 - Gravar risco calculado nos contratos(Mirtes)

               08/10/2004 - Assumir risco inicial do Rating(se existir)(Mirtes)
               
               05/05/2005 - Atualizar nivel de risco/recalculo data atraso
                            quando CL(Mirtes) 

               25/05/2005 - Atualizar campo dsnivris na tabela crapass(CORVU)
                            e atualizado campo cooperativa tab.crapris
                            e tab.crapvri (Mirtes)

               12/08/2005 - Qdo contrato em prejuizo - obrigatorio o risco H
                            no docto 3010(Mirtes)
               
               15/09/2005 - Docto 3010 - prejuizo = risco H(Mirtes) 
                          
               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               11/01/2006 - Alterado nivel risco(assumir menor) quando em 
                            dia(Mirtes)
               02/02/2006 - Assumir risco do rating quando atraso(Mirtes)
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               20/04/2007 - Substituir craptab "LIMCHEQESP" pelo craplrt (Ze).
               
               11/05/2007 - Enxergar os abonos do prejuizo (Magui).
               
               02/09/2008 - Alterado para chamar includes/crps310.i (Diego).
               
               27/10/2008 - Controlar prejuizo a +48M (Magui).
               
               07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
               
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps310"
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

RUN STORED-PROCEDURE pc_crps310 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps310 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps310.pr_cdcritic WHEN pc_crps310.pr_cdcritic <> ?
       glb_dscritic = pc_crps310.pr_dscritic WHEN pc_crps310.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps310.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps310.pr_infimsol = 1 THEN
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

