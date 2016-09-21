/* ............................................................................

   Programa: fontes/aditiv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Outubro/2004                        Ultima atualizacao: 02/12/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ADITIV (Aditivos Contratuais)

   Observacao: A tabela CRAPTAB eh gravada (quando eh gravada) com o caractere
               "A" na posicao 10 do campo craptab.dstextab indicando que foi
               bloqueada pela tela ADITIV.

   Alteracoes:  23/11/2004 - Efetuado acerto na impressao do nro do aditivo
                             (Mirtes)
                26/11/2004 - Aceitar aditivos na proposta(Mirtes)

                10/12/2004 - Incluidos Tipos 7 e 8; Incluida opcao "V";
                             Alterados nomes dos aditivos;
                             F7 no nro do contrato;
                             Incluido titulo do aditivo na impressao (Evandro).

               17/12/2004 - Incluido o nome do associado no local da assinatura,
                            codigo e nome do operador;
                            Imprimir 2 vias (Evandro).

               22/12/2004 - Alterado tamanho do numero do aditivo na impressao;
                            (Evandro).

               14/01/2005 - Nao permitir alteracao da data de pagamento para
                            alem do mes corrente (Edson).

               09/03/2005 - Opcao 8 - Se nao existir avais no cad.proposta de
                            emprestimo, verificar avais no cad.emprestimo
                            (Contratos Antigos)(Mirtes)

               18/03/2005 - Opcao 5 - Solicitado se deseja eliminar o bem
                            anterior(substituicao)(Mirtes)

               25/04/2005 - Incluida Opcao "X" - Eliminacao bens alienados
                            por engano no contrato de emprestimo(sem aditivos
                            e somente permissao gerente)(Mirtes);
                            Alimentacao do campo "cdcooper" das tabelas na
                            criacao dos registros (Evandro).

              17/06/2005 - Retirada a opcao de atualizacao na tabela crawepr
                           quanto tipo 6.Apenas impressao do docto,pois o bem
                           sempre devera estar na proposta(Mirtes)

              11/07/2005 - Tipo de aditivo 8 nao permitir para Viacredi(Mirtes)

              08/08/2005 - Alterado para conectar com o banco generico ao
                           chamar o programa  fontes/aditiv_r.p (Diego).

              31/08/2005 - Tipo de aditivo 6 - nao permitir mais(Mirtes)

              20/09/2005 - Modificado FIND FIRST para FIND na tabela
                           crapcop.cdcooper = glb_cdcooper (Diego).

              27/09/2005 - Alterado para mostrar Data Inclusao Aditivo (Diego).

              17/10/2005 - Alterado para ler tbm nas tabelas crapadt e
                           crapadi o codigo da cooperativa (Diego).

              10/02/2006 - Unificacao dos bancos de dados - SQLWorks - Andre

              13/02/2006 - Inclusao do parametro glb_cdcooper para a chamada do
                           programa fontes/pedesenha.p - SQLWorks - Fernando.

              03/03/2006 - Corrigido escopo de transacao (Evandro).

              12/02/2007 - Alterado para nao permitir que data de debito do
                           emprestimo seje maior que dia 28 (Elton).

              05/04/2007 - Liberar aditivo tipo 8 para Viacredi(Mirtes)

              23/04/2007 - Baixar crapavs para emprestimos alterados de folha
                           para conta
                         - Controlar alteracao de data de pagamento atualizando
                           qtmesdec
                         - Retirada a opcao "A" - Altera (Julio)

              16/05/2007 - Para controle da data de pagamento, verificar
                           pagamentos no mes atraves do craplem (Julio)

              21/05/2007 - Permitido a inclusao de aplicacoes PRE e POS nos
                           aditivos 2 e 3 (Elton).

              16/08/2007 - Permitir alteracao de data de pagamento superior a
                           um mes para funcionarios da Bunge (empres 4)(Julio)

              11/10/2007 - Alterado HELP nos aditivos 2 e 3 para mostrar os
                           tipos de aplicacoes existentes (Elton).

              11/10/2007 - Nao permitir alterar mes e ano da data de pagamento
                           quando emprestimo for do tipo c/c (Julio)

              09/11/2007 - Subustituida verificacao do campo crapepr.qtprecal
                           por leitura na tabela craplem
                          (Procedure verifica_prestacoes_pagas) (Diego).

              04/07/2008 - Alterado help do tipo de aplicacao quando aplicacao
                           vinculada e vinculada terceiro. Nao permitir deixar
                           todos os campos de tipo de aplicacao e numero da
                           aplicacao em branco (Gabriel).

              20/09/2010 - Migrar os campos de alienaçao da crawepr para a
                           crapbpr. Retirar comentarios desnecessarios
                           (Gabriel)

              21/12/2010 - Permitir excluir o bem na substituicao de
                           veiculo (Gabriel).

               14/01/2010 - Ajuste no layout devido o aumento do campo nome
                            (Henrique).

              18/10/2011 - Adaptado fonte para o uso de BO. (Gabriel - DB1).

              27/02/2014 - Novos campos para o CPF na Substituicao Veiculo
                          (Tipo 5)
                           Campo incluido no frame f_tipo5, na procedure tipo5
                           e nos parametros da Grava_Dados e Valida_dados
                           da b1wgen0115 (Guilherme/SUPERO)

              22/05/2014 - Ajuste da posicao do frame de f_imprime na opcao
                           Consultar e no frame f_tipo5 (Guilherme/Supero)
                           
              03/06/2014 - Concatena o numero do servidor no endereco do
                           terminal (Tiago-RKAM).
                           
              08/11/2014 - Novos modelos de impressao (Jonata-RKAM).            

              02/03/2015 - Alterado formats do browse b_aplicacoes. (Reinert)

              27/03/2015 - Alterada procedure tipo_5 para executar LEAVE quando
                           NOK do Grava_Dados. Quando ocorria erro na exclusao
                           nao saia do DO WHILE TRUE  (Guilherme/SUPERO)
                           
              25/05/2015 - Incluir glb_cdagenci na grava_dados 
                           (Lucas Ranghetti #288277)
                           
              02/12/2015 - Retirar find da crapope na procedure Grava_Dados
                           (Lucas Ranghetti #366888 )
............................................................................ */

{ sistema/generico/includes/b1wgen0115tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{includes/gg0000.i}
{ sistema/ayllos/includes/verifica_caracter.i }

DEF STREAM str_1.

DEF VAR h-b1wgen0115 AS HANDLE                                      NO-UNDO.

DEF    VAR aux_idseqbem     AS INTE                                   NO-UNDO.
DEF    VAR aut_flgsenha     AS LOGICAL                                NO-UNDO.
DEF    VAR aut_cdoperad     AS CHAR                                   NO-UNDO.
DEF    VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.
DEF    VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.
DEF    VAR aux_confirma     AS CHAR    FORMAT "!(1)"                  NO-UNDO.
DEF    VAR aux_titulo       AS CHAR FORMAT "x(76)"                    NO-UNDO.

DEF    VAR aux_flgaplic     AS LOGICAL                                NO-UNDO.
DEF    VAR aux_nrctremp     AS INTE                                   NO-UNDO.
DEF    VAR aux_nraditiv     AS INTE                                   NO-UNDO.
DEF    VAR aux_contador     AS INTE                                   NO-UNDO.
DEF    VAR aux_nrdconta     AS INTE                                   NO-UNDO.

DEF    VAR tel_dtmvtolt     AS DATE    FORMAT "99/99/9999"            NO-UNDO.
DEF    VAR tel_dsaditiv     AS CHAR    FORMAT "x(36)"  EXTENT 8
           INIT ["1- Alteracao Data do Debito",
                 "2- Aplicacao Vinculada",
                 "3- Aplicacao Vinculada Terceiro",
                 "4- Inclusao de Fiador/Avalista",
                 "5- Substituicao de Veiculo",
                 "6- Interveniente Garantidor Veiculo",
                 "7- Sub-rogacao - C/ Nota Promissoria",
                 "8- Sub-rogacao - S/ Nota Promissoria"]              NO-UNDO.

/* variaveis para impressao */
DEF    VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5        NO-UNDO.
DEF    VAR rel_nmempres     AS CHAR    FORMAT "x(15)"                 NO-UNDO.
DEF    VAR rel_nrmodulo     AS INT     FORMAT "9"                     NO-UNDO.
DEF    VAR rel_nmmodulo     AS CHAR    FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]                  NO-UNDO.

DEF    VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF    VAR par_flgcance AS LOGICAL                                    NO-UNDO.
DEF    VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF    VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF    VAR aux_nmendter AS CHAR    FORMAT "x(20)"                     NO-UNDO.
DEF    VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF    VAR aux_flgescra AS LOGICAL                                    NO-UNDO.

DEF    VAR tel_dsdopcao AS CHAR    FORMAT "x(6)" EXTENT 5             NO-UNDO.
DEF    VAR aux_tpaplica AS INTE                                       NO-UNDO.
DEF    VAR aux_nrctagar AS INTE                                       NO-UNDO.

DEF    VAR tel_dspprogm AS CHAR    FORMAT "x(60)"                     NO-UNDO.
DEF    VAR tel_dsrdca30 AS CHAR    FORMAT "x(60)"                     NO-UNDO.
DEF    VAR tel_dsrdca60 AS CHAR    FORMAT "x(60)"                     NO-UNDO.
DEF    VAR tel_dsrdcpre AS CHAR    FORMAT "x(60)"                     NO-UNDO.
DEF    VAR tel_dsrdcpos AS CHAR    FORMAT "x(60)"                     NO-UNDO.

