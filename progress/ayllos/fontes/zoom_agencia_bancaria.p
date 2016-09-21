/*.............................................................................

   Programa: fontes/zoom_agencia_bancaria.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Dezembro/2006                       Ultima alteracao:   /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela crapagb - Cadastro de Agencia Bancaria.

   Alteracoes:  
............................................................................. */

DEF INPUT PARAM par_cdbccxlt AS INT                             NO-UNDO.

DEF SHARED VAR shr_cdageban LIKE crapagb.cdageban               NO-UNDO.
DEF SHARED VAR shr_nmageban LIKE crapagb.nmageban               NO-UNDO.

DEF VAR aux_nmdbanco  AS CHAR                                   NO-UNDO.
                 
DEF QUERY q_crapagb FOR crapagb. 

DEF BROWSE  b_crapagb QUERY q_crapagb                         
    DISPLAY crapagb.cdageban COLUMN-LABEL "Agencia"            FORMAT "z,zz9"
            crapagb.nmageban COLUMN-LABEL "Nome da Agencia"    FORMAT "x(40)"
            WITH 8 DOWN CENTERED 
                 TITLE "Agencias do Banco " + STRING(aux_nmdbanco).

FORM b_crapagb HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_crapagb.          

DEF FRAME f_crapagb  
          SKIP(1)
          b_crapagb   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX NO-LABEL CENTERED OVERLAY ROW 8.
 

ON RETURN OF b_crapagb 
   DO:
       ASSIGN shr_cdageban = crapagb.cdageban
              shr_nmageban = crapagb.nmageban.
       
       CLOSE QUERY q_crapagb.               
       
       APPLY "END-ERROR" TO b_crapagb.
   END.


FIND crapban WHERE crapban.cdbccxlt = par_cdbccxlt NO-LOCK NO-ERROR.

IF   NOT available crapban THEN
     DO:
         MESSAGE "057 - BANCO NAO CADASTRADO.".
         NEXT.
     END.
ELSE
     aux_nmdbanco = crapban.nmresbcc.

OPEN QUERY q_crapagb FOR EACH crapagb WHERE crapagb.cddbanco = par_cdbccxlt
                                            NO-LOCK.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET b_crapagb WITH FRAME f_crapagb.
      
   LEAVE.
      
END.  /*  Fim do DO WHILE TRUE  */
   
HIDE FRAME f_crapagb NO-PAUSE.
   
/* .......................................................................... */