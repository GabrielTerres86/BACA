/* .............................................................................

   Programa: Includes/gt0001a.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                        Ultima Atualizacao: 26/05/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Efetuar Alteracao dos Convenios(Generico)

   Alteracoes: 13/12/2004 - Inclusao do historico repasse CECRED (Julio)
   
               03/06/2005 - Inclusao da opcao de unificacao de arquivos 
                            (Julio)

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

               22/07/2008 - Incluir campo tel_flgautdb para a Autorizacao do
                            debito (Gabriel).
                            
               24/07/2008 - Manter valor do campo tel_flgautdb mesmo com a 
                            mudanca da impressao da declaracao (Gabriel).
                            
               20/10/2008 - Inclusao dos campos para Repasse: Banco, Agencia,
                            Conta, CNPJ e Tipo (Diego).
                            
               12/11/2008 - Incluido campo flgindeb, e substituidos:
                            nrccdrcb => dsccdrcb
                            cdagercb => dsagercb (Diego).
                            
               04/06/2010 - Incluido campo tel_vltrftaa referente a pagamento
                            atraves de TAA (Elton).
                            
               16/07/2010 - Criado log da tela (Adriano).
               
               29/03/2011 - Incluido condicao para que somente os operadores 
                            "979, 997, 126" possam alterar os campos de repasse
                            (Adriano).
                            
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
                            
               03/04/2014 - Inclusao do campo tel_tprepass com tratamento
                            para alteracao.
                            (PRJ Automatizacao TED pagto convenios repasse) - 
                            (Fabricio)
                            
               13/06/2014 - Exclusao do operador '30097' e inclusao dos
                            operadores 'F0030503', 'F0030642' e 'F0030175'.
                            (Chamado 164027) - (Fabricio).
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                           
               10/02/2015 - Inclusao do campo tel_flgdbssd.
                            (PRJ Melhoria - Chamado 229249) - (Fabricio)
               
               18/09/2015 - Inclusão do campo tel_nrctdbfl PRJ 214 (Vanessa)             
               
               14/09/2016 - Incluir chamada da rotina pc_pula_seq_gt0001 (Lucas Ranghetti #484556)

			   08/12/2016 - P341-Automatização BACENJUD - Realizar a validação 
			                do departamento pelo código do mesmo (Renato Darosci)

			   29/03/2017 - Ajutes devido ao tratamento da versao do layout FEBRABAN
							(Jonata RKAM M311)

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

............................................................................. */
DEF VAR log_nrseqatu LIKE gnconve.nrseqatu           NO-UNDO.  
DEF VAR log_nrseqint LIKE gnconve.nrseqint           NO-UNDO.
DEF VAR log_nrseqcxa LIKE gnconve.nrseqcxa           NO-UNDO. 
DEF VAR log_nrcnvfbr LIKE gnconve.nrcnvfbr           NO-UNDO. 
DEF VAR log_nmempres LIKE gnconve.nmempres           NO-UNDO.
DEF VAR log_cddbanco LIKE gnconve.cddbanco           NO-UNDO.   
DEF VAR log_flginter LIKE gnconve.flginter           NO-UNDO.
DEF VAR log_cdhisrep LIKE gnconve.cdhisrep           NO-UNDO. 
DEF VAR log_cdhiscxa LIKE gnconve.cdhiscxa           NO-UNDO. 
DEF VAR log_cdhisdeb LIKE gnconve.cdhisdeb           NO-UNDO. 
DEF VAR log_vltrfcxa LIKE gnconve.vltrfcxa           NO-UNDO.
DEF VAR log_vltrfnet LIKE gnconve.vltrfnet           NO-UNDO.
DEF VAR log_vltrftaa LIKE gnconve.vltrftaa           NO-UNDO.
DEF VAR log_vltrfdeb LIKE gnconve.vltrfdeb           NO-UNDO.
DEF VAR log_nmarqatu LIKE gnconve.nmarqatu           NO-UNDO.  
DEF VAR log_nmarqcxa LIKE gnconve.nmarqcxa           NO-UNDO. 
DEF VAR log_flgagenc LIKE gnconve.flgagenc           NO-UNDO.
DEF VAR log_nmarqint LIKE gnconve.nmarqint           NO-UNDO.
DEF VAR log_nmarqdeb LIKE gnconve.nmarqdeb           NO-UNDO.
DEF VAR log_cdconven LIKE gnconve.cdconven           NO-UNDO.
DEF VAR log_cdcooper LIKE gnconve.cdcooper           NO-UNDO.  
DEF VAR log_tpdenvio LIKE gnconve.tpdenvio           NO-UNDO. 
DEF VAR log_dsdiracc LIKE gnconve.dsdiracc           NO-UNDO. 
DEF VAR log_flgativo LIKE gnconve.flgativo           NO-UNDO.
DEF VAR log_flgcvuni LIKE gnconve.flgcvuni           NO-UNDO.
DEF VAR log_flgdecla LIKE gnconve.flgdecla           NO-UNDO.
DEF VAR log_flggeraj LIKE gnconve.flggeraj           NO-UNDO.
DEF VAR log_flgautdb LIKE gnconve.flgautdb           NO-UNDO.
DEF VAR log_flgindeb LIKE gnconve.flgindeb           NO-UNDO.
DEF VAR log_dsagercb LIKE gnconve.dsagercb           NO-UNDO.
DEF VAR log_cdbccrcb LIKE gnconve.cdbccrcb           NO-UNDO.
DEF VAR log_dsccdrcb LIKE gnconve.dsccdrcb           NO-UNDO.
DEF VAR log_cpfcgrcb LIKE gnconve.cpfcgrcb           NO-UNDO. 
DEF VAR log_flgrepas LIKE gnconve.flgrepas           NO-UNDO.
DEF VAR log_dsemail1 LIKE gnconve.dsendcxa           NO-UNDO.
DEF VAR log_dsemail2 LIKE gnconve.dsendcxa           NO-UNDO.       
DEF VAR log_dsemail3 LIKE gnconve.dsendcxa           NO-UNDO.      
DEF VAR log_dsemail4 LIKE gnconve.dsenddeb           NO-UNDO.  
DEF VAR log_dsemail5 LIKE gnconve.dsenddeb           NO-UNDO.
DEF VAR log_dsemail6 LIKE gnconve.dsenddeb           NO-UNDO.
DEF VAR log_flgenvpa LIKE gnconve.flgenvpa           NO-UNDO.
DEF VAR log_nrlayout LIKE gnconve.nrlayout           NO-UNDO.
DEF VAR log_nrseqpar LIKE gnconve.nrseqpar           NO-UNDO.
DEF VAR log_nmarqpar LIKE gnconve.nmarqpar           NO-UNDO.
DEF VAR log_tprepass AS CHAR                         NO-UNDO.
DEF VAR log_flgdbssd LIKE gnconve.flgdbssd           NO-UNDO.
DEF VAR log_nrctdbfl LIKE gnconve.nrctdbfl           NO-UNDO.
DEF VAR aux_nrseqatu LIKE gnconve.nrseqatu           NO-UNDO.
DEF VAR aux_nrseqint LIKE gnconve.nrseqint           NO-UNDO.
DEF VAR aux_nrseqcxa LIKE gnconve.nrseqcxa           NO-UNDO.
DEF VAR aux_nrcnvfbr LIKE gnconve.nrcnvfbr           NO-UNDO.
DEF VAR aux_nmempres LIKE gnconve.nmempres           NO-UNDO.
DEF VAR aux_cddbanco LIKE gnconve.cddbanco           NO-UNDO.
DEF VAR aux_flginter LIKE gnconve.flginter           NO-UNDO.
DEF VAR aux_cdhisrep LIKE gnconve.cdhisrep           NO-UNDO.
DEF VAR aux_cdhiscxa LIKE gnconve.cdhiscxa           NO-UNDO.
DEF VAR aux_cdhisdeb LIKE gnconve.cdhisdeb           NO-UNDO.
DEF VAR aux_vltrfcxa LIKE gnconve.vltrfcxa           NO-UNDO.
DEF VAR aux_vltrfnet LIKE gnconve.vltrfnet           NO-UNDO.
DEF VAR aux_vltrftaa LIKE gnconve.vltrftaa           NO-UNDO.
DEF VAR aux_vltrfdeb LIKE gnconve.vltrfdeb           NO-UNDO.
DEF VAR aux_nmarqatu LIKE gnconve.nmarqatu           NO-UNDO.
DEF VAR aux_nmarqcxa LIKE gnconve.nmarqcxa           NO-UNDO.
DEF VAR aux_flgagenc LIKE gnconve.flgagenc           NO-UNDO.
DEF VAR aux_nmarqint LIKE gnconve.nmarqint           NO-UNDO.
DEF VAR aux_nmarqdeb LIKE gnconve.nmarqdeb           NO-UNDO.
DEF VAR aux_cdconven LIKE gnconve.cdconven           NO-UNDO.
DEF VAR aux_cdcooper LIKE gnconve.cdcooper           NO-UNDO.
DEF VAR aux_tpdenvio LIKE gnconve.tpdenvio           NO-UNDO.
DEF VAR aux_dsdiracc LIKE gnconve.dsdiracc           NO-UNDO.
DEF VAR aux_flgativo LIKE gnconve.flgativo           NO-UNDO.
DEF VAR aux_flgcvuni LIKE gnconve.flgcvuni           NO-UNDO.
DEF VAR aux_flgdecla LIKE gnconve.flgdecla           NO-UNDO.
DEF VAR aux_flggeraj LIKE gnconve.flggeraj           NO-UNDO.
DEF VAR aux_flgautdb LIKE gnconve.flgautdb           NO-UNDO.
DEF VAR aux_flgindeb LIKE gnconve.flgindeb           NO-UNDO.
DEF VAR aux_dsagercb LIKE gnconve.dsagercb           NO-UNDO.
DEF VAR aux_cdbccrcb LIKE gnconve.cdbccrcb           NO-UNDO.
DEF VAR aux_dsccdrcb LIKE gnconve.dsccdrcb           NO-UNDO.
DEF VAR aux_cpfcgrcb LIKE gnconve.cpfcgrcb           NO-UNDO.
DEF VAR aux_flgrepas LIKE gnconve.flgrepas           NO-UNDO.
DEF VAR aux_dsemail1 LIKE gnconve.dsendcxa           NO-UNDO.
DEF VAR aux_dsemail2 LIKE gnconve.dsendcxa           NO-UNDO.       
DEF VAR aux_dsemail3 LIKE gnconve.dsendcxa           NO-UNDO.      
DEF VAR aux_dsemail4 LIKE gnconve.dsenddeb           NO-UNDO.  
DEF VAR aux_dsemail5 LIKE gnconve.dsenddeb           NO-UNDO.
DEF VAR aux_dsemail6 LIKE gnconve.dsenddeb           NO-UNDO.
DEF VAR aux_flgenvpa LIKE gnconve.flgenvpa           NO-UNDO.
DEF VAR aux_nrlayout LIKE gnconve.nrlayout           NO-UNDO.
DEF VAR aux_nrseqpar LIKE gnconve.nrseqpar           NO-UNDO.
DEF VAR aux_nmarqpar LIKE gnconve.nmarqpar           NO-UNDO.
DEF VAR aux_tprepass AS CHAR                         NO-UNDO.
DEF VAR aux_flgdbssd LIKE gnconve.flgdbssd           NO-UNDO.
DEF VAR aux_nrctdbfl LIKE gnconve.nrctdbfl           NO-UNDO.
DEF VAR aux_cdcritic AS INTEGER                      NO-UNDO.
DEF VAR aux_dscritic AS CHARACTER                    NO-UNDO.

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

