BEGIN
    UPDATE CECRED.TBEPR_CDC_USUARIO CDC
    SET
        CDC.DSLOGIN = '47243147000176'
    WHERE
        CDC.IDUSUARIO = 84707;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20500, SQLERRM);
        ROLLBACK;
END;
/