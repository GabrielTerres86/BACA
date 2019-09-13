insert into crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr) 
            values  ('BACA_EMPR_CONSIG','TELA_CONSIG','pc_baca_empr_consig','pr_cdcooper'
                    , (select nrseqrdr from craprdr where nmprogra = 'TELA_CONSIG' )) ;

insert into crapaca (nmdeacao,nmpackag,nmproced,lstparam,nrseqrdr) 
            values  ('BACA_CONSIG','TELA_CONSIG','pc_baca_consig','pr_cdcooper,pr_cdempres'
                    , (select nrseqrdr from craprdr where nmprogra = 'TELA_CONSIG' )) ;

commit;
