/* .............................................................................

   Programa: Includes/cadpacc.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes
   Data    : Marco/2004                        Ultima Atualizacao: 15/09/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela CADPAC(Cadastramento PAC)
        
   Alteracao : 07/07/2004 - Acessar tabela GENERI(LOCALIDADE)- Cidade do PAC
                            (Mirtes)

               23/08/2004 - Acrescentar Endereco dos PAC nos talonarios (ZE).

               03/05/2005 - Acrescentar Ag.Relacionamento COBAN(Mirtes)   
                  
               26/08/2005 - Tratar situacao do PAC (Edson).

               12/01/2006 - Tratar pacs para o PROGRID (Rosangela).
               
               08/02/2006 - Tratar horarios das guias GPS e DOCTOS (Evandro).
               
               10/02/2006 - Unificacao dos bancos de dados - SQLWorks - Andre
               
               10/01/2007 - Incluido novos campos na tela e substituido dados 
                            da craptab por dados da crapage (Elton).

               25/06/2007 - Modificar consulta de horario para titulo
                          - Consultar horario para transferencia pela internet
                            (David).
              
               18/10/2007 - Includios os campos  Orgao pagador e Agencia 
                            Pioneira (Gabriel).             
                            
               16/11/2007 - Incluido campo plano de capital internet(Guilherme)
               
               25/04/2008 - Incluir campos (qtddaglf,qtddlslf) e parametro
                            para segundo processo de agendamentos (David).
                          - Incluido campo "Verificar Pend.COBAN" com
                            informacoes da crapage.vercoban (Elton).
                          - Incluir campos para canc. de pagamentos(Guilherme).

                            
               26/08/2009 - Substituicao do campo banco/agencia da COMPE, 
                            para o banco/agencia COMPE de CHEQUE/DOC/TITULO
                            (Sidnei - Precise).                           
                            
               30/11/2009 - Incluir campo crapage.vllimapv que armazena o
                            Valor de Aprovacao do Comite Local para crédito
                            (David).

               19/05/2010 - Incluido na tela campo "Envelopes"
                            (Sandro-GATI)  
                            
               11/10/2010 - Incluido o campo "Qtde. Max. de cheques por previa"
                            (Adriano).             
                            
               22/02/2011 - Incluir campo 'Regional' (Gabriel).             
               
               10/05/2011 - Incluido campo "Geracao Boletos Registrada"
                            (Adriano).
                            
               09/02/2012 - Retirado os tratamentos de malote, agencia 
                            agrupadora para a inclusao da agencia do PAC
                            (Adriano).                       
 
               25/05/2012 - Removido campo tel_cdagectl. (David Kruger).
               
               01/04/2013 - Adicionados campos relativos ao horário limite para
                            pagmto de conv. SICREDI
                          - Inclusao campos convenios SICREDI (Lucas).
                          
               11/04/2013 - Incluir campos tel_vlminsgr, tel_vlmaxsgr
                            no frame f_pac04 (Lucas R.).
                            
               21/06/2013 - Inclusão dos campos tel_tpageins, tel_cdorgins
                            no frame f_pac04 (Reinert).
                            
               15/01/2014 - Alterada critica "15 - Agencia nao cadastrada" para
                            "962 - PA nao cadastrado". (Reinert)
                            
               18/08/2014 - Inclusao dos Horarios do Credito Pre Aprovado.
                            (Jaison)
                            
               15/09/2014 - Inclusao do parametro de quantidade de meses
                            para agendamento de aplicacao/resgate (Tiago/Gielow)                            
............................................................................. */
                  
FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                   crapage.cdagenci = tel_cdagenci 
                   NO-LOCK NO-ERROR NO-WAIT.
                            
IF NOT AVAILABLE crapage  THEN
   DO:
       ASSIGN glb_cdcritic = 962.
       RUN fontes/critic.p.
       ASSIGN glb_cdcritic = 0.

       BELL.
       MESSAGE glb_dscritic.
       
       CLEAR FRAME f_pac NO-PAUSE.   
       DISPLAY tel_cdagenci WITH FRAME f_pac.   
       NEXT.

   END.

