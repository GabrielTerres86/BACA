/* .............................................................................

   Programa: Fontes/radar2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior                             
   Data    : Marco/05                        Ultima atualizacao: 17/12/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela RADAR.
   
   Alteracoes: 30/03/2005 - Incluir dois novos campos na tabela gnradar, para
                            exportar dois novos valores: vlctaenc e vlsbremp
                            (Junior).
                                                        
               01/04/2005 - Incluir dois novos campos na tabela gnradar, para
                            exportar dois novos valores: vltotati e vltotpas
                            (Junior).
                            
               14/04/2005 - Incluir novo campo na tabela gnradar, para armaze-
                            nar valor "Operacoes de Credito CECRED", campo
                            vlopcred (Junior).
                            
               16/12/2005 - Comentado para processar todas as datas do arquivo
                            (Junior). /* ALTERACAO DESFEITA */
                            
               19/12/2005 - Alterar comando rcp para scp (copia segura) 
                            (Junior).

               22/12/2005 - Alterar comando scp por rcp, para usuarios autori-
                            zados (Junior).
                            
               17/03/2006 - Alterar campos de Data Inicio e Data Final, para
                            serem informados pelo usuario (Junior).
                            
               29/11/2006 - Alterar comando rcp por scp, para permitir a copia
                            por qualquer usuario (Junior).
                            
               06/11/2007 - Verificar com o comando 'sed' se os valores dos
                            arquivos exportados sao validos para a importacao
                            na Intranet (Junior).
                            
               09/11/2007 - Remover os arquivos gnradar apos o processamento,
                            no diretorio radar (Junior).

               29/01/2008 - Incluir novo campo na tabela gnradar, para armaze-
                            nar valor "Saldo Interfinanceiro", campo
                            vlinterf (Junior).

               17/03/2009 - Alterar o endereco do servidor web (de 172.19.1.70
                            para galileu.cecrednet.coop.br) para copiar os
                            dados das tabelas, e atualizar os relatorios (Jr).

               22/04/2009 - Alterar o endereco do servidor web (de
                            galileu.cecrednet.coop.br para
                            0302lan01.cecrednet.coop.br) para copiar os
                            dados das tabelas, e atualizar os relatorios (Jr).

               24/04/2009 - Alterar o endereco do servidor web (de
                            0302lan01.cecrednet.coop.br para
                            pkghttpintranet.cecrednet.coop.br) para copiar os
                            dados das tabelas, e atualizar os relatorios (Jr).
                            
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
                            
               21/09/2010 - Utilizar sudo para copia dos arquivos (Guilherme).
               
               03/03/2011 - Incluir novo campo na tabela gnradar, para armaze-
                            nar valor "Numerario em Custodia de Terceiros", 
                            campo nrcstter (Jorge).

               25/08/2011 - Alterar caminha o scpuser (Magui).
               
               31/10/2011 - Atualizar comando de copia de arquivo (David).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).    
               
               20/08/2012 - Ajuste no comando quoter e rm para evitar erro ao 
                            ler os arquivos com espaco no nome (David).
                            
               17/12/2013 - Inclusao de VALIDATE gnradar (Carlos)
                                  
 ............................................................................ */

{ includes/var_online.i } 

DEF STREAM str_1.
DEF STREAM str_2.

DEFINE TEMP-TABLE crawcop                                             NO-UNDO
       FIELD cdcooper LIKE crapcop.cdcooper
       FIELD nmrescop LIKE crapcop.nmrescop
       FIELD inarqexi AS CHAR FORMAT "x(20)"
       FIELD nmarquiv AS CHAR FORMAT "x(30)"
       INDEX crawcop_1 AS PRIMARY cdcooper.
                                                  
DEF VAR aux_dtinicio AS DATE              FORMAT "99/99/9999"         NO-UNDO.
DEF VAR aux_dttermin AS DATE              FORMAT "99/99/9999"         NO-UNDO.
DEF VAR aux_cdcooper AS INTEGER           FORMAT "99"                 NO-UNDO.

