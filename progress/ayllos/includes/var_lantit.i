/* .............................................................................

   Programa: Includes/var_lantit.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao: 16/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela LANTIT.

   Alteracoes: 13/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               10/01/2001 - Criado novo campo tplotmov (Deborah).

               30/03/2001 - Acrescentar campo para o fator de vencimento no
                            codigo de barras. (Ze Eduardo).

               23/10/2002 - Pedir autenticacao quando caixa (Margarete).

               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               23/11/2009 - Alteracao Codigo Historico (Kbase). 
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
............................................................................. */

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_dtvencto AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.

DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdlinha AS CHAR    FORMAT "x(54)"               NO-UNDO.
DEF {1} SHARED VAR tel_dscodbar AS CHAR    FORMAT "x(44)"               NO-UNDO.
DEF {1} SHARED VAR tel_vldpagto AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zzzz9"               NO-UNDO.
DEF {1} SHARED VAR tel_dtdpagto AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_nrautdoc LIKE craptit.nrautdoc                   NO-UNDO.

DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(76)" EXTENT 2      NO-UNDO.

DEF {1} SHARED VAR tel_nrcampo1 AS DECIMAL FORMAT "9999999999"          NO-UNDO.
DEF {1} SHARED VAR tel_nrcampo2 AS DECIMAL FORMAT "99999999999"         NO-UNDO.
DEF {1} SHARED VAR tel_nrcampo3 AS DECIMAL FORMAT "99999999999"         NO-UNDO.
DEF {1} SHARED VAR tel_nrcampo4 AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_nrcampo5 AS DECIMAL FORMAT "zzzzzzzzzzz999"      NO-UNDO.
DEF {1} SHARED VAR tel_nrcampo6 AS DECIMAL FORMAT "99999999999999"      NO-UNDO.

DEF {1} SHARED VAR tab_intransm AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_hrlimite AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtlibera AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_tplotmov AS INT     FORMAT "z9"                  NO-UNDO.
DEF {1} SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.

DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagebcb AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_lsvalido AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdigver AS INT                                  NO-UNDO.

DEF {1} SHARED FRAME f_lantit.
DEF {1} SHARED FRAME f_regant.
DEF {1} SHARED FRAME f_lanctos.

aux_lsvalido = "1,2,3,4,5,6,7,8,9,0,RETURN,F4,CURSOR-LEFT,CURSOR-RIGHT".

FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, I, M, R ou X)"
                        VALIDATE(CAN-DO("A,C,E,I,M,R,X",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE 
                                          crapage.cdcooper = glb_cdcooper   AND
                                          crapage.cdagenci = tel_cdagenci), 
                                          "962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE 
                                          crapbcl.cdbccxlt = tel_cdbccxlt), 
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote > 0,
                                "058 - Numero do lote errado.")
     SKIP(1)
     tel_qtinfoln AT  2 LABEL "Informado:Qtd"
     tel_vlinfodb AT 24 LABEL "Debito"
     tel_vlinfocr AT 51 LABEL "Credito"
     SKIP
     tel_qtcompln AT  2 LABEL "Computado:Qtd"
     tel_vlcompdb AT 24 LABEL "Debito"
     tel_vlcompcr AT 51 LABEL "Credito"
     SKIP
     tel_qtdifeln AT  2 LABEL "Diferenca:Qtd"
     tel_vldifedb AT 24 LABEL "Debito"
     tel_vldifecr AT 51 LABEL "Credito"
     SKIP(1)
     tel_cdhistor AT  2 LABEL "Hist." 
                        HELP "Entre com o historico do titulo."
                        VALIDATE(CAN-FIND(craphis WHERE
                                          craphis.cdcooper = glb_cdcooper AND
                                          craphis.cdhistor = tel_cdhistor),
                                          "526 - Historico nao encontrado.")
                                 
     tel_nrdconta AT 15 LABEL "Associado"   
                        HELP "Entre com a conta do associado."
                                 
     tel_nmprimtl AT 37 NO-LABEL
     SKIP(1)
     tel_dscodbar AT  2 LABEL "Codigo de barras"
                        HELP "Passe o titulo pela leitora."
     tel_dtdpagto AT 67 NO-LABEL
     SKIP(1)
     "Linha digitavel:"  AT  2
     "Valor Pago   Seq." AT 61
     SKIP(1)
     tel_dsdlinha AT 02 NO-LABEL

     tel_vldpagto AT 57 NO-LABEL
                        HELP "Entre com o valor total pago."
                        VALIDATE(tel_vldpagto > 0,
                                 "269 - Valor errado.")
                         
     tel_nrseqdig AT 72 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lantit.

FORM tel_reganter[1] AT  2 NO-LABEL  
     tel_reganter[2] AT  2 NO-LABEL
     WITH ROW 19 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM tel_dsdlinha     FORMAT "x(56)"          LABEL "Linha digitavel"
     craptit.vldpagto FORMAT "zzzzzz,zz9.99"  LABEL "Valor Pago"
     craptit.nrseqdig FORMAT "zzzz9"          LABEL "Seq."
     WITH ROW 8 COLUMN 3 OVERLAY NO-LABEL NO-BOX 11 DOWN FRAME f_lanctos.

FORM tel_nrautdoc  LABEL "Autenticacao NRO."
                   HELP "Informe o numero da autenticacao."
                   VALIDATE(tel_nrautdoc > 0,
                            "375 - O campo deve ser preenchido")
     WITH ROW 16 CENTERED OVERLAY SIDE-LABELS FRAME f_autentica.

/* .......................................................................... */