ASSIGN tel_nmextage    = crapage.nmextage
       tel_insitage    = crapage.insitage
       tel_nmresage    = crapage.nmresage
       tel_cdcxaage    = crapage.cdcxaage
       tel_tpagenci    = crapage.tpagenci
       tel_cdccuage    = crapage.cdccuage
       tel_cdorgpag    = crapage.cdorgpag
       tel_cdagecbn    = crapage.cdagecbn
       tel_vercoban    = crapage.vercoban
       tel_cdcomchq    = crapage.cdcomchq
       tel_cdbantit    = crapage.cdbantit   
       tel_cdbanchq    = crapage.cdbanchq
       tel_cdbandoc    = crapage.cdbandoc
       tel_cdagetit    = crapage.cdagetit
       tel_cdagechq    = crapage.cdagechq
       tel_cdagedoc    = crapage.cdagedoc
       tel_flgdsede    = crapage.flgdsede
       tel_dsendcop    = crapage.dsendcop
       tel_nmbairro    = crapage.nmbairro
       tel_dscomple    = crapage.dscomple
       tel_nrcepend    = crapage.nrcepend
       tel_nmcidade    = crapage.nmcidade
       tel_cdufdcop    = crapage.cdufdcop
       tel_dsdemail    = crapage.dsdemail
       tel_dsinform[1] = crapage.dsinform[1]
       tel_dsinform[2] = crapage.dsinform[2]
       tel_dsinform[3] = crapage.dsinform[3]
       tel_hhlimcan    = INTE(SUBSTR(STRING(crapage.hrcancel,
                                            "HH:MM:SS"),1,2))
       tel_mmlimcan    = INTE(SUBSTR(STRING(crapage.hrcancel,
                                            "HH:MM:SS"),4,2))
       tel_nrtelfax    = crapage.nrtelfax
       tel_qtddaglf    = crapage.qtddaglf
       tel_qtmesage    = crapage.qtmesage
       tel_qtddlslf    = crapage.qtddlslf
       tel_vllimapv    = crapage.vllimapv
       tel_qtchqprv    = crapage.qtchqprv
       tel_flgdopgd    = crapage.flgdopgd
       tel_cdageagr    = crapage.cdageagr
       tel_cddregio    = crapage.cddregio
       tel_cdagepac    = crapage.cdagepac
       tel_tpageins    = crapage.tpageins
       tel_cdorgins    = crapage.cdorgins
       tel_vlminsgr    = crapage.vlminsgr
       tel_vlmaxsgr    = crapage.vlmaxsgr.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRPLANCAPI" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.

IF AVAILABLE craptab  THEN
   ASSIGN aux_hrcapfim = INTE(SUBSTR(craptab.dstextab,3,5))
          aux_hrcapini = INTE(SUBSTR(craptab.dstextab,9,5))
          tel_hhcapfim = INTE(SUBSTR(STRING(aux_hrcapfim,"HH:MM:SS"),1,2))
          tel_mmcapfim = INTE(SUBSTR(STRING(aux_hrcapfim,"HH:MM:SS"),4,2))
          tel_hhcapini = INTE(SUBSTR(STRING(aux_hrcapini,"HH:MM:SS"),1,2))
          tel_mmcapini = INTE(SUBSTR(STRING(aux_hrcapini,"HH:MM:SS"),4,2)).
           
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRTRTITULO" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.
    
IF AVAILABLE craptab  THEN
   ASSIGN aux_hrtitfim = INTE(SUBSTR(craptab.dstextab,3,5))
          aux_hrtitini = INTE(SUBSTR(craptab.dstextab,9,5))
          tel_hhtitfim = INTE(SUBSTR(STRING(aux_hrtitfim,"HH:MM:SS"),1,2))
          tel_mmtitfim = INTE(SUBSTR(STRING(aux_hrtitfim,"HH:MM:SS"),4,2))
          tel_hhtitini = INTE(SUBSTR(STRING(aux_hrtitini,"HH:MM:SS"),1,2))
          tel_mmtitini = INTE(SUBSTR(STRING(aux_hrtitini,"HH:MM:SS"),4,2))
          tel_flsgproc = IF  SUBSTR(craptab.dstextab,15,3) = "SIM"  THEN
                             TRUE
                         ELSE
                             FALSE.
           
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRTRCOMPEL" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.

IF  AVAILABLE craptab  THEN
    ASSIGN aux_hrcompel = INTE(SUBSTR(craptab.dstextab,3,5))
           tel_hhcompel = INTE(SUBSTR(STRING(aux_hrcompel,"HH:MM:SS"),1,2))
           tel_mmcompel = INTE(SUBSTR(STRING(aux_hrcompel,"HH:MM:SS"),4,2)).
                       
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRGUIASGPS" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.
                   
