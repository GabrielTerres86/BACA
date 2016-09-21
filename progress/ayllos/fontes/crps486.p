/* ..........................................................................
   
   Programa: Fontes/crps486.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Dezembro/2004.             Ultima atualizacao: 22/06/2012
   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Exportacao das tabelas do banco generico para o servidor WEB
               Para os relatorios gerenciais.

   Alteracoes: 19/12/2005 - Alterado comando rcp para scp (copia segura)
                            (Junior).
                            
               22/12/2005 - Alterar comando scp por rcp, para usuarios autori-
                            zados (Junior).
                            
               01/09/2006 - Modificado para exportar temp-table(ref. gnlcred)
                            nos totais por cooperativa, data e pac (Diego).
                            
               29/11/2006 - Alterar comando rcp por scp, para permitir a copia
                            por qualquer usuario (Junior).
                            
               02/10/2007 - Inverter ordem da salva dos arquivos (primeiro
                            copiar no /salvar, depois enviar os arquivos para
                            o servidor web) (Junior).
                            
               10/10/2007 - Verificar com o comando 'sed' se os valores dos
                            arquivos exportados sao validos para a importacao
                            na Intranet (Junior).
                            
               27/11/2008 - Alterar o endereco do servidor web para copiar os
                            dados das tabelas, e atualizar os relatorios (Jr).

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
                            
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop
                            na leitura e gravacao dos arquivos (Elton).
                            
               21/09/2010 - Utilizar sudo para copia de arquivos(Guilherme).
               
               31/10/2011 - Atualizar comando de copia de arquivo (David).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).                                                        
 ............................................................................ */

{ includes/var_batch.i }

DEFINE STREAM str_1.  /* Para gerar os arquivos */
DEFINE STREAM str_2.  /* Para arquivo auxiliar. */

DEF TEMP-TABLE w-totais   LIKE gnlcred.

DEF VAR rel_nmempres AS CHAR              FORMAT "x(15)"              NO-UNDO.

DEF VAR aux_dtinicio AS DATE              FORMAT "99/99/9999"         NO-UNDO.
DEF VAR aux_dttermin AS DATE              FORMAT "99/99/9999"         NO-UNDO.
DEF VAR aux_cdcooper AS INTEGER           FORMAT "99"                 NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR              FORMAT "x(20)"              NO-UNDO.
DEF VAR aux_nmarqtmp AS CHAR              FORMAT "x(15)"              NO-UNDO.

glb_cdprogra = "crps486".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.
    
ASSIGN aux_dtinicio = glb_dtmvtolt - 30 /* para dados dos ultimos 30 dias */
       aux_dttermin = glb_dtmvtolt.
       
