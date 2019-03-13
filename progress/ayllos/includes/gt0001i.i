/* .............................................................................

   Programa: Includes/gt0001i.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                    Ultima Atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Inclusao dos Convenios(Generico)

   Alteracoes: 13/12/2004 - Inclusao do historico repasse CECRED (Julio)

               03/06/2005 - Inclusao da opcao de unificacao de arquivos (Julio)
                
               11/01/2006 - Alteracao na validacao dos historicos, nao validar
                            mais pelo gener, mas sim pelo craphis. 
                            Alteracao nos campos de preenchimento de
                            email's (Julio)

               18/01/2006 - Acrescentado campo flgdecla, referente autorizacao
                            para impressao de declaracao (Diego).
               
               24/05/2007 - Incluido campo flggeraj, referente a confirmacao do
                            recebimento do arquivo de debito (Elton).

               21/08/2007 - Incluido campo flginter, ref. pagamento internet
                            vltrfnet, ref. valor tarifa p/ pagtos internet.
                            (Guilherme). 

               22/01/2008 - Impedir a digitacao dos valores das tarifas (David).
           
                          - Alimentar cdcooper na crapthi (Gabriel). 
                           
               22/07/2008 - Incluir campo tel_flgautdb, Autorizacao do debito
                            (Gabriel).


               24/07/2008 - Inicializar campo tel_flgautdb como "Sim" (Gabriel)
               
               20/10/2008 - Inclusao dos campos para Repasse: Banco, Agencia,
                            Conta, CNPJ e Tipo (Diego).
                            
               12/11/2008 - Incluido campo flgindeb, e substituidos:
                            nrccdrcb => dsccdrcb
                            cdagercb => dsagercb (Diego).
                            
               04/06/2010 - Incluido campo tel_vltrftaa referente ao valor de 
                            tarifa de TAA (Elton).     
                            
               15/07/2010 - Criado log da tela (Adriano). 
               
               29/03/2011 - Incluido condicao para que somente os operadores
                            "997, 979, 126" 
                            possam incluir nos campos de repasse
                            (Adriano).  
                            
               09/12/2011 - Alteração na inicialização da variável tel_flgautdb,
                            deixando-a com valor FALSE (Lucas).
                
               06/01/2012 - Alterado para permitir acesso aos campos
                            tel_cdbccrcb, tel_dsagercb, tel_dsccdrcb somente    
                            para os operadores:
                            - 997
                            - 126
                            - 979
                            (Adriano).
                            
               07/03/2012 - Inclusao dos campos:
                            - tel_flgenvpa
                            - tel_nrseqpar
                            - tel_nmarqpar
                            (Adriano).
 
               23/04/2012 - Incluido o departamento "COMPE" na validacao dos
                            departamentos (Adriano).  
               
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
                            
               10/02/2015 - Inclusao do campo tel_flgdbssd.
                            (PRJ Melhoria - Chamado 229249) - (Fabricio)
                            
               18/09/2015 - Inclusão do campo tel_nrctdbfl PRJ 214 (Vanessa)
               
			   08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)

			  29/03/2017 - Ajutes devido ao tratamento da versao do layout FEBRABAN
							(Jonata RKAM M311)

			  26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

              10/03/2019 - Inclusão do indicador de validação do CPF/CNPJ Layout 5.
                           Gabriel Marcos (Mouts) - SCTASK0038352.

............................................................................. */


IF   tel_cdconven = 0   THEN
     DO:
         ASSIGN glb_cdcritic = 474.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         NEXT-PROMPT tel_cdconven WITH FRAME f_convenio.
         NEXT.
     END.

