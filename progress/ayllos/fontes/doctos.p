/* .............................................................................

   Programa: Fontes/doctos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Janeiro/2004                    Ultima alteracao: 24/03/2016
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Gerar Arquivo DOC para transmissao Banco Brasil
   
   Alteracao : 05/04/2004 - Criar tab. controle(operador) se nao existir(Mirtes)
               07/04/2004 - Opcao X, permitir atualizar apenas 1 docto(Mirtes)
               15/04/2004 - Inclusao da frame help para as opcoes da tela
                            (Julio).

               28/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               14/03/2005 - Se tela em uso por outro operador, solicitar
                            liberacao coordenador(pedesenha.p)(Mirtes)
                            
               27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
               
               07/02/2006 - Atualizazao de cdcooper depois do comando create - 
                            SQLWorks - Andre
                          - Opcao "H" para controle de horarios (Evandro).
                            
               13/02/2006 - Inclusao do parametro par_cdcooper para a 
                            chamada do programa fontes/pedesenha.p - SQLWorks -
                            Fernando.

               21/09/2006 - Atualizacao prevendo envio digito conta alfa(BB).
                            (Mirtes).

               26/09/2006 - Se glb_cdoperad = "1","996","997" pode-se alterar a 
                            situacao dos arquivos (David).

               02/10/2006 - Alterado help dos campos (Elton).

               09/10/2006 - Geracao DOC BB(Mirtes)

               31/10/2006 - Geragco DOC BB.Digito X(Mirtes)

               21/02/2007 - Gerar DOC BANCOOB (David).
               
               10/04/2007 - Acerto nro documento Bancoob(Mirtes)
               
               11/04/2007 - Nao converter mais para inteiro o campo ctarcbe
                            (Evandro).

               10/05/2007 - Enviar segundo titular quando DOC D - conta
                            conjunta BANCOOB(Mirtes)

               15/02/2008 - Disponibilidar utilizacao de TED, alem do DOC
                            que esta disponivel; (Sidnei - Precise)
                          - Label da opcao C para contemplar TEDs;
                          - Comentada a opcao V pois tem mesma funcao que a C;
                          - Opcao X para contemplar TEDs;
                          - Opcao R solicitar Enviados/Nao Enviados
                          - Melhoria das mensagens de verificacoes e contagens
                            de arquivos e registros gerados
                            (Evandro).
                            
               16/04/2008 - Alterada opcao "H" para permitir configuracao de
                            horario para TED'S (Diego).
               
               19/05/2008 - Correcao na atualizacao da HRTRDOCTOS (Magui).
               
               18/07/2008 - Havendo so TEDS nao mostrava a consulta (Magui).
               
               19/08/2008 - Tratar praca de compensacao (Magui).
               
               29/09/2008 - Alterar tipo de Documento - Circular BB (Ze).
               
               04/11/2008 - Tratamento do Ctrl-C qdo no relatorio (Martin).
               
               29/09/2008 - Alterar tipo de Doc. Circular BB - Franklin (Ze).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               28/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de DOC (cdagedoc e
                            cdbandoc) - (Sidnei - Precise).
               
               01/10/2009 - Precise - Paulo. Alterado programa para gravar 
                            em tabela generica quando o banco for cecred (997)
                            e imprimir em saparado dos demais (BB e Bancoob)
                          - Precise - Guilherme. Alterado programa para nao  
                            se basear no codigo fixo 997 para CECRED, mas sim
                            utilizar o campo cdbcoctl da CRAPCOP
                          - Alteracao do nome do arquivo quando CECRED, padrao
                            definido pela ABBC. (Precise/Guilherme)
                          - Inclusao do campo BANCO na tela, processamento de 
                            acordo com a opcao selecionada, gravar valor no
                            campo cdbcoenv na geracao do arquivo e atribuir 0
                            na "atualiza_compel_regerar" (Precise/Guilherme)
                            
                          - Validar operadores para CECRED (Guilherme).
                          
                          - Redefinir a crawage dos programas Titulo, Doctos,
                            Compel, para igualar a da BO b1wgen0012
                            (Guilherme/Supero).

                          - Remocao da BO b1wgen0012 (Guilherme/Supero)

                          - Nao gerar mais para CECRED na opcao "B". Sera
                            apenas via PRCCTL (Guilherme/Supero)
                            
               20/05/2010 - Tratar apenas consulta Nossa Remessa - IF 085
                          - Tratar departamento COMPE opcao "H"(Guilherme).
                          
               07/07/2010 - Retirar validação de LOTE na opcao R (Guilherme)
               
               16/04/2012 - Fonte substituido por doctosp.p (Tiago).
               
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                          
               13/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                          
                            
               06/01/2014 - Alterada critica de "089 - Agencia devera ser 
                            informada." para "962 - PA nao cadastrado.".
                          - Adicionado VALIDATE quando PA nao for encontrado
                            (Reinert)
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               24/03/2016 - Ajustes de permissao conforme solicitado no chamado 358761 (Kelvin).
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.

DEF  VAR aut_flgsenha AS LOGICAL                                    NO-UNDO.
DEF  VAR aut_cdoperad AS CHAR                                       NO-UNDO.

DEF  VAR aux_posregis AS RECID                                      NO-UNDO.
DEF  VAR aux_tamanho  AS INTE                                       NO-UNDO.
DEF  VAR aux_digito   AS CHAR                                       NO-UNDO.
DEF  var aux_conta    AS DEC                                        NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF VAR par_numipusr AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

DEF TEMP-TABLE crawage                                                  NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade 
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEF QUERY q_agencia  FOR crawage. 
                                     
DEF BROWSE b_agencia  QUERY q_agencia
      DISP crawage.cdagenci COLUMN-LABEL "PA" 
           crawage.nmresage COLUMN-LABEL "Nome"
           WITH 13 DOWN CENTERED NO-BOX.

DEF BUFFER crabtvl FOR craptvl.

DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_nrdocto_ted AS INT FORMAT "zz,zzz,zz9"            NO-UNDO.
DEF        VAR tel_nrdconta LIKE craptvl.nrdconta                    NO-UNDO.
DEF        VAR tel_nmpesemi LIKE craptvl.nmpesemi                    NO-UNDO.
DEF        VAR tel_nmsegemi LIKE craptvl.nmsegemi                    NO-UNDO.
DEF        VAR tel_cpfcgemi LIKE craptvl.cpfcgemi                    NO-UNDO.
DEF        VAR tel_cpfsgemi LIKE craptvl.cpfsgemi                    NO-UNDO.
DEF        VAR tel_cdbccrcb LIKE craptvl.cdbccrcb                    NO-UNDO.
DEF        VAR tel_cdagercb LIKE craptvl.cdagercb                    NO-UNDO.
DEF        VAR tel_nrctarec LIKE craptvl.nrcctrcb                    NO-UNDO.   
DEF        VAR tel_vldocrcb LIKE craptvl.vldocrcb                    NO-UNDO. 
DEF        VAR tel_doctos   LIKE craptvl.nrdocmto                    NO-UNDO.
DEF        VAR tel_cddsenha AS CHAR    FORMAT "x(10)"                NO-UNDO.
DEF        VAR tel_nrdhhini AS INT                                   NO-UNDO.
DEF        VAR tel_nrdmmini AS INT                                   NO-UNDO.
DEF        VAR tel_dssituac AS CHAR    FORMAT "x(30)"                NO-UNDO.

DEF   VAR tel_situacao AS LOG   FORMAT "NAO PROCESSADO/PROCESSADO"   NO-UNDO.

DEF        VAR aux_cdsituac AS INT                                   NO-UNDO.
DEF        VAR aux_nrdahora AS INT                                   NO-UNDO.
DEF        VAR aux_flglotab AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_nrseqlct AS INTE                                  NO-UNDO.
DEF        VAR aux_tpdoctrf AS CHAR   FORMAT "x(01)"                 NO-UNDO.
DEF        VAR aux_flgexreg AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cdagefim LIKE craptvl.cdagenci                    NO-UNDO.
DEF        VAR aux_nrdconta LIKE craptvl.nrdconta                    NO-UNDO.
DEF        VAR aux_nrdolote AS INTE FORMAT "999999"                  NO-UNDO.
DEF        VAR aux_nrconven AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdsequen AS INT                                   NO-UNDO.
DEF        VAR aux_cdseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_dtmvtolt AS CHAR                                  NO-UNDO. 
DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO. 
DEF        VAR aux_qtregarq AS INT                                   NO-UNDO.
DEF        VAR aux_hrarquiv AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtdoclot AS INT                                   NO-UNDO.
DEF        VAR aux_vltotlot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vltotarq AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vltotdoc AS DECIMAL                               NO-UNDO.
DEF        VAR aux_qtlinarq AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_tppessoa AS INT                                   NO-UNDO.
DEF        VAR aux_digitage AS CHAR                                  NO-UNDO.
DEF        VAR aux_totregis AS INT                                   NO-UNDO.

DEF        VAR aux_nmpesrcb  LIKE craptvl.nmpesrcb                   NO-UNDO.
DEF        VAR aux_cpfcgrcb  LIKE craptvl.cpfcgrcb                   NO-UNDO.


DEF        VAR tel_flgenvio AS LOG  FORMAT "Enviados/Nao Enviados"   NO-UNDO.

DEF        VAR tel_flgtpdoc AS LOG  FORMAT "DOC/TED" INIT YES        NO-UNDO.

DEF        VAR tel_qtdtotal AS INT  FORMAT ">>>,>>9"                 NO-UNDO.
DEF        VAR tel_vlrtotal AS DEC  FORMAT ">>>,>>>,>>>,>>>.99"      NO-UNDO.

DEF       VAR tel_cdbcoenv  AS CHAR FORMAT "x(15)" VIEW-AS COMBO-BOX
   LIST-ITEMS
      "TODOS",
      "BANCO DO BRASIL",
      "BANCOOB",
      "CECRED"  INIT "TODOS" NO-UNDO.

DEF        VAR aux_cdbcoenv AS CHAR INIT "0"                         NO-UNDO.
DEF        VAR aux_vldocrcb AS DEC  FORMAT "999,999,999,999.99"      NO-UNDO.

DEF        VAR aux_valor    AS CHAR FORMAT "X(07)"                   NO-UNDO.
DEF        VAR aux_valor2   AS CHAR FORMAT "X(06)"                   NO-UNDO.
DEF        VAR flg_doctobb  AS LOG INIT NO                           NO-UNDO.

DEF        VAR h-b1wgen0012 AS HANDLE                                NO-UNDO.
DEF        VAR aux_flgtpdoc AS CHAR FORMAT "X(01)"                   NO-UNDO.

DEF TEMP-TABLE crattem                                               NO-UNDO
           FIELD cdseqarq AS INTEGER
           FIELD nrdolote AS INTEGER
           FIELD cddbanco AS INTEGER
           FIELD nmarquiv AS CHAR
           FIELD nrrectit AS RECID
           FIELD nrdconta LIKE crapccs.nrdconta
           FIELD cdagenci LIKE crapccs.cdagenci
           FIELD cdbantrf LIKE crapccs.cdbantrf
           FIELD cdagetrf LIKE crapccs.cdagetrf
           FIELD nrctatrf LIKE crapccs.nrctatrf
           FIELD nrdigtrf LIKE crapccs.nrdigtrf
           FIELD nmfuncio LIKE crapccs.nmfuncio
           FIELD nrcpfcgc LIKE crapccs.nrcpfcgc
           FIELD nrdocmto LIKE craplcs.nrdocmto
           FIELD vllanmto LIKE craplcs.vllanmto
           FIELD dtmvtolt LIKE craplcs.dtmvtolt
           FIELD tppessoa AS INT FORMAT "9"
           INDEX crattem1 cdseqarq nrdolote.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, B, C, E, X ou R)."
                        VALIDATE(CAN-DO("A,B,C,E,H,X,R",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_doctos.

FORM tel_dtmvtolt AT 1 LABEL "  Referencia" 
                       HELP "Informe a data de referencia do movimento."
     tel_cdagenci      LABEL "       PA"
                       HELP "Informe o numero do PA ou zero '0' para todos."
                       VALIDATE (CAN-FIND (crapage WHERE 
                                     crapage.cdcooper = glb_cdcooper  AND
                                     crapage.cdagenci = tel_cdagenci) OR
                                     tel_cdagenci = 0
                                     ,"962 - PA nao cadastrado.")
     tel_flgtpdoc      LABEL "     Tipo" 
                       HELP "Informe 'D' para DOC ou 'T' para TED."
     WITH ROW 6 COLUMN 17 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

FORM tel_dtmvtolt AT 1  LABEL "  Referencia" 
                        HELP "Informe a data de referencia do movimento."
     tel_cdagenci AT 27 LABEL " PA"
                  HELP "Informe o numero do PA ou zero '0' para todos."
                  VALIDATE (CAN-FIND (crapage WHERE 
                                      crapage.cdcooper = glb_cdcooper  AND
                                      crapage.cdagenci = tel_cdagenci) OR
                                      tel_cdagenci = 0
                                      ,"962 - PA nao cadastrado.")
     tel_doctos   AT 39 LABEL "Docto"
                  HELP  "Informe o numero do documento ou '0' para todos."
     tel_flgtpdoc AT 59 LABEL "Tipo" 
                  HELP "Informe 'D' para DOC ou 'T' para TED."
     WITH ROW 6 COLUMN 12 WIDTH 68 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_x.

FORM tel_dtmvtolt AT 1 LABEL " Referencia" 
                       HELP "Informe a data de referencia do movimento."
     tel_cdagenci      LABEL " PA"
                 HELP "Informe o numero do PA ou zero '0' para todos."
                 VALIDATE (CAN-FIND (crapage WHERE 
                                     crapage.cdcooper = glb_cdcooper  AND
                                     crapage.cdagenci = tel_cdagenci) OR
                                     tel_cdagenci = 0
                                     ,"962 - PA nao cadastrado.")
     tel_flgenvio      LABEL " Opcao"
                      HELP "Informe 'N' para nao enviados ou 'E' para enviados."
     tel_flgtpdoc      LABEL "  Tipo" 
                      HELP "Informe 'D' para DOC ou 'T' para TED."  SKIP
     SKIP(1)
     tel_cdbcoenv AT 6 LABEL " Banco" 
                 HELP "Entre com o banco para gerar o arquivo compensacao"
     SKIP
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_v.

FORM tel_dtmvtolt AT 1 LABEL "  Referencia" 
                       HELP "Informe a data de referencia do movimento."
     tel_cdagenci      LABEL "   PA"
                 HELP "Informe o numero do PA."
                 VALIDATE (CAN-FIND (crapage WHERE 
                                     crapage.cdcooper = glb_cdcooper AND
                                     crapage.cdagenci = tel_cdagenci)
                                     ,"962 - PA nao cadastrado.")
     tel_nrdocto_ted   LABEL "   Docto(TED)"
                 HELP "Informe o digito do numero do documento(TED)."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_ted.

FORM b_agencia AT 18 
     HELP "Utilize SETAS p/selecionar o PA a ser excluido ou F4 p/sair."
     WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_agencia.

FORM aux_confirma    AT 1 LABEL "Iniciar Nova Selecao?     " 
     WITH ROW 12 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_regera.

FORM tel_nrdconta AT  1 LABEL "Conta(DE)"
     tel_nmpesemi AT  1 LABEL "Tit(1)"
     tel_nmsegemi AT  1 LABEL "Tit(2)"
     tel_cpfcgemi AT  1 LABEL "CNPJ(1)"
     tel_cpfsgemi AT  1 LABEL "CNPJ(2)"
     tel_cdbccrcb AT  1 LABEL "Banco"
     tel_cdagercb AT  1 LABEL "Agencia"
     tel_nrctarec AT  1 LABEL "Conta"
     tel_vldocrcb AT  1 LABEL "Valor"
     SKIP(1)
     WITH ROW 9 COLUMN 9 NO-BOX OVERLAY SIDE-LABELS FRAME f_lista_ted.

FORM tel_qtdtotal       FORMAT "zz,zz9"          LABEL "Quantidade Total" 
     tel_vlrtotal AT 34 FORMAT "zzz,zzz,zz9.99"  LABEL "Valor Total"
     WITH ROW 20 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_totais.

FORM "(A) - Alterar TED para DOC" SKIP
     "(B) - Gerar arquivos" SKIP
     "(C) - Consultar DOC's/TED's digitados" SKIP
     "(E) - Desconsiderar PA's" SKIP
     "(H) - Alteracao de Horarios" SKIP
     "(R) - Relatorio" SKIP
     "(X) - Reativar registros" SKIP
     WITH SIZE 50 BY 9 CENTERED OVERLAY ROW 09 
     TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao.

DEF QUERY q_lotes FOR craplot
                  FIELDS(cdagenci nrdolote vlinfocr vlcompcr),
                      crawage
                  FIELD(cdagenci),
                      crapope
                  FIELDS(nmoperad).    
                                     
DEF BROWSE b_lotes QUERY q_lotes 
    DISP craplot.cdagenci COLUMN-LABEL "PA"
         crapope.nmoperad COLUMN-LABEL "Ope"       FORMAT "x(10)"
         craplot.nrdolote COLUMN-LABEL "Lote"
         craplot.vlinfocr COLUMN-LABEL "Informado" FORMAT "zzz,zz9.99"
         craplot.vlcompcr COLUMN-LABEL "Computado" FORMAT "zzz,zz9.99"
         (craplot.vlinfocr - craplot.vlcompcr) COLUMN-LABEL "Diferenca"
                                                   FORMAT "-zzz,zz9.99"
         WITH 9 DOWN.

DEF FRAME f_lotes_doc  
          SKIP(1)
          b_lotes   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
  
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.
     
FORM tel_cdagenci       LABEL " PA   "
                        HELP "Informe o numero do PA."
                        VALIDATE( tel_cdagenci <> 0 , 
                                         "962 - PA nao cadastrado.")
     tel_cddsenha BLANK LABEL "         Senha"
                        HELP "Informe a senha."
     tel_flgtpdoc       LABEL "        Tipo"
                        HELP "Informe 'D' para DOC ou 'T' para TED."
     SKIP(3)
     tel_nrdhhini AT  1 LABEL "Limite para digitacao dos titulos" 
                        FORMAT "99" AUTO-RETURN
                        HELP "Informe a hora limite (10:00 a 20:00)."
     ":"          AT 38 
     tel_nrdmmini AT 39 NO-LABEL FORMAT "99" 
                        HELP "Informe os minutos (0 a 59)."
     "Horas"
     
     SKIP(1)
     tel_situacao AT 9 LABEL "Situacao do(s) arquivo(s)"
                       HELP "Informe (N)ao processado ou (P)rocessado."
     WITH ROW 11 COLUMN 9 NO-BOX OVERLAY SIDE-LABELS FRAME f_opcao_h.
      

ON VALUE-CHANGED, ENTRY OF b_agencia
   DO:
       IF  AVAIL crawage THEN
           aux_posregis = RECID(crawage).
   END.

ON RETURN OF b_agencia
   DO:
       IF  AVAIL crawage THEN
           aux_posregis = RECID(crawage).

       IF   glb_cddopcao = "E"   THEN
            DO:
                aux_confirma = "N".
                MESSAGE COLOR NORMAL "Deseja realmente excluir este PA ?"
                        UPDATE aux_confirma.
                                        
                IF   CAPS(aux_confirma) = "S"   THEN
                     DO:
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE COLOR NORMAL "Aguarde! Excluindo Registro...".
                         
                         FIND crawage WHERE RECID(crawage) = aux_posregis
                                            NO-ERROR.
                         IF  AVAIL crawage THEN
                             DELETE crawage.
                     END.
               
                OPEN QUERY q_agencia FOR EACH crawage BY crawage.cdagenci.
     
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Pressione <ENTER> p/Excluir!".                    
            END.
            
   END.

ON RETURN OF tel_cdbcoenv DO:

   IF   SUBSTRING(tel_cdbcoenv:SCREEN-VALUE,1,8) = "BANCO DO" THEN
        aux_cdbcoenv = "1".
   ELSE
   IF   SUBSTRING(tel_cdbcoenv:SCREEN-VALUE,1,7) = "BANCOOB" THEN
        aux_cdbcoenv = "756".
   ELSE
   IF   SUBSTRING(tel_cdbcoenv:SCREEN-VALUE,1,6) = "CECRED" THEN
        aux_cdbcoenv = STRING(crapcop.cdbcoctl).
   ELSE DO:
      IF tel_flgenvio THEN /* Enviados */ 

         /*OBS: Temporariamente foi incluido o 0 no cdbcoenv pois
           só o campo da tabela so sera alimentado com 1,756,85
           quando for liberado a compe. Apos isso, remover o 0 */
         ASSIGN aux_cdbcoenv = "0,1,756," + STRING(crapcop.cdbcoctl).
      ELSE                /* Nao Enviados */
         ASSIGN aux_cdbcoenv = "0".
   END.

   APPLY "GO".
