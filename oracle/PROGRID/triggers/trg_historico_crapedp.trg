CREATE OR REPLACE TRIGGER PROGRID.TRG_HISTORICO_CRAPEDP
  after update or delete on crapedp
  for each row
declare
  -- local variables here
  procedure grava_historico (id_acao in varchar2,
                             nm_campo in varchar2,
                             vl_anterior in varchar2,
                             vl_atual in varchar2) is
  wr_idevento crapedp.idevento%type;
  wr_cdcooper crapedp.cdcooper%type;
  wr_dtanoage crapedp.dtanoage%type;
  wr_cdevento crapedp.cdevento%type;
 
  wr_hratuali CRAPHEV.hratuali%TYPE := TO_CHAR(SYSDATE,'SSSSS');

  begin
    IF id_acao = 'A' then -- Alteração
      wr_idevento := :NEW.IDEVENTO;
      wr_cdcooper := :NEW.CDCOOPER;
      wr_dtanoage := :NEW.DTANOAGE;
      wr_cdevento := :NEW.CDEVENTO;
   
    ELSE
      wr_idevento := :OLD.IDEVENTO;
      wr_cdcooper := :OLD.CDCOOPER;
      wr_dtanoage := :OLD.DTANOAGE;
      wr_cdevento := :OLD.CDEVENTO;
     
    END IF;

      insert into craphev 
                  (IDEVENTO,
                   CDCOOPER, 
                   DTANOAGE, 
                   CDEVENTO, 
                   NMDCAMPO, 
                   DTATUALI, 
                   DSANTCMP, 
                   DSATUCMP, 
                   HRATUALI)
             values(
                  wr_idevento,
                  wr_cdcooper,
                  wr_dtanoage,
                  wr_cdevento ,
                  nm_campo,
                  SYSDATE,
                  vl_anterior,
                  vl_atual,                 
                  wr_hratuali
                  );

  end;
