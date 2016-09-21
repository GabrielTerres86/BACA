/* .............................................................................

   Programa: fontes/matrici.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                       Ultima atualizacao: 24/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela MATRIC.

   Observacao: As includes "criticas_dados_matrici.i" e 
               "cadastra_dados_matrici.i" sao usadas para a validacao e
               atualizacao dos dados, porem a "cadastra_dados_matrici.i" prende
               o registro da tabela "crapmat" portanto deve ser uma das ultimas
               rotinas a serem executadas.

   Alteracoes: 26/07/2006 - Incluido zoom no campo crapass.cdempres (David).
   
               06/09/2006 - Acerto no SETORECONO (Ze).

               29/09/2006 - Proibir caracter invalidos na razao social (Magui).
               
               16/10/2006 - Criticar quando nome da mae e pai foram iguais (Ze)
               
               10/11/2006 - Verifica se CPF esta cadastrado na Conta Sal. (Ze).
               
               19/03/2007 - Corrigir dspessoa ADMINIST (Magui).
               
               03/08/2007 - Nao permitir incluir uma conta se ja tiver uma
                            conta salario ativa com o mesmo CPF (Evandro).
               
               29/08/2007 - Alimentar tambem crapjur.nmextttl (Guilherme).
               
               07/12/2007 - Nao efetuar critica na Transpocred quando
                            crapmat.vlcapsub = 0 (Diego).
                            
               03/03/2008 - Correcao na inclusao de pessoa juridica (Evandro).
                            
               28/04/2008 - Alterado emissao do cheque para 10 folhas
                            (Gabriel).

               20/05/2008 - Alterada a chamada das Naturalidades (Evandro).
               
               13/06/2008 - Alteracao de controle de transacao (Evandro).
               
               07/07/2008 - Retirada verificacao na craptab "EMPRESINOP",
                            critica 558 - Empresa nao e conveniada (Diego).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase)
               
               09/06/2009 - Trocar "." por " " na abreviacao do 
                            crapttl.nmtalttl (Fernando).
                            
               22/07/2010 - Adapatado para uso de BO (Jose Luis, DB1) 
               
               16/02/2011 - Incluir parametro tt-prod_serv_ativos na procedure
                            Valida_Dados (David).
                            
               12/04/2011 - Inclusão de CEP integrado e browser procuradores
                            alterado para só aparecer na saída do último                            
                            campo. (André - DB1)                          

               27/04/2012 - Inclusao de Input glb_dtmvtolt na chamada da
                            Valida_Inicio_Inclusao.(David Kruger).
                            
               25/06/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).            
                            
               26/11/2012 - Correções em instâncias da BO52 (Lucas).
                            
                            
               29/04/2013 - Incluir campo tel_cdufnatu em tela e ajusta para 
                            validar e gravar (Lucas R.)
                            
               28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                            0 - menor/maior. (Carlos)
				
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)

............................................................................. */

{ sistema/generico/includes/b1wgen0038tt.i }
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

DEF      VAR aux_nmdcampo AS CHAR                                     NO-UNDO.
DEF      VAR aux_nmsegntl AS CHAR                                     NO-UNDO.
DEF      VAR aux_cdtipcta AS INTE                                     NO-UNDO.
DEF      VAR aux_dsproftl AS CHAR                                     NO-UNDO.
DEF      VAR aux_nmdsecao AS CHAR                                     NO-UNDO.
DEF      VAR aux_dtcadass AS DATE                                     NO-UNDO.
DEF      VAR aux_msgretor AS CHAR                                     NO-UNDO.
DEF      VAR aux_inmatric AS INTE                                     NO-UNDO.
DEF      VAR aux_rowidass AS ROWID                                    NO-UNDO.
DEF      VAR aux_dtdebito AS DATE                                     NO-UNDO.
DEF      VAR aux_vlparcel AS DECI                                     NO-UNDO.
DEF      VAR aux_qtparcel AS INTE                                     NO-UNDO.
DEF      VAR aux_nrmatric AS INT     FORMAT "zzz,zz9"                 NO-UNDO.
DEF      VAR aux_permalte AS LOG                                      NO-UNDO.
DEF      VAR aux_verrespo AS LOG                                      NO-UNDO.
DEF      VAR aux_nrcpfcgc AS CHAR FORMAT "X(18)"                      NO-UNDO.
DEF      VAR aux_nrctanov AS INTE                                     NO-UNDO.

DEF      VAR h-b1wgen0052 AS HANDLE                                   NO-UNDO.
DEF      VAR h-b1wgen0060 AS HANDLE                                   NO-UNDO.
DEF      VAR h-b1wgen9999 AS HANDLE                                   NO-UNDO.


IF NOT VALID-HANDLE(h-b1wgen0060) THEN
   RUN sistema/generico/procedures/b1wgen0060.p 
   PERSISTENT SET h-b1wgen0060.

/*-- Eventos para atualizar as descricoes na tela --*/
ON LEAVE, RETURN, GO OF tel_cdagenci IN FRAME f_matric DO:

    /* PAC */
    ASSIGN INPUT tel_cdagenci.

    DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                     INPUT glb_cdcooper,
                     INPUT tel_cdagenci,
                     INPUT "nmresage",
                    OUTPUT tel_dsagenci,
                    OUTPUT glb_dscritic).

    IF  tel_dsagenci = ""  THEN
        ASSIGN tel_dsagenci = "NAO CADASTRADA".

    DISPLAY tel_dsagenci WITH FRAME f_matric.
    
END.