DEF    VAR aux_cdagenci AS INTE                                       NO-UNDO.

DEF    QUERY  q_opcao_v  FOR tt-aditiv.
DEF    BROWSE b_opcao_v  QUERY q_opcao_v
       DISPLAY tt-aditiv.nrdconta  LABEL "Conta/DV"
               tt-aditiv.nrctremp  LABEL "Contrato"
               tt-aditiv.dsaditiv  LABEL "Tipo do Aditivo"
               tt-aditiv.nraditiv  LABEL "Nro."     FORMAT "zz9"
               tt-aditiv.dtmvtolt  LABEl "Data"
               WITH 9 DOWN WIDTH 76 CENTERED NO-LABELS NO-BOX OVERLAY.

DEF TEMP-TABLE cratadi NO-UNDO LIKE tt-aditiv.

FORM SKIP(1)
     glb_cddopcao     AT  3 LABEL "Opcao"    AUTO-RETURN
                            HELP "Informe a opcao desejada (C, E, I, V, X)"
     SKIP(1)
     cratadi.nrdconta AT  3 LABEL "Conta/dv" AUTO-RETURN
                            HELP "Informe a Conta/DV ou F7 para pesquisar"

     cratadi.nrctremp AT 29 LABEL "Contrato" AUTO-RETURN
           HELP "Informe o numero do contrato / F7 para listar"

     tel_dtmvtolt     AT 55  LABEL "A partir de"
           HELP  "Informe a data de criacao dos Aditivos que deseja visualizar"

     SKIP(1)
     cratadi.nraditiv AT  3 LABEL "Aditivo "
                            HELP "Informe o numero do aditivo / F7 para listar"

     SKIP(1)
     cratadi.cdaditiv AT  3 LABEL "Tipo    "
                            HELP "Informe o tipo de aditivo"
     tel_dsaditiv     AT 22
     SKIP(1)
     WITH ROW 4 OVERLAY SIDE-LABELS NO-LABELS WIDTH 80 TITLE glb_tldatela
          FRAME f_aditiv.

FORM SKIP(1)
     tel_dsimprim AT 10
     tel_dscancel TO 30
     SKIP
     WITH ROW 18 CENTERED OVERLAY NO-LABELS WIDTH 40 NO-BOX FRAME f_imprime.

FORM SKIP(1)
     tel_dsimprim AT 10
     tel_dscancel TO 30
     SKIP(1)
     WITH ROW 13 CENTERED OVERLAY NO-LABELS WIDTH 40 FRAME f_imprime1.

FORM "Aguarde... Imprimindo..."
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     cratadi.dtmvtolt  AT 10 LABEL "Data Inclusao Aditivo"
     SKIP (1)
     cratadi.flgpagto  AT 10 LABEL "Debitar em"
                       HELP  "Entre com (F)OLHA DE PAGTO ou (C)ONTA CORRENTE."
     SKIP(1)
     cratadi.dtdpagto  AT 10 LABEL "Data Pagamento"
                       HELP  "Entre com a data do pagamento"
     SKIP(5)
     WITH ROW 8 OVERLAY SIDE-LABELS TITLE " 1- Alteracao da data do debito "
          WIDTH 50 CENTERED FRAME f_tipo1.

FORM SKIP(1)
     tt-aditiv.dscpfavl      AT 10 LABEL "Numero do CPF"
     SKIP(1)
     tt-aditiv.nmdavali  AT 7 LABEL "Nome do Avalista"
     SKIP(1)
     tt-aditiv.dtmvtolt  AT 2   LABEL "Data Inclusao Aditivo"
     SKIP(5)
     WITH ROW 8 OVERLAY SIDE-LABELS
          TITLE " 4- Alteracao de avalista/fiador "
          WIDTH 70 CENTERED FRAME f_tipo4.

FORM cratadi.dtmvtolt  AT  3 LABEL "Data Inclusao Aditivo"
     SKIP
     cratadi.dsbemfin  AT  3 LABEL "Automovel     "
                       HELP  "Entre com o automovel"
     SKIP
     cratadi.nrrenava  AT  3 LABEL "Renavan       "
                       HELP  "Entre com o numero do renavam"
     SKIP
     cratadi.tpchassi  AT  3 LABEL "Tipo Chassi   "
                       HELP  "Entre com o tipo do chassi (1-Remarcado/2-Normal)"
     SKIP
     cratadi.dschassi  AT  3 LABEL "Chassi        "
                       HELP  "Entre com o numero do chassi"
     SKIP
     cratadi.nrdplaca  AT  3 LABEL "Placa         "
                       HELP  "Entre com o numero da placa"
     SKIP
     cratadi.ufdplaca  AT  3 LABEL "UF Placa      "
                       HELP "Entre com a Unidade da Federacao (estado) da placa"
     SKIP
     cratadi.dscorbem  AT  3 LABEL "Cor           "
                       HELP  "Entre com a cor do veiculo"
     SKIP
     cratadi.nranobem  AT  3 LABEL "Ano           "
                       HELP  "Entre com o ano do veiculo"
     SKIP
     cratadi.nrmodbem  AT  3 LABEL "Modelo        "
                       HELP  "Entre com o modelo do veiculo"
     SKIP
     cratadi.uflicenc  AT  3 LABEL "UF Licenci.   "
                       HELP  "Entre com a UF (estado) do licenciamento"
     SKIP
     cratadi.nrcpfcgc  AT  3 LABEL "CPF/CNPJ Propr"
                       HELP "Entre com o CPF/CNPJ propr. interveniente"
     SKIP(2)
     WITH ROW 5 OVERLAY SIDE-LABELS WIDTH 62 CENTERED
          TITLE " 5- Substituicao de Veiculo - Alienacao " FRAME f_tipo5.

FORM cratadi.dtmvtolt  AT  5 LABEL "Data Inclusao Aditivo    "
     SKIP
     cratadi.nmdgaran  AT  5 LABEL "Nome do Interv.Garantidor"
                             HELP "Informe o nome do Interveniente Garantidor"
     SKIP
     cratadi.nrcpfgar  AT  5 LABEL "CPF Interv.Garantidor    "
                      HELP "Informe o numero do CPF do Interveniente Garantidor"
     SKIP
     cratadi.nrdocgar  AT  5 LABEL "Docto Interv.Garantidor  "
              HELP "Informe o numero da Identidade do Interveniente Garantidor"
     SKIP
     cratadi.dsbemfin  AT  5 LABEL "Automovel  "
                       HELP  "Entre com a descricao automovel"
     SKIP
     cratadi.nrrenava  AT  5 LABEL "Renavan    "
                       HELP  "Entre com o numero do renavam"
     SKIP
     cratadi.tpchassi  AT  5 LABEL "Tipo Chassi"
                       HELP  "Entre com o tipo do chassi (1-Remarcado/2-Normal)"
     cratadi.dschassi  AT 30 LABEL "Chassi"
                       HELP  "Entre com o numero do chassi"
     SKIP
     cratadi.nrdplaca  AT  5 LABEL "Placa      "
                       HELP  "Entre com o numero da placa"
     SKIP
     cratadi.ufdplaca  AT  5 LABEL "UF Placa   "
                       HELP "Entre com a Unidade da Federacao (estado) da placa"
     SKIP
     cratadi.dscorbem  AT  5 LABEL "Cor        "
                       HELP  "Entre com a cor do veiculo"
     SKIP
     cratadi.nranobem  AT  5 LABEL "Ano        "
                       HELP  "Entre com o ano do veiculo"
     cratadi.nrmodbem  AT 30 LABEL "Modelo"
                       HELP  "Entre com o modelo veiculo"
     cratadi.uflicenc  AT 50 LABEL "UF Licenci."
                       HELP  "Entre com a UF (estado) do licenciamento"
     SKIP(3)
     WITH ROW 5 OVERLAY SIDE-LABELS WIDTH 75 CENTERED
          TITLE " 6- Interveniente Garantidor - Veiculo de terceiro "
          FRAME f_tipo6.

FORM SKIP(1)
     cratadi.dtmvtolt AT 11     LABEL "Data Inclusao Aditivo"
     SKIP(1)
     cratadi.nrcpfgar AT 10 LABEL "CPF do Avalista       "
                            HELP  "Entre com o CPF do avalista"
     SKIP(1)
     "Nota Promissoria/Valor"        AT  5
     "Nota Promissoria/Valor"        AT 44
     SKIP
     cratadi.nrpromis[1]  AT  2 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[1]  AT 23 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     cratadi.nrpromis[2]  AT 41 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[2]  AT 62 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     SKIP
     cratadi.nrpromis[3]  AT  2 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[3]  AT 23 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     cratadi.nrpromis[4]  AT 41 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[4]  AT 62 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     SKIP
     cratadi.nrpromis[5]  AT  2 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[5]  AT 23 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     cratadi.nrpromis[6]  AT 41 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[6]  AT 62 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     SKIP
     cratadi.nrpromis[7]  AT  2 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[7]  AT 23 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     cratadi.nrpromis[8]  AT 41 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[8]  AT 62 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     SKIP
     cratadi.nrpromis[9]  AT  2 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[9]  AT 23 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     cratadi.nrpromis[10] AT 41 NO-LABEL
                                HELP  "Entre com o numero da nota promissoria"
     cratadi.vlpromis[10] AT 62 NO-LABEL
                                HELP  "Entre com o valor da nota promissoria"
     SKIP(3)
     WITH ROW 5 OVERLAY SIDE-LABELS WIDTH 78 CENTERED
          TITLE " 7- Sub-rogacao - C/ Nota Promissoria "
          FRAME f_tipo7.

