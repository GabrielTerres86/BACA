/*.........................................................................

   Programa: Includes/gt0001e.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                    Ultima Atualizacao: 29/03/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Exclusao  dos Convenios(Generico)

   Alteracoes: 13/12/2004 - Inclusao do historico para repasse CECRED (Julio)
               
               03/06/2005 - Inclusao da opcao de unificacao de arquivos
                            (Julio)

               12/01/2006 - Alteracao na validacao dos historicos, nao validar
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
                
               22/07/2008 - Incluido campo tel_flgautdb, Autorizacao do debito
                            (Gabriel).
                            
               20/10/2008 - Inclusao dos campos para Repasse: Banco, Agencia,
                            Conta, CNPJ e Tipo (Diego).
                            
               12/11/2008 - Incluido campo flgindeb, e substituidos:
                            nrccdrcb => dsccdrcb
                            cdagercb => dsagercb (Diego).
                            
               04/06/2010 - Incluido campo tel_vltrftaa referente a valor de 
                            tarifa de pagamento feito atraves de TAA (Elton).   
                            
               15/07/2010 - Criado log da tela (Adriano).                
               
               07/03/2012 - Inclusao dos campos:
                            - tel_flgenvpa
                            - tel_nrseqpar
                            - tel_nmarqpar
                            (Adriano).       

               22/06/2012 - Substituido gncoper por crapcop (Tiago).
               
               10/09/2013 - Substituido campo tel_cdagedeb (gnconve.cdagedeb )
                            por tel_flgagenc (gnconve.flgagenc)
                          - Incluido campo tel_dsdiracc (gnconve.dsdiracc).
                            (Reinert)
                            
               03/04/2014 - Inclusao do campo tel_tprepass.
                            (PRJ Automatizacao TED pagto convenios repasse) - 
                            (Fabricio)
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               10/02/2015 - Inclusao do campo tel_flgdbssd.
                            (PRJ Melhoria - Chamado 229249) - (Fabricio)
               
               18/09/2015 - Inclusão do campo tel_nrctdbfl PRJ 214 (Vanessa)

			   29/03/2017 - Ajutes devido ao tratamento da versao do layout FEBRABAN
							(Jonata RKAM M311)

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

FIND gnconve WHERE gnconve.cdconven = tel_cdconven 
                   NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE gnconve   THEN
     DO:
         glb_cdcritic = 563.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         NEXT-PROMPT tel_cdconven WITH FRAME f_convenio.
         NEXT.
     END.

ASSIGN tel_nmrescop = " ".

FIND FIRST crapcop WHERE crapcop.cdcooper = gnconve.cdcooper 
                         NO-LOCK NO-ERROR.

IF  AVAIL crapcop THEN
     ASSIGN tel_nmrescop = crapcop.nmrescop.

                
ASSIGN  
        tel_nrseqatu   = gnconve.nrseqatu   
        tel_nrseqint   = gnconve.nrseqint 
        tel_nrseqcxa   = gnconve.nrseqcxa  
        tel_nrcnvfbr   = gnconve.nrcnvfbr  
        tel_nmempres   = gnconve.nmempres 
        tel_cddbanco   = gnconve.cddbanco    
        tel_vltrfcxa   = gnconve.vltrfcxa  
        tel_vltrfnet   = gnconve.vltrfnet
        tel_vltrftaa   = gnconve.vltrftaa
        tel_flginter   = gnconve.flginter
        tel_vltrfdeb   = gnconve.vltrfdeb  
        tel_cdhisrep   = gnconve.cdhisrep  
        tel_cdhiscxa   = gnconve.cdhiscxa  
        tel_cdhisdeb   = gnconve.cdhisdeb  
        tel_nmarqatu   = gnconve.nmarqatu   
        tel_nmarqcxa   = gnconve.nmarqcxa
        tel_nrctdbfl   = gnconve.nrctdbfl
        tel_flgagenc   = gnconve.flgagenc  
        tel_nmarqint   = gnconve.nmarqint 
        tel_nmarqdeb   = gnconve.nmarqdeb 
        tel_cdconven   = gnconve.cdconven
        tel_cdcooper   = gnconve.cdcooper   
        tel_tpdenvio   = gnconve.tpdenvio  
        tel_dsdiracc   = gnconve.dsdiracc
		tel_nrlayout   = gnconve.nrlayout
        tel_flgvlcpf   = gnconve.flgvlcpf
        tel_flgativo   = gnconve.flgativo
        tel_flgcvuni   = gnconve.flgcvuni
        tel_flgdecla   = gnconve.flgdecla
        tel_flggeraj   = gnconve.flggeraj
        tel_flgautdb   = gnconve.flgautdb
        tel_flgindeb   = gnconve.flgindeb
        tel_dsagercb   = gnconve.dsagercb
        tel_cdbccrcb   = gnconve.cdbccrcb
        tel_dsccdrcb   = gnconve.dsccdrcb
        tel_cpfcgrcb   = gnconve.cpfcgrcb
        tel_flgrepas   = gnconve.flgrepas
        tel_flgenvpa   = gnconve.flgenvpa
        tel_nrseqpar   = gnconve.nrseqpar
        tel_nmarqpar   = gnconve.nmarqpar
        tel_tprepass   = IF gnconve.tprepass = 1 THEN
                             "D+1"
                         ELSE
                             "D+2"
        tel_tprepass:SCREEN-VALUE = IF gnconve.tprepass = 1 THEN
                                        "D+1"
                                    ELSE
                                        "D+2"
        tel_flgdbssd   = gnconve.flgdbssd.
        
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
        tel_flginter
        tel_vltrfnet
        tel_vltrftaa 
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


FIND FIRST gncvcop WHERE gncvcop.cdcooper = tel_cdcooper AND
                         gncvcop.cdconven = tel_cdconven 
                         NO-LOCK NO-ERROR.

IF  AVAIL gncvcop THEN
    DO:
        glb_cdcritic = 797. /* Convenio com Cooperativas Relacionadas */
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        glb_cdcritic = 0.
        NEXT-PROMPT tel_cdconven WITH FRAME f_convenio.
        NEXT.

    END.

    
DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND gnconve WHERE gnconve.cdconven = tel_cdconven
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE gnconve   THEN
            IF   LOCKED gnconve   THEN
                 DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(gnconve),
                        					 INPUT "banco",
                        					 INPUT "gnconve",
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
                        
                        glb_cdcritic = 0.
                        NEXT.

                 END.
            ELSE
                 DO:
                     glb_cdcritic = 563. /* Convenio nao Cadastrada */
                     CLEAR FRAME f_convenio.   
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.
   END.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            DISPLAY tel_cdconven WITH FRAME f_convenio.   
            MESSAGE glb_dscritic.
            NEXT.
        END.

            
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.

      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            DISPLAY tel_cdconven WITH FRAME f_convenio.   

            NEXT.
        END.

   DELETE gnconve.
 
   RELEASE gnconve.
   
   RUN excluir_log (INPUT "excluiu").

END. /* Fim da transacao */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.
                 
CLEAR FRAME f_convenio ALL NO-PAUSE.

  
PROCEDURE excluir_log:

    DEF INPUT PARAM par_dsdcampo AS CHAR   NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") + " '-->' Operador " +
                      glb_cdoperad + " " + par_dsdcampo + " o convenio " +
                      STRING(tel_cdconven) + " >> log/gt0001.log").
     

END PROCEDURE.

/* .......................................................................... */
