<?
/*!
 * FONTE        : form_consulta_pac.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 05/03/2012
 * OBJETIVO     : Mostrar campos da opcao P - Listar Transacoes sem Documento
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * --------------
 */

?>
<div id="divConsultaPac">
<form id="frmConsultaPac" name="frmConsultaPac" class="formulario">

	
	<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
	<input id="cdagenci" name="cdagenci" type="text" />
	<a id="lupaPesqPa"  name="lupaPesqPa" href="#" onClick="controlaPesquisa();return false;" style="padding: 3px 0 0 3px;" tabindex="-1">
		<img src="http://dwebayllos.cecred.coop.br/imagens/geral/ico_lupa.gif">
	</a>
	
	<br/>
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	
	
	<div id="divDadosConsultaPac">
	</div>
	
	<div id="divBotoes" style="margin-top:5px; margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar"   onclick="estadoInicial(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btnOK"   onclick="consultaTransacoesPac(1, 50); return false;" >Prosseguir</a>
	</div>
	
</form>
</div>
