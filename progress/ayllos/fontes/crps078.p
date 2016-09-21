/* ..........................................................................

   Programa: Fontes/crps078.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Janeiro/94.                     Ultima atualizacao: 23/07/2013
             
   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 41.
               Calculo mensal dos juros sobre emprestimos.

   Alteracoes: 23/06/94 - Alterado para permitir utilizar a taxa do mes na li-
                          quidacao do emprestimo (Edson).

               17/10/94 - Alterado para inclusao de novos parametros para as
                          linhas de credito: taxa minima e maxima e o indica-
                          dor de linha com saldo devedor.

               03/03/95 - Alterado para inclusao de novos campos no craplem:
                          dtpagemp e txjurepr (Edson).

               14/03/95 - Alterado para pegar a moeda fixa do proximo movimento
                          (Odair).

               11/09/95 - Altera inliquid para 1 quando vlsdeved for igual a 0
                          (Edson).

               12/06/96 - Alterado para tratar o controle de emprestimos em
                          atraso (Edson).

               04/10/96 - Atualizar o campo crapepr.indpagto com 0 (Odair).

               19/11/96 - Alterar a mascara do campo nrctremp (Odair).

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/04/2000 - Alterado o calculo dos meses decorridos para 
                            emprestimos vinculados a c/c (Deborah).

               04/12/2000 - Tratar o ano no calculo dos meses decorridos 
                            (Edson).

               02/06/2001 - Ajustes para tratar contratos em prejuizo
                            (Deborah).

               27/02/2002 - Alterar calculo do qtprecal (Margarete).

               15/07/2002 - Alterar dtdpagto quando contrato novo (Margarete).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               17/04/2003 - Incluir criacao do crapmcr (Margarete).

               03/01/2005 - Quando qtprecal negativo mover zeros (Margarete).

               28/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplem, craplcm e crapmcr (Diego).
                            
               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.   
                         
               12/07/2007 - Quando emprestimo for liquidado e vinculado a folha
                            ver se ha algum crapavs em aberto(Guilherme).
                             
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               01/06/2009 - Aumentar arrays para 999 (Magui).
               
               11/12/2009 - Desativar ratings quando emprestimo liquidado.
                            Retirar comentarios desnecessarios.
                            (Gabriel).
                             
               26/03/2010 - Quando finalizacao do epr utilizar crapepr.dtultpag
                            em crapmcr.dtdbaixa (Magui).
                            
               01/03/2012 - Tratar so os emprestimos do tipo Price TR 
                            (Gabriel)           
                            
               17/01/2013 - Tratamento para armazenar novo campo
                            crapepr.flliqmen (Lucas R.)
                            
               04/03/2013 - Incluso verificacao para nao emitir a critica
                            "ATENCAO: Contrato NAO microfilmado" no caso de
                             cooperativa migrada (Daniel). 
                            
               23/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps078"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps078 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    INPUT glb_cdoperad,
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

CLOSE STORED-PROCEDURE pc_crps078 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps078.pr_cdcritic WHEN pc_crps078.pr_cdcritic <> ?
       glb_dscritic = pc_crps078.pr_dscritic WHEN pc_crps078.pr_dscritic <> ?
       glb_stprogra = IF pc_crps078.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps078.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
      
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