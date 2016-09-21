/* ..........................................................................

   Programa: Fontes/crps312.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Margarete
   Data    : Junho/2001.                     Ultima atualizacao: 20/01/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 41. Ordem = 3.
               Calculo mensal dos juros sobre prejuizos de emprestimos.
               Relatorio 264.

   Alteracoes: 22/08/2001 - Tratar pagamentos dos prejuizos (Margarete).
   
               09/11/2001 - Alterar forma de 12 meses ou mais (Margarete).

               02/01/2002 - Corrigir prejuizo no mesmo mes (Margarete).
                 
               06/06/2002 - Erro de quebra (Margarete).  

               17/06/2002 - Incluir prejuizo a +48 meses (Margarete).

               01/08/2003 - Prejuizo para o Pac onde o associado
                            tem conta (Margarete).

               15/03/2004 - Considerar os abonos concedidos (Margarete).
               
               03/05/2005 - Alterado numero de copias para impressao na
                            Viacredi;
                            Alimentar o campo cdcooper das tabelas (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               25/07/2006 - Alterado numero de copias do relatorio 264 para    
                            Viacredi (Elton).   
                                      
               03/08/2006 - Incluida relacao de contas com contrato em prejuizo
                            a mais de 48 meses (Diego).
               
               08/12/2006 - Alterado para 3 o numero de copias do relatorio 264
                            para Viacredi (Elton).
                            
               13/12/2006 - Valores pagos tira o abono (Magui).
               
               15/12/2006 - Incluida relacao de contas em prejuizo abertas
                            durante o mes atual (Elton).

               25/01/2007 - Alterado formato dos campos do tipo DATE de
                            "99/99/99" para "99/99/9999" (Elton). 

               06/11/2008 - Alterado formato dos campos total geral e total 
                            pac para evitar estouro (Gabriel) .
                            
               18/02/2010 - Incluir linha de credito no relatorio (David).
               
               15/04/2010 - Alterado para garar arquivo txt para importacao
                            excel, grava-lo no diretorio salvar e envia-lo
                            por email (Sandro-GATI).
                            
              01/06/2010 - Alteração do campo "pkzip25" para "zipcecred.pl" 
                           (Vitor).             
               
              15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                           leitura e gravacao dos arquivos (Elton).
                           
              28/12/2010 - Inclusao da coluna "Data Primeiro Pagamento"
                           (Adriano).
                                                      
              18/02/2011 - Alterado o formato da data dos campos
                           crapepr.dtprejuz e crapepr.dtdpagto.
                           De:"99/99/99" Para: "99/99/9999". (Fabricio)
                           
              08/04/2011 - Retirado os pontos dos campos numéricos e decimais
                           que são exportados para o arquivo crrl264.txt.
                           (Isara - RKAM)
                           
              19/10/2011 - Disponibilizar arquivo crrl264.txt para 
                           Acredicoop(Mirtes)
                           
              03/10/2012 - Disponibilizar arquivo crrl264.txt para
                           Alto Vale (David Kruger).
                           
              10/06/2013 - Alteração função enviar_email_completo para
                           nova versão (Jean Michel).
              
              15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                 
              03/09/2013 - Atualizar o saldo prejuizo na tabela crapcyb. (James)
              
              28/10/2013 - Ajuste para não atualizar o saldo prejuizo na tabela
                           crapcyb. (James)
                           
              20/01/2014 - Incluir VALIDATE craplot, craplem (Lucas R.)
              
              16/04/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Andre Santos - SUPERO)

............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps312"
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

RUN STORED-PROCEDURE pc_crps312 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps312 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps312.pr_cdcritic WHEN pc_crps312.pr_cdcritic <> ?
       glb_dscritic = pc_crps312.pr_dscritic WHEN pc_crps312.pr_dscritic <> ?
       glb_stprogra = IF pc_crps312.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps312.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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