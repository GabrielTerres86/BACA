/* ............................................................................

   Programa: fontes/contas_endereco.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Junho/2006                         Ultima Atualizacao: 13/08/2015

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes ao endereco do Associado

   Alteracoes: 22/12/2006 - Corrigido o HIDE do frame (Evandro).
   
               05/01/2007 - Modificado tratamento para atualizacao do campo
                            crapalt.tpaltera, quando o operador aceitar
                            endereco cadastrado via web (Diego).

               06/06/2007 - Nao permite utilizar ";" nos campos endereco,
                            complemento, bairro e cidade (Elton).

               19/06/2009 - Criar registro na crapbem quando o imovel for
                            quitado ou financiado (Gabriel).
                            
               19/05/2010 - Utilizar a BO b1wgen0038.p (David).
               
               22/09/2010 - Bloqueia edição em conta filha (Gabriel - DB1).
               
               07/04/2011 - Inclusão de CEP integrado. (André - DB1)
               
               28/04/2011 - Inclusão de campo inicio de residencia. 
                            (André - DB1)
                            
               30/05/2011 - Alteracao do format dos campos nmbairro e nmcidade.
                            (Fabricio)
                         
               03/06/2011 - Alteracao do posicionamento de campos do endereco.
                            (Jorge)
                      
               15/06/2011 - Verificacao de endereco x correios (Jorge).
               
               01/07/2011 - Criados campos nrdoapto e cddbloco (Henrique).
               
               13/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
			   
			   01/02/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)
.............................................................................*/

