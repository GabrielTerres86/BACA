/* .............................................................................

   Programa: Includes/var_lote.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                    Ultima atualizacao: 09/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis e forms da tela LOTE.

   Alteracoes: 22/06/94 - Alterado para incluir variavel auxiliar para a data
                          de debito.

               07/11/94 - Alterado para criar variavel auxiliar para a sequen-
                          cia do crapneg (Deborah).

               30/11/94 - Alterado para permitir entrada de tplotmov 10 e 11 e
                          chamar a tela LANRDA se o tipo de lote for 10 e
                          LANRGT se for 11 (Odair).

               29/05/95 - Alterado para nao mostrar a data do debito na tela
                          (Deborah).

               14/06/95 - Alterado para incluir o tipo de lote 12 (Odair).

               15/12/95 - Alterado para incluir o tipo de lote 13 (Odair).

               19/03/96 - Alterado para incluir o tipo de lote 14 (Odair).

               09/12/96 - Alterado para incluir o tipo de lote 15 (Odair).

               14/03/97 - Alterado para incluir o tipo de lote 16 (Odair).

               31/03/97 - Alterado para incluir o tipo de lote 17 (Deborah).

               24/11/97 - Alterado para incluir o tipo de lote 18 (Odair)

               02/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/10/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner). 

               05/01/2001 - Tratar tipo de lote 21 (Deborah).

               24/04/2001 - Tratar tipo de lote 23 - CHEQUES ACOLHIDOS (Edson).
 
               20/09/2001 - Eliminar histor 21 quando 386 (Margarete).

               16/05/2002 - Tratar novos historicos do prejuizo (Margarete).
               
               13/09/2002 - Incluir tipo de lote para DOC e TED (Margarete).

               19/03/2003 - Incluir tratamento da Concredi (Margarete).

               17/09/2004 - Aceitar tipo de lote 29(Mirtes).

               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               18/05/2007 - Alterado LABEL 9-APL para 9-RDC e chama tela LANRDC
                            quando inclui tipo de lote for 9 (Elton).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               18/09/2008 - Alterado Help de F8 para F7 e incluido na variavel
                            aux_proxtela a LANCDT (Guilherme).
                            
               15/07/2009 - Alteracao CDOPERAD (Diego).
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).           
                
               25/03/2010 - Incluir no help do historico o <F7> (Gabriel).     
               
               04/05/2010 - Desativadas as telas LANSEG e LANPPR. (Gabriel).
               
               12/03/2012 - Declarado variaveis necessarias para utilizacao
                            da include lelem.i (Tiago).                                                            
                                                       
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).  
			   
			   11/06/2018 - ajuste para o nrlote permitir 7 digitos  (INC0017046) - (Alcemir - Mout's).
			                   
............................................................................. */

DEF BUFFER crablem  FOR craplem.
DEF BUFFER crab2lem FOR craplem.

DEF {1} SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_cdhistor AS INT     FORMAT "zzz9"                NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxpg AS INT     FORMAT "zz9"                 NO-UNDO.

DEF {1} SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_tplotmov AS INT     FORMAT "z9"                  NO-UNDO.
DEF {1} SHARED VAR tel_dtmvtopg AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_nmoperad AS CHAR    FORMAT "x(18)"               NO-UNDO.

DEF {1} SHARED VAR tel_nrdcaixa AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdopecxa AS CHAR    FORMAT "x(10)"               NO-UNDO.

DEF {1} SHARED VAR tel_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tel_nrborder AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tab_diapagto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR tab_inusatab AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrdolote AS INT     FORMAT "zzzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_tplotmov AS INT     FORMAT "z9"                  NO-UNDO.
DEF {1} SHARED VAR aux_dtmvtopg AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT     FORMAT "z9"                  NO-UNDO.
DEF {1} SHARED VAR aux_cdtipcta AS INT     FORMAT "z9"                  NO-UNDO.
DEF {1} SHARED VAR aux_stimeout AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF {1} SHARED VAR aux_nmarquiv AS CHAR    FORMAT "x(8)"                NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_flgerros AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR aux_proxtela AS CHAR    FORMAT "x(6)" EXTENT 35 INIT
                   ["LANDPV","LANCAP","LANPLA","LANCTR","LANEMP","LANCON",
                    "LANLCR","LANCPL","LANRDC","LANRDA","LANRGT","LANAUT",
                    "LANFAT","","","LANCRD","LANCAR","LANCOB",
                    "LANCST","LANTIT","LANTIT","LOTE22","LANCHQ","TRFVAL",
                    "TRFVAL","LANBDC","LANCDC","","LANLCI","","","","",
                    "","LANCDT"]
                                                                        NO-UNDO.

