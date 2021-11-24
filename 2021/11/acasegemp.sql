begin
UPDATE crapaca a 
   SET a.lstparam = 'pr_idsegmento, pr_cdcanal, pr_tppermissao, pr_vlmax_autorizado, pr_tpemprst' 
 WHERE a.nmdeacao = 'SEGEMP_ALTERA_PERM';
commit;
end;