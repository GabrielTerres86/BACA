/* .............................................................................

   Programa: Fontes/matricx.p.
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                      Ultima atualizacao: 05/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitel alterar o NOME/RAZAO SOCIAL e o CPF/CNPJ.

   Alteracoes: 06/09/2006 - Acerto no SETORECONO (Ze).

               29/09/2006 - Proibir caracter invalido na razao social (Magui).
               
               10/11/2006 - Verifica se CPF esta cadastrado na Conta Sal. (Ze).
               
               19/03/2007 - Corrigir dspessoa ADMINIST (Magui).

               03/08/2007 - Nao permitir trocar CPF para um CPF que ja tiver
                            uma conta salario ativa (Evandro).
                            
               06/09/2007 - Alimentar campo crapjur.nmextttl do crapass.nmprimtl
                            (Guilherme).
                            
               18/10/2007 - Atualizar crapavt.nrcpfcgc quando for alterado
                            numero do CPF e a conta estiver cadastrada como
                            Representante/Procurador (Diego).
                            
               07/11/2007 - Atualizar os campos alterados somente apos confirmar
                            a operacao em ambas procedures(fisica e juridica)
                            (Diego).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).            
               
               15/07/2010 - Adapatado para uso de BO (Jose Luis, DB1)
               
               16/02/2011 - Incluir parametro tt-prod_serv_ativos na procedure
                            Valida_Dados (David).
                            
               12/04/2011 - Nao mostrar mais browser procuradores devido a 
                            alteraçao em tela necessária ao CEP integrado.
                            (André - DB1)       
                            
               15/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).   
                            
               09/08/2013 - Adicionado parametro cdufnatu. (Reinert)  
               
               08/05/2014 - Adicionado solicitacao de senha do coordenador.
                            (Douglas)                             
               
               15/05/2014 - Atualizado a leitura do estado civil para os campo
                            tt-crapass.cdestcv2 tt-crapass.dsestcv2. 
                            (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Tiago Castro - RKAM).

               13/08/2014 - Ajustar a busca de nmconjug para ler da tabela tt-crapass
                            carregada na b1wgen52b (Douglas)
                            
               28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                            0 - menor/maior. (Carlos)
                            
               13/07/2015 - Reformulacao cadastral (Gabriel-RKAM)     
               
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
               
               05/10/2015 - Adicionado nova opção "J" para alteração apenas do cpf/cnpj e 
                             removido a possibilidade de alteração pela opção "X", conforme 
                             solicitado no chamado 321572 (Kelvin).
				
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)
............................................................................. */

{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/b1wgen0070tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ includes/var_online.i }
{ includes/var_matric.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM 
    &TELA-MATRIC=SIM &TELA-CONTAS=NAO}

DEF      VAR aux_nrmatric AS INT  FORMAT "zzz,zz9"                   NO-UNDO.
DEF      VAR aux_dtdemsoc AS DATE FORMAT "99/99/9999"                NO-UNDO.
DEF      VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
DEF      VAR aux_dtcadass AS DATE                                    NO-UNDO.
DEF      VAR aux_msgretor AS CHAR                                    NO-UNDO.
DEF      VAR aux_inmatric AS INTE                                    NO-UNDO.
DEF      VAR aux_rowidass AS ROWID                                   NO-UNDO.
DEF      VAR aux_dtmvtoan AS DATE                                    NO-UNDO.
DEF      VAR aux_nmsegntl AS CHAR                                    NO-UNDO.
DEF      VAR aux_cdtipcta AS INTE                                    NO-UNDO.
DEF      VAR aux_dsproftl AS CHAR                                    NO-UNDO.
DEF      VAR aux_nmdsecao AS CHAR                                    NO-UNDO.
DEF      VAR aux_permalte AS LOG                                     NO-UNDO.
DEF      VAR aux_verrespo AS LOG                                     NO-UNDO.
DEF      VAR aux_idseqttl AS INT                                     NO-UNDO.
DEF      VAR aux_nrctanov AS INTE                                    NO-UNDO.