DEF VAR aux_nmarquiv AS CHAR FORMAT "x(40)"  NO-UNDO.
DEF VAR aux_nmarqrad AS CHAR FORMAT "x(40)"  NO-UNDO.
DEF VAR aux_nmarqaux AS CHAR FORMAT "x(40)"  NO-UNDO.
DEF VAR aux_setlinha AS CHAR FORMAT "x(400)" NO-UNDO.
DEF VAR aux_dtrefere AS DATE NO-UNDO.
DEF VAR aux_dtmvtolt AS DATE NO-UNDO.

DEF VAR aux_vlcirrlp AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlrescap AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlsldban AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlsobras AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vltotper AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vltoting AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vltotdsp AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vltotres AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlcirelp AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlctaenc AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlsbremp AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vltotati AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vltotpas AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlopcred AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_vlinterf AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.
DEF VAR aux_nrcstter AS DECIMAL FORMAT "zzz,zzz,zz9.99-" NO-UNDO.

DEF VAR tel_dstitulo AS CHAR    FORMAT "x(40)"                NO-UNDO.

DEF VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF VAR aux_dsmsgarq AS CHAR                                  NO-UNDO.
DEF VAR aux_setlnarq AS CHAR   FORMAT "x(50)"                 NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF QUERY q_coper FOR crawcop. 

DEF BROWSE b_coper QUERY q_coper
                   DISP CAPS(crawcop.nmrescop) COLUMN-LABEL "Cooperativa" 
                   FORMAT "x(20)"
                   crawcop.inarqexi COLUMN-LABEL "Situacao"    FORMAT "x(10)"
                   WITH 6 DOWN.

DEF FRAME f_cooper  
          b_coper   HELP  "Pressione <F4> ou <END> para finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 8.
          
FORM aux_setlnarq  FORMAT "x(50)"
     WITH FRAME AA WIDTH 50 NO-BOX NO-LABELS OVERLAY.

FORM aux_dtinicio LABEL "Data Inicial"
     "   "
     aux_dttermin LABEL "Data Final"
     WITH ROW 6 COLUMN 4 OVERLAY SIDE-LABELS NO-BOX CENTERED FRAME f_periodo.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

VIEW FRAME f_moldura.

PAUSE 0.

VIEW FRAME f_periodo.

/* Leitura do arquivo com as datas da importacao */

ASSIGN aux_nmarquiv = "arq/crps486.tmp".

IF  SEARCH(aux_nmarquiv) = ? THEN
    DO:
       glb_cdcritic = 182.
       RUN fontes/critic.p.
       BELL.
       MESSAGE glb_dscritic.
       PAUSE 2 NO-MESSAGE.
       glb_nmdatela = "".
       RETURN.
    END.

INPUT STREAM str_2 FROM VALUE(aux_nmarquiv) NO-ECHO.

SET STREAM str_2 aux_dtinicio aux_dttermin WITH FRAME AA WIDTH 50.

INPUT STREAM str_2 CLOSE.


FIND crabcop WHERE crabcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.


EMPTY TEMP-TABLE crawcop.

FOR EACH crapcop WHERE crapcop.cdcooper <> 3 BY crapcop.cdcooper:
        
    CREATE crawcop.
    ASSIGN crawcop.cdcooper = crapcop.cdcooper
           crawcop.nmrescop = LC(crapcop.nmrescop)
           crawcop.inarqexi = IF   SEARCH("/micros/arqradar/" + 
                                          LC(crapcop.nmrescop) + ".txt") <> ?
                              THEN "OK"
                              ELSE "Falta"
           crawcop.nmarquiv = IF   SEARCH("/micros/arqradar/" + 
                                          LC(crapcop.nmrescop) + ".txt") <> ?
                              THEN LC(crapcop.nmrescop) + ".txt"
                              ELSE "".

