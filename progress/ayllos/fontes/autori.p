/*.............................................................................

   Programa: Fontes/autori.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/95.                       Ultima atualizacao: 10/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela AUTORI.

   Alteracoes: 15/08/95 - Alterado para permitir alterar a data de cancelamento
                          (Deborah).

               19/12/95 - Alterado para incluir o DDD e conferir o digito do
                          telefone (Deborah).

               30/08/96 - Alterado para nao permitir inclusoes, alteracoes e
                          exclusoes no historico 31 fora do periodo (Odair).

               07/11/96 - Alterado para conferir digito historico 48 (Odair)

               09/04/97 - Permitir incluir quando sistema coloca data de
                          cancelamento (Odair).

               09/01/98 - Alterado para permitir excluir as autorizacoes que
                          estejam canceladas e ja foram enviadas as empresas.
                          (Deborah)

               05/03/98 - Tratar datas do milenio (Odair)

               28/04/98 - Alterado para nao deixar excluir se ja tiver
                          lancamentos (Deborah).

               29/05/98 - Deixar alterar telesc  a qualquer momento (Odair)

               10/07/98 - Tratar telesc celular (Odair)

               01/09/98 - Tratar B.T.V. (Odair)

               09/11/98 - Tratar situacao em prejuizo (Deborah).
               
               25/10/99 - Tratar telesc fixa e celular (Odair)
               
               13/12/99 - Colocar mais controles para TELESC e CELULAR (Odair)
               
             23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                          titular (Eduardo). 

             24/01/2001 - Incluir historico 371 (Margarete/Planner).

             29/03/2001 - Rejeitar num. de referencias maior que 9 para 
                          historico 371 - Global Telecom. (Eduardo).

             18/03/2002 - Liberado numeracao maior para a Casan (Deborah)
             
             10/05/2003 - Alteracao no calculo do Digito Verificador (ZE).
             
             14/08/2003 - Inclusao do tratamento do historico 149, 
                          SAMAE JARAGUA (Julio).
 
             29/09/2004 - Inclusao CELESC - CECRED (Julio)             
                                      
             03/11/2004 - Inclusao VIVO - CECRED (Julio)
             
             12/11/2004 - Incluida opcao "R";
                          Tratamento do tamanho da referencia - Celesc
                          (Evandro).
             
             26/11/2004 - Inclusao SAMAE TIMBO - CECRED (Julio)

             30/11/2004 - VIVO estava com calculo do digito igual ao da Global
                           Telecom. Mudou para calculo padrao (Julio)
                           
             13/01/2005 - Alterado para gerar log ("log/autori.log") (Evandro).
             
             24/01/2005 - Alterado a quantidade de digitos da VIVO de 10 p/ 11
                          (Julio)

             26/01/2005 - Tratamento SAMAE GASPAR CECRED (Julio).

             02/02/2005 - Tratamento SAMAE BLUMENAU CECRED -> 634 (Julio)
               
             15/04/2005 - Incluida critica tamanho(historico 31)(Mirtes)
             
             30/05/2005 - Tratamento Aguas Itapema -> 455 (Julio). 
                                
             22/06/2005 - Tratamento digito verificador SAMAE GASPAR (Julio)

             24/06/2005 - Alimentado campo cdcooper da tabela crapatr;
                          Implantada em todas as opcoes uma busca por codigo de
                          historicos ao teclar F7 (Diego).
                          
             05/07/2005 - Tratamento para codigo da UNIMED (Julio)    
                      
             05/08/2005 - Referencia UNIMED - plano empresaria tem somente 
                          6 digitos (Julio)
                          
             25/08/2005 - Tratamento para SAMAE Brusque -> 616 (Julio)
             
             20/10/2005 - Tratamento para SAMAE POMERODE -> 619 (Julio)
                          
             26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.    
             
             07/03/2006 - Mostrar 'DEB.CANCELADO' quando o debito for cancelado
                          apos ter sido programado (Evandro).
                          
             13/10/2006 - Tratamento para CELESC Distribuicao -> 667 (Julio)
             
             02/02/2007 - Tratamento para DAE Navegantes -> 672 (Elton).
             
             29/03/2007 - Alterado calculo do digito verificador para CELESC
                          (Elton).
             
             19/04/2007 - Permitido ao operador "799" utilizar a opcao "R"
                          (Elton).
                          
             24/10/2007 - Tratamento para Aguas de Joinville -> 554 (Elton).
             
             23/11/2007 - Tratamento para SEMASA Itajai -> 674 (Elton).
             
             16/04/2008 - Retirada a critica "450" nas opcoes "C" e "E" (Elton).
             
             28/04/2008 - Alterado para convenio SEMASA "674" utilizar calculo
                          do digito verificador utilizado pelo programa
                          "fontes/dig_semasa.p" (Elton).

             09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                          glb_cdcooper) no "find" da tabela CRAPHIS. 
                        - Incluido parametro "glb_cdcooper" para possibilitar a
                          chamada do programa fontes/zoom_historicos.p. 
                        - Kbase IT Solutions - Paulo Ricardo Maciel.
 
             14/11/2008 - Incluir campo Nome da empresa somente como consulta
                          (Gabriel).
                          
             22/01/2009 - Nao permite cancelar debito se campo nmempres estiver
                          preenchido (Elton). 
                        - Retirar permissao do operador 799 (Gabriel).
                           
             10/02/2009 - Permitir ao operador 979 alterar (Gabriel).
             
             11/05/2009 - Alteracao CDOPERAD (Kbase).
             
             07/08/2009 - Nao permite inclusao de autorizacao para Uniodonto
                          (Elton).
             
             24/08/2009 - Permite inclusao de autorizacao para Uniodonto
                          (Elton).
                          
             14/09/2009 - Na opcao "A" quando retirar data de cancelamento 
                          retirar tambem o label "DEB.CANCELADO" (Elton).
                          
             19/10/2009 - Alteracao Codigo Historico (Kbase).            
             
             16/03/2010 - Ajuste para o programa do <F7> do historico
                          (Gabriel).
             
             18/05/2010 - Tratamento para Aguas Presidente Getulio -> 852;
                        - Tratamento para TIM Celular -> 834 conforme convenio
                          com historico 288 (Elton).
              
             01/10/2010 - Tratamento para Samae Rio Negrinho -> 900 (Elton).
             
             05/04/2011 - Tratamento para CERSAD -> 928;
                        - Tratamento para Foz do Brasil -> 961;
                        - Tratamento para Aguas de Massaranduba -> 962 (Elton).
                        
             05/05/2010 - Adaptacao para BO. (André - DB1)        
             
             03/09/2012 - Ajustes e melhorias no fonte (David Kruger).   
             
             05/08/2013 - Retirado chamada de procedure verifica-tabela-exec
                          pois nao sera mais utilizada (Lucas R.)
             
             19/05/2014 - Ajustado tela e melhorado layout - Projeto Debito
                          Automatico - Softdesk 148330
                          (Lucas R.)
                          
             15/09/2014 - Alteração de parâmetros na chamada da procedure
                          grava-dados para Projeto de Débito Automático Fácil
                          (Lucas Lunelli - Out/2014).
                          
             23/10/2014 - Descomentado UPDATE tel_flgsicre WITH FRAME f_autori
                          (Lucas R.)
                            
             03/02/2015 - Incluir parametro na procedure retorna-calculo-barras
                          (Lucas R. #242146)
                          
             05/03/2015 - Retirar condicao 
                          " crapscn.dsnomcnv MATCHES "*FEBRABAN*" "
                          do fonte (SD 233749 - Tiago).
                          
             10/04/2015 - #265405 Inclusao do parametro cdoperad na procedure
                          valida_conta_sicredi para validar o horario para
                          inclusao de deb auto sicredi pelo seu PA de trabalho
                          (Carlos)
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0092tt.i }

DEF VAR tel_nrdconta AS INTE    FORMAT "zzzz,zzz,9"                 NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                      NO-UNDO.
DEF VAR tel_cdhistor AS CHAR                                        NO-UNDO.
DEF VAR tel_dshistor AS CHAR    FORMAT "x(11)"                      NO-UNDO.
DEF VAR tel_cdrefere AS DECI    FORMAT "zzzzzzzzzzzzzzzzzzzzzzzzz"  NO-UNDO.
DEF VAR tel_dtautori AS DATE    FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_dtcancel AS DATE    FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_dtultdeb AS DATE    FORMAT "99/99/9999"                 NO-UNDO.
DEF VAR tel_dtvencto AS INTE    FORMAT "z9"                         NO-UNDO.
DEF VAR tel_nmfatura AS CHAR    FORMAT "x(40)"                      NO-UNDO.
DEF VAR tel_regante1 AS CHAR    FORMAT "x(75)"  EXTENT 4            NO-UNDO.
DEF VAR tel_regante2 AS CHAR    FORMAT "x(40)"  EXTENT 4            NO-UNDO.
DEF VAR tel_cddddtel AS INTE    FORMAT "zzz"                        NO-UNDO.
DEF VAR tel_dbcancel AS LOGI    FORMAT "DEB.CANCELADO/"             NO-UNDO.
DEF VAR tel_nmempres AS CHAR                                        NO-UNDO.

DEF VAR tel_flgsicre AS LOG     FORMAT "SIM/NAO"                    NO-UNDO.
DEF VAR tel_flgmanua AS LOG     FORMAT "SIM/NAO"                    NO-UNDO.
DEF VAR tel_codbarra AS CHAR    FORMAT "x(44)"                      NO-UNDO.
DEF VAR tel_fatura01 AS CHAR    FORMAT "x(12)"                      NO-UNDO.
DEF VAR tel_fatura02 AS CHAR    FORMAT "x(12)"                      NO-UNDO.
DEF VAR tel_fatura03 AS CHAR    FORMAT "x(12)"                      NO-UNDO.
DEF VAR tel_fatura04 AS CHAR    FORMAT "x(12)"                      NO-UNDO.
DEF VAR aux_nrcalcul AS CHAR                                        NO-UNDO.
DEF VAR aux_tamnrcal AS INT                                         NO-UNDO.
DEF VAR aux_nrdigito AS INTE                                        NO-UNDO.
DEF VAR aux_flgretor AS LOG                                         NO-UNDO.

DEF VAR aux_cdempcon AS INTE                                        NO-UNDO.
DEF VAR aux_cdsegmto AS CHAR                                        NO-UNDO.
DEF VAR aux_cdempres AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INTE    FORMAT "99"                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                       NO-UNDO.
DEF VAR par_nmprimtl AS CHAR                                        NO-UNDO.
DEF VAR par_cdsitdtl AS INTE                                        NO-UNDO.
DEF VAR par_nmprintl AS CHAR                                        NO-UNDO.
DEF VAR par_nmdcampo AS CHAR                                        NO-UNDO.
DEF VAR par_dshistor AS CHAR                                        NO-UNDO.
DEF VAR par_nmfatret AS CHAR                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.

DEF VAR aux_dsnomcnv AS CHAR                                        NO-UNDO.
DEF VAR h-b1wgen0092 AS HANDLE                                      NO-UNDO.

DEF QUERY q-empr-conve FOR craphis.
DEF QUERY q-empr-conve-sicre FOR crapscn.

DEF BROWSE b-empr-conve-sicre QUERY q-empr-conve-sicre
      DISP SPACE(2)
           cdempres COLUMN-LABEL "Convenio"
           SPACE(2)
           dsnomcnv COLUMN-LABEL "Descricao"
           WITH 9 DOWN OVERLAY NO-BOX.

DEF BROWSE b-empr-conve QUERY q-empr-conve
      DISP SPACE(2)
           cdhistor COLUMN-LABEL "Historico"
           SPACE(2)
           dsexthst COLUMN-LABEL "Descricao"
           WITH 9 DOWN OVERLAY NO-BOX.

DEF FRAME f-empr-conve-sicre
          b-empr-conve-sicre HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7 VIEW-AS DIALOG-BOX.

DEF FRAME f-empr-conve
          b-empr-conve HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7 VIEW-AS DIALOG-BOX.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao     AT  3 LABEL "Opcao" AUTO-RETURN
                            HELP "Informe a opcao desejada (C, E, I ou R)"
                            VALIDATE (CAN-DO("C,E,I,R",glb_cddopcao),
                                  "014 - Opcao errada.")
     tel_nrdconta     AT 13 FORMAT "zzzz,zzz,9" LABEL "Conta/dv" AUTO-RETURN
                            HELP "Informe o numero da conta do associado"
     tel_nmprimtl     AT 37 FORMAT "x(40)" NO-LABEL
     SKIP(1)
     tel_flgsicre     AT 4  FORMAT "SIM/NAO" LABEL "Sicredi" AUTO-RETURN
                            HELP "Informe Sim ou Nao." 
     tel_flgmanua     AT 22 FORMAT "SIM/NAO" LABEL "Manual" AUTO-RETURN
                            HELP "Informe Sim ou Nao."
     SKIP(1)
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_autori.

FORM "Codigo de barras: " AT 4
     tel_codbarra         FORMAT "x(44)" 
     SKIP(1)
     "Fatura: "           AT 4
     tel_fatura01         FORMAT "x(12)"
     "-"
     tel_fatura02         FORMAT "x(12)"
     "-"
     tel_fatura03         FORMAT "x(12)"
     "-"
     tel_fatura04         FORMAT "x(12)"
    SKIP(1)
    WITH COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_barras.

FORM " Convenio                          Referencia Dt.Autor.  Dt.Canc.   Ult.Deb."
     SKIP(1) 
     tel_dshistor     AT  2 FORMAT "x(17)" HELP "Informe o convenio ou tecle <ENTER> para listar."
     tel_cdrefere     AT 21
     tel_dtautori     AT 47 
     tel_dtcancel     AT 58
     tel_dtultdeb     AT 69
     tel_cdhistor
    WITH COLUMN 2 OVERLAY NO-LABEL NO-BOX FRAME f_autori_lista.

FORM tel_dshistor     AT  2 FORMAT "x(17)" 
                            HELP "Informe o historico ou tecle <ENTER> p/ Listar"
     tel_cdrefere     AT 21 
     tel_dtautori     AT 47  
     tel_dtcancel     AT 58 
     tel_dtultdeb     AT 69 
     WITH ROW 12 COLUMN 2 OVERLAY 8 DOWN NO-LABEL NO-BOX FRAME f_consulta.

ON END-ERROR OF b-empr-conve DO:

    DISABLE b-empr-conve WITH FRAME f-empr-conve.

    CLOSE QUERY q-empr-conve.
    HIDE FRAME f-empr-conve.

    NEXT-PROMPT tel_dshistor WITH FRAME f_autori_lista.

END.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0.

IF  NOT VALID-HANDLE(h-b1wgen0092)  THEN
    RUN sistema/generico/procedures/b1wgen0092.p 
        PERSISTENT SET h-b1wgen0092.

Inicio: DO WHILE TRUE:

    IF  glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.
   
    ASSIGN tel_cdhistor = "0"
           tel_cdrefere = 0
           tel_nmprimtl = " ".
    
    NEXT-PROMPT tel_nrdconta WITH FRAME f_autori.

    HIDE FRAME f_consulta.

    HIDE FRAME f_autori_lista.
    CLEAR FRAME f_autori_lista.
    HIDE FRAME f_barras.
    CLEAR FRAME f_barras.
    HIDE FRAME f_consulta.
    CLEAR FRAME f_consulta. 

    ASSIGN glb_cddopcao = "C".

    Verifica: DO WHILE TRUE ON ENDKEY UNDO Verifica, LEAVE Verifica:

        UPDATE glb_cddopcao tel_nrdconta WITH FRAME f_autori.

        HIDE FRAME f_autori_lista.
        CLEAR FRAME f_autori_lista.
        HIDE FRAME f_barras NO-PAUSE.
        CLEAR FRAME f_barras NO-PAUSE.

        CLEAR FRAME f_consulta ALL NO-PAUSE.
        PAUSE(0).

        RUN valida-conta IN h-b1wgen0092
            ( INPUT glb_cdcooper,
              INPUT glb_cdagenci,
              INPUT 0,
              INPUT tel_nrdconta, 
             OUTPUT par_nmprimtl, 
             OUTPUT par_cdsitdtl,
             OUTPUT TABLE tt-erro ).

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                IF  AVAIL tt-erro  THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        CLEAR FRAME f_autori_lista NO-PAUSE.
                        NEXT-PROMPT tel_nrdconta WITH FRAME f_autori.
                        NEXT Verifica.
                    END.
            END.

        ASSIGN tel_nmprimtl = par_nmprimtl.
      
        DISPLAY tel_nmprimtl WITH FRAME f_autori.
      
        LEAVE Verifica.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "AUTORI"   THEN
                DO:
                    HIDE FRAME f_autori_lista.
                    HIDE FRAME f_autori.
                    HIDE FRAME f_consulta.
                    DELETE PROCEDURE h-b1wgen0092.
                    RETURN.
                END.
            ELSE
                NEXT Inicio.
        END.
 
    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

    ASSIGN tel_dtautori = glb_dtmvtolt
           tel_dtcancel = glb_dtmvtolt
           tel_codbarra = ""
           tel_fatura01 = ""
           tel_fatura02 = ""
           tel_fatura03 = ""
           tel_fatura04 = ""
           tel_flgsicre = FALSE.

    IF  glb_cddopcao = "C"   THEN
        DO:
            DISPLAY tel_flgsicre WITH FRAME f_autori.
              
            UPDATE tel_flgsicre WITH FRAME f_autori.
            

            ASSIGN tel_dshistor = ""
                   tel_cdrefere = 0
                   tel_dtautori = ? 
                   tel_dtcancel = ?
                   tel_dtultdeb = ?.
            
            dsconv:
            DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                    
                IF  NOT tel_flgsicre THEN
                    DO:
                        tel_dshistor = "". /* Inicia vazio */

                        cecred:
                        DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                
                             UPDATE tel_dshistor 
                                   WITH FRAME f_autori_lista.

                             IF  LASTKEY = KEYCODE("F7") OR 
                                 (LASTKEY = 13 AND 
                                 tel_dshistor <> "") THEN
                                 DO: 
                                     RUN pi-exibe-browse (INPUT FRAME-FIELD,
                                                          INPUT tel_dshistor).
                               
                                     IF  RETURN-VALUE <> "OK" THEN
                                         DO:
                                             MESSAGE "Convenio nao encontrado.".
                                             CLEAR FRAME f_autori_lista.
                                             PAUSE 1 NO-MESSAGE.
                                             NEXT cecred.
                                         END.
                               
                                     IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                                         NEXT cecred.
                                 END.
                               
                                APPLY LASTKEY. 
                            LEAVE cecred.
                        END.

                        UPDATE tel_cdrefere WITH FRAME f_autori_lista.
                    END.
                ELSE
                    VIEW FRAME f_autori_lista. 

                RUN busca-autori.

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        HIDE FRAME f_autori_lista.
                        CLEAR FRAME f_autori_lista.
                        NEXT Inicio.
                    END.

                RUN valida-historico.

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        HIDE FRAME f_autori_lista.
                        CLEAR FRAME f_autori_lista.
                        NEXT Inicio.
                    END.

                PAUSE(0).

                ASSIGN aux_contador = 1.

                FOR EACH tt-autori NO-LOCK:
                
                    ASSIGN aux_contador = aux_contador + 1
                           tel_cdhistor = STRING(tt-autori.cdhistor)
                           tel_cddddtel = tt-autori.cddddtel
                           tel_cdrefere = tt-autori.cdrefere
                           tel_dshistor = tt-autori.dshistor
                           tel_dtautori = tt-autori.dtautori
                           tel_dtcancel = tt-autori.dtcancel
                           tel_dtultdeb = tt-autori.dtultdeb
                           tel_dtvencto = tt-autori.dtvencto
                           tel_nmfatura = tt-autori.nmfatura
                           tel_nmempres = tt-autori.nmempres
                           tel_dbcancel = tt-autori.dbcancel.
                    
                    IF  aux_contador = 1  THEN
                        IF  aux_flgretor  THEN 
                            DO:
                                PAUSE MESSAGE
                                      "Tecle <Enter> para continuar ou <Fim> para encerrar".
                                CLEAR FRAME f_consulta ALL NO-PAUSE.
                            END.
                        ELSE
                            ASSIGN aux_flgretor = TRUE. 

                    DISPLAY tel_dshistor tel_cdrefere tel_dtautori 
                            tel_dtcancel tel_dtultdeb 
                            WITH FRAME f_consulta.
                
                    IF  aux_contador = 8  THEN
                        ASSIGN aux_contador = 0.
                    ELSE
                        DOWN WITH FRAME f_consulta.
                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                    DO: 
                        HIDE FRAME f_autori_lista.
                        CLEAR FRAME f_autori_lista.
                        HIDE FRAME f_consulta.
                        CLEAR FRAME f_consulta. 
                        LEAVE Inicio.
                    END.

                LEAVE.
            END.
        END.
    ELSE
    IF  glb_cddopcao = "E"   THEN
        DO:
            /* Iniciar vazio */    
            ASSIGN tel_dshistor = ""
                   tel_cdrefere = 0
                   tel_dtautori = ? 
                   tel_dtcancel = ?
                   tel_dtultdeb = ?. 

            DO  WHILE TRUE:

                DISPLAY tel_flgsicre WITH FRAME f_autori.
                
                UPDATE tel_flgsicre WITH FRAME f_autori. 
                    
                IF  NOT tel_flgsicre THEN
                    DO: 
                        tel_dshistor = "". /* Inicia vazio */

                        cecred:
                        DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                
                            UPDATE tel_dshistor 
                                   WITH FRAME f_autori_lista.

                             IF  LASTKEY = KEYCODE("F7") OR 
                                 LASTKEY = 13 THEN
                                 DO: 
                                     RUN pi-exibe-browse (INPUT FRAME-FIELD,
                                                          INPUT tel_dshistor).
                               
                                     IF  RETURN-VALUE <> "OK" THEN
                                         DO:
                                             MESSAGE "Convenio nao encontrado.".
                                             CLEAR FRAME f_autori_lista.
                                             PAUSE 1 NO-MESSAGE.
                                             NEXT cecred.
                                         END.
                               
                                     IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                                         NEXT cecred.
                                 END.
                               
                            APPLY LASTKEY. 

                            IF  tel_dshistor = "" THEN
                                DO:
                                   MESSAGE "Convenio nao informado.".
                                   PAUSE 2 NO-MESSAGE.
                                   NEXT cecred.
                                END.

                            LEAVE cecred.
                        END.         
                    END. /* fim do flgsicre false */
                ELSE
                    DO:
                        tel_dshistor = "". /* Inicia vazio */

                        sicredi:
                        DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                
                            UPDATE tel_dshistor 
                                   WITH FRAME f_autori_lista.

                           IF  LASTKEY = KEYCODE("F7") OR
                               LASTKEY = 13 THEN
                               DO:
                                   RUN pi-exibe-browse-sicre (INPUT FRAME-FIELD,
                                                              INPUT tel_dshistor).
                           
                                   IF  RETURN-VALUE <> "OK" THEN
                                       DO:
                                           MESSAGE "Convenio SICREDI nao encontrado.".
                                           CLEAR FRAME f_autori_lista.
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT sicredi.
                                       END.
                           
                                   IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                                       NEXT sicredi.
                               END.

                            APPLY LASTKEY. 
                               
                            IF  tel_dshistor = "" THEN
                                DO:
                                     MESSAGE "Convenio nao informado.".
                                     PAUSE 2 NO-MESSAGE.
                                     NEXT sicredi.
                                END.

                            LEAVE sicredi.
                        END.         
                    END.
                    
                referencia:
                DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                    
                    UPDATE tel_cdrefere WITH FRAME f_autori_lista.

                    IF  tel_cdrefere = 0 THEN
                        DO:
                            MESSAGE "Referencia nao informada.".
                            PAUSE 2 NO-MESSAGE.
                            NEXT referencia.
                        END.
                    LEAVE referencia.
                END.

                DO  WHILE TRUE:

                    RUN busca-autori.
                          
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            NEXT Inicio.
                        END.
                    
                    RUN valida-historico.
    
                    IF  RETURN-VALUE <> "OK"  THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            NEXT Inicio.
                        END.

                    RUN atualiza-tela.
                    
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            NEXT Inicio.
                        END.
            
                    DISPLAY tel_dshistor tel_cdrefere tel_dtautori tel_dtcancel
                            tel_dtultdeb WITH FRAME f_autori_lista.
                    
                    RUN valida-dados.
            
                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            NEXT Inicio.
                        END.

                    LEAVE.
                END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                    ASSIGN aux_confirma = "N"
                           glb_dscritic = "Deseja cancelar este optante do " +
                                          "servico de Debito Automatico?".
                    
                    MESSAGE COLOR NORMAL glb_dscritic 
                                         UPDATE aux_confirma.
                    ASSIGN glb_cdcritic = 0.
        
                    LEAVE.
        
                END.  /*  Fim do DO WHILE TRUE  */
        
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S"   THEN
                    DO:
                        ASSIGN glb_cdcritic = 79.
                        NEXT.
                    END.
    
                RUN grava-dados.
    
                IF  RETURN-VALUE <> "OK" THEN
                    DO:
                        HIDE FRAME f_autori_lista.
                        CLEAR FRAME f_autori_lista.
                        NEXT Inicio.
                    END.
                LEAVE.
            END.
        END.
    ELSE
    IF  glb_cddopcao = "I"   THEN
        DO:
            
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

                DISPLAY tel_flgsicre WITH FRAME f_autori. 
                
                UPDATE tel_flgsicre WITH FRAME f_autori.    

                /* SICREDI SIM */
                IF  tel_flgsicre THEN
                    DO:
                        RUN valida_conta_sicredi IN h-b1wgen0092 
                                                (INPUT glb_cdcooper,
                                                 INPUT tel_nrdconta,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT glb_cdoperad,
                                                OUTPUT TABLE tt-erro).

                         IF  RETURN-VALUE <> "OK" THEN
                             DO:
                                 FIND FIRST tt-erro NO-ERROR.
                              
                                 IF  AVAILABLE tt-erro THEN
                                     MESSAGE tt-erro.dscritic.
    
                                 NEXT Inicio.
                             END.

                        UPDATE tel_flgmanua 
                            WITH FRAME f_autori.

                       /* Informa automatico - leitor de codigo de barras */
                       IF  NOT tel_flgmanua THEN
                           DO:

                              Codbarras:
                              DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:

                                  UPDATE tel_codbarra
                                     WITH FRAME f_barras.
                       
                                  IF  tel_codbarra = "" THEN
                                      DO:
                                          MESSAGE "Informe o codigo de barras.".
                                          NEXT Codbarras.
                                      END.

                                  RUN retorna-calculo-barras IN h-b1wgen0092
                                                            (INPUT glb_cdcooper,
                                                             INPUT 0, /* fat01 */
                                                             INPUT 0, /* fat02 */
                                                             INPUT 0, /* fat03 */
                                                             INPUT 0, /* fat04 */
                                                             INPUT tel_codbarra,
                                                             INPUT tel_flgmanua,
                                                             INPUT "caracter",
                                                            OUTPUT par_nmdcampo,
                                                            OUTPUT aux_dsnomcnv,
                                                            OUTPUT TABLE tt-erro).
                           
                                  IF  RETURN-VALUE <> "OK" THEN
                                      DO:
                                          FIND FIRST tt-erro NO-ERROR.
                                       
                                          IF  AVAILABLE tt-erro THEN
                                              MESSAGE tt-erro.dscritic.
    
                                          NEXT Codbarras.
                                      END.

                                    LEAVE Codbarras.
                              END.
                           
                              tel_dshistor = aux_dsnomcnv. /* Inicia vazio */

                              DISPLAY tel_dshistor WITH FRAME f_autori_lista.

                              referencia:
                              DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                  
                                  UPDATE tel_cdrefere WITH FRAME f_autori_lista.
                          
                                  IF  tel_cdrefere = 0 THEN
                                      DO:
                                          MESSAGE "Referencia nao informada.".
                                          NEXT referencia.
                                      END.

                                  RUN retorna-calculo-referencia IN h-b1wgen0092 
                                                                (INPUT glb_cdcooper,
                                                                 INPUT tel_codbarra,
                                                                 INPUT tel_cdrefere,
                                                                OUTPUT par_nmdcampo,
                                                                OUTPUT aux_dsnomcnv,
                                                                OUTPUT TABLE tt-erro).
                                          
                                  IF  RETURN-VALUE <> "OK" OR 
                                      TEMP-TABLE tt-erro:HAS-RECORDS THEN
                                      DO:
                                          FIND FIRST tt-erro NO-ERROR.
                                       
                                          IF  AVAILABLE tt-erro THEN
                                              MESSAGE tt-erro.dscritic.
                                  
                                          NEXT referencia.
                                      END.
                                  LEAVE referencia.
                              END.

                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      
                                 ASSIGN aux_confirma = "N"
                                        glb_cdcritic = 78.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE COLOR NORMAL glb_dscritic 
                                                      UPDATE aux_confirma.
                                 ASSIGN glb_cdcritic = 0.
                              
                                 LEAVE.
                              
                              END.  /*  Fim do DO WHILE TRUE  */
                       
                              IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                  aux_confirma <> "S"   THEN
                                  DO:
                                      HIDE FRAME f_autori_lista.
                                      CLEAR FRAME f_autori_lista.
                                      HIDE FRAME f_barras NO-PAUSE.
                                      CLEAR FRAME f_barras NO-PAUSE.
                                      ASSIGN glb_cdcritic = 79.
                                      NEXT.
                                  END.
                           END.
                       ELSE
                           DO:
                               Faturas:
                               DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:

                                   UPDATE tel_fatura01
                                          tel_fatura02
                                          tel_fatura03
                                          tel_fatura04
                                       WITH FRAME f_barras.

                                   IF  tel_fatura01 = "" OR 
                                       tel_fatura02 = "" OR 
                                       tel_fatura03 = "" OR 
                                       tel_fatura04 = "" THEN
                                       DO:
                                           MESSAGE "Fatura nao informada.".
                                           NEXT Faturas.
                                       END.

                                   EMPTY TEMP-TABLE tt-erro.

                                   RUN retorna-calculo-barras IN h-b1wgen0092
                                                    (INPUT glb_cdcooper,
                                                     INPUT DEC(tel_fatura01),
                                                     INPUT DEC(tel_fatura02),
                                                     INPUT DEC(tel_fatura03),
                                                     INPUT DEC(tel_fatura04),
                                                     INPUT "",
                                                     INPUT tel_flgmanua,
                                                     INPUT "caracter",
                                                     OUTPUT par_nmdcampo,
                                                     OUTPUT aux_dsnomcnv,
                                                     OUTPUT TABLE tt-erro).
                                               
                                   IF  RETURN-VALUE <> "OK" THEN
                                       DO:

                                          FIND FIRST tt-erro NO-ERROR.
                                      
                                          IF  AVAILABLE tt-erro THEN
                                              DO:
                                                  IF  par_nmdcampo = "fatura01" THEN
                                                      DO:
                                                         aux_dscritic = tt-erro.dscritic + 
                                                                        " no campo Fatura 01".
                                                         MESSAGE aux_dscritic.
                                                         NEXT Faturas.
                                                      END.
                                                  ELSE   
                                                  IF  par_nmdcampo = "fatura02" THEN
                                                      DO:
                                                          IF  SUBSTR(tt-erro.dscritic,1,3) <> "008" THEN
                                                              aux_dscritic = tt-erro.dscritic.
                                                          ELSE
                                                              aux_dscritic = tt-erro.dscritic + 
                                                                             " no campo Fatura 02".
                                                          MESSAGE aux_dscritic.
                                                          NEXT Faturas.
                                                      END.
                                                  ELSE
                                                  IF  par_nmdcampo = "fatura03" THEN
                                                      DO:
                                                          aux_dscritic = tt-erro.dscritic + 
                                                                         " no campo Fatura 03".
                                                          MESSAGE aux_dscritic.
                                                          NEXT Faturas.
                                                      END.
                                                  ELSE
                                                  IF  par_nmdcampo = "fatura04" THEN
                                                      DO:
                                                          aux_dscritic = tt-erro.dscritic + 
                                                                         " no campo Fatura 04".
                                                          MESSAGE aux_dscritic.
                                                          NEXT Faturas.
                                                      END.
                                                  ELSE
                                                      DO:
                                                          MESSAGE tt-erro.dscritic.
                                                          NEXT Faturas.
                                                      END.
                                              END.
                                       END.
                                   LEAVE Faturas.
                               END.

                               tel_dshistor = aux_dsnomcnv.

                               DISPLAY tel_dshistor WITH FRAME f_autori_lista.

                               referencia:
                               DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                   
                                   UPDATE tel_cdrefere WITH FRAME f_autori_lista.
                
                                   IF  tel_cdrefere = 0 THEN
                                       DO:
                                           MESSAGE "Referencia nao informada.".
                                           NEXT referencia.
                                       END.

                                   RUN retorna-calculo-referencia IN h-b1wgen0092 
                                                                 (INPUT glb_cdcooper,
                                                                  INPUT tel_codbarra,
                                                                  INPUT tel_cdrefere,
                                                                 OUTPUT par_nmdcampo,
                                                                 OUTPUT aux_dsnomcnv,
                                                                 OUTPUT TABLE tt-erro).
                           
                                   IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                                       DO:
                                           FIND FIRST tt-erro NO-ERROR.
                                        
                                           IF  AVAILABLE tt-erro THEN
                                               MESSAGE tt-erro.dscritic.
                                   
                                           PAUSE 2 NO-MESSAGE.

                                           NEXT referencia.
                                       END.

                                   LEAVE referencia.
                               END.

                                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             
                                   ASSIGN aux_confirma = "N"
                                          glb_cdcritic = 78.
                                   RUN fontes/critic.p.
                                   BELL.
                                   MESSAGE COLOR NORMAL glb_dscritic 
                                                        UPDATE aux_confirma.
                                   ASSIGN glb_cdcritic = 0.
                                   
                                   LEAVE.
                             
                                END.  /*  Fim do DO WHILE TRUE  */
                       
                              IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                  aux_confirma <> "S"   THEN
                                  DO:
                                     ASSIGN glb_cdcritic = 79.
                                     NEXT.
                                  END.
                           END.
                    END. /* Fim do sicredi true */
                ELSE    /* se nao for sicredi */
                    DO:
                        ASSIGN aux_cdempcon = 0  
                               aux_cdsegmto = "0"  
                               aux_cdempres = "". 

                        tel_dshistor = "". /* Inicia vazio */

                        dsconv:
                        DO WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                        
                            UPDATE tel_dshistor WITH FRAME f_autori_lista.

                            IF  LASTKEY =  KEYCODE("F7") OR 
                                LASTKEY = 13 THEN
                                DO:
                                    RUN pi-exibe-browse (INPUT FRAME-FIELD,
                                                         INPUT tel_dshistor).
                    
                                    IF  RETURN-VALUE <> "OK" THEN
                                        DO:
                                            MESSAGE "Convenio nao encontrado.".
                                            CLEAR FRAME f_autori_lista.
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT dsconv.
                                        END.
                    
                                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
                                        NEXT dsconv.
                                        
                                END.           
                            APPLY LASTKEY. 
                                
                            IF  tel_dshistor = "" THEN
                                DO:
                                    MESSAGE "Convenio nao informado.".
                                    PAUSE 2 NO-MESSAGE.
                                    NEXT dsconv.
                                END.

                            LEAVE dsconv.            
                        END. /* DO WHILE TRUE */
                            
                        referencia:
                        DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                            
                            UPDATE tel_cdrefere WITH FRAME f_autori_lista.
        
                            IF  tel_cdrefere = 0 THEN
                                DO:
                                    MESSAGE "Referencia nao informada.".
                                    PAUSE 2 NO-MESSAGE.
                                    NEXT referencia.
                                END.
                            
                            RUN valida-dados.

                            IF  RETURN-VALUE <> "OK" THEN
                                NEXT.

                            LEAVE referencia.
                        END.

                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                              
                            ASSIGN aux_confirma = "N"
                                   glb_cdcritic = 78.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE COLOR NORMAL glb_dscritic 
                                                 UPDATE aux_confirma.
                            ASSIGN glb_cdcritic = 0.
                          
                            LEAVE.
                          
                        END.  /*  Fim do DO WHILE TRUE  */
           
                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                            aux_confirma <> "S"   THEN
                            DO:
                                ASSIGN glb_cdcritic = 79.
                                NEXT.
                            END.
                    END.

                IF  tel_cdhistor = "31" THEN
                    DO WHILE TRUE:

                        RUN verifica-aut-baixada IN h-b1wgen0092 
                            ( INPUT glb_cdcooper, 
                              INPUT glb_cdagenci,
                              INPUT 0,
                              INPUT tel_nrdconta,
                              INPUT tel_cdhistor,
                              INPUT tel_cdrefere,
                             OUTPUT TABLE tt-erro ).

                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:

                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                       
                                IF  AVAIL tt-erro  THEN
                                    DO:
                                        ASSIGN aux_confirma = "N".

                                        MESSAGE tt-erro.dscritic
                                                UPDATE aux_confirma.
                                        LEAVE.
                                    END.

                                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                                    aux_confirma <> "S"   THEN
                                    DO:
                                        ASSIGN glb_cdcritic = 79.
                                        NEXT Inicio.
                                    END.
                            END.

                        LEAVE.
                    END.

                RUN grava-dados.

                IF  RETURN-VALUE <> "OK"  THEN
                    DO:
                        HIDE FRAME f_autori_lista.
                        CLEAR FRAME f_autori_lista.
                        NEXT Inicio.        
                    END.

               ASSIGN tel_codbarra = ""
                      tel_fatura01 = ""
                      tel_fatura02 = ""
                      tel_fatura03 = ""
                      tel_fatura04 = "".

                HIDE FRAME f_autori_lista.
                CLEAR FRAME f_autori_lista.
                HIDE FRAME f_barras NO-PAUSE.
                CLEAR FRAME f_barras NO-PAUSE.

                NEXT Inicio.
            END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF  glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.
 
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
        END.
    ELSE
    IF  glb_cddopcao = "R"   THEN
        DO:
            RUN valida-oper IN h-b1wgen0092
                ( INPUT glb_cdcooper,  
                  INPUT 0,             
                  INPUT 0,             
                  INPUT glb_cdoperad,  
                  INPUT glb_nmdatela,  
                  INPUT 1,             
                  INPUT tel_nrdconta,  
                  INPUT 0,             
                  INPUT YES,           
                  INPUT glb_dsdepart,
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            NEXT.
                        END.
                END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
 
                IF  glb_cdcritic > 0 THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                    END.
                
                ASSIGN tel_dshistor = ""
                       tel_cdrefere = 0
                       tel_dtautori = ? 
                       tel_dtcancel = ?.

                DO  WHILE TRUE:

                    DISPLAY tel_flgsicre WITH FRAME f_autori.
                    
                    UPDATE tel_flgsicre WITH FRAME f_autori.    
                        
                    IF  NOT tel_flgsicre THEN
                        DO: 
                            tel_dshistor = "". /* Inicia vazio */
                                
                            cecred:
                            DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                    
                                UPDATE tel_dshistor WITH FRAME f_autori_lista.

                                IF  LASTKEY = KEYCODE("F7") OR 
                                    LASTKEY = 13 THEN
                                    DO:
                                        RUN pi-exibe-browse (INPUT FRAME-FIELD,
                                                             INPUT tel_dshistor).
                                
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                                MESSAGE "Convenio nao encontrado.".
                                                CLEAR FRAME f_autori_lista.
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT cecred.
                                            END.
                                
                                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                                            NEXT cecred.
                                    END.

                                 APPLY LASTKEY. 

                                 IF  tel_dshistor = "" THEN
                                     DO:
                                        MESSAGE "Convenio nao informado.".
                                        PAUSE 2 NO-MESSAGE.
                                        NEXT cecred.
                                     END.   

                                LEAVE cecred.
                            END.         
                        END. /* fim do flgsicre false */
                    ELSE
                        DO:
                            tel_dshistor = "". /* Inicia vazio */
    
                            sicredi:
                            DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                                    
                                UPDATE tel_dshistor WITH FRAME f_autori_lista.

                                IF  LASTKEY = KEYCODE("F7") OR 
                                    LASTKEY = 13 THEN
                                    DO:
                                        RUN pi-exibe-browse-sicre (INPUT FRAME-FIELD,
                                                                   INPUT tel_dshistor).
                                
                                        IF  RETURN-VALUE <> "OK" THEN
                                            DO:
                                                MESSAGE "Convenio SICREDI nao encontrado.".
                                                CLEAR FRAME f_autori_lista.
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT sicredi.
                                            END.
                                
                                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN   
                                            NEXT sicredi.

                                    END.

                                APPLY LASTKEY. 

                                IF  tel_dshistor = "" THEN
                                    DO:
                                         MESSAGE "Convenio nao informado.".
                                         PAUSE 2 NO-MESSAGE.
                                         NEXT sicredi.
                                    END.

                                LEAVE sicredi.
                            END.         
                        END.
                        
                        referencia:
                        DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:
                            
                            UPDATE tel_cdrefere WITH FRAME f_autori_lista.
        
                            IF  tel_cdrefere = 0 THEN
                                DO:
                                    MESSAGE "Referencia nao informada.".
                                    PAUSE 2 NO-MESSAGE.
                                    NEXT referencia.
                                END.
                            LEAVE referencia.
                        END.
                    LEAVE.
                END.

                DO WHILE TRUE ON ERROR UNDO, RETRY:
                
                    RUN busca-autori.

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            HIDE FRAME f_autori.
                            NEXT Inicio.
                        END.

                    RUN valida-historico.

                    IF  RETURN-VALUE <> "OK"  THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            NEXT Inicio.
                        END.

                    RUN atualiza-tela.

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            HIDE FRAME f_autori.
                            NEXT Inicio.
                        END.
                                     
                    DISPLAY tel_dshistor tel_cdrefere tel_dtautori 
                            tel_dtcancel tel_dtultdeb
                            WITH FRAME f_autori_lista.
                
                    LEAVE.
                END.                  

                DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                    IF  glb_cdcritic > 0 THEN
                        DO:
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                        END.
    
                    ASSIGN tel_dtautori = glb_dtmvtolt
                           tel_dtcancel = ?.

                    IF  tt-autori.dtcancel = ? THEN
                        DO:
                            Data:
                            DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:

                                DISP tel_dtautori  WITH FRAME f_autori_lista.

                                LEAVE Data.
                            END.
                        END.
                    ELSE
                        DO:
                            
                            Data:
                            DO  WHILE TRUE ON ENDKEY UNDO, NEXT Inicio:

                                DISP tel_dtautori tel_dtcancel 
                                   WITH FRAME f_autori_lista.

                                LEAVE Data.
                            END.
                        END.

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                              
                        ASSIGN aux_confirma = "N"
                               glb_cdcritic = 78.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE COLOR NORMAL glb_dscritic 
                                             UPDATE aux_confirma.
                        ASSIGN glb_cdcritic = 0.
                      
                        LEAVE.
                      
                    END.  /*  Fim do DO WHILE TRUE  */
       
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                        aux_confirma <> "S"   THEN
                        DO:
                            ASSIGN glb_cdcritic = 79.
                            NEXT Inicio.
                        END.

                    RUN grava-dados.

                    IF  RETURN-VALUE <> "OK"  THEN
                        DO:
                            HIDE FRAME f_autori_lista.
                            CLEAR FRAME f_autori_lista.
                            NEXT Inicio.
                        END.
                    LEAVE.  
                END.

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:
                       CLEAR FRAME f_autori_lista.
                       HIDE FRAME f_autori_lista.
                       LEAVE.
                    END.
                LEAVE.
            END.
        END.

END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0092)  THEN
    DELETE PROCEDURE h-b1wgen0092.

