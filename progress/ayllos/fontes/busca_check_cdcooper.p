/*******************
fonte original fontes/check_cdcooper.p - Guilherme
********************/
def input param par_nmsistem as char        no-undo.
def input param par_nmprogra as char        no-undo.
def input param par_tipodout as log         no-undo.

if   par_nmsistem = ""   then
     do:
         message "O sistema deve ser informado!!!" view-as alert-box.
         leave.
     end.

def stream str_1.

def var cTexto    as char format "x(70)"                    no-undo.
def var cDir      as char format "x(10)"                    no-undo.
def var cPrograma as char format "x(10)"                    no-undo.
def var cTabela   as char                                   no-undo.

def var aux_dsdlinha as char                no-undo.
def var aux_dsdireto as char extent 2       no-undo.
def var aux_contador as int                 no-undo.
def var aux_flgexist as logical init no     no-undo.

define temp-table ttSearch no-undo
       field programa  as char format "x(10)"
       field local     as char format "x(20)"
       field linha     as int  format ">>>9"
       field palavra   as char format "x(7)"
       field tabela    as char format "x(15)"
       index idxprograma is primary
             programa
             local
             linha.

define temp-table ttAccess no-undo
       field programa as char format "x(10)"
       field local    as char format "x(10)"
       field linha    as int  format "9999"
       field palavra  as char format "x(7)"
       field tabela   as char format "x(15)"
       field campo    as char format "x(15)"
       index idxprograma is primary
             programa
             local
             linha.

define query qSearch for ttSearch.
define browse bSearch query qSearch 
       display ttSearch.programa
               ttSearch.local
               ttSearch.linha
               ttSearch.palavra
               ttSearch.tabela
               with 3 down.
               
define query qAccess for ttAccess.
define browse bAccess query qAccess
       display ttAccess.programa
               ttAccess.local
               ttAccess.linha
               ttAccess.palavra
               ttSearch.tabela
               ttAccess.campo
               with 7 down.


/* limpa o arquivo */
unix silent value("> /tmp/check_cdcooper.lst").


/* conecta ao generico */
{ /usr/coop/viacredi/includes/gg0000.i }
f_conectagener().


/* diretorio de cada sistema */
if   par_nmsistem = "ayllos"   then
     aux_dsdireto[1] = "/usr/coop/sistema/ayllos/fontes/".
else
if   par_nmsistem = "siscaixa"   then
     do:
         assign aux_dsdireto[1] = "/usr/coop/sistema/siscaixa/web/"
                aux_dsdireto[2] = "/usr/coop/sistema/siscaixa/web/dbo/".
                
         if not can-do(propath,aux_dsdireto[1]) then
            propath = propath + "," + aux_dsdireto[1].
     end.
else
if   par_nmsistem = "generico"   then
     aux_dsdireto[1] = "/usr/coop/sistema/generico/procedures/".
else
if   par_nmsistem = "internet"   then
     assign aux_dsdireto[1] = "/usr/coop/sistema/internet/fontes/"
            aux_dsdireto[2] = "/usr/coop/sistema/internet/procedures/".
else
if   par_nmsistem = "siscash"   then
     do:
         assign aux_dsdireto[1] = "/usr/coop/sistema/siscash/cash/"
                aux_dsdireto[2] = "/usr/coop/sistema/siscash/procedures/".
                
         if not can-do(propath,aux_dsdireto[1]) then
            propath = propath + "," + "/usr/coop/sistema/siscash/".
     end.

     
     
/* verifica somente o programa informado */
if   par_nmprogra <> ""   then
     do:
         RUN verifica_programa(INPUT aux_dsdireto[1] + par_nmprogra).

         if   return-value <> "OK"   then
              return "NOK".

     end.
else
     /* varre os diretorios do sistema informado */
     do aux_contador = 1 to 2:
     
        if   aux_dsdireto[aux_contador] <> ""   then
             do:
                INPUT STREAM str_1 THROUGH
                       VALUE("ls " + aux_dsdireto[aux_contador] + "*.*")
                       NO-ECHO.
                
                DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
                    
                   import stream str_1 unformatted aux_dsdlinha.
              
                   /* se a extensao nao for ".p", ".w" ignora */
                   if not can-do("p,w",substring(aux_dsdlinha,
                                        r-index(aux_dsdlinha,".") + 1)) then
                      next.
                      
                   put screen "Verificando:"
                              row 14 column 3.
                   put screen string(aux_dsdlinha,"x(70)")
                              row 15 column 3.
              
                   RUN verifica_programa(INPUT aux_dsdlinha).

                   put screen string(" ","x(70)")
                              row 15 column 3.
                end.
                
                input stream str_1 close.
             end.
     end.
     
/* se o arquivo estiver vazio, remove */
if not aux_flgexist then
   unix silent value("rm /tmp/check_cdcooper.lst").


