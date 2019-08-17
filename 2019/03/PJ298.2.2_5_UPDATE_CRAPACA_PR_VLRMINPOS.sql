-- incluir parametro para identificar o tipo de Emprestimo
UPDATE CRAPACA 
SET LSTPARAM = 'pr_cdcooper,pr_nrconven,pr_nrdconta,pr_prazomax,pr_prazobxa,pr_vlrminpp,pr_vlrmintr,pr_vlrminpos,pr_dslinha1,pr_dslinha2,pr_dslinha3,pr_dslinha4,pr_dstxtsms,pr_dstxtema,pr_blqemiss,pr_qtdmaxbl,pr_flgblqvl,pr_descprej,pr_tpproduto'
WHERE NMDEACAO = 'TAB096_GRAVAR'
  AND NMPACKAG = 'TELA_TAB096';

COMMIT;