FORM SKIP(1)
     cratadi.nrcpfgar    AT 10 LABEL "CPF do Avalista"
                               HELP  "Entre com o CPF do avalista"
     SKIP(1)
     cratadi.vlpromis[1] AT 10 LABEL "Valor Pago     "
                               HELP  "Entre com o valor da nota promissoria"
     SKIP(1)
     cratadi.dtmvtolt    AT 04 LABEL "Data Inclusao Aditivo"
     SKIP(3)
     WITH ROW 10 OVERLAY SIDE-LABELS WIDTH 58 CENTERED
          TITLE " 8- Sub-rogacao - S/ Nota Promissoria "
          FRAME f_tipo8.

DEF QUERY q_selecapl FOR tt-aplicacoes.

DEF BROWSE b_selecapl QUERY q_selecapl
    DISP tt-aplicacoes.flgselec NO-LABEL FORMAT "*/"
         tt-aplicacoes.dtmvtolt LABEL "Data"         FORMAT "99/99/99"
         tt-aplicacoes.dshistor LABEL "Historico"    FORMAT "x(9)"
         tt-aplicacoes.vlaplica LABEL "Valor"        FORMAT "zzz,zz9.99"
         tt-aplicacoes.nrdocmto LABEL "Docmto"       FORMAT "x(6)"
         tt-aplicacoes.dtvencto LABEL "Dt.Vencto"    FORMAT "99/99/99"
         tt-aplicacoes.vlsldapl LABEL "Saldo"        FORMAT "z,zzz,zz9.99"
         tt-aplicacoes.sldresga LABEL "Saldo p/Resg" FORMAT "z,zzz,zz9.99"
         WITH 6 DOWN NO-BOX NO-LABEL.

FORM b_selecapl
     HELP "Pressione ESPACO para selecionar ou F4 para continuar"
     SKIP
     WITH ROW 5 COL 1 WIDTH 80 OVERLAY CENTERED SIDE-LABELS
          TITLE " Escolha a aplicacao " FRAME f_selecao.

ON  ANY-KEY OF b_selecapl DO:

    IF  LASTKEY = 32 THEN /* ESPACO */
        DO:
            IF  AVAIL tt-aplicacoes  THEN
                DO:
                    IF  tt-aplicacoes.flgselec  THEN
                        ASSIGN tt-aplicacoes.flgselec:SCREEN-VALUE
                                 IN BROWSE b_selecapl = STRING(FALSE)
                               tt-aplicacoes.flgselec = FALSE.
                    ELSE
                        ASSIGN tt-aplicacoes.flgselec:SCREEN-VALUE
                                 IN BROWSE b_selecapl = STRING(TRUE)
                               tt-aplicacoes.flgselec = TRUE.
                END.

    END.
END.

DEF QUERY q_aplicacoes FOR tt-aplicacoes.

DEF BROWSE b_aplicacoes QUERY q_aplicacoes DISPLAY
           tt-aplicacoes.dtmvtolt LABEL "Data"         FORMAT "99/99/99"
           tt-aplicacoes.dshistor LABEL "Historico"    FORMAT "x(9)"
           tt-aplicacoes.vlaplica LABEL "Valor"        FORMAT "zzz,zz9.99"
           tt-aplicacoes.nrdocmto LABEL "Docmto"       FORMAT "x(6)"
           tt-aplicacoes.dtvencto LABEL "Dt.Vencto"    FORMAT "99/99/9999"
           tt-aplicacoes.vlsldapl LABEL "Saldo"        FORMAT "z,zzz,zz9.99"
           tt-aplicacoes.sldresga LABEL "Saldo p/Resg" FORMAT "z,zzz,zz9.99"
           WITH 5 DOWN NO-BOX NO-LABEL.

DEF VAR aux_title AS CHAR NO-UNDO.

FORM
    SKIP(1)
    tt-aditiv.nrctagar      AT  04  LABEL "Conta Interveniente Garantidor"
                                    HELP  "Entre com o numero da conta"
    SKIP
    tt-aditiv.dtmvtolt      AT  04   LABEL "Data Inclusao Aditivo"
    SKIP(1)
    "  Tipo Aplicacoes" AT 02
    SKIP
    "------ ------------------------------------------------------------" AT 02
    SKIP
    tel_dsdopcao[1] AT 02 NO-LABEL
        HELP "Pressione ENTER para listar 'P.PROG' ou F4 para continuar"
    tel_dspprogm AT 09 NO-LABEL
    SKIP
    tel_dsdopcao[2] AT 02 NO-LABEL
        HELP "Pressione ENTER para listar 'RDCA30' ou F4 para continuar"
    tel_dsrdca30 AT 09 NO-LABEL
    SKIP
    tel_dsdopcao[3] AT 02 NO-LABEL
        HELP "Pressione ENTER para listar 'RDCA60' ou F4 para continuar"
    tel_dsrdca60 AT 09 NO-LABEL
    SKIP
    tel_dsdopcao[4] AT 02 NO-LABEL
        HELP "Pressione ENTER para listar 'RDCPRE' ou F4 para continuar"
    tel_dsrdcpre AT 09 NO-LABEL
    SKIP
    tel_dsdopcao[5] AT 02 NO-LABEL
        HELP "Pressione ENTER para listar 'RDCPOS' ou F4 para continuar"
    tel_dsrdcpos AT 09 NO-LABEL
    SKIP(1)
    WITH ROW 6 CENTERED SIDE-LABELS OVERLAY TITLE aux_title WIDTH 71 FRAME f_inclusao.

FORM
    aux_titulo NO-LABEL AT 02
    SKIP
    tt-aditiv.nrctagar      AT  04  LABEL "Conta Interveniente Garantidor"
                                    HELP  "Entre com o numero da conta"
    SKIP
    tt-aditiv.dtmvtolt      AT  04   LABEL "Data Inclusao Aditivo"
    SKIP
    "---------------------------- Escolha a Aplicacao ----------------" AT 02
     SPACE(0)
     "-----------"
     SKIP
    b_aplicacoes
    HELP "Utilize as setas para navegar ou pressione F4 para continuar"
    SKIP
    "------------------------------------------------------------------" AT 02
     SPACE(0)
     "----------"
    SKIP
    WITH ROW 5 CENTERED SIDE-LABELS OVERLAY WIDTH 78 NO-BOX FRAME f_aplicacoes.

FORM SKIP(1)
     b_opcao_v  HELP "Use as SETAS para navegar ou F4 para sair"
     SKIP
     WITH ROW 6 CENTERED OVERLAY TITLE " Aditivos Contratuais "
          FRAME f_opcao_v.

FUNCTION f_normaliza_linha RETURN CHAR (INPUT par_dslinha AS CHAR):

    IF  LENGTH(par_dslinha) = 0 THEN
        RETURN par_dslinha.

    ASSIGN par_dslinha = SUBSTRING(par_dslinha,1,(LENGTH(par_dslinha) - 1)).

    IF  LENGTH(par_dslinha) > 60 THEN
        ASSIGN par_dslinha = SUBSTRING(par_dslinha,1,57)
               ENTRY(NUM-ENTRIES(par_dslinha,"/"),par_dslinha,"/") = "...".

    RETURN par_dslinha.

END FUNCTION.

DEF TEMP-TABLE tta-aplicacoes NO-UNDO LIKE tt-aplicacoes.

ASSIGN glb_cddopcao = "C"
       tel_dsdopcao[1] = "P.PROG"
       tel_dsdopcao[2] = "RDCA30"
       tel_dsdopcao[3] = "RDCA60"
       tel_dsdopcao[4] = "RDCPRE"
       tel_dsdopcao[5] = "RDCPOS".

RUN fontes/inicia.p.

