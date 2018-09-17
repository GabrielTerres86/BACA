<?
/*!
 * FONTE        : form_reimprime_controle.php
 * CRIAÇÃO      : Fabricio
 * DATA CRIAÇÃO : 22/03/2012
 * OBJETIVO     : Mostrar campos da opcao I - Reimprimir controle de movimentacao em especie
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 * --------------
 */

?>
<div id="divReimprimeControle">
<form id="frmReimprimeControle" name="frmReimprimeControle" class="formulario">

	<label for="dtmvtolt"><? echo utf8ToHtml('Data:') ?></label>
	<input id="dtmvtolt" name="dtmvtolt" type="text"  />
	
	<label for="tpdocmto"><? echo utf8ToHtml('Tipo de Documento:') ?></label>
	<select id="tpdocmto" name="tpdocmto" onChange="habilitaCampos();return false;">
		<option value="" <? echo 'selected' ?> ></option> 
		<option value="0" <? echo $cddopcao == '0' ? 'selected' : '' ?> > 0 - Outros </option> 
		<option value="1" <? echo $cddopcao == '1' ? 'selected' : '' ?> > 1 - DOC C </option>
		<option value="2" <? echo $cddopcao == '2' ? 'selected' : '' ?> > 2 - DOC D </option>
		<option value="3" <? echo $cddopcao == '3' ? 'selected' : '' ?> > 3 - TED </option>
		<option value="4" <? echo $cddopcao == '4' ? 'selected' : '' ?> > 4 - DEP. INTERCOOP. </option>
	</select>
	
	<br/>
	
	<div id="divCampos">
		
		<label for="cdagenci"><? echo utf8ToHtml('PA:') ?></label>
		<input id="cdagenci" name="cdagenci" type="text" />
		
		<label for="cdbccxlt"><? echo utf8ToHtml('Banco/Caixa:') ?></label>
		<input id="cdbccxlt" name="cdbccxlt" type="text"  />
		
		<label for="nrdolote"><? echo utf8ToHtml('Lote:') ?></label>
		<input id="nrdolote" name="nrdolote" type="text"  />
		
		<label for="nrdocmto"><? echo utf8ToHtml('Documento:') ?></label>
		<input id="nrdocmto" name="nrdocmto" type="text"  />
		
	</div>
	
	<div id="divCamposOutros">
		
		<label for="nrdconta"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input id="nrdconta" name="nrdconta" type="text" />
		<a href="#" id="lupaPesq" onClick="mostraPesquisaAssociado('nrdconta','divCamposOutros','');return false;"><img src="<?php  echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
	
	</div>
	
	<div id="divCamposIntercoop">
		
		<label for="cdageint"><? echo utf8ToHtml('PA:') ?></label>
		<input id="cdageint" name="cdageint" type="text"  />
		
		<label for="nrdcaixa"><? echo utf8ToHtml('Caixa:') ?></label>
		<input id="nrdcaixa" name="nrdcaixa" type="text"  />
		
		<label for="nrdocint"><? echo utf8ToHtml('Docmto:') ?></label>
		<input id="nrdocint" name="nrdocint" type="text"  />
		
	</div>
	
	
	<br style="clear:both;" />
	<hr style="background-color:#666; height:1px;" />
	
	
	
	<div id="divDadosMovimentacao">
	</div>
	
	<div id="divBotoes" style="margin-top:5px; margin-bottom:10px">
		<a href="#" class="botao" id="btVoltar" onclick="estadoInicial(); return false;" >Voltar</a>
		<a href="#" class="botao" id="btProsseguir"   onclick="consultaControleMovimentacao(); return false;" >Prosseguir</a>
	</div>
	
	
</form>
</div>
