/* .............................................................................

   Programa: Fontes/gt0001.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                        Ultima Atualizacao: 26/05/2018

   Dados referentes ao programa:
                     
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Cadastramento dos Convenios(Generico)

   Alteracoes: 13/12/2004 - Inclusao do campo, historico para repasse CECRED
                            (Julio)

               31/03/2005 - Criado tipo 4 para transmissao de arquivos 
                            "e-mail com senha" (Julio)

               03/07/2005 - Inclusao do campo flgcvuni, para convenios que
                            precisam receber um soh arquivo (Julio)

               11/01/2006 - Alteracao na validacao dos historicos, nao validar
                            mais pelo gener, mas sim pelo craphis. 
                            Alteracao nos campos de preenchimento de
                            email's (Julio)

               18/01/2006 - Acrescentado campo flgdecla, referente autorizacao
                            para impressao de declaracao (Diego).

               20/01/2006 - Acrescentado HELP no campo flgdecla (Diego).
               
               24/05/2007 - Incluido campo flggeraj, referente a confirmacao do
                            recebimento do arquivo de debito (Elton).

               01/06/2007 - Incluido ACCESTAGE entre as opcoes de tipo de envio
                            (Elton).
                            
               23/08/2007 - Incluido novos parametros Pagamento Internet e
                            Tarifa Internet(Guilherme).
                            
               22/01/2008 - Impedir a digitacao dos valores das tarifas (David).
               
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS.
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                            
                          - Declaracao de variavel para campo tel_flgautdb, 
                            Aut.Debito e alterado help do browse (Gabriel).
                            
               20/10/2008 - Inclusao dos campos para Repasse: Banco, Agencia,
                            Conta, CNPJ e Tipo (Diego).
                            
               06/11/2008 - Aumentado Format do campo tel_cdagercb (Diego).
               
               12/11/2008 - Incluida variavel tel_flgindeb, e substituidas:
                            tel_nrccdrcb => tel_dsccdrcb
                            tel_cdagercb => tel_dsagercb (Diego).
                            
               03/03/2009 - Permitir somente operador 799 ou 1 nas
                            opcoes A,I,E.   (Fernando).
                          
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               02/06/2010 - Incluido campo Trf.TAA e alterado label de alguns 
                            campos (Elton).
                            
               29/03/2011 - Incluido os operadores "997, 979, 126"
                            na condicao glb_cdcooper <> "C" (Adriano).
                            
               06/12/2011 - Alterações nos campos "Hist.Pagto:", "Hist.Automatico:"
                            e "Hist.Repasse Cecred" de 3 para 4 posições.
                            Alterada a inicialização da var tel_flgautdb para FALSE.
                            (Lucas). 
                            
               07/03/2012 - Inclusao dos campos:
                            - tel_flgenvpa
                            - tel_nrseqpar
                            - tel_nmarqpar
                            (Adriano).             
                            
               23/04/2012 - Incluido o departamento "COMPE" na validacao dos
                            departamentos (Adriano);
                          - Substituido codigo do fonte gt0001.p pelo codigo do
                            fonte gt0001p.p (Elton).   
                            
               22/06/2012 - Substituido gncoper por crapcop (Tiago).         
                                       
               10/01/2013 - Retirado o operador "997" e incluido o "30097" nas
                            opcoes de repasse.(Mirtes)
                            
               10/09/2013 - Substituido campo "Agencia:" (gnconve.cdagedeb )
                            por "Usa Agencia:" (gnconve.flgagenc)
                          - Incluido campo "Dir.Accesstage:" (gnconve.dsdiracc).
                            (Reinert)
                            
               03/04/2014 - Inclusao do campo tel_tprepass.
                            (PRJ Automatizacao TED pagto convenios repasse) - 
                            (Fabricio)
                            
               13/06/2014 - Exclusao do operador '30097' e inclusao dos
                            operadores 'F0030503', 'F0030642' e 'F0030175'.
                            (Chamado 164027) - (Fabricio).
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               01/12/2014 - Implementacao Van E-Sales (substituindo a Van
                            Interchange, nao mais utilizada); utilizacao inicial
                            pela Oi. (Chamado 192004) - (Fabricio)
                            
               10/02/2015 - Inclusao do campo tel_flgdbssd.
                            (PRJ Melhoria - Chamado 229249) - (Fabricio)
                            
               18/09/2015 - Inclusão do campo tel_nrctdbfl PRJ 214 (Vanessa)
 
               14/09/2016 - Incluir chamada da rotina var_oracle.i (Lucas Ranghetti #484556)
               
               01/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
			   29/03/2017 - Ajutes devido ao tratamento da versao do layout FEBRABAN
							(Jonata RKAM M311)
............................................................................. */

