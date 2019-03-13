/* .............................................................................

   Programa: Includes/gt0001c.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                    Ultima Atualizacao: 29/03/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Consulta dos Convenios(Generico)

   Alteracoes: 13/12/2004 - Inclusao do historico para repasse CECRED (Julio)
               
               03/06/2005 - Inclusao da opcao para unificacao de arquivos
                            (Julio).

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

               22/07/2008 - Mostrar campo tel_flgautdb, Autorizacao de debito
                            e permitir escolher o convenio na query (Gabriel).
                            
               20/10/2008 - Inclusao dos campos para Repasse: Banco, Agencia,
                            Conta , CNPJ e Tipo (Diego).
                            
               12/11/2008 - Incluido campo flgindeb, e substituidos:
                            nrccdrcb => dsccdrcb
                            cdagercb => dsagercb (Diego).
                            
               04/06/2010 - Incluido campo tel_vltrftaa referente a pagamento
                            atraves de TAA (Elton).
                            
               07/03/2012 - Inclusao dos campos:
                            - tel_flgenvpa
                            - tel_nrseqpar
                            - tel_nmarqpar
                            (Adriano).              
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).
               
               10/09/2013 - Substituido campo "Agencia:" (gnconve.cdagedeb )
                            por "Usa Agencia:" (gnconve.flgagenc)
                          - Incluido campo "Dir.Accesstage:" (gnconve.dsdiracc).
                            (Reinert)
                            
               03/04/2014 - Inclusao do campo tel_tprepass.
                            (PRJ Automatizacao TED pagto convenios repasse) - 
                            (Fabricio)
                            
               10/02/2015 - Inclusao do campo tel_flgdbssd.
                            (PRJ Melhoria - Chamado 229249) - (Fabricio)
               
               18/09/2015 - Inclusão do campo tel_nrctdbfl PRJ 214 (Vanessa)

			   29/03/2017 - Ajutes devido ao tratamento da versao do layout FEBRABAN
							(Jonata RKAM M311)

               10/03/2019 - Inclusão do indicador de validação do CPF/CNPJ Layout 5.
                            Gabriel Marcos (Mouts) - SCTASK0038352.

............................................................................. */

ON RETURN OF bgnconve-b DO:

   tel_cdconven = gnconve.cdconven.
   
   DISPLAY tel_cdconven WITH FRAME f_convenio.
   
   APPLY "GO".

END.

