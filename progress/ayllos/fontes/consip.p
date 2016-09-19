/*.............................................................................
   
   Programa: Fontes/consip.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Outubro/2012.                   Ultima atualizacao: 24/01/2013

   Dados referentes ao programa:                                           

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CONSIP.

   Alteracoes: 24/01/2013 - Liberar acesso a tela para todos usuarios (David).
   
.............................................................................*/

{ includes/var_online.i }

DEF VAR tel_desendip AS CHAR                                          NO-UNDO.
DEF VAR tel_hrtransa AS CHAR                                          NO-UNDO.
DEF VAR tel_dttransa AS DATE                                          NO-UNDO.
DEF VAR tel_cdcooper AS INTE                                          NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                          NO-UNDO.

DEF STREAM str_1.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao LABEL "Opcao" FORMAT "!(1)" AT 3
     SPACE(3)
     tel_cdcooper LABEL "Cooperativa" FORMAT "z9"
     SPACE(3)
     tel_desendip LABEL "IP"    FORMAT "x(15)"
     SPACE(3) 
     tel_dttransa LABEL "Data"  FORMAT "99/99/9999"
     WITH ROW 6 OVERLAY WIDTH 78 CENTERED SIDE-LABELS NO-BOX FRAME f_opcao.

FORM craplgm.nrdconta LABEL "Conta" FORMAT "zzzz,zzz,9"
     tel_hrtransa     LABEL "Hora"  FORMAT "x(8)"
     WITH DOWN NO-LABEL NO-BOX FRAME f_dados.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_cdcooper = glb_cdcooper
       tel_desendip = ""
       tel_dttransa = glb_dtmvtolt.

DISPLAY glb_cddopcao tel_cdcooper tel_desendip tel_dttransa WITH FRAME f_opcao.

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao tel_cdcooper tel_desendip tel_dttransa 
               WITH FRAME f_opcao.

        HIDE MESSAGE NO-PAUSE.

        IF  glb_cddopcao <> "C"  THEN
            DO:
                MESSAGE "Opcao invalida.".
                NEXT-PROMPT glb_cddopcao WITH FRAME f_opcao.
                NEXT.
            END.

        FIND crapcop WHERE crapcop.cdcooper = tel_cdcooper NO-LOCK NO-ERROR.
          
        IF  NOT AVAIL crapcop  THEN
            DO:
                MESSAGE "Cooperativa invalida.".
                NEXT-PROMPT tel_cdcooper WITH FRAME f_opcao.
                NEXT.
            END.

        IF  tel_desendip = ""  THEN
            DO:
                MESSAGE "Informe o IP para consulta.".
                NEXT-PROMPT tel_desendip WITH FRAME f_opcao.
                NEXT.
            END.

        IF  tel_dttransa = ?             OR
            tel_dttransa > glb_dtmvtolt  THEN
            DO:
                MESSAGE "Data invalida.".
                NEXT-PROMPT tel_dttransa WITH FRAME f_opcao.
                NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "CONSIP"   THEN
                DO:
                    HIDE FRAME f_moldura.
                    HIDE FRAME f_opcao.
                    RETURN.
                END.
            ELSE
                DO:
                    ASSIGN glb_cdcritic = 0.
                    NEXT.
                END.
        END.

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.
    
    ASSIGN glb_nmarqimp = "/micros/cecred/lista_acessos_ip_" + 
                          REPLACE(crapcop.nmrescop," ","")
           aux_contador = 0.

    OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp).

    FOR EACH craplgm WHERE craplgm.cdcooper = tel_cdcooper   AND
                           craplgm.cdoperad = "996"          AND 
                           craplgm.dttransa = tel_dttransa   AND 
                           craplgm.dsorigem = "INTERNET"     AND 
                           craplgm.nmdatela = "INTERNETBANK" NO-LOCK:

        IF  craplgm.dstransa = "Efetuado login de acesso a conta on-line."  OR
            craplgm.dstransa = "Cadastrar frase secreta para acesso a conta " +
                               "on-line"  THEN
            FOR EACH craplgi WHERE craplgi.cdcooper = craplgm.cdcooper AND
                                   craplgi.nrdconta = craplgm.nrdconta AND
                                   craplgi.idseqttl = craplgm.idseqttl AND
                                   craplgi.nrsequen = craplgm.nrsequen AND
                                   craplgi.dttransa = craplgm.dttransa AND
                                   craplgi.hrtransa = craplgm.hrtransa
                                   USE-INDEX craplgi1 NO-LOCK:

                IF  craplgi.dsdadatu = tel_desendip  THEN 
                    DO:
                        ASSIGN tel_hrtransa = STRING(craplgm.hrtransa,
                                                     "HH:MM:SS")
                               aux_contador = aux_contador + 1.

                        DISP STREAM str_1 craplgm.nrdconta tel_hrtransa 
                                    WITH FRAME f_dados.
                        DOWN WITH FRAME f_dados.
                    END.

            END. /** Fim do FOR EACH craplgi **/

    END. /** Fim do FOR EACH craplgm **/

    OUTPUT STREAM str_1 CLOSE.

    IF  aux_contador = 0  THEN
        MESSAGE "** Nenhum acesso foi efetuado pelo IP " + tel_desendip + " **".
    ELSE
        DO: 
            UNIX SILENT VALUE("ux2dos " + glb_nmarqimp + " > " + glb_nmarqimp + 
                              ".txt").
            MESSAGE "Relacao foi gerada em " + glb_nmarqimp + ".txt".
        END.

    UNIX SILENT VALUE("rm " + glb_nmarqimp + " 2>/dev/null").

END. /** Fim do DO WHILE TRUE **/

/*...........................................................................*/