{ includes/var_online.i  }
{ sistema/generico/includes/var_oracle.i }

DEF        VAR tel_nrseqatu    LIKE gnconve.nrseqatu                 NO-UNDO.
DEF        VAR tel_nrseqint    LIKE gnconve.nrseqint                 NO-UNDO.
DEF        VAR tel_nrseqcxa    LIKE gnconve.nrseqcxa                 NO-UNDO.
DEF        VAR tel_nrcnvfbr    LIKE gnconve.nrcnvfbr                 NO-UNDO.
DEF        VAR tel_nmempres    LIKE gnconve.nmempres                 NO-UNDO.
DEF        VAR tel_cddbanco    LIKE gnconve.cddbanco                 NO-UNDO.
DEF        VAR tel_vltrfcxa    AS DECI FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltrfnet    AS DECI FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_flginter    LIKE gnconve.flginter                 NO-UNDO.
DEF        VAR tel_vltrftaa    AS DECI FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_vltrfdeb    LIKE gnconve.vltrfdeb                 NO-UNDO.
DEF        VAR tel_cdhisrep    AS INT FORMAT "z999"                  NO-UNDO.
DEF        VAR tel_cdhiscxa    AS INT FORMAT "z999"                  NO-UNDO.
DEF        VAR tel_cdhisdeb    AS INT FORMAT "z999"                  NO-UNDO.
DEF        VAR tel_nmarqatu    LIKE gnconve.nmarqatu                 NO-UNDO.
DEF        VAR tel_nmarqcxa    LIKE gnconve.nmarqcxa                 NO-UNDO.
DEF        VAR tel_nrctdbfl    LIKE gnconve.nrctdbfl  FORMAT "z999" NO-UNDO.
DEF        VAR tel_flgagenc    AS LOGI FORMAT "Sim/Nao" INIT FALSE   NO-UNDO.
DEF        VAR tel_nmarqint    LIKE gnconve.nmarqint                 NO-UNDO.
DEF        VAR tel_nmarqdeb    LIKE gnconve.nmarqdeb                 NO-UNDO.
DEF        VAR tel_cdconven    LIKE gnconve.cdconve                  NO-UNDO.
DEF        VAR tel_cdcooper    LIKE gnconve.cdcooper                 NO-UNDO.
DEF        VAR tel_tpdenvio    LIKE gnconve.tpdenvio                 NO-UNDO.
DEF        VAR tel_dsdiracc    LIKE gnconve.dsdiracc                 NO-UNDO.
DEF        VAR tel_nmrescop    LIKE crapcop.nmrescop                 NO-UNDO.   
DEF        VAR tel_flgativo    LIKE gnconve.flgativo                 NO-UNDO.
DEF        VAR tel_flgcvuni    LIKE gnconve.flgcvuni                 NO-UNDO.
DEF        VAR tel_flgdecla    LIKE gnconve.flgdecla                 NO-UNDO.
DEF        VAR tel_flgindeb    LIKE gnconve.flgindeb                 NO-UNDO.
DEF        VAR tel_flggeraj    LIKE gnconve.flggeraj                 NO-UNDO.
DEF        VAR tel_flgautdb    AS LOGI FORMAT "Sim/Nao" INIT FALSE   NO-UNDO.
DEF        VAR tel_dsagercb AS CHAR                                  NO-UNDO.
DEF        VAR tel_cdbccrcb    LIKE gnconve.cdbccrcb                 NO-UNDO.
DEF        VAR tel_dsccdrcb AS CHAR                                  NO-UNDO.
DEF        VAR tel_cpfcgrcb    LIKE gnconve.cpfcgrcb                 NO-UNDO.
DEF        VAR tel_flgrepas AS LOG     FORMAT "B/L"     INIT TRUE    NO-UNDO.
DEF        VAR tel_flgdbssd AS LOG     FORMAT "Sim/Nao" INIT FALSE   NO-UNDO.

