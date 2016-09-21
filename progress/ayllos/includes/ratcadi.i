/*..............................................................................

   Programa: Includes/ratcadi.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Fernando   
   Data    : Setembro/2009                   Ultima Atualizacao: 11/12/2013 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de inclusao da tela RATCAD(Cad.Rating)
   
   Alteracoes:
   
            03/03/2011 - Utilizado a variavel tel_inpessoa para indicar a
                         descricao e nao apenas o codigo do tipo de pessoa,
                         e criado a variavel tel_intopico para informar no
                         momento da inclusao se a nota se refere ao
                         cooperado ou a operacao. (Fabricio)
                         
            11/12/2013 - Alteracao referente a integracao Progress X 
                         Dataserver Oracle 
                         Inclusao do VALIDATE ( André Euzébio / SUPERO)              
............................................................................. */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                          
    FIND craprat WHERE craprat.cdcooper = glb_cdcooper AND
                       craprat.nrtopico = tel_nrtopico NO-LOCK NO-ERROR.

    IF  AVAIL craprat THEN
        DO:
            ASSIGN  tel_dstopico = craprat.dstopico
                    tel_inpessoa = TRIM(STRING(craprat.inpessoa))
                    tel_intopico = TRIM(STRING(craprat.intopico)).
                    
            IF tel_inpessoa = "1" THEN
                ASSIGN tel_inpessoa = "1 - Fisica".
            ELSE
                ASSIGN tel_inpessoa = "2 - Juridica".

            IF tel_intopico = "1" THEN
                ASSIGN tel_intopico = "1 - Cooperado".
            ELSE
                ASSIGN tel_intopico = "2 - Operacao".
            
            DISPLAY tel_dstopico
                    tel_inpessoa 
                    tel_intopico WITH FRAME f_ratcad.
        END.
    ELSE 
        DO:
            ASSIGN tel_inpessoa = ""
                   tel_intopico = "". 
                   
            UPDATE tel_dstopico           
                   tel_inpessoa
                   tel_intopico
                   WITH FRAME f_ratcad.
                   
        END.

    UPDATE tel_nritetop WITH FRAME f_ratcad.

    FIND craprai WHERE craprai.cdcooper = glb_cdcooper AND
                       craprai.nrtopico = tel_nrtopico AND
                       craprai.nritetop = tel_nritetop NO-LOCK NO-ERROR.

    IF  AVAILABLE craprai   THEN
        DO:
            ASSIGN  tel_dsitetop = craprai.dsitetop
                    tel_pesoitem = craprai.pesoitem.
            DISPLAY tel_dsitetop
                    tel_pesoitem WITH FRAME f_ratcad.
        END.
    ELSE 
        DO:
            UPDATE tel_dsitetop 
                   tel_pesoitem WITH FRAME f_ratcad.
        END.

    FIND LAST craprad WHERE craprad.cdcooper = glb_cdcooper AND              
                            craprad.nrtopico = tel_nrtopico AND 
                            craprad.nritetop = tel_nritetop NO-LOCK NO-ERROR.
  
    IF  AVAIL craprad THEN
        ASSIGN tel_nrseqite = craprad.nrseqite + 1.
    ELSE
        ASSIGN tel_nrseqite = 1.

    DISPLAY tel_nrseqite   WITH FRAME f_ratcad.

    UPDATE tel_dsseqite
           tel_pesosequ
           WITH FRAME f_ratcad.

    FIND craprat WHERE craprat.cdcooper = glb_cdcooper AND
                       craprat.nrtopico = tel_nrtopico NO-LOCK NO-ERROR.

    IF  NOT AVAIL craprat THEN
        DO:
            CREATE craprat.
            ASSIGN craprat.nrtopico = tel_nrtopico
                   craprat.dstopico = tel_dstopico
                   craprat.inpessoa = INT(tel_inpessoa)
                   craprat.intopico = INT(tel_intopico)
                   craprat.cdcooper = glb_cdcooper.
            VALIDATE craprat.
        END.                
                        
    FIND craprai WHERE craprai.cdcooper = glb_cdcooper AND
                       craprai.nrtopico = tel_nrtopico AND
                       craprai.nritetop = tel_nritetop NO-LOCK NO-ERROR.
   
    IF  NOT AVAIL craprai THEN
        DO:
            CREATE craprai.
            ASSIGN craprai.nrtopico = tel_nrtopico
                   craprai.nritetop = tel_nritetop
                   craprai.dsitetop = tel_dsitetop
                   craprai.pesoitem = tel_pesoitem
                   craprai.cdcooper = glb_cdcooper.
            VALIDATE craprai.
        END.
        
    CREATE craprad.
    ASSIGN craprad.nrtopico = tel_nrtopico
           craprad.nritetop = tel_nritetop 
           craprad.nrseqite = tel_nrseqite
           craprad.dsseqite = tel_dsseqite
           craprad.pesosequ = tel_pesosequ
           craprad.cdcooper = glb_cdcooper.
    VALIDATE craprad.

    ASSIGN tel_nrseqite     = tel_nrseqite + 1
           tel_dsseqite     = " " .

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
         NEXT.

    MESSAGE "Inclusao efetuada com exito!".
END.
/* .......................................................................... */