begin
  IF UPDATING THEN
    IF :NEW.tpevento  <> :OLD.tpevento THEN
      grava_historico('A','TPEVENTO',:OLD.tpevento,:NEW.tpevento );
    END IF;

    IF :NEW.qtmaxtur         <> :OLD.qtmaxtur THEN
      grava_historico('A','QTMAXTUR',:OLD.qtmaxtur,:NEW.qtmaxtur );
    END IF;

    IF :NEW.qtmintur         <> :OLD.qtmintur THEN
      grava_historico('A','QTMIMTUR',:OLD.qtmintur,:NEW.qtmintur );
    END IF;

    IF :NEW.tppartic         <> :OLD.tppartic THEN
      grava_historico('A','TPPARTIC',:OLD.tppartic,:NEW.tppartic );
    END IF;

    IF :NEW.qtparcta         <> :OLD.qtparcta THEN
      grava_historico('A','QTPARCTA',:OLD.qtparcta,:NEW.qtparcta );
    END IF;

    IF :NEW.flgcompr         <> :OLD.flgcompr THEN
      grava_historico('A','FLGCOMPR',:OLD.flgcompr,:NEW.flgcompr );
    END IF;

    IF :NEW.flgtdpac         <> :OLD.flgtdpac THEN
      grava_historico('A','FLGTDPAC',:OLD.flgtdpac,:NEW.flgtdpac );
    END IF;

    IF :NEW.flgcerti         <> :OLD.flgcerti THEN
      grava_historico('A','FLGCERTI',:OLD.flgcerti,:NEW.flgcerti );
    END IF;

    IF :NEW.flgrestr         <> :OLD.flgrestr THEN
      grava_historico('A','FLGRESTR',:OLD.flgrestr,:NEW.flgrestr );
    END IF;

    IF :NEW.flgativo         <> :OLD.flgativo THEN
      grava_historico('A','FLGATIVO',:OLD.flgativo,:NEW.flgativo );
    END IF;

    IF :NEW.flgsorte         <> :OLD.flgsorte THEN
      grava_historico('A','FLGSORTE',:OLD.flgsorte,:NEW.flgsorte );
    END IF;

    IF :NEW.nridamin         <> :OLD.nridamin THEN
      grava_historico('A','NRIDAMIN',:OLD.nridamin,:NEW.nridamin );
    END IF;

    IF :NEW.prfreque         <> :OLD.prfreque THEN
      grava_historico('A','PRFREQUE',:OLD.prfreque,:NEW.prfreque );
    END IF;

    IF :NEW.cdeixtem         <> :OLD.cdeixtem THEN
      grava_historico('A','CDEIXTEM',:OLD.cdeixtem,:NEW.cdeixtem );
    END IF;

    IF :NEW.nmevento         <> :OLD.nmevento THEN
      grava_historico('A','NMEVENTO',:OLD.nmevento,:NEW.nmevento );
    END IF;

    IF :NEW.dtlibint         <> :OLD.dtlibint THEN
      grava_historico('A','DTLIBINT',:OLD.dtlibint,:NEW.dtlibint );
    END IF;

    IF :NEW.dtretint         <> :OLD.dtretint THEN
      grava_historico('A','DTRETINT',:OLD.dtretint,:NEW.dtretint );
    END IF;

    --Campos novos para inclusão após criação dos mesmos na tabela:
    --NRSEQTEM
    IF :NEW.NRSEQTEM   <> :OLD.NRSEQTEM THEN
      grava_historico('A','NRSEQTEM',:OLD.NRSEQTEM,:NEW.NRSEQTEM );
    END IF;

    --NRSEQPRI
    IF :NEW.NRSEQPRI   <> :OLD.NRSEQPRI THEN
      grava_historico('A','NRSEQPRI',:OLD.NRSEQPRI,:NEW.NRSEQPRI );
    END IF;

    --CDOPERAD
    IF :NEW.CDOPERAD   <> :OLD.CDOPERAD THEN
      grava_historico('A','CDOPERAD',:OLD.CDOPERAD,:NEW.CDOPERAD );
    END IF;

    --DSJUSTIF
    IF :NEW.DSJUSTIF   <> :OLD.DSJUSTIF THEN
      grava_historico('A','DSJUSTIF',:OLD.DSJUSTIF,:NEW.DSJUSTIF );
    END IF;

    IF :NEW.qtdiaeve         <> :OLD.qtdiaeve THEN
      grava_historico('A','QTDIAEVE',:OLD.qtdiaeve,:NEW.qtdiaeve );
    END IF;

  ELSIF DELETING THEN
      grava_historico('E','TPEVENTO',:OLD.tpevento,'' );
      grava_historico('E','QTMAXTUR',:OLD.qtmaxtur,'' );
      grava_historico('E','QTMIMTUR',:OLD.qtmintur,'' );
      grava_historico('E','TPPARTIC',:OLD.tppartic,'' );
      grava_historico('E','QTPARCTA',:OLD.qtparcta,'' );
      grava_historico('E','FLGCOMPR',:OLD.flgcompr,'' );
      grava_historico('E','FLGTDPAC',:OLD.flgtdpac,'' );
      grava_historico('E','FLGCERTI',:OLD.flgcerti,'' );
      grava_historico('E','FLGRESTR',:OLD.flgrestr,'' );
      grava_historico('E','FLGATIVO',:OLD.flgativo,'' );
      grava_historico('E','FLGSORTE',:OLD.flgsorte,'' );
      grava_historico('E','NRIDAMIN',:OLD.nridamin,'' );
      grava_historico('E','PRFREQUE',:OLD.prfreque,'' );
      grava_historico('E','CDEIXTEM',:OLD.cdeixtem,'' );
      grava_historico('E','NMEVENTO',:OLD.nmevento,'' );
      grava_historico('E','DTLIBINT',:OLD.dtlibint,'' );
      grava_historico('E','DTRETINT',:OLD.dtretint,'' );
      grava_historico('E','NRSEQTEM',:OLD.NRSEQTEM,'' );
      grava_historico('E','CDOPERAD',:OLD.CDOPERAD,'' );
      grava_historico('E','DSJUSTIF',:OLD.DSJUSTIF,'' );
      grava_historico('E','QTDIAEVE',:OLD.QTDIAEVE,'' );
  END IF;
end TRG_HISTORICO_CRAPEDP;
/

