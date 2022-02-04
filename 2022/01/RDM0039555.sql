BEGIN
    delete tbgen_notif_push
    where cdnotificacao in
    (
    select cdnotificacao
    FROM
    tbgen_notif_push
    WHERE
        cdnotificacao IN (
        SELECT
        cdnotificacao
        FROM
        tbgen_notificacao
        WHERE
        cdmensagem = 7858)
    );
    COMMIT;
END;

BEGIN
    delete tbgen_notif_push
    where cdnotificacao in
    (
    select cdnotificacao
    FROM
    tbgen_notif_push
    WHERE
        cdnotificacao IN (
        SELECT
        cdnotificacao
        FROM
        tbgen_notificacao
        WHERE
        cdmensagem = 7870)
    );
    COMMIT;
END;