ON LEAVE OF tel_inhabmen IN FRAME f_matric DO:

   /* Habilitacao */
   ASSIGN INPUT tel_inhabmen.

   DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                    INPUT tel_inhabmen,
                    OUTPUT tel_dshabmen,
                    OUTPUT glb_dscritic).
   
   DISPLAY tel_dshabmen WITH FRAME f_matric.

   IF tel_inhabmen <> 1 THEN
      DO:
         ASSIGN tel_dthabmen = ?.

         ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_matric = TRUE.

         DISP tel_dthabmen WITH FRAME f_matric.

      END.
   ELSE
      ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_matric = FALSE.

END.

ON LEAVE, RETURN OF tel_inpessoa IN FRAME f_matric DO:

   ASSIGN INPUT tel_inpessoa.
  
   IF tel_inpessoa = 1   THEN
      tel_dspessoa = "FISICA".
   ELSE
      IF tel_inpessoa = 2   THEN
         tel_dspessoa = "JURIDICA".
      ELSE
         tel_dspessoa = "".

   DISPLAY tel_dspessoa WITH FRAME f_matric.

END.

RUN Busca_Dados.

IF RETURN-VALUE <> "OK" THEN
   DO:
       IF VALID-HANDLE(h-b1wgen0060) THEN
          DELETE OBJECT h-b1wgen0060.

       RETURN "NOK".

   END.
 
INCLUIR: 
   
    DO ON ENDKEY UNDO, LEAVE:
         
       CLEAR FRAME f_matric.
       
       ASSIGN tel_nrcpfcgc = ""
              tel_natjurid = 0
              tel_insestad = 0
              tel_dtiniatv = ?
              tel_dspessoa = "FISICA"
              tel_cdsexotl = ""
              tel_nmfansia = ""
              tel_cdseteco = 0
              tel_nmseteco = ""
              tel_cdrmativ = 0
              tel_nrcepend = 0
              tel_dsendere = ""
              tel_nrendere = 0
              tel_complend = ""
              tel_nmbairro = ""
              tel_nmcidade = ""
              tel_cdufende = ""
              tel_nrcxapst = 0
              tel_nrdddtfc = 0
              tel_nrtelefo = 0
              aux_dtdebito = ?
              aux_vlparcel = 0
              aux_qtparcel = 0
              tel_dthabmen = ?
              tel_inhabmen = 0.
              
       
       DISPLAY glb_cddopcao 
               tel_nrdconta 
               tel_dspessoa WITH FRAME f_matric.
       
       UPDATE tel_cdagenci
              tel_inpessoa
              WITH FRAME f_matric
       
       EDITING:
       
          READKEY.
          HIDE MESSAGE NO-PAUSE.
       
          APPLY LASTKEY.
       
          IF  GO-PENDING  THEN
              DO:
                  RUN Valida_Inicio_Inclusao.
       
                  IF  RETURN-VALUE = "NOK"  THEN
                      DO:
                          { sistema/generico/includes/foco_campo.i &VAR-GERAL=SIM 
                                &NOME-FRAME="f_matric"
                                &NOME-CAMPO=aux_nmdcampo }
                      END.
              END.
       
       END.
       
       IF  tel_inpessoa = 1  THEN
           RUN trata_conta_fisica.
       ELSE
           RUN trata_conta_juridica.
            
       IF  RETURN-VALUE <> "OK"  THEN
           UNDO INCLUIR, LEAVE INCLUIR.
       
END. /* Fim DO TRANSACTION */
          
IF aux_nrmatric > 0 THEN
   DO:
       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          MESSAGE "A matricula utilizada foi"
                  TRIM(STRING(aux_nrmatric,"zzz,zz9")).
          PAUSE MESSAGE "Tecle algo para continuar...".

          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

   END.

/* Para nao ficar habilitado o tempo todo */
DISABLE tel_nmconjug WITH FRAME f_matric.

CLEAR FRAME f_matric.
CLEAR FRAME f_matric_juridica.

ASSIGN glb_cddopcao = "I".

IF VALID-HANDLE(h-b1wgen0060) THEN
   DELETE OBJECT h-b1wgen0060.

