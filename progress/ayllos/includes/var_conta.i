/* .............................................................................

   Programa: includes/var_conta.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/94.                    Ultima atualizacao: 13/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela CONTA.

   Alteracoes: 17/11/94 - Incluido a quantidade de dias de estouro (tot.dias)
                          na tela. (Deborah)

               28/03/96 - Alterado para nao mostrar a quantidade de extratos
                          do mes (qtextmes) (Deborah).

               03/07/97 - Alterado para tratar extrato quinzenal (Deborah).

               21/08/97 - Colocado HELP no campo cdgraupr (Deborah).

               20/03/98 - Tratamento para milenio e troca para V8 - (Margarete)
               
               19/10/98 - Tratar dados do segundo titular (Deborah).

               20/10/98 - Tratar dados do responsavel (Deborah).

               27/11/98 - Colocar Help no tipo e na sit. da conta (Deborah).

               23/12/98 - Melhorar help do tipo de conta (Deborah). 

               13/04/1999 - Tratar tipo de emissao dos avisos (Deborah). 

               16/10/2000 - Alterar fone para 20 posicoes (Margarete/Planner)

               15/01/2001 - Substituir CCOH por COOP (Margarete/Planner).
               
               22/05/2002 - Incluir variavel aux_dstextab (Junior).

               01/08/2002 - Incluir nova situacao da conta (Margarete).

               15/10/2002 - Incluir campos inarqcbr e dsdemail. Foram removidos
                            os campos tel_nmsecext, tel_nmpesext e tel_nrfonext
                            (Junior).
                            
               20/08/2004 - Modificado o HELP e o VALIDATE do campo 
                            crapass.tpextcta para permitir o valor 0 ou 1
                            (0-nao emite, 1-emite) (Evandro).
                            
               22/09/2004 - Incluir opcao T, cadastra titulares (Margarete).
               
               25/11/2004 - Tratamento E/OU no crapttl (Ze).
               
               28/12/2004 - Incluido campo tel_flgiddep (Evandro).
               
               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               22/02/2005 - Incluir opcao S, Sist.Financeiro Nacional(Evandro).
               
               13/12/2005 - Incluida opcao "E", Exclusao Conta Integracao
                            (Diego).
                            
               18/04/2006 - Alteracao no tel_inarqcbr (Ze).

               30/06/2006 - Substituicao do campo cartao, correspondente ao
                            cartao de cheque especial, pelo campo "Qtd. Folhas
                            Talao" (Julio)

               25/07/2006 - Incluido opcao "CH" no help e validate dos campos
                            tpdoc... (David).
                            
               22/08/2007 - Alterado cdgraupr da crapass para crapttl
                            (Guilherme).
                            
               10/12/2009 - Alterado inhabmen crapass p/ crapttl(Guilherme).
               
               05/01/2010 - Incluido FORMAT para o campo crapass.nmprimtl
                            (Diego).
                            
               26/07/2013 - Removido campo crapass.dsnatstl (Reinert).
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               13/12/2013 - Alterado form f_conta de "CPF/CGC" para "CPF/CNPJ".
                            (Reinert)
............................................................................. */

DEF {1} SHARED VAR shr_dsnatura AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR shr_inpessoa AS INT                               NO-UNDO.
DEF {1} SHARED VAR shr_cdtipcta LIKE craptip.cdtipcta                NO-UNDO.
DEF {1} SHARED VAR shr_dstipcta LIKE craptip.dstipcta                NO-UNDO.

DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"       NO-UNDO.
DEF {1} SHARED VAR tel_dsagenci AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_dsinadim AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dslbacen AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsgraupr AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmsecext AS CHAR    FORMAT "x(24)"            NO-UNDO.
DEF {1} SHARED VAR tel_nmpesext AS CHAR    FORMAT "x(20)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrfonext AS CHAR    FORMAT "X(20)"            NO-UNDO.
DEF {1} SHARED VAR tel_dstipcta AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF {1} SHARED VAR tel_dssitdct AS CHAR    FORMAT "x(25)"            NO-UNDO.
DEF {1} SHARED VAR tel_inmaicta AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_hacartao AS CHAR    FORMAT "x(1)"             NO-UNDO.
DEF {1} SHARED VAR tel_dsddsdev AS CHAR    FORMAT "x(10)"            NO-UNDO.
DEF {1} SHARED VAR tel_flgiddep AS LOGICAL FORMAT "S/N"              NO-UNDO.

