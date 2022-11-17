BEGIN
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA ESSENCIAL' where t.cdpacote = 102;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA ESPECIAL' where t.cdpacote = 103;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA PROTAGONISTA' where t.cdpacote = 104;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA MEI' where t.cdpacote = 105;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA COOP' where t.cdpacote = 106;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA MAX' where t.cdpacote = 107;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'CESTA PREMIUM' where t.cdpacote = 108;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XI' where t.cdpacote = 109;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XII' where t.cdpacote = 110;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XIII' where t.cdpacote = 111;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XIV' where t.cdpacote = 112;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XV' where t.cdpacote = 113;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XVI' where t.cdpacote = 114;
  update CECRED.TBTARIF_PACOTES t set t.dspacote = 'PACOTE DE SERVICOS PJ XVII' where t.cdpacote = 115;
  COMMIT;
END;


