--   executar update na TBSEG_PRESTAMISTA
Declare 
  vr_contador number;
  vr_dscritic varchar2(500);
  VR_NRPROPOSTA varchar2(15);
  vr_excsaida EXCEPTION;  
  cursor cr_curs  is
  SELECT IDSEQTRA, CDAPOLIC  ,CDCOOPER, NRDCONTA, NRCTRSEG, NRCTREMP, a.rowid   FROM  tbseg_prestamista a     
   where  NRPROPOSTA is null 
  order by 1,2,3;  
begin
  vr_contador:=0;

  FOR rw_curs IN cr_curs LOOP    
    vr_contador:= vr_contador + 1;         
    BEGIN
      SELECT SEGU0003.FN_NRPROPOSTA() INTO VR_NRPROPOSTA  FROM DUAL;
      UPDATE tbseg_prestamista set nrproposta = VR_NRPROPOSTA --vr_contador
       ,dtdenvio = null
       , tpregist = case when tpregist = 3 then 1 else tpregist end        
       WHERE ROWID = rw_curs.rowid;
       UPDATE CECRED.TBSEG_NRPROPOSTA SET  DTSEGURO = SYSDATE  WHERE NRPROPOSTA  = VR_NRPROPOSTA ; 
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar crapseg! rowid: '||
                       rw_curs.rowid; 
        RAISE vr_excsaida;
    END;   
  END LOOP;
  commit;  
  vr_dscritic := 'SUCESSO -> Registros atualizados: '|| vr_contador;
EXCEPTION
  WHEN vr_excsaida then 
    DBMS_OUTPUT.PUT_LINE('Erro : '||vr_dscritic);
    rollback;
end;
