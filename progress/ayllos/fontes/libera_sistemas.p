/*.............................................................................
 Programa: Fontes/LIBERA_SISTEMAS.p
 Sistema : Conta-Corrente - Cooperativa de Credito
 Sigla   : CRED
 Autor   : Evandro
 Data    :                                      Ultima alteracao:  25/10/2011

 Dados referentes ao programa:
 
 Objetivo: Liberar programa para a producao
   
 Alteracoes: 25/10/2011 - Somente liberar programas para o diretorio 
                          /usr/coop/sistema - unificacao de diretorios
                          (Fernando).
.............................................................................*/  
def stream str_1.
def stream str_2.
def stream log.

def var aux_cdsistem  as int                                       no-undo.
def var aux_dssistem  as char                                      no-undo.
def var aux_caminho   as char                                      no-undo.
def var aux_contador  as int                                       no-undo.
def var aux_dsdlinha  as char                                      no-undo.
DEF VAR aux_dsdbusca  AS CHAR                                      NO-UNDO.
def var aux_flgversao as log    format "Sim/Nao" init yes          no-undo.
def var aux_usuario   as char                                      no-undo.

def temp-table arquivos                                            no-undo
    field dsdireto   as char
    field nmarquiv   as char format "x(25)"
    field selected   as logical format "Sim/Nao"
    index arquivos1 as primary unique nmarquiv dsdireto
    index arquivos2 dsdireto nmarquiv.
    
def buffer b_arquivos for arquivos.    

def query  q_escolhe for arquivos.
def browse b_escolhe query q_escolhe
           display arquivos.nmarquiv  column-label "Arquivo"
                   arquivos.selected  column-label "Liberar"
                   with 14 down.


form "1- AYLLOS"              SKIP
     "2- CAIXA ON-LINE"       SKIP
     "3- PROGRID"             SKIP
     "4- CRM/INTERNET"        SKIP
     "5- GENERICO"            SKIP
     "----------------------" SKIP
     aux_cdsistem       label "Sistema" format "9"
                        validate(can-do("1,2,3,4,5",string(aux_cdsistem)),"")
                        help "Escolha o sistema a ser liberado"
     with side-labels overlay frame f_sistema.
     
form b_escolhe help "Pressione ENTER para selecionar ou F4 para sair"
     with no-box column 40 overlay frame f_escolhe.
     
form aux_dsdlinha format "x(22)" column-label "Liberando..."
     with down row 10 overlay frame f_liberando.
     
FORM aux_dsdbusca                         FORMAT "x(29)"
     WITH ROW 19 COLUMN 40 OVERLAY NO-LABEL FRAME f_busca.
     
/* pega o nome do usuario no UNIX */
INPUT THROUGH VALUE("who am i").
import aux_usuario.
input close.


empty temp-table arquivos.

update aux_cdsistem with frame f_sistema.

if   aux_cdsistem = 1   then
     run ayllos.
else
if   aux_cdsistem = 2   then
     run caixa_on_line.
else
if   aux_cdsistem = 3   then
     run progrid.
else
if   aux_cdsistem = 4   then
     run crm.
else
     run generico.
     
run escolhe_arquivos.
    
MESSAGE "ATENCAO!!! Salvar VERSAO atual dos programas escolhidos?"
        update aux_flgversao.

output stream log to value ("/usr/coop/cecred/log/libsis.log") append.

put stream log unformatted
    SKIP(1)
    "LIBERACOES DO SISTEMA " aux_dssistem " POR " aux_usuario " EM "
    string(today,"99/99/9999") " - " STRING(TIME,"HH:MM:SS").
    
if   aux_flgversao   then
     put stream log unformatted " (VERSOES SALVAS)" skip(1).
else
     put stream log unformatted " (VERSOES NAO SALVAS)" skip(1).
     
       
/*****************************************************************************
                 DIRETORIOS UNIFICADOS - LIBERAR SOMENTE PARA
                             /usr/coop/sistema/
******************************************************************************/