ASSIGN  tel_nrseqatu   = 1
        tel_nrseqint   = 1
        tel_nrseqcxa   = 1
        tel_nrcnvfbr   = ""
        tel_nmempres   = ""
        tel_cddbanco   = 0
        tel_vltrfcxa   = 0.0
        tel_vltrfnet   = 0.0
        tel_flginter   = FALSE
        tel_vltrftaa   = 0.0
        tel_vltrfdeb   = 0.0
        tel_cdhisrep   = 0
        tel_cdhiscxa   = 0
        tel_cdhisdeb   = 0
        tel_nmarqatu   = ""
        tel_nmarqcxa   = ""
        tel_nrctdbfl   = 0
        tel_flgagenc   = FALSE
        tel_nmarqint   = ""
        tel_nmarqdeb   = ""
        tel_tpdenvio   = 0
        tel_dsdiracc   = ""
        tel_flgautdb   = FALSE
        tel_flgindeb   = FALSE
        tel_dsagercb   = ""
        tel_cdbccrcb   = 0
        tel_dsccdrcb   = ""
        tel_cpfcgrcb   = 0
        tel_flgrepas   = FALSE
        tel_dsemail1   = ""
        tel_dsemail2   = ""
        tel_dsemail3   = ""
        tel_dsemail4   = ""
        tel_dsemail5   = ""
        tel_dsemail6   = ""
		tel_nrlayout   = 4
        tel_flgvlcpf   = TRUE
        tel_flgativo   = FALSE
        tel_flgcvuni   = FALSE
        tel_flgdecla   = FALSE
        tel_flggeraj   = FALSE
        tel_flgenvpa   = FALSE
        tel_nrseqpar   = 0
        tel_nmarqpar   = ""
        tel_tprepass   = "D+1"
        tel_tprepass:SCREEN-VALUE = "D+1"
        tel_flgdbssd   = FALSE.
                   
DISPLAY tel_cdconven 
        tel_cdcooper 
        tel_nmrescop
        tel_nmempres
        tel_nrseqatu  
        tel_nrseqint 
        tel_nrseqcxa
        tel_nrcnvfbr 
        tel_flgagenc
        tel_cddbanco 
        tel_vltrfcxa 
        tel_vltrftaa 
        tel_vltrfnet
        tel_flginter
        tel_vltrfdeb 
        tel_cdhisrep 
        tel_cdhiscxa 
        tel_cdhisdeb 
        tel_nmarqatu  
        tel_nmarqcxa
        tel_nrctdbfl
        tel_nmarqint 
        tel_nmarqdeb 
        tel_tpdenvio
        tel_dsdiracc
		tel_nrlayout
        tel_flgvlcpf
        tel_flgativo
        tel_flgcvuni
        tel_flgdecla
        tel_flggeraj
        tel_flgautdb
        tel_flgindeb
        tel_dsagercb
        tel_cdbccrcb
        tel_dsccdrcb
        tel_cpfcgrcb
        tel_flgrepas
        tel_flgenvpa
        tel_nrseqpar
        tel_nmarqpar
        tel_tprepass
        tel_flgdbssd
        WITH FRAME f_convenio.

