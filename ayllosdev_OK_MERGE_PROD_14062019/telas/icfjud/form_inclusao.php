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
	
	<label for="dacaojud"><? echo utf8ToHtml('A&ccedil;&atilde;o Judicial:') ?></label>
	<input id="dacaojud" name="dacaojud" type="text" maxlength="25" /><br style="clear:both;" />
	
	<label for="tpdconta"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
	<select id="tpdconta" name="tpdconta">
		<option value="00" ></option>
		<option value="01" ><? echo utf8ToHtml('Conta Sacada') ?></option>
		<option value="02" ><? echo utf8ToHtml('Conta Deposit&aacute;ria') ?></option>
	</select>
	
	<br style="clear:both;" />
	
	<label for="dtdtroca"><? echo utf8ToHtml('Data da Troca:') ?></label>
	<input id="dtdtroca" name="dtdtroca" type="text" />
	
	<br style="clear:both;" />
	
	<label for="vldopera"><? echo utf8ToHtml('Valor da Opera&ccedil;&atilde;o:') ?></label>
	<input id="vldopera" name="vldopera" type="text" />	
	
	<br style="clear:both;" />
	
	<label for="dsdocmc7"><? echo utf8ToHtml('CMC7:') ?></label>
	<input id="dsdocmc7" name="dsdocmc7" type="text" maxlength="50"  />
	
    </fieldset>	
	
	
	<div id="divBotoes">
		<a href="#" class="botao" id="btnVoltar" name="btnVoltar" onClick="estadoInicial();return false;">Voltar</a>
		<a href="#" class="botao" id="btnSalvar" name="btnSalvar" onClick="incluiICF(); return false;">Salvar</a>
	</div>
	
</form>
</div>