DEF        VAR tel_dsemail1 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dsemail2 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dsemail3 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dsemail4 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dsemail5 AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dsemail6 AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR tel_flgenvpa LIKE gnconve.flgenvpa                    NO-UNDO.
DEF        VAR tel_nrlayout LIKE gnconve.nrlayout                    NO-UNDO.
DEF        VAR tel_nrseqpar LIKE gnconve.nrseqpar                    NO-UNDO.
DEF        VAR tel_nmarqpar LIKE gnconve.nmarqpar                    NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

DEF        VAR tel_tprepass AS CHAR VIEW-AS COMBO-BOX 
                            LIST-ITEMS "D+1","D+2" FORMAT "x(03)"    NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Opcao:"       AT 6
     glb_cddopcao   AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, E, I)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")
     SKIP (1)
     tel_cdconven           LABEL "Cod.Convenio"
                            HELP "Informe nro convenio"
     tel_nmempres    AT 29  Label "Nome"
                            HELP "Informe nome Empresa Convenio"
                            VALIDATE (tel_nmempres <> " ",
                            "357 - O campo deve ser preenchido.")
     SKIP
     tel_cdcooper           LABEL "Cooperativa"
                            HELP "Informe Cooperativa Dominio Convenio"
     tel_nmrescop    AT 29  LABEL "Nome"
     SKIP
     tel_nrcnvfbr           LABEL "Conv.Febraban"
                            HELP "Informe Codigo Convenio Febraban"
     tel_flgativo    AT 39  LABEL "Ativo"
                            HELP "Convenio Ativo(Sim/Nao)" 
     tel_flginter    AT 52  LABEL "Pagamento Internet"                         
     SKIP
     tel_flgenvpa           LABEL "Arquivo Parcial"
                          HELP "Envia arquivo parcial ( (E)nvia / (N)ao )."
     SKIP 
     tel_nrseqatu           LABEL "Seq.Atualiz./Deb."
                          HELP "Informe nro sequencial arq. Atualizacao Cad."
     tel_nrseqint    AT 32  LABEL "Seq.Integ."
                           HELP "Informe nro sequencial arq. Debito Automatico"
     tel_nrseqcxa    AT 53  LABEL "Seq.Caixa"
                           HELP "Informe nro sequencial arq. Arrecadacao Caixa"
     SKIP
     tel_nrseqpar           LABEL "Seq.Parc."
                            HELP "colocar algo aqui"
     tel_flgagenc    AT 31  LABEL "Usa Agencia"
                            HELP "Informe se usa agencia (Sim/Nao)"
     tel_cddbanco    AT 57  LABEL "Banco"
                            HELP "Informe Codigo do Banco"
     SKIP
     tel_cdhiscxa           LABEL "Hist.Pagto" 
                     VALIDATE(CAN-FIND(craphis where 
                                       craphis.cdcooper = glb_cdcooper AND
                                       craphis.cdhistor = INPUT tel_cdhiscxa)OR
                              INPUT tel_cdhiscxa = 0,
                              "526 - Historico nao Cadastrado")
                     HELP "Informe Codigo de Historico para Faturas Caixa"
     tel_vltrfcxa    AT 19  LABEL "Trf.Caixa"
                     HELP "Informe Valor tarifa para faturas caixa"
     tel_vltrfnet    AT 38  LABEL "Trf.Internet"
     tel_vltrftaa    AT 62  LABEL  "Trf.TAA" 
     tel_cdhisdeb           LABEL "Hist.Automatico"
                     VALIDATE(CAN-FIND(craphis where 
                              craphis.cdcooper = glb_cdcooper        AND 
                              craphis.cdhistor = INPUT tel_cdhisdeb) OR
                              INPUT tel_cdhisdeb = 0,
                              "526 - Historico nao Cadastrado")
                     HELP "Informe Codigo de Historico para Debito Automatico"
     tel_vltrfdeb    AT 41  LABEL "Tarifa Debito Automatico"
                     HELP "Informe Valor tarifa para debito automatico"
     tel_cdhisrep           LABEL "Hist.Repasse Ailos"
                     VALIDATE(CAN-FIND(craphis WHERE
                                  craphis.cdcooper = glb_cdcooper        AND  
                                  craphis.cdhistor = INPUT tel_cdhisrep) OR
                              tel_cdhisrep = 0,
                              "526 - Historico nao Cadastrado")
                     HELP "Informe Codigo de historico para repasse AILOS"
     tel_tprepass    AT 28 LABEL "Forma de Repasse"
                     HELP "Selecione o tipo de repasse"
     tel_flgdbssd    AT 55 LABEL "Debita sem Saldo"
                     HELP "Informe se o debito deve ocorrer mesmo sem saldo (Sim/Nao)"
     SKIP
     tel_nmarqatu           LABEL "Arq.Atualiz."
                            Help "Informe Nome do Arquivo"
     tel_nmarqcxa    AT 30  LABEL "Arq.Pagto" 
                            Help "Informe Nome do Arquivo"
     tel_nrctdbfl    AT 57  LABEL "Cta.Deb.Filiad" 
                            Help "Informe a Conta de Debito da Filiada"
     tel_nmarqint           LABEL "Arq.Integ."
                            Help "Informe Nome do Arquivo"
     tel_nmarqdeb    AT 28  LABEL "Arq.Deb."
     tel_nmarqpar    AT 55  LABEL "Arq.Parc."
                            HELP "Informe o nome do arquivo parcial."
     SKIP
     tel_flgcvuni           LABEL "Arquivo Unico"
     tel_nrlayout    AT 21  LABEL "Layout"
							VALIDATE(tel_nrlayout = 4 OR tel_nrlayout = 5,
                              "Tipo do layout invalido.")
                            HELP "Tipo do layout FEBRABAN ( Versao 4 / Versao 5 )."
	 tel_tpdenvio    AT 32  LABEL "Tipo de Envio"
         HELP "1-MAIL/2-E-SALES/3-NEXXERA/4-MAIL(SENHA)/5-ACCESSTAGE/6-WEBSERVI"
                            VALIDATE (tel_tpdenvio >= 1 AND tel_tpdenvio <= 6,
                                      "380 - Numero errado")
     tel_dsdiracc    AT 53  LABEL "Dir.Accesstage" FORMAT "X(10)"
         HELP "Informe o diretorio da acesstage"
     SKIP
     tel_flgdecla           LABEL "Declaracao"
                            HELP "Impressao da Declaracao de Autorizacao"
     tel_flggeraj    AT  20 LABEL "Gera Registro J"
     HELP "Informe se gera arquivo de confirmacao (Sim/Nao)."
     tel_flgautdb    AT  41 LABEL "Aut.Debito"
     HELP "Informe se gera autorizacao de debito (Sim/Nao)."
     tel_flgindeb    AT  59 LABEL "Aut.Inc.Deb."
     HELP "Informe se autoriza inclusao de debito (Sim/Nao)."
     SKIP                                 
     "REPASSES:"  
     tel_cdbccrcb  LABEL "Bco"
                   HELP "Entre com o banco que recebera o repasse"
     tel_dsagercb  LABEL "Age"    FORMAT "xxxx-x"
                   HELP "Entre com a Agencia que recebera o repasse"
     tel_dsccdrcb  LABEL "Conta"  FORMAT "xxxxxxxx-x"
                   HELP "Entre com a conta corrente para o repasse"
     tel_cpfcgrcb  LABEL "CNPJ"
                   HELP "Entre com o CNPJ para o repasse"
     tel_flgrepas  LABEL "Tipo"
                   HELP "Informe tipo de repasse: (B)ruto  ou  (L)iquido"
     WITH NO-LABELS ROW 5 OVERLAY COLUMN 2 FRAME f_convenio NO-BOX SIDE-LABELS.