FIND gnconve WHERE gnconve.cdconven = tel_cdconven
                   NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE gnconve   THEN
     DO:
         glb_cdcritic = 793.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         NEXT-PROMPT tel_cdconven WITH FRAME f_convenio.
         NEXT.
     END.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE:
      
      SET tel_nmempres WITH FRAME f_convenio.
       
      DO  WHILE TRUE:
       
          SET tel_cdcooper  WITH FRAME f_convenio.

          IF   tel_cdcooper <> 0   THEN
               DO:
                   FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper 
                                      NO-LOCK NO-ERROR.

                   IF   NOT AVAILABLE crapcop   THEN
                        DO:
                           glb_cdcritic = 794.
                           RUN fontes/critic.p.
                           BELL.
                           MESSAGE glb_dscritic.
                           glb_cdcritic = 0.
                           NEXT-PROMPT tel_cdcooper WITH FRAME f_convenio.
                           NEXT.
                        END.
               END.
          ELSE
               DO:
                   glb_cdcritic = 794.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   glb_cdcritic = 0.
                   NEXT-PROMPT tel_cdcooper WITH FRAME f_convenio.
                   NEXT.
               END.
           
          ASSIGN tel_nmrescop = crapcop.nmrescop.
          DISPLAY tel_nmrescop WITH FRAME f_convenio.
          LEAVE.

      END.
          
      SET tel_nrcnvfbr
          tel_flgativo
          tel_flginter
          tel_flgenvpa
          tel_nrseqatu  
          tel_nrseqint
          tel_nrseqcxa
          WITH FRAME f_convenio.

      SET tel_nrseqpar WHEN tel_flgenvpa = TRUE
          tel_flgagenc
          tel_cddbanco 
          WITH FRAME f_convenio.
          
      DO WHILE TRUE: 
          
         SET tel_cdhiscxa WITH FRAME f_convenio.
      
         IF  tel_cdhiscxa <> 0  THEN
             DO: 
                 FIND crapthi WHERE crapthi.cdcooper = glb_cdcooper AND
                                    crapthi.cdhistor = tel_cdhiscxa AND
                                    crapthi.dsorigem = "CAIXA"      
                                    NO-LOCK NO-ERROR.
                                 
                 IF  NOT AVAIL crapthi  THEN
                     DO:
                         BELL.
                         MESSAGE "Tarifa de Caixa nao cadastrada.".
                         NEXT.
                     END.

                 ASSIGN tel_vltrfcxa = crapthi.vltarifa.
                
                 FIND crapthi WHERE crapthi.cdcooper = glb_cdcooper AND
                                    crapthi.cdhistor = tel_cdhiscxa AND
                                    crapthi.dsorigem = "INTERNET"   
                                    NO-LOCK NO-ERROR.

                 IF  NOT AVAIL crapthi  THEN
                     DO:
                         BELL.
                         MESSAGE "Tarifa de Internet nao cadastrada.".
                         NEXT.
                     END.
                  
                 ASSIGN tel_vltrfnet = crapthi.vltarifa.

                 FIND crapthi WHERE crapthi.cdcooper = glb_cdcooper AND
                                    crapthi.cdhistor = tel_cdhiscxa AND
                                    crapthi.dsorigem = "CASH"      
                                    NO-LOCK NO-ERROR.
                                 
                 IF  NOT AVAIL crapthi  THEN
                     DO:
                         BELL.
                         MESSAGE "Tarifa de TAA nao cadastrada.".
                         NEXT.
                     END.
                  
                 ASSIGN tel_vltrftaa = crapthi.vltarifa.

             END.
         ELSE
             ASSIGN tel_vltrfcxa = 0 
                    tel_vltrfnet = 0
                    tel_vltrftaa = 0.  
                                           
         DISPLAY tel_vltrfcxa 
                 tel_vltrfnet 
                 tel_vltrftaa 
                 WITH FRAME f_convenio.
         
         LEAVE.
         
      END.

      DO WHILE TRUE:
      
         SET tel_cdhisdeb WITH FRAME f_convenio.
         
         IF  tel_cdhisdeb <> 0  THEN
             DO:
                 FIND crapthi WHERE crapthi.cdcooper = glb_cdcooper AND
                                    crapthi.cdhistor = tel_cdhisdeb AND
                                    crapthi.dsorigem = "AIMARO"     
                                    NO-LOCK NO-ERROR.
                                 
                 IF  NOT AVAIL crapthi  THEN
                     DO:
                         BELL.
                         MESSAGE "Tarifa de Debito Automatico nao cadastrada.".
                         NEXT.
                     END.
                  
                 ASSIGN tel_vltrfdeb = crapthi.vltarifa.

             END.
         ELSE
             ASSIGN tel_vltrfdeb = 0.
              
         DISPLAY tel_vltrfdeb WITH FRAME f_convenio.

         LEAVE.
         
      END.
      
      SET tel_cdhisrep WHEN tel_cdcooper = 3 WITH FRAME f_convenio.

      IF glb_cdoperad = "979"             OR
         glb_cdoperad = "126"             OR  
         UPPER(glb_cdoperad) = "F0030503" OR
         UPPER(glb_cdoperad) = "F0030642" OR
         UPPER(glb_cdoperad) = "F0030175" OR
         glb_cddepart        = 6          OR /* CONTABILIDADE */
         glb_cddepart        = 11         OR /* FINANCEIRO    */
         glb_cddepart        = 4        THEN /* COMPE         */
          SET tel_tprepass WITH FRAME f_convenio.

      SET tel_flgdbssd
          tel_nmarqatu  
          tel_nmarqcxa
          tel_nrctdbfl
          tel_nmarqint 
          tel_nmarqdeb
          tel_nmarqpar WHEN tel_flgenvpa = TRUE
          tel_flgcvuni
		  tel_nrlayout WHEN tel_cdhisdeb > 0
          tel_flgvlcpf
          tel_tpdenvio
          WITH FRAME f_convenio.

