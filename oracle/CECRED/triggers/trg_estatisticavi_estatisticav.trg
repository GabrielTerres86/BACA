CREATE OR REPLACE TRIGGER CECRED.TRG_EstatisticaVi_EstatisticaV
	BEFORE INSERT 
	ON EstatisticaVisao 
	FOR EACH ROW 
	BEGIN 
		SELECT SEQ_EstatisticaVi_EstatisticaV.NEXTVAL 
		INTO :NEW.EstatisticaVisaoId 
		FROM DUAL; 
	END;
/

