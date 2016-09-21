/*............................................................................

   Programa: Includes/var_manccf.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo
   Data    : Dezembro/01.                        Ultima atualizacao: 11/10/2012
   Dados referentes ao programa:


   Frequencia: Diario (On-line)
   Objetivo  : Criar as variaveis e form da tela MANCCF.

   Alteracoes: 08/05/2003 - Alteracao do nome do Banco - Concredi (Ze Eduardo).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               19/02/2004 - Ajustes no na carta de regularizacao (Julio).

               07/06/2005 - Tratamento para Conta Integracao (Evandro).
               
               05/12/2005 - Incluida "aux_chqctitg", "tel_cdagenci" e
                            "aux_tldatela" (Evandro).
                            
               26/01/2006 - Retirado o LABEL para conta = 0 (Evandro).

               10/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               15/02/2006 - Incluido campo 'flgselec' na temp-table para
                            controlar a selecao de cheques (Evandro).
                            
               17/01/2007 - Incluida a coluna "SIT" na temp=-table para a
                            situacao do registro (Evandro).

               15/02/2007 - Incluidas variaveis rel_cdbanchq e rel_cdagechq
                            e modificados frames utilizados para impressao da
                            carta (Diego).
               
               26/02/2007 - Incluida coluna "Banco" e alterado formato dos
                            campos do tipo Date para "99/99/9999" do browser
                            (Elton). 
                            
               06/03/2007 - Excluida a variavel "aux_chqctitg", nao sera mais
                            usada no controle de envio dos registros (Evandro).
                            
               09/03/2007 - Incluida coluna "Conta Chq." e ajustado format no
                            browser (Diego).
                 
               12/06/2007 - Incluido coluna do titular responsavel pelos
                            cheques no browser (Elton).
               
               12/07/2007 - Incluida coluna com titular responsavel pelo cheque
                            e campo para assinatura de todos os titulares da
                            conta (Elton).
                            
               30/01/2008 - Incluido variaveis para mostrar taxa CCF na carta
                            (Guilherme).
                            
               04/11/2008 - Excluidos FRAMES f_cabec_bcobrasil_timb e 
                            f_escop_bcobrasil_timb (Diego).
               
               15/05/2009 - Incluidos campos cdoperad e nmoperad no frame
                            f_rodape2 (Fernando).
                            
               16/03/2010 - Inclusao variaveis projeto IF CECRED (Guilherme).
               
               07/03/2012 - Inclusao Obs na carta baixa CCF (Guilherme).
               
               11/10/2012 - Incluido handle para b1wgen9998 (David Kruger).
               
............................................................................. */
                                                                  
DEFINE VAR tel_nrdconta LIKE crapass.nrdconta                         NO-UNDO.
DEFINE VAR tel_nmprimtl LIKE crapass.nmprimtl                         NO-UNDO.
DEFINE VAR tel_cdagenci LIKE crapass.cdagenci                         NO-UNDO.
                                                              
DEFINE VAR aux_dtmvtolt AS DATE                                       NO-UNDO.
                                                             
DEFINE VAR aux_confirma AS CHAR    FORMAT "!"                         NO-UNDO.
DEFINE VAR aux_nmoperad AS CHAR    FORMAT "x(11)"                     NO-UNDO.
                                                             
DEFINE VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEFINE VAR aux_nmarqtp1 AS CHAR                                       NO-UNDO.
DEFINE VAR aux_nmarqtp2 AS CHAR                                       NO-UNDO.
DEFINE VAR aux_nmarqtp3 AS CHAR                                       NO-UNDO.
                                                          
DEFINE VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEFINE VAR aux_flgfirst_bob  AS LOGICAL                               NO-UNDO.
DEFINE VAR aux_flgfirst_bra  AS LOGICAL                               NO-UNDO.
DEFINE VAR aux_flgfirst_cec  AS LOGICAL                               NO-UNDO.

DEFINE VAR aux_nmendter AS CHAR                                       NO-UNDO.
DEFINE VAR aux_tldatela AS CHAR                                       NO-UNDO.
                                                                 
DEFINE VAR rel_dsexten1 AS CHAR    FORMAT "x(65)"                     NO-UNDO.
DEFINE VAR rel_dsexten2 AS CHAR    FORMAT "x(16)"                     NO-UNDO.
                                                              
DEFINE VAR rel_nrcpfcgc AS CHAR    FORMAT "x(18)"                     NO-UNDO.
DEFINE VAR rel_nmrescop AS CHAR    EXTENT 2                           NO-UNDO.
DEFINE VAR aux_qtpalavr AS INT                                        NO-UNDO.
DEFINE VAR aux_qtcontpa AS INT                                        NO-UNDO.
DEFINE VAR aux_flgzerar AS LOGICAL                                    NO-UNDO.
                                                         
