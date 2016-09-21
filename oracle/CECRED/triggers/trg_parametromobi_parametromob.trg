CREATE OR REPLACE TRIGGER CECRED.TRG_ParametroMobi_ParametroMob
	BEFORE INSERT 
	ON ParametroMobile 
	FOR EACH ROW 
	BEGIN 
		SELECT CECRED.SEQ_ParametroMobi_ParametroMob.NEXTVAL 
		INTO :NEW.ParametroMobileId 
		FROM DUAL; 
	END;
/

