-- incluir parametro para identificar o tipo de Emprestimo
UPDATE CRAPACA 
SET LSTPARAM = LSTPARAM || ',pr_pr_vlrminpos'
WHERE NMDEACAO = 'TAB096_GRAVAR'
  AND NMPACKAG = 'TELA_TAB096';

COMMIT;