END.

/*---Opcao para Listar Cheques nao Processados ---*/
DEF QUERY q_doctos FOR craptvl
                  FIELDS(cdagenci cdbccxlt nrdolote 
                         nrdconta nrdocmto vldocrcb).
                                     
DEF BROWSE b_doctos QUERY q_doctos 
    DISP  craptvl.cdagenci    COLUMN-LABEL "PA"
          craptvl.cdbccxlt    COLUMN-LABEL "BANCO/CAIXA"
          craptvl.nrdolote    COLUMN-LABEL "Lote"
          craptvl.nrdconta    COLUMN-LABEL "Conta"
          craptvl.nrdocmto    COLUMN-LABEL "Docto"
          craptvl.vldocrcb    COLUMN-LABEL "Valor"               
          WITH 6 DOWN.

DEF FRAME f_doctos_b  
          SKIP(1)
          b_doctos    HELP  "Pressione <F4> ou <END> p/finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 9.

/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/*--- Inicializa com todas as agencias --*/
FIND FIRST crawage NO-LOCK NO-ERROR.
IF  NOT AVAIL crawage THEN
    DO:
      FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
          CREATE crawage.
          ASSIGN crawage.cdagenci = crapage.cdagenci
                 crawage.nmresage = crapage.nmresage
                 crawage.cdbandoc = crapage.cdbandoc
                 crawage.cdcomchq = crapage.cdcomchq.
      END. 
    END.      

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtolt = glb_dtmvtolt.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0.
           END.

      RUN proc_limpa.
      VIEW FRAME f_helpopcao.
      PAUSE(0).

      UPDATE glb_cddopcao  WITH FRAME f_doctos.

      HIDE FRAME f_helpopcao NO-PAUSE.    
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "DOCTOS"  THEN
                 DO:
                     HIDE FRAME f_lotes_doc NO-PAUSE.
                     HIDE FRAME f_refere_v.
                     HIDE FRAME f_refere_x  NO-PAUSE.
                     HIDE FRAME f_doctos.
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_opcao_h.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "A"   THEN       /*  Gera TED - Como DOC */
        DO:
           HIDE FRAME f_ted.
           HIDE FRAME f_refere    NO-PAUSE.
           HIDE FRAME f_refere_v  NO-PAUSE.
           HIDE FRAME f_agencia   NO-PAUSE.
           HIDE FRAME f_regera    NO-PAUSE.
           HIDE FRAME f_lotes_doc NO-PAUSE.
           HIDE FRAME f_refere_x  NO-PAUSE.
           HIDE FRAME f_opcao_h   NO-PAUSE.
           
           ASSIGN tel_dtmvtolt      = glb_dtmvtolt
                  tel_cdagenci      = 0
                  tel_nrdocto_ted   = 0.
        
           DISPLAY tel_dtmvtolt   tel_cdagenci     tel_nrdocto_ted
                   WITH FRAME f_ted.

           UPDATE tel_cdagenci    tel_nrdocto_ted  WITH FRAME f_ted.

           FIND FIRST craplot WHERE craplot.cdcooper = glb_cdcooper AND
                                    craplot.dtmvtolt = tel_dtmvtolt AND
                                    craplot.tplotmov = 25 /* TED */
                                    NO-LOCK NO-ERROR.
                              
            IF   NOT AVAILABLE craplot   THEN
                 DO:
                     ASSIGN glb_cdcritic = 90.
                     NEXT.
                 END.          
            
            FIND craptvl WHERE craptvl.cdcooper = glb_cdcooper     AND
                               craptvl.dtmvtolt = tel_dtmvtolt     AND
                               craptvl.cdagenci = tel_cdagenci     AND
                               craptvl.tpdoctrf = 3                AND
                               craptvl.nrdocmto = tel_nrdocto_ted     
                               NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL craptvl THEN 
                DO:
                   ASSIGN glb_cdcritic = 22. /* Documento Errado */
                   NEXT.
                END.          

            /*--- Verificar se Arquivo nao foi Transmitido --*/
            ASSIGN aux_nmarquiv = "td" +
                      STRING(craptvl.nrdocmto, "9999999")  + 
                      STRING(DAY(glb_dtmvtolt),"99")   + 
                      STRING(MONTH(glb_dtmvtolt),"99") +
                      STRING(craptvl.cdagenci, "999") +
                      ".rem".
            IF   SEARCH("arq/" + aux_nmarquiv) <> ?   THEN /* Arq.encontrado */
                 UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                                   " salvar 2>/dev/null").
            ELSE
                 DO:
                     ASSIGN glb_cdcritic = 677. /* Transmissao ja Efetuada */
                     NEXT.
                 END.

            ASSIGN tel_nrdconta = craptvl.nrdconta
                   tel_nmpesemi = craptvl.nmpesemi
                   tel_nmsegemi = craptvl.nmsegemi
                   tel_cpfcgemi = craptvl.cpfcgemi
                   tel_cpfsgemi = craptvl.cpfsgemi
                   tel_cdbccrcb = craptvl.cdbccrcb
                   tel_cdagercb = craptvl.cdagercb
                   tel_nrctarec = craptvl.nrcctrcb
                   tel_vldocrcb = craptvl.vldocrcb.
                   
            DISPLAY tel_nrdconta   tel_nmpesemi   tel_nmsegemi   tel_cpfcgemi
                    tel_cpfsgemi   tel_cdbccrcb   tel_cdagercb   tel_nrctarec
                    tel_vldocrcb   WITH FRAME f_lista_ted.

            DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                 aux_confirma = "N".
                 glb_cdcritic = 78.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                 glb_cdcritic = 0.
                 LEAVE.
            END.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                 aux_confirma <> "S" THEN
                 DO:
                     glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     RUN proc_limpa.
                     NEXT.
                 END.

            /*  Busca dados da cooperativa  */
            FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE crapcop THEN
                 DO:
                     ASSIGN glb_cdcritic = 651.
                     NEXT.
                 END.

            RUN proc_gera_arquivo_ted.
            
            IF   glb_cdcritic > 0   THEN
                 NEXT.
                 
            DO ON STOP UNDO, LEAVE:
               RUN fontes/doctos_r.p(INPUT tel_dtmvtolt,
                                     INPUT tel_cdagenci,
                                     INPUT TRUE,  /* Nao utiliz. qdo TED */
                                     INPUT "T",   /* TED */
                                     INPUT recid(craptvl), 
                                     INPUT TABLE crawage).
               PAUSE 3 NO-MESSAGE.
            END.
                                   
            HIDE MESSAGE NO-PAUSE.

            MESSAGE "Foi(ram) gravado(s)" aux_qtarquiv "arquivo(s)"
                    "-" aux_qtregarq "DOC(s)".
                    
            MESSAGE "Arquivo = " aux_nmarquiv.
            MESSAGE "Transmita-o(s) via INTRANET.".
            PAUSE 3 NO-MESSAGE. 
            LEAVE.
        END.
   ELSE
   IF   glb_cddopcao = "E"   THEN       /*  Eliminar Agencias Processamento */
        DO:
           HIDE FRAME f_refere    NO-PAUSE.
           HIDE FRAME f_refere_v  NO-PAUSE.
           HIDE FRAME f_agencia   NO-PAUSE.
           HIDE FRAME f_ted       NO-PAUSE.
           HIDE FRAME f_regera    NO-PAUSE.
           HIDE FRAME f_lotes_doc NO-PAUSE.
           HIDE FRAME f_refere_x  NO-PAUSE.
           HIDE FRAME f_opcao_h   NO-PAUSE.
           
           RUN  p_regera_agencia.

           OPEN QUERY q_agencia FOR EACH crawage BY crawage.cdagenci.
  
           ENABLE b_agencia  WITH FRAME  f_agencia.
           SET b_agencia WITH FRAME f_agencia.
       END.     
   ELSE
        IF   glb_cddopcao = "X"   THEN
             DO:
                HIDE FRAME f_lotes_doc NO-PAUSE.
                HIDE FRAME f_ted       NO-PAUSE.
                HIDE FRAME f_agencia   NO-PAUSE.
                HIDE FRAME f_regera    NO-PAUSE.
                HIDE FRAME f_refere    NO-PAUSE.
                HIDE FRAME f_refere_x  NO-PAUSE.
                HIDE FRAME f_refere_v  NO-PAUSE.
                HIDE FRAME f_opcao_h   NO-PAUSE.

                UPDATE tel_dtmvtolt  tel_cdagenci  tel_doctos  tel_flgtpdoc
                       WITH FRAME f_refere_x.

                ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN
                                           9999
                                      ELSE tel_cdagenci.

                OPEN QUERY q_doctos 
                  FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper  AND
                                         craptvl.dtmvtolt = tel_dtmvtolt  AND
                                         craptvl.cdagenci >= tel_cdagenci AND
                                         craptvl.cdagenci <= aux_cdagefim AND
                                       ((tel_flgtpdoc     = YES /* DOC */ AND 
                                         craptvl.tpdoctrf <> 3)           OR
                                        (tel_flgtpdoc     = NO  /* TED */ AND
                                         craptvl.tpdoctrf  = 3))          AND
                                        (craptvl.nrdocmto  = tel_doctos   OR
                                         tel_doctos        = 0)           AND
                                         craptvl.flgenvio = YES NO-LOCK
                                         BY craptvl.cdagenci
                                         BY craptvl.nrdolote
                                         BY craptvl.vldocrcb.

                ENABLE b_doctos WITH FRAME f_doctos_b.

                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
                HIDE FRAME f_doctos_b. 
               
                HIDE MESSAGE NO-PAUSE.
   
                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    aux_confirma = "N".
                    glb_cdcritic = 78.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                    glb_cdcritic = 0.
                    LEAVE.
                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    DO:
                       glb_cdcritic = 79.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       RUN proc_limpa.
                       NEXT.
                    END.

                RUN atualiza_docs_regerar.
   
                MESSAGE "Movtos atualizados         ".
                MESSAGE "                           ".
             END.
        ELSE              
        IF   glb_cddopcao = "C"   THEN    /* Consulta Valores */
             DO:
                 HIDE FRAME f_refere    NO-PAUSE.
                 HIDE FRAME f_refere_v  NO-PAUSE.
                 HIDE FRAME f_agencia   NO-PAUSE.
                 HIDE FRAME f_ted       NO-PAUSE.
                 HIDE FRAME f_regera    NO-PAUSE.
                 HIDE FRAME f_lotes_doc NO-PAUSE.
                 HIDE FRAME f_refere_x  NO-PAUSE.
                 HIDE FRAME f_opcao_h   NO-PAUSE.
             
                 ASSIGN tel_cdagenci = 0
                        tel_flgenvio = TRUE.

                 DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                      UPDATE tel_dtmvtolt  tel_cdagenci  
                             tel_flgenvio  tel_flgtpdoc WITH FRAME f_refere_v.
              
                      IF   tel_flgenvio  THEN
                           DO  WHILE TRUE:
                               UPDATE tel_cdbcoenv WITH FRAME f_refere_v.
                               LEAVE.
                           END.
                      ELSE aux_cdbcoenv = "0".
                      
                      ASSIGN aux_confirma = "N" 
                             aux_flgexreg = NO.
            
                      ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN
                                                 9999
                                            ELSE tel_cdagenci.
                     
                      /********** Nao verificar craplot - 27/05/2010
                      FOR EACH craplot WHERE 
                               craplot.cdcooper  = glb_cdcooper   AND
                               craplot.dtmvtolt  = tel_dtmvtolt   AND
                               craplot.cdagenci >= tel_cdagenci   AND
                               craplot.cdagenci <= aux_cdagefim   AND
                              (craplot.tplotmov = 24 OR
                               craplot.tplotmov = 25) NO-LOCK,
                          EACH crawage WHERE
                               crawage.cdagenci  = craplot.cdagenci NO-LOCK:
                          ASSIGN aux_flgexreg = YES.
                          LEAVE.
                      END.

                      IF   NOT aux_flgexreg   THEN
                           DO:
                               ASSIGN glb_cdcritic = 90.
                               LEAVE.
                           END.
                      **********************/

                      ASSIGN aux_vldocrcb = 0.
                      
                      OPEN QUERY q_doctos
                           FOR EACH craptvl WHERE
                                    craptvl.cdcooper = glb_cdcooper  AND
                                    craptvl.dtmvtolt = tel_dtmvtolt  AND
                                    craptvl.cdagenci >= tel_cdagenci AND
                                    craptvl.cdagenci <= aux_cdagefim AND
                                  ((tel_flgtpdoc     = YES /* DOC */ AND 
                                    craptvl.tpdoctrf <> 3)           OR
                                   (tel_flgtpdoc     = NO  /* TED */ AND
                                    craptvl.tpdoctrf = 3))           AND
                              CAN-DO(aux_cdbcoenv,STRING(craptvl.cdbcoenv)) AND
                                    craptvl.flgenvio = tel_flgenvio NO-LOCK
                                    BY craptvl.cdagenci
                                    BY craptvl.nrdolote
                                    BY craptvl.vldocrcb.
                      ENABLE b_doctos WITH FRAME f_doctos_b.

                      DO aux_contador = 1 TO NUM-RESULTS("q_doctos"):
                          ASSIGN aux_vldocrcb = aux_vldocrcb + craptvl.vldocrcb.
                          QUERY q_doctos:GET-NEXT().
                      END.

                      ASSIGN tel_qtdtotal = NUM-RESULTS("q_doctos")
                             tel_vlrtotal = aux_vldocrcb.

                      DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_totais.

                      WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                         
                      HIDE FRAME f_doctos_b.
                      HIDE FRAME f_totais. 
               
                      HIDE MESSAGE NO-PAUSE.

                      DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      
                          MESSAGE COLOR NORMAL
                          "Deseja listar os LOTES referentes a pesquisa(S/N)?:"
                                  UPDATE aux_confirma.
                          LEAVE.
                      END. /* fim do DO WHILE */
                            
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                           aux_confirma <> "S"                  THEN DO:
                           RUN proc_limpa.
                           NEXT.
                      END.
 
                      IF   tel_flgtpdoc THEN
                           ASSIGN aux_flgtpdoc = "D". /* DOC */ 
                      ELSE
                           ASSIGN aux_flgtpdoc = "T". /* TED */ 

                      DO ON STOP UNDO, LEAVE:
                         RUN fontes/doctos_r.p (INPUT tel_dtmvtolt, 
                                                INPUT tel_cdagenci,
                                                INPUT tel_flgenvio,
                                                INPUT aux_flgtpdoc,
                                                INPUT " ",
                                                INPUT TABLE crawage).
                      END.
                 END.   /*  Fim do DO WHILE TRUE  */
             END.
        ELSE
        IF   glb_cddopcao = "B"   THEN  /*  Gera arquivos para o BANCO BB */
             DO:
                 HIDE FRAME f_lotes_doc NO-PAUSE.
                 HIDE FRAME f_ted       NO-PAUSE.
                 HIDE FRAME f_agencia   NO-PAUSE.
                 HIDE FRAME f_regera    NO-PAUSE.
                 HIDE FRAME f_refere_v  NO-PAUSE.
                 HIDE FRAME f_refere_X  NO-PAUSE.
                 HIDE FRAME f_lotes_doc NO-PAUSE.
                 HIDE FRAME f_opcao_h   NO-PAUSE.

                 ASSIGN tel_dtmvtolt = glb_dtmvtolt
                        tel_cdagenci = 0.
        
                 DISPLAY tel_dtmvtolt tel_cdagenci tel_flgtpdoc
                         WITH FRAME f_refere.

                 UPDATE  tel_dtmvtolt tel_cdagenci tel_flgtpdoc
                         WITH FRAME f_refere.
 
                 ASSIGN aux_flglotab = NO
                        aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                                            9999
                                       ELSE tel_cdagenci.
                     
                 FOR EACH craplot WHERE craplot.cdcooper  = glb_cdcooper AND
                                        craplot.dtmvtolt  = tel_dtmvtolt AND
                                        craplot.cdbccxlt  = 11           AND
                                        craplot.cdagenci >= tel_cdagenci AND
                                        craplot.cdagenci <= aux_cdagefim AND
                                        craplot.tplotmov = 24 NO-LOCK,
                     EACH crawage WHERE 
                          crawage.cdagenci  = craplot.cdagenci AND
                          crawage.cdbandoc <> crapcop.cdbcoctl NO-LOCK:

                     IF   craplot.vlinfocr - craplot.vlcompcr <> 0   THEN
                          DO:
                              ASSIGN aux_flglotab = YES.
                              LEAVE.
                          END.
                 END.              
            
                 OPEN QUERY q_doctos 
                      FOR EACH craptvl WHERE 
                               craptvl.cdcooper  = glb_cdcooper AND
                               craptvl.dtmvtolt  = tel_dtmvtolt AND
                               craptvl.cdagenci >= tel_cdagenci AND
                               craptvl.cdagenci <= aux_cdagefim AND
                             ((tel_flgtpdoc     = YES /* DOC */ AND 
                               craptvl.tpdoctrf <> 3)           OR
                              (tel_flgtpdoc     = NO  /* TED */ AND
                               craptvl.tpdoctrf  = 3))          AND
                               craptvl.flgenvio  = NO NO-LOCK
                               BY craptvl.cdagenci
                               BY craptvl.nrdolote
                               BY craptvl.vldocrcb.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE b_doctos WITH FRAME f_doctos_b.
                    LEAVE.
                 END.

                 CLOSE QUERY q_doctos.

                 HIDE FRAME f_doctos_b NO-PAUSE.                 

                 HIDE MESSAGE NO-PAUSE.

                 IF   aux_flglotab   THEN
                      DO:
                          ASSIGN glb_cdcritic = 139.
                          NEXT.
                      END.

                 DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      aux_confirma = "N".
                      glb_cdcritic = 78.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                      glb_cdcritic = 0.
                      LEAVE.
                 END.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                      aux_confirma <> "S" THEN
                      DO:
                          glb_cdcritic = 79.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          RUN proc_limpa.
                          NEXT.
                      END.

                 /*---- Controle de 1 operador utilizando  tela --*/

                 FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                                    NO-LOCK NO-ERROR.
                 IF  NOT AVAIL crapcop  THEN 
                     DO:
                        glb_cdcritic = 1.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
                        PAUSE MESSAGE
                        "Tecle <entra> para voltar `a tela de identificacao!".
                        BELL.
                        NEXT.
                     END.

                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                                    craptab.nmsistem = "CRED"            AND
                                    craptab.tptabela = "GENERI"          AND
                                    craptab.cdempres = crapcop.cdcooper  AND
                                    craptab.cdacesso = "DOCTOS"          AND
                                    craptab.tpregist = 1 NO-LOCK NO-ERROR.
            
                 IF  NOT AVAIL craptab THEN 
                     DO:
                        CREATE craptab.
                        ASSIGN craptab.nmsistem = "CRED"      
                               craptab.tptabela = "GENERI"          
                               craptab.cdempres = crapcop.cdcooper           
                               craptab.cdacesso = "DOCTOS"
                               craptab.tpregist = 1
                               craptab.cdcooper = glb_cdcooper.
                        RELEASE craptab.    
                     END.

                 DO  WHILE TRUE:
                     FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                        craptab.nmsistem = "CRED"           AND
                                        craptab.tptabela = "GENERI"         AND
                                        craptab.cdempres = crapcop.cdcooper AND
                                        craptab.cdacesso = "DOCTOS"         AND
                                        craptab.tpregist = 1 NO-LOCK NO-ERROR.

                     IF   NOT AVAIL craptab THEN 
                          DO:
                            MESSAGE 
                         "Controle nao cad.(Avise Inform) Processo Cancelado!".
                            PAUSE MESSAGE
                         "Tecle <entra> para voltar `a tela de identificacao!".
                            BELL.
                            LEAVE.
                         END.

                     IF  craptab.dstextab <> " " THEN
                         DO:
                             MESSAGE
                               "Processo sendo utilizado pelo Operador " +
                               TRIM(SUBSTR(craptab.dstextab,1,20)).
                             PAUSE MESSAGE
                               "Peca liberacao Coordenador ou Aguarde......".
                    
                             RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                     INPUT 2, 
                                                     OUTPUT aut_flgsenha,
                                                     OUTPUT aut_cdoperad).
                             IF   aut_flgsenha    THEN
                                  LEAVE.
                             NEXT.
                         END.
                     LEAVE.
                 END.

                 FIND craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                                    craptab.nmsistem = "CRED"               AND
                                    craptab.tptabela = "GENERI"             AND
                                    craptab.cdempres = crapcop.cdcooper     AND
                                    craptab.cdacesso = "DOCTOS"             AND
                                    craptab.tpregist = 1  
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
                 IF  AVAIL craptab THEN     
                     DO:
                        ASSIGN craptab.dstextab = glb_cdoperad.
                        RELEASE craptab.
                     END.
            
                 /*  Verifica se os lotes estao fechados  */
   
                 HIDE MESSAGE NO-PAUSE.

                 MESSAGE "AGUARDE... Verificando os lotes do dia.".
                 PAUSE 3 NO-MESSAGE. 

                 FOR EACH craplot WHERE craplot.cdcooper  = glb_cdcooper AND
                                        craplot.dtmvtolt  = tel_dtmvtolt AND
                                        craplot.cdbccxlt  = 11           AND
                                        craplot.cdagenci >= tel_cdagenci AND
                                        craplot.cdagenci <= aux_cdagefim AND
                                        craplot.tplotmov  = 24 
                                        NO-LOCK,
                     EACH crawage WHERE crawage.cdagenci  = craplot.cdagenci AND
                                        crawage.cdbandoc <> crapcop.cdbcoctl
                                        NO-LOCK,
                         FIRST crapope WHERE crapope.cdcooper = glb_cdcooper AND
                                             crapope.cdoperad = craplot.cdoperad
                                             NO-LOCK:

                     IF   craplot.qtinfoln <> craplot.qtcompln   OR
                          craplot.vlinfocr <> craplot.vlcompcr   THEN
                          DO:
                              MESSAGE "Lote nao batido:" 
                                      STRING(craplot.cdagenci,"999") + "-" +
                                      STRING(craplot.cdbccxlt,"999") + "-" +
                                      STRING(craplot.nrdolote,"999999").

                              glb_cdcritic = 139.
                              LEAVE.
                          END.
                          
                 END.  /*  Fim do FOR EACH  */

                 IF   glb_cdcritic > 0   THEN
                      NEXT.

                 MESSAGE "PROCESSANDO.. Lote(s) do dia fechado(s)! " +
                         "Gerando arquivo(s).".
                 
                 PAUSE 3 NO-MESSAGE. 
 
                 IF tel_flgtpdoc THEN  /* Para DOC'S */
                    DO:
                         /* gerar arquivo para DOC BB */
                         RUN proc_gera_arquivo_bbrasil.

                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "PROCESSANDO.. Foi(ram) gravado(s)" 
                                 aux_qtarquiv
                                 "arquivo(s) -" aux_totregis "DOC(s) BB".
                         PAUSE 3 NO-MESSAGE.
                         
                         RUN proc_gera_arquivo_bancoob.
                         
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "PROCESSANDO.. Foi(ram) gravado(s)" 
                                 aux_qtarquiv
                                 "arquivo(s) -" aux_totregis "DOC(s) BANCOOB".
                         PAUSE 3 NO-MESSAGE.

                    END.
                 ELSE
                    DO:
                         /* gerar arquivo para TED BB */
                         RUN proc_gera_arquivo_ted_bbrasil.

                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "PROCESSANDO.. Foi(ram) gravado(s)" 
                                 aux_qtarquiv
                                 "arquivo(s) -" aux_totregis "TED(s) BB".
                         PAUSE 3 NO-MESSAGE.
                    END.

                 IF   glb_cdcritic > 0   THEN  
                      DO:
                          RUN atualiza_controle_operador.
                          NEXT.
                      END.
                 
                 IF   tel_flgtpdoc THEN
                      ASSIGN aux_flgtpdoc = "D". /* DOC */
                 ELSE
                      ASSIGN aux_flgtpdoc = "T". /* TED */
                 
                 DO ON STOP UNDO, LEAVE:
                    RUN fontes/doctos_r.p (INPUT tel_dtmvtolt, 
                                           INPUT tel_cdagenci,
                                           INPUT FALSE,   
                                           INPUT aux_flgtpdoc,
                                           INPUT " ",
                                           INPUT TABLE crawage).
                 END.
                 
                 RUN atualiza_docs.

                 RUN atualiza_controle_operador.
                 
                 MESSAGE "Movimentos atualizados. Transmita-o(s) via INTRANET.".

                 PAUSE 3 NO-MESSAGE. 
            
                 LEAVE.
             
             END.
        ELSE
        IF   glb_cddopcao = "R"   THEN                      /*  Relatorio  */
             DO:
                 HIDE FRAME f_lotes_doc NO-PAUSE.
                 HIDE FRAME f_ted       NO-PAUSE.
                 HIDE FRAME f_agencia   NO-PAUSE.
                 HIDE FRAME f_regera    NO-PAUSE.
                 HIDE FRAME f_refere_v  NO-PAUSE.
                 HIDE FRAME f_refere_x  NO-PAUSE.
                 HIDE FRAME f_opcao_h   NO-PAUSE.
            
                 ASSIGN tel_dtmvtolt = glb_dtmvtolt
                        tel_cdagenci = 0.
        
                 DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                      UPDATE tel_dtmvtolt  tel_cdagenci
                             tel_flgenvio  tel_flgtpdoc WITH FRAME f_refere_v.

                      ASSIGN aux_flgexreg = NO
                             aux_cdagefim = IF   tel_cdagenci = 0  THEN 
                                                 9999
                                            ELSE tel_cdagenci.

                      IF tel_flgtpdoc THEN
                         ASSIGN aux_flgtpdoc = "D". /* DOC */
                      ELSE
                         ASSIGN aux_flgtpdoc = "T". /* TED */

                      DO ON STOP UNDO, LEAVE:
                         RUN fontes/doctos_r.p (INPUT tel_dtmvtolt, 
                                                INPUT tel_cdagenci,
                                                INPUT tel_flgenvio,
                                                INPUT aux_flgtpdoc,
                                                INPUT " ",
                                                INPUT TABLE crawage).
                      END.
                 END.  /*  Fim do DO WHILE TRUE  */
         
                 HIDE FRAME f_refere.
             END.
        ELSE              
        IF   glb_cddopcao = "H"   THEN    /* Alteracao de Horarios */
             DO: 
                HIDE FRAME f_lotes_doc NO-PAUSE.
                HIDE FRAME f_refere_v  NO-PAUSE.
                HIDE FRAME f_ted       NO-PAUSE.
                HIDE FRAME f_agencia   NO-PAUSE.
                HIDE FRAME f_regera    NO-PAUSE.
                HIDE FRAME f_refere    NO-PAUSE.
                HIDE FRAME f_refere_x  NO-PAUSE.

                CLEAR FRAME f_opcao_h.
                
                ASSIGN tel_cdagenci = 0.

                UPDATE tel_cdagenci 
                       tel_cddsenha       
                       tel_flgtpdoc
                       WITH FRAME f_opcao_h.
                       
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                   crapage.cdagenci = tel_cdagenci 
                                   NO-LOCK NO-ERROR.
                                   
                IF   NOT AVAIL crapage THEN
                     DO:
                         glb_cdcritic = 962. /* PA nao cadastrado */
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         PAUSE 3 NO-MESSAGE.
                         HIDE FRAME f_opcao_h   NO-PAUSE.
                         NEXT.
                     END.

                DO aux_contador = 1 TO 10:

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                      craptab.nmsistem = "CRED"        AND
                                      craptab.tptabela = "GENERI"      AND
                                      craptab.cdempres = 00            AND
                                      craptab.cdacesso = "HRTRDOCTOS"  AND
                                      craptab.tpregist = tel_cdagenci
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptab   THEN
                        IF   LOCKED craptab   THEN
                             DO:
                                RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
                                
                                RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                					 INPUT "banco",
                                					 INPUT "craptab",
                                					 OUTPUT par_loginusr,
                                					 OUTPUT par_nmusuari,
                                					 OUTPUT par_dsdevice,
                                					 OUTPUT par_dtconnec,
                                					 OUTPUT par_numipusr).
                                
                                DELETE PROCEDURE h-b1wgen9999.
                                
                                ASSIGN aux_dadosusr = 
                                "077 - Tabela sendo alterada p/ outro terminal.".
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 3 NO-MESSAGE.
                                LEAVE.
                                END.
                                
                                ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                                			  " - " + par_nmusuari + ".".
                                
                                HIDE MESSAGE NO-PAUSE.
                                
                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                MESSAGE aux_dadosusr.
                                PAUSE 5 NO-MESSAGE.
                                LEAVE.
                                END.
                                                                
                                NEXT.
                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 55.
                                 LEAVE.
                             END.    
                   ELSE
                        glb_cdcritic = 0.
            
                   LEAVE.
        
                END.  /*  Fim do DO .. TO  */
                
                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         PAUSE 3 NO-MESSAGE.
                         HIDE FRAME f_opcao_h NO-PAUSE.
                         NEXT.
                     END.
                     
                IF   tel_flgtpdoc   THEN    /* DOC */ 
                     ASSIGN aux_cdsituac = INT(SUBSTR(craptab.dstextab,1,1))
                            aux_nrdahora = INT(SUBSTR(craptab.dstextab,3,5)).
                ELSE                        /* TED */ 
                     ASSIGN aux_cdsituac = INT(SUBSTR(craptab.dstextab,13,1))
                            aux_nrdahora = INT(SUBSTR(craptab.dstextab,15,5)).
                            
                ASSIGN tel_situacao = IF  aux_cdsituac = 0  THEN
                                          TRUE
                                      ELSE
                                          FALSE
                       tel_nrdhhini = INT(SUBSTR(STRING(aux_nrdahora,
                                                        "HH:MM:SS"),1,2))
                       tel_nrdmmini = INT(SUBSTR(STRING(aux_nrdahora,
                                                        "HH:MM:SS"),4,2)).
                
                DISPLAY tel_situacao WITH FRAME f_opcao_h.
                
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                   IF  glb_cdcritic > 0  THEN
                       DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         PAUSE 3 NO-MESSAGE.
                         NEXT.
                       END.
                 
                   IF   glb_dsdepart = "TI"                   OR
                        glb_dsdepart = "SUPORTE"              OR
                        glb_dsdepart = "COMPE"                OR
                        glb_dsdepart = "COORD.ADM/FINANCEIRO" OR 
                        glb_dsdepart = "CANAIS"               THEN
                        UPDATE tel_nrdhhini tel_nrdmmini tel_situacao
                               WITH FRAME f_opcao_h.
                   ELSE
                        UPDATE tel_nrdhhini tel_nrdmmini WITH FRAME f_opcao_h.
                       
                   IF   tel_nrdhhini < 10 OR tel_nrdhhini > 20 THEN
                        DO:
                            glb_cdcritic = 687.
                            NEXT.
                        END.

                   IF   tel_nrdmmini > 59  THEN
                        DO:
                            glb_cdcritic = 687.
                            NEXT.
                        END.

                   IF   tel_nrdhhini = 20 AND tel_nrdmmini > 0 THEN
                        DO:
                            glb_cdcritic = 687.
                            NEXT.
                        END.
                  
                   LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */
                
                IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                     DO:
                        HIDE FRAME f_opcao_h NO-PAUSE.
                        RUN proc_limpa.
                        NEXT.
                     END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   aux_confirma = "N".
                   glb_cdcritic = 78.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                   glb_cdcritic = 0.
                   LEAVE.
                END.

                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                     aux_confirma <> "S" THEN
                     DO:
                         glb_cdcritic = 79.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         HIDE FRAME f_opcao_h NO-PAUSE.
                         RUN proc_limpa.
                         
                         NEXT.
                     END.

                ASSIGN aux_nrdahora = (tel_nrdhhini * 3600) + 
                                      (tel_nrdmmini * 60)
                       
                       aux_cdsituac = IF   tel_situacao  THEN  
                                           0  
                                      ELSE 1
                       glb_cdcritic = 0.
                       
                IF   tel_flgtpdoc  THEN  /* DOC */ 
                     ASSIGN SUBSTRING(craptab.dstextab,1,11) = 
                                              STRING(aux_cdsituac,"9") + " " +
                                              STRING(aux_nrdahora,"99999") + 
                                              ",DOC".
                ELSE                     /* TED */ 
                     ASSIGN SUBSTRING(craptab.dstextab,13,11) = 
                                              STRING(aux_cdsituac,"9") + " " +
                                              STRING(aux_nrdahora,"99999") + 
                                              ",TED".
                                              
                CLEAR FRAME f_opcao_h.
                HIDE FRAME f_opcao_h   NO-PAUSE.
                
             END. /* Fim opcao H */
             
        
