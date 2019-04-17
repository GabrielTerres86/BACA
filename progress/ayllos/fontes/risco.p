/* .............................................................................
   Programa: Fontes/risco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete                       Ultima Alteracao: 19/05/2017
   Data    : Junho/2001

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela RISCO.

   Alteracoes: 18/09/2002 - Alteracao somente para operador 1 (Margarete).

               09/04/2003 - Incluir novos campos na tela (Margarete).

               17/11/2003 - Alt. p/para gravar conforme layout Docto 3020,
                            gravando tambem inddocto 0(Docto 3010)
                            Alt. para efetuar Contabilizacao Provisao(Mirtes).

               05/07/2005 - Alimentado campo cdcooper da tabela crapvri e
                            do buffer crabris (Diego).

               12/07/2005- Permitir exclusao da base de dados a informacao da
                           conta 1457 do mes de 06/2005 - CREDCREA(Mirtes)

               03/08/2005 - Lancamento Contabil (provisao) deve ocorrer em
                            dia util(Mirtes)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               08/02/2006 - Incluida opcao "R" para impressao do relatorio
                            227 (Evandro).

               01/06/2006 - Desenvolver o Gerencial a Credito e a Debito (Ze).

               14/07/2006 - Acrescentar lancamentos no Gerencial (Ze).

               01/09/2008 - Alteracao CDEMPRES (Kbase).

               22/10/2008 - Incluir prejuizo a +48M ate 60M (   Magui).

               01/12/2009 - Efetuado acerto para mostrar critica (Diego).

               19/01/2010 - Quando cooperado tiver vencidas, considerar
                            as a vencer tambem vencidas (Magui)

               27/07/2010 - Reversao da receita de juros de emprestimo com mais
                            de 60 dias de atraso - Relatorio (Guilherme).
                          - Alterado cabecalho para utilizar o tipo padrao
                            (Adriano).

               25/08/2010 - Feito tratamento, Emprestimos/Financiamentos
                            (Adriano).

               21/09/2011 - Alterado relatorio 534 para tratar a modalidade
                            499 - Fianciamento (Adriano).

               30/09/2011 - Ajuste data limite para calculo do acumulado
                            (juros de emprestimos e financiamentos) (Irlan)

               04/06/2012 - Calculo dos juros + 60 (Gabriel).

               15/10/2012 - Tratar conta contabil quando Cecred (Gabriel)

               05/12/2012 - Ajuste no juros para que nao
                            ultrapasse o valor da divida (Tiago).

               04/01/2013 - Criada procedure verifica_conta_altovale_risco
                            para desprezar as contas migradas (Tiago).

               04/01/2013 - Incluido condicao (craptco.tpctatrf <> 3) na busca
                            da craptco (Tiago).

               21/02/2013 - Incluso procedure calcula_juros_60 para eliminar a
                            repetiçao de código (Daniel)

               10/04/2013 - Retirar codigo repetido (Gabriel).

               05/07/2013 - 2a. fase projeto Credito (Gabriel)

               07/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)

               05/12/2013 - Alterada procedure verifica_conta_altovale_risco
                            para verifica_conta_migracao_risco que despreza
                            as contas migradas (Tiago).

               10/12/2013 - Ajuste para calcular os valores dos Juros para o
                            novo empréstimo (James).

               17/12/2013 - Inserido PAs da migracao na condicao da craptco
                            na procedure verifica_conta_migracao_risco (Tiago).

               05/02/2014 - Incluir opcao "M" (Migracao) para emitir relatorio
                            com saldo dos emprestimos e financiamentos das
                            contas migradas. (Reinert)

               28/02/2014 - Incluso VALIDATE (Daniel).

               05/03/2014 - Adicionada variavel aux_nrmxpari. (Reinert)

               16/07/2014 - Correçao da procedure normaliza_jurosa60 e alteraçao
                            da procedure calculaJurosEmprestimoPreFixado pra ficar igual
                            ao crrpl227 SD 157528 (Vanessa Klein)

               06/10/2014 - Modificaçao do paramentro de valor inclusao de permissao
                            para numeros negativos.(Felipe)

               17/10/2014 - Inserido tratamento para migracao da
                            Concredi -> Viacredi e Credimilsul -> Scrcred na
                            procedure verifica_conta_migracao_risco. (Jaison)

               20/10/2014 - Declaracao de variaveis para alteracao devido agregacao
                            dos riscos Saldo Bloqueado ao Ad. a Depositante
                            (Marcos-Supero)

               01/12/2014 - Ajustar o tamanho das variaveis de 200 para 999.
                            (James)

               09/12/2014 - Inclusão da temp-table tt-incorporada exibindo o relatorio M
                            com as cooperativas separadas.
                            Mudanças tambem no formulário f_rel_emp_fin para atender a
                            estrutura no novo formato de relatório(Felipe).

               22/01/2015 - Ajuste na procedcure calcula_juros_60 (Tela risco R) para ficar
                            com a mesma logica da tela risco K e do crll227 SD210498 (Vanessa)

               09/03/2015 - Projeto Risco - Incluida novas contas no array de
                            [aux_nrcctab], para Vlr Limite Nao Utilizado PF e PJ
                            (Guilherme/SUPERO)

               14/03/2015 - Projeto 186 - Segregacao PF/PJ
                            Chamada da PC_RISCO do ORACLE
                            (Guilherme/SUPERO)
                            
               07/03/2016 - Projeto 306 - Provisao cartao de credito. (James)
               
               31/12/2016 - Incorporaçao Transulcred -> Transpocred.  (Oscar)

               19/05/2017 - Projeto 408 - Provisao Garantias Prestadas Central > Sing. (Andrei-Mouts)
               
               01/02/2019 - P450 - estória 9050:7. 3040 - Layout Arquivo 3026 (Fabio Adriano- AMcom).
              
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_oracle.i }

DEF      STREAM str_1.
DEF      STREAM str_2.
DEF      STREAM str_3. /* Para impressao */


DEF NEW SHARED VAR tel_dtrefere  AS DATE    FORMAT "99/99/9999"        NO-UNDO.
DEF VAR tel_nrdconta        LIKE crapass.nrdconta                      NO-UNDO.

DEF VAR tel_vlvec30         AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec60         AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec90         AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec180        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec360        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec720        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec1080       AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec1440       AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec1800       AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec5400       AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vlvec9999       AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.

DEF VAR tel_vldiv14         AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv30         AS DEC  FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv60         AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv90         AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv120        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv150        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv180        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv240        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv300        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv360        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv540        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.
DEF VAR tel_vldiv999        AS DECI FORMAT "zzzzz,zz9.99"              NO-UNDO.

DEF VAR tel_vlprjano        AS DECI FORMAT "zzzz,zz9.99"               NO-UNDO.
DEF VAR tel_vlprjaan        AS DECI FORMAT "zzzz,zz9.99"               NO-UNDO.
DEF VAR tel_vlprjant        AS DECI FORMAT "zzzz,zz9.99"               NO-UNDO.

DEF VAR tel_nmprimtl        AS CHAR FORMAT "x(21)"                     NO-UNDO.
DEF VAR tel_innivris        AS INTE FORMAT "z9"                        NO-UNDO.
DEF VAR tel_cdmodali        LIKE crapris.cdmodali                      NO-UNDO.
DEF VAR tel_nrctremp        LIKE crapris.nrctremp                      NO-UNDO.
DEF VAR tel_nrseqctr        LIKE crapris.nrseqctr                      NO-UNDO.
DEF VAR tel_dtinictr        LIKE crapris.dtinictr                      NO-UNDO.

DEF VAR aux_dsacesso        AS CHAR FORMAT "x(10)"                     NO-UNDO.
DEF VAR aux_confirma        AS CHAR FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_contador        AS INTE FORMAT "z9"                        NO-UNDO.
DEF VAR aux_contad02        AS INTE FORMAT "z9"                        NO-UNDO.
DEF VAR aux_cddopcao        AS CHAR                                    NO-UNDO.
DEF VAR aux_dtrefere        AS DATE                                    NO-UNDO.

DEF VAR aux_cdvencto        AS INTE FORMAT "9999" EXTENT 11            NO-UNDO.
DEF VAR aux_vlvencto        AS DECI               EXTENT 11            NO-UNDO.

DEF VAR aux_cdvencid        AS INTE FORMAT "9999" EXTENT 12            NO-UNDO.
DEF VAR aux_vlvencid        AS DECI               EXTENT 12            NO-UNDO.