Inicio: DO WHILE TRUE:

    EMPTY TEMP-TABLE cratadi.

    CREATE cratadi.
    ASSIGN cratadi.nrdconta = 0
           cratadi.nrctremp = 0
           cratadi.nraditiv = 0
           cratadi.nrctagar = 0
           cratadi.cdaditiv = 0
           cratadi.flgpagto = TRUE
           cratadi.dtdpagto = ?
           cratadi.dsbemfin = ""
           cratadi.dschassi = ""
           cratadi.nrdplaca = ""
           cratadi.dscorbem = ""
           cratadi.nranobem = 0
           cratadi.nrmodbem = 0
           cratadi.tpaplica = 0
           cratadi.nraplica = 0
           aux_flgaplic = NO
           cratadi.nrrenava = 0
           cratadi.tpchassi = 2
           cratadi.ufdplaca = ""
           cratadi.uflicenc = ""
           cratadi.nrcpfgar = 0
           cratadi.nrdocgar = ""
           cratadi.nmdgaran = ""
           cratadi.nrpromis = ""
           cratadi.vlpromis = 0
           tel_dtmvtolt = ?.

    IF  NOT VALID-HANDLE(h-b1wgen0115) THEN
        RUN sistema/generico/procedures/b1wgen0115.p
            PERSISTENT SET h-b1wgen0115.

    HIDE tel_dtmvtolt IN FRAME f_aditiv.
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        UPDATE glb_cddopcao WITH FRAME f_aditiv.
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "ADITIV" THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0115) THEN
                        DELETE OBJECT h-b1wgen0115.

                    HIDE FRAME f_aditiv.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  glb_cddopcao <> "C"   THEN
        DO:
            { includes/acesso.i }
        END.

    DISPLAY tel_dsaditiv WITH FRAME f_aditiv.

    Opcoes: DO WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
        
        IF  glb_cddopcao = "X"  THEN
            DO:
                HIDE cratadi.nraditiv IN FRAME f_aditiv.
                UPDATE  cratadi.nrdconta
                        cratadi.nrctremp
                        WITH FRAME f_aditiv

                EDITING:

                    DO WHILE TRUE:

                        READKEY PAUSE 1.

                        IF  LASTKEY = KEYCODE("F7") THEN
                            DO:
                                IF  FRAME-FIELD = "nrdconta" THEN
                                    DO:
                                        RUN fontes/zoom_associados.p
                                           ( INPUT  glb_cdcooper,
                                            OUTPUT aux_nrdconta).

                                        IF  aux_nrdconta > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nrdconta =
                                                                  aux_nrdconta.
                                                DISPLAY cratadi.nrdconta
                                                    WITH FRAME f_aditiv.
                                                PAUSE 0.
                                            END.
                                    END.
                                ELSE
                                IF FRAME-FIELD = "nrctremp"   THEN
                                    DO:
                                        RUN fontes/zoom_emprestimos.p
                                            ( INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT INPUT cratadi.nrdconta,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_dtmvtopr,
                                              INPUT glb_inproces,
                                             OUTPUT aux_nrctremp ).

                                        IF  aux_nrctremp > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nrctremp =
                                                                  aux_nrctremp.
                                                DISPLAY cratadi.nrctremp
                                                    WITH FRAME f_aditiv.
                                                PAUSE 0.
                                                APPLY "RETURN".
                                            END.
                                    END.
                            END. /* F7 */

                            APPLY LASTKEY.

                            LEAVE.

                        END. /* fim DO WHILE */
                    END. /* fim do EDITING */

            END.
        ELSE
        IF  glb_cddopcao = "I"  THEN
            DO:
                HIDE cratadi.nraditiv IN FRAME f_aditiv.
                UPDATE  cratadi.nrdconta
                        cratadi.nrctremp
                        WITH FRAME f_aditiv

                EDITING:

                    DO WHILE TRUE:

                        READKEY PAUSE 1.

                        IF  LASTKEY = KEYCODE("F7") THEN
                            DO:
                                IF  FRAME-FIELD = "nrdconta" THEN
                                    DO:
                                        RUN fontes/zoom_associados.p
                                           ( INPUT  glb_cdcooper,
                                            OUTPUT aux_nrdconta).

                                        IF  aux_nrdconta > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nrdconta =
                                                                  aux_nrdconta.
                                                DISPLAY cratadi.nrdconta
                                                    WITH FRAME f_aditiv.
                                                PAUSE 0.
                                            END.
                                    END.
                                ELSE
                                IF FRAME-FIELD = "nrctremp"   THEN
                                    DO:
                                        RUN fontes/zoom_emprestimos.p
                                            ( INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT INPUT cratadi.nrdconta,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_dtmvtopr,
                                              INPUT glb_inproces,
                                             OUTPUT aux_nrctremp ).

                                        IF  aux_nrctremp > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nrctremp =
                                                                  aux_nrctremp.
                                                DISPLAY cratadi.nrctremp
                                                    WITH FRAME f_aditiv.
                                                PAUSE 0.
                                                APPLY "RETURN".
                                            END.
                                    END.
                            END. /* F7 */

                        APPLY LASTKEY.

                        LEAVE.

                    END. /* fim DO WHILE */
                END. /* fim do EDITING */

                DO  WHILE TRUE:
                    UPDATE cratadi.cdaditiv WITH FRAME f_aditiv.
                    LEAVE.
                END.
            END.
        ELSE
            DO:
                IF  glb_cddopcao = "V" THEN
                    DO:
                        CLEAR FRAME f_aditiv NO-PAUSE.

                        DISPLAY glb_cddopcao WITH FRAME f_aditiv.
                        HIDE cratadi.cdaditiv cratadi.nraditiv IN FRAME f_aditiv.

                        UPDATE  cratadi.nrdconta
                                cratadi.nrctremp
                                tel_dtmvtolt
                                WITH FRAME f_aditiv
                        EDITING:

                            DO WHILE TRUE:
                                READKEY PAUSE 1.

                                IF  LASTKEY = KEYCODE("F7") THEN
                                    DO:
                                        IF  FRAME-FIELD = "nrdconta" THEN
                                            DO:
                                                RUN fontes/zoom_associados.p
                                                   ( INPUT  glb_cdcooper,
                                                    OUTPUT aux_nrdconta).

                                                IF  aux_nrdconta > 0   THEN
                                                    DO:
                                                        ASSIGN cratadi.nrdconta =
                                                                      aux_nrdconta.
                                                        DISPLAY cratadi.nrdconta
                                                            WITH FRAME f_aditiv.
                                                        PAUSE 0.
                                                    END.
                                            END.
                                        ELSE
                                        IF FRAME-FIELD = "nrctremp"   THEN
                                            DO:
                                                RUN fontes/zoom_emprestimos.p
                                                    ( INPUT glb_cdcooper,
                                                      INPUT 0,
                                                      INPUT 0,
                                                      INPUT glb_cdoperad,
                                                      INPUT INPUT cratadi.nrdconta,
                                                      INPUT glb_dtmvtolt,
                                                      INPUT glb_dtmvtopr,
                                                      INPUT glb_inproces,
                                                     OUTPUT aux_nrctremp ).

                                                IF  aux_nrctremp > 0   THEN
                                                    DO:
                                                        ASSIGN cratadi.nrctremp =
                                                                      aux_nrctremp.
                                                        DISPLAY cratadi.nrctremp
                                                            WITH FRAME f_aditiv.
                                                        PAUSE 0.
                                                    END.
                                            END.
                                    END. /* F7 */

                                    APPLY LASTKEY.

                                    LEAVE.

                            END. /* fim DO WHILE */

                        END. /* fim do EDITING */

                        RUN opcao_v.
                        NEXT Inicio.
                    END.

                HIDE cratadi.cdaditiv IN FRAME f_aditiv.


                UPDATE  cratadi.nrdconta
                        cratadi.nrctremp
                        cratadi.nraditiv
                        WITH FRAME f_aditiv

                EDITING:

                    DO WHILE TRUE:

                        READKEY PAUSE 1.

                        IF  LASTKEY = KEYCODE("F7")   THEN
                            DO:
                                IF  FRAME-FIELD = "nrdconta" THEN
                                    DO:
                                        RUN fontes/zoom_associados.p
                                           ( INPUT  glb_cdcooper,
                                            OUTPUT aux_nrdconta).

                                        IF  aux_nrdconta > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nrdconta =
                                                                  aux_nrdconta.
                                                DISPLAY cratadi.nrdconta
                                                    WITH FRAME f_aditiv.
                                                PAUSE 0.
                                            END.
                                    END.
                                ELSE
                                IF  FRAME-FIELD = "nraditiv"   THEN
                                    DO:
                                        HIDE MESSAGE.

                                        RUN fontes/zoom_aditivos.p
                                            ( INPUT glb_cdcooper,
                                              INPUT INPUT cratadi.nrdconta,
                                              INPUT INPUT cratadi.nrctremp,
                                             OUTPUT aux_nraditiv ).

                                        IF  aux_nraditiv > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nraditiv =
                                                        aux_nraditiv.

                                                DISPLAY cratadi.nraditiv WITH
                                                    FRAME f_aditiv.

                                                PAUSE 0.
                                            END.
                                    END.
                                ELSE
                                IF  FRAME-FIELD = "nrctremp"   THEN
                                    DO:
                                        HIDE MESSAGE.

                                        RUN fontes/zoom_emprestimos.p
                                            ( INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT INPUT cratadi.nrdconta,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_dtmvtopr,
                                              INPUT glb_inproces,
                                             OUTPUT aux_nrctremp ).

                                        IF  aux_nrctremp > 0   THEN
                                            DO:
                                                ASSIGN cratadi.nrctremp =
                                                            aux_nrctremp.
                                                DISPLAY cratadi.nrctremp
                                                    WITH FRAME f_aditiv.
                                                PAUSE 0.
                                            END.
                                    END.
                            END. /* F7 */

                            APPLY LASTKEY.

                            LEAVE.

                    END. /* fim DO WHILE */
                END. /* fim do EDITING */

            END.
        
        RUN Busca_Dados.
        
        IF  RETURN-VALUE <> "OK" THEN
            NEXT Opcoes.

        LEAVE Opcoes.

    END.  /* Fim Opcoes*/

    FIND FIRST tt-aditiv NO-ERROR.
    
    IF  AVAIL tt-aditiv THEN
        BUFFER-COPY tt-aditiv TO cratadi.
    
    CASE cratadi.cdaditiv:
        WHEN 1 THEN RUN tipo_1.
        WHEN 2 THEN RUN tipo_2.
        WHEN 3 THEN RUN tipo_3.
        WHEN 4 THEN RUN tipo_4.
        WHEN 5 THEN RUN tipo_5.
        WHEN 6 THEN RUN tipo_6.
        WHEN 7 THEN RUN tipo_7.
        WHEN 8 THEN RUN tipo_8.
        OTHERWISE
            IF  glb_cddopcao = "X" THEN
                RUN elimina_bens_alienados.
    END CASE.
