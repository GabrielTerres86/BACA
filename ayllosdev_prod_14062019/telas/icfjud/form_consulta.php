<?
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 07/03/2013
 * OBJETIVO     : Mostrar campos da opcao C - Consultar
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divConsulta">
<form id="frmConsulta" name="frmConsulta" class="formulario">

	<fieldset>
		<legend><? echo utf8ToHtml('Consultar por'); ?></legend>
	
	<!--	<label for="contacon"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input id="contacon" name="contacon" type="text" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a> -->
		
		<label for="dtinireq"><? echo utf8ToHtml('Data Solicita&ccedil;&atilde;o:') ?></label>
		<input id="dtinireq" name="dtinireq" type="text" />

		<label for="cdbancon"><? echo utf8ToHtml('Banco Requisitado:') ?></label>
		<input id="cdbancon" name="cdbancon" type="text" maxlength="3"  />
		
		<label for="intipreq"><? echo utf8ToHtml('Tp.Req:') ?></label>
		<select id="intipreq" name="intipreq">
			<option value="1"> Enviada </option>
			<option value="2"> Recebida </option>
		</select>
		
		<label for="cdagecon"><? echo utf8ToHtml('Ag&ecirc;ncia Requisitada:') ?></label>
		<input id="cdagecon" name="cdagecon" type="text" maxlength="4"  />
	
		<label for="nrctacon"><? echo utf8ToHtml('Conta Requisitada:') ?></label>
		<input id="nrctacon" name="nrctacon" type="text" maxlength="12"  /><br style="clear:both;" />
	
		<label for="dsdocmc7"><? echo utf8ToHtml('CMC7:') ?></label>
		<input id="dsdocmc7" name="dsdocmc7" type="text" maxlength="50"/>
	
	</fieldset>
	
	<div id="divDadosConsulta">
	
		<br/>
		<br style="clear:both;" />
		<hr style="background-color:#666; height:1px;" />
	</div>
	
	<div id="divBotoes">
		<a href="#" align="center" class="botao" id="btnVoltar" name="btnVoltar" onClick="estadoInicial();return false;">Voltar</a>
		<a href="#" class="botao" id="btnConsultar" name="btnConsultar" onClick="consultaICF(); return false;">Consultar</a>
		<a href="#" class="botao" id="btnReenviar" name="btnReenviar" onClick="reenviarICFs(); return false;">Reenviar</a>
	</div>
	
</form>
</div>