procedure verifica_programa:

  def input param par_nmprogra as char      no-undo.
  
  empty temp-table ttSearch.
  empty temp-table ttAccess.
  
  /* para programas webspeed, deve-se salvar o .r */
  if   par_nmsistem = "siscaixa" then
       compile value(par_nmprogra) xref
               value("/tmp/check_cdcooper.xref")
               SAVE NO-ERROR.
  else
       compile value(par_nmprogra) xref
               value("/tmp/check_cdcooper.xref") NO-ERROR.
          
  /* Se teve erro de compilacao */
  IF   error-status:num-messages <> 0   THEN
  do:
       if  par_tipodout  then /*tela*/
           message "Programa:" par_nmprogra SKIP
                   "Error:" error-status:get-message(1) view-as alert-box.
       return "NOK".
  end.        
  input from value("/tmp/check_cdcooper.xref").
  
  repeat:

    import unformatted cTexto.
    
    if lookup("search", cTexto, " ") <> 0 then do:
      if lookup("TEMPTABLE", cTexto, " ") <> 0 or
         lookup("WORKFILE",  cTexto, " ") <> 0 then
        assign cTabela = entry(5, cTexto, " ").
      else do:
        assign cTabela = entry(2, entry(5, cTexto, " "), ".").

        find banco._file where banco._file._file-name = cTabela
                               no-lock no-error.
        
        find banco._field where banco._field._File-recid = recid(banco._file)
                            and banco._field._field-name = "cdcooper"
                                no-lock no-error.
                                
        if not avail banco._field then
          next.
      end.
      
      create ttSearch.
    
      run adecomm/_osprefx.p (entry(1, cTexto, " "),
                              output cDir,
                              output cPrograma).
    
      assign ttSearch.programa = cPrograma.
    
      run adecomm/_osprefx.p (entry(2, cTexto, " "),
                              output cDir,
                              output cPrograma).
    
      assign ttSearch.local    = cPrograma
             ttSearch.linha    = int(entry(3, cTexto, " "))
             ttSearch.palavra  = entry(4, cTexto, " ")
             ttSearch.tabela   = entry(5, cTexto, " ").
    end.   
  
    if lookup("access", cTexto, " ") <> 0 then do:
      create ttAccess.
      
      run adecomm/_osprefx.p (entry(1, cTexto, " "),
                              output cDir,
                              output cPrograma).
      assign ttAccess.programa = cPrograma.
    
      run adecomm/_osprefx.p (entry(2, cTexto, " "),
                              output cDir,
                              output cPrograma).
                              
      assign ttAccess.local   = cPrograma
             ttAccess.linha   = int(entry(3, cTexto, " "))
             ttAccess.palavra = entry(4, cTexto, " ")
             ttAccess.tabela  = entry(5, cTexto, " ")
             ttAccess.campo   = entry(6, cTexto, " ").
             
    end.
  end.

  input close.
  
  /* remove o .xref */
  unix silent value("rm /tmp/check_cdcooper.xref").

  for each ttSearch no-lock by ttSearch.programa
                               by ttSearch.local
                                  by ttSearch.linha:
    if can-find(first ttAccess where ttAccess.programa = ttSearch.programa and
                                     ttAccess.local    = ttSearch.local    and
                                     ttAccess.linha    = ttSearch.linha    and
                                     ttAccess.tabela   = ttSearch.tabela   and
                                     ttAccess.campo    = "cdcooper")       then
      delete ttSearch.
  end.
  
  /* somente as tabelas do banco, despreza temp-tables */
  open query qSearch for each ttSearch where 
                              index(ttSearch.tabela,".") <> 0
                              no-lock
                              by ttSearch.programa
                                by ttSearch.local
                                  by ttSearch.linha.
              
  IF   NUM-RESULTS("qSearch") <> 0   THEN
       do:
           aux_flgexist = yes.
           unix silent value("echo 'Programa: " + ttSearch.programa + "' " +
                             ">> /tmp/check_cdcooper.lst").
                   
           get first qSearch.

           repeat:

              /* includes e tals */
              if  ttSearch.programa <> ttSearch.local   then 
                  aux_dsdlinha = ttSearch.local         + " " +
                                 STRING(ttSearch.linha) + " " +
                                 ttSearch.palavra       + " " +
                                 ttSearch.tabela.
              else
                  aux_dsdlinha = STRING(ttSearch.linha) + " " +
                                 ttSearch.palavra       + " " +
                                 ttSearch.tabela.
                          
              unix silent value("echo '" +
                                "   " + 
                                aux_dsdlinha + "' " +
                                ">> /tmp/check_cdcooper.lst").

              get next qSearch.
                      
              if not available ttSearch then
                 leave.
           end.              
                       
           unix silent value("echo ' ' " +
                             ">> /tmp/check_cdcooper.lst").
                   
           close query qSearch.
       end.
          
  return "OK".
   
end procedure.