END.

PROCEDURE imprime:

    PAUSE 0.

    IF (cratadi.cdaditiv = 2  OR
        cratadi.cdaditiv = 3) AND
        glb_cddopcao = "I"    THEN
        DO:
            DISPLAY      tel_dsimprim tel_dscancel  WITH FRAME f_imprime1.
            CHOOSE FIELD tel_dsimprim tel_dscancel  WITH FRAME f_imprime1.
        END.
    ELSE
        DO:
            DISPLAY      tel_dsimprim tel_dscancel  WITH FRAME f_imprime.
            CHOOSE FIELD tel_dsimprim tel_dscancel  WITH FRAME f_imprime.
        END.

    HIDE FRAME f_imprime  NO-PAUSE.
    HIDE FRAME f_imprime1 NO-PAUSE.

    IF  FRAME-VALUE = tel_dsimprim   THEN
        DO:
            VIEW FRAME f_aguarde.
            PAUSE 3 NO-MESSAGE.
        END.
    ELSE
        RETURN.

    RUN Gera_Impressao.

    RETURN "OK".

END PROCEDURE.

PROCEDURE tipo_1.

    IF  glb_cddopcao = "C"   THEN
        DO:
            DISPLAY cratadi.dtmvtolt cratadi.flgpagto
                    cratadi.dtdpagto WITH FRAME f_tipo1.
        END.
    ELSE
        DO:
            DISPLAY cratadi.flgpagto
                    " " @ cratadi.dtmvtolt WITH FRAME f_tipo1.

            DO  WHILE TRUE:

                IF  tt-aditiv.tpdescto = 2 THEN
                    UPDATE cratadi.dtdpagto WITH FRAME f_tipo1.
                ELSE
                    UPDATE cratadi.flgpagto
                           cratadi.dtdpagto WITH FRAME f_tipo1.

                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    NEXT.

                LEAVE.
            END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 NEXT.

        END.

    RUN Grava_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN.

    RUN imprime.

END PROCEDURE.

PROCEDURE tipo_2:

    EMPTY TEMP-TABLE tta-aplicacoes.

    ASSIGN tel_dspprogm = ""
           tel_dsrdca30 = ""
           tel_dsrdca60 = ""
           tel_dsrdcpre = ""
           tel_dsrdcpos = "".

    CLEAR FRAME f_inclusao NO-PAUSE.

    ASSIGN aux_titulo = "-------------------- 2- Deposito vinculado - " +
                        "Aplicacoes --------------------".

    IF  glb_cddopcao = "C" THEN
        DO:
            OPEN QUERY q_aplicacoes FOR EACH tt-aplicacoes NO-LOCK.

            IF  AVAIL tt-aditiv THEN
                DISPLAY aux_titulo
                        tt-aditiv.nrctagar
                        tt-aditiv.dtmvtolt
                   WITH FRAME f_aplicacoes.

            COLOR DISPLAY NORMAL tel_dsimprim tel_dscancel WITH FRAME f_imprime.
            DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_imprime.

            PAUSE(0).

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                SET b_aplicacoes WITH FRAME f_aplicacoes.
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

        END.
    ELSE
        DO WHILE TRUE:
            IF  glb_cddopcao = "E"   THEN
                DO:
                    RUN esconde-aditivos.

                    OPEN QUERY q_aplicacoes FOR EACH tt-aplicacoes NO-LOCK.

                    IF  AVAIL tt-aditiv THEN
                        DISPLAY aux_titulo
                                tt-aditiv.nrctagar
                                tt-aditiv.dtmvtolt
                           WITH FRAME f_aplicacoes.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        UPDATE b_aplicacoes WITH FRAME f_aplicacoes.
                        LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
                END.
            ELSE
                 DO WHILE TRUE:

                    ASSIGN aux_title = " 2- Deposito vinculado - Aplicacoes ".

                    IF  AVAIL tt-aditiv THEN
                        DISPLAY tt-aditiv.nrctagar
                                " " @ tt-aditiv.dtmvtolt
                                tel_dsdopcao
                           WITH FRAME f_inclusao.

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        HIDE FRAME f_selecao.

                        CHOOSE FIELD tel_dsdopcao WITH FRAME f_inclusao.

                        CASE FRAME-VALUE:
                            WHEN tel_dsdopcao[1] THEN ASSIGN aux_tpaplica = 1
                                                             tel_dspprogm = "".
                            WHEN tel_dsdopcao[2] THEN ASSIGN aux_tpaplica = 3
                                                             tel_dsrdca30 = "".
                            WHEN tel_dsdopcao[3] THEN ASSIGN aux_tpaplica = 5
                                                             tel_dsrdca60 = "".
                            WHEN tel_dsdopcao[4] THEN ASSIGN aux_tpaplica = 7
                                                             tel_dsrdcpre = "".
                            WHEN tel_dsdopcao[5] THEN ASSIGN aux_tpaplica = 8
                                                             tel_dsrdcpos = "".
                            OTHERWISE NEXT.
                        END CASE.

                        RUN Busca_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FOR EACH tta-aplicacoes:
                            FOR FIRST tt-aplicacoes WHERE
                                      tt-aplicacoes.nraplica =
                                                    tta-aplicacoes.nraplica AND
                                      tt-aplicacoes.tpaplica =
                                                       tta-aplicacoes.tpaplica:
                                ASSIGN tt-aplicacoes.flgselec = TRUE.
                                DELETE tta-aplicacoes.
                            END.
                        END.

                        OPEN QUERY q_selecapl FOR EACH tt-aplicacoes NO-LOCK.

                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE b_selecapl WITH FRAME f_selecao.
                                LEAVE.
                        END.

                        FOR EACH tt-aplicacoes WHERE tt-aplicacoes.flgselec
                            BY tt-aplicacoes.nraplica:

                            CASE tt-aplicacoes.tpaplica:
                                WHEN 1 THEN ASSIGN tel_dspprogm = tel_dspprogm +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 3 THEN ASSIGN tel_dsrdca30 = tel_dsrdca30 +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 5 THEN ASSIGN tel_dsrdca60 = tel_dsrdca60 +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 7 THEN ASSIGN tel_dsrdcpre = tel_dsrdcpre +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 8 THEN ASSIGN tel_dsrdcpos = tel_dsrdcpos +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                            END CASE.

                            CREATE tta-aplicacoes.
                            BUFFER-COPY tt-aplicacoes TO tta-aplicacoes.
                        END.

                        CASE aux_tpaplica:
                            WHEN 1 THEN ASSIGN tel_dspprogm =
                                                f_normaliza_linha(tel_dspprogm).
                            WHEN 3 THEN ASSIGN tel_dsrdca30 =
                                                f_normaliza_linha(tel_dsrdca30).
                            WHEN 5 THEN ASSIGN tel_dsrdca60 =
                                                f_normaliza_linha(tel_dsrdca60).
                            WHEN 7 THEN ASSIGN tel_dsrdcpre =
                                                f_normaliza_linha(tel_dsrdcpre).
                            WHEN 8 THEN ASSIGN tel_dsrdcpos =
                                                f_normaliza_linha(tel_dsrdcpos).
                        END CASE.

                        DISPLAY tel_dspprogm tel_dsrdca30
                                tel_dsrdca60 tel_dsrdcpre
                                tel_dsrdcpos WITH FRAME f_inclusao.

                    END.

                    IF  NOT TEMP-TABLE tta-aplicacoes:HAS-RECORDS THEN
                        RETURN.

                    RUN Valida_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    LEAVE.

                 END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 RETURN.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            LEAVE.

        END.

        IF  glb_cddopcao = "E" THEN
            RETURN.

    RUN imprime.

END PROCEDURE.

