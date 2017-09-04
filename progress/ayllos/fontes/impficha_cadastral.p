/* .............................................................................

   Programa: Fontes/impficha_cadastral.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Eduardo   
   Data    : Junho/2006                        Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir e ou visualizar as A FICHA CADASTRAL.

   Alteracoes: 08/08/2006 - Tratada a vigencia das procuracoes da variavel
                            tel_dtvalida (David).
                            
               03/01/2007 - Considerar titularidade na busca dos CONTATOS
                            (Evandro).
                            
               09/01/2007 - Imprimir o item "RESPONSAVEL LEGAL" e o item
                            "DEPENDENTES" para a pessoa fisica (Evandro).
                            
               31/01/2007 - Efetuado acerto dos campos referente Conjuge
                            (Diego).
                            
               26/03/2007 - Incluido campo "Secao" nos dados comerciais 
                            (Elton). 
               
               20/03/2008 - Alterado campo dssolida para nmdsecao(Guilherme);
                          - Alterada descricao do tipo de contrato de trabalho
                            para "2-TEMP/TERCEIRO" (Evandro).
                            
               18/06/2009 - Extender o campo rendimento e o seu valor 
                            para 4. 
                            Incluir campo endividamento nos representantes 
                            (Gabriel). 

               31/07/2009 - Incluido campo "Concentracao faturamento unico
                            cliente" - crapjfn.perfatcl - no registro pessoa
                            juridica (Fernando).
                            
               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).
               
               27/04/2010 - Adaptacao para uso de BO (Jose Luis, DB1)
               
               04/04/2011 - As informacoes dos contatos na ficha cadastral 
                            a partir da tela contas, serao apenas impresso
                            na opcao impressoes/completo (Adriano).
                           
               18/08/2011 - Adicionado campos tt-fcad.nrdoapto e 
                            tt-fcad.cddbloco em Endereco. (Jorge)
                            
               03/04/2012 - Retirado campo tt-fcad.nranores e adicionado campos
                            tt-fcad.dtabrres e tt-fcad.dstemres. (Jorge)
                            
               27/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).   
                            
               25/04/2013 - Incluir tt-fcad-psfis.cdufnatu no frame de impressao
                            f_dados_pf (Lucas R.)  
               
               02/07/2013 - Inclusao de poderes na ficha cadastral (Jean Michel)
               
               23/05/2014 - Ajustes em ligação de tabelas de procuradores com 
                            tabela de poderes. (Jorge/Rosangela) - SD 155408  
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
               
               07/10/2014 - Remoção do Endividamento e dos Bens dos representantes
                            por caracterizar quebra de sigilo bancário (Dionathan)
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

                            
............................................................................. */

DEF STREAM str_1.

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ includes/var_ficha_cadastral.i }

/* utilizados pelo includes impressao.i */

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.

DEF VAR par_flgrodar AS LOGI                                         NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                         NO-UNDO.
DEF VAR par_flgcance AS LOGI                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.

DEF VAR rel_nmresage AS CHAR                                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                     NO-UNDO.

DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgfirst AS LOGICAL                                      NO-UNDO.
DEF VAR aux_opcimpri AS LOGICAL                                      NO-UNDO.
DEF VAR aux_cdopetfn AS CHAR                                         NO-UNDO.
DEF VAR aux_lsopetfn AS CHAR                                         NO-UNDO.
/*VAR PODERES*/
DEF VAR aux_lstpoder AS CHAR                                         NO-UNDO.
DEF VAR aux_contstri AS INT                                          NO-UNDO.

DEF VAR h-b1wgen0058 AS HANDLE                                       NO-UNDO.
/*FIM VAR PODERES*/
DEF BUFFER crabttl FOR crapttl.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM "** MENSAGEM PRIORITARIA **"
     SKIP(1)
     WITH COLUMN aux_nrcoluna NO-BOX FRAME f_prioridade.
     
FORM tel_dsobserv
     WITH COLUMN aux_nrcoluna NO-BOX NO-LABELS FRAME f_texto.

IF NOT VALID-HANDLE(h-b1wgen0058) THEN
   RUN sistema/generico/procedures/b1wgen0058.p PERSISTENT SET h-b1wgen0058.

DYNAMIC-FUNCTION("ListaPoderes" IN h-b1wgen0058, OUTPUT aux_lstpoder).

ASSIGN glb_cdprogra    = "ANOTA"
       glb_flgbatch    = FALSE
       glb_nrdevias    = 1
       glb_cdempres    = 11
       par_flgrodar    = TRUE.

RUN Busca_Dados.

IF  RETURN-VALUE <> "OK" THEN
    RETURN.

FIND FIRST tt-fcad NO-LOCK NO-ERROR.

IF  NOT AVAILABLE tt-fcad THEN
    DO:
       MESSAGE "Ficha cadastral nao encontrada." VIEW-AS ALERT-BOX.
       RETURN "NOK".
    END.

RUN Atualiza_Campos.

IF  RETURN-VALUE <> "OK" THEN
    RETURN "NOK".


IF   glb_nmrotina = "FICHA CADASTRAL"   THEN
     DO:
         INPUT THROUGH basename `tty` NO-ECHO.
         SET aux_nmendter WITH FRAME f_terminal.
         INPUT CLOSE.

         aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                               aux_nmendter.

         UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

         ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".
     END.
ELSE
     ASSIGN aux_nmarqimp = glb_nmarqimp.

IF   NOT aux_tipconsu   THEN
     DO:
         HIDE MESSAGE NO-PAUSE.

         VIEW FRAME f_aguarde.
         PAUSE 2 NO-MESSAGE.
         HIDE FRAME f_aguarde NO-PAUSE.
   
         IF   glb_nmrotina = "FICHA CADASTRAL"   THEN
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 80 PAGED.
         ELSE
              OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 80 PAGED
                     APPEND.
        
         VIEW STREAM str_1 FRAME f_paginacao.
   
         /*  Configura a impressora para 1/8"  */
         PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

         PUT STREAM str_1 CONTROL "\0330\033x0" NULL.
                            
         aux_nrcoluna = 5.
     END.
