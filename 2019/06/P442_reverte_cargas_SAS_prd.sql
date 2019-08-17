/* Reverter todas as cargas carregadas parcialmente devido problemas PRE-APROVADO */
DECLARE
  CURSOR cr_busca_cargas IS
    SELECT pot.skcarga  
          ,NVL(carAim.idcarga, 99999) idcarga
    FROM integradados.sas_preaprovado_carga@sasrw pot 
        ,integradados.dw_fatocontrolecarga@sasrw car
        ,tbepr_carga_pre_aprv       carAim
    WHERE car.skcarga = carAim.Skcarga_Sas(+)
       AND pot.skcarga = car.skcarga 
       AND car.qtregistroprocessado > 0 
       AND car.dthorafiminclusao IS NOT NULL 
       AND dthorainicioprocesso IS NOT NULL
	   AND car.dthorainicioprocesso IS NOT NULL
	   AND car.dthorafimprocesso IS NULL
	   AND pot.skcarga = 64902;
  
BEGIN
  FOR rw_busca_cargas IN cr_busca_cargas LOOP
    DELETE TBEPR_MOTIVO_NAO_APRV
    WHERE idcarga = rw_busca_cargas.idcarga;
    
    DELETE tbepr_carga_pre_aprv
    WHERE idcarga = rw_busca_cargas.idcarga;
    
    DELETE tbepr_carga_pre_aprv
    WHERE idcarga = rw_busca_cargas.idcarga;
    
    DELETE tbepr_carga_pre_aprv
    WHERE idcarga = rw_busca_cargas.idcarga;
    
    UPDATE integradados.dw_fatocontrolecarga@sasrw
    SET dthorafimprocesso = NULL
       ,dthorainicioprocesso = NULL
    WHERE skcarga = rw_busca_cargas.skcarga;
    
    UPDATE integradados.sas_preaprovado_limite@sasrw
    SET cdstatuscarga = NULL
       ,dsstatuscarga = NULL
    WHERE skcarga = rw_busca_cargas.skcarga;
    
    UPDATE integradados.sas_preaprovado_carga@sasrw
    SET dtliberacao = NULL
       ,dtbloqueio= NULL
       ,cdopliberacao = NULL
       ,cdopbloqueio = NULL
    WHERE skcarga = rw_busca_cargas.skcarga;
    
    DELETE crapcpa
    WHERE iddcarga = rw_busca_cargas.skcarga;
  END LOOP;
END;