END.  /*  Fim do DO WHILE TRUE  */

/* ........................................................................  */

PROCEDURE proc_gera_arquivo_bancoob:

   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm arq/dc*.CBE 2>/dev/null").

   /* Contadores de arquivo e registros */
   ASSIGN aux_qtarquiv = 0
          aux_totregis = 0.
   
   FOR EACH craptvl WHERE craptvl.cdcooper  = glb_cdcooper  AND
                          craptvl.dtmvtolt  = tel_dtmvtolt  AND
                          craptvl.cdagenci >= tel_cdagenci  AND
                          craptvl.cdagenci <= aux_cdagefim  AND
                          craptvl.flgenvio  = FALSE         AND  
                          craptvl.tpdoctrf <> 3,
       EACH crawage WHERE crawage.cdagenci = craptvl.cdagenci  AND
                          crawage.cdbandoc = 756 /* BANCOOB */ NO-LOCK
                          BREAK BY craptvl.cdagenci
                                    BY craptvl.cdbccrcb :
   
       IF   FIRST-OF(craptvl.cdagenci) THEN
            DO:
                ASSIGN aux_qtregarq = 0
                       aux_vltotarq = 0
                       aux_cdsequen = 1
                       aux_hrarquiv = SUBSTR(STRING(TIME,"HH:MM:SS"),1,2) +
                                      SUBSTR(STRING(TIME,"HH:MM:SS"),4,2) 
                       aux_qtarquiv = aux_qtarquiv + 1
                       aux_nmarquiv = "dc" +
                                      STRING(craptvl.nrdocmto, "9999999") +
                                      STRING(DAY(glb_dtmvtolt),"99") + 
                                      STRING(MONTH(glb_dtmvtolt),"99") +
                                      STRING(craptvl.cdagenci, "999") +
                                      ".CBE".

                IF   SEARCH("arq/" + aux_nmarquiv) <> ?   THEN
                     DO:
                         BELL.
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Arquivo ja existe:" aux_nmarquiv.
                         glb_cdcritic = 459.
                         RETURN.
                     END.
                                                
                OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                
                /* Header do Arquivo */
                PUT STREAM str_1
                           FILL("0",20)        FORMAT "x(20)"
                           "DCR605"
                           "756"
                           "0"
                           YEAR(glb_dtmvtolt)  FORMAT "9999"
                           MONTH(glb_dtmvtolt) FORMAT "99"
                           DAY(glb_dtmvtolt)   FORMAT "99"
                           crawage.cdcomchq    FORMAT "999"
                           "1"
                           crawage.cdcomchq    FORMAT "999"
                           "0001"
                           YEAR(TODAY)         FORMAT "9999"
                           MONTH(TODAY)        FORMAT "99"
                           DAY(TODAY)          FORMAT "99"
                           aux_hrarquiv        FORMAT "9999"
                           FILL(" ",8)         FORMAT "x(8)"
                           " "
                           FILL(" ",177)       FORMAT "x(177)"
                           aux_cdsequen        FORMAT "99999999"
                           SKIP.
            END.
   
       FIND crapagb WHERE crapagb.cdageban = craptvl.cdagercb AND
                          crapagb.cddbanco = craptvl.cdbccrcb NO-LOCK NO-ERROR.
                          
       IF   NOT AVAILABLE crapagb THEN
            DO:
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                  " Ref: " + STRING(glb_dtmvtolt,"99/99/9999") +
                                  " DOC " + STRING(craptvl.nrdocmto) + " - " +
                                  " Agencia destino nao cadastrada: " +
                                  STRING(craptvl.cdagercb,"zzz9") + " Banco: " +
                                  STRING(craptvl.cdbccrcb,"zzz9") +
                                  " >> log/doctos.log").
                                  
                NEXT.
            END.
       
       ASSIGN aux_cdsequen = aux_cdsequen + 1
              aux_tpdoctrf = IF   craptvl.tpdoctrf = 1 THEN
                                  "4"
                             ELSE
                                  "5"
              glb_nrcalcul = craptvl.cdagercb * 10.
              
       RUN fontes/digbbx.p (INPUT glb_nrcalcul,
                            OUTPUT glb_dsdctitg,
                            OUTPUT glb_stsnrcal).
              
       ASSIGN aux_digitage = SUBSTR(glb_dsdctitg,8,1)
              aux_qtregarq = aux_qtregarq + 1
              aux_totregis = aux_totregis + 1
              aux_vltotarq = aux_vltotarq + craptvl.vldocrcb
              aux_vltotdoc = aux_vltotdoc + craptvl.vldocrcb.  
                    
       ASSIGN aux_nmpesrcb = craptvl.nmpesrcb
              aux_cpfcgrcb = craptvl.cpfcgrcb.
       
       IF  craptvl.tpdoctrf  = 2  AND   /* DOC D */
           craptvl.cpfsgemi  > 0 THEN
           ASSIGN  aux_nmpesrcb  = REPLACE(craptvl.nmsegemi,"E/OU","") 
                   aux_cpfcgrcb = craptvl.cpfsgemi.

       /* Detalhe do Arquivo */
       PUT STREAM str_1 
                  crawage.cdcomchq                 FORMAT "999"
                  craptvl.cdbccrcb                 FORMAT "999"
                  craptvl.cdagercb                 FORMAT "9999"
                  aux_digitage                     FORMAT "x(1)"
                  craptvl.nrcctrcb                 FORMAT "9999999999999"
                  craptvl.nrdocmto                 FORMAT "999999"
                  craptvl.vldocrcb * 100           FORMAT "999999999999999999"
                  
                  aux_nmpesrcb                     FORMAT "x(40)"
                  aux_cpfcgrcb                     FORMAT "99999999999999"
                  
                  craptvl.tpdctacr                     FORMAT "99"
                  craptvl.cdfinrcb                     FORMAT "99"
                  FILL(" ",11)                         FORMAT "x(11)"
                  crawage.cdcomchq                     FORMAT "999"
                  "756"
                  SUBSTR(STRING(crapcop.cdagebcb),1,4) FORMAT "9999" 
                  SUBSTR(STRING(crapcop.cdagebcb),5,1) FORMAT "x(1)"
                  craptvl.nrdconta                     FORMAT "9999999999999"
                  craptvl.nmpesemi                     FORMAT "x(40)"
                  craptvl.cpfcgemi                     FORMAT "99999999999999"
                  craptvl.tpdctadb                     FORMAT "99"
                  "SC"
                  FILL(" ",3)                          FORMAT "x(3)"
                  aux_tpdoctrf                         FORMAT "9"
                  FILL(" ",5)                          FORMAT "x(5)"
                  aux_qtregarq                         FORMAT "999999"
                  YEAR(glb_dtmvtolt)                   FORMAT "9999"
                  MONTH(glb_dtmvtolt)                  FORMAT "99"
                  DAY(glb_dtmvtolt)                    FORMAT "99"
                  crawage.cdcomchq                     FORMAT "999"
                  "0001"      
                  "000000000"
                  "00"
                  "045"
                  FILL(" ",4)                          FORMAT "x(4)"
                  aux_cdsequen                         FORMAT "99999999" 
                  SKIP.                  

       IF   LAST-OF(craptvl.cdagenci) THEN 
            DO:
                ASSIGN aux_cdsequen = aux_cdsequen + 1.
                
                /* Trailer do Arquivo */
                PUT STREAM str_1 
                           FILL("9",20)          FORMAT "x(20)"
                           "DCR605"
                           "756"
                           "0"
                           YEAR(glb_dtmvtolt)  FORMAT "9999"
                           MONTH(glb_dtmvtolt) FORMAT "99"
                           DAY(glb_dtmvtolt)   FORMAT "99"
                           crawage.cdcomchq    FORMAT "999"
                           "1"
                           crawage.cdcomchq    FORMAT "999"
                           "0001"
                           YEAR(TODAY)         FORMAT "9999"
                           MONTH(TODAY)        FORMAT "99"
                           DAY(TODAY)          FORMAT "99"
                           aux_hrarquiv        FORMAT "9999"
                           FILL(" ",8)         FORMAT "x(8)"
                           " "
                           aux_qtregarq        FORMAT "99999999"
                           aux_vltotarq * 100  FORMAT "999999999999999999"
                           FILL(" ",151)       FORMAT "x(151)"
                           aux_cdsequen        FORMAT "99999999"
                           SKIP.
                                                      
                OUTPUT STREAM str_1 CLOSE.

                /* Copia para o /micros */
                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                                  ' | tr -d "\032"' + 
                                  " > /micros/" + crapcop.dsdircop +
                                  "/bancoob/"   + aux_nmarquiv +
                                  " 2>/dev/null").
                                  
                /* move para o salvar */
                UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                                  " salvar 2>/dev/null").                      
                                                      
            END.

   END. /* Fim do FOR EACH */
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

       FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper AND
                              crapage.cdagenci <= aux_cdagefim AND
                              crapage.cdagenci >= tel_cdagenci NO-LOCK,
           EACH crawage WHERE crawage.cdagenci  = crapage.cdagenci AND
                              crawage.cdbandoc <> crapcop.cdbcoctl NO-LOCK:
           
           DO aux_contador = 1 TO 10:

               FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                  craptab.nmsistem = "CRED"           AND
                                  craptab.tptabela = "GENERI"         AND
                                  craptab.cdempres = 00               AND
                                  craptab.cdacesso = "HRTRDOCTOS"     AND
                                  craptab.tpregist = crapage.cdagenci
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE craptab   THEN
                    IF   LOCKED craptab   THEN
                         DO:
                            RUN sistema/generico/procedures/b1wgen9999.p
                            PERSISTENT SET h-b1wgen9999.
                            
                            RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                            					 INPUT "banco",
                            					 INPUT "craptab",
                            					 OUTPUT par_loginusr,
                            					 OUTPUT par_nmusuari,
                            					 OUTPUT par_dsdevice,
                            					 OUTPUT par_dtconnec,
                            					 OUTPUT par_numipusr).
                            
                            DELETE PROCEDURE h-b1wgen9999.
                            
                            ASSIGN aux_dadosusr = 
                            "077 - Tabela sendo alterada p/ outro terminal.".
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 3 NO-MESSAGE.
                            LEAVE.
                            END.
                            
                            ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                            			  " - " + par_nmusuari + ".".
                            
                            HIDE MESSAGE NO-PAUSE.
                            
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            MESSAGE aux_dadosusr.
                            PAUSE 5 NO-MESSAGE.
                            LEAVE.
                            END.
                            
                            NEXT.
                         END.
                    ELSE
                         DO:
                             ASSIGN glb_cdcritic = 55.
                             LEAVE.
                         END.    
               ELSE
                    ASSIGN glb_cdcritic = 0.

               LEAVE.

           END.  /*  Fim do DO TO  */

           IF   glb_cdcritic > 0 THEN
                RETURN.

              
       ASSIGN SUBSTRING(craptab.dstextab,1,1)  = "1".

       END. /* Fim do FOR EACH */
       
       UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                         " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                         " - Valor total: " + 
                         STRING(aux_vltotdoc,"zzz,zzz,zz9.99") +
                         " - Qtd. arquivos: " + STRING(aux_qtarquiv, "zzz9") +
                         " >> log/doctos.log").
   
   END. /* Fim da TRANSACTION */