FORM SKIP(1)
     "End. e_mail Caixa:" AT 5  
     tel_dsemail1 AT 24 SKIP
     tel_dsemail2 AT 24 SKIP
     tel_dsemail3 AT 24 SKIP
     SKIP(1)
     "End. e_mail Debito:" AT 4  
     tel_dsemail4 AT 24 SKIP
     tel_dsemail5 AT 24 SKIP
     tel_dsemail6 AT 24 SKIP
     SKIP(1)
     WITH  NO-LABEL ROW 9 COLUMN 3 OVERLAY WIDTH 76 FRAME f_email.        

/* variaveis para mostrar a consulta */          
 
DEF QUERY  bgnconveq FOR gnconve , crapcop.

DEF BROWSE bgnconve-b QUERY bgnconveq
      DISP SPACE(5)
           gnconve.cdconven             COLUMN-LABEL "Convenio"
           SPACE(1)
           gnconve.nmempres             COLUMN-LABEL "Nome"
           SPACE(1)
           gnconve.cdcooper             COLUMN-LABEL "Cooperativa"
           SPACE(1)
           crapcop.nmrescop             COLUMN-LABEL "Nome"
           SPACE(1)
           gnconve.flgativo             COLUMN-LABEL "Ativo"
           WITH 9 DOWN OVERLAY.    

