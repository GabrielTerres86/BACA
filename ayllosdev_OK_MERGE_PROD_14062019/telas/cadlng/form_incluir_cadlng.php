<?
/**********************************************************************
  Fonte        : form_incluir_cadlng.php
  Criação      : Adriano
  Data criação : Outubro/2011
  Objetivo     : Form de inclusao CADLNG.
  --------------
  Alterações   :
  --------------
 *********************************************************************/ 
?>

<form id="frmIncCadlng" name="frmIncCadlng" class="formulario">	
		
	<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
	<input name="nrcpfcgc" id="nrcpfcgc" type="text" />
	
	<br />
	
	<label for="nmpessoa"><? echo utf8ToHtml('Nome:') ?></label>
	<input name="nmpessoa" id="nmpessoa" type="text" />
	
	<br />
	
	<label for="cdcoosol">Cooperativa Solicitante:</label>
	<input name="cdcoosol" id="cdcoosol" type="text" value="<? echo getByTagName($registro,'cdcoosol') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	
	<br />
	
	<label for="nmextcop"></label>
	<input name="nmextcop" id="nmextcop" type="text" style="margin-left: 178px;" value="<? echo getByTagName($registro,'nmextcop') ?>" />
	
	<br />
		
	<label for="nmpessol"><? echo utf8ToHtml('Nome Solicitante:') ?></label>
	<input name="nmpessol" id="nmpessol" type="text" />
	
	<br />
	
	<label for="dscarsol"><? echo utf8ToHtml('Cargo Solicitante:') ?></label>
	<input name="dscarsol" id="dscarsol" type="text" />
	
	<br />
	
	<label for="dsmotinc"><? echo utf8ToHtml('Motivo da Inclus&atilde;o:') ?></label>
	<textarea name="dsmotinc" id="dsmotinc" maxlength="150"></textarea>
	
	<br />
	
	<div id="divBtIncluir">
		<span></span>
		<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','realizaInclusao();','limpaCampos();','sim.gif','nao.gif');return false" />
	
	</div>
	
</form>
	
	