DEF {1} SHARED VAR tel_inarqcbr AS INT     FORMAT "9"                NO-UNDO.
DEF {1} SHARED VAR tel_dsdemail AS CHAR    FORMAT "x(43)"            NO-UNDO.

DEF {1} SHARED VAR tel_dslimcre AS CHAR    FORMAT "x(02)"            NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfcgc AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz" NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfstl AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz" NO-UNDO.
DEF {1} SHARED VAR tel_nrcpfrsp AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz" NO-UNDO.
DEF {1} SHARED VAR tel_dtaltera AS DATE    FORMAT "99/99/99"         NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfcgc AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfstl AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR dis_nrcpfrsp AS CHAR    FORMAT "x(18)"            NO-UNDO.
DEF {1} SHARED VAR tel_qtfoltal AS INTEGER FORMAT "99"               NO-UNDO.

DEF {1} SHARED VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz9"        NO-UNDO.
DEF {1} SHARED VAR aux_cdtipcta AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_cdsitdct AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT     FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmsegntl AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_stimeout AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrseqdig AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_cdsecext AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_tpextcta AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrdeanos AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_nrdmeses AS INT                               NO-UNDO.
DEF {1} SHARED VAR aux_dsdidade AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR FORMAT "x"                   NO-UNDO. 
DEF {1} SHARED VAR aux_dstextab AS CHAR                              NO-UNDO.
DEF {1} SHARED VAR aux_nmsegttl AS CHAR                              NO-UNDO.

DEF {1} SHARED VAR par_cdcritic AS INTE                              NO-UNDO.

DEF {1} SHARED FRAME f_conta.

DEF BUFFER crabttl5 FOR crapttl.

FORM glb_cddopcao      AT  1 LABEL "Opcao"  AUTO-RETURN
                             HELP "Opcao desejada (A,C,E,S ou T)"
                             VALIDATE(CAN-DO("A,C,E,S,T",glb_cddopcao),
                                      "014 - Opcao errada.")
     tel_nrdconta      AT 10 LABEL "conta/dv"
                             HELP "Numero da conta do associado"
     crapass.cdagenci  AT 33 LABEL "PA"
     "-"               AT 40
     tel_dsagenci      AT 42 NO-LABEL
     crapass.nrmatric  AT 58 LABEL "matr" 
     crapass.indnivel  AT 73 LABEL "niv"
     SKIP    
     crapass.nmprimtl  AT  1 LABEL "titular "  FORMAT "x(40)"
     "CPF/CNPJ:"       AT 52
     tel_nrcpfcgc      AT 61 NO-LABEL 
     crapass.cdtipcta  AT  1 LABEL "tipo de conta" 
     HELP "Entre com o tipo de conta ou F7 para listar"
     "-"               
     tel_dstipcta      NO-LABEL
     crapass.cdsitdct  LABEL "sit." 
       HELP "1-Nor,2-Enc.Ass,3-Enc.COOP,4-Enc.Dem,5-Nao aprov,6-S/Tal,9-Outros"      "-"               
     tel_dssitdct      NO-LABEL
     crapass.tpavsdeb  LABEL "av."
     SKIP
