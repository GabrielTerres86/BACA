begin

update cecred.tbseg_param_prst_cap_seg p set p.capitmin = 15000 where p.idseqpar = 6;

commit;
end;