/* .............................................................................

   Programa: Includes/var_lanctr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/94.                         Ultima atualizacao: 21/01/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar a variaveis e frames da tela LANCTR - Lancamento de
               contratos de emprestimos.

   Alteracoes: 01/04/98 - Tratamento para milenio e troca para V8 (Margarete).
   
               19/01/99 - Variaveis para o IOF (Deborah).

               13/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               06/12/00 - Mostrar contratos avalizados pelo mesmo fiador
                                            (Margarete/Planner).
               
               03/07/01 - Alterar aux_titelavl p/ 61 posicoes (Junior).

               13/11/03 - Incluido campo Nivel de Risco(Mirtes).

               22/06/2004 - Obter conta/nomes avalistas Terceiros(Mirtes).

               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks - 
                            Eder
               08/04/2008 - Alterado formato da variavel "tel_qtpreemp" de
                            "z9" para "zz9" 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                                        
               22/01/2009 - Alteracao cdempres (Diego).

               26/06/2009 - Criadas variaveis/temp-table que serao usadas
                            nos emprestimos atrelados com boletos (Fernando).
                            
               28/04/2010 - inclusao da funcao K (Gati - Daniel).
               
               29/10/2012 - Inluir frame f_ge-economico para imprimir contas 
                            do GE (Lucas R.).
                            
               08/05/2013 - Ajuste no layout do frame f_ge-economico (Adriano).
               
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
                            
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
               
               21/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)             
............................................................................. */

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
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

DEF {1} SHARED VAR tel_nivrisco AS CHAR    FORMAT "x(02)"               NO-UNDO.
DEF {1} SHARED VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrctremp AS INT     FORMAT "zz,zzz,zz9"           NO-UNDO.
DEF {1} SHARED VAR tel_cdfinemp AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdlcremp AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_vlemprst AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlpreemp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtpreemp AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrctaav1 AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrctaav2 AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_reganter AS CHAR    FORMAT "x(76)" EXTENT 3      NO-UNDO.

DEF {1} SHARED VAR tel_avalist1 AS CHAR    FORMAT "x(18)"               NO-UNDO.
DEF {1} SHARED VAR tel_avalist2 AS CHAR    FORMAT "x(18)"               NO-UNDO.

DEF {1} SHARED VAR tel_flgpagto AS LOGICAL FORMAT "Folha/Conta"         NO-UNDO.

DEF {1} SHARED VAR tel_dtdpagto AS DATE    FORMAT "99/99/9999"          NO-UNDO.

DEF {1} SHARED VAR aux_dtmvtolt AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR aux_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR aux_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.

DEF {1} SHARED VAR aux_lsfinemp AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_insitlcr AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_insitfin AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_vlpreemp AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_txjurlcr AS DECIMAL DECIMALS 7                   NO-UNDO.
DEF {1} SHARED VAR aux_incalpre AS DECIMAL DECIMALS 5                   NO-UNDO.

DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.

DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgretor AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_flgdodia AS LOGICAL INIT TRUE  /* MFX do dia */  NO-UNDO.
DEF {1} SHARED VAR aux_regexist AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_ddmesnov AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_cdhistor AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_vllanmto AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_indebcre AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_inhistor AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tab_diapagto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_dtiniiof AS DATE FORMAT "99/99/9999"             NO-UNDO.
DEF {1} SHARED VAR tab_dtfimiof AS DATE FORMAT "99/99/9999"             NO-UNDO.
DEF {1} SHARED VAR tab_txiofepr AS DECIMAL FORMAT "zzzzzzzz9,999999"    NO-UNDO.

DEF {1} SHARED VAR tab_nrctabol AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_cdlcrbol AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultdia AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtmesant AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultpag AS DATE                                 NO-UNDO.