END PROCEDURE.


PROCEDURE proc_gera_arquivo_bbrasil:

   /* Remove os arquivos temporarios */
   UNIX SILENT VALUE("rm arq/dc*.rem 2>/dev/null").

   EMPTY TEMP-TABLE crattem.
   
   /* Contadores de arquivo e registros */
   ASSIGN aux_qtarquiv = 0
          aux_totregis = 0.
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "CONFIG"      AND
                      craptab.cdempres = 00            AND
                      craptab.cdacesso = "COMPELBBDC"  AND
                      craptab.tpregist = 000 NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 55.
            RETURN.
        END.    
                            
   ASSIGN aux_nrconven = SUBSTR(craptab.dstextab,1,20)
          aux_cdsequen = INTEGER(SUBSTR(craptab.dstextab,22,06)) 
                         /* Sequencial a  cada Header */
          aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,29,06)) 
                         /* Sequencial  arquivo - Zera a cada dia */
          aux_nrdolote = 0 
          flg_doctobb  = NO.
          
   FOR EACH craptvl WHERE craptvl.cdcooper  = glb_cdcooper  AND
                          craptvl.dtmvtolt  = tel_dtmvtolt  AND
                          craptvl.cdagenci >= tel_cdagenci  AND
                          craptvl.cdagenci <= aux_cdagefim  AND
                          craptvl.flgenvio  = FALSE         AND  
                          craptvl.tpdoctrf <> 3,
       EACH crawage WHERE crawage.cdagenci = craptvl.cdagenci  AND
                          crawage.cdbandoc = 1 /* BB */        NO-LOCK
                          BREAK BY craptvl.cdagenci
                                    BY craptvl.cdbccrcb :
       
       IF   FIRST-OF(craptvl.cdagenci) THEN
            ASSIGN aux_cdseqarq = aux_cdseqarq  + 1  
                   flg_doctobb  = NO.
       
       /* DOC BB lote = 1  , demais lote = 2 */
       IF   craptvl.cdbccrcb = 1 THEN
            ASSIGN aux_nrdolote =  1 
                   flg_doctobb  = YES.
       ELSE 
           IF  flg_doctobb = YES THEN
               ASSIGN aux_nrdolote = 2.
           ELSE
               ASSIGN aux_nrdolote = 1. 
       
       CREATE crattem.
       ASSIGN crattem.cdseqarq = aux_cdseqarq
              crattem.nrdolote = aux_nrdolote
              crattem.cddbanco = 1
              crattem.nrrectit = RECID(craptvl).

   END. 
       
   ASSIGN aux_dtmvtolt = STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(YEAR(glb_dtmvtolt),"9999")
          aux_qtregarq = 0.
                                     
   FOR EACH crattem USE-INDEX crattem1 NO-LOCK 
                    BREAK BY crattem.cdseqarq BY crattem.nrdolote:
                    
       FIND craptvl WHERE RECID(craptvl) = crattem.nrrectit NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craptvl THEN
            DO:
                ASSIGN glb_cdcritic = 770.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                                  
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + glb_dscritic +  " " +
                            " Sequencia: " + STRING(crattem.cdseqarq ,"9999") +
                            " >> log/compel.log").
                LEAVE.
             END.
       
       FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                          crapage.cdagenci = craptvl.cdagenci NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE crapage THEN
            DO:
                ASSIGN glb_cdcritic = 015.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                                  
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + glb_dscritic +  " " +
                            " Sequencia: " + STRING(crattem.cdseqarq ,"9999") +
                            " >> log/compel.log").
                LEAVE.
            END.
            
       IF   FIRST-OF(crattem.cdseqarq)  THEN
            DO:
                ASSIGN aux_qtregarq = 0
                       aux_hrarquiv = SUBSTR(STRING(time, "HH:MM:SS"), 1,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 4,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 7,2)
                       aux_qtarquiv = aux_qtarquiv + 1
                       aux_nmarquiv = "dc" +
                                      STRING(craptvl.nrdocmto, "9999999") +
                                      STRING(DAY(glb_dtmvtolt),"99") + 
                                      STRING(MONTH(glb_dtmvtolt),"99") +
                                      STRING(craptvl.cdagenci, "999") +
                                      ".rem".

                IF   SEARCH("arq/" + aux_nmarquiv) <> ?   THEN
                     DO:
                         BELL.
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Arquivo ja existe:" aux_nmarquiv.
                         glb_cdcritic = 459.
                         RETURN.
                     END.
                                                
                OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                
                ASSIGN aux_cdsequen = aux_cdsequen + 1.
                
                /* Header do Arquivo */
                PUT STREAM str_1
                           "00100000"
                           FILL(" ",09)      FORMAT "x(09)"
                           "2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctabbd  FORMAT "9999999999999"
                           " "               FORMAT "x(01)"
                           crapcop.nmrescop  FORMAT "x(30)"
                           "BANCO DO BRASIL"
                           FILL(" ",25)      FORMAT "x(25)"
                           "1"
                           aux_dtmvtolt      FORMAT "x(08)"
                           aux_hrarquiv      FORMAT "x(06)"
                           aux_cdsequen      FORMAT "999999"
                           "03000000"
                           FILL(" ",54)      FORMAT "x(54)" 
                           "000000000000000" SKIP.
            END.

       IF   FIRST-OF(crattem.nrdolote)  THEN
            DO:
                ASSIGN aux_qtdoclot = 0
                       aux_vltotlot = 0
                       aux_valor2   = "1C9803".
                
                IF   craptvl.cdbccrc = 1 THEN
                     ASSIGN aux_valor2 = "1C9801".  /* BANCO BRASIL */
                    
                /* Header do Lote */
                PUT STREAM str_1
                           "001"
                           crattem.nrdolote  FORMAT "9999"
                           aux_valor2        FORMAT "x(06)"
                           "020 2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctabbd  FORMAT "9999999999999"
                           " "               FORMAT "x(01)"
                           crapcop.nmrescop  FORMAT "x(30)"
                           FILL(" ",40)      FORMAT "x(40)"
                           crapcop.dsendcop  FORMAT "x(30)"
                           crapcop.nrendcop  FORMAT "99999"
                           FILL(" ",15)      FORMAT "x(15)"
                           crapcop.nmcidade  FORMAT "x(20)"
                           crapcop.nrcepend  FORMAT "99999999" 
                           crapcop.cdufdcop  FORMAT "!(2)"
                           FILL(" ",08)      FORMAT "x(08)" 
                           "0000000000"      SKIP.
            END.
       
       ASSIGN aux_qtdoclot = aux_qtdoclot + 1
              aux_vltotlot = aux_vltotlot + craptvl.vldocrcb
              aux_qtregarq = aux_qtregarq + 1
              aux_totregis = aux_totregis + 1
              aux_vltotdoc = aux_vltotdoc + craptvl.vldocrcb
              aux_digitage = " ".

       IF  craptvl.cdbccrcb = 1 THEN
           DO:
              ASSIGN glb_nrcalcul = craptvl.cdagercb * 10.
              
              RUN fontes/digbbx.p (INPUT  glb_nrcalcul,
                                   OUTPUT glb_dsdctitg,
                                   OUTPUT glb_stsnrcal).
              
              ASSIGN aux_digitage = SUBSTR(glb_dsdctitg,8,1).
           END.       
 
        
       ASSIGN aux_valor = "A000700".
       
       IF   craptvl.cdbccrcb = 1 THEN        /* BANCO BRASIL */
            ASSIGN aux_valor = "A000000".
          
       /*--- Transformar digito numerico em alfa - somente BB --*/
       IF   craptvl.cdbccrcb = 1 THEN        /* BANCO BRASIL */
            RUN fontes/digbbx.p (INPUT  craptvl.nrcctrcb,
                                 OUTPUT glb_dsdctitg,
                                 OUTPUT glb_stsnrcal).
       ELSE
            ASSIGN glb_dsdctitg = STRING(craptvl.nrcctrcb,"9999999999999").
       
       ASSIGN aux_tamanho = LENGTH(glb_dsdctitg)
              aux_digito  = SUBSTR(glb_dsdctitg,aux_tamanho,1)
              aux_conta   = 
                  DEC(SUBSTR(STRING(craptvl.nrcctrcb,"9999999999999"),1,12)).

       PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qtdoclot                   FORMAT "99999"
                        aux_valor                      FORMAT "x(07)"
                        craptvl.cdbccrcb               FORMAT "999"