/* .......................................................................... */

PROCEDURE busca-autori:

    IF  tel_flgsicre AND glb_cddopcao = "C" THEN
        tel_cdhistor = "0".
    ELSE
    IF tel_flgsicre AND glb_cddopcao <> "C" THEN
       tel_cdhistor = "1019".

    RUN busca-autori IN h-b1wgen0092
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT 0, 
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_cdhistor,
          INPUT tel_cdrefere,
          INPUT tel_flgsicre,
         OUTPUT TABLE tt-erro,
         OUTPUT TABLE tt-autori).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.

           RETURN "NOK".
        END.

    RETURN "OK".
END PROCEDURE.

PROCEDURE valida-dados:

    RUN valida-dados IN h-b1wgen0092
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
          INPUT tel_cdhistor,
          INPUT tel_cdrefere,
          INPUT tel_dtautori,
          INPUT tel_dtcancel,
          INPUT ?, /*dtlimite*/
          INPUT glb_dtmvtolt,
          INPUT tel_dtvencto,
         OUTPUT par_nmdcampo,
         OUTPUT par_nmprimtl,
         OUTPUT TABLE tt-erro ) .

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
END.

PROCEDURE atualiza-tela:

    FIND FIRST tt-autori NO-ERROR.

    IF  AVAILABLE tt-autori THEN 
        DO:
            ASSIGN tel_cdhistor = STRING(tt-autori.cdhistor)
                   tel_dshistor = tt-autori.dshistor
                   tel_cddddtel = tt-autori.cddddtel
                   tel_cdrefere = tt-autori.cdrefere
                   tel_dtautori = tt-autori.dtautori
                   tel_dtcancel = tt-autori.dtcancel
                   tel_dtultdeb = tt-autori.dtultdeb
                   tel_dtvencto = tt-autori.dtvencto
                   tel_nmfatura = tt-autori.nmfatura
                   tel_nmempres = tt-autori.nmempres.
            
        END.
    ELSE
        ASSIGN tel_cdhistor = "0"
               tel_dshistor = ""
               tel_cddddtel = 0
               tel_cdrefere = 0
               tel_dtautori = ?
               tel_dtcancel = ?
               tel_dtultdeb = ?
               tel_dtvencto = 0
               tel_nmfatura = ""
               tel_nmempres = "".

    RETURN "OK".
