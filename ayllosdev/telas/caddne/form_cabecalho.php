<?
/*
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : Agosto/2011
 * OBJETIVO     : Cabeçalho para a tela CADDNE
 * --------------
 * ALTERAÇÕES   : 07/05/2019 - Alterado o texto das opções (Mateus Z - Mouts)
 * --------------
 */ 
?>
<form id="frmCabCaddne" name="frmCabCaddne" class="formulario cabecalho" style="display:none;" onSubmit="executa_opcao(); return false;">	
	
	<label for="cddopcao">Op&ccedil;&atilde;o:</label>
	<select id="cddopcao" name="cddopcao" alt="Informe a op&ccedil;&atilde;o desejada (A, E ou T)." onchange="altera_opcao()">
		<option value="A"> A - Alterar </option> 
		<option value="E"> E - Excluir </option>
		<option value="T"> T - Importar Arquivos de CEP dos Correios </option>
	</select>
	<label for="nrcepend">CEP:</label>
	<input id="nrcepend" name="nrcepend" alt="Informe o CEP desejado.">
	<input type="image" id="btLupa" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" onclick="return false;" />	
	<input type="image" id="btOK" src="<? echo $UrlImagens; ?>botoes/ok.gif" onClick="executa_opcao(); return false;" />
	<input type="image" id="btRefresh" src="<? echo $UrlImagens; ?>geral/refresh.png" onclick="estado_inicial(); return false;"/>
	<br style="clear:both" />	
	
</form>