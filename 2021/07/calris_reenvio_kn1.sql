DECLARE

BEGIN

UPDATE tbcalris_tanque
   SET cdstatus = 7
 WHERE idcalris_tanque in (
	72605,72583,75556,69606,79380,77991,77925,68702,68998,70017,70275,69712,74984
   ,75442,75459,76269,77988,78713,78033,79215,79381,79382,79383,78670,79412,79413
   ,79414,79423,78855,77872,79384,81191,80921,81862,81746);
COMMIT;

UPDATE tbcalris_pessoa
   SET dhkn1 = null
     , cdclasrisco_kn1 = null
 WHERE idcalris_pessoa IN (
	91706,91684,95638,88593,98581,97192,97126,
	87902,88198,89004,89262,88699,94084,94542,
	94559,95348,97189,97914,97234,98416,98582,
	98583,98584,97871,98613,98614,98615,98624,
	98056,97073,98585,100605,100335,100104,99988
 );
 COMMIT;

END;
/