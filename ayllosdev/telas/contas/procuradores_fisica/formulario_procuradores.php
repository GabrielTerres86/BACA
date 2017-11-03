<?
/*!
 * FONTE        : formulario_procuradores.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
 * OBJETIVO     : Forumlário de dados de Procuradores para alteração
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 * 				  20/04/2012 - Adicionado os campos dthabmen, inhabmen,
 *							   dshabment (Adriano).
 *
 *                03/09/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 *                31/07/2017 - Aumentado campo dsnatura de 25 para 50, PRJ339-CRM (Odirlei-AMcom).
 *
 *				  28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
 *							   CH, RE, PP E CT. (PRJ339 - Reinert)
 *
 * 				  25/09/2017 - Adicionado uma lista de valores para carregar orgao emissor (PRJ339 - Kelvin).

 *				  18/10/2017 - Removendo caixa postal. (PRJ339 - Kelvin)	
 */	
?>
	
<div id="divProcuradores">
	
	<form name="frmDadosProcuradores" id="frmDadosProcuradores" class="formulario condensado" >		
		<fieldset>
			<legend><? echo utf8ToHtml('Identificação') ?></legend>		

			<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($procuracao->tags,'nrdconta') ?>" />
			
			<label for="nrdctato" class="rotulo rotulo-70">Conta/dv:</label>
			<input name="nrdctato" id="nrdctato" type="text" value="<? echo getByTagName($registros[0]->tags,'nrdctato') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			
			<label for="nrcpfcgc" style="width:249px">C.P.F.:</label>
			<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo getByTagName($registros[0]->tags,'nrcpfcgc') ?>" />
			<br />
			
			<label for="nmdavali" class="rotulo rotulo-70">Nome:</label>
			<input name="nmdavali" id="nmdavali" type="text" value="<? echo getByTagName($registros[0]->tags,'nmdavali') ?>" />
			
			<label for="dtnascto" style="width:56px;">Dt. Nasc.:</label>
			<input name="dtnascto" id="dtnascto" type="text" value="<? echo getByTagName($registros[0]->tags,'dtnascto') ?>" />
			<br />
			
			<label for="inhabmen" class="rotulo rotulo-70">Resp. Legal:</label>
			<select id="inhabmen" name="inhabmen">
				<option value=""> - </option>
				<option value="0" <? if (getByTagName($registros[0]->tags,'inhabmen') == '0'){ echo ' selected'; } ?>> 0 - MENOR / MAIOR</option>
				<option value="1" <? if (getByTagName($registros[0]->tags,'inhabmen') == '1'){ echo ' selected'; } ?>> 1 - MENOR HABILITADO</option>
				<option value="2" <? if (getByTagName($registros[0]->tags,'inhabmen') == '2'){ echo ' selected'; } ?>> 2 - INCAPACIDADE CIVIL</option>
			</select>
			
			<label for="dthabmen" style="width:100px">Dt. Emancipa&ccedil;&atilde;o:</label>
			<input name="dthabmen" id="dthabmen" type="text" value="<? echo getByTagName($registros[0]->tags,'dthabmen') ?>" />
				
			
			<br />
			<label for="tpdocava" class="rotulo rotulo-70">Documento:</label>
			<select name="tpdocava" id="tpdocava">
				<option value="" <? if (getByTagName($IdentFisica,'tpdocava') == ""){ echo " selected"; } ?>> - </option>
				<option value="CI" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CI"){ echo " selected"; } ?>>CI</option>
				<option value="CN" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CN"){ echo " selected"; } ?>>CN</option>
				<option value="CH" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CH"){ echo " selected"; } ?>>CH</option>
				<option value="RE" <? if (getByTagName($registros[0]->tags,'tpdocava') == "RE"){ echo " selected"; } ?>>RE</option>
				<option value="PP" <? if (getByTagName($registros[0]->tags,'tpdocava') == "PP"){ echo " selected"; } ?>>PP</option>
				<option value="CT" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CT"){ echo " selected"; } ?>>CT</option>
			</select>
			<input name="nrdocava" id="nrdocava" type="text" value="<? echo getByTagName($registros[0]->tags,'nrdocava') ?>" />
			
			<label for="cdoeddoc" class="rotulo-linha">Org.Emi.:</label>
			<input name="cdoeddoc" id="cdoeddoc" type="text" value="<? echo getByTagName($registros[0]->tags,'cdoeddoc') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="nmoeddoc" id="nmoeddoc" type="text" style="display:none;" />
			
			<label for="cdufddoc" class="rotulo-linha">U.F.:</label>
			<? echo selectEstado('cdufddoc', getByTagName($registros[0]->tags,'cdufddoc'), 1) ?>
			
			<label for="dtemddoc" style="width:56px;">Dt. Emi.:</label>
			<input name="dtemddoc" id="dtemddoc" type="text" value="<? echo getByTagName($registros[0]->tags,'dtemddoc') ?>" />
			
			<label for="cdestcvl" class="rotulo rotulo-70">Estado Civil:</label>
			<select name="cdestcvl" id="cdestcvl">
				<option value="" selected> - </option>
			</select>
			
			<label for="cdsexcto" style="width:40px;">Sexo:</label>
			<input name="cdsexcto" id="sexoMas" type="radio" class="radio" value="1" <? if (getByTagName($registros[0]->tags,'cdsexcto') == "1") { echo " checked"; } ?> />
			<label for="sexoMas" class="radio">Mas.</label>
			<input name="cdsexcto" id="sexoFem" type="radio" class="radio" value="2" <? if (getByTagName($registros[0]->tags,'cdsexcto') == "2") { echo " checked"; } ?> />
			<label for="sexoFem" class="radio">Fem.</label>
			<br />
				
			<label for="cdnacion" class="rotulo rotulo-70">Nacional.:</label>
			<input name="cdnacion" id="cdnacion" type="text" class="pesquisa" maxlength="15" value="<? echo getByTagName($registros[0]->tags,'cdnacion') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
			<input name="dsnacion" id="dsnacion" type="text" class="alphanum pesquisa" maxlength="15" value="<? echo getByTagName($registros[0]->tags,'dsnacion') ?>" />
			<br />
			
			<label for="dsnatura" class="rotulo rotulo-70">Natural de:</label>
			<input name="dsnatura" id="dsnatura" type="text" class="alphanum pesquisa" maxlength="50" value="<? echo getByTagName($registros[0]->tags,'dsnatura') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		</fieldset>
		
		
		<fieldset>
			<legend><? echo utf8ToHtml('Endereço') ?></legend>		

			<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
			<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($registros[0]->tags,'nrcepend') ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="dsendres"><? echo utf8ToHtml('End.:') ?></label>
			<input name="dsendres" id="dsendres" type="text" value="<? echo getByTagName($registros[0]->tags[30]->tags,'dsendres.1') ?>" />		
			<br />

			<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
			<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($registros[0]->tags,'nrendere') ?>" />

			<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
			<input name="complend" id="complend" type="text" value="<? echo getByTagName($registros[0]->tags,'complend') ?>" />
			<br />

			<label for="cdufresd"><? echo utf8ToHtml('U.F.:') ?></label>
			<? echo selectEstado('cdufresd', getByTagName($registros[0]->tags,'cdufresd'), 1); ?>		

			<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
			<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($registros[0]->tags,'nmbairro') ?>" />								
			<br />	

			<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
			<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($registros[0]->tags,'nmcidade') ?>" />
			
		</fieldset>
		
		
		<fieldset>
			<legend><? echo utf8ToHtml('Filiação') ?></legend>				
			
			<label for="nmmaecto" class="rotulo rotulo-70">Nome M&atilde;e:</label>
			<input name="nmmaecto" id="nmmaecto" type="text" value="<? echo getByTagName($registros[0]->tags,'nmmaecto') ?>" /><br />
			
			<label for="nmpaicto" class="rotulo rotulo-70">Nome Pai:</label>
			<input name="nmpaicto" id="nmpaicto" type="text" value="<? echo getByTagName($registros[0]->tags,'nmpaicto') ?>" /><br />
		</fieldset>
		
		
		<fieldset>
			<legend><? echo utf8ToHtml('Operação') ?></legend>
			
			<label for="vledvmto" class="rotulo rotulo-50">Endivid.:</label>
			<input name="vledvmto" id="vledvmto" type="text" class="moeda" maxlength="18" value="<? echo getByTagName($registros[0]->tags,'vledvmto') ?>" />
			
			<label for="dsrelbem" class="rotulo-linha">Bens:</label>
			<input name="dsrelbem" id="dsrelbem" type="text" value="<? echo $registros[0]->tags[40]->tags[0]->cdata; ?>" />
			<a class="lupaBens"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
						
			<label for="dtvalida" class="rotulo-linha">Vig&ecirc;ncia:</label>
			<input name="dtvalida" id="dtvalida" type="text" class="data" value="<? echo getByTagName($registros[0]->tags,'dtvalida') ?>" />			
		</fieldset>		
	</form>	
	
	<div id="divBotoes">
		<? if ( $operacao == 'CF' ) { ?>		
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoProcuradores('');return false;" />	
		<? } else if ( $operacao == 'A' ) { ?>		
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoProcuradores('');return false;" />		
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoProcuradores('AV');return false;" />		
		<? } else if ( $operacao == 'I' || $operacao == 'IB' ) { ?>	
			<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoProcuradores('');return false;" />		
			<input type="image" id="btLimpar" src="<? echo $UrlImagens; ?>botoes/limpar.gif"   onClick="estadoInicialProcuradores();return false;" />
			<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoProcuradores('IV');return false;" />		
		<? } ?>
	</div>			
</div>