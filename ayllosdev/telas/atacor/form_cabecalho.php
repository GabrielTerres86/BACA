<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Reginaldo (AMcom)
 * DATA CRIAÇÃO : 06/02/2018
 * OBJETIVO     : Cabeçalho para a tela ATACOR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 
 */ 
?>

<form id="frmCabAtacor" name="frmCabAtacor" class="formulario cabecalho" >		
	<label for="nracordo">Acordo: </label>
	<input type="text" id="nracordo" name="nracordo" alt="Informe o nro. do acordo que deseja atualizar." />
	<a href="#" class="botao" id="btBuscaAcordo" onclick="carrega_dados();return false;">Ok</a>
	
	<label for="nmprimtl">Titular:</label>
	<input name="nmprimtl" id="nmprimtl" type="text" readonly/>
	
	<label for="nrdconta">Conta:</label>
	<input name="nrdconta" id="nrdconta" type="text" readonly/>
	
	<br style="clear:both" />		
</form>