DEF VAR aux_vlprjano        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR aux_vlprjaan        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR aux_vlprjant        LIKE crapris.vldivida                      NO-UNDO.

DEF VAR aux_vllmtepf        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR aux_vllmtepj        LIKE crapris.vldivida                      NO-UNDO.

DEF VAR aux_vlsrisco        AS DECI FORMAT  "zzzz,zz9.99"              NO-UNDO.
DEF VAR aux_codvenct        AS INTE FORMAT "9999"                      NO-UNDO.
DEF VAR aux_vldivida        AS DECI FORMAT "zzzz,zz9.99"               NO-UNDO.
DEF VAR aux_vldivida_sldblq AS DECI FORMAT "zzzz,zz9.99"               NO-UNDO.

DEF VAR aux_rsvec180        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsvec360        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsvec999        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsdiv060        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsdiv180        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsdiv360        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsdiv999        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsprjano        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsprjaan        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.
DEF VAR aux_rsprjant        AS DECI FORMAT "zzz,zzz,zz9.99-"           NO-UNDO.

DEF VAR tel_ttvec180        LIKE crapris.vlvec180                      NO-UNDO.
DEF VAR tel_ttvec360        LIKE crapris.vlvec360                      NO-UNDO.
DEF VAR tel_ttvec999        LIKE crapris.vlvec999                      NO-UNDO.

/*---- Variaveis include Contabilizacao --*/
DEF VAR rel_dsdrisco        AS CHAR FORMAT "x(02)"    EXTENT 20        NO-UNDO.
DEF VAR rel_percentu        AS DECI FORMAT "zz9.99"   EXTENT 20        NO-UNDO.
DEF VAR rel_vldabase        AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
                                                      EXTENT 20        NO-UNDO.

DEF VAR rel_vldivida        AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
                                                      EXTENT 20        NO-UNDO.
DEF VAR rel_vlprovis        AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
                                                      EXTENT 20        NO-UNDO.
DEF VAR aux_vlprejuz_conta  AS DECI                                    NO-UNDO.
DEF VAR aux_vlpercen        AS DECI FORMAT "zz9.99"                    NO-UNDO.
DEF VAR aux_vlpreatr        AS DECI                                    NO-UNDO.
/*--- Tabela Contabilizacao --*/
DEF VAR aux_vldevedo        AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
                                                      EXTENT 31        NO-UNDO.
DEF VAR aux_nrcctab         AS INTE FORMAT "99999999" EXTENT 29        NO-UNDO.
DEF VAR aux_vldespes        AS DECI FORMAT "zzz,zzz,zzz,zz9.99"
                                                      EXTENT 31        NO-UNDO.
DEF VAR aux_innivris        AS INTE                                    NO-UNDO.



DEF VAR con_dtmvtolt        AS CHAR                                    NO-UNDO.
DEF VAR con_dtmvtopr        AS CHAR                                    NO-UNDO.
DEF VAR aux_nmarqdat        AS CHAR                                    NO-UNDO.
DEF VAR aux_nmarqsai        AS CHAR                                    NO-UNDO.
DEF VAR aux_nmarqres        AS CHAR                                    NO-UNDO.
DEF VAR aux_cdccuage        AS INTE EXTENT 999                         NO-UNDO.
DEF VAR aux_vllanmto        AS DECI                                    NO-UNDO.
DEF VAR aux_linhadet        AS CHAR                                    NO-UNDO.
DEF VAR aux_dtmvtopr        AS DATE                                    NO-UNDO.
DEF VAR aux_nrcctab_c       AS CHAR FORMAT "x(11)"                     NO-UNDO.


DEF VAR aux_ttlanmto        AS DECI FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
DEF VAR aux_ttlanmto_risco  AS DECI FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
DEF VAR aux_ttlanmto_divida AS DECI FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.

DEF VAR aux_dtmvtolt        AS DATE                                    NO-UNDO.
DEF VAR aux_flsoavto        AS LOGI                                    NO-UNDO.
DEF VAR aux_contacon        AS CHAR                                    NO-UNDO.

DEF VAR aux_nrmaxpas        AS INTE                                    NO-UNDO.
DEF VAR aux_nrmxpari        AS INTE                                    NO-UNDO.

DEF VAR tel_tprelato        AS CHAR FORMAT "x(20)" VIEW-AS COMBO-BOX
                                                      INNER-LINES 2    NO-UNDO.

DEF VAR aux_flgescra        AS LOGI                                    NO-UNDO.
DEF VAR aux_dscomand        AS CHAR                                    NO-UNDO.
DEF VAR par_flgfirst        AS LOGI INIT TRUE                          NO-UNDO.
DEF VAR tel_dsimprim        AS CHAR FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel        AS CHAR FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR par_flgcance        AS LOGI                                    NO-UNDO.

DEF VAR rel_nmempres        AS CHAR FORMAT "x(15)"                     NO-UNDO.
DEF VAR rel_nmresemp        AS CHAR FORMAT "x(15)"                     NO-UNDO.
DEF VAR rel_nmrelato        AS CHAR FORMAT "x(40)" EXTENT 5            NO-UNDO.

DEF VAR rel_nrmodulo        AS INTE FORMAT "9"                         NO-UNDO.
DEF VAR rel_nmmodulo        AS CHAR FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]
                                      NO-UNDO.

DEF VAR aux_dtmigrac        AS DATE                                    NO-UNDO.
DEF VAR rel_valr0299        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR rel_jurs0299        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR rel_valr0499        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR rel_jurs0499        LIKE crapris.vldivida                      NO-UNDO.
DEF VAR rel_qtde0299        AS INTE                                    NO-UNDO.
DEF VAR rel_qtde0499        AS INTE                                    NO-UNDO.

DEF VAR h-b1wgen0084        AS HANDLE                                  NO-UNDO.

DEF BUFFER crabris      FOR crapris.
DEF BUFFER crabvri      FOR crapvri.
DEF BUFFER b-crapvri    FOR crapvri.

DEF TEMP-TABLE tt-vencto                                               NO-UNDO
    FIELD cdvencto LIKE crapvri.cdvencto
    FIELD dias     AS INTE.


 DEF TEMP-TABLE tt-incorporada                                        NO-UNDO
   FIELD cdcooper LIKE craptco.cdcooper
   FIELD rel_valr0299       AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
   FIELD rel_qtde0299       AS INTE
   FIELD rel_jurs0299       AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
   FIELD rel_valr0499       AS DECI FORMAT "zzz,zzz,zzz,zz9.99-"
   FIELD rel_qtde0499       AS INTE
   FIELD rel_jurs0499      AS DECI FORMAT "zzz,zzz,zzz,zz9.99-".

FORM
    "SALDO DA CARTEIRA DE EMPRES/FINANC DAS CONTAS MIGRADAS PARA"
    crapcop.nmrescop NO-LABEL
    SKIP(1)
    "DATA DE REFERENCIA:" tel_dtrefere NO-LABEL
    SKIP(1)
    WITH DOWN NO-BOX WIDTH 132 FRAM f_cab_rel_emp_fin.

FORM
   tt-incorporada.rel_valr0299                COLUMN-LABEL "EMPRESTIMO"
   tt-incorporada.rel_qtde0299                COLUMN-LABEL "QTD. EMPRESTIMO"
   tt-incorporada.rel_jurs0299                COLUMN-LABEL "JUROS MAIS60 EMPR."
   tt-incorporada.rel_valr0499                COLUMN-LABEL "FINANCIAMENTO"
   tt-incorporada.rel_qtde0499                COLUMN-LABEL "QTD. FINANCIAMENTO"
   tt-incorporada.rel_jurs0499                COLUMN-LABEL "JUROS MAIS60 FINAN."
    WITH DOWN NO-BOX WIDTH 132 FRAM f_rel_emp_fin.

FORM aux_nrcctab[aux_contador] LABEL "C.CONTAB" FORMAT "9999,9999"  AT 20
     aux_vldevedo[aux_contador] LABEL "VALOR"
     aux_vldespes[aux_contador] LABEL "Contab."
     WITH DOWN NO-BOX WIDTH 132 FRAM f_conta.


 /*  Qualquer alteracao verificar tambem na includes/riscok.i - Ze Eduardo  */