/* Agencia s/Digito */  craptvl.cdagercb               FORMAT "99999"
/* Digito da Agencia */ aux_digitage                   FORMAT "x(01)"
/* Conta s/Digito */    aux_conta                      FORMAT "999999999999"
/* Digito da Conta*/    aux_digito                     FORMAT "x(01)"
/* Digito Ag/Conta */   " "                            FORMAT "x(01)"
                        craptvl.nmpesrcb               FORMAT "x(30)"
                        STRING(craptvl.nrdocmto)       FORMAT "x(20)"
                        DAY(craptvl.dtmvtolt)          FORMAT "99"
                        MONTH(craptvl.dtmvtolt)        FORMAT "99"
                        YEAR(craptvl.dtmvtolt)         FORMAT "9999"
                        "BRL"
                        "000000000000000"
                        craptvl.vldocrcb * 100         FORMAT "999999999999999"
                        FILL(" ",20)      FORMAT "x(20)"
                        FILL(" ",8)       FORMAT "x(08)"
                        "000000000000000"
                        FILL(" ",52)      FORMAT "x(52)"
                        "0"
                        "0000000000"      SKIP.
 
        ASSIGN aux_qtdoclot = aux_qtdoclot + 1
               aux_qtregarq = aux_qtregarq + 1.

        IF   craptvl.flgpescr = YES THEN   /* Pessoa Fisica */
             ASSIGN aux_tppessoa = 1.
        ELSE
             ASSIGN aux_tppessoa = 2.      /* Pessoa Juridica */
            
        PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qtdoclot                   FORMAT "99999"
                        "B   "
                        aux_tppessoa                   FORMAT "9"
                        craptvl.cpfcgrcb               FORMAT "99999999999999"
                        FILL(" ",30)                   FORMAT "x(30)"
                        "00000"                        FORMAT "99999"
                        FILL(" ",50)                   FORMAT "x(50)"
                        "00000"                        FORMAT "99999"
                        "     "                        FORMAT "x(05)"
                        "00000000"                     FORMAT "99999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        FILL(" ",30)                   FORMAT "x(30)" SKIP.  
                                                 
       IF   LAST-OF(crattem.nrdolote) THEN
            DO:
                /*   Trailer do Lote   */
                PUT STREAM str_1 "001"
                                 crattem.nrdolote   FORMAT "9999"
                                 "5         "
                                 (aux_qtdoclot + 2) FORMAT "999999"
                                 (aux_vltotlot * 100)  
                                                    FORMAT "999999999999999999"
                                 "000000000000000000000000"
                                 FILL(" ",165)      FORMAT "x(165)"
                                 "0000000000"
                                 SKIP.
            END.

       IF   LAST-OF(crattem.cdseqarq) THEN
            DO:
                ASSIGN aux_qtlinarq = aux_qtregarq + (crattem.nrdolote * 2) + 2.
                
                /*   Trailer do Arquivo   */
                PUT STREAM str_1 "00199999         "
                                 crattem.nrdolote    FORMAT "999999"
                                 aux_qtlinarq        FORMAT "999999"
                                 "000000"
                                 FILL(" ",205)       FORMAT "x(205)" 
                                 SKIP.
                
                OUTPUT STREAM str_1 CLOSE.

                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                                  " > /micros/" + crapcop.dsdircop + 
                                  "/compel/" + aux_nmarquiv + " 2>/dev/null").

                UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                                  " salvar 2>/dev/null").
            END.
       
   END.  /*  Fim do FOR EACH -- crattem  */

   IF   glb_cdcritic > 0   THEN
        RETURN.
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      
      /* Atualiza a sequencia da remessa */
               
      DO aux_contador = 1 TO 10:

         FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                            craptab.nmsistem = "CRED"        AND
                            craptab.tptabela = "CONFIG"      AND
                            craptab.cdempres = 00            AND
                            craptab.cdacesso = "COMPELBBDC"  AND
                            craptab.tpregist = 000
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craptab   THEN
              IF   LOCKED craptab   THEN
                   DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        NEXT.
                   END.
              ELSE
                   DO:
                       glb_cdcritic = 55.
                       LEAVE.
                   END.    
         ELSE
              glb_cdcritic = 0.

         LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0 THEN
           RETURN.

      craptab.dstextab = SUBSTR(craptab.dstextab,1,20)  + " " +
                         STRING(aux_cdsequen,"999999")  + " " +
                         STRING(aux_cdseqarq,"999999").
                        
   END. /* TRANSACTION */