ELSE
     DO:
         aux_nrcoluna = 1.

         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
         /* visualiza nao pode ter caracteres de controle */
     END.

ASSIGN glb_cdcritic = 0
       aux_flgfirst = TRUE.

IF   tt-fcad.inpessoa = 1   THEN
     RUN trata_conta_fisica.
ELSE
     RUN trata_conta_juridica.
              
RETURN "OK".

/* .......................................................................... */

/******************************************************************************/
/***********************  P E S S O A    F I S I C A  *************************/
/******************************************************************************/

PROCEDURE trata_conta_fisica:

   DISPLAY STREAM str_1 
       tt-fcad.nmextcop 
       tt-fcad.nrdconta
       tt-fcad.dsagenci 
       tt-fcad.nrmatric  
       WITH FRAME f_identi.

   DISPLAY STREAM str_1
           tt-fcad-psfis.nmextttl 
           tt-fcad-psfis.inpessoa    
           tt-fcad-psfis.dspessoa
           tt-fcad-psfis.nrcpfcgc 
           tt-fcad-psfis.dtcnscpf 
           tt-fcad-psfis.cdsitcpf
           tt-fcad-psfis.dssitcpf 
           tt-fcad-psfis.tpdocttl 
           tt-fcad-psfis.nrdocttl
           tt-fcad-psfis.cdoedttl 
           tt-fcad-psfis.cdufdttl 
           tt-fcad-psfis.dtemdttl
           tt-fcad-psfis.dtnasttl 
           tt-fcad-psfis.cdsexotl 
           tt-fcad-psfis.tpnacion
           tt-fcad-psfis.restpnac 
           tt-fcad-psfis.dsnacion 
           tt-fcad-psfis.dsnatura
           tt-fcad-psfis.cdufnatu
           tt-fcad-psfis.inhabmen 
           tt-fcad-psfis.dshabmen 
           tt-fcad-psfis.dthabmen
           tt-fcad-psfis.cdgraupr WHEN tel_idseqttl <> 1
           tt-fcad-psfis.dsgraupr 
           tt-fcad-psfis.cdestcvl
           tt-fcad-psfis.dsestcvl 
           tt-fcad-psfis.grescola 
           tt-fcad-psfis.dsescola
           tt-fcad-psfis.cdfrmttl 
           tt-fcad-psfis.rsfrmttl 
           tt-fcad-psfis.nmtalttl 
           tt-fcad-psfis.qtfoltal    
           WITH FRAME f_dados_pf.
           
   DISPLAY STREAM str_1 
       tt-fcad-filia.nmpaittl    
       tt-fcad-filia.nmmaettl
       WITH FRAME f_filiacao_pf.
  
   /* Endereco */
   DISPLAY STREAM str_1 
       tt-fcad.incasprp    
       tt-fcad.dscasprp
       tt-fcad.dtabrres
       tt-fcad.dstemres
       tt-fcad.vlalugue
       tt-fcad.nrcepend    
       tt-fcad.dsendere
       tt-fcad.nrendere    
       tt-fcad.complend
       tt-fcad.nmbairro    
       tt-fcad.nmcidade
       tt-fcad.cdufende    
       tt-fcad.nrcxapst
       tt-fcad.nrdoapto
       tt-fcad.cddbloco
       WITH FRAME f_endereco.
  
   /* Endereco Comercial */
   DISPLAY STREAM str_1 tt-fcad-comer.cdnatopc    
                        tt-fcad-comer.rsnatocp        
                        tt-fcad-comer.cdocpttl
                        tt-fcad-comer.rsocupa         
                        tt-fcad-comer.tpcttrab    
                        tt-fcad-comer.dsctrtab
                        tt-fcad-comer.nmextemp    
                        tt-fcad-comer.nrcgcemp
                        tt-fcad-comer.dsproftl    
                        tt-fcad-comer.cdnvlcgo    
                        tt-fcad-comer.rsnvlcgo
                        tt-fcad-comer.nrcepend 
                        tt-fcad-comer.dsendere 
                        tt-fcad-comer.nrendere 
                        tt-fcad-comer.complend 
                        tt-fcad-comer.nmbairro 
                        tt-fcad-comer.nmcidade 
                        tt-fcad-comer.cdufende 
                        tt-fcad-comer.nrcxapst 
                        tt-fcad-comer.cdturnos    
                        tt-fcad-comer.dtadmemp    
                        tt-fcad-comer.vlsalari
                        tt-fcad-comer.tpdrend1 
                        tt-fcad-comer.dstipre1     
                        tt-fcad-comer.vldrend1
                        tt-fcad-comer.tpdrend2 
                        tt-fcad-comer.dstipre2     
                        tt-fcad-comer.vldrend2
                        tt-fcad-comer.tpdrend3 
                        tt-fcad-comer.dstipre3     
                        tt-fcad-comer.vldrend3
                        tt-fcad-comer.tpdrend4 
                        tt-fcad-comer.dstipre4     
                        tt-fcad-comer.vldrend4
                        tt-fcad-comer.cdempres    
                        tt-fcad-comer.nmresemp
                        WITH FRAME f_comercial_pf.

   DISPLAY STREAM str_1 WITH FRAME f_titulo_bens.
 
   /* bens */
   FOR EACH tt-fcad-cbens NO-LOCK:
       
       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)     AND
            NOT aux_tipconsu                            THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_bens.
            END.

       DISPLAY STREAM str_1 tt-fcad-cbens.dsrelbem   
                            tt-fcad-cbens.persemon  
                            tt-fcad-cbens.qtprebem
                            tt-fcad-cbens.vlprebem   
                            tt-fcad-cbens.vlrdobem
                            WITH FRAME f_bens.

       DOWN STREAM str_1 WITH FRAME f_bens. 

   END.

   DOWN 1 STREAM str_1 WITH FRAME f_bens.
   

   DISPLAY STREAM str_1 WITH FRAME f_titulo_telefones.

   /* telefones */
   FOR EACH tt-fcad-telef:
       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)     AND
            NOT aux_tipconsu                            THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_telefones.
            END.

       DISPLAY STREAM str_1 
           tt-fcad-telef.dsopetfn 
           tt-fcad-telef.nrdddtfc
           tt-fcad-telef.nrtelefo 
           tt-fcad-telef.nrdramal
           tt-fcad-telef.tptelefo
           tt-fcad-telef.secpscto      
           tt-fcad-telef.nmpescto
           WITH FRAME f_telefones.
                
       DOWN STREAM str_1 WITH FRAME f_telefones.
   END.
   
   DOWN 1 STREAM str_1 WITH FRAME f_telefones.
  
   DISPLAY STREAM str_1 WITH FRAME f_titulo_emails.

   /* emails */
   FOR EACH tt-fcad-email:

       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)    AND
            NOT aux_tipconsu                           THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_emails.
            END.

       DISPLAY STREAM str_1 
           tt-fcad-email.dsdemail      
           tt-fcad-email.secpscto
           tt-fcad-email.nmpescto      
           WITH FRAME f_emails.
               
       DOWN STREAM str_1 WITH FRAME f_emails.
   END.
   
   DOWN 1 STREAM str_1 WITH FRAME f_emails.

   /* Conjuge */
   IF  AVAILABLE tt-fcad-cjuge THEN
       DISPLAY STREAM str_1
           tt-fcad-cjuge.nrctacje
           tt-fcad-cjuge.dtnasccj
           tt-fcad-cjuge.nrcpfcje
           tt-fcad-cjuge.nmconjug
           tt-fcad-cjuge.tpdoccje
           tt-fcad-cjuge.nrdoccje
           tt-fcad-cjuge.cdoedcje
           tt-fcad-cjuge.cdufdcje
           tt-fcad-cjuge.dtemdcje
           tt-fcad-cjuge.gresccje
           tt-fcad-cjuge.dsescola
           tt-fcad-cjuge.cdfrmttl
           tt-fcad-cjuge.rsfrmttl
           tt-fcad-cjuge.cdnatopc
           tt-fcad-cjuge.rsnatocp
           tt-fcad-cjuge.cdocpttl
           tt-fcad-cjuge.rsocupa
           tt-fcad-cjuge.tpcttrab
           tt-fcad-cjuge.dsctrtab
           tt-fcad-cjuge.nmextemp
           tt-fcad-cjuge.nrcpfemp
           tt-fcad-cjuge.dsproftl
           tt-fcad-cjuge.cdnvlcgo
           tt-fcad-cjuge.rsnvlcgo
           tt-fcad-cjuge.nrfonemp
           tt-fcad-cjuge.nrramemp
           tt-fcad-cjuge.cdturnos
           tt-fcad-cjuge.dtadmemp
           tt-fcad-cjuge.vlsalari
           WITH FRAME f_conjuge_pf.

   /* lista os dependentes */
   DISPLAY STREAM str_1 WITH FRAME f_titulo_dependentes_pf.

   FOR EACH tt-fcad-depen:
       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)    AND
            NOT aux_tipconsu                           THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_dependentes_pf.
            END.

       DISPLAY STREAM str_1
           tt-fcad-depen.nmdepend
           tt-fcad-depen.dtnascto
           tt-fcad-depen.tpdepend
           tt-fcad-depen.dstextab
           WITH FRAME f_dependentes_pf.

       DOWN STREAM str_1 WITH FRAME f_dependentes_pf.
   END.
   
   DOWN 1 STREAM str_1 WITH FRAME f_dependentes_pf.

    
   
   IF glb_nmrotina <> "FICHA CADASTRAL" AND
     (glb_nmrotina = "IMPRESSOES"       AND
      aux_impcadto = FALSE)  THEN
      DO:
         /* lista de contatos */
         FOR EACH tt-fcad-ctato BREAK BY tt-fcad-ctato.nrdctato:
             IF   FIRST-OF(tt-fcad-ctato.nrdctato)   THEN
                  DO:
                      /* Verifica se cabe um contato */
                      IF   LINE-COUNTER(str_1) + 7 >= PAGE-SIZE(str_1)     AND
                           NOT aux_tipconsu                            THEN
                           PAGE STREAM str_1.
                          
                      DISPLAY STREAM str_1 WITH FRAME f_titulo_contatos_pf.
                  END.
        
             DISPLAY STREAM str_1
                 tt-fcad-ctato.nrdctato
                 tt-fcad-ctato.nmdavali
                 tt-fcad-ctato.nrcepend
                 tt-fcad-ctato.dsendere
                 tt-fcad-ctato.nrendere
                 tt-fcad-ctato.complend
                 tt-fcad-ctato.nmbairro
                 tt-fcad-ctato.nmcidade
                 tt-fcad-ctato.cdufende
                 tt-fcad-ctato.nrcxapst
                 tt-fcad-ctato.nrtelefo
                 tt-fcad-ctato.dsdemail
                 WITH FRAME f_contatos_pf.
        
             DOWN STREAM str_1 WITH FRAME f_contatos_pf.
        
         END.


      END.


   /* responsavel legal */
   FOR EACH tt-fcad-respl BREAK BY tt-fcad-respl.nrdconta:
       IF FIRST-OF(tt-fcad-respl.nrdconta)   THEN
          DO:
              /* Verifica se cabe um contato */
              IF LINE-COUNTER(str_1) + 12 >= PAGE-SIZE(str_1) AND
                 NOT aux_tipconsu                             THEN
                 PAGE STREAM str_1.
                  
              DISPLAY STREAM str_1 WITH FRAME f_titulo_responsavel_pf.
          END.

       /* Se quebrar a pagina, repete o cabecalho */
       IF LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) AND
          NOT aux_tipconsu                        THEN
          DO:
              PAGE STREAM str_1.
              DISPLAY STREAM str_1 WITH FRAME f_titulo_responsavel_pf.
          END.

       DISPLAY STREAM str_1 tt-fcad-respl.nrdconta    
                            tt-fcad-respl.nrcpfcgc    
                            tt-fcad-respl.nmrespon
                            tt-fcad-respl.tpdeiden    
                            tt-fcad-respl.nridenti    
                            tt-fcad-respl.dsorgemi
                            tt-fcad-respl.cdufiden    
                            tt-fcad-respl.dtemiden    
                            tt-fcad-respl.dtnascin
                            tt-fcad-respl.cddosexo    
                            tt-fcad-respl.cdestciv    
                            tt-fcad-respl.dsestciv
                            tt-fcad-respl.dsnacion    
                            tt-fcad-respl.dsnatura    
                            tt-fcad-respl.cdcepres
                            tt-fcad-respl.dsendres    
                            tt-fcad-respl.nrendres    
                            tt-fcad-respl.dscomres
                            tt-fcad-respl.dsbaires
                            tt-fcad-respl.dscidres    
                            tt-fcad-respl.dsdufres
                            tt-fcad-respl.nrcxpost    
                            tt-fcad-respl.nmmaersp    
                            tt-fcad-respl.nmpairsp
                            WITH FRAME f_responsavel_pf.

       DOWN STREAM str_1 WITH FRAME f_responsavel_pf.

   END.
   

   /* Procurador */
   FOR EACH tt-fcad-procu:
       /* Se quebrar a pagina, repete o cabecalho */
       IF LINE-COUNTER(str_1) > PAGE-SIZE(str_1) - 14 AND
          NOT aux_tipconsu                            THEN
          DO:
              PAGE STREAM str_1.
              DISPLAY STREAM str_1 WITH FRAME f_titulo_procuradores_pf.
          END.
       ELSE
          DISPLAY STREAM str_1 WITH FRAME f_titulo_procuradores_pf.

       DISPLAY STREAM str_1 tt-fcad-procu.nrcpfcgc
                            tt-fcad-procu.nmdavali
                            tt-fcad-procu.tpdocava
                            tt-fcad-procu.nrdocava
                            tt-fcad-procu.cdoeddoc
                            tt-fcad-procu.cdufddoc
                            tt-fcad-procu.dtemddoc
                            tt-fcad-procu.dtnascto
                            tt-fcad-procu.cdsexcto
                            tt-fcad-procu.dsestcvl
                            tt-fcad-procu.dsnacion
                            tt-fcad-procu.dsnatura
                            tt-fcad-procu.nrcepend
                            tt-fcad-procu.dsendere
                            tt-fcad-procu.nrendere
                            tt-fcad-procu.complend
                            tt-fcad-procu.nmbairro
                            tt-fcad-procu.nmcidade
                            tt-fcad-procu.cdufende
                            tt-fcad-procu.nrcxapst
                            tt-fcad-procu.nmmaecto
                            tt-fcad-procu.nmpaicto
                            tt-fcad-procu.dtvalida
                            tt-fcad-procu.nrdctato 
                            /*tt-fcad-procu.vledvmto*/
                            tt-fcad-procu.inhabmen
                            tt-fcad-procu.dthabmen
                            tt-fcad-procu.dshabmen
                            WITH FRAME f_procuradores_pf.

       DOWN STREAM str_1 WITH FRAME f_procuradores_pf.

       /* poderes */

       ASSIGN aux_dsoutpo1 = ""
              aux_dsoutpo2 = "" 
              aux_dsoutpo3 = "" 
              aux_dsoutpo4 = "" 
              aux_dsoutpo5 = "". 
       
       FOR EACH tt-fcad-poder WHERE
                tt-fcad-poder.nrdconta = INT(tt-fcad.nrdconta) AND
                tt-fcad-poder.nrctapro = INT(tt-fcad-procu.nrdctato) AND
                tt-fcad-poder.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                NO-LOCK BREAK BY tt-fcad-poder.nrctapro:
           
           IF FIRST-OF(tt-fcad-poder.nrctapro)   THEN
              DO:
                  DISPLAY STREAM str_1 WITH FRAME f_cabecalho_poderes.
              END.

           /* Se quebrar a pagina, repete o cabecalho */
           IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) AND
                NOT aux_tipconsu                            THEN
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 WITH FRAME f_titulo_poderes.
                END.
           
           IF INT(tt-fcad-poder.dscpoder) <> 9 THEN
              DO:
                  IF tt-fcad-poder.flgconju = "NO" THEN
                     tt-fcad-poder.flgconju = "Nao".
                  ELSE
                     tt-fcad-poder.flgconju = "Sim".
                
                  IF tt-fcad-poder.flgisola = "NO" THEN
                     tt-fcad-poder.flgisola = "Nao".
                  ELSE
                     tt-fcad-poder.flgisola = "Sim".
              END.
           ELSE
              DO:
                  tt-fcad-poder.flgconju = " ".
                  tt-fcad-poder.flgisola = " ".
                  DO aux_contstri = 1 TO NUM-ENTRIES(tt-fcad-poder.dsoutpod,"#"):
    
                     IF aux_contstri = 1 THEN
                        aux_dsoutpo1 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 2 THEN
                           aux_dsoutpo2 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 3 THEN
                           aux_dsoutpo3 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 4 THEN
                           aux_dsoutpo4 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 5 THEN
                           aux_dsoutpo5 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                  END.
           END.


           IF INT(tt-fcad-poder.dscpoder) <> 9 THEN
            DO:
                tt-fcad-poder.dscpoder = ENTRY(INT(tt-fcad-poder.dscpoder), aux_lstpoder) + "Teste jean".

               DISPLAY STREAM str_1 tt-fcad-poder.flgconju @ tt-fcad-poder.flgconju FORMAT "X(3)"
                                    tt-fcad-poder.flgisola @ tt-fcad-poder.flgisola FORMAT "X(3)"
                                    TRIM(tt-fcad-poder.dscpoder) @ tt-fcad-poder.dscpoder
                                    WITH FRAME f_poderes.
               
               DOWN STREAM str_1 WITH FRAME f_poderes.
            END.
           
       END.

      /* DISPLAY STREAM str_1 tt-fcad-poder.flgconju @ tt-fcad-poder.flgconju FORMAT "X(3)"
                            tt-fcad-poder.flgisola @ tt-fcad-poder.flgisola FORMAT "X(3)"
                            TRIM(tt-fcad-poder.dscpoder) @ tt-fcad-poder.dscpoder
                            WITH FRAME f_poderes.
           
       DOWN STREAM str_1 WITH FRAME f_poderes.
*/
       IF aux_dsoutpo1 <> "" THEN DO:
              DISPLAY STREAM str_1 aux_dsoutpo1
                                   aux_dsoutpo2
                                   aux_dsoutpo3
                                   aux_dsoutpo4
                                   aux_dsoutpo5
                                   WITH FRAME f_poderes_outros.
       END.

       DOWN 1 STREAM str_1 WITH FRAME f_poderes.
       /* poderes */

       /* bens */
       
       FOR EACH tt-fcad-bensp WHERE
                              tt-fcad-bensp.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                              NO-LOCK:

           /* Se quebrar a pagina, repete o cabecalho */
           IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)     AND
                NOT aux_tipconsu                            THEN
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 WITH FRAME f_titulo_bens.
                END.

           DISPLAY STREAM str_1 tt-fcad-bensp.dsrelbem @ tt-fcad-cbens.dsrelbem
                                tt-fcad-bensp.persemon @ tt-fcad-cbens.persemon
                                tt-fcad-bensp.qtprebem @ tt-fcad-cbens.qtprebem
                                tt-fcad-bensp.vlprebem @ tt-fcad-cbens.vlprebem
                                tt-fcad-bensp.vlrdobem @ tt-fcad-cbens.vlrdobem
                                WITH FRAME f_bens.

           DOWN STREAM str_1 WITH FRAME f_bens.
       END.

       DOWN 1 STREAM str_1 WITH FRAME f_bens.
       /* bens */
   END.
   

   /* Se a ficha for dos outros titulares coloca tambem o 1o. titular */
   IF   tel_idseqttl <> 1   THEN
        DO:
            DISPLAY STREAM str_1 
                tt-fcad.dsmvtolt
                tt-fcad-psfis.nmprimtl @ tt-fcad.nmprimtl
                WITH FRAME f_cadast.
            
            DOWN STREAM str_1 WITH FRAME f_cadast.

            DISPLAY STREAM str_1 
                "" @ tt-fcad.dsmvtolt 
                tt-fcad.nmprimtl
                WITH FRAME f_cadast.
                                 
            DISPLAY STREAM str_1 SKIP(2) WITH FRAME f_pula_linha.
        END.
   ELSE
        DO:
            DISPLAY STREAM str_1 
                tt-fcad.dsmvtolt 
                tt-fcad.nmprimtl
                WITH FRAME f_cadast.
                                
            DISPLAY STREAM str_1 SKIP(2) WITH FRAME f_pula_linha.
        END.                                
  
   DISPLAY STREAM str_1 tt-fcad.dsoperad WITH FRAME f_responsa.
  
   OUTPUT STREAM STR_1 CLOSE.

   IF   NOT aux_tipconsu                   AND
        glb_nmrotina = "FICHA CADASTRAL"   THEN
        DO:
            /*** nao necessario ao programa somente para nao dar erro
                 de compilacao na rotina de impressao ****/
            FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                     NO-LOCK NO-ERROR.

            { includes/impressao.i }

            HIDE MESSAGE NO-PAUSE.
        END.

