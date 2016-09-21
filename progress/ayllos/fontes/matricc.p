/* .............................................................................

   Programa: fontes/matricc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                     Ultima atulizacao: 13/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela MATRIC.

   Alteracoes: 06/09/2006 - Acerto no SETORECONO (Ze).
   
               03/01/2007 - Criticar se associado esta sendo criado em outro
                            terminal, porque nao possui os dados (Evandro).
                            
               19/03/2007 - Corrigir dspessoa ADMINIST (Magui)
               
               01/09/2008 - Alteracao CDEMPRES (Kbase).
               
               08/06/2010 - Adapatado para uso de BO (Jose Luis, DB1)
               
               12/04/2011 - Modificado browser de procuradores para
                            ajuste devido a CEP integrado (André - DB1)
                            
               14/06/2012 - Ajustes referente ao projeto GP - Socios menores
                            (Adriano).
                            
               27/11/2012 - Correçoes em instâncias da BO52 (Lucas).
               
               26/04/2013 - Incluir campo tel_cdufnatu no frame de pessoa fisica
                            (Lucas R.)

               15/05/2014 - Atualizado a leitura do estado civil para os campo
                            tt-crapass.cdestcv2 tt-crapass.dsestcv2. 
                            (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                           (Tiago Castro - RKAM).

               13/08/2014 - Ajustar a busca de nmconjug para ler da tabela tt-crapass
                            carregada na b1wgen52b (Douglas)
                            
               28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                            0 - menor/maior. (Carlos)
                                                        
               13/07/2015 - Reformulacao cadastral (Gabriel-RKAM).             
............................................................................. */

{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ includes/var_online.i }
{ includes/var_matric.i }

DEFINE VARIABLE h-b1wgen0052 AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-b1wgen0060 AS HANDLE      NO-UNDO.
DEFINE VARIABLE aux_idseqttl AS INT         NO-UNDO.
DEFINE VARIABLE aux_permalte AS LOG         NO-UNDO.
DEFINE VARIABLE aux_verrespo AS LOG         NO-UNDO.
DEFINE VARIABLE aux_nrcpfcgc AS DEC         NO-UNDO.

IF  NOT VALID-HANDLE(h-b1wgen0052) THEN
    RUN sistema/generico/procedures/b1wgen0052.p 
        PERSISTENT SET h-b1wgen0052.

RUN Busca_Dados.

IF  RETURN-VALUE <> "OK" OR
    KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    DO:
        IF  VALID-HANDLE(h-b1wgen0052) THEN
            DELETE OBJECT h-b1wgen0052.

        RETURN.

    END.
   
RUN Atualiza_Campos.

IF   tel_inpessoa = 1   THEN
     DO:
         RUN trata_conta_fisica.

         CLEAR FRAME f_matric_juridica.
     END.
ELSE
     DO:
         RUN trata_conta_juridica.

         CLEAR FRAME f_matric.
         CLEAR FRAME f_matric_juridica.
     END.         

ASSIGN glb_cddopcao = "C".

IF  VALID-HANDLE(h-b1wgen0052) THEN
    DELETE OBJECT h-b1wgen0052.

RETURN "OK".