DEF {1} SHARED VAR par_situacao AS LOGICAL                              NO-UNDO.
DEF {1} SHARED VAR par_qtexclln AS INT     FORMAT "zzzz9"               NO-UNDO.
DEF {1} SHARED VAR par_vlexcldb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR par_vlexclcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.

DEF {1} SHARED VAR aux_dtcalcul AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultdia AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtmesant AS DATE                                 NO-UNDO.
DEF {1} SHARED VAR aux_dtultpag AS DATE                                 NO-UNDO.

DEF {1} SHARED VAR aux_inliquid AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctatos AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrctremp AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrultdia AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiacal AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiames AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdiamss AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_ddlanmto AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_qtprepag AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR aux_nrseqneg AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"     NO-UNDO.
DEF {1} SHARED VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR aux_vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR aux_txdjuros AS DECIMAL DECIMALS 7                   NO-UNDO.

DEF {1} SHARED VAR aux_vlpreemp LIKE crapepr.vlpreemp                   NO-UNDO.
DEF {1} SHARED VAR aux_qtprecal LIKE crapepr.qtprecal                   NO-UNDO.
DEF {1} SHARED VAR aux_qtpreemp LIKE crapepr.qtpreemp                   NO-UNDO.
DEF {1} SHARED VAR aux_qtmesdec LIKE crapepr.qtmesdec                   NO-UNDO.

DEF {1} SHARED VAR aux_inhst093 AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR aux_lsconta1 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta2 AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_lsconta3 AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_qtinfocc AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_qtinfoci AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_qtinfocs AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR aux_vlinfocc AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR aux_vlinfoci AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR aux_vlinfocs AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.
DEF {1} SHARED VAR aux_dschqcop AS CHAR    FORMAT "x(20)"               NO-UNDO.
DEF {1} SHARED VAR tot_qtcheque AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tot_vlcheque AS DECIMAL FORMAT "zzz,zzz,zz9.99"      NO-UNDO.

DEF {1} SHARED VAR aux_flgpg391 AS LOGICAL                              NO-UNDO.

DEF {1} SHARED FRAME f_lote.

DEF {1} SHARED FRAME f_moldura.

DEF {1} SHARED FRAME f_debito.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao        AT  2 LABEL "Opcao" AUTO-RETURN
                              HELP "Informe a opcao desejada (A, C, E, I ou O)."
                               VALIDATE(CAN-DO("A,C,E,I,O",glb_cddopcao),
                                        "014 - Opcao errada.")

     tel_dtmvtolt        AT 12 LABEL "Data" AUTO-RETURN
                               HELP "Informe a data do movimento do lote."

     tel_cdagenci        AT 30 LABEL "PA"
                               HELP "Informe o codigo do PA."

     tel_cdbccxlt        AT 45 LABEL "Banco/Caixa"
                               HELP "Informe o codigo do banco ou caixa."

     tel_nrdolote        AT 64 LABEL "Lote"
                               HELP "Informe o numero do lote."
     SKIP(1)
     "Informado"         AT 29
     "Computado          Diferenca" AT 49
     SKIP(1)
     "Total de Lanctos:" AT  2
     tel_qtinfoln        AT 32 NO-LABEL AUTO-RETURN
                               HELP "Entre com a quantidade de lancamentos."

     tel_qtcompln        AT 52 NO-LABEL
     tel_qtdifeln        AT 71 NO-LABEL
     SKIP(1)
     "Total a  Debito :" AT 2
     tel_vlinfodb        AT 20 NO-LABEL AUTO-RETURN
                               HELP "Entre com o valor a debito."

     tel_vlcompdb        AT 40 NO-LABEL
     tel_vldifedb        AT 59 NO-LABEL
     SKIP(1)
     "Total a  Credito:" AT 2
     tel_vlinfocr        AT 20 NO-LABEL AUTO-RETURN
                               HELP "Entre com o valor a credito."

     tel_vlcompcr        AT 40 NO-LABEL
     tel_vldifecr        AT 59 NO-LABEL
     SKIP(1)
     "Tipo  do Lote   :" AT 2
     tel_tplotmov        AT 36 NO-LABEL
     " 1-DPV,  2-CAP,  3-PLA,  4-CTR,  5-EMP" AT 40 SKIP
     " 6-CON,       ,  8-CPL,  9-RDC, 10-RDA" AT 40 SKIP 
     /*
     "Data do debito  :" AT 2
     tel_dtmvtopg        AT 30 NO-LABEL AUTO-RETURN
                               HELP "Preencha somente se o tipo de lote for 6."
     */
     "Operador        :" AT 2
     tel_nmoperad        AT 20 NO-LABEL
     SKIP
     "Tecle F7 para ver os demais" AT 41 SKIP
     "tipos de lote."              AT 41
     WITH ROW 6 COLUMN 2 SIDE-LABELS NO-BOX OVERLAY WIDTH 78 FRAME f_lote.

