/*.............................................................................

    Programa: b1wgen0063tt.i
    Autor   : Jose Luis
    Data    : ABril/2010                   Ultima atualizacao: 16/09/2015

    Objetivo  : Definicao das Temp-Tables para tela de IMPRESSOES

    Alteracoes: 06/06/2011 - Criar mais uma linha de endereco na
                             tt-abert-compj (Gabriel)
                
                25/07/2013 - Criar tt-ctaassin para Cartao de Assinatura
                             (Jean Michel)
                
                03/10/2013 - Criar tt-cratavt para Cartao de Assinatura
                             (Jean Michel)
                             
                02/06/2014 - Adicionado  campo de cpf em tt-cratpod.
                             (Jorge/Rosangela) - SD 1554081
                             
                16/09/2015 - Reformulacao cadastral (Tiago Castro-RKAM).

.............................................................................*/

/*...........................................................................*/

/* --- IMPRESSAO DA ABERTURA ----------------------------------------------- */
/* Inicio - Dados comuns a PF e PJ */
DEFINE TEMP-TABLE tt-abert-ident NO-UNDO
    /* f_cabec */
    FIELD dstitulo AS CHAR
    /* f_identificacao */
    FIELD nmextcop AS CHAR 
    FIELD dslinha1 AS CHAR 
    FIELD dslinha2 AS CHAR 
    FIELD dslinha3 AS CHAR
    FIELD dslinha4 AS CHAR
    FIELD inpessoa AS INTE .
/* Fim - Dados comuns a PF e PJ */

/* --- Pessoa Fisica --------------------------------------------------------*/
DEFINE TEMP-TABLE tt-abert-psfis NO-UNDO
    /* f_identificacao_pf */
    FIELD nmprimtl AS CHAR
    FIELD nrdconta AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD dslinha1 AS CHAR
    FIELD dslinha2 AS CHAR
    FIELD dslinha3 AS CHAR
    FIELD dslinha4 AS CHAR
    FIELD dsestcvl AS CHAR
    /* f_representacao_pf */
    FIELD nmrepleg AS CHAR
    FIELD nrcpfrep AS CHAR  /* CPF do representante legal */
    FIELD nrdocrep AS CHAR. /* documento do representante legal */
 
DEFINE TEMP-TABLE tt-abert-compf NO-UNDO
    /* f_complem_pf */
    FIELD dstitulo AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nrdocmto AS CHAR.

DEFINE TEMP-TABLE tt-abert-decpf NO-UNDO
    /* f_declara_1_pf */
    FIELD dsclact1 AS CHAR
    FIELD dsclact2 AS CHAR
    FIELD dsclact3 AS CHAR
    FIELD dsclact4 AS CHAR
    FIELD dsclact5 AS CHAR
    FIELD dsclact6 AS CHAR
    /* f_declara_2_pf */
    FIELD dsmvtolt AS CHAR
    FIELD nmextttl AS CHAR   
    FIELD nmextcop AS CHAR
    /* f_declara_2ttl */
    FIELD linhater AS CHAR
    FIELD nmsgdttl AS CHAR
    FIELD nmterttl AS CHAR
    /* f_declara_4ttl */
    FIELD nmqtottl AS CHAR.
/* --- Pessoa Fisica - FIM --------------------------------------------------*/

/* --- Pessoa Juridica ------------------------------------------------------*/
DEFINE TEMP-TABLE tt-abert-psjur NO-UNDO
    /* f_identificacao_pj */
    FIELD nmprimtl AS CHAR
    FIELD nrdconta AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dslinha1 AS CHAR
    FIELD dslinha2 AS CHAR
    FIELD dslinha3 AS CHAR
    FIELD dslinha4 AS CHAR
    /* f_complem_pj_cabec */
    FIELD dsnatjur AS CHAR
    FIELD nrinsest AS CHAR.

DEFINE TEMP-TABLE tt-abert-compj NO-UNDO
    /* f_complem_pj */
    FIELD dstitulo AS CHAR
    FIELD dsproftl AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD dslinha1 AS CHAR
    FIELD dslinha2 AS CHAR
    FIELD dslinha3 AS CHAR.

DEFINE TEMP-TABLE tt-abert-decpj NO-UNDO
    /* f_declara_pj */
    FIELD dsclact1 AS CHAR
    FIELD dsclact2 AS CHAR
    FIELD dsclact3 AS CHAR
    FIELD dsclact4 AS CHAR
    FIELD dsclact5 AS CHAR
    FIELD dsclact6 AS CHAR
    /* f_declara_pj2 */
    FIELD dsmvtolt AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nmextcop AS CHAR.
/* --- Pessoa Juridica - FIM ------------------------------------------------*/

/* --- IMPRESSAO DO TERMO DE ADESAO ---------------------------------------- */
DEFINE TEMP-TABLE tt-termo-ident NO-UNDO
    /* f_identi */
    FIELD nmextcop AS CHAR
    FIELD cdagenci AS INTE
    FIELD nrdconta AS CHAR FORMAT "x(10)"
    /* f_termo_adesao */
    FIELD nmrescop AS CHAR
    FIELD dsmvtolt AS CHAR.