PROCEDURE trata_conta_fisica:
                          
    IF NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p
           PERSISTEN SET h-b1wgen0060.

    DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                     INPUT tel_inhabmen,
                     OUTPUT tel_dshabmen,
                     OUTPUT glb_dscritic).
       
    IF VALID-HANDLE(h-b1wgen0060) THEN
       DELETE OBJECT h-b1wgen0060.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       
       DISPLAY glb_cddopcao  tel_nrdconta  tel_cdagenci  tel_dsagenci  
               tel_nrmatric  tel_inpessoa  tel_dspessoa  tel_nmprimtl  
               dis_nrcpfcgc @ tel_nrcpfcgc
               tel_dtcnscpf  tel_cdsitcpf  tel_dssitcpf  tel_tpdocptl   
               tel_nrdocptl  tel_cdoedptl  tel_cdufdptl  tel_dtemdptl   
               tel_dtnasctl  tel_cdsexotl  tel_tpnacion  tel_restpnac
               tel_dsnacion  tel_dsnatura  tel_cdufnatu  tel_cdestcvl  
               tel_dsestcvl  tel_nmconjug  tel_nrcepend  tel_dsendere  
               tel_nrendere  tel_complend  tel_nmbairro  tel_nrcxapst  
               tel_nmpaittl  tel_nmcidade  tel_cdufende  tel_nmmaettl  
               tel_cdempres  tel_nmresemp  tel_nrcadast  tel_cdocpttl  
               tel_dsocpttl  tel_dtadmiss  tel_dtdemiss  tel_cdmotdem WHEN tel_cdmotdem > 0
               tel_dsmotdem  tel_dthabmen  tel_inhabmen  tel_dshabmen
               WITH FRAME f_matric.
       
       /* exibe mensagens de alerta -  apos display */
       FOR EACH tt-alertas WHERE tt-alertas.tpalerta = "F"
                              BY tt-alertas.cdalerta:
       
           MESSAGE tt-alertas.dsalerta.
       
           IF  tt-alertas.qtdpausa <> 0 THEN
               PAUSE tt-alertas.qtdpausa NO-MESSAGE.
       END.

       PAUSE MESSAGE 
             "Pressione algo para continuar - <F4>/<END> para voltar.".

       IF (tel_inhabmen = 0   AND
           aux_nrdeanos < 18) OR 
           tel_inhabmen = 2   THEN
          DO: 
              ASSIGN glb_nmrotina = "MATRIC".
                     aux_nrcpfcgc = DEC(REPLACE(REPLACE(tel_nrcpfcgc,".",""),
                                    "-","")).

              EMPTY TEMP-TABLE tt-resp.

              RUN fontes/contas_responsavel.p (INPUT "MATRIC_CONS",
                                               INPUT tel_nrdconta,
                                               INPUT aux_idseqttl,
                                               INPUT aux_nrcpfcgc,
                                               INPUT tel_dtnasctl,
                                               INPUT tel_inhabmen,
                                               OUTPUT aux_permalte,
                                               INPUT-OUTPUT TABLE tt-resp). 
       
              /*As variaveis abaixo estao sendo alimentadas
                devido a serem atualizadas dentro do
                contas_responsavel */
              ASSIGN glb_cddopcao = "C"
                     glb_nmrotina = ""
                     tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,
                                    "99999999999"),"XXX.XXX.XXX-XX").
       
          END.

    END.

    RETURN "OK".

END PROCEDURE. /* trata_conta_fisica */

PROCEDURE trata_conta_juridica:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
        DISPLAY glb_cddopcao  tel_nrdconta  tel_cdagenci  tel_dsagenci        
                tel_nrmatric  tel_inpessoa  tel_dspessoa  tel_nmprimtl    
                dis_nrcpfcgc @ tel_nrcpfcgc
                tel_nmfansia  tel_dtcnscpf  tel_cdsitcpf  tel_dssitcpf  
                tel_insestad  tel_natjurid  tel_dsnatjur  tel_dtiniatv  
                tel_cdseteco  tel_nmseteco  tel_cdrmativ  tel_dsrmativ  
                tel_nrtelefo  tel_nrdddtfc  tel_nrcepend  tel_dsendere  
                tel_nrendere  tel_complend  tel_nmbairro  tel_nrcxapst  
                tel_nmcidade  tel_cdufende  tel_dtadmiss  tel_dtdemiss  
                tel_cdmotdem  tel_dsmotdem  
                WITH FRAME f_matric_juridica.
    
       /* exibe mensagens de alerta -  apos display */
        FOR EACH tt-alertas WHERE tt-alertas.tpalerta = "F"
                               BY tt-alertas.cdalerta:
    
            MESSAGE tt-alertas.dsalerta.
    
            IF  tt-alertas.qtdpausa <> 0 THEN
                PAUSE tt-alertas.qtdpausa NO-MESSAGE.
        END.
    
        PAUSE MESSAGE 
             "Pressione algo para continuar - <F4>/<END> para voltar.".
    
        /* Mostra a tela de procuradores */
        RUN fontes/contas_procuradores.p (INPUT "MATRIC",
                                          INPUT tt-crapass.nrdconta,
                                          INPUT "C",
                                          INPUT tt-crapass.nrcpfcgc,
                                          OUTPUT aux_permalte,
                                          OUTPUT aux_verrespo,
                                          OUTPUT TABLE tt-resp,
                                          INPUT-OUTPUT TABLE tt-bens,
                                          INPUT-OUTPUT TABLE tt-crapavt).
    
    END.

    RETURN "OK".

END PROCEDURE. /* trata_conta_juridica */

/* ......................................................................... */

