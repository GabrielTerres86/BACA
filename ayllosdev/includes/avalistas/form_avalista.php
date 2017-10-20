<?php
/*!
 * FONTE        : form_avalista.php
 * CRIAÇÃO      : Rodolpho Telmo e Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 27/04/2011 
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO da aba NOVO LIMITE do AVALISTA da tela de ATENDA
 *
 * ALTERACOES   : 22/04/2015 - Consultas automatizadas para o limite de credito (Gabriel-RKAM)
 *				  25/07/2016 - Corrigi o uso de indice inexistente no array $registros. SD 479874 (Carlos R.)
 *				  28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
 *							   CH, RE, PP E CT. (PRJ339 - Reinert)
 */	
 
$registros[0]->tags = ( isset($registros[0]->tags) ) ? $registros[0]->tags : array();
$registros[1]->tags = ( isset($registros[1]->tags) ) ? $registros[1]->tags : array();
	
?>	
<fieldset class="fsAvalista">
	<legend>Avalista/Fiadores 1</legend>

	<label for="nrctaav1">Conta/dv:</label>
	<input name="nrctaav1" id="nrctaav1" type="text" value="<? echo !empty($registros[0]) ? getByTagName($registros[0]->tags,'nrctaava') : '0' ?>" />
	<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>	
	<a class="pointer"><img src="<? echo $UrlImagens; ?>geral/refresh.png"></a>		
	
	<label for="nmdaval1">Nome:</label>
	<input name="nmdaval1" id="nmdaval1" type="text" value="<? echo getByTagName($registros[0]->tags,'nmdavali') ?>" />
	<br />
	
	<label for="nrcpfav1">CPF/CNPJ:</label>
	<input name="nrcpfav1" id="nrcpfav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrcpfcgc') ?>" />
    
	<label for="tpdocav1">Doc.:</label>
	<select name="tpdocav1" class="campo" id="tpdocav1">
		<option value=""   <? if (getByTagName($registros[0]->tags,'tpdocava') == ""  ){ echo " selected"; } ?>> </option>
		<option value="CI" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CI"){ echo " selected"; } ?>>CI</option>
		<option value="CN" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CN"){ echo " selected"; } ?>>CN</option>
		<option value="CH" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CH"){ echo " selected"; } ?>>CH</option>
		<option value="RE" <? if (getByTagName($registros[0]->tags,'tpdocava') == "RE"){ echo " selected"; } ?>>RE</option>
		<option value="PP" <? if (getByTagName($registros[0]->tags,'tpdocava') == "PP"){ echo " selected"; } ?>>PP</option>
		<option value="CT" <? if (getByTagName($registros[0]->tags,'tpdocava') == "CT"){ echo " selected"; } ?>>CT</option>
	</select>
	<input name="dsdocav1" id="dsdocav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrdocava') ?>" />
	<br />
	
	<label for="nmdcjav1">C&ocirc;njuge:</label>
	<input name="nmdcjav1" id="nmdcjav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nmconjug') ?>" />

	<label for="cpfcjav1">CPF/CNPJ:</label>
	<input name="cpfcjav1" id="cpfcjav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrcpfcjg') ?>" />
	
	<label for="tdccjav1">Doc.:</label>
	<select name="tdccjav1" class="campo" id="tdccjav1" style="width: 42px;">
		<option value=""   <? if (getByTagName($registros[0]->tags,'tpdoccjg') == ""  ){ echo " selected"; } ?>> </option>
		<option value="CI" <? if (getByTagName($registros[0]->tags,'tpdoccjg') == "CI"){ echo " selected"; } ?>>CI</option>
		<option value="CN" <? if (getByTagName($registros[0]->tags,'tpdoccjg') == "CN"){ echo " selected"; } ?>>CN</option>
		<option value="CH" <? if (getByTagName($registros[0]->tags,'tpdoccjg') == "CH"){ echo " selected"; } ?>>CH</option>
		<option value="RE" <? if (getByTagName($registros[0]->tags,'tpdoccjg') == "RE"){ echo " selected"; } ?>>RE</option>
		<option value="PP" <? if (getByTagName($registros[0]->tags,'tpdoccjg') == "PP"){ echo " selected"; } ?>>PP</option>
		<option value="CT" <? if (getByTagName($registros[0]->tags,'tpdoccjg') == "CT"){ echo " selected"; } ?>>CT</option>
	</select>
	<input name="doccjav1" id="doccjav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrdoccjg') ?>" />
	<br />
	
	<label for="nrcepav1">CEP:</label>
	<input name="nrcepav1" id="nrcepav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrcepend') ?>" />
	<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

	<label for="ende1av1">End.:</label>
	<input name="ende1av1" id="ende1av1" type="text" value="<? echo getByTagName($registros[0]->tags,'dsendre1') ?>" />		

	<label for="nrender1">Nro.:</label>
	<input name="nrender1" id="nrender1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrendere') ?>" />

	<br />
	
	<label for="complen1">Comp.:</label>
	<input name="complen1" id="complen1" type="text" value="<? echo getByTagName($registros[0]->tags,'complend') ?>" />

	<label for="ende2av1">Bairro:</label>
	<input name="ende2av1" id="ende2av1" type="text" value="<? echo getByTagName($registros[0]->tags,'dsendre2') ?>" />								

	<br />	

	<label for="nrcxaps1">Cx.Postal:</label>
	<input name="nrcxaps1" id="nrcxaps1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrcxapst') ?>" />		

	<label for="nmcidav1">Cidade:</label>
	<input name="nmcidav1" id="nmcidav1" type="text"  value="<? echo getByTagName($registros[0]->tags,'nmcidade') ?>" />
	
	<label for="cdufava1">U.F.:</label>
	<?php echo selectEstado('cdufava1', getByTagName($registros[0]->tags,'cdufresd'), 1); ?>	

	<br />

	<label for="nrfonav1">Tel.:</label>
	<input name="nrfonav1" id="nrfonav1" type="text" value="<? echo getByTagName($registros[0]->tags,'nrfonres') ?>" />		

	<label for="emailav1">E-mail:</label>
	<input name="emailav1" id="emailav1" type="text" value="<? echo getByTagName($registros[0]->tags,'dsdemail') ?>" />								
	
	<br />
	
	<label for="vlrenme1">Renda/m&ecirc;s:</label>
	<input name="vlrenme1" id="vlrenme1" type="text" value="<? echo getByTagName($registros[0]->tags,'vlrenmes') ?>" />
	<input type="hidden" name="inpesso1"     id="inpesso1"     value="">
	<input type="hidden" name="ant_nrctaav1" id="ant_nrctaav1" value="">
	<input type="hidden" name="ant_nrcpfav1" id="ant_nrcpfav1" value="">
	