END.

PROCEDURE grava-dados:

    IF tel_flgsicre THEN
       tel_cdhistor = "1019".

    RUN grava-dados IN h-b1wgen0092
        ( INPUT glb_cdcooper,   /*  par_cdcooper   */
          INPUT 0,              /*  par_cdagenci   */
          INPUT 0,              /*  par_nrdcaixa   */
          INPUT glb_cdoperad,   /*  par_cdoperad   */
          INPUT glb_nmdatela,   /*  par_nmdatela   */
          INPUT 1,              /*  par_idorigem   */
          INPUT tel_nrdconta,   /*  par_nrdconta   */
          INPUT 1,              /*  par_idseqttl   */
          INPUT YES,            /*  par_flgerlog   */
          INPUT glb_dtmvtolt,   /*  par_dtmvtolt   */
          INPUT glb_cddopcao,   /*  par_cddopcao   */         
          INPUT tel_cdhistor,   /*  par_cdhistor   */
          INPUT tel_cdrefere,   /*  par_cdrefere   */
          INPUT 0,              /*  par_cddddtel   */
          INPUT tel_dtautori,   /*  par_dtiniatr   */
          INPUT tel_dtcancel,   /*  par_dtfimatr   */
          INPUT tel_dtultdeb,   /*  par_dtultdeb   */
          INPUT ?,              /*  par_dtvencto   */
          INPUT "",             /*  par_nmfatura   */
          INPUT 0,              /*  par_vlrmaxdb   */        
          INPUT tel_flgsicre,
          INPUT 0,              /*  par_cdempcon   */
          INPUT 0,              /*  par_cdsegmto   */
          INPUT tel_flgmanua,
          INPUT tel_fatura01,
          INPUT tel_fatura02,
          INPUT tel_fatura03,
          INPUT tel_fatura04,
          INPUT tel_codbarra,
         OUTPUT par_nmfatret,     
         OUTPUT TABLE tt-erro).

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
END.

