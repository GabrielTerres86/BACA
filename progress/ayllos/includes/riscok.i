/* .............................................................................
   Programa: Includes/riscok.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Novembro/2003                   Ultima Alteracao: 14/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar Arq. Contabilizacao Provisao
               (Relatorio 321)

   Alteracao : 03/08/2005 - Lancamento Contabil (provisao) deve ocorrer em
                            dia util(Mirtes)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               01/06/2006 - Desenvolver o Gerencial a Credito e a Debito (Ze).

               11/07/2006 - Acerto nas contas contabeis para a CENTRAL (Ze).

               14/07/2006 - Acrescentar lancamentos no Gerencial (Ze).

               07/08/2006 - Acerto no lancamento Gerencial (Ze).

               01/09/2008 - Alteracao cdempres (Kbase IT).

               20/10/2008 - Incluir prejuizo a +48M ate 60M (Magui).

               04/12/2008 - Tratamento para desconto de titulos somando com o
                            desconto de cheques (Evandro).

               19/01/2010 - Quando cooperado tiver vencidas, considerar
                            as a vencer tambem vencidas (Magui)

               21/01/2010 - Criacao de log para verificar a data e o usuario
                            que executou essa funcao (GATI - Daniel)

               26/07/2010 - Reversao da receita de juros de emprestimo com mais
                            de 60 dias de atraso (Guilherme).

               25/08/2010 - Feito tratamento, Emprestimos/Financiamentos
                            (Adriano).

               01/09/2010 - Na reversao de epr 60d atraso, lancar registros
                            quebrados por PAC (Guilherme).

               05/10/2010 - Corrigido arquivo do risco para a contabilidade.
                            Estava sendo lancado o valor da divida ao inves
                            da provisao (Adriano).

               03/03/2011 - Tratar Cliente Relevante (Guilherme).

               21/03/2011 - Detalhar com 1633 no gerencial (Magui).

               21/09/2011 - Tratado a modalidade de 499 - financiamento
                            para ser incluida no arquivo para a contabilidade
                            (Adriano).

               30/09/2011 - Ajuste data limite para calculo do acumulado
                            (juros de emprestimos e financiamentos) (Irlan)

               13/04/2012 - Alteraçao da descriçao do arquivo gerado atraves da
                            tela risco. (David Kruger).

               04/06/2012 - Ajuste do resultado da provisao (Gabriel).

               08/10/2012 - Ajuste na leitura dos títulos descontados da
                            cob. registrada (cdorigem = 5) (Rafael).

               15/10/2012 - Tratar conta contabil para a Cecred (Gabriel)

               05/12/2012 - Ajuste para gerar arquivo _2 das contas migradas em
                            01/01/2013. Arquivo com data-base 31/12/2012
                            (Tiago/Irlan)

               05/12/2012 - Ajuste no juros para que nao
                            ultrapasse o valor da divida (Tiago).

               03/01/2013 - Alterado tratamente da procedure
                            verifica_conta_altovale para listar somente as contas
                            ja existentes antes da migracao quando periodo
                            for ate 31/12/2013. (Irlan)

               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).

               21/02/2013 - Incluso procedure calcula_juros_60k para eliminar a
                            repetiçao de código (Daniel)

               10/04/2013 - Retirar codigo repetido (Gabriel).

               06/07/2013 - 2a. fase Projeto Credito (Gabriel).

               07/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)

               05/12/2013 - Inserido tratamento para migracao da Acredicop
                            na procedure verifica_conta_altovale e modificado
                            nome para verifica_conta_migracao (Tiago).

               17/12/2013 - Inserido PAs da migracao na condicao da craptco
                            na procedure verifica_conta_migracao (Tiago).

               05/03/2014 - Adicionada variavel aux_nrmxpari para contador de
                            PAs da crapris. (Reinert)

               05/10/2014   - verifica_conta_migracao na qual deve ser incluído
                              tratamento para não incluir no arquivo gerado as contas incorporadas pela
                              Viacredi (1) e Scrcred (13).(Felipe)


               20/10/2014 - Nova regra quanto ao Saldo Bloqueado liberado ao Cooperado,
                            pois a partir de agora esta informaçao será incorporada ao
                            mesmo risco do Adiantamento a Depositante (AD).
                            Alteramos a rotina para listar apenas divida e reversao
                            do Saldo Bloqueado e nao trazer mais provisao do mesmo
                            haja visto que a provisao esta no AD. (Marcos-Supero)

               09/03/2015 - Projeto RISCO - Tratamento para inclusao do Valor
                            Limite Nao Utilizado PF e PJ -> inddocto = 3
                            (Guilherme/SUPERO)

               14/03/2015 - Projeto 186 - Segregacao PF/PJ e
                            Chamada da PC_RISCO_K do ORACLE
                            (Guilherme/SUPERO)
............................................................................. */


DEF VAR aux_dscritic AS CHAR                                       NO-UNDO.