END PROCEDURE.

 
/******************************************************************************/
/********************** P E S S O A    J U R I D I C A ************************/
/******************************************************************************/

PROCEDURE trata_conta_juridica:
   
   DISPLAY STREAM str_1 tt-fcad.nmextcop 
                        tt-fcad.nrdconta
                        tt-fcad.dsagenci 
                        tt-fcad.nrmatric  
                        WITH FRAME f_identi.
                 
   DISPLAY STREAM str_1 tt-fcad-psjur.nmprimtl  
                        tt-fcad-psjur.inpessoa  
                        tt-fcad-psjur.dspessoa      
                        tt-fcad-psjur.nmfansia  
                        tt-fcad-psjur.nrcpfcgc      
                        tt-fcad-psjur.dtcnscpf  
                        tt-fcad-psjur.cdsitcpf  
                        tt-fcad-psjur.dssitcpf      
                        tt-fcad-psjur.natjurid  
                        tt-fcad-psjur.dsnatjur      
                        tt-fcad-psjur.qtfilial  
                        tt-fcad-psjur.qtfuncio  
                        tt-fcad-psjur.dtiniatv  
                        tt-fcad-psjur.cdseteco  
                        tt-fcad-psjur.nmseteco      
                        tt-fcad-psjur.cdrmativ  
                        tt-fcad-psjur.dsrmativ      
                        tt-fcad-psjur.dsendweb  
                        tt-fcad-psjur.qtfoltal  
                        tt-fcad-psjur.nmtalttl  
                        WITH FRAME f_dados_pj.

    DISPLAY STREAM str_1 tt-fcad-regis.vlfatano  
                         tt-fcad-regis.vlcaprea  
                         tt-fcad-regis.dtregemp
                         tt-fcad-regis.nrregemp  
                         tt-fcad-regis.orregemp  
                         tt-fcad-regis.dtinsnum
                         tt-fcad-regis.nrinsmun  
                         tt-fcad-regis.nrinsest  
                         tt-fcad-regis.flgrefis
                         tt-fcad-regis.perfatcl
                         tt-fcad-regis.nrcdnire  
                         WITH FRAME f_registro_pj.
    
   FOR EACH tt-fcad-procu NO-LOCK :
            
       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) - 14   AND
            NOT aux_tipconsu                              THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_procuradores_pj.
            END.
       ELSE
          DISPLAY STREAM str_1 WITH FRAME f_titulo_procuradores_pj.

       DISPLAY STREAM str_1 tt-fcad-procu.nrcpfcgc
                            tt-fcad-procu.nmdavali
                            tt-fcad-procu.tpdocava
                            tt-fcad-procu.nrdocava
                            tt-fcad-procu.cdoeddoc
                            tt-fcad-procu.cdufddoc
                            tt-fcad-procu.dtemddoc
                            tt-fcad-procu.dtnascto
                            tt-fcad-procu.cdsexcto
                            tt-fcad-procu.dsestcvl
                            tt-fcad-procu.dsnacion
                            tt-fcad-procu.dsnatura
                            tt-fcad-procu.nrcepend
                            tt-fcad-procu.dsendere
                            tt-fcad-procu.nrendere
                            tt-fcad-procu.complend
                            tt-fcad-procu.nmbairro
                            tt-fcad-procu.nmcidade
                            tt-fcad-procu.cdufende
                            tt-fcad-procu.nrcxapst
                            tt-fcad-procu.nmmaecto
                            tt-fcad-procu.nmpaicto
                            tt-fcad-procu.dtvalida
                            tt-fcad-procu.dsproftl
                            tt-fcad-procu.nrdctato
                            /*tt-fcad-procu.vledvmto*/
                            tt-fcad-procu.persocio
                            tt-fcad-procu.flgdepec
                            tt-fcad-procu.inhabmen
                            tt-fcad-procu.dthabmen
                            tt-fcad-procu.dshabmen
                            WITH FRAME f_procuradores_pj.

       DOWN STREAM str_1 WITH FRAME f_procuradores_pj.
       
        /* poderes */
       ASSIGN aux_dsoutpo1 = ""
              aux_dsoutpo2 = "" 
              aux_dsoutpo3 = ""   
              aux_dsoutpo4 = ""   
              aux_dsoutpo5 = "".
        
       FOR EACH tt-fcad-poder WHERE
                tt-fcad-poder.nrdconta = INT(tt-fcad.nrdconta) AND
                tt-fcad-poder.nrctapro = INT(tt-fcad-procu.nrdctato) AND
                tt-fcad-poder.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                EXCLUSIVE-LOCK BREAK BY tt-fcad-poder.nrctapro:
           
           IF FIRST-OF(tt-fcad-poder.nrctapro)   THEN
              DO:
                  DISPLAY STREAM str_1 WITH FRAME f_cabecalho_poderes.
              END.

           /* Se quebrar a pagina, repete o cabecalho */
           IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) AND
                NOT aux_tipconsu                            THEN
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 WITH FRAME f_titulo_poderes.
                END.
           
           IF INT(tt-fcad-poder.dscpoder) <> 9 THEN
              DO:
                  IF tt-fcad-poder.flgconju = "NO" THEN
                     tt-fcad-poder.flgconju = "Nao".
                  ELSE
                     tt-fcad-poder.flgconju = "Sim".
                
                  IF tt-fcad-poder.flgisola = "NO" THEN
                     tt-fcad-poder.flgisola = "Nao".
                  ELSE
                     tt-fcad-poder.flgisola = "Sim".
              END.
           ELSE
              DO:
                  tt-fcad-poder.flgconju = " ".
                  tt-fcad-poder.flgisola = " ".
                  DO aux_contstri = 1 TO NUM-ENTRIES(tt-fcad-poder.dsoutpod,"#"):
                     IF aux_contstri = 1 THEN
                        aux_dsoutpo1 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 2 THEN
                           aux_dsoutpo2 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 3 THEN
                           aux_dsoutpo3 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 4 THEN
                           aux_dsoutpo4 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                     ELSE
                        IF aux_contstri = 5 THEN
                           aux_dsoutpo5 = "- " + ENTRY(aux_contstri,tt-fcad-poder.dsoutpod,"#").
                  END.
           END.

           IF INT(tt-fcad-poder.dscpoder) <> 9 THEN
            DO:
            
               tt-fcad-poder.dscpoder = ENTRY(INT(tt-fcad-poder.dscpoder), aux_lstpoder).
    
               DISPLAY STREAM str_1 tt-fcad-poder.flgconju @ tt-fcad-poder.flgconju FORMAT "X(3)"
                                    tt-fcad-poder.flgisola @ tt-fcad-poder.flgisola FORMAT "X(3)"
                                    TRIM(tt-fcad-poder.dscpoder) @ tt-fcad-poder.dscpoder
                                    WITH FRAME f_poderes.
               
               DOWN STREAM str_1 WITH FRAME f_poderes.
            END.
       END.

       tt-fcad-poder.dscpoder = ENTRY(9, aux_lstpoder).
       
       DISPLAY STREAM str_1 TRIM(tt-fcad-poder.dscpoder) @ tt-fcad-poder.dscpoder
                            WITH FRAME f_poderes.
       
       DOWN STREAM str_1 WITH FRAME f_poderes.

       IF aux_dsoutpo1 <> "" THEN DO:
              DISPLAY STREAM str_1 aux_dsoutpo1
                                   aux_dsoutpo2
                                   aux_dsoutpo3
                                   aux_dsoutpo4
                                   aux_dsoutpo5
                                   WITH FRAME f_poderes_outros.
       END.

       DOWN 1 STREAM str_1 WITH FRAME f_poderes.
       
       /* bens */
       /*
       FOR EACH tt-fcad-bensp WHERE
                              tt-fcad-bensp.nrcpfcgc = tt-fcad-procu.nrcpfcgc
                              NO-LOCK:

           /* Se quebrar a pagina, repete o cabecalho */
           IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)     AND
                NOT aux_tipconsu                            THEN
                DO:
                    PAGE STREAM str_1.
                    DISPLAY STREAM str_1 WITH FRAME f_titulo_bens.

                END.

           DISPLAY STREAM str_1 tt-fcad-bensp.dsrelbem @ tt-fcad-cbens.dsrelbem
                                tt-fcad-bensp.persemon @ tt-fcad-cbens.persemon
                                tt-fcad-bensp.qtprebem @ tt-fcad-cbens.qtprebem
                                tt-fcad-bensp.vlprebem @ tt-fcad-cbens.vlprebem
                                tt-fcad-bensp.vlrdobem @ tt-fcad-cbens.vlrdobem
                                WITH FRAME f_bens.

           DOWN STREAM str_1 WITH FRAME f_bens.

       END.

       DOWN 1 STREAM str_1 WITH FRAME f_bens.
       */

       /* responsavel legal */ 
       FOR EACH tt-fcad-respl
                  WHERE tt-fcad-respl.nrctamen = tt-fcad-procu.nrdctato AND
                        (IF tt-fcad-procu.nrdctato = 0 THEN 
                            tt-fcad-respl.nrcpfmen = DEC(REPLACE(REPLACE(
                                         tt-fcad-procu.nrcpfcgc,".",""),"-",""))
                         ELSE
                            TRUE)
                        NO-LOCK:

           DISPLAY STREAM str_1 WITH FRAME f_titulo_responsavel_pj.

           /* Se quebrar a pagina, repete o cabecalho */
           IF LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) AND
              NOT aux_tipconsu                        THEN
              DO:
                  PAGE STREAM str_1.
                  DISPLAY STREAM str_1 WITH FRAME f_titulo_responsavel_pj.
              END.
           
           DISPLAY STREAM str_1 tt-fcad-respl.nrdconta    
                                tt-fcad-respl.nrcpfcgc    
                                tt-fcad-respl.nmrespon
                                tt-fcad-respl.tpdeiden    
                                tt-fcad-respl.nridenti    
                                tt-fcad-respl.dsorgemi
                                tt-fcad-respl.cdufiden    
                                tt-fcad-respl.dtemiden    
                                tt-fcad-respl.dtnascin
                                tt-fcad-respl.cddosexo    
                                tt-fcad-respl.cdestciv    
                                tt-fcad-respl.dsestciv
                                tt-fcad-respl.dsnacion    
                                tt-fcad-respl.dsnatura    
                                tt-fcad-respl.cdcepres
                                tt-fcad-respl.dsendres    
                                tt-fcad-respl.nrendres    
                                tt-fcad-respl.dscomres
                                tt-fcad-respl.dsbaires    
                                tt-fcad-respl.dscidres    
                                tt-fcad-respl.dsdufres
                                tt-fcad-respl.nrcxpost    
                                tt-fcad-respl.nmmaersp    
                                tt-fcad-respl.nmpairsp
                                WITH FRAME f_responsavel_pj.
           
           DOWN STREAM str_1 WITH FRAME f_responsavel_pj.

       END.
       
   END.

   /*  Se nao existir informacoes sobre a representantes/procuradores  */
   IF   NOT CAN-FIND(FIRST tt-fcad-procu WHERE
                     tt-fcad-procu.nmdavali <> "") THEN
        DISPLAY STREAM str_1 WITH FRAME f_procuradores_pj.

   DISPLAY STREAM str_1 WITH FRAME f_titulo_bens.
   
   FOR EACH tt-fcad-cbens NO-LOCK:

       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)     AND
            NOT aux_tipconsu                            THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_bens.
            END.

       DISPLAY STREAM str_1 tt-fcad-cbens.dsrelbem   
                            tt-fcad-cbens.persemon  
                            tt-fcad-cbens.qtprebem
                            tt-fcad-cbens.vlprebem   
                            tt-fcad-cbens.vlrdobem
                            WITH FRAME f_bens.

       DOWN STREAM str_1 WITH FRAME f_bens. 
   END.
                 
   DOWN 1 STREAM str_1 WITH FRAME f_bens.
   

   /* Endereco */
   DISPLAY STREAM str_1 tt-fcad.incasprp    
                        tt-fcad.dscasprp
                        tt-fcad.dtabrres
                        tt-fcad.dstemres
                        tt-fcad.vlalugue
                        tt-fcad.nrcepend    
                        tt-fcad.dsendere
                        tt-fcad.nrendere    
                        tt-fcad.complend
                        tt-fcad.nmbairro    
                        tt-fcad.nmcidade
                        tt-fcad.cdufende    
                        tt-fcad.nrcxapst
                        tt-fcad.nrdoapto
                        tt-fcad.cddbloco
                        WITH FRAME f_endereco.
                                                              
   /*   quebrar da pagina  */
   IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  AND
        NOT aux_tipconsu                         THEN
        PAGE STREAM str_1.

   IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) - 6 AND
        NOT aux_tipconsu                           THEN
        DO:
            PAGE STREAM str_1.
        END.

   DISPLAY STREAM str_1 WITH FRAME f_titulo_telefones.

   FOR EACH tt-fcad-telef:
       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)     AND
            NOT aux_tipconsu                            THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_telefones.
            END.

       DISPLAY STREAM str_1 tt-fcad-telef.dsopetfn 
                            tt-fcad-telef.nrdddtfc
                            tt-fcad-telef.nrtelefo 
                            tt-fcad-telef.nrdramal
                            tt-fcad-telef.tptelefo
                            tt-fcad-telef.secpscto      
                            tt-fcad-telef.nmpescto
                            WITH FRAME f_telefones.
                
       DOWN STREAM str_1 WITH FRAME f_telefones.
   END.

   DOWN 1 STREAM str_1 WITH FRAME f_telefones.
  
   DISPLAY STREAM str_1 WITH FRAME f_titulo_emails.

   FOR EACH tt-fcad-email:

       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)    AND
            NOT aux_tipconsu                           THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_emails.
            END.

       DISPLAY STREAM str_1 tt-fcad-email.dsdemail      
                            tt-fcad-email.secpscto
                            tt-fcad-email.nmpescto      
                            WITH FRAME f_emails.
               
       DOWN STREAM str_1 WITH FRAME f_emails.
   END.
   
   DOWN 1 STREAM str_1 WITH FRAME f_emails.
   
   DISPLAY STREAM str_1 WITH FRAME f_titulo_referencias_pj.

   FOR EACH tt-fcad-refer:

       /* Se quebrar a pagina, repete o cabecalho */
       IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1) - 9   AND
            NOT aux_tipconsu                             THEN
            DO:
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 WITH FRAME f_titulo_referencias_pj.
            END.

       DISPLAY STREAM str_1 tt-fcad-refer.nrdctato    
                            tt-fcad-refer.nmdavali    
                            tt-fcad-refer.dsproftl    
                            tt-fcad-refer.nmextemp    
                            tt-fcad-refer.cddbanco    
                            tt-fcad-refer.cdagenci    
                            tt-fcad-refer.nrcepend    
                            tt-fcad-refer.dsendere    
                            tt-fcad-refer.nrendere    
                            tt-fcad-refer.complend    
                            tt-fcad-refer.nmbairro    
                            tt-fcad-refer.nmcidade    
                            tt-fcad-refer.cdufende    
                            tt-fcad-refer.nrcxapst    
                            tt-fcad-refer.nrtelefo    
                            tt-fcad-refer.dsdemail    
                            WITH FRAME f_referencias_pj.

       DOWN STREAM str_1 WITH FRAME f_referencias_pj.

   END.

  DISPLAY STREAM str_1 tt-fcad.dsmvtolt tt-fcad.nmprimtl  WITH FRAME f_cadast.
  
  DISPLAY STREAM str_1 SKIP(2) WITH FRAME f_pula_linha.
  
  DISPLAY STREAM str_1 tt-fcad.dsoperad WITH FRAME f_responsa.
  
  OUTPUT STREAM STR_1 CLOSE.
                  
  IF   NOT aux_tipconsu                   AND
       glb_nmrotina = "FICHA CADASTRAL"   THEN
       DO:
           /*** nao necessario ao programa somente para nao dar erro 
                de compilacao na rotina de impressao ****/
           FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                    NO-LOCK NO-ERROR.

           { includes/impressao.i } 

           HIDE MESSAGE NO-PAUSE.
       END.