PROCEDURE trata_conta_fisica:     

    ON LEAVE OF tel_inhabmen IN FRAME f_matric DO:

       /* Habilitacao */
       ASSIGN INPUT tel_inhabmen.
    
       DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                        INPUT tel_inhabmen,
                        OUTPUT tel_dshabmen,
                        OUTPUT glb_dscritic).
       
       DISPLAY tel_dshabmen 
               WITH FRAME f_matric.
    
    END.

    /* Inclusão de CEP integrado. (André - DB1) */
    ON GO, LEAVE OF tel_nrcepend IN FRAME f_matric DO:

        IF  INPUT tel_nrcepend = 0  THEN
            RUN Limpa_Endereco(1).

    END.

    ON RETURN OF tel_nrcepend IN FRAME f_matric DO:

        HIDE MESSAGE NO-PAUSE.
    
        ASSIGN INPUT tel_nrcepend.
    
        IF  tel_nrcepend <> 0  THEN 
            DO:
                RUN fontes/zoom_endereco.p (INPUT tel_nrcepend,
                                            OUTPUT TABLE tt-endereco).
        
                FIND FIRST tt-endereco NO-LOCK NO-ERROR.
        
                IF  AVAIL tt-endereco THEN
                    DO:
                        ASSIGN tel_nrcepend = tt-endereco.nrcepend 
                               tel_dsendere = tt-endereco.dsendere 
                               tel_nmbairro = tt-endereco.nmbairro 
                               tel_nmcidade = tt-endereco.nmcidade 
                               tel_cdufende = tt-endereco.cdufende.
                    END.
                ELSE
                    DO:
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            RETURN NO-APPLY.
                            
                        MESSAGE "CEP nao cadastrado.".
                        RUN Limpa_Endereco(1).
                        RETURN NO-APPLY.
                    END.
            END.
        ELSE
            RUN Limpa_Endereco(1).
    
        DISPLAY tel_nrcepend  tel_dsendere
                tel_nmbairro  tel_nmcidade
                tel_cdufende 
                WITH FRAME f_matric.
    
        NEXT-PROMPT tel_nrendere WITH FRAME f_matric.
    END.

    /*-- Eventos para atualizar as descricoes na tela --*/
    ON LEAVE OF tel_cdsitcpf IN FRAME f_matric DO:

       /* Situacao do CPF/CNPJ */
        ASSIGN INPUT tel_cdsitcpf.

        DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                         INPUT tel_cdsitcpf,
                         OUTPUT tel_dssitcpf,
                         OUTPUT glb_dscritic).

       DISPLAY tel_dssitcpf WITH FRAME f_matric.

    END.
    
    ON LEAVE OF tel_tpnacion IN FRAME f_matric DO:

        /* tipo nacionalidade */
        ASSIGN INPUT tel_tpnacion.

        DYNAMIC-FUNCTION("BuscaTipoNacion" IN h-b1wgen0060, 
                         INPUT tel_tpnacion,
                         INPUT "restpnac",
                         OUTPUT tel_restpnac,
                         OUTPUT glb_dscritic).

        IF  glb_dscritic <> "" THEN
            ASSIGN tel_restpnac = "DESCONHECIDA".

       DISPLAY tel_restpnac WITH FRAME f_matric.

    END.

    ON LEAVE OF tel_cdestcvl IN FRAME f_matric DO:

        /* Estado civil */
        ASSIGN INPUT tel_cdestcvl.

        DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                         INPUT tel_cdestcvl,
                         INPUT "rsestcvl",
                         OUTPUT tel_dsestcvl,
                         OUTPUT glb_dscritic).

        IF  glb_dscritic <> "" THEN
            ASSIGN tel_dsestcvl = "NAO CADASTRADO".

       DISPLAY tel_dsestcvl WITH FRAME f_matric.

       APPLY "VALUE-CHANGED" TO tel_cdestcvl IN FRAME f_matric.

       /* Quando estado civil for "Casado" e idade for menor que 18 anos,
          a pessoa passa automaticamente a ser emancipada.*/
       IF CAN-DO("2,3,4,8,9,11",STRING(tel_cdestcvl)) THEN
          DO:
             ASSIGN INPUT tel_dtnasctl.

             IF VALID-HANDLE(h-b1wgen9999) THEN
                DELETE OBJECT(h-b1wgen9999).

             RUN sistema/generico/procedures/b1wgen9999.p
                 PERSISTENT SET h-b1wgen9999.

             /* validar pela procedure generica do b1wgen9999.p */
             RUN idade IN h-b1wgen9999 ( INPUT tel_dtnasctl,
                                         INPUT glb_dtmvtolt,
                                         OUTPUT aux_nrdeanos,
                                         OUTPUT aux_nrdmeses,
                                         OUTPUT aux_dsdidade ).

             IF VALID-HANDLE(h-b1wgen9999) THEN
                DELETE OBJECT(h-b1wgen9999).


             IF aux_nrdeanos < 18 AND 
                tel_inhabmen = 0 THEN
                DO:
                   ASSIGN tel_inhabmen = 1
                          tel_dthabmen = glb_dtmvtolt.
                   
                   DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                                    INPUT tel_inhabmen,
                                    OUTPUT tel_dshabmen,
                                    OUTPUT glb_dscritic).
                   
                   DISP tel_inhabmen
                        tel_dthabmen
                        tel_dshabmen
                        WITH FRAME f_matric.

                END.

             ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_matric = TRUE
                    tel_dthabmen:READ-ONLY IN FRAME f_matric = TRUE
                    aux_nrdeanos = 0
                    aux_nrdmeses = 0
                    aux_dsdidade = "".

          END.
        ELSE
          ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_matric = FALSE
                 tel_dthabmen:READ-ONLY IN FRAME f_matric = FALSE.

    END.

    ON VALUE-CHANGED OF tel_cdestcvl IN FRAME f_matric DO:
    
        /* Se for solteiro, nao pede conjuge */
        IF   INPUT tel_cdestcvl = 1   OR   /* SOLTEIRO */
             INPUT tel_cdestcvl = 5   OR   /* VIUVO */
             INPUT tel_cdestcvl = 6   OR   /* SEPARADO */
             INPUT tel_cdestcvl = 7   THEN /* DIVORCIADO */
             DO:
                 tel_nmconjug = "".
                 DISPLAY tel_nmconjug WITH FRAME f_matric.
                 DISABLE tel_nmconjug WITH FRAME f_matric.
             END.
        ELSE
            DO:
               /* Habilita todos os campos para manter a ordem
                  dos campos no do update */
               ENABLE tel_nmconjug    tel_nrcepend
                      tel_nrendere    tel_complend    
                      tel_nrcxapst    tel_cdempres
                      tel_nrcadast    tel_cdocpttl
                      WITH FRAME f_matric.

               APPLY "ENTRY" TO tel_nmconjug IN FRAME f_matric.
            END.
    END.

    ON LEAVE OF tel_cdempres IN FRAME f_matric DO:

        /* Empresa */
        ASSIGN INPUT tel_cdempres.
        
        DYNAMIC-FUNCTION("BuscaEmpresa" IN h-b1wgen0060,
                         INPUT glb_cdcooper,
                         INPUT tel_cdempres,
                        OUTPUT tel_nmresemp,
                        OUTPUT glb_dscritic ).

        IF  glb_dscritic <> "" THEN
            ASSIGN tel_nmresemp = "NAO CADASTRADA".

        DISPLAY tel_nmresemp WITH FRAME f_matric.

    END.

    ON LEAVE OF tel_cdocpttl IN FRAME f_matric DO:

        /* Ocupacao */
        ASSIGN INPUT tel_cdocpttl.

        DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                         INPUT tel_cdocpttl,
                        OUTPUT tel_dsocpttl,
                        OUTPUT glb_dscritic ).

        IF  glb_dscritic <> "" THEN
            ASSIGN tel_dsocpttl = "DESCONHEC.".

        DISPLAY tel_dsocpttl WITH FRAME f_matric.

    END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_nrdeanos = 0
              aux_nrdmeses = 0
              aux_dsdidade = ""
              aux_permalte = TRUE
              aux_verrespo = FALSE
              aux_nrcpfcgc = ""
              tel_inhabmen:READ-ONLY IN FRAME f_matric = FALSE
              tel_dthabmen:READ-ONLY IN FRAME f_matric = FALSE.
       
       UPDATE tel_nmprimtl  tel_nrcpfcgc  tel_dtcnscpf
              tel_cdsitcpf  tel_tpdocptl  tel_nrdocptl
              tel_cdoedptl  tel_cdufdptl  tel_dtemdptl
              tel_nmmaettl  tel_nmpaittl  tel_dtnasctl    
              tel_cdsexotl  tel_tpnacion  tel_dsnacion    
              tel_dsnatura  tel_cdufnatu  tel_inhabmen  
              tel_dthabmen  tel_cdestcvl  tel_nmconjug    
              tel_nrcepend  tel_nrendere    
              tel_complend  tel_nrcxapst  tel_cdempres    
              tel_nrcadast  tel_cdocpttl
              WITH FRAME f_matric

       EDITING:
          READKEY.
          HIDE MESSAGE NO-PAUSE.

          IF   FRAME-FIELD = "tel_nmprimtl"   THEN
               DO:
                   IF   LASTKEY =  KEYCODE("=") OR
                        LASTKEY =  KEYCODE("%") OR
                        LASTKEY =  KEYCODE("&") OR
                        LASTKEY =  KEYCODE("#") OR
                        LASTKEY =  KEYCODE("+") OR
                        LASTKEY =  KEYCODE("?") OR
                        LASTKEY =  KEYCODE(",") OR
                        LASTKEY =  KEYCODE(".") OR
                        LASTKEY =  KEYCODE("/") THEN
                        MESSAGE "Caracteres =,%,&,#,+,?,',','.',/"
                                "nao permitidos!".
                   ELSE 
                        DO: 
                            HIDE MESSAGE NO-PAUSE.
                            APPLY LASTKEY.
                        END.
               END.
          ELSE
          IF   FRAME-FIELD = "tel_cdsexotl"   THEN
               DO:
                   /* So deixa escrever M ou F */
                   IF   NOT CAN-DO("GO,RETURN,TAB,BACK-TAB,BACKSPACE," +
                        "END-ERROR,HELP,CURSOR-UP,CURSOR-DOWN," + 
                        "CURSOR-LEFT,CURSOR-RIGHT,M,F",
                        KEY-FUNCTION(LASTKEY))   THEN
                        MESSAGE "Escolha (M)asculino / (F)eminino".
                   ELSE 
                        DO:
                            IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
                                NEXT-PROMPT tel_cdsexotl
                                            WITH FRAME f_matric.
                                            
                            HIDE MESSAGE NO-PAUSE.
                            APPLY LASTKEY.
                        END.
               END.
          ELSE               
          IF   FRAME-FIELD = "tel_cdestcvl"   THEN
               DO:
                   IF   LASTKEY = KEYCODE("F7") THEN
                        DO:
                            shr_cdestcvl = tel_cdestcvl.
                            RUN fontes/zoom_estcivil.p.
                            IF   shr_cdestcvl <> 0 THEN
                                 DO:
                                    ASSIGN tel_cdestcvl = shr_cdestcvl
                                           tel_dsestcvl = shr_dsestcvl.
                                    DISPLAY tel_cdestcvl tel_dsestcvl
                                            WITH FRAME f_matric.
                                    NEXT-PROMPT tel_cdestcvl
                                            WITH FRAME f_matric.
                                END.
                        END.
                   ELSE    
                        APPLY LASTKEY.

                   /* Se for solteiro, nao pede conjuge */
                   IF   INPUT tel_cdestcvl = 1   OR   /* SOLTEIRO */
                        INPUT tel_cdestcvl = 5   OR   /* VIUVO */
                        INPUT tel_cdestcvl = 6   OR   /* SEPARADO */
                        INPUT tel_cdestcvl = 7   THEN /* DIVORCIADO */
                        DO:
                            tel_nmconjug = "".
                            DISPLAY tel_nmconjug WITH FRAME f_matric.
                            DISABLE tel_nmconjug WITH FRAME f_matric.
                        END.
                   ELSE
                        /* Habilita todos os campos para manter a ordem
                           dos campos no do update */
                        ENABLE tel_nmconjug    tel_nrcepend
                               tel_nrendere    tel_complend    
                               tel_nrcxapst    tel_cdempres
                               tel_nrcadast    tel_cdocpttl
                               WITH FRAME f_matric.
               END.
          ELSE
          IF   LASTKEY = KEYCODE("F7") THEN
               DO:
                   /* Inclusão de CEP integrado. (André - DB1) */
                   IF  FRAME-FIELD = "tel_nrcepend"  THEN
                       DO:
                           RUN fontes/zoom_endereco.p 
                                (INPUT 0,
                                 OUTPUT TABLE tt-endereco).
                 
                           FIND FIRST tt-endereco NO-LOCK NO-ERROR.
               
                           IF  AVAIL tt-endereco THEN
                               ASSIGN tel_nrcepend = tt-endereco.nrcepend
                                      tel_dsendere = tt-endereco.dsendere
                                      tel_nmbairro = tt-endereco.nmbairro
                                      tel_nmcidade = tt-endereco.nmcidade
                                      tel_cdufende = tt-endereco.cdufende.
                                                     
                           DISPLAY tel_nrcepend    
                                   tel_dsendere
                                   tel_nmbairro
                                   tel_nmcidade
                                   tel_cdufende WITH FRAME f_matric.

                           IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                               NEXT-PROMPT tel_nrendere WITH FRAME f_matric.
                       END.
                   ELSE
                   IF   FRAME-FIELD = "tel_tpnacion" THEN
                        DO:
                           shr_tpnacion = tel_tpnacion.
                           RUN fontes/zoom_tipo_nacion.p.
                           IF  shr_tpnacion <> 0  THEN
                               DO:
                                  ASSIGN tel_tpnacion = shr_tpnacion
                                         tel_restpnac = shr_restpnac.
    
                                  DISPLAY tel_tpnacion tel_restpnac
                                          WITH FRAME f_matric.
    
                                  NEXT-PROMPT tel_tpnacion
                                              WITH FRAME f_matric.
                             END.
                        END.
                   ELSE
                   IF   FRAME-FIELD = "tel_dsnacion" THEN
                        DO:
                           shr_dsnacion = tel_dsnacion.
                           RUN fontes/nacion.p.
                           IF   shr_dsnacion <> " " THEN
                                DO:
                                    tel_dsnacion = shr_dsnacion.
                                    DISPLAY tel_dsnacion
                                            WITH FRAME f_matric.
                                    NEXT-PROMPT tel_dsnacion
                                                WITH FRAME f_matric.
                                END.
                        END.
                   ELSE
                   IF   FRAME-FIELD = "tel_dsnatura" THEN
                        DO:
                           RUN fontes/natura.p (OUTPUT shr_dsnatura).
                           IF   shr_dsnatura <> "" THEN
                                DO:
                                    tel_dsnatura = shr_dsnatura.
                                    DISPLAY tel_dsnatura
                                            WITH FRAME f_matric.
                                    NEXT-PROMPT tel_dsnatura
                                            WITH FRAME f_matric.
                                END.
                        END.
                   ELSE
                   IF   FRAME-FIELD = "tel_cdempres"   THEN
                        DO:
                           ASSIGN shr_cdempres = tel_cdempres. 
                           RUN fontes/zoom_empresa.p.
                           IF   shr_cdempres <> 0 THEN
                                DO:
                                   ASSIGN tel_cdempres = shr_cdempres
                                          tel_nmresemp = shr_nmresemp.
                                   DISPLAY tel_cdempres tel_nmresemp  
                                           WITH FRAME f_matric.
                                   NEXT-PROMPT tel_cdempres           
                                           WITH FRAME f_matric.
                               END.
                        END.
                   ELSE 
                   IF   FRAME-FIELD = "tel_cdocpttl" THEN
                        DO:
                           OCUPACAO_1:
                           DO WHILE TRUE ON ENDKEY UNDO OCUPACAO_1,LEAVE: 
                               ASSIGN shr_ocupacao_pesq  = " ". 

                               UPDATE shr_ocupacao_pesq
                                      WITH FRAME f_pesq_ocupacao.

                               HIDE FRAME f_pesq_ocupacao.
                               ASSIGN shr_cdocpttl = tel_cdocpttl.

                               RUN fontes/zoom_ocupacao.p.
                               IF   shr_cdocpttl <> 0   THEN
                                    DO:
                                        ASSIGN tel_cdocpttl = shr_cdocpttl
                                               tel_dsocpttl = shr_rsdocupa.

                                        DISPLAY tel_cdocpttl
                                                tel_dsocpttl
                                                WITH FRAME f_matric.

                                        NEXT-PROMPT tel_cdocpttl
                                                    WITH FRAME f_matric.
                                    END.

                               LEAVE.   
                           END. /* DO WHILE */
                        END.
               END. /* Fim do F7 */
          ELSE
          IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
             UNDO, LEAVE.
          ELSE
             APPLY LASTKEY.

          IF GO-PENDING THEN
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

       END. /* Fim do EDITING */
          
       /* Para nao ficar habilitado o tempo todo */
       DISABLE tel_nmconjug WITH FRAME f_matric.

       /* parcelamento do capital */
       IF  tel_inpessoa <> 3 THEN
           RUN fontes/matric_pc.p
               ( INPUT tel_nrdconta,
                 INPUT 1,
                OUTPUT aux_dtdebito,
                OUTPUT aux_vlparcel,  
                OUTPUT aux_qtparcel ).

       IF (tel_inhabmen = 0   AND
           aux_nrdeanos < 18) OR 
           tel_inhabmen = 2   THEN
          DO:  
              ASSIGN glb_nmrotina = "MATRIC"
                     aux_nrcpfcgc = tel_nrcpfcgc.

              EMPTY TEMP-TABLE tt-resp.

              RUN fontes/contas_responsavel.p (INPUT "MATRIC",
                                               INPUT tel_nrdconta,
                                               INPUT 1,
                                               INPUT DEC(tel_nrcpfcgc),
                                               INPUT tel_dtnasctl,
                                               INPUT tel_inhabmen,
                                               OUTPUT aux_permalte,
                                               INPUT-OUTPUT TABLE tt-resp). 
       
              /*As variaveis abaixo estao sendo alimentadas
                devido a serem atualizadas dentro do
                contas_responsavel */
              ASSIGN glb_cddopcao = "I"
                     glb_nmrotina = ""
                     aux_verrespo = TRUE
                     tel_nrcpfcgc = aux_nrcpfcgc.

              RUN Valida_Dados.

              IF   RETURN-VALUE = "NOK" THEN
                   NEXT.
       
          END. 

       /* confirmacao dentro do bloco DO WHILE TRUE para que possa retornar
          a edicao em caso de manutencao simultenea de regitros (lock) */
       RUN Confirma.

       IF  aux_confirma = "S" THEN
           DO:
              RUN Grava_Dados.

              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.
           END.

       LEAVE.
    END. /* Fim DO WHILE */
    
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
         RETURN "NOK".

    RETURN "OK".

