/* ..........................................................................

   Programa: Fontes/crps479.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2007                        Ultima atualizacao: 13/06/2011
                                                                          
   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 082.
               Importacao Folha(Impressao Holerite)

   Observacao: As criticas utilizadas para os erros foram retiradas do layout
               do arquivo de retorno. Os codigos e descricoes sao:
               
               101 - OPERACAO DO COMPROVANTE DEVE SER 'I' OU 'E'
               103 - TIPO DE COMPROVANTE NAO CADASTRADO
               105 - MES DE REFERENCIA DEVE ESTAR NO INTERVALO 1 A 12
               106 - ANO DE REFERENCIA DEVE SER MAIOR DO QUE 2002
               110 - BANCO DO FUNCIONARIO DEVE SER 0009
               113 - DIGITO DA CONTA DO FUNCIONARIO INCONSISTENTE
               116 - DIGITO DO CPF DO FUNCIONARIO INCOSISTENTE
               117 - NOME DO FUNCIONARIO DEVE ESTAR PREENCHIDO
               119 - CODIGO OU DESCRICAO DO LCTO DEVE ESTAR PREENCHIDO
               120 - VALOR DO LANCAMENTO DEVE SER NUMERICO
               122 - IDENTIFICADOS DE LCTO DEVE SER 1, 2, 3, 4, 5 OU 6
               129 - MENSAGEM DO COMPROVANTE DEVE ESTAR PREENCHIDA
               132 - TOTAL DE DETALHES DO COMPROVANTE INCONSISTENTE
               138 - DATA DE ADMISSAO SE FOR PREENCHIDA DEVE SER VALIDA
               906 - CONTEUDO DEVE SER 'REMESSA HPAG EMPRESA'
               907 - NUMERO DO LOTE DEVE SER NUMERICO
               916 - TOTAL DE REGISTROS DO LOTE INCONSISTENTE
               917 - CGC DA EMPRESA INCONSISTENTE
               918 - CODIGO DO LANCAMENTO DO PRODUTO INCONSISTENTE

   Alteracoes: 11/06/2007 - Criticar CPF nao cadastrado na crapttl (Evandro).

               06/07/2007 - Retirada obrigatoriedade do lote, mensagem e 
                            data liberacao(Mirtes)
                            
               01/08/2007 - Verificar se o arquivo eh da empresa DP e enviar
                            via e-mail para leda@dpempresarial.com.br (Evandro)
                            
               13/06/2011 - Transferido toda a regra de negocio para a include
                            crps479.i; que passara a ser chamada por este 
                            programa e tambem pelo crps600.p(tela). (Fabricio)

............................................................................. */

DEF STREAM str_1. /* Para importacao, retorno e relatorio */
DEF STREAM str_2. /* Para ler os arquivos */

{ includes/var_batch.i }

DEF NEW SHARED VAR shr_inpessoa AS INT                               NO-UNDO.

DEFINE VARIABLE aux_dsdlinha AS CHARACTER                            NO-UNDO.
DEFINE VARIABLE aux_dtrefere AS DATE                                 NO-UNDO.
DEFINE VARIABLE aux_nrseqddp AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_nrseqmdp AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_nrcgcemp AS DECIMAL                              NO-UNDO.
DEFINE VARIABLE aux_flgrgatv AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_cddpagto AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_nrdconta AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_idseqttl AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_cdempres AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_flgrecus AS LOGICAL                              NO-UNDO.
DEFINE VARIABLE aux_nmarquiv AS CHAR                                 NO-UNDO.
DEFINE VARIABLE aux_lsretarq AS CHAR                                 NO-UNDO.
DEFINE VARIABLE par_diretori AS CHAR     
       INIT "integra/HRFP*.REM integra/HRFER*.REM integra/HR13*.REM 
            integra/HRPLR*.REM"
                                                                     NO-UNDO.

DEFINE VARIABLE aux_qtreghol AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_qtregarq AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_qtheader AS INTEGER                              NO-UNDO.
DEFINE VARIABLE aux_contador AS INTEGER                              NO-UNDO.

DEFINE VARIABLE rel_qtderros AS INTEGER                              NO-UNDO.
DEFINE VARIABLE rel_qtdgeral AS INTEGER                              NO-UNDO.
DEFINE VARIABLE rel_qtdcerto AS INTEGER                              NO-UNDO.

DEFINE VARIABLE h-b1wgen0011 AS HANDLE                               NO-UNDO.

/* Para auxiliar na geracao do arquivo de retorno */
DEFINE TEMP-TABLE w_retorno  NO-UNDO
       FIELD nmarquiv AS CHARACTER
       FIELD dslinarq AS CHARACTER
       FIELD cddmsgm1 AS INTEGER
       FIELD cddmsgm2 AS INTEGER
       FIELD cddmsgm3 AS INTEGER
       FIELD nrsequen AS INTEGER
       FIELD tpregist AS INTEGER
       FIELD qtheader AS INTEGER.
       
/* Variaveis para o relatorio */
DEFINE VARIABLE rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEFINE VARIABLE rel_nmresemp AS CHAR                                 NO-UNDO.
DEFINE VARIABLE rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
       
FORM w_retorno.nmarquiv         FORMAT "x(60)"    LABEL "ARQUIVO"
     SKIP(2)
     "RECEBIDOS"         AT 19
     "INTEGRADOS"        AT 38
     "REJEITADOS"        AT 58
     SKIP(1)
     "REGISTROS:"
     rel_qtdgeral        AT 22  FORMAT "zz,zz9" 
     rel_qtdcerto        AT 42  FORMAT "zz,zz9"
     rel_qtderros        AT 62  FORMAT "zz,zz9"
     SKIP(5)
     WITH DOWN NO-BOX SIDE-LABELS NO-LABELS FRAME f_relatorio.

ASSIGN glb_cdprogra = "crps479".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

{ includes/crps479.i }

RUN fontes/fimprg.p.

/* ......................................................................... */