FOR EACH crapcop WHERE crapcop.cdcooper <> 3:
    
    /*** Arquivo GNINFPL - Informacoes por agencia da cooperativa ***/

    ASSIGN aux_nmarquiv = "radar/gninfpl_" + STRING(crapcop.cdcooper,"99").
                                                                   
    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + ".tmp").

    PUT STREAM str_1 aux_dtinicio " " aux_dttermin SKIP.

    FOR EACH gninfpl WHERE gninfpl.cdcooper = crapcop.cdcooper AND
                           gninfpl.dtmvtolt >= aux_dtinicio AND
                           gninfpl.dtmvtolt <= aux_dttermin BY gninfpl.dtmvtolt.
    
        EXPORT STREAM str_1 DELIMITER ";" gninfpl.

    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE('cat ' + aux_nmarquiv + '.tmp | sed -e "s/-,/-0,/g" | ' +
                      'sed -e "s/;,/;0,/g" > ' + aux_nmarquiv  + '.txt').

    /*** Arquivo GNTOTPL - Informacoes totais por cooperativa ***/

    ASSIGN aux_nmarquiv = "radar/gntotpl_" + STRING(crapcop.cdcooper,"99").

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + ".tmp").

    PUT STREAM str_1 aux_dtinicio " " aux_dttermin SKIP.

    FOR EACH gntotpl WHERE gntotpl.cdcooper = crapcop.cdcooper AND
                           gntotpl.dtmvtolt >= aux_dtinicio AND
                           gntotpl.dtmvtolt <= aux_dttermin BY gntotpl.dtmvtolt.
    
        EXPORT STREAM str_1 DELIMITER ";" gntotpl.

    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE('cat ' + aux_nmarquiv + '.tmp | sed -e "s/-,/-0,/g" | ' +
                      'sed -e "s/;,/;0,/g" > ' + aux_nmarquiv  + '.txt').

    /*** Arquivo GNSLDCX - Informacoes de saldos de caixa on-line e cash ***/

    ASSIGN aux_nmarquiv = "radar/gnsldcx_" + STRING(crapcop.cdcooper,"99").

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + ".tmp").

    PUT STREAM str_1 aux_dtinicio " " aux_dttermin SKIP.

    FOR EACH gnsldcx WHERE gnsldcx.cdcooper = crapcop.cdcooper AND
                           gnsldcx.dtmvtolt >= aux_dtinicio AND
                           gnsldcx.dtmvtolt <= aux_dttermin BY gnsldcx.dtmvtolt.
    
        EXPORT STREAM str_1 DELIMITER ";" gnsldcx.

    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE('cat ' + aux_nmarquiv + '.tmp | sed -e "s/-,/-0,/g" | ' +
                      'sed -e "s/;,/;0,/g" > ' + aux_nmarquiv  + '.txt').

    /*** Arquivo GNLCRED - Informacoes de emprestimos por agencia ***/

    ASSIGN aux_nmarquiv = "radar/gnlcred_" + STRING(crapcop.cdcooper,"99").

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv + ".tmp").

    PUT STREAM str_1 aux_dtinicio " " aux_dttermin SKIP.

    CREATE w-totais.

    FOR EACH gnlcred WHERE gnlcred.cdcooper = crapcop.cdcooper AND
                           gnlcred.dtmvtolt >= aux_dtinicio AND
                           gnlcred.dtmvtolt <= aux_dttermin 
                           BREAK BY gnlcred.cdcooper
                                  BY gnlcred.cdagenci
                                    BY gnlcred.dtmvtolt.
        
        ASSIGN w-totais.qtassoci = w-totais.qtassoci + gnlcred.qtassoci
               w-totais.qtctremp = w-totais.qtctremp + gnlcred.qtctremp
               w-totais.vlemprst = w-totais.vlemprst + gnlcred.vlemprst.
               
        IF   LAST-OF(gnlcred.cdcooper)  OR
             LAST-OF(gnlcred.cdagenci)  OR
             LAST-OF(gnlcred.dtmvtolt)  THEN
             DO:
                 ASSIGN w-totais.cdcooper = gnlcred.cdcooper
                        w-totais.cdagenci = gnlcred.cdagenci
                        w-totais.dtmvtolt = gnlcred.dtmvtolt
                        w-totais.dslcremp = " "
                        w-totais.cdlcremp = 0.

                 EXPORT STREAM str_1 DELIMITER ";" w-totais.
                 
                 ASSIGN w-totais.qtassoci = 0
                        w-totais.qtctremp = 0
                        w-totais.vlemprst = 0.
             END.

    END.

    OUTPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE('cat ' + aux_nmarquiv + '.tmp | sed -e "s/-,/-0,/g" | ' +
                      'sed -e "s/;,/;0,/g" > ' + aux_nmarquiv  + '.txt').

END. /* Fim do FOR EACH crapcop. */
    
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/* Salva os arquivos no diretorio "salvar" */

UNIX SILENT VALUE("cp radar/gn*.txt salvar").

/* Copia os arquivos gerados para o servidor WEB */

IF  glb_nmpacote = "pkgprod" THEN
    UNIX SILENT VALUE("sudo /usr/bin/su - scpuser -c 'scp /usr/coop/" + 
                      crapcop.dsdircop + "/radar/gn*.txt " +
                      "scpuser@pkghttpintranet.cecred.coop.br:" +
                      "/var/www/intranet/relatorio/arquivos' "
                      + "1> /dev/null 2>&1").

/* Remove os arquivos gerados */

UNIX SILENT VALUE("rm radar/gn*.* 2>/dev/null").

/* Cria arquivo auxiliar com a data do movimento */

ASSIGN aux_nmarqtmp = "arq/crps486.tmp".

OUTPUT STREAM str_2 TO VALUE(aux_nmarqtmp).

PUT STREAM str_2 aux_dtinicio " " aux_dttermin.

OUTPUT STREAM str_2 CLOSE.

RUN fontes/fimprg.p.

/* .......................................................................... */