for each arquivos where arquivos.selected = yes no-lock
                        by arquivos.dsdireto:
                            
    disp arquivos.nmarquiv @ aux_dsdlinha
         with frame f_liberando.
    down with frame f_liberando.
    pause 0.
                 
    put stream log unformatted 
        arquivos.dsdireto + "/" + arquivos.nmarquiv SKIP.

    if   aux_cdsistem = 1   then
         run libera_ayllos (INPUT arquivos.dsdireto + "/" +
                                  arquivos.nmarquiv).
    else
         do:
            /* log de comandos para verificar em caso de erros */
            output to value ("/usr/coop/cecred/log/libsis_cmd.log") append.
            
            put unformatted string(today,"99/99/9999")
                            " - "
                            string(time,"hh:mm:ss")
                            " -> ".

            if   aux_cdsistem = 2   then
                 run libera_caixa_on_line (INPUT arquivos.dsdireto + "/" +
                                                 arquivos.nmarquiv).
            else
            if   aux_cdsistem = 3   then
                 run libera_progrid (INPUT arquivos.dsdireto + "/" +
                                           arquivos.nmarquiv).
            else
            if   aux_cdsistem = 4   then
                 run libera_crm (INPUT arquivos.dsdireto + "/" +
                                       arquivos.nmarquiv).
            else
                 run libera_generico (INPUT arquivos.dsdireto + "/" +
                                            arquivos.nmarquiv).

            output close.
         end.
             
end.
    
output stream log close. 

quit.

procedure ayllos:
    def var aux_qtdireto as int             init 2                    no-undo.
    def var aux_lsdireto as char  extent 2  init["fontes","includes"] no-undo.
    
    ASSIGN aux_caminho  = "/usr/coop/sistema/ayllos/"
           aux_dssistem = "AYLLOS".

    do  aux_contador = 1 to aux_qtdireto:
        run carrega_arquivos(INPUT "ls " + aux_caminho +
                                   aux_lsdireto[aux_contador] + "/*.*",
                             INPUT aux_lsdireto[aux_contador]).
    end.  
    
end procedure.


procedure caixa_on_line:
    def var aux_qtdireto as int             init 3                  no-undo.
    def var aux_lsdireto as char  extent 3  init["web","web/dbo",
                                                 "web/include"]     no-undo.
    
    ASSIGN aux_caminho  = "/usr/coop/sistema/siscaixa/"
           aux_dssistem = "CAIXA ON-LINE".

    do  aux_contador = 1 to aux_qtdireto:
        run carrega_arquivos(INPUT "ls " + aux_caminho +
                                   aux_lsdireto[aux_contador] + "/*.*",
                             INPUT aux_lsdireto[aux_contador]).
    end.
    
end procedure.

procedure progrid:
    def var aux_qtdireto as int             init 4                  no-undo.
    def var aux_lsdireto as char  extent 4
                            init["fontes","includes","dbo","zoom"]  no-undo.
    
    ASSIGN aux_caminho  = "/usr/coop/sistema/progrid/web/"
           aux_dssistem = "PROGRID".

    do  aux_contador = 1 to aux_qtdireto:

        run carrega_arquivos(INPUT "ls " + aux_caminho +
                                   aux_lsdireto[aux_contador] + "/*.*",
                             INPUT aux_lsdireto[aux_contador]).
    end.
end.


procedure crm:
    def var aux_qtdireto as int             init 3                 no-undo.
    def var aux_lsdireto as char  extent 3
                            init["fontes","includes","procedures"] no-undo.
    
    ASSIGN aux_caminho  = "/usr/coop/sistema/internet/"
           aux_dssistem = "CRM/INTERNET".

    do  aux_contador = 1 to aux_qtdireto:

        run carrega_arquivos(INPUT "ls " + aux_caminho +
                                   aux_lsdireto[aux_contador] + "/*.*",
                             INPUT aux_lsdireto[aux_contador]).
    end.
end.