END. /* Fim do FOR EACH crapcop. */                 

PAUSE 0.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   RUN fontes/inicia.p.
   
   VIEW FRAME f_cooper.

   OPEN QUERY q_coper 
        FOR EACH crawcop BY crawcop.cdcooper.
 
   DISABLE b_coper WITH FRAME f_cooper.
   
   UPDATE aux_dtinicio aux_dttermin WITH FRAME f_periodo.

   DO WHILE TRUE:

      RUN fontes/inicia.p.
   
      ENABLE b_coper WITH FRAME f_cooper.
   
      ON RETURN OF b_coper IN FRAME f_cooper
         DO:
            IF  crawcop.inarqexi = "OK" THEN
                DO:
                    DO WHILE TRUE:
                       aux_confirma = "N".
                       glb_cdcritic = 78.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                       LEAVE.
                    END.

                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                         aux_confirma <> "S" THEN     /*   F4 OU FIM    */
                         NEXT.
 
                    RUN proc_learquivo.
                END.
            ELSE
                DO:
                    glb_cdcritic = 182.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE 2 NO-MESSAGE.
                    glb_cdcritic = 0.
                    LEAVE.
                END.
         
            /* RETURN NO-APPLY. */
         END.

      WAIT-FOR RETURN, END-ERROR OF DEFAULT-WINDOW.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           LEAVE.
   END.
END.  /* DO WHILE TRUE do UPDATE */


IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
         RUN fontes/novatela.p.
         IF   CAPS(glb_nmdatela) <> "RADAR"   THEN
              DO:
                  HIDE FRAME f_cooper.
                  HIDE FRAME f_periodo.
              END.
        END.

PROCEDURE proc_learquivo:

