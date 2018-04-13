/* .............................................................................

   Programa: Fontes/lanrqe.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Agosto/2000.                    Ultima atualizacao: 18/05/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANRQE.
   
   Observacao: tprequis = 1 -> Pedido Cheque Normal (Interprint)
                          2 -> Cheque TB (Impressao CECRED)
                          3 -> Formulario Continuo (Interprint)
                          5 -> Formulario Avulso (Impressao CECRED) 
                          8 -> Bloquetos Banco do Brasil (Impressao CECRED)
                          
   Alteracoes: 17/04/2001 - Permitir no max 500 bloquetos (Deborah).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera 
                            armazenado na variavel aux_lsconta3 (Julio).
                            
               19/11/2003 - Tratamento CONTA CONVEIO cheque formulario continuo
                            tipo de requisicao 3 (Julio).

               13/01/2004 - Exclusao da opcao 7 de requisicao, bloqueto de
                            cobranca Bancoob (Julio).

               15/01/2004 - Inclusao req. 8(Bloquetos Banco Brasil)(Mirtes) 
               
               04/10/2004 - Alteracao no help do campo tel_qtreqtal (Julio)

               02/05/2005 - Alteracao help tel_qtreqtal(Mirtes).
               
               03/10/2005 - Incluir o Continuo ITG (Ze).
               
               08/11/2005 - Alterar o Limite de Form. Continuo (Ze).

               20/12/2005 - Inclusao das opcoes "(5)Form.Avulso e (2)Cheque TB"
                            (Julio)

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               14/02/2006 - Alterado para ler folhas ao inves de taloes para o
                            "Formulario Continuo" (Evandro).

               12/06/2007 - Alterado qtdade formulario continuo.Somente  
                            Somente Viacredi(Mirtes)
                            
               10/05/2008 - Alterado help do tel_qtreqtal (Gabriel).
               
               03/07/2008 - Nao permite mais de 400 folhas para o mesmo pedido
                            de formularios continuos, verificar todas as
                            requisicoes pendentes (Evandro).
                            
               01/12/2009 - Alterar label para chq avulso 200 PJ(Guilherme).
               
               10/06/2010 - Coope tem que estar operando com ABBC para
                            podes solicitar taloes tipo 3 (Magui).
                            
               06/09/2011 - Criado a var h-b1wgen0110 e instanciado a include
                            var_internet.i (Adriano).
                            
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               15/04/2013 - Ajustes realizados:
                             - Retirado a chamada do fontes ver_ctace e da 
                               craptab que alimentao as variaveis aux_lsconta3,
                               aux_lsconta4;
                             - Incluido a declaracao da variavel aux_dsoperac
                              (Adriano).         
                            
               09/11/2016 - #551764 A partir do dia 16/11 a area de suprimentos
                            nao produzira mais cheques avulsos. Opcao 5, formulario
                            avulso, foi retirada (Carlos)

               14/03/2017 - Aumentar para 1400 folhas por requisição no formulario  
                            3, conforme solicitado no chamado 627236. (Kelvin)
                            
               18/05/2017 - Ajustar tela para a nova opcao "P" (Lucas Ranghetti #646559)
                            
               20/03/2018 - Adicionadas variaveis para serem utilidas nas includes
                            "lanrqea.i" e "lanrqei.i". PRJ366 (Lombardi).
                            
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR tel_qtinforq AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR tel_qtcomprq AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR tel_qtinfotl AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_qtcomptl AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_qtreqtal AS INT     FORMAT "zzz9"                 NO-UNDO.
DEF        VAR tel_tprequis AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"               NO-UNDO.
DEF        VAR tel_nrdctabb AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_reganter AS CHAR    FORMAT "x(48)" EXTENT 6       NO-UNDO.
DEF        VAR tel_dtsolici AS DATE    FORMAT "99/99/9999"           NO-UNDO.

DEF        VAR aux_nrseqdig AS INT     FORMAT "zzzz9"                NO-UNDO.
DEF        VAR aux_qtinforq AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR aux_qtinfotl AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR aux_qtinfoen AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR aux_qtcomprq AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR aux_qtcomptl AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR aux_qtcompen AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR aux_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_nrdctabb AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.

DEF        VAR aux_nrinichq AS INT                                   NO-UNDO.
DEF        VAR aux_nrfinchq AS INT                                   NO-UNDO.
DEF        VAR aux_qtreqtal AS INT                                   NO-UNDO.
DEF        VAR aux_tprequis AS INT                                   NO-UNDO.
DEF        VAR aux_nrinital AS INT                                   NO-UNDO.
DEF        VAR aux_nrfintal AS INT                                   NO-UNDO.
DEF        VAR aux_nrcheque AS INT                                   NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_lsconta1 AS CHAR                                  NO-UNDO.

DEF        VAR aux_lsconta3 AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta4 AS CHAR                                  NO-UNDO.
DEF        VAR aux_flopabbc AS LOG                                   NO-UNDO.
DEF        VAR aux_dsoperac AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0110 AS HANDLE                                NO-UNDO.

DEF        VAR aux_cdmodali AS INTE                                  NO-UNDO.
DEF        VAR aux_indctitg AS INTE                                  NO-UNDO.
DEF        VAR aux_possuipr AS CHAR                                  NO-UNDO.
DEF        VAR aux_des_erro AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.

DEF BUFFER crabreq FOR crapreq.

FORM    SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
            TITLE COLOR MESSAGE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  5 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, E, I ou P)"
                        VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                                  glb_cddopcao = "E" OR glb_cddopcao = "I" OR 
                                  glb_cddopcao = "P",
                                  "014 - Opcao errada.")
    WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM 
     "Informado   Computado            "  AT 39
     SKIP
     "Requisicoes       :"  AT 20
     tel_qtinforq    AT 43 NO-LABEL
     tel_qtcomprq    AT 55 NO-LABEL
     SKIP
     "Folhas/bloq solic.:" AT 20
     tel_qtinfotl    AT 42 NO-LABEL
     tel_qtcomptl    AT 54 NO-LABEL
     SKIP(1)
     "Conta/dv    Tipo Req.   Folhas/Bloq.    Seq." 
                  AT  14
     SKIP
     tel_nrdctabb AT  12 NO-LABEL AUTO-RETURN
                         HELP "Informe o numero da conta do associado."
     tel_tprequis AT  30 NO-LABEL AUTO-RETURN
         HELP "3-Form.Continuo / 8-Bloquetos BB"
                VALIDATE(tel_tprequis = 3 OR
                         tel_tprequis = 8 OR tel_tprequis = 0,
                         "014 - Opcao Errada")
     tel_qtreqtal AT  43 NO-LABEL AUTO-RETURN
         HELP "Qtd.Max:TB=20/Cont=100-1500/Bloquet.BB=500"
     tel_nrseqdig AT  52 NO-LABEL
     WITH ROW 7 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lanrqe.
     
FORM 
     "REQUISICOES PENDENTES"  AT 30    
     SKIP(1)
     "Conta/dv    Tipo Req.   Folhas/Bloq.    Seq.  Data Solicitacao" 
                  AT  8
     SKIP(1)
     tel_nrdctabb AT  6 NO-LABEL AUTO-RETURN
                         HELP "Informe o numero da conta do associado."     
     tel_tprequis AT  24 NO-LABEL AUTO-RETURN
         HELP "3-Form.Continuo / 8-Bloquetos BB"
                VALIDATE(tel_tprequis = 3 OR
                         tel_tprequis = 8 OR tel_tprequis = 0,
                         "014 - Opcao Errada")
     tel_qtreqtal AT  36 NO-LABEL AUTO-RETURN
         HELP "Qtd.Max:TB=20/Cont=100-1500/Bloquet.BB=500"
     tel_nrseqdig AT 46 NO-LABEL     
     tel_dtsolici AT 60 NO-LABEL     
     WITH ROW 7 COLUMN 2 OVERLAY NO-LABELS NO-BOX FRAME f_lanrqe_p.

FORM tel_reganter[1] AT 12 NO-LABEL  tel_reganter[2] AT 12 NO-LABEL
     tel_reganter[3] AT 12 NO-LABEL  tel_reganter[4] AT 12 NO-LABEL
     tel_reganter[5] AT 12 NO-LABEL  tel_reganter[6] AT 12 NO-LABEL
     WITH ROW 14 COLUMN 2 OVERLAY NO-BOX FRAME f_regant.

FORM crapreq.nrdctabb  AT 12  crapreq.tprequis  AT 30
     crapreq.qtreqtal  AT 43  FORMAT "zzz9" crapreq.nrseqdig  AT 52
     WITH ROW 14 COLUMN 2 OVERLAY NO-LABEL NO-BOX 7 DOWN FRAME f_lanctos.

FORM crapreq.nrdctabb  AT 6  
     crapreq.tprequis  AT 24
     crapreq.qtreqtal  AT 36  FORMAT "zzz9" 
     crapreq.nrseqdig  AT 46
     crapreq.dtmvtolt  AT 60
     WITH ROW 11 COLUMN 2 OVERLAY NO-LABEL NO-BOX 7 DOWN FRAME f_lanctos_p.     

VIEW FRAME f_moldura.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 794.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.
/*** Verificar se cooperativa ja esta operando com a ABBC ***/
FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "EXECUTAABBC"  AND
                   craptab.tpregist = 0 no-lock no-error.            
