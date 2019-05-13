-- Add/modify columns 
alter table CRAWEPR add vliofcon number(25,2);
-- Add comments to the columns 
comment on column CRAWEPR.VLIOFCON is 'Valor do IOF do emprestimo consignado. (Valor calculado pelo sistema FIS)';
