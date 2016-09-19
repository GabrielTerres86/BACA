/* .............................................................................

   Programa: Fontes/matrica.p.
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Abril/2006                      Ultima atualizacao: 13/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de alteracao da tela MATRIC.
   
   Observacao: As includes "criticas_dados_matrica.i" e 
               "cadastra_dados_matrica.i" sao usadas para a validacao e
               atualizacao dos dados, porem a "cadastra_dados_matrica.i" prende
               o registro da tabela "crapmat" portanto deve ser uma das ultimas
               rotinas a serem executadas.

   Alteracoes: 26/07/2006 - Incluido zoom no campo crapass.cdempres (David).
   
               06/09/2006 - Corrigida a atualizacao do telefone - pessoa
                            juridica (Evandro) - Acerto SETORECONO (Ze).
                            
               16/10/2006 - Criticar quando nome da mae e pai foram iguais (Ze)
               
               19/03/2007 - Corrigir dspessoa ADMINIST (Magui).

               03/08/2007 - Nao permitir reativar uma conta se ja tiver uma
                            conta salario ativa com o mesmo CPF (Evandro).
                            
               20/05/2008 - Alterada a chamada das Naturalidades (Evandro).
               
               07/07/2008 - Retirada verificacao na craptab "EMPRESINOP",
                            critica 558 - Empresa nao e conveniada (Diego).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               29/01/2009 - Alimentar o crapass.cdempres (Ze).

               02/09/2009 - Zerar variaveis aux_cdempres e aux_cdempres2 para
                            evitar alteracao errada na tabela crapepr
                            quando pessoa juridica (Gabriel).
                            
               21/06/2010 - Adapatado para uso de BO (Jose Luis, DB1).
               
               02/02/2011 - Incluido verificaçao de Produtos e Serviços ativos
                            do cooperado quando for demitido. (Jorge)
                
               12/04/2011 - Inclusao de CEP integrado e browser procuradores
                            alterado para só aparecer na saída do último                            
                            campo. (André - DB1)
                            
               15/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).   
                            
               29/04/2013 - Incluir campo tel_cdufnatu em tela e ajusta para 
                            validar e gravar (Lucas R.)

               15/05/2014 - Atualizado a leitura do estado civil para os campo
                            tt-crapass.cdestcv2 tt-crapass.dsestcv2. 
                            (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                           (Tiago Castro - RKAM).

               13/08/2014 - Ajustar a busca de nmconjug para ler da tabela tt-crapass
                            carregada na b1wgen52b (Douglas)

               28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                             0 - menor/maior. (Carlos)
                             
               02/03/2015 - Instanciar BO 52a antes de chamar. 
                            Chamado 260514. (Jonata-RKAM).  
                            
               13/07/2015 - Reformulacao cadastral (Gabriel-RKAM).     
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
			   
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de 
			                Transferencia entre PAs (Heitor - RKAM)
............................................................................. */

{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ includes/var_online.i }
{ includes/var_matric.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM 
    &TELA-MATRIC=SIM &TELA-CONTAS=NAO }

DEF      VAR aux_nmdcampo AS CHAR                                     NO-UNDO.
DEF      VAR aux_nmsegntl AS CHAR                                     NO-UNDO.
DEF      VAR aux_cdtipcta AS INTE                                     NO-UNDO.
DEF      VAR aux_dsproftl AS CHAR                                     NO-UNDO.
DEF      VAR aux_dtcadass AS DATE                                     NO-UNDO.
DEF      VAR aux_msgretor AS CHAR                                     NO-UNDO.
DEF      VAR aux_inmatric AS INTE                                     NO-UNDO.
DEF      VAR aux_rowidass AS ROWID                                    NO-UNDO.
DEF      VAR aux_dtmvtoan AS DATE                                     NO-UNDO.
DEF      VAR aux_dtdebito AS DATE                                     NO-UNDO.
DEF      VAR aux_vlparcel AS DECI                                     NO-UNDO.
DEF      VAR aux_qtparcel AS INTE                                     NO-UNDO.
DEF      VAR aux_nmdsecao AS CHAR                                     NO-UNDO.
DEF      VAR aux_idseqttl AS INT                                      NO-UNDO.
DEF      VAR aux_permalte AS LOG                                      NO-UNDO.
DEF      VAR aux_verrespo AS LOG                                      NO-UNDO.
DEF      VAR aux_nrcpfcgc AS CHAR FORMAT "X(18)"                      NO-UNDO.
DEF      VAR aux_nrctanov AS INTE                                     NO-UNDO.