/* Validacao da senha do coordenador */
DEF      VAR aut_flgsenha AS LOGICAL                                 NO-UNDO.
DEF      VAR aut_cdoperad AS CHAR                                    NO-UNDO.

DEF      VAR h-b1wgen0052 AS HANDLE                                  NO-UNDO.


IF NOT VALID-HANDLE(h-b1wgen0052) THEN
   RUN sistema/generico/procedures/b1wgen0052.p 
       PERSISTENT SET h-b1wgen0052.

RUN Busca_Dados.
 
IF RETURN-VALUE <> "OK" THEN
   DO:
      IF VALID-HANDLE(h-b1wgen0052) THEN
         DELETE OBJECT h-b1wgen0052.

      RETURN "NOK".

   END.

RUN Atualiza_Campos.

IF RETURN-VALUE <> "OK" THEN
   DO:
       IF VALID-HANDLE(h-b1wgen0052) THEN
          DELETE OBJECT h-b1wgen0052.
   
       RETURN "NOK".

   END.
 
TRANS_1:

DO ON ENDKEY UNDO, LEAVE
   ON ERROR  UNDO TRANS_1, LEAVE TRANS_1:

   /* Tratamento por tipo de pessoa */
   IF tel_inpessoa = 1   THEN         
      RUN trata_conta_fisica.
   ELSE
      RUN trata_conta_juridica.
      
   IF RETURN-VALUE = "NOK"   THEN
      UNDO TRANS_1, LEAVE.
 
END. /* Fim da transacao */

CLEAR FRAME f_matric.
CLEAR FRAME f_matric_juridica.     

ASSIGN glb_cddopcao = "X".

IF VALID-HANDLE(h-b1wgen0052) THEN
   DELETE OBJECT h-b1wgen0052.

PROCEDURE trata_conta_fisica:                

    DISPLAY glb_cddopcao  tel_nrdconta  tel_cdagenci  tel_dsagenci  
            tel_nrmatric  tel_inpessoa  tel_dspessoa  tel_nmprimtl  
            tel_nrcpfcgc  tel_dtcnscpf  tel_cdsitcpf  tel_dssitcpf  
            tel_tpdocptl  tel_nrdocptl  tel_cdoedptl  tel_cdufdptl  
            tel_dtemdptl  tel_dtnasctl  tel_cdsexotl  tel_tpnacion  
            tel_restpnac  tel_dsnacion  tel_dsnatura  tel_cdufnatu
            tel_cdestcvl  
            tel_dsestcvl  tel_nmconjug  tel_nrcepend  tel_dsendere  
            tel_nrendere  tel_complend  tel_nmbairro  tel_nmcidade  
            tel_cdufende  tel_nrcxapst  tel_nmpaittl  tel_nmmaettl  
            tel_cdempres  tel_nmresemp  tel_nrcadast  tel_cdocpttl  
            tel_dsocpttl  tel_dtadmiss  tel_dtdemiss  tel_cdmotdem 
            tel_dsmotdem  WITH FRAME f_matric.

    DO WHILE TRUE ON ENDKEY UNDO, RETURN "NOK":
    
       UPDATE tel_nmprimtl
              WITH FRAME f_matric

       EDITING:

          READKEY.
          HIDE MESSAGE NO-PAUSE.
          
          APPLY LASTKEY.

          IF  GO-PENDING THEN
              DO:
                 ASSIGN INPUT tel_nmprimtl.

                 RUN Valida_Dados.

                 IF  RETURN-VALUE <> "OK" THEN
                     DO:
                        {sistema/generico/includes/foco_campo.i &VAR-GERAL=SIM 
                            &NOME-FRAME="f_matric"
                            &NOME-CAMPO=aux_nmdcampo }
                            
                      END.
              END.

       END. /* Fim do EDITING */

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
            tel_nmfansia  tel_nrcpfcgc  tel_dtcnscpf  tel_cdsitcpf
            tel_dssitcpf  tel_insestad  tel_natjurid  tel_dsnatjur  
            tel_dtiniatv  tel_cdseteco  tel_nmseteco  tel_cdrmativ  
            tel_dsrmativ  tel_nrdddtfc  tel_nrtelefo  tel_nrcepend
            tel_dsendere  tel_nrendere  tel_complend  tel_nmbairro  
            tel_nmcidade  tel_cdufende  tel_nrcxapst  tel_dtadmiss  
            tel_dtdemiss  tel_cdmotdem  tel_dsmotdem
            WITH FRAME f_matric_juridica.
            
    FOR EACH tt-alertas BY tt-alertas.cdalerta:
       
        MESSAGE tt-alertas.dsalerta.

        IF  tt-alertas.qtdpausa <> 0 THEN
            PAUSE tt-alertas.qtdpausa NO-MESSAGE.

    END.

    DO WHILE TRUE ON ENDKEY UNDO, RETURN "NOK":

       UPDATE tel_nmprimtl
              WITH FRAME f_matric_juridica

       EDITING:
          READKEY.
          HIDE MESSAGE NO-PAUSE.

          APPLY LASTKEY.
          IF  GO-PENDING THEN
              DO:
                 ASSIGN INPUT tel_nmprimtl.

                 RUN Valida_Dados.

                 IF  RETURN-VALUE <> "OK" THEN
                     DO:
                        {sistema/generico/includes/foco_campo.i &VAR-GERAL=SIM 
                            &NOME-FRAME="f_matric_juridica"
                            &NOME-CAMPO=aux_nmdcampo }
                      END.

              END.

       END. /* Fim do EDITING */

       RUN Confirma.

       IF  aux_confirma = "S" THEN
           DO:
               RUN Grava_Dados.
    
               IF  RETURN-VALUE <> "OK" THEN
                   NEXT.
           END.

       LEAVE.

    END.
 
    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */
PROCEDURE Busca_Dados:

    ASSIGN glb_cddopcao = "X".

    IF NOT VALID-HANDLE(h-b1wgen0052) THEN
       RUN sistema/generico/procedures/b1wgen0052.p 
           PERSISTENT SET h-b1wgen0052.
    
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
         OUTPUT TABLE tt-crapcrl) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    FOR EACH tt-alertas BY tt-alertas.cdalerta:
       
        MESSAGE tt-alertas.dsalerta.

        IF  tt-alertas.qtdpausa <> 0 THEN
            PAUSE tt-alertas.qtdpausa NO-MESSAGE.

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
           ASSIGN tel_nrcpfcgc = STRING(tt-crapass.nrcpfcgc)
                  tel_cdagenci = tt-crapass.cdagenci
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
                  aux_dsproftl = tt-crapass.dsproftl
                  aux_nmsegntl = tt-crapass.nmsegntl
                  aux_cdtipcta = tt-crapass.cdtipcta
                  aux_dtcadass = tt-crapass.dtmvtolt
                  aux_inmatric = tt-crapass.inmatric
                  aux_dtmvtoan = tt-crapass.dtmvtoan
                  aux_rowidass = tt-crapass.rowidass
                  aux_idseqttl = tt-crapass.idseqttl
                  tel_inhabmen = tt-crapass.inhabmen
                  aux_nrdeanos = tt-crapass.nrdeanos.
    
           IF  tel_inpessoa = 1 THEN
               dis_nrcpfcgc = STRING(STRING(tel_nrcpfcgc,"99999999999"),
                                     "xxx.xxx.xxx-xx").
           ELSE 
               dis_nrcpfcgc = STRING(STRING(tel_nrcpfcgc,"99999999999999"),
                                     "xx.xxx.xxx/xxxx-xx").
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF VAR aux_dtdebito AS DATE                                NO-UNDO.
    DEF VAR aux_vlparcel AS DECIMAL                             NO-UNDO.
    DEF VAR aux_qtparcel AS INT                                 NO-UNDO.
    DEF VAR aux_contmens AS INT                                 NO-UNDO.

    ASSIGN glb_cddopcao = "X".
    
    IF NOT VALID-HANDLE(h-b1wgen0052) THEN
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
          INPUT dec(tel_nrcpfcgc),
          INPUT tel_nmprimtl,
          INPUT aux_dtcadass,
          INPUT aux_nmsegntl,
          INPUT tel_nmpaittl,
          INPUT tel_nmmaettl,
          INPUT tel_nmconjug,
          INPUT tel_cdempres,
          INPUT (IF tel_cdsexotl = "M" THEN 1 ELSE 2), 
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
          INPUT NO,
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
         OUTPUT TABLE tt-prod_serv_ativos) NO-ERROR.
    
     
                                                  
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
                  DO aux_contmens = 1 TO NUM-ENTRIES(tt-erro.dscritic,"|"):
                      MESSAGE ENTRY(aux_contmens,tt-erro.dscritic,"|").
                  END.
                  RETURN "NOK".
               END.
        END.

    /* apresentar mensagem de alerta */
    FOR EACH tt-alertas BY tt-alertas.cdalerta:
        MESSAGE tt-alertas.dsalerta.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            PAUSE.
            LEAVE.
        END.
        
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT. 
    END.

    IF  aux_msgretor <> "" AND NOT(aux_msgretor BEGINS "078") THEN
        DO:
           MESSAGE aux_msgretor.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               PAUSE.
               LEAVE.
           END.
            
           IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
               NEXT. 
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Grava_Dados:

    DEFINE VARIABLE aux_cdsexotl AS INTEGER     NO-UNDO.
    
    ASSIGN glb_cddopcao = "X"
           aux_cdsexotl = (IF tel_cdsexotl = "M" THEN 1 ELSE 2).

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
          INPUT DEC(tel_nrcpfcgc),
          INPUT tel_nmprimtl,
          INPUT tel_nmpaittl,
          INPUT tel_nmmaettl,
          INPUT tel_nmconjug,
          INPUT tel_cdempres,            
          INPUT aux_cdsexotl,
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
          INPUT "",
          INPUT 0,
          INPUT 0, 
          INPUT TABLE tt-crapavt,
          INPUT TABLE tt-crapcrl,
          INPUT TABLE tt-bens,
          2, /** Campo somente no Ayllos WEB **/
          0, /** Campo somente no Ayllos WEB **/
         OUTPUT aux_msgretor,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrecad,
         OUTPUT TABLE tt-erro) NO-ERROR .

    IF ERROR-STATUS:ERROR THEN
       DO:
          IF VALID-HANDLE(h-b1wgen0052) THEN
             DELETE OBJECT h-b1wgen0052.

          MESSAGE ERROR-STATUS:GET-MESSAGE(1).
          READKEY.
          RETURN "NOK".
       END.

    IF RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF AVAILABLE tt-erro THEN
             DO:
                IF VALID-HANDLE(h-b1wgen0052) THEN
                   DELETE OBJECT h-b1wgen0052.

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

    IF VALID-HANDLE(h-b1wgen0052) THEN
       DELETE OBJECT h-b1wgen0052.

    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE Confirma:

    RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

    IF   aux_confirma <> "S"   THEN
         RETURN "NOK".

     /* Se o operador confirmou a alteracao
        vamos solicitar a senha do coordenador */
    RUN fontes/pedesenha.p
               (INPUT glb_cdcooper,
                INPUT 2, /* Nivel do Operador - Coordenador  */ 
                OUTPUT aut_flgsenha,
                OUTPUT aut_cdoperad).
                                             
    IF  NOT aut_flgsenha THEN
        DO:
            ASSIGN aux_confirma = "N"
                   glb_cdcritic = 79.
            
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.



