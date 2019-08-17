declare
  vr_nrseqrdr number;

BEGIN
  BEGIN
    INSERT INTO craprdr(nmprogra,dtsolici) VALUES('TELA_ATENDA_PREAPV',SYSDATE)
             RETURNING nrseqrdr INTO vr_nrseqrdr; 
  EXCEPTION
    WHEN OTHERS THEN
      SELECT nrseqrdr
        INTO vr_nrseqrdr
      FROM craprdr
      WHERE nmprogra = 'TELA_ATENDA_PREAPV';
  END; 
  
  BEGIN
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'RESUMO_PREAPV','TELA_ATENDA_PREAPV','pc_resumo_pre_aprovado','pr_nrdconta');
  
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'MOTIVO_SEM_PREAPV','TELA_ATENDA_PREAPV','pc_lista_motivos_sem_preapv','pr_nrdconta');
               
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'COMBO_MOTIVOS_BLOQ','TELA_ATENDA_PREAPV','pc_lista_motivos_tela',NULL);
  
    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
       VALUES(vr_nrseqrdr, 'GRAVA_PARAM_PREAPV','TELA_ATENDA_PREAPV','pc_mantem_param_preapv','pr_nrdconta,pr_flglibera_pre_aprv,pr_dtatualiza_pre_aprv,pr_idmotivo');               
  EXCEPTION 
    WHEN OTHERS THEN
      NULL;
  END;

  BEGIN
    SELECT r.nrseqrdr 
      INTO vr_nrseqrdr
    FROM craprdr r 
    WHERE r.nmprogra = 'ATENDA_CRD';

    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
      VALUES(vr_nrseqrdr, 'GRAVA_PARAM_MAJORA','TELA_ATENDA_CARTAOCREDITO','pc_mantem_param_majora','pr_nrdconta');

    INSERT INTO CRAPACA(NRSEQRDR,NMDEACAO,NMPACKAG,NMPROCED,LSTPARAM)
      VALUES(vr_nrseqrdr, 'BUSCA_PARAM_MAJORA','TELA_ATENDA_CARTAOCREDITO','pc_busca_param_majora','pr_nrdconta');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  commit;
end;