DEF {1} SHARED VAR aux_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctatos AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctremp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrultdia AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiacal AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiames AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiamss AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_ddlanmto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_qtempres AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_qtprepag AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrinssac AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_txdjuros AS DECIMAL DECIMALS 7                   NO-UNDO.
DEF {1} SHARED VAR aux_qtctarel AS INT FORMAT "zz9"                     NO-UNDO.

DEF {1} SHARED VAR h-b1crapsab  AS HANDLE                               NO-UNDO.
DEF {1} SHARED TEMP-TABLE cratsab NO-UNDO LIKE crapsab.

DEF {1} SHARED FRAME f_lanctr.
DEF {1} SHARED FRAME f_regant.
DEF {1} SHARED FRAME f_lanctos.

DEF        BUFFER crabass   FOR crapass.
DEF        BUFFER crabepr   FOR crapepr.
DEF        BUFFER crablcr   FOR craplcr.
DEF        BUFFER crablem   FOR craplem.
DEF        BUFFER crabavl   FOR crapavl.

DEF        VAR aux_nravlctr LIKE crapass.nrdconta                    NO-UNDO.
DEF        VAR aux_titelavl AS CHARACTER FORMAT "x(61)"              NO-UNDO.
DEF        VAR aux_qtlintel AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_tpdsaldo AS INT                                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.
DEF        VAR aux_qtprecal LIKE crapepr.qtprecal                    NO-UNDO.

DEF        VAR aux_qtctaavl AS INT                                   NO-UNDO.
DEF        VAR aux_avljaacu AS LOG                                   NO-UNDO.
DEF        VAR aux_aprovavl AS LOG  FORMAT "Sim/Nao"                 NO-UNDO.
DEF        VAR aux_cdempres AS INT                                   NO-UNDO.

DEF        VAR tab_indpagto AS INT                                   NO-UNDO.
DEF        VAR tab_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR tab_dtlimcal AS DATE                                  NO-UNDO.
DEF        VAR tab_flgfolha AS LOGICAL                               NO-UNDO.
DEF        VAR aux_inusatab AS LOGICAL                               NO-UNDO.

DEF TEMP-TABLE  w-emprestimo                                         NO-UNDO
    FIELD nrdconta LIKE crapepr.nrdconta
    FIELD nrctremp LIKE crapepr.nrctremp
    FIELD dtmvtolt LIKE crapepr.dtmvtolt
    FIELD vlemprst LIKE crapepr.vlemprst
    FIELD qtpreemp LIKE crapepr.qtpreemp
    FIELD vlpreemp LIKE crapepr.vlpreemp
    FIELD vlsdeved LIKE aux_vlsdeved.

DEF TEMP-TABLE tt-ge-economico 
    FIELD nrctasoc LIKE crapgrp.nrctasoc
    FIELD dsdrisgp LIKE crapgrp.dsdrisgp
    FIELD msgaviso AS CHAR.

DEF TEMP-TABLE tt-grupo-epr NO-UNDO LIKE crapgrp
    FIELD vlendivi AS DECI
    FIELD vlendigp AS DECI.

FORM SPACE(1)
     w-emprestimo.nrdconta  LABEL "Conta/dv"
     w-emprestimo.nrctremp  LABEL "Contrato"
     w-emprestimo.dtmvtolt  LABEL "Data"
     w-emprestimo.vlemprst  LABEL "Valor"           format ">>>,>>9.99"
     w-emprestimo.qtpreemp  LABEL "Qtd"  
     w-emprestimo.vlpreemp  LABEL "Vlr Prest" format ">>>,>>9.99"
     w-emprestimo.vlsdeved  LABEL "Saldo"           FORMAT "->>>,>>9.99"
     SPACE(1)
     WITH ROW 8 COLUMN 5 OVERLAY 9 DOWN NO-LABELS FRAME f_emprestimos
          TITLE aux_titelavl.

FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, E, I ou K)"
                        VALIDATE(CAN-DO("C,E,I,K",glb_cddopcao),
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
                        VALIDATE(CAN-FIND(crapban WHERE 
                                          crapban.cdbccxlt = tel_cdbccxlt), 
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
     "  Conta/dv   Contrato   Fin LC NV     Valor Emprestado" AT  2
     "Valor da Prestacao"                                     AT 60 SKIP
     "Qtd.Prest.      Forma      Inicio   Fiadores: Conta/CPF" AT  2
     "Conta/CPF   Seq."                                        AT 62
     SKIP(1)
     tel_nrdconta AT  2 NO-LABEL AUTO-RETURN
                        HELP "Entre com o numero da conta do associado."

     tel_nrctremp AT 14 NO-LABEL
                        HELP "Entre com o numero do contrato de emprestimo."

     tel_cdfinemp AT 26 NO-LABEL AUTO-RETURN
                        HELP "Entre com o codigo na finalidade do emprestimo."

     tel_cdlcremp AT 30 NO-LABEL AUTO-RETURN
                        HELP "Entre com o codigo da linha de credito"

     tel_nivrisco AT 35 NO-LABEL AUTO-RETURN
                        HELP "Entre com o Nivel de Risco."
     
     tel_vlemprst AT 38 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor do emprestimo."
                        VALIDATE(tel_vlemprst > 0,
                                 "091 - Valor do lancamento errado.")

     tel_vlpreemp AT 60 NO-LABEL AUTO-RETURN
                        HELP "Entre com o valor da prestacao do emprestimo."
     SKIP
     tel_qtpreemp AT 10 NO-LABEL
                        HELP "Entre com a quantidade de prestacoes"
     tel_flgpagto AT 18 NO-LABEL
         HELP '"F" para vincular `a folha ou "C" para debito em c/c.'

     tel_dtdpagto AT 27 NO-LABEL
                        HELP "Entre com a data do primeiro pagamento."

     tel_nrctaav1 AT 46 NO-LABEL AUTO-RETURN
                        HELP "Entre com a conta do primeiro fiador."

     tel_nrctaav2 AT 60 NO-LABEL AUTO-RETURN
                        HELP "Entre com a conta do segundo fiador."

     tel_nrseqdig AT 72 NO-LABEL
     tel_avalist1 AT 41 NO-LABEL 
     tel_avalist2 AT 60 NO-LABEL
     
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanctr.

FORM tel_reganter[1] AT  2 NO-LABEL
     tel_reganter[2] AT  2 NO-LABEL
     tel_reganter[3] AT  2 NO-LABEL
     WITH ROW 18 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM crapepr.nrdconta AT  2
     crapepr.nrctremp AT 16
     crapepr.cdfinemp AT 26
     crapepr.cdlcremp AT 32
     crapepr.vlemprst AT 38
     crapepr.vlpreemp AT 60
     WITH ROW 18 COLUMN 2 OVERLAY NO-LABEL NO-BOX 3 DOWN FRAME f_lanctos.

DEF QUERY q-ge-economico FOR tt-ge-economico.

DEF BROWSE b-ge-economico QUERY q-ge-economico
    DISPLAY tt-ge-economico.nrctasoc 
    WITH 3 DOWN WIDTH 15 NO-BOX NO-LABELS OVERLAY.

FORM "Conta"                                      AT 7
     tel_nrdconta
     "Pertence a Grupo Economico."              
     SKIP
     "Valor ultrapassa limite legal permitido."   AT 7
     SKIP
     "Verifique endividamento total das contas."  AT 7
     SKIP(1)
     "Grupo possui"                               AT 7
     aux_qtctarel
     "Contas Relacionadas:"         
     SKIP                           
     "-------------------------------------"      AT 7
     SKIP
     b-ge-economico      AT 18
     HELP "Pressione <F4> ou <END> p/ sair"
     WITH ROW 9 CENTERED NO-LABELS OVERLAY WIDTH 55 FRAME f_ge-economico.


/* .......................................................................... */

