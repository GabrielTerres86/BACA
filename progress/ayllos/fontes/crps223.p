/* ............................................................................

   Programa: Fontes/crps223.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/98.                        Ultima atualizacao: 06/06/2013
                                                                            
   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 003.
               Atualizar o rendimento das aplicacoes e da poupanca no CRAPCOT

   Alteracoes: 16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               02/12/2003 - Atualizar campos crapcot para IR (Margarete).

               28/01/2004 - Atualizar campos do abono (Margarete).

               26/05/2004 - Zerar variavel aux_vlirabpp (Margarete).

               16/12/2004 - Incluidos hist. 875/877/876(Ajuste IR)(Mirtes)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               09/02/2007 - Alterada para a solicitacao 73. Deve rodar depois
                            que rodaram todos os programas de aplicacao.
                            Nao esquecer que o crps104, aniversario do rdca30
                            roda com glb_dtmvtolt entao esse programa deve 
                            rodar depois disso (Magui).

               02/03/2007 - Rodar fimprg(meses iguais)(Mirtes).
               
               19/06/2007 - Incluidos historicos 475, 476, 532 e 533 referente
                            aos campos crapcot.vlirfrdc e crapcot.vlrenrdc
                            (Elton).
               
               07/02/2008 - Corrigir can-do. Despreza os historicos da segunda
                            linha se a ultima virgula estivesse na primeira 
                            linha (Magui).

               05/02/2009 - Incluir historicos 463, 474, 529 e 531 referentes a
                            provisao e reversao de aplicacoes RDC. Novos campos
                            vlprvrdc, vlrevrdc e vlpvardc (David).
                            
               01/09/2009 - Alterado para sol 41 e ordem 4. Rodava depois
                            do crps011 faltando assim informacoes de
                            dezembro (Magui).
                            
               18/02/2011 - Comentado as linhas que se referem a atualizacao
                            dos seguintes campos: crapcot.vlprvrdc e
                            crapcot.vlrevrdc. (Fabricio - tarefa 38320)
                            
               12/07/2012 - Ajustar alteracao acima pois os historicos dos
                            campos acima estao sendo somandos no campo
                            crapcop.vlirrdca (David).
               
               06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
 ............................................................................ */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps223"
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

RUN STORED-PROCEDURE pc_crps223 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps223 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps223.pr_cdcritic WHEN pc_crps223.pr_cdcritic <> ?
       glb_dscritic = pc_crps223.pr_dscritic WHEN pc_crps223.pr_dscritic <> ?
       glb_stprogra = IF pc_crps223.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps223.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