END PROCEDURE.  

PROCEDURE trata_conta_juridica:

    /* Inclusão de CEP integrado. (André - DB1) */
    ON GO, LEAVE OF tel_nrcepend IN FRAME f_matric_juridica DO:

        IF  INPUT tel_nrcepend = 0  THEN
            RUN Limpa_Endereco(2).

    END.

    ON RETURN OF tel_nrcepend IN FRAME f_matric_juridica DO:

        HIDE MESSAGE NO-PAUSE.
    
        ASSIGN INPUT tel_nrcepend.
    
        IF  tel_nrcepend <> 0  THEN 
            DO:
                RUN fontes/zoom_endereco.p (INPUT tel_nrcepend,
                                            OUTPUT TABLE tt-endereco).
        
                FIND FIRST tt-endereco NO-LOCK NO-ERROR.
        
                IF  AVAIL tt-endereco THEN
                    DO:
                        ASSIGN tel_nrcepend = tt-endereco.nrcepend 
                               tel_dsendere = tt-endereco.dsendere 
                               tel_nmbairro = tt-endereco.nmbairro 
                               tel_nmcidade = tt-endereco.nmcidade 
                               tel_cdufende = tt-endereco.cdufende.
                    END.
                ELSE
                    DO:
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                            RETURN NO-APPLY.
                            
                        MESSAGE "CEP nao cadastrado.".
                        RUN Limpa_Endereco(2).
                        RETURN NO-APPLY.
                    END.
            END.
        ELSE
            RUN Limpa_Endereco(2).
    
        DISPLAY tel_nrcepend  tel_dsendere
                tel_nmbairro  tel_nmcidade
                tel_cdufende
                WITH FRAME f_matric_juridica.
    
        NEXT-PROMPT tel_nrendere 
                    WITH FRAME f_matric_juridica.
    END.

    /*-- Eventos para atualizar as descricoes na tela --*/
    ON LEAVE OF tel_cdsitcpf IN FRAME f_matric_juridica DO:

        /* Situacao do CPF/CNPJ */
        ASSIGN INPUT tel_cdsitcpf.

        DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                         INPUT tel_cdsitcpf,
                         OUTPUT tel_dssitcpf,
                         OUTPUT glb_dscritic).

       DISPLAY tel_dssitcpf WITH FRAME f_matric_juridica.

    END.

    ON LEAVE OF tel_natjurid IN FRAME f_matric_juridica DO:

        /* Natureza juridica */
        ASSIGN INPUT tel_natjurid.

        DYNAMIC-FUNCTION("BuscaNaturezaJuridica" IN h-b1wgen0060,
                          INPUT tel_natjurid,
                          INPUT "rsnatjur",
                         OUTPUT tel_dsnatjur,
                         OUTPUT glb_dscritic).

        IF  glb_dscritic <> "" THEN
            ASSIGN tel_dsnatjur = "NAO CADASTRADO".
       
        DISPLAY tel_dsnatjur WITH FRAME f_matric_juridica.

    END.

    ON LEAVE OF tel_cdseteco IN FRAME f_matric_juridica DO:

        /* Setor economico */
        ASSIGN INPUT tel_cdseteco.

        DYNAMIC-FUNCTION("BuscaSetorEconomico" IN h-b1wgen0060,
                          INPUT glb_cdcooper,
                          INPUT tel_cdseteco,
                         OUTPUT tel_nmseteco,
                         OUTPUT glb_dscritic).
    
        IF  glb_dscritic <> "" THEN
            ASSIGN tel_nmseteco = "NAO CADASTRADO".

        DISPLAY tel_nmseteco WITH FRAME f_matric_juridica.

    END.

    ON LEAVE OF tel_cdrmativ IN FRAME f_matric_juridica DO:

        /* Ramo de Atividade */
        ASSIGN INPUT tel_cdrmativ.

        DYNAMIC-FUNCTION("BuscaRamoAtividade" IN h-b1wgen0060,
                         INPUT tel_cdseteco,
                         INPUT tel_cdrmativ,
                        OUTPUT tel_dsrmativ,
                        OUTPUT glb_dscritic).

        IF  glb_dscritic <> "" THEN
            ASSIGN tel_dsrmativ = "NAO CADASTRADO".

        DISPLAY tel_dsrmativ WITH FRAME f_matric_juridica.

    END.

    PAUSE 0.
    DISPLAY glb_cddopcao    tel_nrdconta
            tel_cdagenci    tel_dsagenci
            tel_inpessoa    tel_dspessoa
            WITH FRAME f_matric_juridica.
    
    DO WHILE TRUE ON ENDKEY UNDO, RETURN "NOK":
       
       UPDATE tel_nmprimtl  tel_nmfansia  tel_nrcpfcgc
              tel_dtcnscpf  tel_cdsitcpf  tel_insestad
              tel_natjurid  tel_dtiniatv  tel_cdseteco
              tel_cdrmativ  tel_nrdddtfc  tel_nrtelefo
              tel_nrcepend  tel_nrendere
              tel_complend  tel_nrcxapst        
              WITH FRAME f_matric_juridica
              
       EDITING:
          READKEY.
          HIDE MESSAGE NO-PAUSE.
          
          IF   FRAME-FIELD = "tel_nmprimtl"   THEN
               DO:
                   IF   LASTKEY =  KEYCODE("=") OR
                        LASTKEY =  KEYCODE("%") OR
                        LASTKEY =  KEYCODE("&") OR
                        LASTKEY =  KEYCODE("#") OR
                        LASTKEY =  KEYCODE("+") OR
                        LASTKEY =  KEYCODE("?") OR
                        LASTKEY =  KEYCODE(",") OR
                        LASTKEY =  KEYCODE(".") OR
                        LASTKEY =  KEYCODE("/") THEN
                        MESSAGE "Caracteres =,%,&,#,+,?,',','.',/"
                                "nao permitidos!".
                   ELSE 
                        DO: 
                            HIDE MESSAGE NO-PAUSE.
                            APPLY LASTKEY.
                        END.
               END.
          ELSE
          IF  LASTKEY = KEYCODE("F7") THEN
              DO:
                 /* Inclusão de CEP integrado. (André - DB1) */
                 IF  FRAME-FIELD = "tel_nrcepend"  THEN
                     DO:
                         RUN fontes/zoom_endereco.p 
                              (INPUT 0,
                               OUTPUT TABLE tt-endereco).
               
                         FIND FIRST tt-endereco NO-LOCK NO-ERROR.

                         IF  AVAIL tt-endereco THEN
                             ASSIGN tel_nrcepend = tt-endereco.nrcepend
                                    tel_dsendere = tt-endereco.dsendere
                                    tel_nmbairro = tt-endereco.nmbairro
                                    tel_nmcidade = tt-endereco.nmcidade
                                    tel_cdufende = tt-endereco.cdufende.
                                                   
                         DISPLAY tel_nrcepend    
                                 tel_dsendere
                                 tel_nmbairro
                                 tel_nmcidade
                                 tel_cdufende WITH FRAME f_matric_juridica.

                         IF  KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                             NEXT-PROMPT tel_nrendere 
                                  WITH FRAME f_matric_juridica.
                     END.
                 ELSE
                 IF  FRAME-FIELD = "tel_natjurid"   THEN
                     DO:
                        ASSIGN shr_cdnatjur = INPUT tel_natjurid.
                        RUN fontes/zoom_natureza_juridica.p.
                        IF  shr_cdnatjur <> 0  THEN
                            DO:
                               ASSIGN tel_natjurid = shr_cdnatjur
                                      tel_dsnatjur = shr_rsnatjur.
                               DISPLAY tel_natjurid tel_dsnatjur
                                       WITH FRAME f_matric_juridica.
                               NEXT-PROMPT tel_natjurid
                                    WITH FRAME f_matric_juridica.
                             END.
                     END.
                 ELSE
                 IF  FRAME-FIELD = "tel_cdseteco"   THEN
                     DO:
                         ASSIGN shr_cdseteco = INPUT tel_cdseteco.
                         RUN fontes/zoom_setoreconomico.p
                                          (INPUT glb_cdcooper).
                         IF  shr_cdseteco <> 0  THEN
                             DO:
                                ASSIGN tel_cdseteco = shr_cdseteco
                                       tel_nmseteco = shr_nmseteco.
                                DISPLAY tel_cdseteco tel_nmseteco
                                        WITH FRAME f_matric_juridica.
                                NEXT-PROMPT tel_cdseteco
                                     WITH FRAME f_matric_juridica.
                              END.
                     END.
                 ELSE
                 IF  FRAME-FIELD = "tel_cdrmativ"   THEN
                     DO:
                         ASSIGN shr_cdrmativ = INPUT tel_cdrmativ
                                tel_cdseteco = INPUT tel_cdseteco.
                         RUN fontes/zoom_ramo_atividades.p
                                   (INPUT tel_cdseteco).

                         IF  shr_cdrmativ <> 0  THEN
                             DO:
                                ASSIGN tel_cdrmativ = shr_cdrmativ
                                       tel_dsrmativ = shr_nmrmativ.
                                DISPLAY tel_cdrmativ tel_dsrmativ
                                        WITH FRAME f_matric_juridica.
                                NEXT-PROMPT tel_cdrmativ
                                     WITH FRAME f_matric_juridica.
                              END.
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
                                         INPUT tel_nrdconta,
                                         INPUT "I",
                                         INPUT tel_nrcpfcgc,
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

       IF RETURN-VALUE <> "OK" THEN
          NEXT.

       RUN Valida_Dados.

       IF RETURN-VALUE <> "OK" THEN
          NEXT.

       /* parcelamento do capital */
       IF  tel_inpessoa <> 3 THEN
           RUN fontes/matric_pc.p
               ( INPUT tel_nrdconta,
                 INPUT 1,
                OUTPUT aux_dtdebito,
                OUTPUT aux_vlparcel,  
                OUTPUT aux_qtparcel ).

       /* 78 (S/N) */
       RUN Confirma.

       IF aux_confirma = "S" THEN
          DO:
              RUN Grava_Dados.
    
              IF  RETURN-VALUE <> "OK" THEN
                  NEXT.
          END.
       ELSE
          DO:
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                MESSAGE COLOR NORMAL "Todas as informacoes serao perdidas."
                                     "Confirma a operacao (S/N)?"
                                     UPDATE aux_confirma.
                LEAVE.

             END.
            
             /* Se nao confirmar a saida, volta para o update */
             IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma = "N"                   THEN
                NEXT.
           
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             RETURN "NOK".

          END.

       LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */

PROCEDURE Busca_Dados:

    ASSIGN glb_cddopcao = "I".

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

    IF  VALID-HANDLE(h-b1wgen0052) THEN
        DELETE PROCEDURE h-b1wgen0052.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    /* exibe mensagens de alerta */
    FOR EACH tt-alertas BY tt-alertas.cdalerta:
        MESSAGE tt-alertas.dsalerta.
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

PROCEDURE Valida_Dados:

    DEF VAR aux_contmens AS INT                                 NO-UNDO.

    ASSIGN glb_cddopcao = "I".

    IF  tel_inpessoa = 1 THEN
        DO WITH FRAME f_matric:
    
            ASSIGN INPUT tel_nmprimtl INPUT tel_nrcpfcgc
                   INPUT tel_dtcnscpf INPUT tel_cdsitcpf  
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
                   INPUT tel_dtadmiss.

        END.       
    ELSE
        DO WITH FRAME f_matric_juridica:

            ASSIGN tel_nmprimtl  tel_nrcpfcgc
                   tel_nmfansia  tel_dtcnscpf   
                   tel_cdsitcpf  tel_insestad   
                   tel_natjurid  tel_dtiniatv   
                   tel_cdseteco  tel_cdrmativ   
                   tel_nrdddtfc  tel_nrtelefo   
                   tel_nrcepend  tel_dsendere   
                   tel_nrendere  tel_complend   
                   tel_nmbairro  tel_nmcidade   
                   tel_cdufende  tel_nrcxapst.

        END.

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
          INPUT DEC(tel_nrcpfcgc),
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
          INPUT NO,
          INPUT aux_verrespo,
          INPUT aux_permalte,
          INPUT tel_inhabmen,
          INPUT tel_dthabmen,
          INPUT TABLE tt-crapavt,
          INPUT TABLE tt-resp,
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
        DELETE PROCEDURE h-b1wgen0052.
    
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

    /* controle para criacao de conta administrativa, tipo = 3 */
    IF  aux_msgretor <> "" AND NOT(aux_msgretor BEGINS "078") THEN
        DO:
           IF  aux_msgretor BEGINS "ATENCAO!!! Esta sendo criada uma " THEN
               DO:
                  MESSAGE aux_msgretor .

                  RUN Confirma.

                  RETURN RETURN-VALUE.
               END.
           ELSE
               DO:
                  MESSAGE aux_msgretor.
                  
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     PAUSE.
                     LEAVE.
                  END.
               END.
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Inicio_Inclusao:

    ASSIGN glb_cddopcao = "I".

    DO WITH FRAME f_matric:
    
        ASSIGN tel_cdagenci 
               tel_inpessoa.
                
    END.
    
    IF NOT VALID-HANDLE(h-b1wgen0052) THEN
        RUN sistema/generico/procedures/b1wgen0052.p 
            PERSISTENT SET h-b1wgen0052.

    RUN Valida_Inicio_Inclusao IN h-b1wgen0052 
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT 1,           
          INPUT tel_inpessoa,
          INPUT tel_cdagenci,
          INPUT TRUE,
          INPUT glb_dtmvtolt,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro) NO-ERROR .

    IF  VALID-HANDLE(h-b1wgen0052) THEN  
        DELETE PROCEDURE h-b1wgen0052.

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

    RETURN "OK".