PROCEDURE tipo_3:

    ASSIGN tel_dspprogm = ""
           tel_dsrdca30 = ""
           tel_dsrdca60 = ""
           tel_dsrdcpre = ""
           tel_dsrdcpos = "".

    CLEAR FRAME f_inclusao NO-PAUSE.

    ASSIGN aux_titulo = "------------- 3- Deposito vinculado - Aplicacoes de" +
                        " terceiros --------------".

    IF  glb_cddopcao = "C" THEN
        DO:
            OPEN QUERY q_aplicacoes FOR EACH tt-aplicacoes NO-LOCK.

            IF  AVAIL tt-aditiv THEN
                DISPLAY aux_titulo
                        tt-aditiv.nrctagar
                        tt-aditiv.dtmvtolt
                    WITH FRAME f_aplicacoes.

            COLOR DISPLAY NORMAL tel_dsimprim tel_dscancel WITH FRAME f_imprime.
            DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_imprime.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                UPDATE b_aplicacoes WITH FRAME f_aplicacoes.
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

        END.
    ELSE
        DO WHILE TRUE:
            IF  glb_cddopcao = "E" THEN
                DO:
                    RUN esconde-aditivos.

                    OPEN QUERY q_aplicacoes FOR EACH tt-aplicacoes NO-LOCK.

                    IF  AVAIL tt-aditiv THEN
                        DISPLAY aux_titulo
                                tt-aditiv.nrctagar
                                tt-aditiv.dtmvtolt
                           WITH FRAME f_aplicacoes.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        UPDATE b_aplicacoes WITH FRAME f_aplicacoes.
                        LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
                END.
            ELSE
                DO WHILE TRUE:

                    ASSIGN aux_title =
                          " 3- Deposito vinculado -  Aplicacoes de terceiros ".

                    IF  AVAIL tt-aditiv THEN
                        DISPLAY tt-aditiv.nrctagar
                                " " @ tt-aditiv.dtmvtolt
                                tel_dsdopcao
                           WITH FRAME f_inclusao.

                    UPDATE tt-aditiv.nrctagar
                        WITH FRAME f_inclusao.

                    ASSIGN aux_nrctagar = tt-aditiv.nrctagar
                           cratadi.nrctagar = tt-aditiv.nrctagar.

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        HIDE FRAME f_selecao.

                        CHOOSE FIELD tel_dsdopcao WITH FRAME f_inclusao.

                        CASE FRAME-VALUE:
                            WHEN tel_dsdopcao[1] THEN ASSIGN aux_tpaplica = 1
                                                             tel_dspprogm = "".
                            WHEN tel_dsdopcao[2] THEN ASSIGN aux_tpaplica = 3
                                                             tel_dsrdca30 = "".
                            WHEN tel_dsdopcao[3] THEN ASSIGN aux_tpaplica = 5
                                                             tel_dsrdca60 = "".
                            WHEN tel_dsdopcao[4] THEN ASSIGN aux_tpaplica = 7
                                                             tel_dsrdcpre = "".
                            WHEN tel_dsdopcao[5] THEN ASSIGN aux_tpaplica = 8
                                                             tel_dsrdcpos = "".
                            OTHERWISE NEXT.
                        END CASE.

                        RUN Busca_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        FOR EACH tta-aplicacoes:
                            FOR FIRST tt-aplicacoes WHERE
                                      tt-aplicacoes.nraplica =
                                                    tta-aplicacoes.nraplica AND
                                      tt-aplicacoes.tpaplica =
                                                       tta-aplicacoes.tpaplica:
                                ASSIGN tt-aplicacoes.flgselec = TRUE.
                                DELETE tta-aplicacoes.
                            END.
                        END.

                        OPEN QUERY q_selecapl FOR EACH tt-aplicacoes NO-LOCK.

                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                UPDATE b_selecapl WITH FRAME f_selecao.
                                LEAVE.
                        END.

                        FOR EACH tt-aplicacoes WHERE tt-aplicacoes.flgselec
                            BY tt-aplicacoes.nraplica:

                            CASE tt-aplicacoes.tpaplica:
                                WHEN 1 THEN ASSIGN tel_dspprogm = tel_dspprogm +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                            "zzzz,zz9")) + "/".
                                WHEN 3 THEN ASSIGN tel_dsrdca30 = tel_dsrdca30 +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 5 THEN ASSIGN tel_dsrdca60 = tel_dsrdca60 +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 7 THEN ASSIGN tel_dsrdcpre = tel_dsrdcpre +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                                WHEN 8 THEN ASSIGN tel_dsrdcpos = tel_dsrdcpos +
                                             TRIM(STRING(tt-aplicacoes.nraplica,
                                                             "zzzz,zz9")) + "/".
                            END CASE.

                            CREATE tta-aplicacoes.
                            BUFFER-COPY tt-aplicacoes TO tta-aplicacoes.
                        END.

                        CASE aux_tpaplica:
                            WHEN 1 THEN ASSIGN tel_dspprogm =
                                                f_normaliza_linha(tel_dspprogm).
                            WHEN 3 THEN ASSIGN tel_dsrdca30 =
                                                f_normaliza_linha(tel_dsrdca30).
                            WHEN 5 THEN ASSIGN tel_dsrdca60 =
                                                f_normaliza_linha(tel_dsrdca60).
                            WHEN 7 THEN ASSIGN tel_dsrdcpre =
                                                f_normaliza_linha(tel_dsrdcpre).
                            WHEN 8 THEN ASSIGN tel_dsrdcpos =
                                                f_normaliza_linha(tel_dsrdcpos).
                        END CASE.

                        DISPLAY tel_dspprogm tel_dsrdca30
                                tel_dsrdca60 tel_dsrdcpre
                                tel_dsrdcpos WITH FRAME f_inclusao.

                    END.

                    IF  NOT TEMP-TABLE tta-aplicacoes:HAS-RECORDS THEN
                        RETURN.

                    RUN Valida_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    LEAVE.

                 END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF   aux_confirma <> "S"   THEN
                 RETURN.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            LEAVE.

        END.

    IF  glb_cddopcao = "E" THEN
        RETURN.

   RUN imprime.

END PROCEDURE.

PROCEDURE tipo_4:

    IF AVAIL tt-aditiv THEN
        DISPLAY tt-aditiv.dscpfavl tt-aditiv.nmdavali
                tt-aditiv.dtmvtolt WITH FRAME f_tipo4.

    PAUSE 0.
    DISPLAY      tel_dsimprim tel_dscancel  WITH FRAME f_imprime.
    CHOOSE FIELD tel_dsimprim tel_dscancel  WITH FRAME f_imprime.

    IF  FRAME-VALUE = tel_dsimprim   THEN
        DO:
            VIEW FRAME f_aguarde.
            PAUSE 3 NO-MESSAGE.
        END.
    ELSE
        RETURN.

    RUN Gera_Impressao.

    RETURN.

END PROCEDURE.

PROCEDURE tipo_5:

    IF  glb_cddopcao = "C"   THEN
        DO:
            IF  AVAIL tt-aditiv THEN
                DISPLAY  tt-aditiv.dtmvtolt @ cratadi.dtmvtolt
                         tt-aditiv.dsbemfin @ cratadi.dsbemfin
                         tt-aditiv.dschassi @ cratadi.dschassi
                         tt-aditiv.nrdplaca @ cratadi.nrdplaca
                         tt-aditiv.dscorbem @ cratadi.dscorbem
                         tt-aditiv.nranobem @ cratadi.nranobem
                         tt-aditiv.nrmodbem @ cratadi.nrmodbem
                         tt-aditiv.nrrenava @ cratadi.nrrenava
                         tt-aditiv.tpchassi @ cratadi.tpchassi
                         tt-aditiv.ufdplaca @ cratadi.ufdplaca
                         tt-aditiv.uflicenc @ cratadi.uflicenc
                         tt-aditiv.nrcpfcgc @ cratadi.nrcpfcgc
                    WITH FRAME f_tipo5.
        END.
    ELSE
        DO WHILE TRUE:
            IF  glb_cddopcao = "E"   THEN
                DO:
                    IF  AVAIL tt-aditiv THEN
                        DISPLAY  tt-aditiv.dtmvtolt @ cratadi.dtmvtolt
                                 tt-aditiv.dsbemfin @ cratadi.dsbemfin
                                 tt-aditiv.dschassi @ cratadi.dschassi
                                 tt-aditiv.nrdplaca @ cratadi.nrdplaca
                                 tt-aditiv.dscorbem @ cratadi.dscorbem
                                 tt-aditiv.nranobem @ cratadi.nranobem
                                 tt-aditiv.nrmodbem @ cratadi.nrmodbem
                                 tt-aditiv.nrrenava @ cratadi.nrrenava
                                 tt-aditiv.tpchassi @ cratadi.tpchassi
                                 tt-aditiv.ufdplaca @ cratadi.ufdplaca
                                 tt-aditiv.uflicenc @ cratadi.uflicenc
                                 tt-aditiv.nrcpfcgc @ cratadi.nrcpfcgc
                            WITH FRAME f_tipo5.
                END.
            ELSE
                DO:
                    DO WHILE TRUE:

                        DISPLAY " " @ cratadi.dtmvtolt WITH FRAME f_tipo5.

                        UPDATE cratadi.dsbemfin  cratadi.nrrenava
                               cratadi.tpchassi  cratadi.dschassi
                               cratadi.nrdplaca  cratadi.ufdplaca
                               cratadi.dscorbem  cratadi.nranobem
                               cratadi.nrmodbem  cratadi.uflicenc
                               cratadi.nrcpfcgc
                               WITH FRAME f_tipo5

                        EDITING:
                            READKEY.

                            IF   FRAME-FIELD = "dschassi"   THEN
                                 DO:
                                     IF  NOT fn_caracteres_validos(INPUT KEYFUNCTION(LASTKEY),
                                                                   INPUT "",
                                                                   INPUT "Q,I,O") THEN
                                         NEXT.
                                     ELSE
                                     DO:
                                         APPLY LASTKEY.
                                         ASSIGN cratadi.dschassi.
                                     END.
                                 END.
                            ELSE
                                 APPLY LASTKEY.
                        END.

                        RUN Valida_Dados.

                        IF  RETURN-VALUE <> "OK" THEN
                            NEXT.

                        LEAVE.

                    END.

                END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                NEXT.

            IF  glb_cddopcao = "I" THEN
                DO:
                    ASSIGN aux_confirma = "N"
                           aux_idseqbem = 0.

                    FOR EACH tt-aditiv WHERE tt-aditiv.idseqbem > 0:

                        RUN fontes/confirma.p
                                        (INPUT "EXCLUIR BEM ANTERIOR de Nro " +
                                            STRING(tt-aditiv.nrsequen) + " "  +
                                                   tt-aditiv.dsbemfin + " ?",
                                                        OUTPUT aux_confirma).

                        HIDE MESSAGE NO-PAUSE.

                        IF  aux_confirma = "S" THEN
                            DO:
                                ASSIGN aux_idseqbem = tt-aditiv.idseqbem.
                                LEAVE.
                            END.

                    END. /* FOR EACH tt-aditiv */

                END.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                IF  glb_cddopcao = "E" THEN
                    LEAVE.
                ELSE
                    NEXT.

            LEAVE.

        END.

        IF  glb_cddopcao = "E" THEN
            RETURN.

    RUN imprime.

