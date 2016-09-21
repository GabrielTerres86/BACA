/* .............................................................................

   Programa: Fontes/bordero_lst.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Junho/2004                      Ultima atualizacao: 04/07/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Carregar os borderos de desconto de cheques para uma lista.

   Alteracoes: 02/05/2005 - Listar os borderos liberados a menos de 180 dias
                            (Edson).
               16/11/2005 - Listar os borderos liberados a menos de  90 dias
                            (Mirtes).
               06/01/2006 - Verificar se ainda falta entrar algum cheque.
                            Se sim mostrar bordero (Magui).
                            
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               28/05/2012 - Alterado busca na crapcdb para utilizar indice
                            crapcdb7. Ganho significativo na busca em 
                            teste de desempenho (Guilherme Maba).
                            
               04/07/2014 - #175061 Aumento do format do num do bordero (Carlos)
............................................................................. */

{ includes/var_online.i }

{ includes/var_atenda.i }

{ includes/var_bordero.i }

DEF VAR aux_qtcompln AS INT                                      NO-UNDO.
DEF VAR aux_vlcompcr AS DECIMAL                                  NO-UNDO.

ASSIGN aux_contador = 0
       e_chlist     = ""
       e_recid      = 0.

/*  Leitura dos contratos de limite de desconto de cheques  */

FOR EACH crapbdc WHERE crapbdc.cdcooper = glb_cdcooper   AND
                       crapbdc.nrdconta = tel_nrdconta   NO-LOCK
                       BY crapbdc.nrborder DESCENDING:

    IF   crapbdc.dtlibbdc <> ?   THEN
         IF  (crapbdc.dtlibbdc < glb_dtmvtolt - 90 )   THEN  /* 180 - 150 */
              DO:
                  ASSIGN aux_flglibch = NO.
                  
                  IF   crapbdc.nrdconta <> 85448   THEN
                       
                       FOR EACH crapcdb WHERE
                                crapcdb.cdcooper = glb_cdcooper       AND
                                crapcdb.nrdconta = crapbdc.nrdconta   AND
                                crapcdb.nrborder = crapbdc.nrborder   AND
                                crapcdb.dtlibera > glb_dtmvtolt       NO-LOCK
                                USE-INDEX crapcdb7:

                           ASSIGN aux_flglibch = YES.
                           LEAVE.                               
                       END.
                       
                  IF   NOT aux_flglibch   THEN  
                       NEXT. 
              END.

    FIND craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                       craplot.dtmvtolt = crapbdc.dtmvtolt   AND
                       craplot.cdagenci = crapbdc.cdagenci   AND
                       craplot.cdbccxlt = crapbdc.cdbccxlt   AND
                       craplot.nrdolote = crapbdc.nrdolote   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE craplot   THEN
         ASSIGN aux_qtcompln = 0
                aux_vlcompcr = 0.
    ELSE
         ASSIGN aux_qtcompln = craplot.qtcompln
                aux_vlcompcr = craplot.vlcompcr.

    ASSIGN aux_contador = aux_contador + 1

           e_chlist[aux_contador] = "  " +
                   STRING(crapbdc.dtmvtolt,"99/99/9999")  + " " +
                   STRING(crapbdc.nrborder,"z,zzz,zz9")   + " " +
                   STRING(crapbdc.nrctrlim,"z,zzz,zz9")   + "  " +
                   STRING(aux_qtcompln,"zzz,zz9")         + "  " +
                   STRING(aux_vlcompcr,"zzz,zzz,zz9.99")  + "  " +
                  (IF crapbdc.insitbdc = 1 
                      THEN "EM ESTUDO"
                      ELSE IF crapbdc.insitbdc = 2
                              THEN "ANALISADO"
                              ELSE IF crapbdc.insitbdc = 3
                                      THEN "LIBERADO"
                                      ELSE string(crapbdc.insitbdc) 
                                           + "DEVOLVIDO")

           e_recid[aux_contador] = RECID(crapbdc).

END.  /*  Fim da leitura do crapbdc  */

ASSIGN e_title      = " Desconto de Cheques - Bordero "
       e_wide       = TRUE
       e_chextent   = aux_contador
       e_multiple   = FALSE
       aux_contador = 0.

/* .......................................................................... */