{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF VAR tel_dscasprp AS CHAR FORMAT "x(10)"                            NO-UNDO.
DEF VAR tel_dsendere AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_complend AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_nmbairro AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_nmcidade AS CHAR FORMAT "x(25)"                            NO-UNDO.
DEF VAR tel_cdufende AS CHAR FORMAT "!(2)"                             NO-UNDO.
DEF VAR tel_incasprp AS INTE FORMAT "9"                                NO-UNDO.
DEF VAR tel_nrcepend AS INTE FORMAT "99999,999"                        NO-UNDO.
DEF VAR tel_nrendere AS INTE FORMAT "zzz,zz9"                          NO-UNDO.
DEF VAR tel_nrcxapst AS INTE FORMAT "zz,zz9"                           NO-UNDO.
DEF VAR tel_cdseqinc AS INTE                                           NO-UNDO.
DEF VAR tel_vlalugue AS DECI FORMAT "zzz,zzz,zz9.99"                   NO-UNDO.
DEF VAR tel_dtinires AS CHAR FORMAT "x(7)"                             NO-UNDO.
DEF VAR tel_nranores AS CHAR FORMAT "x(20)"                            NO-UNDO.
DEF VAR tel_nrdoapto AS INTE FORMAT "zzz9"                             NO-UNDO.
DEF VAR tel_cddbloco AS CHAR FORMAT "x(3)"                             NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR FORMAT "x(07)" INIT "Alterar"             NO-UNDO.

DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_qtprebem AS INTE                                           NO-UNDO.
DEF VAR aux_vlprebem AS DECI                                           NO-UNDO.
DEF VAR aux_tpendass AS INTE                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.

DEF VAR h-b1wgen0038 AS HANDLE                                         NO-UNDO.
DEF VAR aux_msgconta AS CHARACTER                                      NO-UNDO.

FORM SKIP(1)
     tel_incasprp AT 08 LABEL "Tipo do Imovel"
         HELP "Informe 1-quitado,2-financ,3-alugado,4-familiar,5-cedido"
     tel_dscasprp NO-LABEL 
     tel_vlalugue AT 42 LABEL "Valor do Imovel"
         HELP "Informe o valor do imovel ou valor do aluguel" 
     SKIP
     tel_dtinires AT 02 LABEL "Inicio de Residencia"
        HELP "Informe o inicio de residencia (mm/aaaa)."
     tel_nranores AT 41 LABEL "Tempo Residencia"
     SKIP(1)
     tel_nrcepend AT 05 LABEL "CEP"
         HELP "Informe o Cep do endereco ou pressione F7 para pesquisar"
     tel_dsendere AT 21 LABEL "Rua"
         HELP "Informe o Endereco do imovel"
     tel_nrendere AT 67 LABEL "Nr"
         HELP  "Informe o numero da residencia"
     SKIP
     tel_complend AT 02 LABEL "Compl."
         HELP  "Informe o complemento do endereco"
     tel_nrdoapto AT 52 LABEL "Apto" 
         HELP "Informe o numero do apartamento"
     tel_cddbloco AT 64 LABEL "Bloco" 
         HELP "Informe o bloco"
     SKIP
     tel_nmbairro AT 02 LABEL "Bairro"
         HELP "Informe o nome do bairro"
     tel_nrcxapst AT 57 LABEL "Caixa Postal"
         HELP  "Numero da caixa postal"
     SKIP
     tel_nmcidade AT 02 LABEL "Cidade"
         HELP "Informe o nome da cidade"
     tel_cdufende AT 65 LABEL "U.F."
         HELP "Informe a Sigla do Estado"
     SKIP(1)
     reg_dsdopcao AT 37 NO-LABEL
         HELP "Pressione ENTER para selecionar ou F4/END para sair"
     WITH ROW 10 WIDTH 80 OVERLAY SIDE-LABELS TITLE " ENDERECO " CENTERED 
          FRAME f_endereco.

FORM SKIP(1)
     "-------------------------------"
     "ENDERECO ATUAL"
     "-------------------------------"
     SKIP
     tel_nrcepend AT 05 LABEL "CEP"
     tel_dsendere AT 21 LABEL "Rua"
     tel_nrendere AT 67 LABEL "Nr"
     SKIP      
     tel_complend AT 02 LABEL "Compl." 
     tel_nrdoapto AT 52 LABEL "Apto"
     tel_cddbloco AT 64 LABEL "Bloco" 
     SKIP
     tel_nmbairro AT 02 LABEL "Bairro"
     tel_nrcxapst AT 57 LABEL "Caixa Postal"
     SKIP
     tel_nmcidade AT 02 LABEL "Cidade"
     tel_cdufende AT 65 LABEL "U.F."
     
     SKIP(1)
     "-------------------"
     "NOVO ENDERECO (ALTERADO PELA INTERNET)"
     "-------------------"
     SKIP
     tt-endereco-cooperado.nrcepend AT 05 LABEL "CEP"          FORMAT "99999,999"
     tt-endereco-cooperado.dsendere AT 21 LABEL "Rua"          FORMAT "x(40)"
     tt-endereco-cooperado.nrendere AT 67 LABEL "Nr"           FORMAT "zzz,zz9"
     SKIP
     tt-endereco-cooperado.complend AT 02 LABEL "Compl."       FORMAT "x(40)"
     tt-endereco-cooperado.nrdoapto AT 52 LABEL "Apto"         FORMAT "zzz9"
     tt-endereco-cooperado.cddbloco AT 64 LABEL "Bloco"        FORMAT "x(3)"
     SKIP
     tt-endereco-cooperado.nmbairro AT 02 LABEL "Bairro"       FORMAT "x(40)"
     tt-endereco-cooperado.nrcxapst AT 51 LABEL "Caixa Postal" FORMAT "zz,zz9" 
     SKIP
     tt-endereco-cooperado.nmcidade AT 02 LABEL "Cidade"       FORMAT "x(25)"
     tt-endereco-cooperado.cdufende AT 51 LABEL "U.F."         FORMAT "!(2)"
     
     WITH ROW 8 WIDTH 80 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
          " ATUALIZACAO DE ENDERECO " CENTERED FRAME f_atualiza_endereco.

/* Inclusão de Inicio de Residencia. (André - DB1)*/
ON RETURN, LEAVE, GO OF tel_dtinires IN FRAME f_endereco DO:

    ASSIGN INPUT tel_dtinires.

    IF  tel_dtinires <> "" THEN
        DO:
            
            IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
                RUN sistema/generico/procedures/b1wgen0038.p 
                    PERSISTENT SET h-b1wgen0038.
        
            RUN trata-inicio-resid IN h-b1wgen0038 
                ( INPUT glb_cdcooper,
                  INPUT 0,
                  INPUT 0,
                  INPUT tel_dtinires,
                 OUTPUT tel_nranores,
                 OUTPUT TABLE tt-erro ).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    RUN mostra-critica.           
                    RETURN NO-APPLY.
                END.
        
            DISPLAY tel_nranores WITH FRAME f_endereco.
        END.
    ELSE
        DO:
            ASSIGN tel_nranores = "".
            DISPLAY tel_nranores WITH FRAME f_endereco.
        END.


END.


/* Inclusão de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_nrcepend IN FRAME f_endereco DO:
    IF  INPUT tel_nrcepend = 0  THEN
        RUN Limpa_Endereco.
END.

ON RETURN OF tel_nrcepend IN FRAME f_endereco DO:

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
                    RUN Limpa_Endereco.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco.

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende  
            WITH FRAME f_endereco.

    NEXT-PROMPT tel_nrendere WITH FRAME f_endereco.
END.
    
ON LEAVE OF tel_incasprp IN FRAME f_endereco DO:

    tel_dscasprp = DYNAMIC-FUNCTION("BuscaDescricaImovel" IN h-b1wgen0038,
                                    INPUT INPUT tel_incasprp).
                    
    DISPLAY tel_dscasprp WITH FRAME f_endereco.
   
END.

ASSIGN aux_flgerlog = TRUE.

DO WHILE TRUE:

    IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
        RUN sistema/generico/procedures/b1wgen0038.p 
            PERSISTENT SET h-b1wgen0038.

    RUN obtem-endereco IN h-b1wgen0038 
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT aux_flgerlog,
         OUTPUT aux_msgconta,
         OUTPUT aux_inpessoa,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-endereco-cooperado).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.           
            LEAVE.
        END.

    ASSIGN tel_incasprp = 0                  
           tel_dscasprp = ""                 
           tel_dtinires = ""                 
           tel_nranores = ""                 
           tel_vlalugue = 0                  
           tel_nrcepend = 0                  
           tel_dsendere = "" 
           tel_nrendere = 0  
           tel_complend = ""
           tel_nrdoapto = 0
           tel_cddbloco = ""     
           tel_nmbairro = "" 
           tel_nmcidade = ""
           tel_cdufende = ""
           tel_nrcxapst = 0.
    
    FIND FIRST tt-endereco-cooperado NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-endereco-cooperado  THEN
        ASSIGN tel_incasprp = tt-endereco-cooperado.incasprp
               tel_dscasprp = tt-endereco-cooperado.dscasprp
               tel_dtinires = tt-endereco-cooperado.dtinires
               tel_vlalugue = tt-endereco-cooperado.vlalugue
               tel_nrcepend = tt-endereco-cooperado.nrcepend
               tel_dsendere = tt-endereco-cooperado.dsendere
               tel_nrendere = tt-endereco-cooperado.nrendere
               tel_complend = tt-endereco-cooperado.complend
               tel_nrdoapto = tt-endereco-cooperado.nrdoapto
               tel_cddbloco = tt-endereco-cooperado.cddbloco
               tel_nmbairro = tt-endereco-cooperado.nmbairro
               tel_nmcidade = tt-endereco-cooperado.nmcidade
               tel_cdufende = tt-endereco-cooperado.cdufende
               tel_nrcxapst = tt-endereco-cooperado.nrcxapst
               aux_qtprebem = tt-endereco-cooperado.qtprebem
               aux_vlprebem = tt-endereco-cooperado.vlprebem.

    /* Inclusão de Inicio de Residencia. (André - DB1)*/
    IF  NOT VALID-HANDLE(h-b1wgen0038)  THEN
        RUN sistema/generico/procedures/b1wgen0038.p 
            PERSISTENT SET h-b1wgen0038.

    IF  tel_dtinires <> ""  THEN
        DO:
            RUN trata-inicio-resid IN h-b1wgen0038 
                ( INPUT glb_cdcooper,
                  INPUT 0,
                  INPUT 0,
                  INPUT tel_dtinires,
                 OUTPUT tel_nranores,
                 OUTPUT TABLE tt-erro ).
        
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    RUN mostra-critica.           
                    RETURN NO-APPLY.
                END.
        END.

    DISPLAY tel_incasprp  
            tel_dscasprp 
            tel_dtinires
            tel_nranores  
            tel_vlalugue
            tel_nrcepend  
            tel_dsendere  
            tel_nrendere 
            tel_complend
            tel_nrdoapto
            tel_cddbloco
            tel_nmbairro  
            tel_nmcidade  
            tel_cdufende  
            tel_nrcxapst
            reg_dsdopcao  
            WITH FRAME f_endereco.
            
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CHOOSE FIELD reg_dsdopcao WITH FRAME f_endereco.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
            LEAVE.
        END.

    HIDE MESSAGE NO-PAUSE.
    
    /*Alteração: Mostra critica se usuario titular em outra conta 
     (Gabriel/DB1)*/
    IF  aux_msgconta <> "" THEN
        DO:
           MESSAGE aux_msgconta. 
           NEXT.
        END.

    ASSIGN glb_nmrotina = "ENDERECO"
           glb_cddopcao = "A".
   
    { includes/acesso.i }
    
    RUN verifica-atualizacao.
   
    IF  RETURN-VALUE = "OK"  THEN
        NEXT.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
        UPDATE tel_incasprp  
               tel_vlalugue
               tel_dtinires
               tel_nrcepend  
               tel_nrendere
               tel_complend  
               tel_nrdoapto
               tel_cddbloco
               tel_nrcxapst
               WITH FRAME f_endereco

        EDITING:

            READKEY.
            HIDE MESSAGE NO-PAUSE.

            IF  LASTKEY = KEYCODE("F7")  THEN
                DO:
                    IF  FRAME-FIELD = "tel_nrcepend"  THEN
                        DO:

                            /* Inclusão de CEP integrado. (André - DB1) */
                            RUN fontes/zoom_endereco.p 
                                ( INPUT 0,
                                 OUTPUT TABLE tt-endereco ).

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
                                    tel_cdufende
                                    WITH FRAME f_endereco.

                            IF  KEYFUNCTION(LASTKEY) <> "END-ERROR"  THEN
                                NEXT-PROMPT tel_nrendere 
                                            WITH FRAME f_endereco.
                        END.
                END.
            ELSE
                APPLY LASTKEY.
        END.

        ASSIGN aux_tpendass = IF   aux_inpessoa = 1   THEN
                                   10 /* Residencial */
                              ELSE 
                                   9. /* Comercial   */

        RUN validar-endereco IN h-b1wgen0038 
            ( INPUT glb_cdcooper,
              INPUT 0,
              INPUT 0,
              INPUT glb_cdoperad,
              INPUT glb_nmdatela,
              INPUT 1,
              INPUT tel_nrdconta,
              INPUT tel_idseqttl,
              INPUT tel_incasprp,
              INPUT tel_dtinires,
              INPUT tel_vlalugue,
              INPUT tel_dsendere,
              INPUT tel_nrendere,
              INPUT tel_nrcepend,
              INPUT tel_complend,
              INPUT tel_nrdoapto,
              INPUT tel_cddbloco,
              INPUT tel_nmbairro,
              INPUT tel_nmcidade,
              INPUT tel_cdufende,
              INPUT tel_nrcxapst,
              INPUT aux_tpendass, /* Tipo endereco Residencial/Comercial */
              INPUT FALSE,
              INPUT TRUE,
             OUTPUT TABLE tt-erro ).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                RUN mostra-critica.
                NEXT.
            END.

        LEAVE.
        
    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        NEXT.

    RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

    IF   aux_confirma <> "S"   THEN          
         NEXT.

    IF  VALID-HANDLE(h-b1wgen0038)  THEN
        DELETE OBJECT h-b1wgen0038.

    RUN sistema/generico/procedures/b1wgen0038.p PERSISTENT SET h-b1wgen0038.

    RUN alterar-endereco IN h-b1wgen0038 
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT glb_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT tel_incasprp,
          INPUT tel_dtinires,
          INPUT tel_vlalugue,
          INPUT tel_dsendere,
          INPUT tel_nrendere,
          INPUT tel_nrcepend,
          INPUT tel_complend,
          INPUT tel_nrdoapto,
          INPUT tel_cddbloco,
          INPUT tel_nmbairro,
          INPUT tel_nmcidade,
          INPUT tel_cdufende,
          INPUT tel_nrcxapst,
          INPUT aux_qtprebem,
          INPUT aux_vlprebem,
          INPUT aux_tpendass,
          INPUT TRUE,
          2, /** Origem **/
         OUTPUT aux_msgalert,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrvcad,
         OUTPUT TABLE tt-erro ). 

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-critica.
            NEXT.
        END.

    IF  aux_msgalert <>""  THEN
        DO:
            MESSAGE aux_msgalert.
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE. 
        END.

    RUN proc_altcad (INPUT "b1wgen0038.p").
    
    IF aux_msgrvcad <> "" THEN
       MESSAGE aux_msgrvcad.

    IF  VALID-HANDLE(h-b1wgen0038)  THEN
        DELETE OBJECT h-b1wgen0038.

    MESSAGE "Alteracao efetuada com sucesso!.".
     
