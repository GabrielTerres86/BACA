/************************
     Data: Julho/2011
    Autor: Guilherme (Evandro).
Descricao: -Efetuar verificacao de cdcooper nos programas
           -Fonte baseado no libera_sistemas.p com alteracoes para nao liberar
           -Creditos mantido ao Evandro (desenvolvedor do libsis)
************************/
def stream str_1.
def stream str_2.

def var aux_cdsistem  as int                                       no-undo.
def var aux_dssistem  as char                                      no-undo.
def var aux_caminho   as char                                      no-undo.
def var aux_contador  as int                                       no-undo.
def var aux_dsdlinha  as char                                      no-undo.
DEF VAR aux_dsdbusca  AS CHAR                                      NO-UNDO.
DEF VAR aux_tpcompil  AS LOGICAL FORMAT "Todos/Escolher"           NO-UNDO.
DEF VAR aux_tipodout  AS LOGICAL FORMAT "Tela/Arquivo" init true   NO-UNDO.
def var aux_flgcomum  as log                                       no-undo.
def var aux_usuario   as char                                      no-undo.

def temp-table arquivos                                            no-undo
    field dsdireto   as char
    field nmarquiv   as char format "x(25)"
    field selected   as logical format "Sim/Nao"
    field camifull   as char
    index arquivos1 as primary unique nmarquiv dsdireto
    index arquivos2 dsdireto nmarquiv.
    
def buffer b_arquivos for arquivos.    

def query  q_escolhe for arquivos.
def browse b_escolhe query q_escolhe
           display arquivos.nmarquiv  column-label "Arquivo"
                   arquivos.selected  column-label "Validar"
                   with 14 down.


form "1- AYLLOS"              SKIP
     "2- CAIXA ON-LINE"       SKIP
     "4- CRM/INTERNET"        SKIP
     "5- GENERICO"            SKIP
     "----------------------" SKIP
     aux_cdsistem       label "Sistema" format "9"
                        validate(can-do("1,2,3,4,5",string(aux_cdsistem)),"")
                        help "Escolha o sistema a ser validado"
     SKIP
     aux_tpcompil      LABEL "Compilar"
                       HELP "Informe (T)odos ou (E)scolher"
     SKIP
     aux_tipodout      LABEL "Saida"
                       HELP "Informe (T)ela ou (A)rquivo"
     with side-labels overlay frame f_sistema.

form " VALIDACAO " SKIP
     "    DE     " SKIP
     " CDCOOPER  " SKIP
     with overlay column 26 frame f_verficando_cop.
     
form b_escolhe help "Pressione ENTER para selecionar ou F4 para sair"
     with no-box column 40 overlay frame f_escolhe.
     
form aux_dsdlinha format "x(22)" column-label "Verificando..."
     with down row 11 overlay frame f_verificando.
     
FORM aux_dsdbusca                         FORMAT "x(29)"
     WITH ROW 19 COLUMN 40 OVERLAY NO-LABEL FRAME f_busca.
     
/* pega o nome do usuario no UNIX */
INPUT THROUGH VALUE("who am i").
import aux_usuario.
input close.


empty temp-table arquivos.

view frame f_verficando_cop.
update aux_cdsistem 
       aux_tpcompil 
       aux_tipodout
       with frame f_sistema.

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
     
if  not aux_tpcompil then
    run escolhe_arquivos.
       
    for each arquivos where arquivos.selected = yes no-lock
                            by arquivos.dsdireto:
                            
        disp arquivos.nmarquiv @ aux_dsdlinha
             with frame f_verificando.
        down with frame f_verificando.
        pause 0.

        if   aux_cdsistem = 1   then
             run valida_fonte (input "ayllos",
                               INPUT arquivos.dsdireto + "/" +
                                           arquivos.nmarquiv,
                               input arquivos.camifull).
        else
             do:
                if   aux_cdsistem = 2   then
                     run valida_fonte (input "siscaixa",
                                       INPUT arquivos.dsdireto + "/" +
                                                   arquivos.nmarquiv,
                                       input arquivos.camifull).
                else
                if   aux_cdsistem = 4   then
                     run valida_fonte (input "internet",
                                       INPUT arquivos.dsdireto + "/" +
                                                   arquivos.nmarquiv,
                                       input arquivos.camifull).
                else
                run valida_fonte (input "generico",
                                  INPUT arquivos.dsdireto + "/" +
                                              arquivos.nmarquiv,
                                  input arquivos.camifull).                

                output close.
             end.
             
    end.

if not aux_tipodout then
    message "Validacao finalizada." skip
            "Arquivo gerado: /tmp/cdcoopersis.log"
            view-as alert-box.
else
    message "Validacao finalizada." view-as alert-box.        
    
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
    def var aux_qtdireto as int             init 1                    no-undo.
    def var aux_lsdireto as char  extent 1
                                  init["procedures"]       no-undo.
    
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
    def var aux_camifull         as char                        no-undo.

    INPUT STREAM str_1 THROUGH VALUE(par_comando) no-echo.
      
    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        import stream str_1 unformatted aux_dsdlinha.
        
        /* se a extensao nao for ".p", ".i", ".w", ".htm" ou ".html", ignora */
        if not can-do("p,i,w,htm,html",
                       substring(aux_dsdlinha,r-index(aux_dsdlinha,".") + 1))
                       then
           next.
        
        /* tira o caminho */
        ASSIGN aux_camifull = aux_dsdlinha
               aux_dsdlinha = substring(aux_dsdlinha,
                                        r-index(aux_dsdlinha,"/") + 1).

        find arquivos where arquivos.nmarquiv = aux_dsdlinha
                            no-lock no-error.
        
        if   not available arquivos   then
             do transaction:
                 create arquivos.
                 assign arquivos.dsdireto = par_dsdireto
                        arquivos.nmarquiv = aux_dsdlinha
                        arquivos.selected = aux_tpcompil
                        arquivos.camifull = aux_camifull.
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

procedure valida_fonte:
    
    def input param par_nmsistem as char                        no-undo.
    def input param par_nmarquiv as char                        no-undo.
    def input param par_camifull as char                        no-undo.
    
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
            run /usr/coop/sistema/ayllos/fontes/busca_check_cdcooper.p
                (input par_nmsistem,
                 input substring(par_nmarquiv,r-index(par_nmarquiv,"/") + 1),
                 input aux_tipodout).
         
            if   return-value <> "OK"   then
                 do:
                     if  aux_tipodout then
                     do:
                     aux_confirma = false.
                     do  while true on endkey undo, retry:
                         message "O fonte" 
                         substring(par_nmarquiv,r-index(par_nmarquiv,"/") + 1)
                                 "nao compila. Continuar?"
                                 update aux_confirma format "S/N".
                         leave.
                     end.
                     
                     if not aux_confirma then
                        quit.
                     end.
                 end.
            else
                 do:
                    /* mostra os resultados */
                    run /usr/coop/sistema/ayllos/fontes/busca_check_cdcooper2.p
                        (input "ayllos",
                         input substring(par_nmarquiv,
                                         r-index(par_nmarquiv,"/") + 1),
                         input par_camifull,
                         input aux_tipodout).

                    if   return-value <> "OK"   then
                         return.
                 end.
         end.
                
    output close.
    
end procedure.

/* .......................................................................... */