IF  AVAIL crapcop  THEN
    ASSIGN tel_nmrescop = crapcop.nmrescop.

ASSIGN  tel_nrseqatu   = gnconve.nrseqatu   
        tel_nrseqint   = gnconve.nrseqint 
        tel_nrseqcxa   = gnconve.nrseqcxa  
        tel_nrcnvfbr   = gnconve.nrcnvfbr  
        tel_nmempres   = gnconve.nmempres 
        tel_cddbanco   = gnconve.cddbanco    
        tel_flginter   = gnconve.flginter
        tel_cdhisrep   = gnconve.cdhisrep  
        tel_cdhiscxa   = gnconve.cdhiscxa  
        tel_cdhisdeb   = gnconve.cdhisdeb  
        tel_vltrfcxa   = gnconve.vltrfcxa
        tel_vltrfnet   = gnconve.vltrfnet
        tel_vltrftaa   = gnconve.vltrftaa
        tel_vltrfdeb   = gnconve.vltrfdeb
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
        tel_flgativo   = gnconve.flgativo
		tel_nrlayout   = gnconve.nrlayout
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
        tel_dsemail1   = ENTRY(1, gnconve.dsendcxa)
        tel_dsemail2   = ENTRY(2, gnconve.dsendcxa)        
        tel_dsemail3   = ENTRY(3, gnconve.dsendcxa)       
        tel_dsemail4   = ENTRY(1, gnconve.dsenddeb)   
        tel_dsemail5   = ENTRY(2, gnconve.dsenddeb)
        tel_dsemail6   = ENTRY(3, gnconve.dsenddeb)   
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
        tel_flgdbssd = gnconve.flgdbssd
        aux_cdcooper = gnconve.cdcooper
        aux_nrseqatu = gnconve.nrseqatu
        aux_nrseqint = gnconve.nrseqint
        aux_nrseqcxa = gnconve.nrseqcxa
        aux_nrcnvfbr = gnconve.nrcnvfbr
        aux_nmempres = gnconve.nmempres
        aux_cddbanco = gnconve.cddbanco
        aux_flginter = gnconve.flginter
        aux_cdhisrep = gnconve.cdhisrep
        aux_cdhiscxa = gnconve.cdhiscxa
        aux_cdhisdeb = gnconve.cdhisdeb
        aux_vltrfcxa = gnconve.vltrfcxa
        aux_vltrfnet = gnconve.vltrfnet
        aux_vltrftaa = gnconve.vltrftaa
        aux_vltrfdeb = gnconve.vltrfdeb
        aux_nmarqatu = gnconve.nmarqatu
        aux_nmarqcxa = gnconve.nmarqcxa
        aux_nrctdbfl = gnconve.nrctdbfl
        aux_flgagenc = gnconve.flgagenc
        aux_nmarqint = gnconve.nmarqint
        aux_nmarqdeb = gnconve.nmarqdeb
        aux_cdconven = gnconve.cdconven
        aux_cdcooper = gnconve.cdcooper 
        aux_tpdenvio = gnconve.tpdenvio
        aux_dsdiracc = gnconve.dsdiracc
        aux_flgativo = gnconve.flgativo 
        aux_flgcvuni = gnconve.flgcvuni
        aux_flgdecla = gnconve.flgdecla
        aux_flggeraj = gnconve.flggeraj 
        aux_flgautdb = gnconve.flgautdb
        aux_flgindeb = gnconve.flgindeb
        aux_dsagercb = gnconve.dsagercb
        aux_cdbccrcb = gnconve.cdbccrcb
        aux_dsccdrcb = gnconve.dsccdrcb
        aux_cpfcgrcb = gnconve.cpfcgrcb
        aux_flgrepas = gnconve.flgrepas
        aux_tprepass = IF gnconve.tprepass = 1 THEN
                           "D+1"
                       ELSE
                           "D+2"
        aux_dsemail1 = ENTRY(1, gnconve.dsendcxa)
        aux_dsemail2 = ENTRY(2, gnconve.dsendcxa)
        aux_dsemail3 = ENTRY(3, gnconve.dsendcxa)
        aux_dsemail4 = ENTRY(1, gnconve.dsenddeb)
        aux_dsemail5 = ENTRY(2, gnconve.dsenddeb)
        aux_dsemail6 = ENTRY(3, gnconve.dsenddeb)
        aux_flgenvpa = gnconve.flgenvpa
		aux_nrlayout = gnconve.nrlayout
        aux_nrseqpar = gnconve.nrseqpar
        aux_nmarqpar = gnconve.nmarqpar
        aux_flgdbssd = gnconve.flgdbssd.


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
        tel_vltrfnet
        tel_vltrftaa 
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
        tel_flgativo
		tel_nrlayout
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

   DO WHILE TRUE:

      SET tel_nmempres 
          WITH FRAME f_convenio.
          
      DO  WHILE TRUE:
 
          SET tel_cdcooper
              WITH FRAME f_convenio.

          IF   tel_cdcooper <> 0   THEN
               DO:
                   FIND crapcop WHERE
                        crapcop.cdcooper = tel_cdcooper NO-LOCK NO-ERROR.
                   
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
      
         IF  tel_cdhiscxa <> 0                 THEN
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
                         NEXT-PROMPT tel_cdhiscxa WITH FRAME f_convenio.
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
                         NEXT-PROMPT tel_cdhiscxa WITH FRAME f_convenio.
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
      
         IF  tel_cdhisdeb <> 0                 THEN
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
         glb_cddepart        = 6          OR   /* CONTABILIDADE */
         glb_cddepart        = 11         OR   /* FINANCEIRO    */
         glb_cddepart        = 4        THEN   /* COMPE         */
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
          tel_tpdenvio
          WITH FRAME f_convenio.

	  IF tel_nrlayout = 5 AND tel_nmarqatu <> "" THEN
         DO:
            BELL.
            MESSAGE "Convenio nao permite o uso deste layout.".
            NEXT.
         END.
		 
      SET tel_dsdiracc WHEN tel_tpdenvio = 5
          tel_flgdecla
          tel_flggeraj
          WITH FRAME f_convenio.
         
      SET tel_flgautdb WHEN tel_flgdecla  
          tel_flgindeb WHEN tel_cdhisdeb <> 0 
          WITH FRAME f_convenio.
           
                                            
      IF   glb_cdoperad = "979"             OR
           glb_cdoperad = "126"             OR
           UPPER(glb_cdoperad) = "F0030503" OR
           UPPER(glb_cdoperad) = "F0030642" OR
           UPPER(glb_cdoperad) = "F0030175" OR
           glb_cddepart        = 6          OR   /* CONTABILIDADE */
           glb_cddepart        = 11         OR   /* FINANCEIRO    */
           glb_cddepart        = 4        THEN   /* COMPE         */
           DO:
              IF   glb_cdoperad = "979"             OR
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
              
              IF   INPUT tel_tpdenvio = 1  OR  INPUT tel_tpdenvio = 4  THEN
                   DO:
                       DISPLAY tel_dsemail1 
                               tel_dsemail2
                               tel_dsemail3
                               tel_dsemail4
                               tel_dsemail5
                               tel_dsemail6 WITH FRAME f_email.
           
                       PAUSE(0).
           
                       SET tel_dsemail1 
                           tel_dsemail2
                           tel_dsemail3
                           tel_dsemail4
                           tel_dsemail5
                           tel_dsemail6 WITH FRAME f_email.
                   END.
              
           END.

      PAUSE (2) NO-MESSAGE.    

      ASSIGN  gnconve.cdcooper = tel_cdcooper 
              gnconve.nmempres = CAPS(tel_nmempres)
              gnconve.nrseqatu = tel_nrseqatu  
              gnconve.nrseqint = tel_nrseqint 
              gnconve.nrseqcxa = tel_nrseqcxa
              gnconve.nrcnvfbr = tel_nrcnvfbr 
              gnconve.flgagenc = tel_flgagenc
              gnconve.cddbanco = tel_cddbanco 
              gnconve.vltrfcxa = tel_vltrfcxa 
              gnconve.vltrfnet = tel_vltrfnet
              gnconve.vltrftaa = tel_vltrftaa
              gnconve.flginter = tel_flginter
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
			  gnconve.nrlayout = tel_nrlayout
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
              gnconve.tprepass = IF tel_tprepass:SCREEN-VALUE = "D+1" THEN
                                     1
                                 ELSE
                                     2
              gnconve.dsendcxa = TRIM(tel_dsemail1) + "," +
                                 TRIM(tel_dsemail2) + "," +
                                 TRIM(tel_dsemail3) 
              gnconve.dsenddeb = TRIM(tel_dsemail4) + "," + 
                                 TRIM(tel_dsemail5) + "," +
                                 TRIM(tel_dsemail6)
              gnconve.flgenvpa = tel_flgenvpa
              gnconve.nrseqpar = tel_nrseqpar
              gnconve.nmarqpar = tel_nmarqpar
              gnconve.flgdbssd = tel_flgdbssd
              
              log_cdcooper = gnconve.cdcooper
              log_nmempres = gnconve.nmempres
              log_nrseqatu = gnconve.nrseqatu  
              log_nrseqint = gnconve.nrseqint
              log_nrseqcxa = gnconve.nrseqcxa
              log_nrcnvfbr = gnconve.nrcnvfbr
              log_flgagenc = gnconve.flgagenc
              log_cddbanco = gnconve.cddbanco
              log_vltrfcxa = gnconve.vltrfcxa
              log_vltrfnet = gnconve.vltrfnet
              log_vltrftaa = gnconve.vltrftaa
              log_flginter = gnconve.flginter
              log_vltrfdeb = gnconve.vltrfdeb
              log_cdhisrep = gnconve.cdhisrep
              log_cdhiscxa = gnconve.cdhiscxa
              log_cdhisdeb = gnconve.cdhisdeb
              log_nmarqatu = gnconve.nmarqatu
              log_nmarqcxa = gnconve.nmarqcxa
              log_nrctdbfl = gnconve.nrctdbfl
              log_nmarqint = gnconve.nmarqint
              log_nmarqdeb = gnconve.nmarqdeb
              log_tpdenvio = gnconve.tpdenvio
              log_dsdiracc = gnconve.dsdiracc
              log_flgativo = gnconve.flgativo
			  log_nrlayout = gnconve.nrlayout
              log_flgcvuni = gnconve.flgcvuni
              log_flgdecla = gnconve.flgdecla
              log_flggeraj = gnconve.flggeraj
              log_flgautdb = gnconve.flgautdb
              log_flgindeb = gnconve.flgindeb 
              log_dsagercb = gnconve.dsagercb
              log_cdbccrcb = gnconve.cdbccrcb
              log_dsccdrcb = gnconve.dsccdrcb
              log_cpfcgrcb = gnconve.cpfcgrcb
              log_flgrepas = gnconve.flgrepas
              log_tprepass = IF gnconve.tprepass = 1 THEN
                                 "D+1"
                             ELSE
                                 "D+2"
              log_dsemail1 = ENTRY(1, gnconve.dsendcxa)
              log_dsemail2 = ENTRY(2, gnconve.dsendcxa)
              log_dsemail3 = ENTRY(3, gnconve.dsendcxa)
              log_dsemail4 = ENTRY(1, gnconve.dsenddeb)
              log_dsemail5 = ENTRY(2, gnconve.dsenddeb)
              log_dsemail6 = ENTRY(3, gnconve.dsenddeb)
              log_flgenvpa = gnconve.flgenvpa
              log_nrseqpar = gnconve.nrseqpar
              log_nmarqpar = gnconve.nmarqpar
              log_flgdbssd = gnconve.flgdbssd.

          /* Se o sequencial de integracao for maior que o anterior, quer dizer que foi alterado
             e precisa ser criado registro de controle */
          IF  tel_nrseqint > aux_nrseqint THEN
              DO:                    
                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
                  RUN STORED-PROCEDURE pc_pula_seq_gt0001  /** CONV0001 **/
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT glb_cdcooper, /* Código da Cooperativa */
                                             INPUT glb_dtmvtolt, /* Data do Movimento */
                                             INPUT tel_cdconven, /* Codigo do convenio */
                                             INPUT 3,            /* Tipo de controle */
                                             INPUT aux_nrseqint, /* Sequencial anterior */
                                             INPUT tel_nrseqint, /* Sequencial alterado */
                                             INPUT tel_nmarqint, /* Nome do arquivo */ 
                                            OUTPUT 0,            /* Código da crítica */
                                            OUTPUT "").          /* Descrição da crítica */
                  
                  CLOSE STORED-PROC pc_pula_seq_gt0001
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                  
                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = ""                         
                         aux_cdcritic = pc_pula_seq_gt0001.pr_cdcritic 
                                         WHEN pc_pula_seq_gt0001.pr_cdcritic <> ?
                         aux_dscritic = pc_pula_seq_gt0001.pr_dscritic
                                         WHEN pc_pula_seq_gt0001.pr_dscritic <> ?.
                  
                  IF  aux_dscritic <> ""  THEN
                      DO:
                          BELL.
                          MESSAGE aux_dscritic.
                          NEXT.       
                      END.
              END.

          RUN gera_log.

      LEAVE.
   
   END.
                       