END PROCEDURE.

PROCEDURE Valida_Procurador:

    ASSIGN glb_cddopcao = "I".

    IF NOT VALID-HANDLE(h-b1wgen0052) THEN
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
         OUTPUT TABLE tt-erro) NO-ERROR .

    IF  VALID-HANDLE(h-b1wgen0052) THEN 
        DELETE PROCEDURE h-b1wgen0052.

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

    ASSIGN glb_cddopcao = "I".

    IF NOT VALID-HANDLE(h-b1wgen0052) THEN
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
          INPUT glb_dtmvtoan,
          INPUT ?,
          INPUT tel_inpessoa, 
          INPUT tel_cdagenci,
          INPUT DEC(tel_nrcpfcgc),
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
          INPUT aux_dtdebito,
          INPUT aux_qtparcel,
          INPUT aux_vlparcel,
          INPUT tel_inhabmen,
          INPUT tel_dthabmen,
          INPUT "",
          INPUT 0, 
          INPUT 0,
          INPUT TABLE tt-crapavt,
          INPUT TABLE tt-resp,
          INPUT TABLE tt-bens,
          2, /** Campo somente no Ayllos WEB **/
          0, /** Campo somente no Ayllos WEB **/
         OUTPUT aux_msgretor,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrecad,
         OUTPUT TABLE tt-erro) NO-ERROR.
    
    IF  VALID-HANDLE(h-b1wgen0052) THEN
        DELETE PROCEDURE h-b1wgen0052.
    
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

		MESSAGE aux_msgretor VIEW-AS ALERT-BOX.
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