IF  AVAILABLE craptab  THEN
    ASSIGN aux_hrguigps = INTE(SUBSTR(craptab.dstextab,3,5))
           tel_hhguigps = INTE(SUBSTR(STRING(aux_hrguigps,"HH:MM:SS"),1,2))
           tel_mmguigps = INTE(SUBSTR(STRING(aux_hrguigps,"HH:MM:SS"),4,2)).
              
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRTRENVELO" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.

IF AVAILABLE craptab  THEN
   ASSIGN aux_hrenvelo = INTE(SUBSTR(craptab.dstextab,1,5))
          tel_hhenvelo = INTE(SUBSTR(STRING(aux_hrenvelo,"HH:MM:SS"),1,2))
          tel_mmenvelo = INTE(SUBSTR(STRING(aux_hrenvelo,"HH:MM:SS"),4,2)).
ELSE
   ASSIGN aux_hrenvelo = INTE(SUBSTR("",1,5))
          tel_hhenvelo = INTE(SUBSTR(STRING(aux_hrenvelo,"HH:MM:SS"),1,2))
          tel_mmenvelo = INTE(SUBSTR(STRING(aux_hrenvelo,"HH:MM:SS"),4,2)).

FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRTRDOCTOS" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.
                   
IF AVAILABLE craptab  THEN
   ASSIGN aux_hrdoctos = INTE(SUBSTR(craptab.dstextab,3,5))
          tel_hhdoctos = INTE(SUBSTR(STRING(aux_hrdoctos,"HH:MM:SS"),1,2))
          tel_mmdoctos = INTE(SUBSTR(STRING(aux_hrdoctos,"HH:MM:SS"),4,2)).
    
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRTRANSFER" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.
     
IF AVAILABLE craptab  THEN
   ASSIGN aux_hrtrffim = INTE(SUBSTR(craptab.dstextab,3,5))
          aux_hrtrfini = INTE(SUBSTR(craptab.dstextab,9,5))
          tel_hhtrffim = INTE(SUBSTR(STRING(aux_hrtrffim,"HH:MM:SS"),1,2))
          tel_mmtrffim = INTE(SUBSTR(STRING(aux_hrtrffim,"HH:MM:SS"),4,2))
          tel_hhtrfini = INTE(SUBSTR(STRING(aux_hrtrfini,"HH:MM:SS"),1,2))
          tel_mmtrfini = INTE(SUBSTR(STRING(aux_hrtrfini,"HH:MM:SS"),4,2)).


FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRCOBRANCA" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.
     
IF AVAILABLE craptab  THEN
   ASSIGN aux_hrbolfim = INTE(SUBSTR(craptab.dstextab,1,5))
          aux_hrbolini = INTE(SUBSTR(craptab.dstextab,7,5))
          tel_hhbolfim = INTE(SUBSTR(STRING(aux_hrbolfim,"HH:MM:SS"),1,2))
          tel_mmbolfim = INTE(SUBSTR(STRING(aux_hrbolfim,"HH:MM:SS"),4,2))
          tel_hhbolini = INTE(SUBSTR(STRING(aux_hrbolini,"HH:MM:SS"),1,2))
          tel_mmbolini = INTE(SUBSTR(STRING(aux_hrbolini,"HH:MM:SS"),4,2)).

/* Param convenios SICREDI */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "GENERI"     AND
                   craptab.cdempres = 00           AND
                   craptab.cdacesso = "HRPGSICRED" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.

IF AVAILABLE craptab  THEN
   ASSIGN aux_hhsicini = STRING(INT(ENTRY(1,craptab.dstextab," ")),"HH:MM")
          aux_hhsicfim = STRING(INT(ENTRY(2,craptab.dstextab," ")),"HH:MM")
          aux_hhsiccan = STRING(INT(ENTRY(3,craptab.dstextab," ")),"HH:MM")
          tel_hhsicini = INTE(ENTRY(1, aux_hhsicini, ":"))
          tel_mmsicini = INTE(ENTRY(2, aux_hhsicini, ":"))
          tel_hhsicfim = INTE(ENTRY(1, aux_hhsicfim, ":"))
          tel_mmsicfim = INTE(ENTRY(2, aux_hhsicfim, ":"))
          tel_hhsiccan = INTE(ENTRY(1, aux_hhsiccan, ":"))
          tel_mmsiccan = INTE(ENTRY(2, aux_hhsiccan, ":")).