DEF FRAME f_convenioc
    bgnconve-b 
    HELP "Use as SETAS para navegar, <ENTER> para entrar e <F4> para sair"
    SKIP 
    WITH NO-BOX CENTERED OVERLAY ROW 7.

/**********************************************/


ON RETURN OF tel_nrlayout IN FRAME f_convenio DO:

   IF INPUT tel_nrlayout = 5 AND INPUT tel_nmarqatu <> "" THEN
      DO:	     
		 BELL.
         MESSAGE "Convenio nao permite o uso deste layout.".
         RETURN NO-APPLY.
	  END.
                      
END.

ON RETURN OF tel_tprepass DO:
    APPLY "GO".
END.

glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_convenio.

DO WHILE TRUE:

        DISPLAY glb_cddopcao WITH FRAME f_convenio.
        
        NEXT-PROMPT tel_cdconven WITH FRAME f_convenio.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           SET glb_cddopcao
               tel_cdconven WITH FRAME f_convenio.
           
           IF   glb_cddopcao <> "C"      THEN
                IF   glb_cddepart <> 20              AND  /* TI"           */
                     glb_cddepart <> 11              AND  /* FINANCEIRO"   */
                     glb_cddepart <>  6              AND  /* CONTABILIDADE"*/
                     glb_cddepart <>  4              AND  /* COMPE"        */
                     glb_cdoperad <> "979"           AND
                     glb_cdoperad <> "126"           AND
              UPPER(glb_cdoperad) <> "F0030503"      AND
              UPPER(glb_cdoperad) <> "F0030642"      AND
              UPPER(glb_cdoperad) <> "F0030175"      THEN
                     DO:
                        glb_cdcritic = 36.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        PAUSE 2 NO-MESSAGE.
                        glb_cdcritic = 0.
                        NEXT.
                     END.

           LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "GT0001"   THEN
                      DO:
                          HIDE FRAME f_convenio.
                          HIDE FRAME f_convenioc.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.

        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN  glb_cddopcao = INPUT glb_cddopcao
                tel_tprepass = "D+1"
                tel_tprepass:SCREEN-VALUE = "D+1".

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                  HIDE FRAME f_convenioc.
                 { includes/gt0001a.i }
             END.
        ELSE        
             IF   INPUT glb_cddopcao = "C" THEN
                  DO:
                      HIDE FRAME f_convenioc.
                      { includes/gt0001c.i }

                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E"   THEN
                       DO:
                           HIDE FRAME f_convenioc.
                       
                          { includes/gt0001e.i }

                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I"   THEN
                            DO:
                               HIDE FRAME f_convenioc.

                                { includes/gt0001i.i }

                            END.
END.

/* .......................................................................... */

