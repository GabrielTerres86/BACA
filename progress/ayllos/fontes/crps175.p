/*** Magui = cuidado, programa precisa ser revisto se voltar a ser possivel
             cadastrar novas aplicacoes RDCA60. Nao calcura provisao para
             novas aplicacoes. ***/
/* ..........................................................................

   Programa: Fontes/crps175.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/96.                    Ultima atualizacao: 06/06/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Solicitacao: 003.
               Calcular o rendimento mensal e liquido das aplicacoes RDCA2
               e listar o resumo mensal.
               Ordem do programa na solicitacao: 4
               Relatorio 138 e 560.

   Alteracoes: 17/02/98 - Alterado para guardar no crapcot o valor abonado
                          (Deborah).

               03/03/98 - Acerto na alteracao anterior (Deborah).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               26/01/99 - Tratar IOF e abono (Deborah).

               07/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               16/03/2000 - Atualizar crapcot.vlrentot (Deborah).

               29/04/2002 - Nova maneira de pegar a taxa (Margarete). 

               15/12/2003 - Incluir total de IRRF (Margarete).

               28/01/2004 - Nao atualizar campos de abono da cpmf (Margarete).
               
               19/04/2004 - Atualizar novos campos craprda (Margarete).
               
               24/05/2004 - Listar base de cpmf a recuperar (Margarete).
               
               05/07/2004 - Quando saque na carencia atualizacao vlslfmes
                            errada (Margarete).

               22/09/2004 - Incluidos historicos 494/495(CI)(Mirtes)

               07/10/2004 - Quando saque total nao esta zerando saldo
                            do final do mes (Margarete).

              16/12/2004 - Incluido historico 876(Ajuste IR)(Mirtes)
              
              28/12/2004 - Alinhados os campos no relatorio (Evandro).         
                   
              01/09/2005 - Tratar leitura do craprda (Margarete).

              07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                           "fontes/iniprg.p" por causa da "glb_cdcooper"
                           (Evandro).
                           
              15/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
               
              26/07/2006 - Campo vlslfmes passa a ser vlsdextr. E o
                            vlslfmes passa a ser o valor exato da poupanca
                            na contabilidade no ultimo dia do mes (Magui).

              28/11/2006 - Melhoria de performance (Evandro).

              11/07/2007 - Incluido na leitura do craplap para emissao do
                           relatorio os historicos possiveis (Magui).

              03/12/2007 - Substituir chamada da include rdca2s pela
                           b1wgen0004a.i (Sidnei - Precise).

              10/12/2008 - Utilizar procedure "acumula_aplicacoes" (David).
              
              11/05/2010 - Incluido relatorio crrl560 - Relacao Detalhada das 
                           Aplicacoes (Elton).
                           
              26/08/2010 - Inserir na crapprb a somatoria das aplicacoes.
                           Tarefa 34647 (Henrique).

*** Nao esquecer mais: campo vlsdextr criado para os extratos trimestrais.
                       O valor ali nao confere 100% com os da contabilidade. 
                       Porque se a aplicacao estiver em carencia nao pode ter
                       rendimento ainda.

              26/11/2010 - Retirar da sol 3 ordem 7 e colocar na sol 83
                           ordem 4.E na CECRED sol 83 e ordem 5 (Magui).
                           
              26/01/2011 - Alimentar crapprb por nrdconta do cooperado
                           (Guilherme)                           
                           
              13/01/2012 - Melhorar desempenho (Gabriel).
              
              25/07/2012 - Ajustes para Oracle (Evandro).
                          
              06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps175"
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

RUN STORED-PROCEDURE pc_crps175 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps175 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps175.pr_cdcritic WHEN pc_crps175.pr_cdcritic <> ?
       glb_dscritic = pc_crps175.pr_dscritic WHEN pc_crps175.pr_dscritic <> ?
       glb_stprogra = IF pc_crps175.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps175.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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