END. /* Fim da transacao */

RELEASE gnconve.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.
                 
CLEAR FRAME f_convenio ALL NO-PAUSE.


PROCEDURE gera_log:
    
    RUN alterar_log (INPUT "nome da empresa",
                     INPUT STRING(aux_nmempres),
                     INPUT STRING(log_nmempres)).
    
    RUN alterar_log (INPUT "codigo da cooperativa",
                     INPUT STRING(aux_cdcooper),
                     INPUT STRING(log_cdcooper)).

    RUN alterar_log (INPUT "numero do convenio p/ febraban",
                     INPUT STRING(aux_nrcnvfbr),
                     INPUT STRING(log_nrcnvfbr)).
    
    RUN alterar_log (INPUT "convenio ativo",
                     INPUT STRING(aux_flgativo),
                     INPUT STRING(log_flgativo)).

    RUN alterar_log (INPUT "envia arquivo parcial",
                     INPUT STRING(aux_flgenvpa),
                     INPUT STRING(log_flgenvpa)).
    
    RUN alterar_log (INPUT "tipo do layout",
                     INPUT STRING(aux_nrlayout),
                     INPUT STRING(log_nrlayout)).
    
    RUN alterar_log (INPUT "pagamento via internet",
                     INPUT STRING(aux_flginter),
                     INPUT STRING(log_flginter)).

    RUN alterar_log (INPUT "numero sequencial do arquivo parcial",
                     INPUT STRING(aux_nrseqpar),
                     INPUT STRING(log_nrseqpar)).
    
    RUN alterar_log (INPUT "numero sequencial do arquivo de atualizacao",
                     INPUT STRING(aux_nrseqatu),
                     INPUT STRING(log_nrseqatu)).

    RUN alterar_log (INPUT "numero sequencial do arquivo de debito automatico",
                     INPUT STRING(aux_nrseqint),
                     INPUT STRING(log_nrseqint)).

    RUN alterar_log (INPUT "numero sequencial do arquivo de envio de arrecadacao",
                     INPUT STRING(aux_nrseqcxa),
                     INPUT STRING(log_nrseqcxa)).

    RUN alterar_log (INPUT "usa agencia",
                     INPUT STRING(aux_flgagenc),
                     INPUT STRING(log_flgagenc)).

    RUN alterar_log (INPUT "codigo do banco",
                     INPUT STRING(aux_cddbanco),
                     INPUT STRING(log_cddbanco)).

    RUN alterar_log (INPUT "codigo do historico de arrecadacao de faturas",
                     INPUT STRING(aux_cdhiscxa),
                     INPUT STRING(log_cdhiscxa)).

    RUN alterar_log (INPUT "valor da tarifa de arrecadacao de faturas",
                     INPUT STRING(aux_vltrfcxa),
                     INPUT STRING(log_vltrfcxa)).

    RUN alterar_log (INPUT "valor da tarifa de arrecadacao de faturas na internet",
                     INPUT STRING(aux_vltrfnet),
                     INPUT STRING(log_vltrfnet)).

    RUN alterar_log (INPUT "valor da tarifa para TAA",
                     INPUT STRING(aux_vltrftaa),
                     INPUT STRING(log_vltrftaa)).

    RUN alterar_log (INPUT "codigo do historico de debito automatico",
                     INPUT STRING(aux_cdhisdeb),
                     INPUT STRING(log_cdhisdeb)).
    
    RUN alterar_log (INPUT "valor da tarifa de debito automatico",
                     INPUT STRING(aux_vltrfdeb),
                     INPUT STRING(log_vltrfdeb)).

    RUN alterar_log (INPUT "codigo do historico de repasse de arrecadacoes para o AILOS",
                     INPUT STRING(aux_cdhisrep),
                     INPUT STRING(log_cdhisrep)).
   
    RUN alterar_log (INPUT "nome do arquivo a ser enviado para atualizacao cadastral",
                     INPUT STRING(aux_nmarqatu),
                     INPUT STRING(log_nmarqatu)).

    RUN alterar_log (INPUT "nome do arquivo a ser enviado para arrecadacao de faturas",
                     INPUT STRING(aux_nmarqcxa),
                     INPUT STRING(log_nmarqcxa)).
    RUN alterar_log (INPUT "conta de debito das filiadas",
                     INPUT STRING(aux_nrctdbfl),
                     INPUT STRING(log_nrctdbfl)).

    RUN alterar_log (INPUT "nome do arquivo de integracao de debitos",
                     INPUT STRING(aux_nmarqint),
                     INPUT STRING(log_nmarqint)).

    RUN alterar_log (INPUT "nome do arquivo a ser enviado contendo os debitos efetuados",
                     INPUT STRING(aux_nmarqdeb),
                     INPUT STRING(log_nmarqdeb)).

    RUN alterar_log (INPUT "nome do arquivo parcial",
                     INPUT STRING(aux_nmarqpar),
                     INPUT STRING(log_nmarqpar)).

    RUN alterar_log (INPUT "convenio unificado",
                     INPUT STRING(aux_flgcvuni),
                     INPUT STRING(log_flgcvuni)).

    RUN alterar_log (INPUT "tipo de envio",
                     INPUT STRING(aux_tpdenvio),
                     INPUT STRING(log_tpdenvio)).

    RUN alterar_log (INPUT "diretorio dos arquivos da accesstage",
                     INPUT STRING(aux_dsdiracc),
                     INPUT STRING(log_dsdiracc)).

    RUN alterar_log (INPUT "declaracao",
                     INPUT STRING(aux_flgdecla),
                     INPUT STRING(log_flgdecla)).

    RUN alterar_log (INPUT "gera registro J",
                     INPUT STRING(aux_flggeraj),
                     INPUT STRING(log_flggeraj)).

    RUN alterar_log (INPUT "autorizacao de debito em conta na declaracao do convenio",
                     INPUT STRING(aux_flgautdb),
                     INPUT STRING(log_flgautdb)).

    RUN alterar_log (INPUT "autoriza inclusao de debito",
                     INPUT STRING(aux_flgindeb),
                     INPUT STRING(log_flgindeb)).

    RUN alterar_log (INPUT "codigo do banco de repasse",
                     INPUT STRING(aux_cdbccrcb),
                     INPUT STRING(log_cdbccrcb)).

    RUN alterar_log (INPUT "agencia para recebimento do repasse",
                     INPUT STRING(aux_dsagercb),
                     INPUT STRING(log_dsagercb)).
                                                 
    RUN alterar_log (INPUT "conta de recebimento do repasse",
                     INPUT STRING(aux_dsccdrcb),
                     INPUT STRING(log_dsccdrcb)).

    RUN alterar_log (INPUT "CPF/CNPJ do corretista ao qual e feito o repasse",
                     INPUT STRING(aux_cpfcgrcb),
                     INPUT STRING(log_cpfcgrcb)).

    RUN alterar_log (INPUT "repassar valor bruto/liquido para o convenio",
                     INPUT STRING(aux_flgrepas),
                     INPUT STRING(log_flgrepas)).

    RUN alterar_log (INPUT "end. e-mail caixa 1",
                     INPUT STRING(aux_dsemail1),
                     INPUT STRING(log_dsemail1)).

    RUN alterar_log (INPUT "end. e-mail caixa 2",
                     INPUT STRING(aux_dsemail2),
                     INPUT STRING(log_dsemail2)).

    RUN alterar_log (INPUT "end. e-mail caixa 3",
                     INPUT STRING(aux_dsemail3),
                     INPUT STRING(log_dsemail3)).

    RUN alterar_log (INPUT "end. e-mail debito 1",
                     INPUT STRING(aux_dsemail4),
                     INPUT STRING(log_dsemail4)).

    RUN alterar_log (INPUT "end. e-mail debito 2",
                     INPUT STRING(aux_dsemail5),
                     INPUT STRING(log_dsemail5)).

    RUN alterar_log (INPUT "end. e-mail debito 3",
                     INPUT STRING(aux_dsemail6),
                     INPUT STRING(log_dsemail6)).

    RUN alterar_log (INPUT "forma de repasse",
                     INPUT STRING(aux_tprepass),
                     INPUT STRING(log_tprepass)).

    RUN alterar_log (INPUT "debita sem saldo",
                     INPUT STRING(aux_flgdbssd),
                     INPUT STRING(log_flgdbssd)).


END PROCEDURE.

PROCEDURE alterar_log:
    
    DEF INPUT PARAM par_dsdcampo AS CHAR      NO-UNDO.
    DEF INPUT PARAM vlr_vldantes AS CHAR      NO-UNDO.
    DEF INPUT PARAM vlr_vldepois AS CHAR      NO-UNDO.

    IF vlr_vldepois = vlr_vldantes THEN
       RETURN.
    
       ASSIGN vlr_vldepois = "---" WHEN vlr_vldepois = ""
              vlr_vldantes = "---" WHEN vlr_vldantes = ""
              vlr_vldepois = REPLACE(REPLACE(vlr_vldepois,"("," "),")","-").
              vlr_vldantes = REPLACE(REPLACE(vlr_vldantes,"("," "),")","-").

    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") + " - " +
                      STRING(TIME,"HH:MM:SS") + " '-->' Operador " +
                      glb_cdoperad + " alterou o campo " + par_dsdcampo + " de " +
                      vlr_vldantes + " para " + vlr_vldepois + " no convenio " +
                      STRING(gnconve.cdconven) + " >> log/gt0001.log").
     

END PROCEDURE.

/* .......................................................................... */