DEFINE TEMP-TABLE tt-termo-assin NO-UNDO
    /* f_inte_ass1 */
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nmoperad AS CHAR.

DEFINE TEMP-TABLE tt-termo-asstl NO-UNDO
    /* f_inte_ass2 */
    FIELD nmprimtl AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nmextttl AS CHAR
    FIELD nrcpfttl AS CHAR
    FIELD nmoperad AS CHAR.

/* --- IMPRESSAO DO INFORMATIVO FINANCEIRO --------------------------------- */
DEFINE TEMP-TABLE tt-finan-cabec NO-UNDO
    /* f_cabecalho */
    FIELD nmextcop AS CHAR
    FIELD dsendcop AS CHAR
    FIELD nrdocnpj AS CHAR.

DEFINE TEMP-TABLE tt-finan-ficha NO-UNDO
    /* f_fichafin_1 */
    FIELD nmprimtl AS CHAR
    FIELD dtultatu AS DATE EXTENT 5
    FIELD opultatu AS CHAR EXTENT 5
    /* f_fichafin_2 */
    FIELD nrcpfcgc AS CHAR
    FIELD dsdtbase AS CHAR
    /* f_fichafin_3 */
    FIELD vlcxbcaf AS CHAR 
    FIELD vlfornec AS CHAR
    FIELD vlctarcb AS CHAR
    FIELD vloutpas AS CHAR
    FIELD vlrestoq AS CHAR
    FIELD vloutatv AS CHAR
    FIELD vlrimobi AS CHAR
    FIELD vldivbco AS CHAR
    FIELD dsultat1 AS CHAR
    /* f_fichafin_4 */
    FIELD cdbccxlt AS CHAR EXTENT 5
    FIELD dstipope AS CHAR EXTENT 5
    FIELD vlropera AS CHAR EXTENT 5
    FIELD garantia AS CHAR EXTENT 5
    FIELD dsvencto AS CHAR EXTENT 5
    /* f_fichafin_5 */
    FIELD vlrctbru AS CHAR
    FIELD ddprzrec AS CHAR
    FIELD vlctdpad AS CHAR
    FIELD ddprzpag AS CHAR
    FIELD vldspfin AS CHAR
    FIELD dsultat3 AS CHAR
    /* f_fichafin_6 */
    FIELD mesanoft AS CHAR EXTENT 12
    FIELD vlrftbru AS CHAR EXTENT 12
    /* f_fichafin_7 */
    FIELD dsinfadi LIKE crapjfn.dsinfadi.

DEFINE TEMP-TABLE tt-tprelato NO-UNDO
    FIELD nmrelato AS CHAR
    FIELD msgrelat AS CHAR
    FIELD flgbloqu AS LOG.

/* Tabela Referente ao Cartao Assinatura */
DEFINE TEMP-TABLE tt-ctaassin NO-UNDO
    FIELD cdcooper AS INT
    FIELD nmcooper AS CHAR FORMAT "x(35)"
    FIELD drcooper AS CHAR
    FIELD cdagenci AS INT
    FIELD nrdconta AS INT
    FIELD idseqttl AS INT
    FIELD nmtitula AS CHAR FORMAT "x(40)"
    FIELD nrcpftit AS DEC
    FIELD nrdctapr AS INT
    FIELD nmprocur AS CHAR FORMAT "x(40)"
    FIELD nrcpfpro AS DEC
    FIELD nrtelpro AS CHAR FORMAT "x(20)"
    FIELD dsfuncao AS CHAR FORMAT "x(20)"
    FIELD dtvencim AS CHAR FORMAT "x(10)".

/* Tabela Referente a impressao de procuradores */  
DEFINE TEMP-TABLE tt-cratavt NO-UNDO
    FIELD nmrescop AS CHAR FORMAT "x(40)"
    FIELD cdagenci AS INT
    FIELD nrdconta AS INT
    FIELD nmtitula AS CHAR FORMAT "x(50)"
    FIELD idseqttl AS INT
    FIELD nrcpfcgc AS CHAR FORMAT "x(20)"
    FIELD nrdctato AS INT
    FIELD nmprocur AS CHAR FORMAT "x(50)"
    FIELD nrcpfpro AS CHAR FORMAT "x(20)"
    FIELD nrtelefo AS CHAR FORMAT "x(15)"
    FIELD dsfuncao AS CHAR FORMAT "x(30)"
    FIELD dtvencim AS CHAR FORMAT "x(10)".

/* Tabela Referente a impressao de poderes */  
DEFINE TEMP-TABLE tt-cratpod NO-UNDO
    FIELD codpoder AS INT
    FIELD nrdctato AS INT
    FIELD nrcpfcgc AS CHAR
    FIELD flgconju AS CHAR FORMAT "x(3)"
    FIELD flgisola AS CHAR FORMAT "x(3)"
    FIELD dsoutpod AS CHAR.