ASSIGN aux_nrcctab[1]  = 33119302   /* Contas para Contabilizacao Provisao */
       aux_nrcctab[2]  = 33219302
       aux_nrcctab[3]  = 33329302
       aux_nrcctab[4]  = 33339302
       aux_nrcctab[5]  = 33429302
       aux_nrcctab[6]  = 33439302
       aux_nrcctab[7]  = 33529302
       aux_nrcctab[8]  = 33539302
       aux_nrcctab[9]  = 33629302
       aux_nrcctab[10] = 33639302
       aux_nrcctab[11] = 33729302
       aux_nrcctab[12] = 33739302
       aux_nrcctab[13] = 33829302
       aux_nrcctab[14] = 33839302
       aux_nrcctab[15] = 33929302
       aux_nrcctab[16] = 33939302.


ASSIGN aux_nrcctab[17] = 84421721  /* Emprestimos Pessoas - Origem 3 */
       aux_nrcctab[18] = 84421723  /* Emprestimos Empresas - Origem 3 */
       aux_nrcctab[19] = 84421724  /* Titulos Descontados - Origem 2 Mod.0302 */
       aux_nrcctab[20] = 84421731  /*Financiamentos Pessoas - Origem 3 */
       aux_nrcctab[21] = 84421731  /*Financiamentos Empresas - Origem 3 */
       aux_nrcctab[22] = 84421722  /* Conta - Origem 1 Mod.0201 Cheque Esp.*/
       aux_nrcctab[23] = 84421722  /* Conta - Origem 1 Mod.0299 Outros Empr.*/
       aux_nrcctab[24] = 84421722. /* Conta - Origem 1 Mod.0101 Adiant.Depos.*/

ASSIGN aux_nrcctab[25] = 16224112  /* Conta - Origem 1 Mod.0201 Cheque Esp.*/
       aux_nrcctab[26] = 16134112  /* Conta - Origem 1 Mod.0299 Outros Empr.*/
       aux_nrcctab[27] = 16114112. /* Conta - Origem 1 Mod.0101 Adiant.Depos.*/

ASSIGN aux_nrcctab[28] = 39879292   /** Conta - Limite Nao Utilizado - PJ **/
       aux_nrcctab[29] = 39889292.  /** Conta - Limite Nao Utilizado - PF **/


ASSIGN aux_cdvencto[1]  =  110
       aux_cdvencto[2]  =  120
       aux_cdvencto[3]  =  130
       aux_cdvencto[4]  =  140
       aux_cdvencto[5]  =  150
       aux_cdvencto[6]  =  160
       aux_cdvencto[7]  =  165
       aux_cdvencto[8]  =  170
       aux_cdvencto[9]  =  175
       aux_cdvencto[10] =  180
       aux_cdvencto[11] =  190.

ASSIGN aux_cdvencid[1]  =  205
       aux_cdvencid[2]  =  210
       aux_cdvencid[3]  =  220
       aux_cdvencid[4]  =  230
       aux_cdvencid[5]  =  240
       aux_cdvencid[6]  =  245
       aux_cdvencid[7]  =  250
       aux_cdvencid[8]  =  255
       aux_cdvencid[9]  =  260
       aux_cdvencid[10] =  270
       aux_cdvencid[11] =  280
       aux_cdvencid[12] =  290.

FORM SKIP (1)
     "Opcao:"         AT 6
     glb_cddopcao     AT 13 NO-LABEL AUTO-RETURN
                      HELP "Informe a opcao desejada (A, C, E, F ,K, I, R, M, T, G ou H)"
                      VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                glb_cddopcao = "E" OR glb_cddopcao = "F" OR
                                glb_cddopcao = "K" OR glb_cddopcao = "I" OR
                                glb_cddopcao = "R" OR glb_cddopcao = "M" OR 
                                glb_cddopcao = "T" OR glb_cddopcao = "G" OR
                                glb_cddopcao = "H",
                                "014 - Opcao errada.")

     "Data Referencia: " AT 18
     tel_dtrefere        NO-LABEL AUTO-RETURN
     "Relat."            AT 48
     tel_tprelato        NO-LABEL
                         HELP "Informe o tipo de relatorio"
     SKIP (1)
     "Conta/DV:"      AT 5
     tel_nrdconta     NO-LABEL AUTO-RETURN
                      HELP "Entre com o numero da conta."
                      VALIDATE (CAN-FIND(crapass WHERE
                                         crapass.cdcooper = glb_cdcooper AND
                                         crapass.nrdconta = tel_nrdconta),
                                "564 - Conta nao cadastrada.")
     tel_nmprimtl     NO-LABEL
     "Nivel de Risco:"
     tel_innivris     NO-LABEL AUTO-RETURN
                      VALIDATE(tel_innivris > 0 AND tel_innivris < 10,
                               "513 - Tipo errado")
     "Modalidade:"    AT 5
     tel_cdmodali     NO-LABEL AUTO-RETURN
     "Contrato/Seq:"
     tel_nrctremp     NO-LABEL AUTO-RETURN

     tel_nrseqctr     NO-LABEL AUTO-RETURN

      "Data:"
     tel_dtinictr     NO-LABEL AUTO-RETURN

     SKIP(1)
     "  Dividas A Vencer Em(Dias)"
     SPACE(13)
     "Vencidas a(Dias)"
     tel_vlvec30    AT 2 AUTO-RETURN
                    LABEL "  30"
                    HELP "Entre com o valor a vencer em 30 dias"
     tel_vlvec60    AUTO-RETURN
                    LABEL "  60"
                    HELP "Entre com o valor a vencer em 60 dias"
     tel_vldiv14    AUTO-RETURN
                    LABEL "  14"
                    HELP "Entre com o valor das dividas vencidas ate 14 dias"
     tel_vldiv30    AUTO-RETURN
                    LABEL "  30"
                    HELP "Entre com o valor das dividas vencidas ate 30 dias"
     tel_vlvec90    AT 2 AUTO-RETURN
                    LABEL "  90"
                    HELP "Entre com o valor a vencer em 90 dias"
     tel_vlvec180   AUTO-RETURN
                    LABEL " 180"
                    HELP "Entre com o valor a vencer em 180 dias"
     tel_vldiv60    AUTO-RETURN
                    LABEL "  60"
                    HELP "Entre com o valor das dividas vencidas ate 60 dias"
     tel_vldiv90    AUTO-RETURN
                    LABEL "  90"
                    HELP "Entre com o valor das dividas vencidas ate 90 dias"
     tel_vlvec360   AT 2 AUTO-RETURN
                    LABEL " 360"
                    HELP "Entre com o valor a vencer em 360 dias"
     tel_vlvec720   AUTO-RETURN
                    LABEL " 720"
                    HELP "Entre com o valor a vencer em 720 dias"
     tel_vldiv120   AUTO-RETURN
                    LABEL " 120"
                    HELP "Entre com o valor das dividas vencidas ate 120 dias"
     tel_vldiv150   AUTO-RETURN
                    LABEL " 150"
                    HELP "Entre com o valor das dividas vencidas ate 150 dias"
     tel_vlvec1080  AT 2 AUTO-RETURN
                    LABEL "1080"
                    HELP "Entre com o valor a vencer em 1080 dias"
     tel_vlvec1440  AUTO-RETURN
                    LABEL "1440"
                    HELP "Entre com o valor a vencer em 1440 dias"
     tel_vldiv180   AUTO-RETURN
                    LABEL " 180"
                    HELP "Entre com o valor das dividas vencidas ate 180 dias"
     tel_vldiv240   AUTO-RETURN
                    LABEL " 240"
                    HELP "Entre com o valor das dividas vencidas ate 240 dias"
     tel_vlvec1800  AT 2 AUTO-RETURN
                    LABEL "1800"
                    HELP "Entre com o valor a vencer em 1800 dias"
     tel_vlvec5400  AUTO-RETURN
                    LABEL "5400"
                    HELP "Entre com o valor a vencer em 5400 dias"
     tel_vldiv300   AUTO-RETURN
                    LABEL " 300"
                    HELP "Entre com o valor das dividas vencidas ate 300 dias"
     tel_vldiv360   AUTO-RETURN
                    LABEL " 360"
                    HELP "Entre com o valor das dividas vencidas ate 360 dias"
     tel_vlvec9999  AT 2 AUTO-RETURN
                    LABEL "9999"
                    HELP "Entre com o valor a vencer acima de 5400 dias"
     tel_vldiv540   AT 40 AUTO-RETURN
                    LABEL " 540"
                    HELP "Entre com o valor das dividas vencidas ate 540 dias"
     tel_vldiv999   AUTO-RETURN
                    LABEL " 999"
                    HELP "Entre com valor dividas vencidas acima de 540 dias"
     SKIP(1)
     " Prejuizo " AT 2
     tel_vlprjano   AUTO-RETURN
                    LABEL "Ate 12M"
                    HELP "Entre com o prejuizo que houve no ano"
     tel_vlprjaan   AUTO-RETURN
                    LABEL "Ate 48M"
         HELP "Entre com o prejuizo que houve a mais de 12 e ate 48 meses"
     tel_vlprjant   AUTO-RETURN
                    LABEL "+48M"
         HELP "Entre com o prejuizo que houve a mais de 48 e ate 60  meses"
       SKIP (1)
     WITH SIDE-LABELS TITLE glb_tldatela
          ROW 4 COLUMN 1 OVERLAY WIDTH 80 FRAME f_risco.