{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_risco_k
    aux_handproc = PROC-HANDLE NO-ERROR
                     (INPUT glb_cdcooper,
                      INPUT STRING(tel_dtrefere,"99/99/9999"),
                      OUTPUT "",
                      OUTPUT "").

CLOSE STORED-PROC pc_risco_k
      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN aux_nmarqsai = ""
       aux_dscritic = "".

ASSIGN aux_nmarqsai = pc_risco_k.pr_retfile
                      WHEN pc_risco_k.pr_retfile <> ?.
ASSIGN aux_dscritic = pc_risco_k.pr_dscritic
                      WHEN pc_risco_k.pr_dscritic <> ?.

IF  aux_dscritic <> ""  THEN DO:
    BELL.
    MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
END.

HIDE MESSAGE NO-PAUSE.


/***** Leitura do crapris para reversao da receita de juros de emprestimo com
       mais de 60 dias de atraso (Guilherme)  *****/
DEF VAR aux_vldjuros  AS DECI                 NO-UNDO.
DEF VAR aux_finjuros  AS DECI                 NO-UNDO.
DEF VAR aux_vldjuros2 AS DECI                 NO-UNDO.
DEF VAR aux_finjuros2 AS DECI                 NO-UNDO.

DEF VAR aux_diascalc AS INTE                 NO-UNDO.
DEF VAR aux_diasmais AS INTE                 NO-UNDO.
DEF VAR aux_dtinicio AS DATE INIT 08/01/2010 NO-UNDO.
DEF VAR aux_dtini499 AS DATE INIT 10/01/2011 NO-UNDO.
DEF VAR aux_dtmovime AS DATE                 NO-UNDO.
DEF VAR con_dtmovime AS CHAR                 NO-UNDO.
DEF VAR aux_vljurctr AS DECI                 NO-UNDO.

/*

   ***********   O RELATÓRIO SERÁ GERADO TAMBÉM PELA ROTINA ORACLE   ***********
  
ASSIGN aux_nmarqres = "rl/crrl321.lst".  /* Resumo */

ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 321.

{ includes/cabrel234_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqres) PAGED PAGE-SIZE 62.
VIEW STREAM str_1 FRAME f_cabrel234_1.

 /*-  Lista  Contas Contabilzacao (risco.lst ) --*/
 DO aux_contador = 1 TO 27:
     
     IF  aux_contador <> 20 AND aux_contador <> 21
     AND aux_contador <> 23 AND aux_contador <> 26 THEN
     DO:
         DISPLAY   STREAM str_1
                   aux_nrcctab[aux_contador]
                   aux_vldevedo[aux_contador]
                   aux_vldespes[aux_contador]
                   WITH FRAME f_conta.
         DOWN WITH FRAME f_conta.
     END.

    IF aux_contador = 21 THEN
       DO:
            aux_vldevedo[aux_contador] = aux_vldevedo[aux_contador] + aux_vldevedo[20].
            aux_vldespes[aux_contador] = aux_vldespes[aux_contador] + aux_vldespes[20].

            DISPLAY   STREAM str_1
               aux_nrcctab[aux_contador]
               aux_vldevedo[aux_contador]
               aux_vldespes[aux_contador]
               WITH FRAME f_conta.
            DOWN WITH FRAME f_conta.

       END.

     IF  aux_contador = 16 THEN DO:  /* Listar Totais Contas Risco */

         /** Risco - Limite Nao utilizado PJ - Nao totaliza "Contab." */
         DISPLAY STREAM str_1
                        aux_nrcctab[28] @ aux_nrcctab[aux_contador]
                        aux_vllmtepj    @ aux_vldevedo[aux_contador]
                        0               @ aux_vldespes[aux_contador]
             WITH FRAME f_conta.
         DOWN WITH FRAME f_conta.

         /** Risco - Limite Nao utilizado PF - Nao totaliza "Contab." */
         DISPLAY STREAM str_1
                        aux_nrcctab[29] @ aux_nrcctab[aux_contador]
                        aux_vllmtepf    @ aux_vldevedo[aux_contador]
                        0               @ aux_vldespes[aux_contador]
             WITH FRAME f_conta.
         DOWN WITH FRAME f_conta.



         DISPLAY   STREAM str_1
                     "Total Lancto Risco " @  aux_nrcctab[aux_contador]
                     " "                   @  aux_vldevedo[aux_contador]
                     aux_ttlanmto_risco    @  aux_vldespes[aux_contador]
                     WITH FRAME f_conta.
            DOWN WITH FRAME f_conta.
         END.

    IF  aux_contador = 22 THEN   /* Listar Totais Conta Provisao  */
         DO:
            DISPLAY   STREAM str_1
                     "Total Lancto Prov. " @  aux_nrcctab[aux_contador]
                     " "                   @  aux_vldevedo[aux_contador]
                     aux_ttlanmto          @  aux_vldespes[aux_contador]
                     WITH FRAME f_conta.
            DOWN WITH FRAME f_conta.
         END.
 END.

DISPLAY STREAM str_1          /* Lista Totais Contas - Dividas */
               "Total Lancto CONTA " @  aux_nrcctab[aux_contador]
               aux_ttlanmto_divida   @   aux_vldevedo[aux_contador]
               " " @   aux_vldespes[aux_contador]
         WITH FRAME f_conta.
DOWN WITH FRAME f_conta.


OUTPUT STREAM str_1 CLOSE.


FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.


UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                  " " + STRING(TIME,"HH:MM:SS") + "' --> '" +
                  "Operador " + glb_cdoperad +
                  " executou a funçao K - Contabilizacao" +
                  " >> log/risco.log").

DISP aux_nmarqsai WITH FRAME f_contabiliza.

PAUSE 6 NO-MESSAGE.


*/
