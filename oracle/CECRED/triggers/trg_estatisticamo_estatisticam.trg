CREATE OR REPLACE TRIGGER CECRED.TRG_EstatisticaMo_EstatisticaM
	BEFORE INSERT 
	ON EstatisticaMobile 
	FOR EACH ROW 
	BEGIN 
		SELECT CECRED.SEQ_EstatisticaMo_EstatisticaM.NEXTVAL 
		INTO :NEW.EstatisticaMobileId 
		FROM DUAL; 
	END;
/