FORM SKIP(1)
     "Digitacao para o mes encerrada"
     SKIP(1)
     WITH NO-LABELS OVERLAY CENTERED ROW 10 FRAME f_encerra.


FORM SKIP(1)
     "Arquivo para Contabilidade Gerado "
     SKIP(1)
     "ATENCAO - Importar arquivos da Contabilidade "
     SKIP (1)
     aux_nmarqsai FORMAT "x(16)"
     WITH NO-LABELS OVERLAY CENTERED ROW 10 FRAME f_contabiliza.

FORM SKIP(1)
     "Arquivo para Contabilidade Gerado "
     SKIP(1)
     aux_nmarqsai FORMAT "x(50)"
     SKIP(1)
     WITH NO-LABELS OVERLAY CENTERED ROW 10 FRAME f_contabiliza_m.


/* variaveis para mostrar a consulta dos lancamentos */
DEF QUERY  bcrapris-q FOR crapris
                      FIELDS(nrdconta vlvec180 vlvec360 vlvec999),
                          crapass
                      FIELDS(nmprimtl).
DEF BROWSE bcrapris-b QUERY bcrapris-q
      DISP crapris.nrdconta                          COLUMN-LABEL "Conta"
           crapass.nmprimtl  FORMAT "x(15)"          COLUMN-LABEL "Titular"
           vlvec180          FORMAT ">>>,>>>,>>9.99" COLUMN-LABEL "Vencer 180d"
           vlvec360          FORMAT ">>>,>>>,>>9.99" COLUMN-LABEL "Vencer 360d"
           vlvec999          FORMAT ">>>,>>>,>>9.99" COLUMN-LABEL "Vencer 999d"
           WITH 8 DOWN OVERLAY.

DEF FRAME f_lancamentos
          bcrapris-b HELP "Pressione <F4> ou <END> para finalizar"
          SKIP(1)
          WITH NO-BOX CENTERED OVERLAY ROW 10.

FORM "TOTAIS" AT 14 SPACE(10)
     tel_ttvec180 FORMAT ">>>,>>>,>>9.99"
     tel_ttvec360 FORMAT ">>>,>>>,>>9.99"
     tel_ttvec999 FORMAT ">>>,>>>,>>9.99"
     SPACE(2)
     WITH OVERLAY ROW 7 NO-LABELS COLUMN 2 FRAME f_total.


PROCEDURE imprime_gerencialcontab:

  DEFINE INPUT PARAMETER aux_vllanger AS DECIMAL.

  aux_linhadet = "999," + TRIM(STRING(aux_vllanger * 100,"zzzzzzzz9,99")).

  PUT STREAM str_2 aux_linhadet FORMAT "x(150)" SKIP.

END.

ON RETURN OF tel_tprelato DO:
    APPLY "GO".
END.

ASSIGN glb_cddopcao = "C"
       tel_tprelato = "Provisao"
       tel_tprelato:LIST-ITEMS = "Provisao,Emp/Finan 60d Atraso".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DISPLAY glb_cddopcao WITH FRAME f_risco.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN glb_cdcritic = 0.

      DO WHILE TRUE:
          UPDATE glb_cddopcao WITH FRAME f_risco.
          
          
          IF glb_cddopcao <> "H" THEN
            UPDATE tel_dtrefere WITH FRAME f_risco.
          ELSE DO:
            /* Fixar a 31/12 do Ano anterior */
            ASSIGN tel_dtrefere = DATE(1,1,year(glb_dtmvtolt)) - 1.
            DISPLAY tel_dtrefere WITH FRAME f_risco.
          END.

          IF  glb_cddopcao = "R"  THEN
              UPDATE tel_tprelato WITH FRAME f_risco.

          LEAVE.
      END.

      IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
          NEXT.

      IF   glb_cddopcao <> "C"  AND
           glb_cddopcao <> "T"  AND
           glb_cddopcao <> "G"  AND
           glb_cddopcao <> "H"  AND
           glb_cddopcao <> "R"  THEN
           DO:
               /*** Verifica se pode rodar ou nao **/
               FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                                  craptab.nmsistem = "CRED"       AND
                                  craptab.tptabela = "USUARI"     AND
                                  craptab.cdempres = 11           AND
                                  craptab.cdacesso = "RISCOBACEN" AND
                                  craptab.tpregist = 000 NO-LOCK NO-ERROR.
               IF   NOT AVAILABLE craptab   THEN
                    ASSIGN glb_cdcritic = 055.
               ELSE
                    IF   INTE(SUBSTR(craptab.dstextab,1,1)) <> 0     THEN
                         ASSIGN glb_cdcritic = 411.

               IF   glb_cdcritic = 0   THEN
                    DO:
                        ASSIGN aux_dtrefere = glb_dtmvtolt - DAY(glb_dtmvtolt).
                        IF   aux_dtrefere <> tel_dtrefere   THEN
                             ASSIGN glb_cdcritic = 411.

               END.

               IF   glb_cdcritic <> 0   THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        CLEAR FRAME f_risco.

                        DISPLAY glb_cddopcao tel_dtrefere
                                WITH FRAME f_risco.
                        NEXT.
                    END.

           END.

      FIND crapope NO-LOCK WHERE
           crapope.cdcooper =  glb_cdcooper AND
           crapope.cdoperad =  glb_cdoperad NO-ERROR.
      IF  NOT AVAIL crapope THEN
          DO:
               ASSIGN glb_cdcritic = 67.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_risco.

               DISPLAY glb_cddopcao tel_dtrefere
                       WITH FRAME f_risco.
               NEXT.
          END.

      IF   glb_cddopcao = "E"    AND
           crapope.nvoperad <> 3 AND
           glb_cdcooper <> 4   THEN   /* Somente Gerentes */
           DO:
               ASSIGN glb_cdcritic = 36.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_risco.

               DISPLAY glb_cddopcao tel_dtrefere
                       WITH FRAME f_risco.
               NEXT.
           END.

      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "RISCO"   THEN
                 DO:
                     HIDE FRAME f_risco.
                     HIDE FRAME f_lancamentos.
                     HIDE FRAME f_encerra.
                     HIDE FRAME f_total.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A"   THEN
        DO:
            { includes/riscoa.i }
        END.
   ELSE
   IF   glb_cddopcao = "C"   THEN
        DO:
            { includes/riscoc.i }
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN
        DO:
            { includes/riscoe.i }
        END.
   ELSE
   IF   glb_cddopcao = "F"   THEN
        DO:
            { includes/riscof.i }
        END.
   ELSE
   IF   glb_cddopcao = "I"   THEN
        DO:
            { includes/riscoi.i }
        END.
   ELSE
   IF   glb_cddopcao = "K"   THEN DO:

        RUN fontes/confirma.p (INPUT "",
                      OUTPUT aux_confirma).

        IF   aux_confirma <> "S"   THEN
             NEXT.

        MESSAGE "Aguarde... Gerando Arq. Contabilizacao...".
        { includes/riscok.i }
   END.
   ELSE
   IF   glb_cddopcao = "M"   THEN
        DO:
            { includes/riscom.i }
        END.
   ELSE
   IF   glb_cddopcao = "R"   THEN
        DO:

            IF  tel_tprelato = "Provisao"  THEN
            DO:

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   ASSIGN aux_confirma = "N"
                          glb_cdcritic = 78.

                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                   LEAVE.
                END.

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                     aux_confirma <> "S" THEN
                     DO:
                         glb_cdcritic = 79.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.

                IF   CAN-FIND(crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                            crapsol.nrsolici = 104)           THEN
                     DO:
                         MESSAGE "Relatorio sendo gerado em outro terminal..."
                                 "Tente mais tarde...".
                         PAUSE 2 NO-MESSAGE.
                         NEXT.
                     END.

                DO TRANSACTION:

                     /* Cria a solicitacao para rodar o programa */
                     CREATE crapsol.
                     ASSIGN crapsol.nrsolici = 104
                            crapsol.dtrefere = glb_dtmvtolt
                            crapsol.nrseqsol = 01
                            crapsol.cdempres = 11
                            crapsol.dsparame = " "
                            crapsol.insitsol = 1
                            crapsol.nrdevias = 1
                            crapsol.cdcooper = glb_cdcooper.
                     VALIDATE crapsol.
                END.

                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Aguarde... Gerando Relatorio...".

                RUN fontes/crps184.p.

                DO TRANSACTION:
                   DELETE crapsol.
                END.

                MESSAGE "ATENCAO! Verifique a GERIMP!".
                PAUSE 2 NO-MESSAGE.
                HIDE MESSAGE NO-PAUSE.
            END.
            ELSE
            IF  tel_tprelato = "Emp/Finan 60d Atraso"  THEN
            DO:
                RUN gera_rel_60d.
            END.
        END.
   ELSE
   IF   glb_cddopcao = "T"   THEN
        DO:
            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF aux_confirma <> "S" THEN
               NEXT.

            MESSAGE "Aguarde... Gerando Arq. Contabilizacao...".
        
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_risco_t
                aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT glb_cdcooper,
                                  INPUT STRING(tel_dtrefere,"99/99/9999"),
                                  OUTPUT "").

            CLOSE STORED-PROC pc_risco_t
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_dscritic = pc_risco_t.pr_dscritic WHEN pc_risco_t.pr_dscritic <> ?.

            IF aux_dscritic <> ""  THEN
               DO:
                   BELL.
                   MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
               END.

            HIDE MESSAGE NO-PAUSE.

        END.       
   ELSE
   IF   glb_cddopcao = "G"   THEN
        DO:
            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF aux_confirma <> "S" THEN
               NEXT.

            MESSAGE "Aguarde... Gerando Arq. Contabilizacao Garantias...".
        
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_risco_g
                aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT glb_cdcooper,
                                  INPUT STRING(tel_dtrefere,"99/99/9999"),
                                  OUTPUT "").

            CLOSE STORED-PROC pc_risco_g
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_dscritic = pc_risco_g.pr_dscritic WHEN pc_risco_g.pr_dscritic <> ?.

            IF aux_dscritic <> ""  THEN
               DO:
                   BELL.
                   MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
               END.

            HIDE MESSAGE NO-PAUSE.

        END.           
   ELSE 
   IF   glb_cddopcao = "H"   THEN
        DO:
            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF aux_confirma <> "S" THEN
               NEXT.

            MESSAGE "Aguarde... Gerando Arq. 3026 ...".
        
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

            RUN STORED-PROCEDURE pc_gera_arq_3026
                aux_handproc = PROC-HANDLE NO-ERROR
                                 (INPUT INTEGER(glb_cdcooper),
                                  INPUT DATE(tel_dtrefere), /*STRING(tel_dtrefere,"99/99/9999")*/
                                  OUTPUT "",
                                  OUTPUT "").

            CLOSE STORED-PROC pc_gera_arq_3026
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
            
            ASSIGN aux_dscritic = pc_gera_arq_3026.pr_dscritic WHEN pc_gera_arq_3026.pr_dscritic <> ?.

            IF aux_dscritic <> ""  THEN
               DO:
                   BELL.
                   MESSAGE aux_dscritic VIEW-AS ALERT-BOX.
               END.

            HIDE MESSAGE NO-PAUSE.

        END.           
        