/* Parametro Credito Pre Aprovado */
FIND craptab WHERE craptab.cdcooper = glb_cdcooper    AND
                   craptab.nmsistem = "CRED"          AND
                   craptab.tptabela = "GENERI"        AND
                   craptab.cdempres = 00              AND
                   craptab.cdacesso = "HRCTRPREAPROV" AND
                   craptab.tpregist = tel_cdagenci 
                   NO-LOCK NO-ERROR.

IF AVAILABLE craptab  THEN
   ASSIGN aux_hhcpaini = STRING(INT(ENTRY(1,craptab.dstextab," ")),"HH:MM")
          aux_hhcpafim = STRING(INT(ENTRY(2,craptab.dstextab," ")),"HH:MM")
          tel_hhcpaini = INTE(ENTRY(1, aux_hhcpaini, ":"))
          tel_mmcpaini = INTE(ENTRY(2, aux_hhcpaini, ":"))
          tel_hhcpafim = INTE(ENTRY(1, aux_hhcpafim, ":"))
          tel_mmcpafim = INTE(ENTRY(2, aux_hhcpafim, ":")).

RUN fontes/le_situacao_pac.p (INPUT tel_insitage, 
                              OUTPUT tel_dssitage).

RUN fontes/digfun.p.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 

    DISPLAY tel_nmextage
            tel_insitage
            tel_dssitage
            tel_nmresage
            tel_cdcxaage 
            tel_tpagenci
            tel_cdccuage
            tel_cdorgpag
            tel_cdagecbn
            tel_vercoban
            tel_cdcomchq
            tel_cdbantit 
            tel_cdbanchq
            tel_cdbandoc
            tel_cdagetit
            tel_cdagechq
            tel_cdagedoc
            tel_flgdsede
            tel_cdagepac
            WITH FRAME f_pac01.
        
    PAUSE MESSAGE "Tecle <Enter> para continuar ou <End> para encerrar".
      
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       LEAVE.

    HIDE FRAME f_pac01.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        DISPLAY tel_dsendcop
                tel_nmbairro
                tel_dscomple
                tel_nrcepend
                tel_nmcidade
                tel_cdufdcop
                tel_dsdemail
                tel_dsinform[1]
                tel_dsinform[2]
                tel_dsinform[3]
                WITH FRAME f_pac02.

        PAUSE MESSAGE "Tecle <Enter> para continuar ou <End> para voltar".

        HIDE FRAME f_pac02.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            DISPLAY tel_hhtitini
                    tel_mmtitini
                    tel_hhtitfim
                    tel_mmtitfim
                    tel_hhcompel
                    tel_mmcompel
                    tel_hhcapini
                    tel_mmcapini
                    tel_hhcapfim
                    tel_mmcapfim
                    tel_hhdoctos
                    tel_mmdoctos
                    tel_hhtrfini
                    tel_mmtrfini 
                    tel_hhtrffim
                    tel_mmtrffim
                    tel_hhbolini
                    tel_mmbolini
                    tel_hhbolfim
                    tel_mmbolfim
                    tel_hhguigps
                    tel_mmguigps
                    tel_hhenvelo
                    tel_mmenvelo
                    tel_hhlimcan
                    tel_mmlimcan
                    tel_nrtelfax
                    tel_qtddaglf
                    tel_qtmesage
                    tel_qtddlslf
                    tel_flsgproc
                    tel_hhsicini
                    tel_mmsicini
                    tel_hhsicfim
                    tel_mmsicfim
                    tel_hhsiccan
                    tel_mmsiccan
                    tel_hhcpaini
                    tel_mmcpaini
                    tel_hhcpafim
                    tel_mmcpafim
                    WITH FRAME f_pac03.

            PAUSE MESSAGE "Tecle <Enter> para continuar ou <End> para voltar".

            HIDE FRAME f_pac03.

            FIND crapreg WHERE crapreg.cdcooper = glb_cdcooper   AND
                               crapreg.cddregio = tel_cddregio
                               NO-LOCK NO-ERROR.

            IF AVAIL crapreg   THEN
               ASSIGN tel_dsdregio = crapreg.dsdregio.
            ELSE
               ASSIGN tel_dsdregio = "".


            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               DISPLAY tel_vllimapv
                       tel_qtchqprv
                       tel_flgdopgd
                       tel_cdageagr
                       tel_cddregio
                       tel_dsdregio
                       tel_tpageins
                       tel_cdorgins
                       tel_vlminsgr
                       tel_vlmaxsgr
                       WITH FRAME f_pac04.

               PAUSE MESSAGE "Tecle <Enter> para continuar ou <End> para voltar".

               LEAVE.

            END.

            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
               NEXT.

            LEAVE.

        END. /** Fim do DO WHILE TRUE **/

        IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
           NEXT.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
       NEXT.
        
    LEAVE.
   