FORM "Data do debito  :" AT  2
      tel_dtmvtopg       AT 28 NO-LABEL AUTO-RETURN
                         HELP  "Informe a data em que o lote deve ser debitado"
                         WITH ROW 18 COLUMN 2 OVERLAY NO-BOX
                         SIDE-LABELS FRAME f_data.

FORM "Data da liberacao:" AT  1
      tel_dtmvtopg        AT 28 NO-LABEL AUTO-RETURN
                    HELP "Informe a data em que os documentos serao liberados."
                         WITH ROW 18 COLUMN 2 OVERLAY NO-BOX
                         SIDE-LABELS FRAME f_data_custodia.

FORM "Data do debito  :" AT 2
      tel_dtmvtopg       AT 28 NO-LABEL AUTO-RETURN
                         HELP  "Informe a data em que o lote deve ser debitado"

      tel_cdhistor       AT 42 LABEL "Historico" AUTO-RETURN

        HELP "Informe o codigo do historico a ser debitado ou <F7> p/ listar."
                         VALIDATE(CAN-FIND(craphis WHERE
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = tel_cdhistor), 
                                           "093 - Historico errado")

      tel_cdbccxpg       AT 59 LABEL "Banco p/pagto" AUTO-RETURN
                         HELP "Informe o codigo do banco para pagamento"
                         VALIDATE(CAN-FIND(crapban WHERE 
                                           crapban.cdbccxlt = tel_cdbccxpg), 
                                           "057 - Banco nao Cadastrado.")
                         WITH ROW 20 COLUMN 2 OVERLAY NO-BOX
                         SIDE-LABELS FRAME f_debito.

FORM "Data do debito  :" AT 2
      tel_dtmvtopg       AT 28 NO-LABEL AUTO-RETURN
                         HELP  "Informe a data em que o lote deve ser debitado"
                         VALIDATE(tel_dtmvtopg <> ?,"013 - Data errada.")

      tel_cdhistor       AT 42 LABEL "Historico" AUTO-RETURN
        HELP "Informe o codigo do historico a ser debitado ou <F7> p/ listar."
                         VALIDATE(CAN-FIND(craphis WHERE
                                           craphis.cdcooper = glb_cdcooper AND
                                           craphis.cdhistor = tel_cdhistor), 
                                           "093 - Historico errado")
                         WITH ROW 20 COLUMN 2 OVERLAY NO-BOX
                         SIDE-LABELS FRAME f_fatura.

FORM SKIP(1) SPACE(05)
     tel_nrdcaixa  LABEL "Numero do Caixa"
                   VALIDATE(tel_nrdcaixa <> 0,
                            "Numero do caixa deve ser informado")
     SPACE(05) SKIP(1)  SPACE(02)
     tel_cdopecxa  LABEL " Operador do Caixa"
                   VALIDATE(CAN-FIND(crapope WHERE 
                                     crapope.cdcooper = glb_cdcooper   AND    
                                     crapope.cdoperad = tel_cdopecxa),
                                     "087 - Codigo do operador nao cadastrado.")
     SPACE(05) SKIP(1)
     WITH ROW 10  OVERLAY CENTERED TITLE " Boletim de Caixa "
                         SIDE-LABELS FRAME f_caixa.

FORM SKIP(1)
     aux_dschqcop AT  3 NO-LABEL
     aux_qtinfocc AT 24 NO-LABEL
     aux_vlinfocc AT 34 NO-LABEL
     SKIP(1)
     aux_qtinfoci AT  7 LABEL "Cheques Menores"
     aux_vlinfoci AT 34 NO-LABEL
     SKIP(1)
     aux_qtinfocs AT  7 LABEL "Cheques Maiores" 
     aux_vlinfocs AT 34 NO-LABEL 
     SKIP(1)
     tot_qtcheque AT  8 LABEL "TOTAL INFORMADO"
     tot_vlcheque AT 34 NO-LABEL
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY TITLE " Protocolo de Custodia "
          FRAME f_info.

FORM SKIP(1)
     tel_nrdconta AT 3 LABEL "Conta/dv" FORMAT "zzzz,zzz,9" AUTO-RETURN 
     "  "
     SKIP(1)
     WITH ROW 10 CENTERED OVERLAY SIDE-LABELS FRAME f_bordero.

/* .......................................................................... */