PROCEDURE Busca_Dados:

    ASSIGN glb_cddopcao = "C".

    RUN Busca_Dados IN h-b1wgen0052
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT 1, 
          INPUT YES,
          INPUT glb_cddopcao,
         OUTPUT TABLE tt-crapass,
         OUTPUT TABLE tt-operadoras-celular,
         OUTPUT TABLE tt-crapavt,
         OUTPUT TABLE tt-alertas,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-bens,
         OUTPUT TABLE tt-crapcrl ) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

   /* exibe mensagens de alerta */
    FOR EACH tt-alertas WHERE tt-alertas.tpalerta = "I"
                           BY tt-alertas.cdalerta:

        MESSAGE tt-alertas.dsalerta.

        IF  tt-alertas.qtdpausa <> 0 THEN
            PAUSE tt-alertas.qtdpausa NO-MESSAGE.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Campos:

    FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                          tt-crapass.nrdconta = tel_nrdconta 
                          NO-ERROR.

    IF  NOT AVAILABLE tt-crapass THEN
        DO:
           MESSAGE "Cadastro do Associado nao foi encontrado.".
           RETURN "NOK".
        END.
    ELSE
        DO:
           ASSIGN tel_cdagenci = tt-crapass.cdagenci
                  tel_dsagenci = tt-crapass.nmresage
                  tel_nrmatric = tt-crapass.nrmatric
                  tel_inpessoa = tt-crapass.inpessoa
                  tel_dspessoa = tt-crapass.dspessoa
                  tel_nmprimtl = tt-crapass.nmprimtl
                  tel_dtcnscpf = tt-crapass.dtcnscpf
                  tel_cdsitcpf = tt-crapass.cdsitcpf
                  tel_dssitcpf = tt-crapass.dssitcpf
                  tel_tpdocptl = tt-crapass.tpdocptl
                  tel_nrdocptl = tt-crapass.nrdocptl
                  tel_cdoedptl = tt-crapass.cdoedptl
                  tel_cdufdptl = tt-crapass.cdufdptl
                  tel_dtemdptl = tt-crapass.dtemdptl
                  tel_dtnasctl = tt-crapass.dtnasctl
                  tel_cdsexotl = (IF tt-crapass.cdsexotl = 1 THEN "M" ELSE "F")
                  tel_tpnacion = tt-crapass.tpnacion
                  tel_restpnac = tt-crapass.destpnac
                  tel_dsnacion = tt-crapass.dsnacion
                  tel_dsnatura = tt-crapass.dsnatura
                  tel_cdufnatu = tt-crapass.cdufnatu
                  tel_cdestcvl = tt-crapass.cdestcv2
                  tel_dsestcvl = tt-crapass.dsestcv2
                  tel_nmconjug = tt-crapass.nmconjug
                  tel_nrcepend = tt-crapass.nrcepend
                  tel_dsendere = tt-crapass.dsendere
                  tel_nrendere = tt-crapass.nrendere
                  tel_complend = tt-crapass.complend
                  tel_nmbairro = tt-crapass.nmbairro
                  tel_nmcidade = tt-crapass.nmcidade
                  tel_cdufende = tt-crapass.cdufende
                  tel_nrcxapst = tt-crapass.nrcxapst
                  tel_nmpaittl = tt-crapass.nmpaittl
                  tel_nmmaettl = tt-crapass.nmmaettl
                  tel_cdempres = tt-crapass.cddempre
                  tel_nmresemp = tt-crapass.nmresemp
                  tel_nrcadast = tt-crapass.nrcadast
                  tel_cdocpttl = tt-crapass.cdocpttl
                  tel_dsocpttl = tt-crapass.dsocpttl
                  tel_dtadmiss = tt-crapass.dtadmiss
                  tel_dtdemiss = tt-crapass.dtdemiss
                  tel_cdmotdem = tt-crapass.cdmotdem
                  tel_dsmotdem = tt-crapass.dsmotdem
                  tel_nmfansia = tt-crapass.nmfansia
                  tel_insestad = tt-crapass.nrinsest
                  tel_natjurid = tt-crapass.natjurid
                  tel_dsnatjur = tt-crapass.rsnatjur
                  tel_dtiniatv = tt-crapass.dtiniatv
                  tel_cdseteco = tt-crapass.cdseteco
                  tel_nmseteco = tt-crapass.nmseteco
                  tel_cdrmativ = tt-crapass.cdrmativ
                  tel_dsrmativ = tt-crapass.dsrmativ
                  tel_nrtelefo = tt-crapass.nrtelefo
                  tel_nrdddtfc = tt-crapass.nrdddtfc
                  tel_dthabmen = tt-crapass.dthabmen
                  tel_inhabmen = tt-crapass.inhabmen
                  aux_nrdeanos = tt-crapass.nrdeanos
                  aux_idseqttl = tt-crapass.idseqttl.

           IF  tel_inpessoa = 1 THEN
               ASSIGN dis_nrcpfcgc = STRING(STRING(tt-crapass.nrcpfcgc,
                                                   "99999999999"),
                                            "xxx.xxx.xxx-xx").
           ELSE ASSIGN dis_nrcpfcgc = STRING(STRING(tt-crapass.nrcpfcgc,
                                                    "99999999999999"),
                                             "xx.xxx.xxx/xxxx-xx").
        END.

    RETURN "OK".

END PROCEDURE.