IF  AVAILABLE craptab THEN
    ASSIGN aux_flopabbc = IF craptab.dstextab = "SIM" THEN
                             YES
                          ELSE
                             NO.

ASSIGN glb_cddopcao = "I"
       aux_flgretor = FALSE
       tel_nrdctabb = 0
       tel_tprequis = 0
       tel_qtreqtal = 0
       tel_nrseqdig = 1.
       
PAUSE(0).

DISPLAY glb_cddopcao WITH FRAME f_opcao.

CLEAR FRAME f_regant NO-PAUSE.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      SET glb_cddopcao WITH FRAME f_opcao.

      LEAVE.

   END.
  
   DISPLAY glb_cddopcao WITH FRAME f_opcao.   
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "lanrqe"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_lanrqe.
                     HIDE FRAME f_regant.
                     HIDE FRAME f_lanctos.
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_lanrqe_p.
                     HIDE FRAME f_lanctos_p.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   ASSIGN aux_flgretor = TRUE.

   IF  glb_cddopcao = "A" THEN
        DO:
            { includes/lanrqea.i } 
        END.
   ELSE
   IF  glb_cddopcao = "C" THEN
             DO:
                 { includes/lanrqec.i }
             END.
        ELSE
   IF  glb_cddopcao = "E"   THEN
                  DO:
                      { includes/lanrqee.i }
                  END.
             ELSE
   IF  glb_cddopcao = "I"   THEN
                       DO:
                           { includes/lanrqei.i }
                       END.
   ELSE
   IF  glb_cddopcao = "P" THEN
       DO:
            { includes/lanrqep.i }
       END.
END.

/* .......................................................................... */

