DECLARE

  CURSOR cr_crapttl IS
    SELECT t.dsjusren
    FROM CECRED.crapttl t
    WHERE t.nrdconta = 523275
      AND t.cdcooper = 13
      AND t.nrcpfcgc = 4089712904
      ;
      
  vr_dsjusren  CECRED.crapttl.DSJUSREN%TYPE;
  vr_pos_erro         PLS_INTEGER;
  vr_criticcd         NUMBER;
  vr_criticds         VARCHAR2(2000);
  
BEGIN
  
  OPEN cr_crapttl;
  FETCH cr_crapttl INTO vr_dsjusren;
  CLOSE cr_crapttl;

  CONTACORRENTE.validaCaracteresTexto (
      pr_dstexto                => to_char( utl_raw.cast_to_raw(vr_dsjusren) )
      , pr_nmdomlib             => 'MAPA_CARACTERES_VALIDOS'
      , pr_nmdomblq             => 'MAPA_CARACTERES_BLOQUEADOS'
      , pr_nrdconta             => 523275
      , pr_cdcooper             => 13
      , pr_poserror             => vr_pos_erro
      , pr_dscritic             => vr_criticds
      , pr_cdcritic             => vr_criticcd
      , pr_dstxtret             => vr_dsjusren);

  UPDATE CECRED.crapttl 
    SET dsjusren = vr_dsjusren
  WHERE nrdconta = 523275
    AND cdcooper = 13
    AND nrcpfcgc = 4089712904;
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