END PROCEDURE.

PROCEDURE proc_gera_arquivo_ted_bbrasil:

   DEF  VAR aux_tamanho  AS INTE                                       NO-UNDO.
   DEF  VAR aux_digito   AS CHAR                                       NO-UNDO.
   DEF  var aux_conta    AS DEC                                        NO-UNDO.

   EMPTY TEMP-TABLE crattem.
   
   /* Contadores de arquivo e registros */
   ASSIGN aux_qtarquiv = 0
          aux_totregis = 0.

   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "CONFIG"      AND
                      craptab.cdempres = 00            AND
                      craptab.cdacesso = "COMPELBBDC"  AND
                      craptab.tpregist = 000 NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 55.
            RETURN.
        END.    
                            
   ASSIGN aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,29,06))
                         /* Sequencial  arquivo - Zera a cada dia */
          aux_nrdolote = 0
          flg_doctobb  = NO.
   
   FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper     AND
                          craptvl.dtmvtolt = tel_dtmvtolt     AND
                          craptvl.cdagenci >= tel_cdagenci    AND
                          craptvl.cdagenci <= aux_cdagefim    AND
                          craptvl.tpdoctrf = 3                AND /* TED */ 
                          craptvl.flgenvio = FALSE            NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = craptvl.cdagenci AND
                          crawage.cdbandoc <> crapcop.cdbcoctl NO-LOCK
            BREAK BY craptvl.cdagenci
                  BY craptvl.cdbccrcb:
       
       IF   FIRST-OF(craptvl.cdagenci) THEN
            ASSIGN aux_cdseqarq = aux_cdseqarq  + 1
                   flg_doctobb  = NO
                   aux_qtarquiv = aux_qtarquiv + 1
                   aux_nmarquiv = "td" +
                                  STRING(craptvl.nrdocmto, "9999999") +
                                  STRING(DAY(glb_dtmvtolt),"99")   + 
                                  STRING(MONTH(glb_dtmvtolt),"99") +
                                  STRING(craptvl.cdagenci, "999") +
                                  ".rem".

       /* DOC BB lote = 1  , demais lote = 2 */
       IF   craptvl.cdbccrcb = 1 THEN
            ASSIGN aux_nrdolote =  1
                   flg_doctobb  = YES.
       ELSE
            IF   flg_doctobb = YES THEN
                 ASSIGN aux_nrdolote = 2.
            ELSE
                 ASSIGN aux_nrdolote = 1.
   
       ASSIGN glb_dsdctitg = STRING(craptvl.nrcctrcb,"9999999999999").
              aux_tamanho  = LENGTH(glb_dsdctitg).
              aux_digito   = SUBSTR(glb_dsdctitg,aux_tamanho,1).
              aux_conta    =                   
                  DEC(SUBSTR(STRING(craptvl.nrcctrcb,"9999999999999"),1,12)).

       IF   craptvl.flgpescr = YES THEN   /* Pessoa Fisica */
            ASSIGN aux_tppessoa = 1.
       ELSE
            ASSIGN aux_tppessoa = 2.      /* Pessoa Juridica */
       
       CREATE crattem.
       ASSIGN crattem.cdseqarq = aux_cdseqarq
              crattem.nrdolote = aux_nrdolote
              crattem.cddbanco = 1
              crattem.nmarquiv = aux_nmarquiv
              crattem.nrrectit = RECID(craptvl)
              crattem.nrdconta = aux_conta
              crattem.cdagenci = craptvl.cdagenci
              crattem.cdbantrf = craptvl.cdbccrcb
              crattem.cdagetrf = craptvl.cdagercb
              crattem.nrctatrf = aux_conta
              crattem.nrdigtrf = aux_digito
              crattem.nmfuncio = craptvl.nmpesrcb
              crattem.nrcpfcgc = craptvl.cpfcgrcb
              crattem.nrdocmto = craptvl.nrdocmto
              crattem.vllanmto = craptvl.vldocrcb
              crattem.dtmvtolt = craptvl.dtmvtolt
              crattem.tppessoa = aux_tppessoa
              aux_totregis     = aux_totregis + 1.
   END. 

   /* Instancia a BO */
   RUN sistema/generico/procedures/b1wgen0012.p 
       PERSISTENT SET h-b1wgen0012.

   RUN gera-arquivo-ted-doc IN h-b1wgen0012(INPUT  TABLE crattem,
                                            INPUT  glb_cdcooper,
                                            INPUT  glb_dtmvtolt,
                                            OUTPUT glb_dscritic).
   DELETE PROCEDURE h-b1wgen0012.
      
   IF   glb_dscritic <> ""   THEN
        DO:
            MESSAGE glb_dscritic.
            PAUSE 3 NO-MESSAGE.
            UNDO.
        END.
   ELSE
        DO:
            MESSAGE "Arquivo gerado com sucesso!".
            PAUSE 3 NO-MESSAGE.
        END.
   