MESSAGE "importando arquivo"
    VIEW-AS ALERT-BOX INFO BUTTONS OK.

   MESSAGE "Importando arquivo " + crawcop.nmarquiv + ", aguarde...".

   ASSIGN aux_cdcooper = crawcop.cdcooper.
              
   ASSIGN aux_nmarquiv = "/micros/arqradar/" + crawcop.nmarquiv.

   UNIX SILENT VALUE('quoter "' + aux_nmarquiv + '" > "' + 
                     aux_nmarquiv + '_q"').

   ASSIGN aux_nmarqaux = aux_nmarquiv + "_q".

   INPUT STREAM str_1 FROM VALUE(aux_nmarqaux) NO-ECHO.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IMPORT STREAM str_1 aux_setlinha.
      
      ASSIGN aux_dtmvtolt = DATE(REPLACE(SUBSTRING(aux_setlinha,1,8),
                                 "/","")). 

      IF   NOT (aux_dtmvtolt >= aux_dtinicio AND
                aux_dtmvtolt <= aux_dttermin) THEN
          NEXT.
      
      IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt)))             OR
           CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND
                                  crapfer.dtferiad = aux_dtmvtolt) THEN
           NEXT.
      ELSE
           ASSIGN aux_vlrescap = DECIMAL(SUBSTRING(aux_setlinha,44,16))
                  aux_vlsobras = DECIMAL(SUBSTRING(aux_setlinha,27,16))
                  aux_vltotper = DECIMAL(SUBSTRING(aux_setlinha,10,16))
                  aux_vltoting = DECIMAL(SUBSTRING(aux_setlinha,61,16))
                  aux_vltotdsp = DECIMAL(SUBSTRING(aux_setlinha,78,16))
                  aux_vltotres = DECIMAL(SUBSTRING(aux_setlinha,112,16))
                  aux_vlctaenc = DECIMAL(SUBSTRING(aux_setlinha,129,16))
                  aux_vlsbremp = DECIMAL(SUBSTRING(aux_setlinha,146,16))
                  aux_vltotati = DECIMAL(SUBSTRING(aux_setlinha,187,16))
                  aux_vltotpas = DECIMAL(SUBSTRING(aux_setlinha,236,16))
                  aux_vlopcred = DECIMAL(SUBSTRING(aux_setlinha,253,16))
                  aux_vlinterf = DECIMAL(SUBSTRING(aux_setlinha,270,16))
                  aux_nrcstter = DECIMAL(SUBSTRING(aux_setlinha,287,16)).
      
      FIND gnradar WHERE gnradar.cdcooper = aux_cdcooper AND
                         gnradar.dtmvtolt = aux_dtmvtolt 
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
      IF   NOT AVAILABLE gnradar THEN

           IF   LOCKED gnradar THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                DO:
                    CREATE gnradar.
  
                    ASSIGN gnradar.cdcooper = aux_cdcooper
                           gnradar.dtmvtolt = aux_dtmvtolt. 
                END.

      ASSIGN gnradar.vlcirrlp = aux_vlcirrlp
             gnradar.vlrescap = aux_vlrescap
             gnradar.vlsldban = aux_vlsldban
             gnradar.vlsobras = aux_vlsobras
             gnradar.vltotdsp = aux_vltotdsp
             gnradar.vltoting = aux_vltoting
             gnradar.vltotper = aux_vltotper
             gnradar.vltotres = aux_vltotres
             gnradar.vlcirelp = aux_vlcirelp
             gnradar.vlctaenc = aux_vlctaenc
             gnradar.vlsbremp = aux_vlsbremp
             gnradar.vltotati = aux_vltotati
             gnradar.vltotpas = aux_vltotpas
             gnradar.vlopcred = aux_vlopcred
             gnradar.vlinterf = aux_vlinterf
             gnradar.nrcstter = aux_nrcstter.
      VALIDATE gnradar.

   END.

   INPUT STREAM str_1 CLOSE.

   /*** Arquivo GNRADAR - Informacoes do RADAR por cooperativa ***/

   ASSIGN aux_nmarqrad = "radar/gnradar_" + STRING(aux_cdcooper,"99").
                                                                   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqrad + ".tmp").

   PUT STREAM str_1 aux_dtinicio " " aux_dttermin SKIP.

   FOR EACH gnradar WHERE gnradar.cdcooper = aux_cdcooper AND
                          gnradar.dtmvtolt >= aux_dtinicio AND
                          gnradar.dtmvtolt <= aux_dttermin 
                          BY gnradar.dtmvtolt.

       EXPORT STREAM str_1 DELIMITER ";" gnradar.

   END.

   OUTPUT STREAM str_1 CLOSE.

   UNIX SILENT VALUE('cat ' + aux_nmarqrad + '.tmp | sed -e "s/-,/-0,/g" | ' +
                     'sed -e "s/;,/;0,/g" > ' + aux_nmarqrad  + '.txt').
                     
   /* Copia o arquivo gerado para o servidor WEB */

   IF   glb_nmpacote = "pkgprod" THEN
        UNIX SILENT VALUE("sudo /usr/bin/su - scpuser -c 'scp /usr/coop/" +
                          crabcop.dsdircop + "/radar/gn*.txt " +
                          "scpuser@pkghttpintranet.cecred.coop.br:" +
                          "/var/www/intranet/relatorio/arquivos' "
                          + "2> /dev/null").
   
   /* Salva o arquivo no diretorio "salvar" */

   UNIX SILENT VALUE("cp radar/gn*.txt salvar").

   /* Remove o arquivo */
   
   UNIX SILENT VALUE("rm radar/gn* 2> /dev/null").
        
   UNIX SILENT VALUE('rm "' + aux_nmarquiv + '" 2>/dev/null').
   UNIX SILENT VALUE('rm "' + aux_nmarqaux + '" 2>/dev/null').

   ASSIGN crawcop.inarqexi = "Processado".

   MESSAGE "Importacao Finalizada com Sucesso!".
   PAUSE 2 NO-MESSAGE.
   HIDE MESSAGE NO-PAUSE.

END PROCEDURE.
/* .......................................................................... */


