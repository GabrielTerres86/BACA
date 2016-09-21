CREATE OR REPLACE TRIGGER CECRED.TRG_UsuarioMobile_UsuarioMobil
	BEFORE INSERT 
	ON UsuarioMobile 
	FOR EACH ROW 
	BEGIN 
		SELECT SEQ_UsuarioMobile_UsuarioMobil.NEXTVAL 
		INTO :NEW.UsuarioMobileId 
		FROM DUAL; 
	END;
/