/*     crapass.tpextcta  LABEL "ext"
                       HELP "Tipo de extrato de conta (0-nao emite, 1-emite)"
                       VALIDATE (crapass.tpextcta = 0 OR
                                 crapass.tpextcta = 1,
                                 "264 - Tipo de extrato errado")*/
     crapass.tpextcta  LABEL "ext"
                       VALIDATE (crapass.tpextcta = 0 OR
                                 crapass.tpextcta = 1 OR
                                 crapass.tpextcta = 2,
                                 "264 - Tipo de extrato errado")
                       
     crapass.cdsecext  LABEL "dest" 
     tel_inarqcbr      LABEL "cobr." 
     HELP "0-Nao recebe arq cobranca por e-mail / 1-Outros / 2-FEBRABAN" 
     tel_dsdemail      LABEL "e-mail "
     HELP "Entre com o e-mail do associado"
     SKIP
     crapass.nmsegntl  AT  1 LABEL "segundo titular   " 
     crapass.tpdocstl  AT  1 LABEL "documento   " 
                             HELP "Entre com CH, CI, CP, CT"
     
     crapass.nrdocstl        NO-LABEL FORMAT "x(15)" 
     crapass.cdoedstl        LABEL " org.emissor" 
     crapass.cdufdstl        LABEL "U.F."
     crapass.dtemdstl        LABEL "data" 
     crapass.dtnasstl  AT 1  LABEL "nascimento  "
                             FORMAT "99/99/9999"
     crapttl.cdgraupr  AT 48 LABEL "parentesco" 
                             HELP
             "1-Conjuge,2-Pai/Mae,3-Filho(a),4-Companheiro(a),9-Nenhum"

     tel_dsgraupr            NO-LABEL
                             HELP "Informe o grau de parentesco"
     crapass.dsfilstl  AT  1 LABEL "filiacao    " FORMAT "x(64)"
     "CPF/CNPJ:"       AT 52
     tel_nrcpfstl      AT 61 NO-LABEL 
                                HELP "Entre com o CPF do segundo titular"
                                
     crapass.nmrespon        LABEL "respons."
     "CPF/CNPJ:"       AT 52         
     tel_nrcpfrsp      AT 61 NO-LABEL 
     crapass.tpdocrsp        LABEL "documento   " 
                             VALIDATE (crapass.tpdocrsp = ""   OR
                                       crapass.tpdocrsp = "CH" OR
                                       crapass.tpdocrsp = "CP" OR
                                       crapass.tpdocrsp = "CI" OR              
                                       crapass.tpdocrsp = "CT",
                                       "021 - Tipo de documento errado")
                             HELP "Entre com CH, CI, CP, CT"

     crapass.nrdocrsp        NO-LABEL FORMAT "x(15)" 
     crapass.cdoedrsp        LABEL " org.emissor"
     crapass.cdufdrsp        LABEL "U.F."
     crapass.dtemdrsp        LABEL "data" 
     crapass.dtcnsspc  AT  1 LABEL "consulta SPC" 
                             FORMAT "99/99/9999"
     crapass.dtdsdspc        LABEL "no SPC p/COOP" 
                             FORMAT "99/99/9999"
     crapass.dtabtcct        LABEL "abert.cta" FORMAT "99/99/9999"
     "ultimas alteracoes:"
     crapass.dtatipct  AT 29 LABEL "tipo conta" FORMAT "99/99/9999"
     crapass.dtultlcr        LABEL "lim.cred." FORMAT "99/99/9999"
     crapass.dtasitct  AT 5  LABEL "situacao conta" FORMAT "99/99/9999"
     tel_dtaltera            LABEL " recad." FORMAT "99/99/9999"
     tel_dslimcre            LABEL "lim.cred."
     crapass.vllimcre        NO-LABEL FORMAT "zz,zzz,zz9.99" 
     crapsld.qtddtdev  AT  1 LABEL "tot.dias"
     crapsld.dtdsdclq  AT 16 LABEL "cred.liq" FORMAT "99/99/9999"
     tel_dsddsdev            NO-LABEL
     tel_qtfoltal      AT 58 LABEL "Qtd. Folhas Talao"
                 HELP "Informe a quantidade de folhas para o talao de cheques."
                             VALIDATE(tel_qtfoltal = 10 OR tel_qtfoltal = 20,
                                      'Quantidade de folhas deve ser 10 ou 20')
     SKIP 
     tel_dsinadim      AT  1 LABEL "inadimpl:   esta no SPC" 
                             HELP "Informe S para SIM ou N para NAO"
                             VALIDATE(CAN-DO("S,N",tel_dsinadim),
                                      '024 - Deve ser "S" ou "N".')

     tel_dslbacen      AT 28 LABEL "/ CCF" 
                             HELP "Informe S para SIM ou N para NAO"
                             VALIDATE(CAN-DO("S,N",tel_dslbacen),
                                      '024 - Deve ser "S" ou "N".')

     tel_flgiddep      AT 36 LABEL " / Id.Dep"
        HELP "Identificacao Deposito (Obrigatoriedade) - S p/ SIM ou N p/ NAO"
     tel_inmaicta            LABEL "  mais contas" 
     crapttl.inhabmen        LABEL " hab.menor" 
     WITH ROW 4 OVERLAY SIDE-LABELS WIDTH 80 TITLE glb_tldatela FRAME f_conta.

/* .......................................................................... */
