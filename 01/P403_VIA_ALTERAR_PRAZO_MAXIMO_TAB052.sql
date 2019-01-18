 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : TAB052
    Projeto     : 403 - Desconto de T�tulos - Release 6
    Autor       : (Paulo Penteado GFT) 
    Data        : 18/01/2019
    Objetivo    : Alterar o conte�do cadastrado para a op��o "Prazo M�ximo" das colunas Operacional e CECRED de PF e PJ
                  para a cooperativa Viacredi

    SELECT INSTR(tab.dstextab,';',1,25) 
          ,SUBSTR(tab.dstextab, 1, INSTR(tab.dstextab,';',1,9))||
           '180'|| -- Operacional - Prazo M�ximo
           SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,10), (INSTR(tab.dstextab,';',1,24) - INSTR(tab.dstextab,';',1,10))+1)||
           '180'|| -- CECRED - Prazo M�ximo
           SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,25))
          ,tab.*
      FROM craptab tab
     WHERE tab.cdacesso IN ('LIMDESCTITCRPJ','LIMDESCTITCRPF')
       AND tab.cdcooper = 1
  ---------------------------------------------------------------------------------------------------------------------*/ 
BEGIN
  UPDATE craptab tab
     SET dstextab = SUBSTR(tab.dstextab, 1, INSTR(tab.dstextab,';',1,9))||
                    '180'|| -- Operacional - Prazo M�ximo
                    SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,10), (INSTR(tab.dstextab,';',1,24) - INSTR(tab.dstextab,';',1,10))+1)||
                    '180'|| -- CECRED - Prazo M�ximo
                    SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,25))
   WHERE UPPER(tab.cdacesso) IN ('LIMDESCTITCRPJ','LIMDESCTITCRPF')
     AND tab.cdcooper = 1;

  COMMIT;
END;
