/* .............................................................................

   Programa: Includes/cadrati.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes   
   Data    : Julho/2004                          Ultima Atualizacao: 05/12/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela CADRAT(Cad.Rating)
   
   Alteracoes: 06/07/2005 - Alimentado campo cdcooper das tabelas craptor,
                            crapitr e crapsir (Diego).
              
               23/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               05/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)  

............................................................................. */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    FIND craptor WHERE craptor.cdcooper = glb_cdcooper AND
                       craptor.nrtopico = tel_nrtopico NO-LOCK NO-ERROR NO-WAIT.

    IF  AVAIL craptor THEN
        DO:
            ASSIGN  tel_dstopico = craptor.dstopico
                    tel_inpessoa = craptor.inpessoa.
                    
            DISPLAY tel_dstopico
                    tel_inpessoa WITH FRAME f_cadrat.
        END.
    ELSE 
        DO:
            UPDATE tel_dstopico           
                   tel_inpessoa
                   WITH FRAME f_cadrat.
        END.

    UPDATE tel_nritetop WITH FRAME f_cadrat.

    FIND crapitr WHERE crapitr.cdcooper = glb_cdcooper AND
                       crapitr.nrtopico = tel_nrtopico AND
                       crapitr.nritetop = tel_nritetop NO-LOCK NO-ERROR NO-WAIT.

    IF  AVAILABLE crapitr   THEN
        DO:
            ASSIGN  tel_dsitetop = crapitr.dsitetop
                    tel_pesoitem = crapitr.pesoitem.
            DISPLAY tel_dsitetop
                    tel_pesoitem WITH FRAME f_cadrat.
        END.
    ELSE 
        DO:
            UPDATE tel_dsitetop 
                   tel_pesoitem WITH FRAME f_cadrat.
        END.

    FIND LAST crapsir WHERE crapsir.cdcooper = glb_cdcooper AND              
                            crapsir.nrtopico = tel_nrtopico AND 
                            crapsir.nritetop = tel_nritetop NO-LOCK NO-ERROR.
  
    IF  AVAIL crapsir THEN
        ASSIGN tel_nrseqite = crapsir.nrseqite + 1.
    ELSE
        ASSIGN tel_nrseqite = 1.

    DISPLAY tel_nrseqite   WITH FRAME f_cadrat.

    UPDATE tel_dsseqite
           tel_pesosequ
           WITH FRAME f_cadrat.

    FIND craptor WHERE craptor.cdcooper = glb_cdcooper AND
                       craptor.nrtopico = tel_nrtopico NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptor THEN
        DO:
            CREATE craptor.
            ASSIGN craptor.nrtopico = tel_nrtopico
                   craptor.dstopico = tel_dstopico
                   craptor.inpessoa = tel_inpessoa
                   craptor.cdcooper = glb_cdcooper.
            VALIDATE craptor.
        END.                
                        
    FIND crapitr WHERE crapitr.cdcooper = glb_cdcooper AND
                       crapitr.nrtopico = tel_nrtopico AND
                       crapitr.nritetop = tel_nritetop NO-LOCK NO-ERROR.
   
    IF  NOT AVAIL crapitr THEN
        DO:
            CREATE crapitr.
            ASSIGN crapitr.nrtopico = tel_nrtopico
                   crapitr.nritetop = tel_nritetop
                   crapitr.dsitetop = tel_dsitetop
                   crapitr.pesoitem = tel_pesoitem
                   crapitr.cdcooper = glb_cdcooper.
            VALIDATE crapitr.
        END.
        
    CREATE crapsir.
    ASSIGN crapsir.nrtopico = tel_nrtopico
           crapsir.nritetop = tel_nritetop 
           crapsir.nrseqite = tel_nrseqite
           crapsir.dsseqite = tel_dsseqite
           crapsir.pesosequ = tel_pesosequ
           crapsir.cdcooper = glb_cdcooper.
    VALIDATE crapsir.

    ASSIGN tel_nrseqite     = tel_nrseqite + 1
           tel_dsseqite     = " " .

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
         NEXT.

END.
/* .......................................................................... */

