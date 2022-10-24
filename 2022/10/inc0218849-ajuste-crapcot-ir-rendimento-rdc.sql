BEGIN
	UPDATE cecred.crapcot
       SET vlrenrdc##8 = nvl(vlrenrdc##8,0) + 22114.17,
           vlrentot##8 = nvl(vlrentot##8,0) + 22114.17,
           vlirfrdc##8 = nvl(vlirfrdc##8,0) + 4975.69
     WHERE cdcooper = 13 and nrdconta = 99842572; 

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/