END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_endereco NO-PAUSE.

IF  VALID-HANDLE(h-b1wgen0038)  THEN
    DELETE PROCEDURE h-b1wgen0038.
     
/*...........................................................................*/

PROCEDURE verifica-atualizacao:

    RUN obtem-atualizacao-endereco IN h-b1wgen0038 
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT TRUE,
         OUTPUT TABLE tt-endereco-cooperado,
         OUTPUT TABLE tt-msg-endereco ).

    FIND FIRST tt-endereco-cooperado NO-LOCK NO-ERROR.

    

    IF  NOT AVAILABLE tt-endereco-cooperado  THEN
        RETURN "NOK".
    
    DISPLAY tel_nrcepend 
            tel_dsendere
            tel_nrendere 
            tel_complend
            tel_nrdoapto 
            tel_cddbloco 
            tel_nmbairro 
            tel_nmcidade
            tel_cdufende 
            tel_nrcxapst
            tt-endereco-cooperado.nrcepend    
            tt-endereco-cooperado.dsendere
            tt-endereco-cooperado.nrendere    
            tt-endereco-cooperado.complend
            tt-endereco-cooperado.nrdoapto
            tt-endereco-cooperado.cddbloco
            tt-endereco-cooperado.nmbairro    
            tt-endereco-cooperado.nmcidade
            tt-endereco-cooperado.cdufende   
            tt-endereco-cooperado.nrcxapst
            WITH FRAME f_atualiza_endereco.
                     
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
        FIND FIRST tt-msg-endereco NO-LOCK NO-ERROR.
        
        IF AVAIL tt-msg-endereco THEN
        DO:
            MESSAGE tt-msg-endereco.dsmsagem.
            PAUSE.
        END.
        
        ASSIGN aux_confirma = "N".
        MESSAGE "Deseja substituir ENDERECO ATUAL pelo ENDERECO da INTERNET?" 
                UPDATE aux_confirma.
                
        IF  aux_confirma <> "S"  THEN
            DO:
                ASSIGN aux_confirma = "N".
                 
                MESSAGE "Deseja EXCLUIR endereco cadastrado na INTERNET?" 
                        UPDATE aux_confirma.
                         
                IF  aux_confirma <> "S"  THEN
                    DO:
                        HIDE FRAME f_atualiza_endereco NO-PAUSE.
                        RETURN "NOK".
                    END.    

                RUN atualiza-endereco-internet (INPUT "E").

                IF  RETURN-VALUE = "NOK"  THEN
                    RETURN "OK".
            END.
        ELSE
            DO:
                RUN atualiza-endereco-internet (INPUT "A").

                IF  RETURN-VALUE = "NOK"  THEN
                    RETURN "OK".
            END.                
     
        LEAVE.
    
    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_atualiza_endereco NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        RETURN "NOK".

    RUN proc_altcad (INPUT "b1wgen0038.p").

    MESSAGE "Alteracao efetuada com sucesso!".
    
    RETURN "OK".
         
END PROCEDURE.

PROCEDURE atualiza-endereco-internet:

    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    RUN gerenciar-atualizacao-endereco IN h-b1wgen0038 
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT par_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT TRUE,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT TABLE tt-erro ).

    IF  RETURN-VALUE = "NOK"  THEN
        DO: 
            RUN mostra-critica.
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE mostra-critica:

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            BELL.
            MESSAGE tt-erro.dscritic.
        END.

END PROCEDURE.

PROCEDURE Limpa_Endereco:
    ASSIGN tel_nrcepend = 0  
           tel_dsendere = ""  
           tel_nmbairro = "" 
           tel_nmcidade = ""  
           tel_cdufende = ""
           tel_nrendere = 0
           tel_complend = ""
           tel_nrdoapto = 0
           tel_cddbloco = ""
           tel_nrcxapst = 0.

    DISPLAY tel_nrcepend  tel_dsendere
            tel_nmbairro  tel_nmcidade
            tel_cdufende  tel_nrendere
            tel_complend  tel_nrdoapto
            tel_cddbloco  tel_nrcxapst WITH FRAME f_endereco.
END PROCEDURE.




/*...........................................................................*/
