<?
/*!
 * FONTE        : form_inclusao.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 01/03/2013
 * OBJETIVO     : Mostrar campos da opcao I - Incluir
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divInclusao">
<form id="frmInclusao" name="frmInclusao" class="formulario">

	
	<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
	<input id="nrdconta" name="nrdconta" type="text" />
	
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<a href="#" class="botao" id="btOK" onclick="consultaInicial();return false;">OK</a>
	<input name="nmprimtl" id="nmprimtl" type="text" value="<? echo $dsdconta ?>" />
	
	<br/>
	<br/>
    <fieldset>
	   	 <legend><? echo utf8ToHtml('Dados do Depositante'); ?></legend>
	

	<label for="cdbandes"><? echo utf8ToHtml('Banco:') ?></label>
	<input id="cdbandes" name="cdbandes" type="text" maxlength="3"  />
	
	<label for="cdagedes"><? echo utf8ToHtml('Ag&ecirc;ncia:') ?></label>
	<input id="cdagedes" name="cdagedes" type="text" maxlength="4"  />
	
	<label for="nrctades"><? echo utf8ToHtml('Conta:') ?></label>
	<input id="nrctades" name="nrctades" type="text" maxlength="12"  />
	
	<br/>
	
	<label for="dacaojud"><? echo utf8ToHtml('A&ccedil;&atilde;o Jud.:') ?></label>
	<input id="dacaojud" name="dacaojud" type="text" maxlength="25" />
	
    </fieldset>	
	
	
	<hr style="background-color:#666; height:1px;" />
	
	<div id="divBotoes">
		<a href="#" class="botao" id="btnVoltar" name="btnVoltar" onClick="estadoInicial();return false;">Voltar</a>
		<a href="#" class="botao" id="btnSalvar" name="btnSalvar" onClick="incluiICF(); return false;">Salvar</a>
	</div>
	
</form>
</div>
