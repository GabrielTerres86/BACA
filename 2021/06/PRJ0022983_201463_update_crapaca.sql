begin
  delete 
	  from crapaca c
   where c.nmpackag = 'TELA_SEGPRE'
     and c.nmdeacao = 'SEGPRE_ALTERAR';
  insert into crapaca
    (nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  values
    ('SEGPRE_ALTERAR',
     'TELA_SEGPRE',
     'pc_alterar',
     ' PR_CDCOPER,PR_TPPESSOA,PR_CDSEGURA,PR_TPDPAGTO,PR_MODALIDA,PR_QTPARCEL,PR_PIEDIAS,PR_PIEPARCE,PR_IFTTDIAS,PR_IFTTPARC,PR_TPCUSTEI,PR_TPADESAO,PR_VIGENCIA,PR_NRAPOLIC,PR_ENDERFTP,PR_LOGINFTP,PR_SENHAFTP,PR_FLGELEPF,PR_FLGINDEN,PR_IDADEMIN,PR_IDADEMAX,PR_GBIDAMIN,PR_GBIDAMAX,PR_PIELIMIT,PR_PIETAXA,PR_IFTTLIMI,PR_IFTTTAXA,PR_LMPSELEG,PR_VLCOMISS,PR_LIMITDPS,PR_CAPITMIN,PR_CAPITMAX,PR_GBSEGMIN,PR_GBSEGMAX ,PR_IDADEDPS',
     '2264');
  COMMIT;
exception
  when others then
    dbms_output.put_line(sqlerrm);
    rollback;
end;
/