END PROCEDURE.

/* .......................................................................... */
PROCEDURE Busca_Dados:

    DEF VAR h-b1wgen0062 AS HANDLE                                   NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0062) THEN
        RUN sistema/generico/procedures/b1wgen0062.p 
            PERSISTENT SET h-b1wgen0062.
    
    RUN Busca_Impressao IN h-b1wgen0062
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_dtmvtolt,
         OUTPUT TABLE tt-fcad,
         OUTPUT TABLE tt-fcad-telef,
         OUTPUT TABLE tt-fcad-email,
         OUTPUT TABLE tt-fcad-psfis,
         OUTPUT TABLE tt-fcad-filia,
         OUTPUT TABLE tt-fcad-comer,
         OUTPUT TABLE tt-fcad-cbens,
         OUTPUT TABLE tt-fcad-depen,
         OUTPUT TABLE tt-fcad-ctato,
         OUTPUT TABLE tt-fcad-respl,
         OUTPUT TABLE tt-fcad-cjuge,
         OUTPUT TABLE tt-fcad-psjur,
         OUTPUT TABLE tt-fcad-regis,
         OUTPUT TABLE tt-fcad-procu,
         /*OUTPUT TABLE tt-fcad-bensp,*/
         OUTPUT TABLE tt-fcad-refer,
         OUTPUT TABLE tt-fcad-poder,
         OUTPUT TABLE tt-erro ).

    IF  VALID-HANDLE(h-b1wgen0062) THEN
        DELETE PROCEDURE h-b1wgen0062.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Campos:

    DEFINE VARIABLE aux_tpretorn AS CHARACTER   NO-UNDO.
    
    ASSIGN aux_tpretorn = "NOK".

    FIND FIRST tt-fcad-psfis NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-fcad-psfis THEN
        DO:
            FIND FIRST tt-fcad-filia NO-LOCK NO-ERROR.

            FIND FIRST tt-fcad-comer NO-LOCK NO-ERROR.

            FIND FIRST tt-fcad-ctato NO-LOCK NO-ERROR.

            FIND FIRST tt-fcad-cjuge NO-LOCK NO-ERROR.

            FIND FIRST tt-fcad-respl NO-LOCK NO-ERROR.
        END.

    ELSE 
        DO:
            FIND FIRST tt-fcad-psjur NO-LOCK NO-ERROR.
    
            IF  AVAILABLE tt-fcad-psjur THEN
                DO:
                   FIND FIRST tt-fcad-regis NO-LOCK NO-ERROR.
                END. 
        END.

    IF  NOT AVAILABLE tt-fcad-psfis AND NOT AVAILABLE tt-fcad-psjur THEN
        DO:
           MESSAGE "Ficha cadastral nao encontrada.".
           RETURN aux_tpretorn.
        END.

    ASSIGN aux_tpretorn = "OK".

    RETURN aux_tpretorn.

END PROCEDURE.