procedure generico:
    def var aux_qtdireto as int             init 2                    no-undo.
    def var aux_lsdireto as char  extent 2
                                  init["includes","procedures"]       no-undo.
    
    ASSIGN aux_caminho  = "/usr/coop/sistema/generico/"
           aux_dssistem = "GENERICO".

    do  aux_contador = 1 to aux_qtdireto:
        run carrega_arquivos(INPUT "ls " + aux_caminho +
                                   aux_lsdireto[aux_contador] + "/*.*",
                             INPUT aux_lsdireto[aux_contador]).
    end.  
    
end procedure.


procedure carrega_arquivos:
    DEF INPUT PARAM par_comando  as char                        no-undo.
    def input param par_dsdireto as char                        no-undo.
    
    def var aux_qtchdiff         as int                         no-undo.

    INPUT STREAM str_1 THROUGH VALUE(par_comando) no-echo.
      
    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        import stream str_1 unformatted aux_dsdlinha.
        
        /* se a extensao nao for ".p", ".i", ".w", ".htm" ou ".html", ignora */
        if not can-do("p,i,w,htm,html",
                       substring(aux_dsdlinha,r-index(aux_dsdlinha,".") + 1))
                       then
           next.
        
        /* verifica se o programa tem diff, senao nem carrega para liberar */
        put screen "Verificando diff: " +
                   substring(aux_dsdlinha,
                             r-index(aux_dsdlinha,"/") + 1) +
                             "                    "
                             row 21.
        
        INPUT STREAM str_2 THROUGH
              VALUE("diff " + aux_dsdlinha + " /usr/local/cecred/sisprod/" +
                    substr(aux_dsdlinha,index(aux_dsdlinha,"sistema/") + 8) +
                    " 2> /dev/null | wc -c") no-echo.
      
        DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

            import stream str_2 unformatted aux_qtchdiff.
        end.
        
        input stream str_2 close.
        
        /* programa sem diff */
        if   aux_qtchdiff = 0   and
             search("/usr/local/cecred/sisprod/" + substr(aux_dsdlinha,
                    index(aux_dsdlinha,"sistema/") + 8)) <> ? then
             next.
        
        /* tira o caminho */
        ASSIGN aux_dsdlinha = substring(aux_dsdlinha,
                                        r-index(aux_dsdlinha,"/") + 1).

        find arquivos where arquivos.nmarquiv = aux_dsdlinha
                            no-lock no-error.
        
        if   not available arquivos   then
             do transaction:
                 create arquivos.
                 assign arquivos.dsdireto = par_dsdireto
                        arquivos.nmarquiv = aux_dsdlinha
                        arquivos.selected = NO.
             end.
    end.

    input stream str_1 close.

    put screen "                                                     " row 21.
end procedure.


procedure escolhe_arquivos:

    def var aux_ultlinha as int         no-undo.
    
    ON ANY-KEY OF b_escolhe IN FRAME f_escolhe DO:

       IF   KEYFUNCTION(LASTKEY) = "RETURN"   AND
            AVAILABLE arquivos                THEN
            DO:
                do transaction:
                   arquivos.selected = NOT arquivos.selected.
                end.
       
                /* linha que foi alterada */
                aux_ultlinha = CURRENT-RESULT-ROW("q_escolhe").
    
                open query q_escolhe for each arquivos exclusive-lock.
    
                /* reposiciona o browse */
                REPOSITION q_escolhe TO ROW aux_ultlinha.
            END.
       ELSE
       IF   (LASTKEY >= 65 AND LASTKEY <= 90)    OR    /* Letras Maiusculas */
            (LASTKEY >= 97 AND LASTKEY <= 122)   OR    /* Letras Minusculas */
            (LASTKEY >= 48 AND LASTKEY <= 57)    OR    /* Numeros */
            (LASTKEY  = 45)                      OR    /* Hifen */
            (LASTKEY  = 95)                      THEN  /* Underline */
            DO:
                aux_dsdbusca = aux_dsdbusca + KEYFUNCTION(LASTKEY).

                DISPLAY aux_dsdbusca WITH FRAME f_busca.

                FIND FIRST b_arquivos WHERE b_arquivos.nmarquiv
                                            BEGINS aux_dsdbusca
                                                   NO-LOCK NO-ERROR.
    
                IF   AVAILABLE b_arquivos   THEN
                     REPOSITION q_escolhe TO ROWID ROWID(b_arquivos).
            END.
       ELSE
            DO:
                aux_dsdbusca = "".
                HIDE FRAME f_busca NO-PAUSE.
            END.
    END.

    open query q_escolhe for each arquivos exclusive-lock.
    
    do while true on endkey undo, leave:
       update b_escolhe with frame f_escolhe

       EDITING:

          READKEY PAUSE 1.

          /* se nao teclar nada oculta a busca */
          IF   LASTKEY = -1   THEN
               DO:
                   aux_dsdbusca = "".
                   HIDE FRAME f_busca NO-PAUSE.
               END.

          APPLY LASTKEY.
       END. /* fim do EDITING */
       
       leave.
    end.
    
    close query q_escolhe.
    