END PROCEDURE.

PROCEDURE tipo_6:

    IF  glb_cddopcao = "C"   THEN
        DO:
            IF  AVAIL tt-aditiv THEN
                DISPLAY tt-aditiv.dtmvtolt @ cratadi.dtmvtolt
                        tt-aditiv.dsbemfin @ cratadi.dsbemfin
                        tt-aditiv.dschassi @ cratadi.dschassi
                        tt-aditiv.nrdplaca @ cratadi.nrdplaca
                        tt-aditiv.dscorbem @ cratadi.dscorbem
                        tt-aditiv.nranobem @ cratadi.nranobem
                        tt-aditiv.nrmodbem @ cratadi.nrmodbem
                        tt-aditiv.nrrenava @ cratadi.nrrenava
                        tt-aditiv.tpchassi @ cratadi.tpchassi
                        tt-aditiv.ufdplaca @ cratadi.ufdplaca
                        tt-aditiv.uflicenc @ cratadi.uflicenc
                        tt-aditiv.nrcpfgar @ cratadi.nrcpfgar
                        tt-aditiv.nrdocgar @ cratadi.nrdocgar
                        tt-aditiv.nmdgaran @ cratadi.nmdgaran
                        WITH FRAME f_tipo6.
        END.
    ELSE
        DO WHILE TRUE:
            IF  glb_cddopcao = "E" THEN
                DO:
                    IF  AVAIL tt-aditiv THEN
                        DISPLAY tt-aditiv.dtmvtolt @ cratadi.dtmvtolt
                                tt-aditiv.dsbemfin @ cratadi.dsbemfin
                                tt-aditiv.dschassi @ cratadi.dschassi
                                tt-aditiv.nrdplaca @ cratadi.nrdplaca
                                tt-aditiv.dscorbem @ cratadi.dscorbem
                                tt-aditiv.nranobem @ cratadi.nranobem
                                tt-aditiv.nrmodbem @ cratadi.nrmodbem
                                tt-aditiv.nrrenava @ cratadi.nrrenava
                                tt-aditiv.tpchassi @ cratadi.tpchassi
                                tt-aditiv.ufdplaca @ cratadi.ufdplaca
                                tt-aditiv.uflicenc @ cratadi.uflicenc
                                tt-aditiv.nrcpfgar @ cratadi.nrcpfgar
                                tt-aditiv.nrdocgar @ cratadi.nrdocgar
                                tt-aditiv.nmdgaran @ cratadi.nmdgaran
                                WITH FRAME f_tipo6.
                END.
            ELSE
                DO WHILE TRUE:
                    DISPLAY " " @ cratadi.dtmvtolt WITH FRAME f_tipo6.

                    UPDATE cratadi.nmdgaran  cratadi.nrcpfgar
                           cratadi.nrdocgar  cratadi.dsbemfin
                           cratadi.nrrenava  cratadi.tpchassi
                           cratadi.dschassi  cratadi.nrdplaca
                           cratadi.ufdplaca  cratadi.dscorbem
                           cratadi.nranobem  cratadi.nrmodbem
                           cratadi.uflicenc  WITH FRAME f_tipo6
                    EDITING:
                        READKEY.

                        IF   FRAME-FIELD = "dschassi"   THEN
                             DO:
                                 IF  NOT fn_caracteres_validos(INPUT KEYFUNCTION(LASTKEY),
                                                               INPUT "",
                                                               INPUT "Q,I,O") THEN
                                     NEXT.
                                 ELSE
                                 DO:
                                     APPLY LASTKEY.
                                     ASSIGN cratadi.dschassi.
                                 END.
                             END.
                        ELSE
                             APPLY LASTKEY.
                    END.


                    RUN Valida_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.

                    LEAVE.

                END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                LEAVE.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                NEXT.

            LEAVE.

        END.

    IF  glb_cddopcao = "E" THEN
        RETURN.

    RUN imprime.

END PROCEDURE.

PROCEDURE tipo_7:

    IF  glb_cddopcao = "C"   THEN
        DO:
            IF AVAIL tt-aditiv THEN
                DISPLAY tt-aditiv.nrcpfgar @ cratadi.nrcpfgar
                        tt-aditiv.dtmvtolt @ cratadi.dtmvtolt
                        tt-aditiv.nrpromis[1]  @ cratadi.nrpromis[1]
                        tt-aditiv.nrpromis[2]  @ cratadi.nrpromis[2]
                        tt-aditiv.nrpromis[3]  @ cratadi.nrpromis[3]
                        tt-aditiv.nrpromis[4]  @ cratadi.nrpromis[4]
                        tt-aditiv.nrpromis[5]  @ cratadi.nrpromis[5]
                        tt-aditiv.nrpromis[6]  @ cratadi.nrpromis[6]
                        tt-aditiv.nrpromis[7]  @ cratadi.nrpromis[7]
                        tt-aditiv.nrpromis[8]  @ cratadi.nrpromis[8]
                        tt-aditiv.nrpromis[9]  @ cratadi.nrpromis[9]
                        tt-aditiv.nrpromis[10] @ cratadi.nrpromis[10]

                        tt-aditiv.vlpromis[1]  @ cratadi.vlpromis[1]
                        tt-aditiv.vlpromis[2]  @ cratadi.vlpromis[2]
                        tt-aditiv.vlpromis[3]  @ cratadi.vlpromis[3]
                        tt-aditiv.vlpromis[4]  @ cratadi.vlpromis[4]
                        tt-aditiv.vlpromis[5]  @ cratadi.vlpromis[5]
                        tt-aditiv.vlpromis[6]  @ cratadi.vlpromis[6]
                        tt-aditiv.vlpromis[7]  @ cratadi.vlpromis[7]
                        tt-aditiv.vlpromis[8]  @ cratadi.vlpromis[8]
                        tt-aditiv.vlpromis[9]  @ cratadi.vlpromis[9]
                        tt-aditiv.vlpromis[10] @ cratadi.vlpromis[10]
                    WITH FRAME f_tipo7.
        END.
    ELSE
        DO WHILE TRUE:

            DO WHILE TRUE:
                IF  glb_cddopcao = "E" THEN
                    DO:
                        IF  AVAIL tt-aditiv THEN
                            DISPLAY tt-aditiv.nrcpfgar @ cratadi.nrcpfgar
                                    tt-aditiv.dtmvtolt @ cratadi.dtmvtolt
                                    tt-aditiv.nrpromis[1]  @ cratadi.nrpromis[1]
                                    tt-aditiv.nrpromis[2]  @ cratadi.nrpromis[2]
                                    tt-aditiv.nrpromis[3]  @ cratadi.nrpromis[3]
                                    tt-aditiv.nrpromis[4]  @ cratadi.nrpromis[4]
                                    tt-aditiv.nrpromis[5]  @ cratadi.nrpromis[5]
                                    tt-aditiv.nrpromis[6]  @ cratadi.nrpromis[6]
                                    tt-aditiv.nrpromis[7]  @ cratadi.nrpromis[7]
                                    tt-aditiv.nrpromis[8]  @ cratadi.nrpromis[8]
                                    tt-aditiv.nrpromis[9]  @ cratadi.nrpromis[9]
                                    tt-aditiv.nrpromis[10] @ cratadi.nrpromis[10]

                                    tt-aditiv.vlpromis[1]  @ cratadi.vlpromis[1]
                                    tt-aditiv.vlpromis[2]  @ cratadi.vlpromis[2]
                                    tt-aditiv.vlpromis[3]  @ cratadi.vlpromis[3]
                                    tt-aditiv.vlpromis[4]  @ cratadi.vlpromis[4]
                                    tt-aditiv.vlpromis[5]  @ cratadi.vlpromis[5]
                                    tt-aditiv.vlpromis[6]  @ cratadi.vlpromis[6]
                                    tt-aditiv.vlpromis[7]  @ cratadi.vlpromis[7]
                                    tt-aditiv.vlpromis[8]  @ cratadi.vlpromis[8]
                                    tt-aditiv.vlpromis[9]  @ cratadi.vlpromis[9]
                                    tt-aditiv.vlpromis[10] @ cratadi.vlpromis[10]
                                    WITH FRAME f_tipo7.
                    END.
                ELSE
                    DO:
                        DISPLAY " " @ cratadi.dtmvtolt WITH FRAME f_tipo7.
                        UPDATE  cratadi.nrcpfgar
                                cratadi.nrpromis[1]     cratadi.vlpromis[1]
                                cratadi.nrpromis[2]     cratadi.vlpromis[2]
                                cratadi.nrpromis[3]     cratadi.vlpromis[3]
                                cratadi.nrpromis[4]     cratadi.vlpromis[4]
                                cratadi.nrpromis[5]     cratadi.vlpromis[5]
                                cratadi.nrpromis[6]     cratadi.vlpromis[6]
                                cratadi.nrpromis[7]     cratadi.vlpromis[7]
                                cratadi.nrpromis[8]     cratadi.vlpromis[8]
                                cratadi.nrpromis[9]     cratadi.vlpromis[9]
                                cratadi.nrpromis[10]    cratadi.vlpromis[10]
                                WITH FRAME f_tipo7.
                    END.

                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    IF  glb_cddopcao = "E" THEN
                        RETURN.
                    ELSE
                        NEXT.

                LEAVE.

            END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                NEXT.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                IF  glb_cddopcao = "E" THEN
                    RETURN.
                ELSE
                    NEXT.

            LEAVE.

        END.

    IF  glb_cddopcao = "E" THEN
        RETURN.

    RUN imprime.