END PROCEDURE.


PROCEDURE atualiza_docs:

   HIDE MESSAGE NO-PAUSE.
   MESSAGE "Atualizando docs gerados ...".

   FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper  AND
                          craptvl.dtmvtolt = tel_dtmvtolt  AND
                          craptvl.cdagenci >= tel_cdagenci AND
                          craptvl.cdagenci <= aux_cdagefim AND  
                          craptvl.flgenvio = FALSE         AND
                        ((tel_flgtpdoc     = YES /* DOC */ AND 
                          craptvl.tpdoctrf <> 3)           OR
                         (tel_flgtpdoc     = NO  /* TED */ AND
                          craptvl.tpdoctrf  = 3))          NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = craptvl.cdagenci AND
                          crawage.cdbandoc <> crapcop.cdbcoctl NO-LOCK:
       
       FIND crabtvl where RECID(crabtvl) = RECID(craptvl) 
                          EXCLUSIVE-LOCK NO-ERROR.
       
       IF  AVAIL crabtvl THEN
           DO:
              ASSIGN crabtvl.flgenvio = TRUE
                     crabtvl.cdbcoenv = crawage.cdbandoc.
              RELEASE crabtvl.
           END.
   END.

END PROCEDURE.

PROCEDURE proc_gera_arquivo_ted:

   EMPTY TEMP-TABLE crattem.
   
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                      craptab.nmsistem = "CRED"        AND
                      craptab.tptabela = "CONFIG"      AND
                      craptab.cdempres = 00            AND
                      craptab.cdacesso = "COMPELBBDC"  AND
                      craptab.tpregist = 000 NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            glb_cdcritic = 55.
            RETURN.
        END.    
                            
   ASSIGN aux_nrconven = SUBSTR(craptab.dstextab,1,20)
          aux_cdsequen = INTEGER(SUBSTR(craptab.dstextab,22,06)) 
                         /* Sequencial a  cada Header Arq(Nao zera)*/
          aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,29,06)). 
                         /* Sequencial  arquivo - Zera a cada dia */
   
   FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper     AND
                          craptvl.dtmvtolt = tel_dtmvtolt     AND
                          craptvl.cdagenci = tel_cdagenci     AND
                          craptvl.tpdoctrf = 3                AND
                          craptvl.nrdocmto = tel_nrdocto_ted  NO-LOCK
                          BREAK BY craptvl.cdagenci:
       
       IF   FIRST-OF(craptvl.cdagenci) THEN
            ASSIGN aux_cdseqarq = aux_cdseqarq  + 1
                   aux_nrdolote = 0.
                   
       ASSIGN aux_nrdolote =  aux_nrdolote + 1.
       
       CREATE crattem.
       ASSIGN crattem.cdseqarq = aux_cdseqarq
              crattem.nrdolote = aux_nrdolote
              crattem.cddbanco = 1
              crattem.nrrectit = RECID(craptvl).
   END. 
       
   ASSIGN aux_dtmvtolt = STRING(DAY(glb_dtmvtolt),"99") +
                         STRING(MONTH(glb_dtmvtolt),"99") +
                         STRING(YEAR(glb_dtmvtolt),"9999")
          aux_qtarquiv = 0
          aux_qtregarq = 0.
                                     
   FOR EACH crattem USE-INDEX crattem1 NO-LOCK 
                    BREAK BY crattem.cdseqarq BY crattem.nrdolote:

       FIND craptvl WHERE RECID(craptvl) = crattem.nrrectit NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE craptvl THEN
            DO:
                ASSIGN glb_cdcritic = 770.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                                  
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + glb_dscritic +  " " +
                            " Sequencia: " + STRING(crattem.cdseqarq ,"9999") +
                            " >> log/compel.log").
                LEAVE.
             END.
       
       FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                          crapage.cdagenci = craptvl.cdagenci NO-LOCK NO-ERROR.
       
       IF   NOT AVAILABLE crapage THEN
            DO:
                ASSIGN glb_cdcritic = 015.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                                  
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                            " - Ref.: " + STRING(glb_dtmvtolt,"99/99/9999") +
                            " " + glb_dscritic +  " " +
                            " Sequencia: " + STRING(crattem.cdseqarq ,"9999") +
                            " >> log/compel.log").
                LEAVE.
            END.
       
       IF   FIRST-OF(crattem.cdseqarq)  THEN
            DO:
                ASSIGN aux_qtregarq = 0
                       aux_hrarquiv = SUBSTR(STRING(time, "HH:MM:SS"), 1,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 4,2) +
                                      SUBSTR(STRING(time, "HH:MM:SS"), 7,2)
                       aux_qtarquiv = aux_qtarquiv + 1
                       aux_nmarquiv = "dc" +
                                      STRING(craptvl.nrdocmto, "9999999") +
                                      STRING(DAY(glb_dtmvtolt),"99") + 
                                      STRING(MONTH(glb_dtmvtolt),"99") +
                                      STRING(craptvl.cdagenci, "999") +
                                      ".rem".

                IF   SEARCH("arq/" + aux_nmarquiv) <> ?   THEN
                     DO:
                         BELL.
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Arquivo ja existe:" aux_nmarquiv.
                         glb_cdcritic = 459.
                         RETURN.
                     END.
                                                
                OUTPUT STREAM str_1 TO VALUE("arq/" + aux_nmarquiv).
                
                /*   Header do Arquivo    */
                
                ASSIGN aux_cdsequen = aux_cdsequen + 1.
                
                PUT STREAM str_1
                           "00100000"
                           FILL(" ",09)      FORMAT "x(09)"
                           "2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctabbd  FORMAT "9999999999999"
                           " "               FORMAT "x(01)"
                           crapcop.nmrescop  FORMAT "x(30)"
                           "BANCO DO BRASIL"
                           FILL(" ",25)      FORMAT "x(25)"
                           "1"
                           aux_dtmvtolt      FORMAT "x(08)"
                           aux_hrarquiv      FORMAT "x(06)"
                           aux_cdsequen      FORMAT "999999"
                           "03000000"
                           FILL(" ",54)      FORMAT "x(54)" 
                           "000000000000000" SKIP.
            END.

       IF   FIRST-OF(crattem.nrdolote)  THEN
            DO:
                ASSIGN aux_qtdoclot = 0
                       aux_vltotlot = 0.
                                       
                /*   Header do Lote    */
                
                ASSIGN  aux_valor2 =  "1C9803".
          
                IF  craptvl.cdbccrc = 1 THEN
                    ASSIGN aux_valor2  = "1C9801".  /* BANCO BRASIL */

                PUT STREAM str_1
                           "001"
                           crattem.nrdolote  FORMAT "9999"
                           aux_valor2        FORMAT "x(06)"
                           "020 2"
                           crapcop.nrdocnpj  FORMAT "99999999999999"
                           aux_nrconven      FORMAT "x(20)"
                           crapcop.cdagedbb  FORMAT "999999"
                           crapcop.nrctabbd  FORMAT "9999999999999"
                           " "               FORMAT "x(01)"
                           crapcop.nmrescop  FORMAT "x(30)"
                           FILL(" ",40)      FORMAT "x(40)"
                           crapcop.dsendcop  FORMAT "x(30)"
                           crapcop.nrendcop  FORMAT "99999"
                           FILL(" ",15)      FORMAT "x(15)"
                           crapcop.nmcidade  FORMAT "x(20)"
                           crapcop.nrcepend  FORMAT "99999999" 
                           crapcop.cdufdcop  FORMAT "!(2)"
                           FILL(" ",08)      FORMAT "x(08)" 
                           "0000000000"      SKIP.
            END.
       
       ASSIGN aux_qtdoclot = aux_qtdoclot + 1
              aux_vltotlot = aux_vltotlot + craptvl.vldocrcb
              aux_qtregarq = aux_qtregarq + 1.

       ASSIGN aux_digitage = " ".

       IF  craptvl.cdbccrcb = 1 THEN
           DO:
               ASSIGN glb_nrcalcul = craptvl.cdagercb * 10.
               RUN fontes/digbbx.p(INPUT  glb_nrcalcul,
                                   OUTPUT glb_dsdctitg,
                                   OUTPUT glb_stsnrcal).
               ASSIGN aux_digitage =  SUBSTR(glb_dsdctitg,8,1).
           END.       
           
       ASSIGN aux_valor = "A000700".

       IF craptvl.cdbccrcb = 1 THEN        /* BANCO BRASIL */
          ASSIGN aux_valor = "A000000".
     
       /*--- Transformar digito numerico em alfa - somente BB --*/
        ASSIGN glb_dsdctitg = STRING(craptvl.nrcctrcb,"9999999999999")
               aux_tamanho = LENGTH(glb_dsdctitg)
               aux_digito  = SUBSTR(glb_dsdctitg,aux_tamanho,1)
               aux_conta   = 
                   DEC(SUBSTR(STRING(craptvl.nrcctrcb,"9999999999999"),1,12)).
       
       PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qtdoclot                   FORMAT "99999"
                        aux_valor                      FORMAT "x(07)"
                        craptvl.cdbccrcb               FORMAT "999"