end procedure.

procedure libera_ayllos:
    
    def input param par_nmarquiv as char                        no-undo.
    
    def var         aux_confirma as logical                     no-undo.
    

    /* somente valida o uso do campo cdcooper para os .p, pois as includes
       nao podem ser compiladas */
    if   substring(par_nmarquiv,r-index(par_nmarquiv,".")) = ".p"   then
         do:
            /* conecta ao banco da viacredi para usar as tabelas como
               exemplo que usam o campo cdcooper */
            if   not connected("banco")   then
                 connect banco -S 3050.
         
            /* verifica o uso do campo cdcooper nas tabelas */
            run /usr/coop/sistema/ayllos/fontes/check_cdcooper.p
                (input "ayllos",
                 input substring(par_nmarquiv,r-index(par_nmarquiv,"/") + 1)).
         
            if   return-value <> "OK"   then
                 do:
                     aux_confirma = false.
                     do  while true on endkey undo, retry:
                         message "O fonte nao compila, liberar mesmo assim?"
                                 update aux_confirma format "S/N".
                         leave.
                     end.
                     
                     if aux_confirma then
                        put stream log unformatted 
                                   "   *** Programa liberado sem compilacao"
                                   SKIP.
                     else
                        do:
                            put stream log unformatted 
                                       "   *** Abortado - Programa nao compila"
                                       SKIP.
                            return.
                        end.
                 end.
            else
                 do:
                    /* mostra os resultados */
                    run /usr/coop/sistema/ayllos/fontes/check_cdcooper2.p
                        (input "ayllos",
                         input substring(par_nmarquiv,
                                         r-index(par_nmarquiv,"/") + 1)).

                    if   return-value <> "OK"   then
                         do:
                             put stream log unformatted 
                                 "   *** Abortado" SKIP.
                             return.
                         end.
                 end.
         end.
                
    /* log de comandos para verificar em caso de erros */
    output to value ("/usr/coop/cecred/log/libsis_cmd.log") append.
            
    put unformatted string(today,"99/99/9999")
                    " - "
                    string(time,"hh:mm:ss")
                    " -> ".
    
    /* copia a versao do programa */
    if   aux_flgversao   then
         unix silent value
              ('sudo /usr/bin/su - scpuser -c "ssh scpuser@pkgprod ' +
               'cp /usr/coop/sistema/ayllos/' + par_nmarquiv +
               ' /usr/coop/sistema/ayllos/versao"').

    /* libera o programa */
    unix silent value
         ('sudo /usr/bin/su - scpuser -c "scp /usr/coop/sistema/ayllos/' + 
          par_nmarquiv + ' ' + 'scpuser@pkgprod:/usr/coop/sistema/ayllos/' + 
          par_nmarquiv + '"').
          
    /* copia para o /usr/local/cecred/sisprod/ para nao ter mais diff */
    unix silent value
         ("cp /usr/coop/sistema/ayllos/" + par_nmarquiv +
          " /usr/local/cecred/sisprod/ayllos/" + par_nmarquiv).
    
    output close.
    
end procedure.