PROCEDURE valida-historico:

    DO WITH FRAME f_autori_lista:
        ASSIGN INPUT tel_dshistor.
    END.

    RUN valida-historico IN h-b1wgen0092
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT 1,           
          INPUT YES,         
          INPUT tel_cdhistor, 
          INPUT glb_cddopcao, 
          INPUT tel_dshistor,
         OUTPUT par_nmdcampo,
         OUTPUT par_dshistor,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                   MESSAGE tt-erro.dscritic.
                   PAUSE 2 NO-MESSAGE.
               END.
           RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE pi-exibe-browse:

    DEF  INPUT   PARAM  par_frmfield    AS CHAR                   NO-UNDO.
    DEF  INPUT   PARAM  par_dsnomcnv    AS CHAR                   NO-UNDO.

    IF  par_dsnomcnv <> "" THEN
        OPEN QUERY q-empr-conve FOR EACH 
                                    craphis WHERE 
                                    craphis.cdcooper = glb_cdcooper AND
                                    craphis.dsexthst MATCHES "*" + par_dsnomcnv + "*" AND
                                    craphis.inautori = 1 AND
                                    craphis.cdhistor <> 1019
                                    NO-LOCK.
    ELSE                
        OPEN QUERY q-empr-conve FOR EACH 
                                    craphis WHERE 
                                    craphis.cdcooper = glb_cdcooper AND
                                    craphis.inautori = 1 AND
                                    craphis.cdhistor <> 1019
                                    NO-LOCK.

    IF  NOT AVAIL craphis THEN
        RETURN "NOK".      

    ENABLE b-empr-conve WITH FRAME f-empr-conve.

    WAIT-FOR RETURN OF b-empr-conve.

    DISABLE b-empr-conve WITH FRAME f-empr-conve.

    ASSIGN tel_dshistor = craphis.dshistor
           tel_cdhistor = STRING(craphis.cdhistor).
    
    DISPLAY tel_dshistor WITH FRAME f_autori_lista.
    
    CLOSE QUERY q-empr-conve.
    HIDE FRAME f-empr-conve. 

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE pi-exibe-browse-sicre:

    DEF  INPUT   PARAM  par_frmfield    AS CHAR                   NO-UNDO.
    DEF  INPUT   PARAM  par_dsnomcnv    AS CHAR                   NO-UNDO.
    

    IF  par_dsnomcnv <> "" THEN
        OPEN QUERY q-empr-conve-sicre FOR EACH 
                                crapscn WHERE
                                crapscn.cdempcon <> 0                  AND
                                crapscn.dsoparre = "E"                 AND
                               (crapscn.cddmoden = "A"                 OR
                                crapscn.cddmoden = "C")                AND
                                crapscn.dsnomcnv  MATCHES "*" + par_dsnomcnv + "*"
                                NO-LOCK.
    ELSE
    OPEN QUERY q-empr-conve-sicre FOR EACH 
                                crapscn WHERE
                                crapscn.cdempcon <> 0                  AND
                                crapscn.dsoparre = "E"                 AND
                               (crapscn.cddmoden = "A"                 OR
                                crapscn.cddmoden = "C")               
                                NO-LOCK.
                              
    IF  NOT AVAIL crapscn THEN
        RETURN "NOK".           

    ENABLE b-empr-conve-sicre WITH FRAME f-empr-conve-sicre.

    WAIT-FOR RETURN OF b-empr-conve-sicre.

    DISABLE b-empr-conve-sicre WITH FRAME f-empr-conve-sicre.

    ASSIGN tel_dshistor = crapscn.dsnomcnv
           tel_cdhistor = crapscn.cdempres.
    
    DISPLAY tel_dshistor WITH FRAME f_autori_lista.
    
    CLOSE QUERY q-empr-conve-sicre.
    HIDE FRAME f-empr-conve-sicre. 

    RETURN "OK".
    
END PROCEDURE.
