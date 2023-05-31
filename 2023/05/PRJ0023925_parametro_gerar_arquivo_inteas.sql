BEGIN
INSERT INTO CECRED.CRAPPRM(
NMSISTEM,
CDCOOPER,
CDACESSO,
DSTEXPRM,
DSVLRPRM)
SELECT 'CRED',
       cop.cdcooper,
       'FL_GRAVAR_ARQUIVO_INTEAS',
       'Habilitar a gravação dos arquivos físicos da e-Financeira gerados no legado (Aimaro) e disponibilizados em diretório ao sistema Matera. 
       Desabilitando este parâmetro, a geração dos arquivos passarão a ser feita no Ailos+. 
       Objetivo: Evitar duplicação de arquivos. Domínio: 0-Não; 1-Sim ',
       '1'
  FROM CECRED.CRAPCOP COP
 WHERE COP.FLGATIVO = 1
   AND NOT EXISTS (SELECT 1
                     FROM CECRED.CRAPPRM X
                    WHERE X.CDACESSO = 'FL_GRAVAR_ARQUIVO_INTEAS'
                      AND X.CDCOOPER = COP.CDCOOPER)
UNION               
SELECT 'CRED',
       0,
       'FL_GRAVAR_ARQUIVO_INTEAS',
       'Habilitar a gravação dos arquivos físicos da e-Financeira gerados no legado (Aimaro) e disponibilizados em diretório ao sistema Matera. 
       Desabilitando este parâmetro, a geração dos arquivos passarão a ser feita no Ailos+. 
       Objetivo: Evitar duplicação de arquivos. Domínio: 0-Não; 1-Sim ',
       '1'
 FROM DUAL
WHERE NOT EXISTS (SELECT 1
                    FROM CECRED.CRAPPRM X
                   WHERE X.CDACESSO = 'FL_GRAVAR_ARQUIVO_INTEAS'
                     AND X.CDCOOPER = 0);
COMMIT;

END;					  