DEF      VAR h-b1wgen0052 AS HANDLE                                   NO-UNDO.
DEF      VAR h-b1wgen0060 AS HANDLE                                   NO-UNDO.
DEF      VAR h-b1wgen9999 AS HANDLE                                   NO-UNDO.

BLOCO_1:
DO ON ENDKEY UNDO, LEAVE
   ON ERROR  UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0052) THEN
       RUN sistema/generico/procedures/b1wgen0052.p 
           PERSISTENT SET h-b1wgen0052.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.
               
   RUN Busca_Dados.
    
   IF  RETURN-VALUE <> "OK" THEN
       DO:
           IF VALID-HANDLE(h-b1wgen0052) THEN
              DELETE OBJECT h-b1wgen0052.

           IF VALID-HANDLE(h-b1wgen0060) THEN
              DELETE OBJECT h-b1wgen0060.

           RETURN "NOK".

       END.

   RUN Atualiza_Campos.

   IF  RETURN-VALUE <> "OK" THEN
       DO:
          IF VALID-HANDLE(h-b1wgen0052) THEN
              DELETE OBJECT h-b1wgen0052.

          IF VALID-HANDLE(h-b1wgen0060) THEN
             DELETE OBJECT h-b1wgen0060.

           RETURN "NOK".

       END.

   /* Tratamento por tipo de pessoa */
   IF   tel_inpessoa = 1   THEN 
        RUN trata_conta_fisica.
   ELSE
        RUN trata_conta_juridica.
        
        
   IF   RETURN-VALUE = "NOK"   THEN
        UNDO BLOCO_1, LEAVE BLOCO_1.
 
END. /* Fim do bloco */

CLEAR FRAME f_matric.
CLEAR FRAME f_matric_juridica.     

glb_cddopcao = "A".

IF VALID-HANDLE(h-b1wgen0052) THEN
   DELETE OBJECT h-b1wgen0052.

IF VALID-HANDLE(h-b1wgen0060) THEN
   DELETE OBJECT h-b1wgen0060.