END. /** Fim do DO WHILE TRUE **/

HIDE MESSAGE NO-PAUSE.

ASSIGN tel_nmextage    = ""
       tel_insitage    = 0
       tel_dssitage    = "EM OBRAS"
       tel_nmresage    = ""
       tel_cdcxaage    = 0
       tel_tpagenci    = 0
       tel_cdccuage    = 0
       tel_cdorgpag    = 0
       tel_cdagecbn    = 0
       tel_vercoban    = TRUE
       tel_cdcomchq    = 0
       tel_cdbantit    = 0
       tel_cdbanchq    = 0
       tel_cdbandoc    = 0
       tel_cdagetit    = 0
       tel_cdagechq    = 0
       tel_cdagedoc    = 0
       tel_flgdsede    = FALSE
       tel_dsendcop    = ""
       tel_nmbairro    = ""
       tel_dscomple    = ""
       tel_nrcepend    = 0
       tel_nmcidade    = ""
       tel_cdufdcop    = ""
       tel_dsdemail    = ""
       tel_dsinform[1] = ""
       tel_dsinform[2] = ""
       tel_dsinform[3] = ""
       tel_hhcapfim    = 0
       tel_mmcapfim    = 0
       tel_hhcapini    = 0
       tel_mmcapini    = 0
       tel_hhtitfim    = 0
       tel_mmtitfim    = 0
       tel_hhtitini    = 0
       tel_mmtitini    = 0
       tel_hhbolini    = 0
       tel_mmbolini    = 0
       tel_hhbolfim    = 0
       tel_mmbolfim    = 0
       tel_flsgproc    = FALSE
       tel_hhcompel    = 0
       tel_mmcompel    = 0
       tel_hhguigps    = 0
       tel_mmguigps    = 0
       tel_hhenvelo    = 0
       tel_mmenvelo    = 0
       tel_hhdoctos    = 0
       tel_mmdoctos    = 0
       tel_hhtrffim    = 0
       tel_mmtrffim    = 0
       tel_hhtrfini    = 0
       tel_mmtrfini    = 0
       tel_hhlimcan    = 0
       tel_mmlimcan    = 0
       tel_nrtelfax    = ""
       tel_qtddaglf    = 0
       tel_qtmesage    = 0
       tel_qtddlslf    = 0
       tel_vllimapv    = 0
       tel_qtchqprv    = 0
       tel_flgdopgd    = FALSE
       tel_cdageagr    = 0
       tel_cddregio    = 0
       tel_tpageins    = 0
       tel_cdorgins    = 0
       tel_dsdregio    = ""
       tel_cdagepac    = 0
       aux_hrtitini    = 0 
       aux_hrtitfim    = 0 
       aux_hrtrfini    = 0 
       aux_hrtrffim    = 0 
       aux_hrbolini    = 0 
       aux_hrbolfim    = 0 
       aux_hrcapini    = 0 
       aux_hrcapfim    = 0 
       aux_hrcompel    = 0 
       aux_hrdoctos    = 0 
       aux_hrguigps    = 0 
       aux_hrenvelo    = 0 
       aux_hrcancel    = 0
       tel_hhsicini    = 0
       tel_mmsicini    = 0
       tel_hhsicfim    = 0
       tel_mmsicfim    = 0
       tel_hhsiccan    = 0
       tel_mmsiccan    = 0
       tel_hhcpaini    = 0
       tel_mmcpaini    = 0
       tel_hhcpafim    = 0
       tel_mmcpafim    = 0.
       
CLEAR FRAME f_pac   NO-PAUSE.
CLEAR FRAME f_pac01 NO-PAUSE.
CLEAR FRAME f_pac02 NO-PAUSE.
CLEAR FRAME f_pac03 NO-PAUSE.
CLEAR FRAME f_pac04 NO-PAUSE.

HIDE FRAME f_pac01 NO-PAUSE.
HIDE FRAME f_pac02 NO-PAUSE. 
HIDE FRAME f_pac03 NO-PAUSE.
HIDE FRAME f_pac04 NO-PAUSE.

/* .......................................................................... */
