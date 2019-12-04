INSERT INTO CRAPACA(NMDEACAO,
                        NMPACKAG,
                        NMPROCED,
                        LSTPARAM,
                        NRSEQRDR)
                 VALUES('VALIDA_CDSEGURANCA',
                        'TELA_COMPEN',
                        'pc_valida_cdseguranca',
                        'pr_cdseguranca',
                        (select nrseqrdr from craprdr where nmprogra = 'TELA_COMPEN'));
                        commit;