END PROCEDURE.

PROCEDURE tipo_8:

    IF  glb_cddopcao = "C"   THEN
        DO:
            IF  AVAIL tt-aditiv THEN
                DISPLAY tt-aditiv.nrcpfgar    @ cratadi.nrcpfgar
                        tt-aditiv.vlpromis[1] @ cratadi.vlpromis[1]
                        tt-aditiv.dtmvtolt    @ cratadi.dtmvtolt
                        WITH FRAME f_tipo8.
        END.
    ELSE
        DO WHILE TRUE:
            DO WHILE TRUE:
                IF  glb_cddopcao = "E"   THEN
                    DO:
                        IF  AVAIL tt-aditiv THEN
                            DISPLAY tt-aditiv.nrcpfgar    @ cratadi.nrcpfgar
                                    tt-aditiv.vlpromis[1] @ cratadi.vlpromis[1]
                                    tt-aditiv.dtmvtolt    @ cratadi.dtmvtolt
                                    WITH FRAME f_tipo8.
                    END.
                ELSE
                    DO:
                        DISPLAY " " @ cratadi.dtmvtolt WITH FRAME f_tipo8.

                        UPDATE  cratadi.nrcpfgar cratadi.vlpromis[1]
                            WITH FRAME f_tipo8.
                    END.

                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    IF  glb_cddopcao = "E" THEN
                        RETURN.
                    ELSE
                        NEXT.

                LEAVE.

            END.

            RUN fontes/confirma.p (INPUT "",
                                   OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN
                NEXT.

            RUN Grava_Dados.

            IF  RETURN-VALUE <> "OK" THEN
                IF  glb_cddopcao = "E" THEN
                    RETURN.
                ELSE
                    NEXT.

            LEAVE.

        END.

    IF  glb_cddopcao = "E" THEN
        RETURN.

    RUN imprime.

END PROCEDURE.

PROCEDURE opcao_v:

    RUN Busca_Dados.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN.

    OPEN QUERY q_opcao_v FOR EACH tt-aditiv.

    UPDATE b_opcao_v WITH FRAME f_opcao_v.

END PROCEDURE.

PROCEDURE elimina_bens_alienados:

    ASSIGN cratadi.cdaditiv = 5.

    FOR EACH tt-aditiv:

        DISPLAY tt-aditiv.dsbemfin @ cratadi.dsbemfin
                tt-aditiv.dschassi @ cratadi.dschassi
                tt-aditiv.nrdplaca @ cratadi.nrdplaca
                tt-aditiv.dscorbem @ cratadi.dscorbem
                tt-aditiv.nranobem @ cratadi.nranobem
                tt-aditiv.nrmodbem @ cratadi.nrmodbem
                tt-aditiv.nrrenava @ cratadi.nrrenava
                tt-aditiv.tpchassi @ cratadi.tpchassi
                tt-aditiv.ufdplaca @ cratadi.ufdplaca
                tt-aditiv.uflicenc @ cratadi.uflicenc
                tt-aditiv.nrcpfcgc @ cratadi.nrcpfcgc
            WITH FRAME f_tipo5.

        RUN fontes/confirma.p (INPUT "",
                               OUTPUT aux_confirma).

        IF  aux_confirma <> "S"   THEN
            NEXT.

        /* necessita da senha do gerente */
        RUN fontes/pedesenha.p ( INPUT glb_cdcooper,
                                 INPUT 3,
                                OUTPUT aut_flgsenha,
                                OUTPUT aut_cdoperad).

        IF  NOT aut_flgsenha   THEN
            LEAVE.

        ASSIGN aux_idseqbem = tt-aditiv.idseqbem.

        RUN Grava_Dados.

    END. /* FOR EACH tt-aditiv */

    RETURN.

END PROCEDURE.

PROCEDURE Busca_Dados:

    DEF VAR aux_qtregist AS INTE                            NO-UNDO.

    EMPTY TEMP-TABLE tt-aditiv.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0115) THEN
        RUN sistema/generico/procedures/b1wgen0115.p
            PERSISTENT SET h-b1wgen0115.
    
    RUN Busca_Dados IN h-b1wgen0115
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
          INPUT glb_cddopcao,
          INPUT cratadi.nrdconta,
          INPUT cratadi.nrctremp,
          INPUT tel_dtmvtolt,
          INPUT cratadi.nraditiv,
          INPUT cratadi.cdaditiv,
          INPUT aux_tpaplica,
          INPUT aux_nrctagar,
          INPUT NO, /* flgpagin */
          INPUT 0,
          INPUT 0,
          INPUT TRUE,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-aditiv,
         OUTPUT TABLE tt-aplicacoes,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    FIND FIRST tt-aditiv NO-ERROR.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Valida_Dados:

    DEF VAR aux_nmdgaran AS CHAR NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0115) THEN
        RUN sistema/generico/procedures/b1wgen0115.p
            PERSISTENT SET h-b1wgen0115.

    RUN Valida_Dados IN h-b1wgen0115
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /*idorigem*/
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT cratadi.nrdconta,
          INPUT cratadi.cdaditiv,
          INPUT cratadi.nrctremp,
          INPUT cratadi.dtdpagto,
          INPUT cratadi.flgpagto,
          INPUT cratadi.nrctagar,
          INPUT cratadi.nrcpfgar,
          INPUT cratadi.dsbemfin,
          INPUT cratadi.nrrenava,
          INPUT cratadi.tpchassi,
          INPUT cratadi.dschassi,
          INPUT cratadi.nrdplaca,
          INPUT cratadi.ufdplaca,
          INPUT cratadi.dscorbem,
          INPUT cratadi.nranobem,
          INPUT cratadi.nrmodbem,
          INPUT cratadi.uflicenc,
          INPUT cratadi.nrcpfcgc, /* GRAVAMES */
          INPUT cratadi.nmdgaran,
          INPUT cratadi.nrdocgar,
          INPUT cratadi.vlpromis[1],
          INPUT TRUE,
          INPUT TABLE tta-aplicacoes,
         OUTPUT cratadi.nmdgaran,
         OUTPUT aux_flgaplic,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE. /* Valida_Dados */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0115) THEN
        RUN sistema/generico/procedures/b1wgen0115.p
            PERSISTENT SET h-b1wgen0115.

    RUN Grava_Dados IN h-b1wgen0115
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /*idorigem*/
          INPUT glb_dtmvtolt,
          INPUT cratadi.nrdconta,
          INPUT 1, /*idseqttl*/
          INPUT glb_cddopcao,
          INPUT cratadi.nrctremp,
          INPUT cratadi.cdaditiv,
          INPUT cratadi.nraditiv,
          INPUT cratadi.flgpagto,
          INPUT cratadi.dtdpagto,
          INPUT aux_flgaplic,
          INPUT cratadi.nrctagar,
          INPUT cratadi.dsbemfin,
          INPUT cratadi.dschassi,
          INPUT cratadi.nrdplaca,
          INPUT cratadi.dscorbem,
          INPUT cratadi.nranobem,
          INPUT cratadi.nrmodbem,
          INPUT cratadi.nrrenava,
          INPUT cratadi.tpchassi,
          INPUT cratadi.ufdplaca,
          INPUT cratadi.uflicenc,
          INPUT cratadi.nrcpfcgc, /* GRAVAMES */
          INPUT aux_idseqbem,
          INPUT cratadi.nrcpfgar,
          INPUT cratadi.nrdocgar,
          INPUT cratadi.nmdgaran,
          INPUT cratadi.nrpromis,
          INPUT cratadi.vlpromis,
          INPUT TRUE,
          INPUT TABLE tta-aplicacoes,
         OUTPUT cratadi.nraditiv,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    IF  VALID-HANDLE(h-b1wgen0115) THEN
        DELETE OBJECT h-b1wgen0115.

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */


PROCEDURE Gera_Impressao:

    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
    SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.

    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.

    IF  NOT VALID-HANDLE(h-b1wgen0115) THEN
        RUN sistema/generico/procedures/b1wgen0115.p
            PERSISTENT SET h-b1wgen0115.

    RUN Gera_Impressao IN h-b1wgen0115
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT 1, /* idorigem */
          INPUT glb_nmdatela,
          INPUT glb_cdprogra,
          INPUT glb_cdoperad,
          INPUT aux_nmendter,
          INPUT cratadi.cdaditiv,
          INPUT cratadi.nraditiv,
          INPUT cratadi.nrctremp,
          INPUT cratadi.nrdconta,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
         OUTPUT aux_nmarqimp,
         OUTPUT aux_nmarqpdf,
         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".
        END.

    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

    /* imprimir 2 vias */
    ASSIGN glb_nrdevias = 1. /***DIEGO***/

    { includes/impressao.i }

    RETURN "OK".

END PROCEDURE. /* Gera_Impressao */

PROCEDURE esconde-aditivos:

    tel_dsaditiv[1]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[2]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[3]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[4]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[5]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[6]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[7]:VISIBLE IN FRAME f_aditiv = FALSE.
    tel_dsaditiv[8]:VISIBLE IN FRAME f_aditiv = FALSE.

END PROCEDURE.
/*...........................................................................*/


