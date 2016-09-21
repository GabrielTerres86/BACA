<?
/************************************************************************************
  Fonte        : form_detalhes.php
  Criação      : Adriano
  Data criação : Outubro/2011
  Objetivo     : Form dos detalhes dos registros da CADLNG para consulta/exclusao.
  --------------
  Aalterações  :
  --------------
 ************************************************************************************/ 
?>

<form id="frmDetalhes" name="frmDetalhes" class="formulario">	
	
	<label for="detsitua"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
	<input name="detsitua" id="detsitua" type="text" />
		
	<br />
		
	<label for="detnrcpf"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
	<input name="detnrcpf" id="detnrcpf" type="text" />
		
	<br />
		
	<label for="detdnome"><? echo utf8ToHtml('Nome:') ?></label>
	<input name="detdnome" id="detdnome" type="text" />
		
	<br />
		
	<label for="detsolic"><? echo utf8ToHtml('Solicitado por:') ?></label>
	<input name="detsolic" id="detsolic" type="text" />
		
	<br />
		
	<label for="detdtinc"><? echo utf8ToHtml('Data da Inclus&atilde;o:') ?></label>
	<input name="detdtinc" id="detdtinc" type="text" />
	
	<br />
	
	<label for="detmotin"><? echo utf8ToHtml('Motivo da Inclus&atilde;o:') ?></label>
	<textarea name="detmotin" id="detmotin" maxlength="150" style="overflow-y: scroll; overflow-x: hidden; width: 515px; height: 100px; margin-left: 2px;"></textarea>
	
	<br />
		
	<label for="detdocad"><? echo utf8ToHtml('Cadastrado por:') ?></label>
	<input name="detdocad" id="detdocad" type="text" />
		
	<br />
		
	<label for="detexclu"><? echo utf8ToHtml('Exclu&iacute;do por:') ?></label>
	<input name="detexclu" id="detexclu" type="text" />
		
	<br />
		
	<label for="detdtexc"><? echo utf8ToHtml('Data da Exclus&atilde;o:') ?></label>
	<input name="detdtexc" id="detdtexc" type="text" />
		
	<br />
		
	<label for="detmotex"><? echo utf8ToHtml('Motivo da Exclus&atilde;o:') ?></label>
	<textarea name="detmotex" id="detmotex" maxlength="150" ></textarea>
	
	<br />
	
	<div id="divBtDetalhes">
		<span></span>
		<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','realizaExclusao(); ','voltaDiv();','sim.gif','nao.gif');return false" />
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="voltaDiv();return false;" />
	</div>
	
	
</form>