DEFINE VAR par_flgrodar AS LOGICAL                                    NO-UNDO.
DEFINE VAR aux_flgescra AS LOGICAL                                    NO-UNDO.
DEFINE VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEFINE VAR par_flgfirst AS LOGICAL                                    NO-UNDO.
DEFINE VAR par_flgcance AS LOGICAL                                    NO-UNDO.
DEFINE VAR aux_contador AS INTEGER                                    NO-UNDO.
DEFINE VAR aux_qtchqsel AS INTEGER                                    NO-UNDO.
DEFINE VAR aux_nrdrowid AS ROWID                                      NO-UNDO.
DEFINE VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEFINE VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.

DEFINE VAR aux_qtdtitul AS INT                                        NO-UNDO.

DEFINE VAR aux_flgbanco AS LOGICAL                                    NO-UNDO.
DEFINE VAR aux_flgbncob AS LOGICAL                                    NO-UNDO.
DEFINE VAR aux_arquivaz AS LOGICAL                                    NO-UNDO.
 
DEFINE VAR rel_cdbanchq AS INT     FORMAT "zzz9"                      NO-UNDO.
DEFINE VAR rel_cdagechq AS INT     FORMAT "zzz9"                      NO-UNDO.
DEFINE VAR rel_dtdiamov AS INT     FORMAT "99"                        NO-UNDO.
DEFINE VAR rel_dtanomov AS INT     FORMAT "9999"                      NO-UNDO.
DEFINE VAR rel_nmmesref AS CHAR    FORMAT "x(09)"                     NO-UNDO.
DEFINE VAR rel_nmdbanco AS CHAR    FORMAT "x(30)"                     NO-UNDO.
DEFINE VAR aux_nmmesref AS CHAR    FORMAT "x(11)" EXTENT 12
                                   INIT ["JANEIRO  ","FEVEREIRO",
                                         "MARCO    ","ABRIL    ",
                                         "MAIO     ","JUNHO    ",
                                         "JULHO    ","AGOSTO   ",
                                         "SETEMBRO ","OUTUBRO  ",
                                         "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.

DEFINE VAR rel_nrdconta LIKE crapass.nrdconta                         NO-UNDO.
DEFINE VAR rel_nrdocmto LIKE crapneg.nrdocmto                         NO-UNDO.
DEFINE VAR rel_vlestour LIKE crapneg.vlestour                         NO-UNDO.
DEFINE VAR rel_nrdctabb LIKE crapneg.nrdctabb                         NO-UNDO.
DEFINE VAR rel_nmcidade AS CHAR      EXTENT 2                         NO-UNDO.

DEFINE VAR rel_idseqttl  LIKE crapneg.idseqttl                        NO-UNDO.
DEFINE VAR tel_nmextttl  AS CHAR FORMAT "x(30)"                       NO-UNDO.
DEFINE VAR tel_nmextttl2 AS CHAR FORMAT "x(30)"                       NO-UNDO.
DEFINE VAR tel_nrcpfcgc  LIKE crapass.nrcpfcgc                        NO-UNDO.
DEFINE VAR tel_nrcpfcgc2 LIKE crapttl.nrcpfcg                         NO-UNDO.
DEFINE VAR aux_dsdlinha  AS CHAR FORMAT "x(31)" 
                         INIT "-------------------------------"       NO-UNDO.
DEFINE VAR aux_dscpfcgc  AS CHAR FORMAT "x(9)"  INIT "CPF/CNPJ:"      NO-UNDO.
DEFINE VAR aux_nrdconta  AS CHAR                INIT "C/C:"           NO-UNDO.
DEFINE VAR rel_nrdconta2 LIKE crapass.nrdconta                        NO-UNDO.

DEFINE VAR aux_vlregccf AS DECIMAL FORMAT "zz9.99"                    NO-UNDO.
DEFINE VAR aux_contchq  AS INT                                        NO-UNDO.
DEFINE VAR aux_vltotccf AS DECIMAL FORMAT "zzz,zz9.99"                NO-UNDO.

DEFINE VAR h-b1wgen9998 AS HANDLE                                     NO-UNDO.

DEFINE TEMP-TABLE cratneg                                             NO-UNDO 
       FIELD nrseqdig  AS  INT     FORMAT "zz,zz9"  
       FIELD dtiniest  AS  DATE    FORMAT "99/99/9999"
       FIELD cdbanchq  AS  DEC     FORMAT "z,zz9"    
       FIELD nrctachq  AS  DEC     FORMAT "zzzz,zzz,9"
       FIELD cdobserv  AS  INT     FORMAT "zzz9"
       FIELD nrdocmto  AS  DEC     FORMAT "zz,zzz,zz9"
       FIELD vlestour  AS  DEC     FORMAT "zzz,zzz,zzz,zz9"
       FIELD dtfimest  AS  DATE    FORMAT "99/99/9999"
       FIELD nmoperad  AS  CHAR    FORMAT "x(11)"
       FIELD flgselec  AS  LOGICAL FORMAT "*/ "
       FIELD flgctitg  AS  INT     FORMAT "9"
       FIELD idseqttl  AS  INT     FORMAT "9"
       INDEX cratneg1  AS  UNIQUE PRIMARY nrseqdig  DESC.

DEFINE QUERY q_manccf FOR cratneg.
                                              
DEFINE BROWSE b_manccf QUERY q_manccf SHARE-LOCK
       DISP cratneg.nrseqdig COLUMN-LABEL "Seq."        FORMAT "zzz9"
            cratneg.dtiniest COLUMN-LABEL "Data"        FORMAT "99/99/99"
            cratneg.cdbanchq COLUMN-LABEL "Bco"         FORMAT "zz9"
            cratneg.nrctachq COLUMN-LABEL "Conta Chq."  FORMAT "zzzz,zzz,9"
            cratneg.nrdocmto COLUMN-LABEL "Cheque"      FORMAT "zzz,zzz,9"
            cratneg.vlestour COLUMN-LABEL "Valor"       FORMAT "zz,zz9.99"
            cratneg.cdobserv COLUMN-LABEL "Al"          FORMAT "z9"
            cratneg.dtfimest COLUMN-LABEL "Regular."    FORMAT "99/99/99"
            cratneg.nmoperad COLUMN-LABEL "por"      FORMAT "x(5)"
            cratneg.flgselec NO-LABEL
            cratneg.flgctitg COLUMN-LABEL "S"           FORMAT "9"
            cratneg.idseqttl COLUMN-LABEL "T"   
            WITH 7 DOWN.                                                
                                                    
DEFINE BUTTON btn_titular    LABEL "Titular".     
DEFINE BUTTON btn_regular    LABEL "Regularizar".
DEFINE BUTTON btn_imprcar    LABEL "Imprimir Carta".
DEFINE BUTTON btn_sair       LABEL "Sair".

DEFINE FRAME f_manccf  SKIP(1)
                       b_manccf     HELP "Use <TAB> para navegar"
                       btn_titular  HELP "Use <TAB> para navegar"  AT 9
                       SPACE(6)
                       btn_regular  HELP "Use <TAB> para navegar" 
                       SPACE(6)
                       btn_imprcar  HELP "Use <TAB> para navegar"
                       SPACE(6)
                       btn_sair     HELP "Use <TAB> para navegar" 
                       WITH NO-BOX CENTERED width 78 OVERLAY ROW 8.
  
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta  AT 5  AUTO-RETURN     LABEL "Conta/dv"
               HELP "Digite o nro da conta/dv"
               VALIDATE(CAN-FIND(crapass WHERE 
                                 crapass.cdcooper = glb_cdcooper  AND
                                 crapass.nrdconta = tel_nrdconta),
                                 "009 - Associado nao cadastrado.")

     tel_nmprimtl  AT 30 FORMAT "x(40)"  LABEL "Nome"
     SKIP
     tel_cdagenci  AT 10 FORMAT "zz9"    LABEL "PAC"
                   HELP "Informe o PAC ou 0 para todos os PAC'S"
     WITH ROW 6 COLUMN 4 OVERLAY SIDE-LABELS NO-BOX FRAME f_conta.


DEFINE TEMP-TABLE cratttl                                             NO-UNDO 
       FIELD idseqttl  LIKE crapttl.idseqttl        
       FIELD nmextttl  LIKE crapttl.nmextttl.        

DEFINE QUERY q_titular FOR cratttl.
                                              
DEFINE BROWSE b_titular QUERY q_titular NO-LOCK
       DISP cratttl.idseqttl COLUMN-LABEL "Seq."        FORMAT "zz9"
            cratttl.nmextttl COLUMN-LABEL "Titular"     FORMAT "x(25)"
            WITH TITLE "TITULARES" 3 DOWN.

FORM b_titular
     HELP "Informe o titular da conta."
     WITH ROW 10 COLUMN 20 OVERLAY  SIDE-LABELS 
          NO-BOX FRAME f_titular.


FORM SKIP(1)
     "  Coloque o papel timbrado na impressora  "
     SKIP(1)
     WITH NO-LABELS OVERLAY CENTERED ROW 10 FRAME f_papeltimbrado.


/*.... F R A M E    B A N C O O B    E    B A N C O    D O    B R A S I L ....*/

FORM SKIP(4)
     rel_nmcidade[1]  ","  rel_dtdiamov "DE" rel_nmmesref FORMAT "x(09)" "DE"
     rel_dtanomov "." AT 35
     SKIP(4)
     "A"
     SKIP
     crapcop.nmextcop
     SKIP(4)
     "Prezados Senhores:"  
     SKIP(3)
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 86 
     FRAME f_cabec_bancoob.

FORM SKIP(3)     
     "Solicito  a " crapcop.nmextcop " a" 
     SKIP
     "exclusao no CCF (Cadastro de Emitentes de Cheque sem  Fundos), dos"
     SKIP 
     "registros incluidos pela devolucao do(s) seguinte(s) cheque(s):"
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 86 FRAME f_escop_bancoob.
      
FORM SKIP(2)
     "\017 Nr Cheque"        
     "Valor\022"             AT 18
     SKIP(1)
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 132 FRAME f_titulo_bancoob.
                                           
FORM "\017"
     rel_nrdocmto   FORMAT "zzz,zzz,9"
     rel_vlestour   FORMAT "zzz,zzz.99"     AT 13
     rel_dsexten1   FORMAT "x(94)"          AT 25
     "\022"
     SKIP(1)
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 132 FRAME f_relacao_bancoob.

FORM SKIP(2)
     "\017Banco"                AT 01
     " Agencia"                 AT 08
     " Conta"                   AT 22
     "Nr Cheque"                AT 31
     "Valor"                    AT 48
     "Tit.\022"                 AT 118
     SKIP(1)
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 132 FRAME f_titulo_bcobrasil.
                                           
FORM "\017"
     rel_cdbanchq                            AT 03
     rel_cdagechq                            AT 12
     rel_nrdctabb   FORMAT "zzzz,zzz,9"      AT 18
     rel_nrdocmto   FORMAT "zzz,zzz,9"       AT 31
     rel_vlestour   FORMAT "zzz,zzz.99"      AT 43
     rel_dsexten1   FORMAT "x(65)"           AT 54
     rel_idseqttl                            AT 121
     "\022"
     SKIP(1)
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 132 FRAME f_relacao_bcobrasil.

FORM "\017"
     rel_cdbanchq                            AT 03
     rel_cdagechq                            AT 12
     rel_nrdctabb   FORMAT "zzzz,zzz,9"      AT 18
     rel_nrdocmto   FORMAT "zzz,zzz,9"       AT 31
     rel_vlestour   FORMAT "zzz,zzz.99"      AT 43
     rel_dsexten1   FORMAT "x(65)"           AT 54
     "\022"
     SKIP
     "\017"
     rel_dsexten2   FORMAT "x(16)"           AT 55
     rel_idseqttl                            AT 121
     "\022"
     SKIP(1)
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 132 FRAME f_relacao_bcobrasil2.


FORM SKIP(1)
     "Autorizo o debito na minha conta corrente da tarifa de exclusao de CCF."
     SKIP
     "No valor total de: R$" aux_vltotccf
     SKIP(3)
     "Atenciosamente,"
     SKIP(3)
     WITH NO-BOX NO-LABEL COLUMN 10  WIDTH 86 FRAME f_rodape.

FORM SKIP(6)
     "-------------------------------"
     aux_dsdlinha AT 35 
     SKIP
     "\033\105" tel_nmextttl "\033\106"
     "\033\105" tel_nmextttl2 AT 42 "\033\106"   
     SKIP                                         
     "\033\105" "CPF/CNPJ:" 
                tel_nrcpfcgc    "\033\106"
     "\033\105" aux_dscpfcgc    AT 42  
                tel_nrcpfcgc2   "\033\106"
     SKIP
     "\033\105" "C/C:" rel_nrdconta "\033\106"
     "\033\105" aux_nrdconta AT 42 
                rel_nrdconta2 "\033\106"
     SKIP(6)
     "-------------------------------"
     SKIP
     "\033\105" crapope.cdoperad "\033\106"
     "\033\105" " - "            
                crapope.nmoperad "\033\106" AT 14
    SKIP(1)
    "OBS: OS DOCUMENTOS DEVEM ESTAR DE ACORDO COM AS NORMAS DO BACEN, SUJEITO"
    SKIP
    "A ANALISE PARA EFETIVAR A REGULARIZACAO DO CCF."
     
     WITH NO-BOX NO-LABEL COLUMN 10 DOWN WIDTH 86 FRAME f_rodape2.

FORM "\033\105" tel_nmextttl "\033\106"
     WITH DOWN NO-BOX NO-LABEL COLUMN 10 WIDTH 86 FRAME f_cooperado.

/*...........................................................................*/

