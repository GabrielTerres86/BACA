CREATE OR REPLACE TRIGGER PROGRID.TRG_HISTORICO_GNAPFDP
  AFTER UPDATE OR DELETE ON GNAPFDP
  FOR EACH ROW
DECLARE  

  -- local variables here
  PROCEDURE grava_historico (pr_nmdcampo    IN VARCHAR2,
                             pr_vlantcmp    IN VARCHAR2,
                             pr_vlatucmp    IN VARCHAR2) IS
  vr_idevento craphfp.idevento%TYPE;
  vr_cdcooper craphfp.cdcooper%TYPE;
  vr_nrcpfcgc craphfp.nrcpfcgc%TYPE;

  vr_hratuali craphfp.hratuali%TYPE := TO_CHAR(SYSDATE,'SSSSS');
  vr_cdcopope craphfp.cdcopope%TYPE;
  vr_cdoperad craphfp.cdoperad%TYPE;


  BEGIN
    IF UPDATING THEN -- Alteração
      vr_idevento := :NEW.IDEVENTO;
      vr_cdcooper := :NEW.CDCOOPER;
      vr_nrcpfcgc := :NEW.nrcpfcgc;
      vr_cdcopope := :NEW.CDCOPOPE;
      vr_cdoperad := :NEW.CDOPERAD;

    ELSE
      vr_idevento := :OLD.IDEVENTO;
      vr_cdcooper := :OLD.CDCOOPER;
      vr_nrcpfcgc := :OLD.nrcpfcgc;
      vr_cdcopope := :OLD.CDCOPOPE;
      vr_cdoperad := :OLD.CDOPERAD;

    END IF;
    BEGIN
      INSERT INTO craphfp
                  (idevento,
                   cdcooper,
                   nrcpfcgc,
                   nmdcampo,
                   dtatuali,
                   hratuali,
                   dsantcmp,
                   dsatucmp,
                   cdcopope,
                   cdoperad)
             VALUES(
                  vr_idevento,
                  vr_cdcooper,
                  vr_nrcpfcgc,
                  pr_nmdcampo,
                  SYSDATE,
                  vr_hratuali,
                  nvl(pr_vlantcmp,' '),
                  nvl(pr_vlatucmp,' '),             
                  vr_cdcopope,
                  vr_cdoperad);
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20500,'Erro ao gravar tabela craphfp: ' || SQLERRM);
    END;
  END;

BEGIN

    IF NVL(:OLD.DTFORINA,SYSDATE+999) <> NVL(:NEW.DTFORINA,SYSDATE+999) THEN
      grava_historico(pr_nmdcampo  => 'DTFORINA',
                      pr_vlantcmp  => to_char(:OLD.dtforina,'DD/MM/RRRR'),
                      pr_vlatucmp  => to_char(:NEW.dtforina,'DD/MM/RRRR') );
    END IF;

    IF NVL(:OLD.DSJUSAIN,' ') <>  NVL(:NEW.DSJUSAIN,' ') THEN
      grava_historico( pr_nmdcampo  =>'DSJUSAIN',
                       pr_vlantcmp  =>:OLD.dsjusain,
                       pr_vlatucmp  =>:NEW.dsjusain );
    END IF;



END TRG_HISTORICO_GNAPFDP;
/
