/* .............................................................................

   Programa: Includes/bloque.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                    Ultima atualizacao: 13/05/2008

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar os lancamentos bloqueados na tela BLOQUE.

   Alteracoes: 08/09/2004 - Tratar conta integracao (Margarete).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
............................................................................. */

aux_flgretor = FALSE.

DISPLAY tel_nmprimtl crapass.nrdctitg tel_dssititg tel_vlsdbloq 
        tel_vlsdblpr tel_vlsdblfp WITH FRAME f_bloque.

CLEAR FRAME f_lanctos ALL NO-PAUSE.

FOR EACH crapdpb WHERE crapdpb.cdcooper =  glb_cdcooper   AND
                       crapdpb.nrdconta =  tel_nrdconta   AND
                       crapdpb.dtliblan >= glb_dtmvtolt   AND
                       crapdpb.inlibera = 1
                       USE-INDEX crapdpb2 NO-LOCK:

    ASSIGN aux_regexist = TRUE
           aux_contador = aux_contador + 1.

    IF   aux_contador = 1 THEN
         IF   aux_flgretor  THEN
              DO:
                  PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                  CLEAR FRAME f_lanctos ALL NO-PAUSE.
              END.
         ELSE
              aux_flgretor = TRUE.

    FIND craphis NO-LOCK WHERE craphis.cdcooper = crapdpb.cdcooper AND 
                               craphis.cdhistor = crapdpb.cdhistor NO-ERROR.

    IF   NOT AVAILABLE craphis   THEN
         tel_dshistor = STRING(crapdpb.cdhistor).
    ELSE
         tel_dshistor = craphis.dshistor.

    PAUSE(0).

    DISPLAY crapdpb.dtliblan tel_dshistor
            crapdpb.vllanmto crapdpb.dtmvtolt
            crapdpb.cdagenci crapdpb.cdbccxlt
            crapdpb.nrdolote crapdpb.nrdocmto
            WITH FRAME f_lanctos.

    IF   aux_contador = 8   THEN
         aux_contador = 0.
    ELSE
         DOWN WITH FRAME f_lanctos.

END.  /*  Fim do FOR EACH  --  Leitura dos depositos bloqueados  */

IF   NOT aux_regexist   THEN
     DO:
         glb_cdcritic = 11.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
     END.

/* .......................................................................... */