END.

PROCEDURE gera_rel_60d:

    HIDE FRAME f_lancamentos.

    DEF VAR aux_vldjuros AS DECI                 NO-UNDO.
    DEF VAR tot_vldjuros AS DECI                 NO-UNDO.
    DEF VAR aux_vldjdmes AS DECI                 NO-UNDO.
    DEF VAR tot_vldjdmes AS DECI                 NO-UNDO.

    DEF VAR tot_vldivida AS DECI                 NO-UNDO.
    DEF VAR aux_totalctr AS INTE                 NO-UNDO.

    DEF VAR aux_diascalc AS INTE                 NO-UNDO.
    DEF VAR aux_diasdepr AS INTE                 NO-UNDO.
    DEF VAR aux_datadatr AS DATE                 NO-UNDO.
    DEF VAR aux_datadepr AS DATE                 NO-UNDO.
    DEF VAR aux_diasmais AS INTE                 NO-UNDO.

    /* Data de inicio da reversao
       So pegara os juros a partir desta data
       01 de Agosto de 2010 */
    DEF VAR aux_dtinicio AS DATE INIT 08/01/2010 NO-UNDO.

    /* Data de inicio juros financiamento */
    DEF VAR aux_dtini499 AS DATE INIT 10/01/2011 NO-UNDO.



    DEF VAR aux_nmendter AS CHAR                 NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR FORMAT "x(40)"  NO-UNDO.
    DEF VAR tel_cddopcao AS CHAR FORMAT "x(1)"   NO-UNDO.
    DEF VAR par_flgrodar AS LOGI INIT TRUE       NO-UNDO.

    DEF VAR aux_flgcabec AS LOG                  NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0084) THEN
        RUN sistema/generico/procedures/b1wgen0084.p
            PERSISTENT SET h-b1wgen0084.

    FORM "--------"     AT 12
         "------------" AT 49
         "------------"
         "------------"
         SKIP
         "Contratos:" AT 01
         aux_totalctr AT 13 FORMAT "zzz,zz9"     NO-LABEL
         "Totais:"    AT 41
         tot_vldjdmes       FORMAT "zzzzz,zz9.99" NO-LABEL
         tot_vldjuros       FORMAT "zzzzz,zz9.99" NO-LABEL
         tot_vldivida       FORMAT "zzzzz,zz9.99" NO-LABEL
         SKIP(1)
         WITH NO-BOX NO-LABELS OVERLAY WIDTH 132 FRAME f_rel_60d_tot.

    EMPTY TEMP-TABLE tt-vencto.

    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 220
           tt-vencto.dias     = 60.

    ASSIGN tt-vencto.cdvencto = 230
           tt-vencto.dias     = 90.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 240
           tt-vencto.dias     = 120.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 245
           tt-vencto.dias     = 150.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 250
           tt-vencto.dias     = 180.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 255
           tt-vencto.dias     = 240.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 260
           tt-vencto.dias     = 300.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 270
           tt-vencto.dias     = 360.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 280
           tt-vencto.dias     = 540.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 290
           tt-vencto.dias     = 540.

    ASSIGN glb_cdrelato[1] = 534
           aux_flgcabec    = FALSE.

    { includes/cabrel132_1.i }

    ASSIGN aux_nmarqimp = "rl/crrl534.lst".

    MESSAGE "Aguarde, carregando dados...".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    /* Emprestimo */
    RUN calcula_juros_60(INPUT  glb_cdcooper,
                         INPUT  tel_dtrefere,
                         INPUT  299,
                         INPUT  aux_dtinicio,
                         OUTPUT tot_vldjdmes,
                         OUTPUT tot_vldjuros,
                         OUTPUT tot_vldivida,
                         OUTPUT aux_totalctr).

    IF  aux_totalctr > 0  THEN
        DISPLAY STREAM str_1 tot_vldjdmes
                             tot_vldjuros
                             tot_vldivida
                             aux_totalctr
                             WITH FRAME f_rel_60d_tot.

    ASSIGN aux_totalctr = 0
           aux_diascalc = 0
           aux_vldjuros = 0
           aux_vldjdmes = 0
           aux_diasdepr = 0
           tot_vldjuros = 0
           tot_vldjdmes = 0
           tot_vldivida = 0.

    /* Financiamento */
    RUN calcula_juros_60(INPUT glb_cdcooper,
                         INPUT tel_dtrefere,
                         INPUT 499,
                         INPUT aux_dtini499,
                         OUTPUT tot_vldjdmes,
                         OUTPUT tot_vldjuros,
                         OUTPUT tot_vldivida,
                         OUTPUT aux_totalctr).

    IF  aux_totalctr > 0  THEN
        DISPLAY STREAM str_1 tot_vldjdmes
                             tot_vldjuros
                             tot_vldivida
                             aux_totalctr
                             WITH FRAME f_rel_60d_tot.


    OUTPUT STREAM str_1 CLOSE. /* Encerra a saida para o STREAM str_1 */

    /* Copia para o diretorio rlnsv */
    UNIX SILENT VALUE("cp " + aux_nmarqimp + " rlnsv" + SUBSTR(aux_nmarqimp,3)).

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqimp.

    RUN fontes/imprim.p.

    tel_cddopcao = "T".

    HIDE MESSAGE NO-PAUSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       MESSAGE "(T)erminal ou (I)mpressora: "
               UPDATE tel_cddopcao FORMAT "!(1)".

       IF   tel_cddopcao = "I"   THEN
            DO:
                /* somente para o includes/impressao.i */
                FIND FIRST crapass
                           WHERE crapass.cdcooper = glb_cdcooper
                           NO-LOCK NO-ERROR.

                glb_nmformul = "132col".

                { includes/impressao.i }

                LEAVE.
            END.
       ELSE
       IF   tel_cddopcao = "T"   THEN
            RUN fontes/visrel.p (INPUT aux_nmarqimp).
       ELSE
            DO:
               glb_cdcritic = 14.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT.
            END.
    END.

    IF VALID-HANDLE(h-b1wgen0084) THEN
       DELETE OBJECT h-b1wgen0084.