IF   tel_cdconven <> 0   THEN
     DO:
         FIND gnconve WHERE gnconve.cdconven = tel_cdconven 
                            NO-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE gnconve   THEN
              DO:
                
                ASSIGN tel_nmrescop = " ".

                FIND FIRST crapcop WHERE crapcop.cdcooper = gnconve.cdcooper
                                         NO-LOCK NO-ERROR.
                IF  AVAIL crapcop THEN
                    ASSIGN tel_nmrescop = crapcop.nmrescop.
                
                ASSIGN  tel_nrseqatu   = gnconve.nrseqatu   
                        tel_nrseqint   = gnconve.nrseqint 
                        tel_nrseqcxa   = gnconve.nrseqcxa  
                        tel_nrcnvfbr   = gnconve.nrcnvfbr  
                        tel_nmempres   = gnconve.nmempres 
                        tel_cddbanco   = gnconve.cddbanco    
                        tel_vltrfcxa   = gnconve.vltrfcxa  
                        tel_flginter   = gnconve.flginter
                        tel_vltrfnet   = gnconve.vltrfnet
                        tel_vltrftaa   = gnconve.vltrftaa
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
                        tel_flgautdb   = gnconve.flgautdb
                        tel_flgindeb   = gnconve.flgindeb
                        tel_dsagercb   = gnconve.dsagercb
                        tel_cdbccrcb   = gnconve.cdbccrcb
                        tel_dsccdrcb   = gnconve.dsccdrcb
                        tel_cpfcgrcb   = gnconve.cpfcgrcb
                        tel_flgrepas   = gnconve.flgrepas
                        tel_dsemail1   = ENTRY(1, gnconve.dsendcxa) 
                        tel_dsemail2   = ENTRY(2, gnconve.dsendcxa)
                        tel_dsemail3   = ENTRY(3, gnconve.dsendcxa)
                        tel_dsemail4   = ENTRY(1, gnconve.dsenddeb)
                        tel_dsemail5   = ENTRY(2, gnconve.dsenddeb)
                        tel_dsemail6   = ENTRY(3, gnconve.dsenddeb)
						tel_nrlayout   = gnconve.nrlayout
                        tel_flgvlcpf   = gnconve.flgvlcpf
                        tel_flgativo   = gnconve.flgativo
                        tel_flgcvuni   = gnconve.flgcvuni
                        tel_flgdecla   = gnconve.flgdecla
                        tel_flggeraj   = gnconve.flggeraj
                        tel_flgenvpa   = gnconve.flgenvpa
                        tel_nrseqpar   = gnconve.nrseqpar
                        tel_nmarqpar   = gnconve.nmarqpar
                        tel_tprepass   = IF gnconve.tprepass = 1 THEN
                                             "D+1"
                                         ELSE
                                             "D+2"
                        tel_tprepass:SCREEN-VALUE = 
                                                IF gnconve.tprepass = 1 THEN
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
                        
                 IF   gnconve.tpdenvio = 1 OR  
                      tel_tpdenvio = 4     THEN
                      DISPLAY tel_dsemail1
                              tel_dsemail2
                              tel_dsemail3
                              tel_dsemail4
                              tel_dsemail5
                              tel_dsemail6
                              WITH FRAME f_email.
              END.
         ELSE
              DO:
                  ASSIGN glb_cdcritic = 563. /* Convenio nao Cadastrado */
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  CLEAR FRAME f_convenio.
                  DISPLAY tel_cdconven WITH FRAME f_convenio.
                  NEXT.
              END.
     END.
ELSE
     DO:
        ASSIGN tel_tprepass = "".

        DISPLAY " " @  tel_cdconven 
                " " @  tel_cdcooper 
                " " @  tel_nmrescop
                " " @  tel_nmempres
                " " @  tel_nrseqatu  
                " " @  tel_nrseqint 
                " " @  tel_nrseqcxa
                " " @  tel_nrcnvfbr 
                " " @  tel_flgagenc
                " " @  tel_cddbanco 
                " " @  tel_vltrfcxa
                " " @  tel_flginter
                " " @  tel_vltrfnet
                " " @  tel_vltrftaa 
                " " @  tel_vltrfdeb 
                " " @  tel_cdhisrep 
                " " @  tel_cdhiscxa 
                " " @  tel_cdhisdeb 
                " " @  tel_nmarqatu  
                " " @  tel_nmarqcxa
                " " @  tel_nrctdbfl
                " " @  tel_nmarqint 
                " " @  tel_nmarqdeb 
                " " @  tel_tpdenvio  
                " " @  tel_dsdiracc
				" " @  tel_nrlayout
                " " @  tel_flgvlcpf
                " " @  tel_flgativo
                " " @  tel_flgcvuni
                " " @  tel_flgdecla
                " " @  tel_flggeraj
                " " @  tel_flgautdb
                " " @  tel_flgindeb
                " " @  tel_dsagercb
                " " @  tel_cdbccrcb
                " " @  tel_dsccdrcb
                " " @  tel_cpfcgrcb
                " " @  tel_flgrepas
                tel_tprepass
                " " @  tel_flgdbssd
                WITH FRAME f_convenio.

         PAUSE(0).
                 
         OPEN QUERY bgnconveq 
               FOR EACH gnconve NO-LOCK,

                   FIRST crapcop WHERE crapcop.cdcooper = gnconve.cdcooper
                                       NO-LOCK BY gnconve.cdconven.
         
         DO WHILE TRUE ON ENDKEY UNDO,LEAVE:     

            UPDATE bgnconve-b   
                   WITH FRAME f_convenioc.
            LEAVE.  
         
         END.
          
     END.

HIDE FRAME f_convenioc.

/* .......................................................................... */