procedure libera_caixa_on_line:
    
    def input param par_nmarquiv as char                        no-undo.
    
    /* copia a versao do programa */
    if   aux_flgversao   then
         unix silent value
              ('sudo /usr/bin/su - scpuser -c "ssh scpuser@pkgprod ' +
               'cp /usr/coop/sistema/siscaixa/' + par_nmarquiv +
               ' /usr/coop/sistema/siscaixa/versao"').

   /* libera o programa - diretorio comum a todas as coops */
   unix silent value
     ('sudo /usr/bin/su - scpuser -c "scp /usr/coop/sistema/siscaixa/' +               par_nmarquiv + ' scpuser@pkgprod:/usr/coop/sistema/' +
      'siscaixa/' + par_nmarquiv + '"').

   /* copia para /usr/local/cecred/sisprod/ para nao ter mais diff */
   unix silent value
      ("cp /usr/coop/sistema/siscaixa/" + par_nmarquiv +
       " /usr/local/cecred/sisprod/siscaixa/" + par_nmarquiv).

end procedure.

procedure libera_progrid:
    
    def input param par_nmarquiv as char                        no-undo.
    
    /* copia a versao do programa */
    if   aux_flgversao   then
         unix silent value
              ('sudo /usr/bin/su - scpuser -c "ssh scpuser@pkgprod ' +
               'cp /usr/coop/sistema/progrid/web/' + par_nmarquiv +
               ' /usr/coop/sistema/progrid/versao"').

    /* libera o programa */
    unix silent value
         ('sudo /usr/bin/su - scpuser -c "scp /usr/coop/sistema/progrid/web/' + 
          par_nmarquiv + ' scpuser@pkgprod:/usr/coop/sistema/progrid/web/' +
          par_nmarquiv + '"').

    /* copia para o /usr/local/cecred/sisprod/ para nao ter mais diff */
    unix silent value
         ("cp /usr/coop/sistema/progrid/web/" + par_nmarquiv +
          " /usr/local/cecred/sisprod/progrid/web/" + par_nmarquiv).

end procedure.


procedure libera_crm:
    
    def input param par_nmarquiv as char                        no-undo.
    
    /* copia a versao do programa */
    if   aux_flgversao   then
         unix silent value
              ('sudo /usr/bin/su - scpuser -c "ssh scpuser@pkgprod ' +
               'cp /usr/coop/sistema/internet/' + par_nmarquiv +
               ' /usr/coop/sistema/internet/versao"').

    /* libera o programa - diretorio comum a todas as coops */
    unix silent value
        ('sudo /usr/bin/su - scpuser -c "scp /usr/coop/sistema/internet/' +
         par_nmarquiv + ' scpuser@pkgprod:/usr/coop/sistema/' +
         'internet/' + par_nmarquiv + '"').

    /* copia para /usr/local/cecred/sisprod/ para nao ter mais diff */
    unix silent value
        ("cp /usr/coop/sistema/internet/" + par_nmarquiv +
         " /usr/local/cecred/sisprod/internet/" + par_nmarquiv).

end procedure.


procedure libera_generico:
    
    def input param par_nmarquiv as char                        no-undo.
    
    /* copia a versao do programa */
    if   aux_flgversao   then
         unix silent value
              ('sudo /usr/bin/su - scpuser -c "ssh scpuser@pkgprod ' +
               'cp /usr/coop/sistema/generico/' + par_nmarquiv +
               ' /usr/coop/sistema/generico/versao"').

    /* libera o programa - diretorio comum a todas as coops */
    unix silent value
        ('sudo /usr/bin/su - scpuser -c "scp /usr/coop/sistema/generico/' +
         par_nmarquiv + ' scpuser@pkgprod:/usr/coop/sistema/' +
         'generico/' + par_nmarquiv + '"').

    /* copia para /usr/local/cecred/sisprod/ para nao ter mais diff */
    unix silent value
        ("cp /usr/coop/sistema/generico/" + par_nmarquiv +
         " /usr/local/cecred/sisprod/generico/" + par_nmarquiv).
         
end procedure.

/* .......................................................................... */