END PROCEDURE.


PROCEDURE gera_crapris_crapvri.

    ASSIGN aux_vldivida = 0
           aux_rsvec180 = 0
           aux_rsvec360 = 0
           aux_rsvec999 = 0
           aux_rsdiv060 = 0
           aux_rsdiv180 = 0
           aux_rsdiv360 = 0
           aux_rsdiv999 = 0
           aux_rsprjano = 0
           aux_rsprjaan = 0
           aux_rsprjant = 0.

    FOR  EACH crapvri EXCLUSIVE-LOCK WHERE
              crapvri.cdcooper  = glb_cdcooper     AND
              crapvri.nrdconta  = crapris.nrdconta AND
              crapvri.dtrefere  = crapris.dtrefere AND
              crapvri.innivris  = crapris.innivris AND
              crapvri.cdmodali  = crapris.cdmodali AND
              crapvri.nrctremp  = crapris.nrctremp AND
              crapvri.nrseqctr  = crapris.nrseqctr :
         DELETE crapvri.
    END.
    RELEASE crapvri.

    IF  tel_vlvec30 <> 0 THEN
        DO:
           ASSIGN aux_codvenct = 110
                  aux_vlsrisco = tel_vlvec30.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec60 <> 0 THEN
        DO:
           ASSIGN aux_codvenct = 120
                  aux_vlsrisco = tel_vlvec60.
             RUN grava_crapvri.
        END.

    IF  tel_vlvec90 <> 0 THEN
        DO:
           ASSIGN aux_codvenct = 130
                  aux_vlsrisco = tel_vlvec90.
             RUN grava_crapvri.
        END.

    IF  tel_vlvec180 <> 0 THEN
        DO:
           ASSIGN aux_codvenct = 140
                  aux_vlsrisco = tel_vlvec180.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec360 <> 0 THEN
        DO:
           ASSIGN aux_codvenct = 150
                  aux_vlsrisco = tel_vlvec360.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec720 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 160
                    aux_vlsrisco = tel_vlvec720.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec1080 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 165
                    aux_vlsrisco = tel_vlvec1080.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec1440 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 170
                    aux_vlsrisco = tel_vlvec1440.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec1800 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 175
                    aux_vlsrisco = tel_vlvec1800.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec5400 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 180
                    aux_vlsrisco = tel_vlvec5400.
           RUN grava_crapvri.
        END.

    IF  tel_vlvec9999 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 190
                    aux_vlsrisco = tel_vlvec9999.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv14 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 205
                    aux_vlsrisco = tel_vldiv14.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv30 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 210
                    aux_vlsrisco = tel_vldiv30.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv60 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 220
                    aux_vlsrisco = tel_vldiv60.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv90 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 230
                    aux_vlsrisco = tel_vldiv90.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv120 <> 0 THEN
        DO:
           ASSIGN  aux_codvenct = 240
                   aux_vlsrisco = tel_vldiv120.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv150 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 245
                    aux_vlsrisco = tel_vldiv150.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv180 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 250
                    aux_vlsrisco = tel_vldiv180.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv240 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 255
                    aux_vlsrisco = tel_vldiv240.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv300 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 260
                    aux_vlsrisco = tel_vldiv300.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv360 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 270
                    aux_vlsrisco = tel_vldiv360.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv540 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 280
                    aux_vlsrisco = tel_vldiv540.
           RUN grava_crapvri.
        END.

    IF  tel_vldiv999 <> 0 THEN
        DO:
           ASSIGN   aux_codvenct = 290
                    aux_vlsrisco = tel_vldiv999.
           RUN grava_crapvri.
        END.

    IF  tel_vlprjano <> 0 THEN
        DO:
          ASSIGN    aux_codvenct = 310
                    aux_vlsrisco = tel_vlprjano.
          RUN grava_crapvri.
        END.

    IF  tel_vlprjaan <> 0 THEN
        DO:
          ASSIGN aux_codvenct = 320
                 aux_vlsrisco = tel_vlprjaan.
          RUN grava_crapvri.
        END.

    IF  tel_vlprjant <> 0 THEN
        DO:
          ASSIGN aux_codvenct = 330
                 aux_vlsrisco = tel_vlprjant.
          RUN grava_crapvri.
        END.

    RUN regera_crapris.

END PROCEDURE.


PROCEDURE grava_crapvri.

    CREATE crapvri.
    ASSIGN crapvri.nrdconta = tel_nrdconta
           crapvri.dtrefere = tel_dtrefere
           crapvri.innivris = tel_innivris
           crapvri.cdmodali = tel_cdmodali
           crapvri.cdvencto = aux_codvenct
           crapvri.vldivida = aux_vlsrisco
           crapvri.nrctremp = tel_nrctremp
           crapvri.nrseqctr = tel_nrseqctr
           crapvri.cdcooper = glb_cdcooper.
    VALIDATE crapvri.

    RUN soma_valores.

END PROCEDURE.


PROCEDURE regera_crapris.   /* Docto 3010 */

    ASSIGN aux_vldivida = 0
           aux_rsvec180 = 0
           aux_rsvec360 = 0
           aux_rsvec999 = 0
           aux_rsdiv060 = 0
           aux_rsdiv180 = 0
           aux_rsdiv360 = 0
           aux_rsdiv999 = 0
           aux_rsprjano = 0
           aux_rsprjaan = 0
           aux_rsprjant = 0.


    /* --- Gerar Docto 3010 --*/
    FOR EACH crabris WHERE crabris.cdcooper = glb_cdcooper
                       AND crabris.nrdconta = tel_nrdconta
                       AND crabris.dtrefere = tel_dtrefere
                       AND crabris.innivris = tel_innivris
                       AND crabris.inddocto = 0 EXCLUSIVE-LOCK:
        DELETE crabris.
    END.


    FOR EACH crapvri NO-LOCK WHERE
             crapvri.cdcooper  = glb_cdcooper AND
             crapvri.nrdconta  = tel_nrdconta AND
             crapvri.dtrefere  = tel_dtrefere AND
             crapvri.innivris  = tel_innivris :
        run soma_valores.
    END.

    IF  aux_vldivida <> 0 THEN DO:
        CREATE crabris.
        ASSIGN crabris.nrdconta = tel_nrdconta
               crabris.dtrefere = tel_dtrefere
               crabris.innivris = tel_innivris
               crabris.inpessoa = crapass.inpessoa
               crabris.nrcpfcgc = crapass.nrcpfcgc
               crabris.vlprjano = aux_rsprjano
               crabris.vlprjaan = aux_rsprjaan
               crabris.vlprjant = aux_rsprjant
               crabris.vlvec180 = aux_rsvec180
               crabris.vlvec360 = aux_rsvec360
               crabris.vlvec999 = aux_rsvec999
               crabris.vldiv060 = aux_rsdiv060
               crabris.vldiv180 = aux_rsdiv180
               crabris.vldiv360 = aux_rsdiv360
               crabris.vldiv999 = aux_rsdiv999
               crabris.vldivida = aux_vldivida
               crabris.cdcooper = glb_cdcooper.
        VALIDATE crabris.
    END.
END PROCEDURE.

