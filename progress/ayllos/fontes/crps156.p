/* .............................................................................

   Programa: Fontes/crps156.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                       Ultima atualizacao: 04/05/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Solicitacao: 005 (Finalizacao do processo).
               Efetuar o resgate das poupancas programas e credita-los em conta-
               corrente.
               Emite relatorio 125.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               21/05/1999 - Consistir se a aplicacao esta bloqueada (Deborah).

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).  
               
               01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               21/08/2001 - Tratamento do saldo antecipado. (Ze Eduardo).

               09/02/2004 - Se resgate total zerar vlabcpmf (Margarete).
               
               12/05/2004 - Quando resgate parcial e tiver vlabcpmf deixar
                            saldo para pagto do IR no aniversario (Margarete).
                            
               13/08/2004 - Se tem vlabcpmf nao deixar resgatar a parte
                            do abono (Margarete). 

               15/09/2004 - Tratamento Conta Investimento(Mirtes)
               
               09/11/2004 - Aumentado tamanho do campo do numero da aplicacao
                            para 7 posicoes, na leitura da tabela (Evandro).
                            
               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, craplpp, craprej, craplci, crapsli e do
                            buffer crablot (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               29/04/2008 - Apos gerar lancamento na conta investimento passar
                            a situacao da rpp para 5 (resgate por vencimento)
                            (Guilherme).
               
               12/02/2010 - Quando o resgate da poupança for por vencimento da 
                            mesma e estiver bloqueada, dar a critica 828 e 
                            fazer o resgate da poupança(Guilherme).

               14/06/2011 - Tratar poupanca inexistente.
               
               09/10/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                            (Lucas R.)
                            
               16/01/2014 - Inclusao de VALIDATE craplot, craplcm, craplpp, 
                            craprej, crablot, craplci e crapsli (Carlos)
                            
               11/03/2014 - Incluido ordenacao por craplrg.tpresgat no for each
                            craplrg. (Reinert)
                            
               04/05/2015 - Adaptaçao fonte hibrido Progress -> Oracle
                                                      ( Odirlei/AMcom )
                                                      
               
              20/04/2016 - Adicionado validacao rw_craplrg.tpresgat = 2
                           para correçao do chamado 414286. (Kelvin) 
............................................................................. */


{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps156"
       glb_cdcritic = 0.

RUN fontes/iniprg.p.

glb_cdcritic = 0.

IF   glb_cdcritic > 0 THEN
     RETURN.


ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_crps156 aux_handproc = PROC-HANDLE
     (INPUT glb_cdcooper,                                                  
      INPUT INT(STRING(glb_flgresta,"1/0")),
                                         INPUT 0,
      INPUT 0,
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
                      

CLOSE STORED-PROCEDURE pc_crps156 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }


ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps156.pr_cdcritic WHEN pc_crps156.pr_cdcritic <> ?
       glb_dscritic = pc_crps156.pr_dscritic WHEN pc_crps156.pr_dscritic <> ?
       glb_stprogra = IF pc_crps156.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps156.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

