UPDATE crapaca
SET lstparam = lstparam || ', pr_flgentepb'
WHERE nmdeacao = 'CALCULAR_TARIFA'
AND   nmpackag = 'TELA_CADSMS';

UPDATE crapaca
SET lstparam = lstparam || ', pr_flgentepb'
WHERE nmdeacao = 'INSERIR_PACOTE'
AND   nmpackag = 'TELA_CADSMS';

UPDATE crapaca
SET lstparam = lstparam || ', pr_nrdconta'
WHERE nmdeacao = 'LISTAR_PACOTES'
AND   nmpackag = 'TELA_CADSMS';