PROCEDURE soma_valores.

    ASSIGN aux_vldivida     = aux_vldivida + crapvri.vldivida.

    IF  crapvri.cdvencto  >= 110 AND
        crapvri.cdvencto  <= 140 THEN
        ASSIGN aux_rsvec180 = aux_rsvec180 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  = 150 THEN
        ASSIGN aux_rsvec360 = aux_rsvec360 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto   > 150 AND
        crapvri.cdvencto  <= 199 THEN
        ASSIGN aux_rsvec999 = aux_rsvec999 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 205 AND
        crapvri.cdvencto  <= 220 THEN
        ASSIGN aux_rsdiv060 = aux_rsdiv060 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 230 AND
        crapvri.cdvencto  <= 250 THEN
        ASSIGN aux_rsdiv180 = aux_rsdiv180 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 255 AND
        crapvri.cdvencto  <= 270 THEN
        ASSIGN aux_rsdiv360 = aux_rsdiv360 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 280 AND
        crapvri.cdvencto  <= 290 THEN
        ASSIGN aux_rsdiv999 = aux_rsdiv999 + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  = 310 THEN
        ASSIGN aux_rsprjano = aux_rsprjano + crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto = 320   THEN
        ASSIGN aux_rsprjaan = aux_rsprjaan + crapvri.vldivida.
    ELSE
        ASSIGN aux_rsprjant = aux_rsprjant + crapvri.vldivida.
END PROCEDURE.


PROCEDURE normaliza_jurosa60:

    DEF INPUT PARAM par_cdcooper    LIKE    crapris.cdcooper    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapris.nrdconta    NO-UNDO.
    DEF INPUT PARAM par_dtrefere    LIKE    crapris.dtrefere    NO-UNDO.
    DEF INPUT PARAM par_innivris    LIKE    crapris.innivris    NO-UNDO.
    DEF INPUT PARAM par_cdmodali    LIKE    crapris.cdmodali    NO-UNDO.
    DEF INPUT PARAM par_nrctremp    LIKE    crapris.nrctremp    NO-UNDO.
    DEF INPUT PARAM par_nrseqctr    LIKE    crapris.nrseqctr    NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vldjuros AS  DECI                NO-UNDO.


    DEF VAR aux_vldiva60    AS  DECI    INITIAL 0               NO-UNDO.


    FOR EACH b-crapvri WHERE b-crapvri.cdcooper  = par_cdcooper AND
                             b-crapvri.nrdconta  = par_nrdconta AND
                             b-crapvri.dtrefere  = par_dtrefere AND
                             b-crapvri.innivris  = par_innivris AND
                             b-crapvri.cdmodali  = par_cdmodali AND
                             b-crapvri.nrctremp  = par_nrctremp AND
                             b-crapvri.nrseqctr  = par_nrseqctr AND
                             b-crapvri.cdvencto >= 230          AND
                             b-crapvri.cdvencto <= 290     NO-LOCK:

        ASSIGN aux_vldiva60 = aux_vldiva60 + b-crapvri.vldivida.
    END.

    IF  par_vldjuros >= aux_vldiva60 THEN
        DO:
             IF  ((par_vldjuros - aux_vldiva60) > 1)  AND (aux_vldiva60 > 1) THEN
                ASSIGN par_vldjuros = aux_vldiva60 - 1.
            ELSE
                ASSIGN par_vldjuros = aux_vldiva60 - 0.1.
        END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE verifica_conta_migracao_risco:

    DEF INPUT PARAM  par_cdcooper   LIKE    crapass.cdcooper        NO-UNDO.
    DEF INPUT PARAM  par_nrdconta   LIKE    crapass.nrdconta        NO-UNDO.
    DEF INPUT PARAM  par_dtrefere   AS      DATE                    NO-UNDO.
    DEF INPUT PARAM  par_dtmvtolt   AS      DATE                    NO-UNDO.

    /*Migracao Concredi -> Viacredi*/
    IF  par_cdcooper  = 1          AND
        par_dtrefere <= 11/30/2014 THEN
        DO:
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 4            AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN
                RETURN "NOK".
        END.
        
        
    /*Migracao Transulcred -> Transpocred */
    IF  par_cdcooper  = 09         AND
        par_dtrefere <= 12/31/2016 THEN
        DO:
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 17           AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN
                RETURN "NOK".
        END.    

    /*Migracao Credimilsul -> Scrcred */
    IF  par_cdcooper  = 13         AND
        par_dtrefere <= 11/30/2014 THEN
        DO:
            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 15           AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN
                RETURN "NOK".
        END.

    /*Migracao Viacredi -> Altovale*/
    IF  par_cdcooper  = 16         AND
        par_dtrefere <= 12/31/2012 THEN
        DO:

            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 1            AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN
                RETURN "NOK".

        END.

    /*Migracao Acredicop -> Viacredi*/
    IF  par_cdcooper  = 1          AND
        par_dtrefere <= 12/31/2013 THEN
        DO:

            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.cdcopant = 2            AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf <> 3           AND
                              (craptco.cdageant = 2            OR
                               craptco.cdageant = 4            OR
                               craptco.cdageant = 6            OR
                               craptco.cdageant = 7            OR
                               craptco.cdageant = 11)
                               NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN
                RETURN "NOK".

        END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE calcula_juros_60:

    DEF INPUT PARAM  par_cdcooper   LIKE    crapris.cdcooper        NO-UNDO.
    DEF INPUT PARAM  par_dtrefere   AS      DATE                    NO-UNDO.
    DEF INPUT PARAM  par_cdmodali   LIKE    crapris.cdmodali        NO-UNDO.
    DEF INPUT PARAM  par_dtinicio   AS      DATE                    NO-UNDO.
    DEF OUTPUT PARAM tot_vldjdmes   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM tot_vldjuros   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM tot_vldivida   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM aux_totalctr   AS DECI                         NO-UNDO.

    DEF VAR aux_vldjdmes AS DECI                                    NO-UNDO.
    DEF VAR aux_diasdepr AS INTE                                    NO-UNDO.
    DEF VAR aux_flgcabec AS LOG                                     NO-UNDO.
    DEF VAR aux_datadepr AS DATE                                    NO-UNDO.
    DEF VAR aux_datadatr AS DATE                                    NO-UNDO.

    FORM "Data de referencia da tela:" AT 03 tel_dtrefere
         SKIP(1)
         "REF EMPRESTIMO" AT 20
         "REF AOS JUROS" AT 35
         SKIP
         "--------------" AT 20
         "-------------" AT 35
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_rel_epr_60d_data.

    FORM "Data de referencia da tela:" AT 03 tel_dtrefere
         SKIP(1)
         "REF FINANCIAM." AT 20
         "REF AOS JUROS" AT 35
         SKIP
         "--------------" AT 20
         "-------------" AT 35
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_rel_fin_60d_data.

    FORM crapris.nrdconta COLUMN-LABEL "Conta/dv"   AT 01
         crapris.nrctremp COLUMN-LABEL "Contrato"

         /* Data e dias do emprestimo/financiamento em atraso */
         aux_datadepr     COLUMN-LABEL "Data Atr"   FORMAT "99/99/99"
         aux_diasdepr     COLUMN-LABEL "Dias"       FORMAT "zzz9"
         /* Data e dias para calculo dos juros */
         aux_datadatr     COLUMN-LABEL "Data Jur"   FORMAT "99/99/99"
             aux_diascalc     COLUMN-LABEL "Dias"       FORMAT "zzz9"

         aux_vldjdmes     COLUMN-LABEL "Juros Mes"  FORMAT "zzzzz,zz9.99"

         aux_vldjuros     COLUMN-LABEL "Juros Acum" FORMAT "zzzzz,zz9.99-"
         crapris.vldivida COLUMN-LABEL "Vlr Divida" FORMAT "zzzzz,zz9.99-"
         crapris.innivris COLUMN-LABEL "Nivel Risco"
         WITH DOWN NO-BOX WIDTH 132 FRAME f_rel_60d_ctr.

    IF par_cdmodali = 299 THEN
        DISPLAY STREAM str_1 tel_dtrefere WITH FRAME f_rel_epr_60d_data.


    FOR EACH crapris  WHERE crapris.cdcooper = par_cdcooper AND
                            crapris.dtrefere = par_dtrefere AND
                            crapris.cdmodali = par_cdmodali AND
                            crapris.inddocto = 1 AND
                            crapris.qtdiaatr > 0 AND crapris.vljura60 > 0
                            NO-LOCK BREAK BY crapris.nrdconta
                                           BY crapris.nrctremp
                                            BY crapris.nrseqctr:

        RUN verifica_conta_migracao_risco(INPUT glb_cdcooper,
                                          INPUT crapris.nrdconta,
                                          INPUT crapris.dtrefere,
                                          INPUT TODAY).

        IF  RETURN-VALUE = "NOK" THEN
            NEXT.

        FIND LAST crapvri WHERE crapvri.cdcooper  = crapris.cdcooper AND
                                crapvri.nrdconta  = crapris.nrdconta AND
                                crapvri.dtrefere  = crapris.dtrefere AND
                                crapvri.innivris  = crapris.innivris AND
                                crapvri.cdmodali  = crapris.cdmodali AND
                                crapvri.nrctremp  = crapris.nrctremp AND
                                crapvri.nrseqctr  = crapris.nrseqctr AND
                                crapvri.cdvencto >= 220              AND
                                crapvri.cdvencto <= 290
                                NO-LOCK NO-ERROR.

        IF  AVAIL crapvri  THEN
            DO:
                ASSIGN aux_vldjdmes = 0
                       aux_vldjuros = 0.

                FIND crapepr WHERE crapepr.cdcooper = crapris.cdcooper AND
                                   crapepr.nrdconta = crapris.nrdconta AND
                                   crapepr.nrctremp = crapris.nrctremp
                                   NO-LOCK NO-ERROR.

                IF AVAIL crapepr THEN
                   DO:
                       IF crapepr.tpemprst = 0 THEN
                          DO:
                              RUN calculaJurosEmprestimoTR
                                                   (INPUT crapris.cdcooper,
                                                    INPUT crapris.nrdconta,
                                                    INPUT crapris.nrctremp,
                                                    INPUT crapvri.cdvencto,
                                                    INPUT crapris.qtdiaatr,
                                                    INPUT tel_dtrefere,
                                                    INPUT par_dtinicio,
                                                    INPUT TABLE tt-vencto,
                                                    INPUT-OUTPUT aux_vldjuros,
                                                    INPUT-OUTPUT aux_vldjdmes,
                                                    INPUT-OUTPUT aux_diascalc,
                                                    INPUT-OUTPUT aux_diasdepr,
                                                    INPUT-OUTPUT aux_datadepr,
                                                    INPUT-OUTPUT aux_datadatr).

                              RUN normaliza_jurosa60(INPUT crapris.cdcooper,
                                                     INPUT crapris.nrdconta,
                                                     INPUT crapris.dtrefere,
                                                     INPUT crapris.innivris,
                                                     INPUT crapris.cdmodali,
                                                     INPUT crapris.nrctremp,
                                                     INPUT crapris.nrseqctr,
                                                     INPUT-OUTPUT aux_vldjuros).

                          END. /* END IF crapepr.tpemprst = 0 */
                       ELSE
                          DO:
                             RUN calculaJurosEmprestimoPreFixado
                                                   (INPUT crapris.cdcooper,
                                                    INPUT crapris.nrdconta,
                                                    INPUT crapris.nrctremp,
                                                    INPUT tel_dtrefere,
                                                    INPUT crapris.qtdiaatr,
                                                    INPUT-OUTPUT aux_vldjdmes,
                                                    INPUT-OUTPUT aux_diascalc,
                                                    INPUT-OUTPUT aux_diasdepr,
                                                    INPUT-OUTPUT aux_datadepr,
                                                    INPUT-OUTPUT aux_datadatr).
                            ASSIGN aux_vldjuros = aux_vldjuros + crapris.vljura60.
                          END.

                   END. /* IF AVAIL crapepr */

                ASSIGN tot_vldjuros = tot_vldjuros + aux_vldjuros
                       tot_vldjdmes = tot_vldjdmes + aux_vldjdmes
                       tot_vldivida = tot_vldivida + crapris.vldivida
                       aux_totalctr = aux_totalctr + 1.

                IF  LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
                    DO:
                        PAGE STREAM str_1.

                        IF par_cdmodali = 299 THEN /* Emprestimo */
                            DISPLAY STREAM str_1 tel_dtrefere WITH FRAME f_rel_epr_60d_data.
                        ELSE
                            DISPLAY STREAM str_1 tel_dtrefere WITH FRAME f_rel_fin_60d_data.
                    END.
                ELSE
                    IF par_cdmodali = 499 THEN /* Financiamento */
                        DO:
                            IF aux_flgcabec = FALSE THEN
                                DISPLAY STREAM str_1 tel_dtrefere WITH FRAME f_rel_fin_60d_data.

                            aux_flgcabec = TRUE.
                        END.

                DISPLAY STREAM str_1 crapris.nrdconta
                                     crapris.nrctremp
                                     aux_diasdepr
                                     aux_datadepr
                                     aux_diascalc
                                     aux_datadatr
                                     aux_vldjdmes
                                     aux_vldjuros
                                     crapris.vldivida
                                     crapris.innivris
                                     WITH FRAME f_rel_60d_ctr.

                DOWN STREAM str_1 WITH FRAME f_rel_60d_ctr.
            END.
    END.