/* Agencia s/Digito */  craptvl.cdagercb               FORMAT "99999"
/* Digito da Agencia */ aux_digitage                   FORMAT "x(01)"
/* Conta s/Digito */    aux_conta                      FORMAT "999999999999"
/* Digito da Conta */   aux_digito                     FORMAT "x(01)"
/* Digito Ag/Conta */   " "                            FORMAT "x(01)"
                        craptvl.nmpesrcb               FORMAT "x(30)"
                        STRING(craptvl.nrdocmto)       FORMAT "x(20)"
                        DAY(craptvl.dtmvtolt)          FORMAT "99"
                        MONTH(craptvl.dtmvtolt)        FORMAT "99"
                        YEAR(craptvl.dtmvtolt)         FORMAT "9999"
                        "BRL"
                        "000000000000000"
                        craptvl.vldocrcb * 100         FORMAT "999999999999999"
                        FILL(" ",20)      FORMAT "x(20)"
                        FILL(" ",8)       FORMAT "x(08)"
                        "000000000000000"
                        FILL(" ",52)      FORMAT "x(52)"
                        "0"
                        "0000000000"      SKIP.
                 
        ASSIGN aux_qtdoclot = aux_qtdoclot + 1
               aux_qtregarq = aux_qtregarq + 1.

        IF   craptvl.flgpescr = YES THEN   /* Pessoa Fisica */
             ASSIGN aux_tppessoa = 1.
        ELSE
             ASSIGN aux_tppessoa = 2.      /* Pessoa Juridica */
            
        PUT STREAM str_1 "001"
                        crattem.nrdolote               FORMAT "9999"
                        "3"
                        aux_qtdoclot                   FORMAT "99999"
                        "B   "
                        aux_tppessoa                   FORMAT "9"
                        craptvl.cpfcgrcb               FORMAT "99999999999999"
                        FILL(" ",30)                   FORMAT "x(30)"
                        "00000"                        FORMAT "99999"
                        FILL(" ",50)                   FORMAT "x(50)"
                        "00000"                        FORMAT "99999"
                        "     "                        FORMAT "x(05)"
                        "00000000"                     FORMAT "99999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        "000000000000000"              FORMAT "999999999999999"
                        FILL(" ",30)                   FORMAT "x(30)" SKIP.  
                                                 
       IF   LAST-OF(crattem.nrdolote) THEN
            DO:
                /*   Trailer do Lote   */
                PUT STREAM str_1 "001"
                                 crattem.nrdolote   FORMAT "9999"
                                 "5         "
                                 (aux_qtdoclot + 2) FORMAT "999999"
                                 (aux_vltotlot * 100)  
                                                    FORMAT "999999999999999999"
                                 "000000000000000000000000"
                                 FILL(" ",165)      FORMAT "x(165)"
                                 "0000000000"
                                 SKIP.
            END.

       IF   LAST-OF(crattem.cdseqarq) THEN
            DO:
                aux_qtlinarq = aux_qtregarq +  2.
                
                /*   Trailer do Arquivo   */
                PUT STREAM str_1 "00199999         "
                /* Qtd.Lotes*/   crattem.nrdolote    FORMAT "999999"
                                 aux_qtlinarq        FORMAT "999999"
                                 "000000"
                                 FILL(" ",205)       FORMAT "x(205)" 
                                 SKIP.
                
                OUTPUT STREAM str_1 CLOSE.

                UNIX SILENT VALUE("ux2dos arq/" + aux_nmarquiv + 
                                  " > /micros/" + crapcop.dsdircop + 
                                  "/compel/" + aux_nmarquiv + " 2>/dev/null").

                UNIX SILENT VALUE("mv arq/" + aux_nmarquiv + 
                                  " salvar 2>/dev/null").
            END.
       
   END.  /*  Fim do FOR EACH -- crattem  */

   IF   glb_cdcritic > 0   THEN
        RETURN.
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      
      /*   Atualiza a sequencia da remessa  */
               
      DO   aux_contador = 1 TO 10:
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "CONFIG"     AND
                              craptab.cdempres = 00           AND
                              craptab.cdacesso = "COMPELBBDC" AND
                              craptab.tpregist = 000
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE craptab   THEN
                IF   LOCKED craptab   THEN
                     DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        NEXT.
                     END.
                ELSE
                     DO:
                         glb_cdcritic = 55.
                         LEAVE.
                     END.    
           ELSE
                glb_cdcritic = 0.

           LEAVE.

      END.  /*  Fim do DO .. TO  */

      IF   glb_cdcritic > 0 THEN
           RETURN.

      craptab.dstextab = SUBSTR(craptab.dstextab,1,20)  + " " +
                         STRING(aux_cdsequen,"999999")  + " " +
                         STRING(aux_cdseqarq,"999999").
                        
   END. /* TRANSACTION */

END PROCEDURE.

PROCEDURE p_regera_agencia:

  ASSIGN aux_confirma = "N".
  UPDATE   aux_confirma WITH FRAME f_regera.
  
  IF  aux_confirma <> "N" THEN 
      DO:
         EMPTY TEMP-TABLE crawage.

         FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
             CREATE crawage.
             ASSIGN crawage.cdagenci = crapage.cdagenci
                    crawage.nmresage = crapage.nmresage
                    crawage.cdbandoc = crapage.cdbandoc
                    crawage.cdcomchq = crapage.cdcomchq.
         END.
      END.
  
  HIDE frame f_regera NO-PAUSE.
  
END PROCEDURE.

PROCEDURE atualiza_controle_operador:

  FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                     craptab.nmsistem = "CRED"           AND       
                     craptab.tptabela = "GENERI"         AND
                     craptab.cdempres = crapcop.cdcooper AND       
                     craptab.cdacesso = "DOCTOS"         AND
                     craptab.tpregist = 1  
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  IF  AVAIL craptab THEN      
      DO:
         ASSIGN craptab.dstextab = " ".
         RELEASE craptab.
      END.

END PROCEDURE.

PROCEDURE atualiza_docs_regerar:

   HIDE MESSAGE NO-PAUSE.
   MESSAGE "Atualizando DOCs/TEDs gerados ...".

   FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper  AND
                          craptvl.dtmvtolt = tel_dtmvtolt  AND
                          craptvl.flgenvio = TRUE          AND  
                          craptvl.cdagenci >= tel_cdagenci AND
                          craptvl.cdagenci <= aux_cdagefim AND
                        ((tel_flgtpdoc     = YES /* DOC */ AND 
                          craptvl.tpdoctrf <> 3)           OR
                         (tel_flgtpdoc     = NO  /* TED */ AND
                          craptvl.tpdoctrf  = 3))          AND
                         (craptvl.nrdocmto  = tel_doctos    OR
                          tel_doctos = 0) NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = craptvl.cdagenci AND
                          crawage.cdbandoc <> crapcop.cdbcoctl NO-LOCK:
  
       FIND crabtvl where RECID(crabtvl) = RECID(craptvl) 
                          EXCLUSIVE-LOCK NO-ERROR.
       IF  AVAIL crabtvl THEN
           DO:
              ASSIGN crabtvl.flgenvio = FALSE
                     crabtvl.cdbcoenv = 0.
              RELEASE crabtvl.
           END.
   END.

   /*  Verifica se ja foi gerado o arquivo e 
      exclui os genericos do titulo ja gerado  */
            
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      FOR EACH gncpdoc WHERE gncpdoc.cdcooper =  glb_cdcooper AND
                             gncpdoc.dtmvtolt =  glb_dtmvtolt AND
                             gncpdoc.cdtipreg =  1            AND
                             gncpdoc.cdagenci >= tel_cdagenci AND
                             gncpdoc.cdagenci <= aux_cdagefim 
                             EXCLUSIVE-LOCK:
          DELETE gncpdoc.
      END.
   END.   /* TRANSACTION */
   
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
            " - " + STRING(glb_dtmvtolt,"99/99/9999") +
            " - DOC/TEC REGERADOS -  PA de " + 
            STRING(tel_cdagenci) + " ate " + STRING(aux_cdagefim) +
            " - Data: " + STRING(tel_dtmvtolt,"99/99/9999") +
            " >> log/doctos.log").

END PROCEDURE.

/* .......................................................................... */

PROCEDURE proc_limpa: /*  Procedure para limpeza da tela  */

    HIDE FRAME f_refere.
    HIDE FRAME f_refere_v.
    HIDE FRAME f_refere_x  NO-PAUSE.
    HIDE FRAME f_lotes_doc NO-PAUSE.
    HIDE FRAME f_ted.
    HIDE FRAME f_totais.
    HIDE FRAME f_opcao_h.
    RETURN.

END PROCEDURE.

/* .......................................................................... */

