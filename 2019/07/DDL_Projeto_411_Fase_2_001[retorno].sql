-- Projeto 411.3 Fase 2 - baca de retorno.
DECLARE
 VR_NRSEQRDR CRAPRDR.NRSEQRDR%TYPE;
BEGIN

update CRAPACA SET lstparam =  'pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3'
WHERE upper(nmdeacao)  = 'CUSAPL_LISTA_ARQUIVOS' AND  upper(NMPACKAG)  = 'TELA_CUSAPL';

update CRAPACA set lstparam = 'pr_cdcooper,pr_nrdconta,pr_nraplica,pr_flgcritic,pr_datade,pr_datate,pr_nmarquiv,pr_dscodib3'
WHERE upper(nmdeacao)  = 'CUSAPL_LISTA_OPERAC'   AND  upper(NMPACKAG)  = 'TELA_CUSAPL';   

update CRAPACA set lstparam = 'pr_idarquivo'
WHERE upper(nmdeacao)  = 'CUSAPL_LISTA_CONT_ARQ' AND  upper(NMPACKAG)  = 'TELA_CUSAPL';

commit;

EXCEPTION   
  WHEN OTHERS THEN
    DBMS_APPLICATION_INFO.SET_MODULE(module_name => 'PJ411_F2_P2 - retorno', action_name => 'Carga Parametros');
    CECRED.pc_internal_exception (pr_cdcooper => 0); 
END;