/* Comentado a pedido da area de negocio - Chamado SCTASK0038352 

	  IF tel_nrlayout = 5 AND tel_nmarqatu <> "" THEN
         DO:
            BELL.
            MESSAGE "Convenio nao permite o uso deste layout.".
            NEXT.
         END.

   Comentado a pedido da area de negocio - Chamado SCTASK0038352 */	

      SET tel_dsdiracc WHEN tel_tpdenvio = 5
          tel_flgdecla
          tel_flggeraj
          WITH FRAME f_convenio.
          
      SET tel_flgautdb WHEN tel_flgdecla  
          tel_flgindeb WHEN tel_cdhisdeb <> 0 WITH FRAME f_convenio.
          
        
      IF glb_cdoperad = "979"             OR
         glb_cdoperad = "126"             OR  
         UPPER(glb_cdoperad) = "F0030503" OR
         UPPER(glb_cdoperad) = "F0030642" OR
         UPPER(glb_cdoperad) = "F0030175" OR
         glb_cddepart        = 6          OR /* CONTABILIDADE */
         glb_cddepart        = 11         OR /* FINANCEIRO    */
         glb_cddepart        = 4        THEN /* COMPE         */
         DO:
            IF glb_cdoperad = "979"             OR
               glb_cdoperad = "126"             OR
               UPPER(glb_cdoperad) = "F0030503" OR
               UPPER(glb_cdoperad) = "F0030642" OR
               UPPER(glb_cdoperad) = "F0030175" THEN
               DO:
                  SET tel_cdbccrcb 
                      tel_dsagercb 
                      WITH FRAME f_convenio.
                  
                  DO WHILE LENGTH(tel_dsagercb) < 5:
                                
                     tel_dsagercb = "0" + tel_dsagercb.
                             
                  END.
                  
                  DISPLAY tel_dsagercb 
                          WITH FRAME f_convenio.
                  
                  SET tel_dsccdrcb 
                      WITH FRAME f_convenio.
                     
                  DO WHILE LENGTH(tel_dsccdrcb) < 9:
                                
                     tel_dsccdrcb = "0" + tel_dsccdrcb.
                             
                  END.
                  
                  DISPLAY tel_dsccdrcb 
                      WITH FRAME f_convenio.
            
               END.

            SET tel_cpfcgrcb tel_flgrepas WITH FRAME f_convenio.
                  
            IF   INPUT tel_tpdenvio = 1   OR   
                 INPUT tel_tpdenvio = 4   THEN
                 DO:
                     DISPLAY tel_dsemail1
                             tel_dsemail2
                             tel_dsemail3
                             tel_dsemail4
                             tel_dsemail5
                             tel_dsemail6 WITH FRAME f_email.
                             
                     SET tel_dsemail1 
                         tel_dsemail2
                         tel_dsemail3
                         tel_dsemail4
                         tel_dsemail5
                         tel_dsemail6 WITH FRAME f_email.
                 END.
      
         END.

      PAUSE (2) NO-MESSAGE.

	   msg_cdhiscxa = "".
       msg_cdhisrep = "".
       msg_cdhisdeb = "".
       msg_msgcdhis = "".
            
          FOR EACH crapcop WHERE crapcop.flgativo = TRUE NO-LOCK BY crapcop.cdcooper:
          
            IF tel_cdhiscxa <> 0 AND tel_cdhiscxa <> ? THEN
              DO:    
              IF NOT CAN-FIND(craphis WHERE craphis.cdcooper = crapcop.cdcooper
                          and craphis.cdhistor = tel_cdhiscxa NO-LOCK) THEN
                 DO:
   
                     msg_cdhiscxa = msg_cdhiscxa + STRING(crapcop.cdcooper) + " - " + STRING(crapcop.nmrescop) + ", ".
                 END.
              END.
              
            IF tel_cdhisrep <> 0 AND tel_cdhisrep <> ? THEN
              DO:    
              IF NOT CAN-FIND(craphis WHERE craphis.cdcooper = crapcop.cdcooper
                          and craphis.cdhistor = tel_cdhisrep NO-LOCK) THEN
                 DO:
   
                     msg_cdhisrep = msg_cdhisrep + STRING(crapcop.cdcooper) + " - " + STRING(crapcop.nmrescop) + ", ".
                 END.
              END.
              
            IF tel_cdhisdeb <> 0 AND tel_cdhisdeb <> ? THEN
              DO:    
              IF NOT CAN-FIND(craphis WHERE craphis.cdcooper = crapcop.cdcooper
                          and craphis.cdhistor = tel_cdhisdeb NO-LOCK) THEN
                 DO:
   
                     msg_cdhisdeb = msg_cdhisdeb + STRING(crapcop.cdcooper) + " - " + STRING(crapcop.nmrescop) + ", ".
                 END.
              END.
          END.
       
       
          IF msg_cdhiscxa <> "" THEN
             msg_msgcdhis = msg_msgcdhis + "Hist. Pagto " + STRING(tel_cdhiscxa) + " nao esta cadastrado para a(s) cooperativas: " + SUBSTRING(msg_cdhiscxa, 1, LENGTH(msg_cdhiscxa) - 2) + "\n".
             
          IF msg_cdhisrep <> "" THEN
             msg_msgcdhis = msg_msgcdhis + "Hist. Repasse Ailos " + STRING(tel_cdhiscxa) + " nao esta cadastrado para a(s) cooperativas: " + SUBSTRING(msg_cdhisrep, 1, LENGTH(msg_cdhisrep) - 2) + "\n".           
 
          IF msg_cdhisdeb <> "" THEN
             msg_msgcdhis = msg_msgcdhis + "Hist. Automatico " + STRING(tel_cdhiscxa) + " nao esta cadastrado para a(s) cooperativas: " + SUBSTRING(msg_cdhisdeb, 1, LENGTH(msg_cdhisdeb) - 2) + "\n". 
          
          
          IF msg_msgcdhis <> "" THEN
             DO:
             MESSAGE msg_msgcdhis + " Favor solicitar a inclusao"
             VIEW-AS ALERT-BOX.
             LEAVE.
             END.

      CREATE gnconve.

      ASSIGN gnconve.cdconven = tel_cdconven
             gnconve.cdcooper = tel_cdcooper 
             gnconve.nmempres = CAPS(tel_nmempres)
             gnconve.nrseqatu = tel_nrseqatu  
             gnconve.nrseqint = tel_nrseqint 
             gnconve.nrseqcxa = tel_nrseqcxa
             gnconve.nrcnvfbr = tel_nrcnvfbr 
             gnconve.flgagenc = tel_flgagenc
             gnconve.cddbanco = tel_cddbanco 
             gnconve.vltrfcxa = tel_vltrfcxa 
             gnconve.vltrfnet = tel_vltrfnet
             gnconve.flginter = tel_flginter
             gnconve.vltrftaa = tel_vltrftaa
             gnconve.vltrfdeb = tel_vltrfdeb 
             gnconve.cdhisrep = tel_cdhisrep 
             gnconve.cdhiscxa = tel_cdhiscxa 
             gnconve.cdhisdeb = tel_cdhisdeb 
             gnconve.nmarqatu = tel_nmarqatu  
             gnconve.nmarqcxa = tel_nmarqcxa
             gnconve.nrctdbfl = tel_nrctdbfl
             gnconve.nmarqint = tel_nmarqint 
             gnconve.nmarqdeb = tel_nmarqdeb 
             gnconve.tpdenvio = tel_tpdenvio
             gnconve.dsdiracc = tel_dsdiracc
             gnconve.flgativo = tel_flgativo
             gnconve.flgcvuni = tel_flgcvuni
             gnconve.flgdecla = tel_flgdecla
             gnconve.flggeraj = tel_flggeraj
             gnconve.flgautdb = tel_flgautdb
             gnconve.flgindeb = tel_flgindeb
             gnconve.dsagercb = tel_dsagercb
             gnconve.cdbccrcb = tel_cdbccrcb
             gnconve.dsccdrcb = tel_dsccdrcb
             gnconve.cpfcgrcb = tel_cpfcgrcb
             gnconve.flgrepas = tel_flgrepas
             gnconve.dsendcxa = TRIM(tel_dsemail1) + "," +
                                TRIM(tel_dsemail2) + "," +
                                TRIM(tel_dsemail3) 
             gnconve.dsenddeb = TRIM(tel_dsemail4) + "," + 
                                TRIM(tel_dsemail5) + "," +
                                TRIM(tel_dsemail6)
             gnconve.flgenvpa = tel_flgenvpa
			 gnconve.nrlayout = tel_nrlayout
             gnconve.flgvlcpf = IF tel_nrlayout = 5 THEN tel_flgvlcpf ELSE NO
             gnconve.nrseqpar = tel_nrseqpar
             gnconve.nmarqpar = tel_nmarqpar
             gnconve.tprepass = IF tel_tprepass:SCREEN-VALUE = "D+1" THEN
                                    1
                                ELSE
                                    2
             gnconve.flgdbssd = tel_flgdbssd.


      RUN gera_incluir_log.
      
      LEAVE.
   
   END.
                       