END PROCEDURE.

PROCEDURE calculaJurosEmprestimoTR:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdvencto AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_qtdiaatr AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_dtinicio AS DATE                           NO-UNDO.

    DEF INPUT  PARAM TABLE FOR tt-vencto.

    DEF INPUT-OUTPUT PARAM par_vldjuros AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vldjdmes AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_diascalc AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_diasdepr AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_datadepr AS DATE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_datadatr AS DATE                     NO-UNDO.

    FIND tt-vencto WHERE tt-vencto.cdvencto = par_cdvencto
                         NO-LOCK NO-ERROR.

    /*  calculo de dias para acima de 540 dias - codigo 290 */
    IF  par_cdvencto = 290  THEN
        DO:
            ASSIGN par_diascalc = par_qtdiaatr - 60.
        END.
    ELSE
    IF  tt-vencto.dias < par_qtdiaatr  THEN
        DO:
            ASSIGN par_diascalc = tt-vencto.dias - 60.
        END.
    ELSE
        DO:
            ASSIGN par_diascalc = par_qtdiaatr - 60.
        END.

    ASSIGN par_diasdepr = par_diascalc + 60
           par_datadepr = par_dtrefere - par_diasdepr
           par_datadatr = par_dtrefere - par_diascalc.

    /* Buscar os registros de emprestimos a partir da data calculada e que
       esta data seja maior que a de inicio da reversao - 01/08/2010       */
    FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper                 AND
                           craplem.nrdconta = par_nrdconta                 AND
                           craplem.dtmvtolt >= par_dtrefere - par_diascalc AND
                           craplem.dtmvtolt >= par_dtinicio                AND
                           craplem.dtmvtolt <= par_dtrefere                AND
                           craplem.cdhistor = 98                           AND
                           craplem.nrdocmto = par_nrctremp
                           NO-LOCK:

        /* Calcular os juros do mes de referencia */
        IF  MONTH(par_dtrefere) = MONTH(craplem.dtmvtolt) AND
            YEAR(par_dtrefere)  = YEAR(craplem.dtmvtolt) THEN
            ASSIGN par_vldjdmes = par_vldjdmes + craplem.vllanmto.

        ASSIGN par_vldjuros = par_vldjuros + craplem.vllanmto.

    END.

    RETURN "OK".

END PROCEDURE. /* END calculaJurosEmprestimoTR */

PROCEDURE calculaJurosEmprestimoPreFixado:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_dtrefere AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_qtdiaatr AS INTE                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM par_vldjdmes AS DECI                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_diascalc AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_diasdepr AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_datadepr AS DATE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_datadatr AS DATE                     NO-UNDO.

    DEF VAR aux_dtultdia AS DATE                                    NO-UNDO.

    ASSIGN aux_dtultdia = DYNAMIC-FUNCTION("fnBuscaDataDoUltimoDiaUtilMes"
                                           IN h-b1wgen0084,
                                           INPUT par_cdcooper,
                                           INPUT par_dtrefere).

    FOR EACH craplem NO-LOCK WHERE craplem.cdcooper = par_cdcooper          AND
                                   craplem.nrdconta = par_nrdconta          AND
                                   craplem.nrctremp = par_nrctremp          AND
                                   (craplem.cdhistor = 1037 OR
                                    craplem.cdhistor = 1038)                AND
                                   craplem.dtmvtolt >
                                         aux_dtultdia - (par_qtdiaatr - 59) AND
                                   craplem.dtmvtolt <= aux_dtultdia:

        /* Calcular os juros do mes de referencia */
        IF  MONTH(aux_dtultdia) = MONTH(craplem.dtmvtolt) AND
            YEAR(aux_dtultdia)  = YEAR(craplem.dtmvtolt) THEN
            ASSIGN par_vldjdmes = par_vldjdmes + craplem.vllanmto.

    END.

    ASSIGN par_diasdepr = par_qtdiaatr
           par_diascalc = par_qtdiaatr - 59
           par_datadepr = aux_dtultdia - par_diasdepr
           par_datadatr = aux_dtultdia - par_diascalc.

    RETURN "OK".

END PROCEDURE. /* END calculaJurosEmprestimoPreFixado */
/* .......................................................................... */
