BEGIN 

UPDATE CECRED.crapaca a
   SET a.lstparam = 'PR_CDCOPER,PR_TPPESSOA,PR_CDSEGURA,PR_TPDPAGTO,PR_MODALIDA ,PR_QTPARCEL ,PR_PIEDIAS  ,PR_PIEPARCE ,PR_IFTTDIAS ,PR_IFTTPARC ,PR_TPCUSTEI ,PR_TPADESAO ,PR_DTINIVIGENCIA ,PR_NRAPOLIC ,PR_ENDERFTP ,PR_LOGINFTP ,PR_SENHAFTP ,PR_FLGELEPF ,PR_FLGINDEN ,PR_IDADEMIN ,PR_IDADEMAX ,PR_GBIDAMIN ,PR_GBIDAMAX ,PR_PIELIMIT ,PR_PIETAXA  ,PR_IFTTLIMI ,PR_IFTTTAXA ,PR_LMPSELEG ,PR_VLCOMISS ,PR_LIMITDPS ,PR_CAPITMIN ,PR_CAPITMAX ,PR_GBSEGMIN ,PR_GBSEGMAX ,PR_IDADEDPS, PR_PAGSEGU, PR_SEQARQU, PR_DTFIMVIGENCIA ,PR_LMINSOCI, PR_DTCTRMISTA, PR_TPPRSTPJATIVO, PR_DTLIBERACAOPRSTPJ, PR_QTMESSOCIO'
 WHERE a.nmdeacao = 'SEGPRE_ALTERAR';
 
COMMIT;
END;