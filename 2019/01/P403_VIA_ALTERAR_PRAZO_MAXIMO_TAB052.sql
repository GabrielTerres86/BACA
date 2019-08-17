 /*---------------------------------------------------------------------------------------------------------------------
    Programa    : TAB052
    Projeto     : 403 - Desconto de Títulos - Release 6
    Autor       : (Paulo Penteado GFT) 
    Data        : 18/01/2019
    Objetivo    : Alterar o conteúdo cadastrado para a opção "Prazo Máximo" das colunas Operacional e CECRED de PF e PJ
                  para a cooperativa Viacredi

    SELECT INSTR(tab.dstextab,';',1,25) 
          ,SUBSTR(tab.dstextab, 1, INSTR(tab.dstextab,';',1,9))||
           '180'|| -- Operacional - Prazo Máximo
           SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,10), (INSTR(tab.dstextab,';',1,24) - INSTR(tab.dstextab,';',1,10))+1)||
           '180'|| -- CECRED - Prazo Máximo
           SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,25))
          ,tab.*
      FROM craptab tab
     WHERE tab.cdacesso IN ('LIMDESCTITCRPJ','LIMDESCTITCRPF')
       AND tab.cdcooper = 1
  ---------------------------------------------------------------------------------------------------------------------*/ 
BEGIN
  UPDATE craptab tab
     SET dstextab = SUBSTR(tab.dstextab, 1, INSTR(tab.dstextab,';',1,9))||
                    '180'|| -- Operacional - Prazo Máximo
                    SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,10), (INSTR(tab.dstextab,';',1,24) - INSTR(tab.dstextab,';',1,10))+1)||
                    '180'|| -- CECRED - Prazo Máximo
                    SUBSTR(tab.dstextab, INSTR(tab.dstextab,';',1,25))
   WHERE UPPER(tab.cdacesso) IN ('LIMDESCTITCRPJ','LIMDESCTITCRPF')
     AND tab.cdcooper = 1;

  COMMIT;
END;