</fieldset>

<fieldset class="fsAvalista">
	<legend>Avalista/Fiadores 2</legend>		

	<label for="nrctaav2">Conta/dv:</label>
	<input name="nrctaav2" id="nrctaav2" type="text" value="<? echo !empty($registros[1]) ? getByTagName($registros[1]->tags,'nrctaava') : '0' ?>" />
	<a class="lupa"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<a class="pointer"><img src="<?php echo $UrlImagens; ?>geral/refresh.png"></a>
	
	<label for="nmdaval2">Nome:</label>
	<input name="nmdaval2" id="nmdaval2" type="text" value="<?php echo getByTagName($registros[1]->tags,'nmdavali') ?>" />
	<br />	

	<label for="nrcpfav2">CPF/CNPJ:</label>
	<input name="nrcpfav2" id="nrcpfav2" type="text" value="<?php echo getByTagName($registros[1]->tags,'nrcpfcgc') ?>" />
	
	<label for="tpdocav2">Doc.:</label>
	<select name="tpdocav2" class="campo" id="tpdocav2">	
		<option value=""   <?php if (getByTagName($registros[1]->tags,'tpdocava') == ""  ){ echo " selected"; } ?>> </option>
		<option value="CI" <?php if (getByTagName($registros[1]->tags,'tpdocava') == "CI"){ echo " selected"; } ?>>CI</option>
		<option value="CN" <?php if (getByTagName($registros[1]->tags,'tpdocava') == "CN"){ echo " selected"; } ?>>CN</option>
		<option value="CH" <?php if (getByTagName($registros[1]->tags,'tpdocava') == "CH"){ echo " selected"; } ?>>CH</option>
		<option value="RE" <?php if (getByTagName($registros[1]->tags,'tpdocava') == "RE"){ echo " selected"; } ?>>RE</option>
		<option value="PP" <?php if (getByTagName($registros[1]->tags,'tpdocava') == "PP"){ echo " selected"; } ?>>PP</option>
		<option value="CT" <?php if (getByTagName($registros[1]->tags,'tpdocava') == "CT"){ echo " selected"; } ?>>CT</option>
	</select>
	<input name="dsdocav2" id="dsdocav2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrdocava') ?>" />
	<br />
	
	<label for="nmdcjav2"><? echo utf8ToHtml('Cônjuge:') ?></label>
	<input name="nmdcjav2" id="nmdcjav2" type="text" value="<? echo getByTagName($registros[1]->tags,'nmconjug') ?>" />

	<label for="cpfcjav2"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
	<input name="cpfcjav2" id="cpfcjav2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrcpfcjg') ?>" />
	
	<label for="tdccjav2"><? echo utf8ToHtml('Doc.:') ?></label>
	<select name="tdccjav2" class="campo" id="tdccjav2">
		<option value=""   <? if (getByTagName($registros[1]->tags,'tpdoccjg') == ""  ){ echo " selected"; } ?>> </option>
		<option value="CI" <? if (getByTagName($registros[1]->tags,'tpdoccjg') == "CI"){ echo " selected"; } ?>>CI</option>
		<option value="CN" <? if (getByTagName($registros[1]->tags,'tpdoccjg') == "CN"){ echo " selected"; } ?>>CN</option>
		<option value="CH" <? if (getByTagName($registros[1]->tags,'tpdoccjg') == "CH"){ echo " selected"; } ?>>CH</option>
		<option value="RE" <? if (getByTagName($registros[1]->tags,'tpdoccjg') == "RE"){ echo " selected"; } ?>>RE</option>
		<option value="PP" <? if (getByTagName($registros[1]->tags,'tpdoccjg') == "PP"){ echo " selected"; } ?>>PP</option>
		<option value="CT" <? if (getByTagName($registros[1]->tags,'tpdoccjg') == "CT"){ echo " selected"; } ?>>CT</option>
	</select>
	<input name="doccjav2" id="doccjav2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrdoccjg') ?>" />
	<br />
	
	<label for="nrcepav2"><? echo utf8ToHtml('CEP:') ?></label>
	<input name="nrcepav2" id="nrcepav2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrcepend') ?>" />
	<a class="lupa"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

	<label for="ende1av2"><? echo utf8ToHtml('End.:') ?></label>
	<input name="ende1av2" id="ende1av2" type="text" value="<? echo getByTagName($registros[1]->tags,'dsendre1') ?>" />		

	<label for="nrender2"><? echo utf8ToHtml('Nro.:') ?></label>
	<input name="nrender2" id="nrender2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrendere') ?>" />

	<br />
	
	<label for="complen2"><? echo utf8ToHtml('Comp.:') ?></label>
	<input name="complen2" id="complen2" type="text" value="<? echo getByTagName($registros[1]->tags,'complend') ?>" />

	<label for="ende2av2"><? echo utf8ToHtml('Bairro:') ?></label>
	<input name="ende2av2" id="ende2av2" type="text" value="<? echo getByTagName($registros[1]->tags,'dsendre2') ?>" />
	<br />

	<label for="nrcxaps2"><? echo utf8ToHtml('Cx.Postal:') ?></label>
	<input name="nrcxaps2" id="nrcxaps2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrcxapst') ?>" />		

	<label for="nmcidav2"><? echo utf8ToHtml('Cidade:') ?></label>
	<input name="nmcidav2" id="nmcidav2" type="text"  value="<? echo getByTagName($registros[1]->tags,'nmcidade') ?>" />
	
	<label for="cdufava2"><? echo utf8ToHtml('U.F.:') ?></label>
	<? echo selectEstado('cdufava2', getByTagName($registros[1]->tags,'cdufresd'), 2); ?>	

	<br />
		
	<label for="nrfonav2"><? echo utf8ToHtml('Tel.:') ?></label>
	<input name="nrfonav2" id="nrfonav2" type="text" value="<? echo getByTagName($registros[1]->tags,'nrfonres') ?>" />		

	<label for="emailav2"><? echo utf8ToHtml('E-mail:') ?></label>
	<input name="emailav2" id="emailav2" type="text" value="<? echo getByTagName($registros[1]->tags,'dsdemail') ?>" />								
	
	<br />
	
	<label for="vlrenme2"><? echo utf8ToHtml('Renda/mês:') ?></label>
	<input name="vlrenme2" id="vlrenme2" type="text" value="<? echo getByTagName($registros[0]->tags,'vlrenmes') ?>" />
	
	<input type="hidden" name="inpesso2" id="inpesso2" value="">	
	<input type="hidden" name="ant_nrctaav2" id="ant_nrctaav2" value="">
	<input type="hidden" name="ant_nrcpfav2" id="ant_nrcpfav2" value="">
	
	<br style="clear:both" />	
</fieldset>		

<script type="text/javascript">
	formataAvalista();
</script>