END. /* Fim da transacao */

RELEASE gnconve.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.
                 
CLEAR FRAME f_convenio ALL NO-PAUSE.



PROCEDURE gera_incluir_log:
    
    RUN incluir_log (INPUT "codigo do convenio",
                     INPUT STRING(gnconve.cdconven)).

    RUN incluir_log (INPUT "nome da empresa",
                     INPUT STRING(gnconve.nmempres)).

    RUN incluir_log (INPUT "codigo da cooperativa",
                     INPUT STRING(gnconve.cdcooper)).

    RUN incluir_log (INPUT "numero do convenio p/ febraban",
                     INPUT STRING(gnconve.nrcnvfbr)).
    
    RUN incluir_log (INPUT "convenio ativo",
                     INPUT STRING(gnconve.flgativo)).

    RUN incluir_log (INPUT "pagamento via internet",
                     INPUT STRING(gnconve.flginter)).

    RUN incluir_log (INPUT "envia arquivo parcial",
                     INPUT STRING(gnconve.flgenvpa)).

	RUN incluir_log (INPUT "tipo do layout",
                     INPUT STRING(gnconve.nrlayout)).

    RUN incluir_log (INPUT "Valida CPF/CNPF",
                     INPUT STRING(gnconve.flgvlcpf)).

    RUN incluir_log (INPUT "numero sequencial do arquivo de atualizacao",
                     INPUT STRING(gnconve.nrseqatu)).

    RUN incluir_log (INPUT "numero sequencial do arquivo de debito automatico",
                     INPUT STRING(gnconve.nrseqint)).

    RUN incluir_log (INPUT "numero sequencial do arquivo de envio de arrecadacao",
                     INPUT STRING(gnconve.nrseqcxa)).

    RUN incluir_log (INPUT "numero sequencial do arquivo parcial",
                     INPUT STRING(gnconve.nrseqpar)).

    RUN incluir_log (INPUT "usa agencia",
                     INPUT STRING(gnconve.flgagenc)).

    RUN incluir_log (INPUT "codigo do banco",
                     INPUT STRING(gnconve.cddbanco)).
    
    RUN incluir_log (INPUT "codigo do historico de arrecadacao de faturas",
                     INPUT STRING(gnconve.cdhiscxa)).

    RUN incluir_log (INPUT "valor da tarifa de arrecadacao de faturas",
                     INPUT STRING(gnconve.vltrfcxa)).
                                                     
    RUN incluir_log (INPUT "valor da tarfica de arrecadacao de faturas na internet",
                     INPUT STRING(gnconve.vltrfnet)).

    RUN incluir_log (INPUT "valor da tarifa para TAA",
                     INPUT STRING(gnconve.vltrftaa)).

    RUN incluir_log (INPUT "codigo  do historico de debito automatico",
                     INPUT STRING(gnconve.cdhisdeb)).

    RUN incluir_log (INPUT "valor da tarifa de debito automatico",
                     INPUT STRING(gnconve.vltrfdeb)).

    RUN incluir_log (INPUT "codigo do historico de repasse de arrecadacoes para o AILOS",
                     INPUT STRING(gnconve.cdhisrep)).

    RUN incluir_log (INPUT "nome do arquivo a ser enviado para atualizacao cadastral",
                     INPUT STRING(gnconve.nmarqatu)).

    RUN incluir_log (INPUT "nome do arquivo a ser enviado para arrecadacao de faturas",
                     INPUT STRING(gnconve.nmarqcxa)).
                     
    RUN incluir_log (INPUT "nome do arquivo a ser enviado para arrecadacao de faturas",
                     INPUT STRING(gnconve.nrctdbfl)).            

    RUN incluir_log (INPUT "nome do arquivo de integracao de debitos",
                     INPUT STRING(gnconve.nmarqint)).

    RUN incluir_log (INPUT "nome do arquivo a ser enviado contendo os debitos efetuados",
                     INPUT STRING(gnconve.nmarqdeb)).

    RUN incluir_log (INPUT "nome do arquivo parcial",
                     INPUT STRING(gnconve.nmarqpar)).

    RUN incluir_log (INPUT "convenio unificado",
                     INPUT STRING(gnconve.flgcvuni)).
    
    RUN incluir_log (INPUT "tipo de envio",
                     INPUT STRING(gnconve.tpdenvio)).

    RUN incluir_log (INPUT "diretorio dos arquivos da accesstage",
                     INPUT STRING(gnconve.dsdiracc)).

    RUN incluir_log (INPUT "declaracao",
                     INPUT STRING(gnconve.flgdecla)).

    RUN incluir_log (INPUT "gera registro J",
                     INPUT STRING(gnconve.flggeraj)).

    RUN incluir_log (INPUT "autorizacao de debito em conta na declaracao do convenio",
                     INPUT STRING(gnconve.flgautdb)).

    RUN incluir_log (INPUT "autoriza inclusao de debito",
                     INPUT STRING(gnconve.flgindeb)).

    RUN incluir_log (INPUT "codigo do banco de repasse",
                     INPUT STRING(gnconve.cdbccrcb)).
    
    RUN incluir_log (INPUT "agencia para recebimento do repasse",
                     INPUT STRING(gnconve.dsagercb)).
                                                     
    RUN incluir_log (INPUT "conta de recebimento do repasse",
                     INPUT STRING(gnconve.dsccdrcb)).
    
    RUN incluir_log (INPUT "CPF/CNPJ do corretista ao qual e feito o repasse",
                     INPUT STRING(gnconve.cpfcgrcb)).
    
    RUN incluir_log (INPUT "repassar valor bruto/liquido para o convenio",
                     INPUT STRING(gnconve.flgrepas)).

    RUN incluir_log (INPUT "end. e-mail caixa 1",
                     INPUT STRING(tel_dsemail1)).

    RUN incluir_log (INPUT "end. e-mail caixa 2",
                     INPUT STRING(tel_dsemail2)).

    RUN incluir_log (INPUT "end. e-mail caixa 3",
                     INPUT STRING(tel_dsemail3)).
    
    RUN incluir_log (INPUT "end. e-mail debito 1",
                     INPUT STRING(tel_dsemail4)).

    RUN incluir_log (INPUT "end. e-mail debito 2",
                     INPUT STRING(tel_dsemail5)).

    RUN incluir_log (INPUT "end. e-mail debito 3",
                     INPUT STRING(tel_dsemail6)).
    
    RUN incluir_log (INPUT "forma de repasse",
                     INPUT tel_tprepass).

    RUN incluir_log (INPUT "debita sem saldo",
                     INPUT STRING(gnconve.flgdbssd)).
    
    
END PROCEDURE.

PROCEDURE incluir_log:

    DEF INPUT PARAM par_dsdcampo AS CHAR   NO-UNDO.
    DEF INPUT PARAM vlr_vlinclui AS CHAR   NO-UNDO.
     
    ASSIGN vlr_vlinclui = "---" WHEN vlr_vlinclui = ""
           vlr_vlinclui = REPLACE(REPLACE(vlr_vlinclui,"("," "),")","-").
    
    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") + " '-->' Operador " +
                      glb_cdoperad + " incluiu o campo " + par_dsdcampo + 
                      " com o valor " + vlr_vlinclui +
                      " >> log/gt0001.log").
     
END PROCEDURE.

/* .......................................................................... */