PROCEDURE trata_conta_fisica: 
    
    DISPLAY glb_cddopcao  tel_nrdconta  tel_cdagenci  tel_dsagenci  
            tel_nrmatric  tel_inpessoa  tel_dspessoa  tel_nmprimtl  
            dis_nrcpfcgc @ tel_nrcpfcgc
            tel_dtcnscpf  tel_cdsitcpf  tel_dssitcpf  tel_tpdocptl   
            tel_nrdocptl  tel_cdoedptl  tel_cdufdptl  tel_dtemdptl   
            tel_dtnasctl  tel_cdsexotl  tel_tpnacion  tel_restpnac
            tel_dsnacion  tel_dsnatura  tel_cdufnatu  tel_inhabmen  
            tel_dshabmen  tel_dthabmen  tel_cdestcvl  tel_dsestcvl   
            tel_nmconjug  tel_nrcepend  tel_dsendere  tel_nrendere   
            tel_complend  tel_nmbairro  tel_nmcidade  tel_cdufende        
            tel_nrcxapst  tel_nmpaittl  tel_nmmaettl  tel_cdempres    
            tel_nmresemp  tel_nrcadast  tel_cdocpttl  tel_dsocpttl
            tel_dtadmiss  tel_dtdemiss  tel_cdmotdem 
            tel_dsmotdem  WITH FRAME f_matric.
       
    DO WHILE TRUE:
       
       ASSIGN aux_verrespo = FALSE
              tel_inhabmen:READ-ONLY IN FRAME f_matric = FALSE
              tel_dthabmen:READ-ONLY IN FRAME f_matric = FALSE.

       UPDATE tel_dtdemiss  
              tel_cdmotdem  WITH FRAME f_matric
              
       EDITING:
          READKEY.
          
          HIDE MESSAGE NO-PAUSE.
                   
          IF   LASTKEY = KEYCODE("F7") THEN
               DO:
                   IF   FRAME-FIELD = "tel_cdmotdem"   THEN
                        DO:
                            RUN fontes/zoom_motivo_demissao.p 
                                     (INPUT  glb_cdcooper,
                                      OUTPUT tel_cdmotdem,
                                      OUTPUT tel_dsmotdem).
                            DISPLAY tel_cdmotdem 
                                    tel_dsmotdem WITH FRAME f_matric.
                        END.
               END. /* Fim do F7 */
          ELSE
          IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
               UNDO, LEAVE.
          ELSE
               APPLY LASTKEY.

          IF  GO-PENDING THEN
              DO: 
                 RUN Valida_Dados.

                 IF  RETURN-VALUE <> "OK" THEN
                     DO:
                        IF aux_nmdcampo = "dthabmen" THEN
                           DO:
                              ASSIGN tel_dthabmen:READ-ONLY IN 
                                     FRAME f_matric = FALSE.

                              ASSIGN INPUT tel_dthabmen.

                           END.


                        {sistema/generico/includes/foco_campo.i &VAR-GERAL=SIM 
                            &NOME-FRAME="f_matric"
                            &NOME-CAMPO=aux_nmdcampo }
                      END.
              END.

       END.  /*  Fim do EDITING  */

       ASSIGN aux_nrcpfcgc = STRING(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","")).

       IF (tel_inhabmen = 0   AND
           aux_nrdeanos < 18) OR 
           tel_inhabmen = 2   THEN
          DO:  
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
              ASSIGN glb_cddopcao = "A"
                     glb_nmrotina = ""
                     aux_verrespo = TRUE
                     tel_nrcpfcgc = STRING(STRING(aux_nrcpfcgc,
                                    "99999999999"),"XXX.XXX.XXX-XX").
       
          END.

          RUN Valida_Dados.
          
          IF RETURN-VALUE = "NOK" THEN
            NEXT.
       

       RUN Confirma.

       IF  aux_confirma = "S" THEN
           DO:
               RUN Grava_Dados.
               
               IF  RETURN-VALUE <> "OK" THEN
                   NEXT.
           END.

       LEAVE.

    END. /* WHILE */
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE trata_conta_juridica:

    DISPLAY glb_cddopcao  tel_nrdconta  tel_cdagenci  tel_dsagenci   
            tel_nrmatric  tel_inpessoa  tel_dspessoa  tel_nmprimtl  
            tel_nmfansia  dis_nrcpfcgc @ tel_nrcpfcgc tel_dtcnscpf  
            tel_cdsitcpf  tel_dssitcpf  tel_insestad  tel_natjurid  
            tel_dsnatjur  tel_dtiniatv  tel_cdseteco  tel_nmseteco  
            tel_cdrmativ  tel_dsrmativ  tel_nrdddtfc  tel_nrtelefo  
            tel_nrcepend  tel_dsendere  tel_nrendere  tel_complend  
            tel_nmbairro  tel_nmcidade  tel_cdufende  tel_nrcxapst  
            tel_dtadmiss  tel_dtdemiss  tel_cdmotdem  tel_dsmotdem
            WITH FRAME f_matric_juridica.

    FOR EACH tt-alertas BY tt-alertas.cdalerta:
       
        MESSAGE tt-alertas.dsalerta.

        IF tt-alertas.qtdpausa <> 0 THEN
           PAUSE tt-alertas.qtdpausa NO-MESSAGE.

    END.

    DO WHILE TRUE:
    
       /* Deixar a opcao como "A" pois pode ter mudado nos procuradores */
       ASSIGN glb_cddopcao = "A"
              aux_verrespo = FALSE
              aux_nrcpfcgc = "".

       DISPLAY glb_cddopcao WITH FRAME f_matric_juridica.

       UPDATE tel_dtdemiss   tel_cdmotdem
              WITH FRAME f_matric_juridica
              
       EDITING:

          READKEY.
          HIDE MESSAGE NO-PAUSE.
          
          IF  LASTKEY = KEYCODE("F7") THEN
              DO:                                  
                IF  FRAME-FIELD = "tel_cdmotdem"   THEN
                     DO:
                        RUN fontes/zoom_motivo_demissao.p 
                            ( INPUT  glb_cdcooper,
                             OUTPUT tel_cdmotdem,
                             OUTPUT tel_dsmotdem ).

                        DISPLAY 
                            tel_cdmotdem 
                            tel_dsmotdem 
                            WITH FRAME f_matric_juridica.
                     END.
              END. /* Fim do F7 */
          ELSE
          IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
               UNDO, LEAVE.
          ELSE
               APPLY LASTKEY.

          IF  GO-PENDING THEN
              DO:
                 RUN Valida_Dados.
    
                 IF  RETURN-VALUE <> "OK" THEN
                     DO:
                        {sistema/generico/includes/foco_campo.i &VAR-GERAL=SIM
                            &NOME-FRAME="f_matric_juridica"
                            &NOME-CAMPO=aux_nmdcampo }
                      END.
              END.
       END.  /*  Fim do EDITING  */

       ASSIGN aux_nrcpfcgc = tel_nrcpfcgc.

       /* Mostra a tela de procuradores */
       RUN fontes/contas_procuradores.p (INPUT "MATRIC",
                                         INPUT tt-crapass.nrdconta,
                                         INPUT "C", /* So consulta */
                                         INPUT tt-crapass.nrcpfcgc,
                                         OUTPUT aux_permalte,
                                         OUTPUT aux_verrespo,
                                         OUTPUT TABLE tt-resp,
                                         INPUT-OUTPUT TABLE tt-bens,
                                         INPUT-OUTPUT TABLE tt-crapavt).

       /*As variaveis abaixo estao sendo alimentadas
         devido a serem atualizadas dentro do
         contas_procuradores */
       ASSIGN glb_cddopcao = "A"
              glb_nmrotina = ""
              tel_nrcpfcgc = STRING(REPLACE(REPLACE(
                             aux_nrcpfcgc,".",""),"-","")).
                     
       RUN Valida_Procurador.
        
       IF  RETURN-VALUE <> "OK" THEN
           NEXT.

       RUN Valida_Dados.
        
       IF  RETURN-VALUE <> "OK" THEN
           NEXT.
              
       RUN Confirma. 

       IF aux_confirma = "S" THEN
          DO:
              RUN Grava_Dados.

              IF RETURN-VALUE <> "OK" THEN
                 NEXT.

          END.

       LEAVE.

    END.
 
    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */

PROCEDURE Busca_Dados:

    ASSIGN glb_cddopcao = "A".

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
         OUTPUT TABLE  tt-operadoras-celular,
         OUTPUT TABLE tt-crapavt,
         OUTPUT TABLE tt-alertas,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-bens,
         OUTPUT TABLE tt-crapcrl ) .
    
    IF ERROR-STATUS:ERROR THEN
       DO:
          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          RETURN "NOK".
       END.

   /* exibe mensagens de alerta */
    FOR EACH tt-alertas WHERE tt-alertas.tpalerta = "I"
                           BY tt-alertas.cdalerta:
        
        MESSAGE tt-alertas.dsalerta.

        ON F4  BELL.
        ON END BELL.

        IF tt-alertas.qtdpausa <> 0 THEN
           PAUSE tt-alertas.qtdpausa NO-MESSAGE.

    END.

    ON F4  END-ERROR.
    ON END END-ERROR.
    
    IF RETURN-VALUE <> "OK"           OR 
       TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                MESSAGE tt-erro.dscritic.
                RETURN "NOK".

             END.

       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Atualiza_Campos:
   
    FIND tt-crapass WHERE tt-crapass.cdcooper = glb_cdcooper AND
                          tt-crapass.nrdconta = tel_nrdconta 
                          NO-ERROR.

    IF NOT AVAILABLE tt-crapass THEN
       DO:
          MESSAGE "Cadastro do Associado nao foi encontrado.".
          RETURN "NOK".

       END.
    ELSE
       DO: 
           ASSIGN tel_cdagenci = tt-crapass.cdagenci
                  tel_dsagenci = tt-crapass.nmresage
                  tel_nrcpfcgc = (IF tt-crapass.inpessoa = 1 THEN 
                                    STRING(STRING(tt-crapass.nrcpfcgc,"99999999999"),
                                    "xxx.xxx.xxx-xx")
                                  ELSE
                                    STRING(STRING(tt-crapass.nrcpfcgc,"99999999999999"),
                                           "xx.xxx.xxx/xxxx-xx"))
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
                  aux_dsproftl = tt-crapass.dsproftl
                  aux_nmsegntl = tt-crapass.nmsegntl
                  aux_cdtipcta = tt-crapass.cdtipcta
                  aux_dtcadass = tt-crapass.dtmvtolt
                  aux_inmatric = tt-crapass.inmatric
                  aux_dtmvtoan = tt-crapass.dtmvtoan
                  aux_rowidass = tt-crapass.rowidass
                  aux_nrdeanos = tt-crapass.nrdeanos
                  aux_idseqttl = tt-crapass.idseqttl
                  tel_dthabmen = tt-crapass.dthabmen
                  tel_inhabmen = tt-crapass.inhabmen
                  aux_nrdeanos = tt-crapass.nrdeanos
                  dis_nrcpfcgc = tel_nrcpfcgc
                  aux_nmttlrfb = tt-crapass.nmttlrfb
                  aux_inconrfb = tt-crapass.inconrfb.

           DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                            INPUT tel_inhabmen,
                            OUTPUT tel_dshabmen,
                            OUTPUT glb_dscritic).
           
       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Dados:

    ASSIGN glb_cddopcao = "A".

    IF  tel_inpessoa = 1 THEN
        DO WITH FRAME f_matric:
    
            ASSIGN INPUT tel_dtcnscpf INPUT tel_cdsitcpf  
                   INPUT tel_tpdocptl INPUT tel_nrdocptl  
                   INPUT tel_cdoedptl INPUT tel_cdufdptl  
                   INPUT tel_dtemdptl INPUT tel_nmmaettl 
                   INPUT tel_nmpaittl INPUT tel_dtnasctl
                   INPUT tel_cdsexotl INPUT tel_tpnacion  
                   INPUT tel_dsnacion INPUT tel_dsnatura 
                   INPUT tel_cdufnatu INPUT tel_inhabmen 
                   INPUT tel_dthabmen
                   INPUT tel_cdestcvl INPUT tel_nmconjug  
                   INPUT tel_nrcepend INPUT tel_dsendere  
                   INPUT tel_nrendere INPUT tel_complend  
                   INPUT tel_nmbairro INPUT tel_nmcidade  
                   INPUT tel_cdufende INPUT tel_nrcxapst  
                   INPUT tel_cdempres INPUT tel_nrcadast  
                   INPUT tel_cdocpttl INPUT tel_dsocpttl
                   INPUT tel_dtadmiss INPUT tel_dtdemiss
                   INPUT tel_cdmotdem. 

        END.
    ELSE
        DO WITH FRAME f_matric_juridica:

            ASSIGN tel_nmfansia   tel_dtcnscpf   
                   tel_cdsitcpf   tel_insestad   
                   tel_natjurid   tel_dtiniatv   
                   tel_cdseteco   tel_cdrmativ   
                   tel_nrdddtfc   tel_nrtelefo   
                   tel_nrcepend   tel_dsendere   
                   tel_nrendere   tel_complend   
                   tel_nmbairro   tel_nmcidade   
                   tel_cdufende   tel_nrcxapst   
                   tel_dtdemiss   tel_cdmotdem.

        END.

   IF  NOT VALID-HANDLE(h-b1wgen0052) THEN
       RUN sistema/generico/procedures/b1wgen0052.p 
           PERSISTENT SET h-b1wgen0052.

    RUN Valida_Dados IN h-b1wgen0052 
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT 1,           
          INPUT TRUE,        
          INPUT glb_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT tel_inpessoa,
          INPUT tel_cdagenci,
          INPUT STRING(dis_nrcpfcgc),
          INPUT tel_nmprimtl,
          INPUT aux_dtcadass,
          INPUT aux_nmsegntl,
          INPUT tel_nmpaittl,
          INPUT tel_nmmaettl,
          INPUT tel_nmconjug,
          INPUT tel_cdempres,
          INPUT (IF tel_cdsexotl = "M" THEN 1 
                 ELSE IF tel_cdsexotl = "F" THEN 2 ELSE 0), 
          INPUT tel_cdsitcpf, 
          INPUT aux_cdtipcta, 
          INPUT tel_dtcnscpf, 
          INPUT tel_dtnasctl, 
          INPUT tel_tpnacion, 
          INPUT tel_dsnacion, 
          INPUT tel_dsnatura,
          INPUT tel_cdufnatu,
          INPUT tel_cdocpttl, 
          INPUT tel_cdestcvl, 
          INPUT aux_dsproftl, 
          INPUT tel_nrcadast, 
          INPUT tel_tpdocptl, 
          INPUT tel_nrdocptl, 
          INPUT tel_cdoedptl, 
          INPUT tel_cdufdptl, 
          INPUT tel_dtemdptl, 
          INPUT tel_dtdemiss, 
          INPUT tel_cdmotdem, 
          INPUT tel_cdufende, 
          INPUT tel_dsendere, 
          INPUT tel_nrendere, 
          INPUT tel_nmbairro, 
          INPUT tel_nmcidade, 
          INPUT tel_complend, 
          INPUT tel_nrcepend, 
          INPUT tel_nrcxapst, 
          INPUT tel_dtiniatv, 
          INPUT tel_natjurid, 
          INPUT tel_nmfansia, 
          INPUT tel_insestad, 
          INPUT tel_cdseteco, 
          INPUT tel_cdrmativ, 
          INPUT tel_nrdddtfc, 
          INPUT tel_nrtelefo, 
          INPUT aux_inmatric, 
          INPUT (IF tel_inpessoa = 1 THEN 
                    FALSE
                 ELSE 
                    TRUE ),
          INPUT aux_verrespo,
          INPUT aux_permalte,
          INPUT tel_inhabmen,
          INPUT tel_dthabmen,
          INPUT TABLE tt-crapavt,
          INPUT TABLE tt-crapcrl,
         OUTPUT aux_nrctanov,
         OUTPUT aux_qtparcel,
         OUTPUT aux_vlparcel,
         OUTPUT aux_nmdcampo,
         OUTPUT aux_msgretor,
         OUTPUT aux_nrdeanos,
         OUTPUT aux_nrdmeses,
         OUTPUT aux_dsdidade,
         OUTPUT TABLE tt-alertas,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-prod_serv_ativos) NO-ERROR .
    
    IF  VALID-HANDLE(h-b1wgen0052) THEN
        DELETE OBJECT h-b1wgen0052.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO: 
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.

           RETURN "NOK".
        END.
         
    /*produtos e servicos ativos*/
    IF  TEMP-TABLE tt-prod_serv_ativos:HAS-RECORDS THEN
        DO:                            
            RUN fontes/visualiza_produtos_servicos.p
                (INPUT TABLE tt-prod_serv_ativos).
        END.

    IF  aux_msgretor <> "" AND NOT(aux_msgretor BEGINS "078") THEN
        DO:
           MESSAGE aux_msgretor.
           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               PAUSE.
               LEAVE.
           END.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Procurador:

    ASSIGN glb_cddopcao = "A".

    IF  NOT VALID-HANDLE(h-b1wgen0052) THEN
        RUN sistema/generico/procedures/b1wgen0052.p 
           PERSISTENT SET h-b1wgen0052.

    RUN Valida_Procurador IN h-b1wgen0052 
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT 1,           
          INPUT TRUE,        
          INPUT glb_dtmvtolt,
          INPUT TABLE tt-crapavt,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro) NO-ERROR.

    IF  VALID-HANDLE(h-b1wgen0052) THEN
        DELETE OBJECT h-b1wgen0052.

    IF  ERROR-STATUS:ERROR THEN
        DO:                
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           READKEY.
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:   
                  MESSAGE tt-erro.dscritic.
                  
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      PAUSE.
                      LEAVE.
                  END.

                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Grava_Dados:

    ASSIGN glb_cddopcao = "A".

   IF VALID-HANDLE(h-b1wgen0052) THEN
      DELETE OBJECT h-b1wgen0052.

   RUN sistema/generico/procedures/b1wgen0052.p 
       PERSISTENT SET h-b1wgen0052.
        
         RUN Grava_Dados IN h-b1wgen0052 
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT 1,            
          INPUT TRUE,         
          INPUT glb_cddopcao, 
          INPUT glb_dtmvtolt,
          INPUT aux_dtmvtoan,
          INPUT aux_rowidass,
          INPUT tel_inpessoa, 
          INPUT tel_cdagenci,
          INPUT DEC(REPLACE(REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-",""),"/","")),
          INPUT tel_nmprimtl,
          INPUT tel_nmpaittl,
          INPUT tel_nmmaettl,
          INPUT tel_nmconjug,
          INPUT tel_cdempres,            
          INPUT (IF tel_cdsexotl = "M" THEN 1 ELSE 2),
          INPUT tel_cdsitcpf,
          INPUT tel_dtcnscpf,
          INPUT tel_dtnasctl,
          INPUT tel_tpnacion,
          INPUT tel_dsnacion,
          INPUT tel_dsnatura,
          INPUT tel_cdufnatu,
          INPUT tel_cdocpttl,
          INPUT ?,  /******************/
          INPUT "", /******************/
          INPUT 0,  /******************/
          INPUT 0,  /* Campos somente */ 
          INPUT 0,  /* No Ayllos Web */  
          INPUT 0,  /******************/                     
          INPUT 0,  /******************/
          INPUT 0,  /******************/
          INPUT tel_cdestcvl,
          INPUT aux_dsproftl,
          INPUT aux_nmdsecao,
          INPUT tel_nrcadast,
          INPUT tel_tpdocptl,
          INPUT tel_nrdocptl,
          INPUT tel_cdoedptl,
          INPUT tel_cdufdptl,
          INPUT tel_dtemdptl,
          INPUT tel_dtdemiss,
          INPUT tel_cdmotdem,
          INPUT tel_cdufende,
          INPUT tel_dsendere,
          INPUT tel_nrendere,
          INPUT tel_nmbairro,
          INPUT tel_nmcidade,
          INPUT tel_complend,
          INPUT tel_nrcepend,
          INPUT tel_nrcxapst,
          INPUT tel_dtiniatv,
          INPUT tel_natjurid,
          INPUT tel_nmfansia,
          INPUT tel_insestad,
          INPUT tel_cdseteco,
          INPUT tel_cdrmativ,
          INPUT tel_nrdddtfc,
          INPUT tel_nrtelefo,
          INPUT ?,
          INPUT 0,
          INPUT 0,
          INPUT tel_inhabmen,
          INPUT tel_dthabmen,
          INPUT aux_nmttlrfb,
          INPUT aux_inconrfb,
          INPUT 0,
          INPUT TABLE tt-crapavt,
          INPUT TABLE tt-resp,
          INPUT TABLE tt-bens,
          2, /** Campo apenas no Ayllos Web **/
          0, /** Campo apenas no Ayllos Web **/
         OUTPUT aux_msgretor,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrecad,
         OUTPUT TABLE tt-erro) NO-ERROR.

    IF VALID-HANDLE(h-b1wgen0052) THEN
       DELETE OBJECT h-b1wgen0052.
    
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

   /* trata a critica 401 */
   IF aux_msgrecad <> "" THEN
      DO:
         ASSIGN aux_confirma = "N".
         MESSAGE aux_msgrecad UPDATE aux_confirma.
      END.
   ELSE
      ASSIGN aux_confirma = "S".
    
   IF aux_confirma = "S" THEN
      /* verificar se é necessario registrar o crapalt */
      RUN proc_altcad (INPUT "b1wgen0052.p").

   IF RETURN-VALUE <> "OK" THEN
      RETURN "NOK".
   
    RETURN "OK".

END PROCEDURE.

PROCEDURE Confirma:

    RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

    IF   aux_confirma <> "S"   THEN
         RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE Limpa_Endereco:

    DEF INPUT PARAM aux_tpform AS INTE                               NO-UNDO.

    ASSIGN tel_nrcepend = 0  
           tel_dsendere = ""  
           tel_nmbairro = "" 
           tel_nmcidade = ""  
           tel_cdufende = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nrcxapst = 0.

    IF aux_tpform = 1 THEN
       DISPLAY tel_nrcepend  tel_dsendere
               tel_nmbairro  tel_nmcidade
               tel_cdufende  tel_nrendere
               tel_complend  tel_nrcxapst 
               WITH FRAME f_matric.
    ELSE
       IF aux_tpform = 2 THEN
           DISPLAY tel_nrcepend  tel_dsendere
                   tel_nmbairro  tel_nmcidade
                   tel_cdufende  tel_nrendere
                   tel_complend  tel_nrcxapst 
                   WITH FRAME f_matric_juridica.

END PROCEDURE.



