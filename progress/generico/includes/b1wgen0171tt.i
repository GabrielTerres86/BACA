/*..............................................................................

    Programa: b1wgen0171tt.i
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/SUPERO
    Data    : Agosto/2013                        Ultima atualizacao: 02/02/2015

    Dados referentes ao programa:

    Objetivo  : Arquivo com vari�veis ultizadas na BO b1wgen0171.p

    Alteracoes: 29/04/2014 - Novo campo ROWIDBPR na tt-bens-gravames
                             (Guilherme/SUPERO)
                             
                02/02/2015 - Adicionado campo blqjud e tpctrpro 
                             em tt-bens-gravames.
                             (Jorge/Gielow) - SD 241854

..............................................................................*/



DEF TEMP-TABLE tt-bens-gravames NO-UNDO
    FIELD lsbemfin AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD nrgravam LIKE crapbpr.nrgravam
    FIELD dscatbem AS CHAR
    FIELD dsbemfin AS CHAR
    FIELD dscorbem AS CHAR
    FIELD vlmerbem AS DECI
    FIELD dschassi AS CHAR
    FIELD tpchassi AS INTE INIT 2
    FIELD ufdplaca AS CHAR
    FIELD nrdplaca AS CHAR
    /* field uf licenciamento ?? */
    FIELD nrrenava AS DECI
    FIELD nranobem AS INTE
    FIELD nrmodbem AS INTE
    FIELD nrcpfbem AS DECI FORMAT "zzzzzzzzzzzzz9"
    FIELD dscpfbem AS CHAR FORMAT "x(18)"
    FIELD vlctrgrv AS DECI
    FIELD dtoperac AS DATE
    FIELD nrseqbem AS INTE
    FIELD cdsitgrv AS INTE
    FIELD dssitgrv AS CHAR
    FIELD idseqbem AS INTE
    FIELD uflicenc AS CHAR
    FIELD idalibem AS INTE
    FIELD dsjstbxa AS CHAR
    FIELD dsjstinc AS CHAR
    FIELD dsblqjud AS CHAR
    FIELD tpctrpro AS INTE
    FIELD rowidbpr AS ROWID
    INDEX ix-bens-1 idseqbem.


DEF TEMP-TABLE tt-bens-zoom LIKE tt-bens-gravames.

DEF TEMP-TABLE tt-contratos NO-UNDO
    FIELD nrctrpro AS INTE.

DEF TEMP-TABLE tt-cooper
    FIELD cdcooper AS INT
    FIELD nmrescop AS CHAR.

DEF TEMP-TABLE tt-dados-arquivo
    FIELD rowidbpr AS ROWID
    FIELD tparquiv AS CHAR
    FIELD cdcooper AS INT

    FIELD nrdconta LIKE crapbpr.nrdconta
    FIELD tpctrpro LIKE crapbpr.tpctrpro
    FIELD nrctrpro LIKE crapbpr.nrctrpro
    FIELD idseqbem LIKE crapbpr.idseqbem

    FIELD cdfingrv LIKE crapcop.cdfingrv
    FIELD cdsubgrv LIKE crapcop.cdsubgrv
    FIELD cdloggrv LIKE crapcop.cdloggrv
    FIELD nrseqlot AS INT       /*Nr sequen Lote */
    FIELD nrseqreg AS INT       /* Nr sequen Registro */
    FIELD dtmvtolt AS DATE      /*Data atual Sistema  */
    FIELD hrmvtolt AS INT       /*Hora atual */
    FIELD nmrescop AS CHAR      /*Nome Cooperativa */
    
    FIELD dschassi LIKE crapbpr.dschassi  /* Chassi do ve�culo        */ 
    FIELD tpchassi LIKE crapbpr.tpchassi  /* Informa��o de remarca��o */ 
    FIELD uflicenc LIKE crapbpr.uflicenc  /* UF de licenciamento      */ 
    FIELD ufdplaca LIKE crapbpr.ufdplaca  /* UF da placa              */ 
    FIELD nrdplaca LIKE crapbpr.nrdplaca  /* Placa do ve�culo         */ 
    FIELD nrrenava LIKE crapbpr.nrrenava  /* RENAVAM do ve�culo       */ 
    FIELD nranobem LIKE crapbpr.nranobem  /* Ano de fabrica��o        */ 
    FIELD nrmodbem LIKE crapbpr.nrmodbem  /* Ano do modelo            */ 
    FIELD nrctremp LIKE crawepr.nrctremp  /* N�mero da opera��o       */ 
    FIELD dtoperad LIKE crawepr.dtmvtolt  /* Data da Operacao         */
    FIELD nrcpfbem LIKE crapbpr.nrcpfbem  /* CPF/CNPJ do cliente      */
    FIELD nmprimtl LIKE crapass.nmprimtl  /* Nome do cliente          */
    FIELD qtpreemp LIKE crawepr.qtpreemp  /* Quantidade de meses      */

    FIELD vlemprst LIKE crawepr.vlemprst  /*  Valor principal da oper.           */        
    FIELD vlpreemp LIKE crawepr.vlpreemp  /*  Valor da parcela                   */        
    FIELD dtdpagto LIKE crawepr.dtdpagto  /*  Data de vencto prim. parc.   */ 
    FIELD dtvencto AS DATE                /*  Data de vencto ult. parc.           */ 
    FIELD nmcidade LIKE crapage.nmcidade  /*  Cidade da libera��o da oper. */        
    FIELD cdufdcop LIKE crapage.cdufdcop  /*  UF da libera��o da oper           */        

    FIELD dsendcop LIKE crapcop.dsendcop  /* Nome do logradouro           */
    FIELD nrendcop LIKE crapcop.nrendcop  /* N�mero do im�vel           */
    FIELD dscomple LIKE crapcop.dscomple  /* Complemento do im�vel */
    FIELD nmbaienc LIKE crapcop.nmbairro  /* Bairro do im�vel           */
    FIELD cdcidenc LIKE crapmun.cdcidade  /* C�digo do munic�pio   */
    FIELD cdufdenc LIKE crapcop.cdufdcop  /* UF do im�vel               */
    FIELD nrcepenc LIKE crapcop.nrcepend  /* CEP do im�vel               */
    FIELD nrdddenc AS CHAR                /* DDD do telefone        */
    FIELD nrtelenc LIKE crapcop.nrtelvoz  /* DDD N�mero do telefone        */

    FIELD dsendere LIKE crapenc.dsendere  /* Nome do logradouro    */
    FIELD nrendere LIKE crapenc.nrendere  /* N�mero do im�vel      */
    FIELD complend LIKE crapenc.complend  /* Complemento do im�vel */
    FIELD nmbairro LIKE crapenc.nmbairro  /* Bairro do im�vel      */
    FIELD cdcidade LIKE crapmun.cdcidade  /* C�digo do munic�pio   */
    FIELD cdufende LIKE crapenc.cdufende  /* UF do im�vel          */
    FIELD nrcepend LIKE crapenc.nrcepend  /* CEP do im�vel         */
    FIELD nrdddass AS CHAR                /* DDD do telefone       */
    FIELD nrtelass AS CHAR                /* N�mero do telefone    */

    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    .
