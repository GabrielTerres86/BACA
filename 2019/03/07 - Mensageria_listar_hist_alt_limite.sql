declare
vr_inserir_novo_programa boolean;        --> Indica se irá precisar inserir um novo programa/tela web, caso ainda não exista no cadastro
vr_lstparam              varchar2(4000); --> Nome do programa/tela web de execução pela mensageria
vr_nmdeacao              varchar2(100);  --> Nome da acao para execucao
vr_nmpackag              varchar2(100);  --> Nome da package de execucao
vr_nmproced              varchar2(100);  --> Nome da procedure de execucao
vr_nmprogra              varchar2(100);  --> Relação dos parâmetros de entrada da procedure

cursor cr_programa is
select cr.nrseqrdr
from   craprdr cr
where  cr.nmprogra = vr_nmprogra;
rw_programa cr_programa%rowtype;

cursor cr_acao is
select ca.nrseqaca
     , ca.nmpackag
     , ca.nmproced
     , ca.lstparam
from   crapaca ca
where  ca.nmdeacao = vr_nmdeacao
and    ca.nrseqrdr = rw_programa.nrseqrdr;
rw_acao cr_acao%rowtype;

begin 
   vr_inserir_novo_programa := true;
   vr_nmprogra/*Proprama*/  := 'TELA_ATENDA_DESCTO'; 
   vr_nmdeacao/*Ação*/      := 'LISTAR_HIST_ALT_LIMITE';
   vr_nmpackag/*Package*/   := 'TELA_ATENDA_DSCTO_TIT';
   vr_nmproced/*Procedure*/ := 'pc_busca_hist_alt_limite_web';
   vr_lstparam/*Parâmetros*/:= 'pr_nrdconta,pr_tpctrlim,pr_nrctrlim';
   
   open  cr_programa;
   fetch cr_programa into rw_programa;
   if    cr_programa%notfound then
         if  vr_inserir_novo_programa then
             begin
                insert into cecred.craprdr
                       ( nmprogra
                       , dtsolici )
                values ( vr_nmprogra
                       , sysdate )
                returning nrseqrdr into rw_programa.nrseqrdr;             
             exception
                when dup_val_on_index then
                     null;
                when others then
                     raise_application_error(-20001,'Erro ao inserir o programa/tela web '||vr_nmprogra||': '||sqlerrm); 
             end;
         else
             raise_application_error(-20001,'Não foi localizado o programa/tela web '||vr_nmprogra);
         end if;
   end   if;
   close cr_programa;
   
   open  cr_acao;
   fetch cr_acao into rw_acao;
   if    cr_acao%notfound then
         begin
            insert into cecred.crapaca
                   ( nmdeacao
                   , nmpackag
                   , nmproced
                   , lstparam
                   , nrseqrdr)
             values( vr_nmdeacao
                   , vr_nmpackag
                   , vr_nmproced
                   , vr_lstparam
                   , rw_programa.nrseqrdr);           
         exception
            when others then
                 raise_application_error(-20001,'Erro ao inserir a ação de interface web '||vr_nmdeacao||': '||sqlerrm); 
         end;
   else
         begin
            update cecred.crapaca aca
            set    nmpackag = vr_nmpackag
                 , nmproced = vr_nmproced
                 , lstparam = vr_lstparam
            where  aca.nrseqaca = rw_acao.nrseqaca;           
         exception
            when others then
                 raise_application_error(-20001,'Erro ao atualizar a ação de interface web '||vr_nmdeacao||': '||sqlerrm); 
         end;        
   end   if;
   close cr_acao; 
   
   commit;  
end;
