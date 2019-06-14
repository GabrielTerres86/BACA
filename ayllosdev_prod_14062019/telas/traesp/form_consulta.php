<?
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 28/02/2012
 * OBJETIVO     : Mostrar campos da opcao C - Consultar
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divConsulta">
<form id="frmConsulta" name="frmConsulta" class="formulario">

	
	<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
	<input id="nrdconta" name="nrdconta" type="text" />
	<a href="#" onClick="mostraPesquisaAssociado('nrdconta','frmConsulta','');return false;"><img src="<?php  echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>

	<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>
	<input id="dtmvtolt" name="dtmvtolt" type="text"  />
	
	<br/>
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	
	
	<div id="divDadosConsulta" width="100%">
	</div>
	
	<div id="divBotoes" style="margin-top:5px; margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btOK"   onclick="consultaTransacoes(1, 50); return false;" >Prosseguir</a>
	</div>
	
</form>
</div>
