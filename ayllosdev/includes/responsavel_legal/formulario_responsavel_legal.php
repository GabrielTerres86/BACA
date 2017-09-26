<?
/*!
 * FONTE        : formulario_responsavel_legal.php
 * CRIAÇÃO      : Gabriel Santos - DB1 Informatica 
 * DATA CRIAÇÃO : 04/05/2010 
 * OBJETIVO     : Forumlário de dados de Responsável Legal para alteração/consulta 
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 *
 * 				  24/04/2012 : Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *                
 *				  16/07/2015 : Reformulacao cadastral (Gabriel-RKAM).
 *                25/04/2017 : Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 *				  28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
 *							   CH, RE, PP E CT. (PRJ339 - Reinert)
 */	
?>
	
	
<form name="frmRespLegal" id="frmRespLegal" class="formulario" >

	<fieldset>
	
		<legend><? echo utf8ToHtml('Identificação'); ?></legend>
		<label for="nrdctato" class="rotulo rotulo-70">Conta/dv:</label>
		<input name="nrdctato" id="nrdctato" type="text" value="<? echo $frm_nrdconta; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="nrcpfcto">C.P.F.:</label>
		<input name="nrcpfcto" id="nrcpfcto" type="text" value="<? echo $frm_nrcpfcgc; ?>" />
		<br />
		
		<label for="nmdavali" class="rotulo rotulo-70">Nome:</label>
		<input name="nmdavali" id="nmdavali" type="text" value="<? echo $frm_nmrespon; ?>" />
		
		<label for="dtnascto" class="rotulo-60">Dt. Nasc.:</label>
		<input name="dtnascto" id="dtnascto" type="text" value="<? echo $frm_dtnascin; ?>" />
		<br />
		
		<label for="tpdocava" class="rotulo rotulo-70">Documento:</label>
		<select name="tpdocava" id="tpdocava">
			<option value="" <? if (getByTagName($IdentFisica,'tpdocava') == ""){ echo " selected"; } ?>> - </option>
			<option value="CI" <? if ($frm_tpdeiden == "CI"){ echo " selected"; } ?>>CI</option>
			<option value="CN" <? if ($frm_tpdeiden == "CN"){ echo " selected"; } ?>>CN</option>
			<option value="CH" <? if ($frm_tpdeiden == "CH"){ echo " selected"; } ?>>CH</option>
			<option value="RE" <? if ($frm_tpdeiden == "RE"){ echo " selected"; } ?>>RE</option>
			<option value="PP" <? if ($frm_tpdeiden == "PP"){ echo " selected"; } ?>>PP</option>
			<option value="CT" <? if ($frm_tpdocava == "CT"){ echo " selected"; } ?>>CT</option>
		</select>
		<input name="nrdocava" id="nrdocava" type="text" value="<? echo $frm_nridenti; ?>" />
		
		<label for="cdoeddoc" class="rotulo-60">Org.Emi.:</label>
		<input name="cdoeddoc" id="cdoeddoc" type="text" value="<? echo $frm_dsorgemi; ?>" />
		<br />
		
		<label for="cdufddoc" class="rotulo rotulo-70">U.F.:</label>
		<? echo selectEstado('cdufddoc', $frm_cdufiden); ?>
		
		<label for="dtemddoc" class="rotulo-60">Data Emi.:</label>
		<input name="dtemddoc" id="dtemddoc" type="text" value="<? echo $frm_dtemiden; ?>" />
		<br />
		
		<label for="cdestciv" class="rotulo rotulo-70">Est. Civil:</label>
		<input name="cdestciv" type="hidden" value="<? echo $frm_cdestciv; ?>" />
		<select name="cdestciv" id="cdestciv">
			<option value="" selected> - </option>
		</select>
		
		<label for="sexoMas" class="rotulo-60">Sexo:</label>
		<input name="cdsexcto" id="sexoMas" type="radio" class="radio" value="1" <? if ($frm_cddosexo == "1") { echo " checked"; } ?> />
		<label for="sexoMas" class="radio">Mas.</label>
		<input name="cdsexcto" id="sexoFem" type="radio" class="radio" value="2" <? if ($frm_cddosexo == "2") { echo " checked"; } ?> />
		<label for="sexoFem" class="radio">Fem.</label>
		<br />
			
		<label for="cdnacion" class="rotulo rotulo-70">Nacional.:</label>
        <input name="cdnacion" id="cdnacion" type="text" value="<? echo $frm_cdnacion; ?>" />
        <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="dsnacion" id="dsnacion" type="text" value="<? echo $frm_dsnacion; ?>" />
		<br />
		
		<label for="dsnatura" class="rotulo rotulo-70">Natural de:</label>
		<input name="dsnatura" id="dsnatura" type="text" value="<? echo $frm_dsnatura; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<br />
		
	</fieldset>		
	
	<fieldset>
	
		<legend><? echo utf8ToHtml('Endereço'); ?></legend>
	
		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo $frm_cdcepres; ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="dsendere"><? echo utf8ToHtml('End.:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo $frm_dsendres; ?>" />		
		<br />

		<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo $frm_nrendres; ?>" />
		
		<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo $frm_dscomres; ?>" />
		<br />
		
		<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
		<input name="nrcxapst" id="nrcxapst" type="text" value="<? echo $frm_nrcxpost; ?>" />		
		
		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo $frm_dsbaires; ?>" />								
		<br />	
		
		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', $frm_dsdufres, 1); ?>	
		
		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo $frm_dscidres ?>" />

		<br />
		
	</fieldset>	
	
	<fieldset>
	
		<legend><? echo utf8ToHtml('Filiação'); ?></legend>
		
		<label for="nmmaecto" class="rotulo rotulo-70">Nome M&atilde;e:</label>
		<input name="nmmaecto" id="nmmaecto" type="text" value="<? echo $frm_nmmaersp; ?>" /><br />
		<br />
		
		<label for="nmpaicto" class="rotulo rotulo-70">Nome Pai:</label>
		<input name="nmpaicto" id="nmpaicto" type="text" value="<? echo $frm_nmpairsp; ?>" /><br />
		<br clear="both" />
		
	</fieldset>		
	
	<fieldset>
	
		<legend> Relacionamento com Titular </legend>
		
		<label for="cdrelacionamento" class="rotulo rotulo-150">Relacionamento com Titular:</label>
		<input name="cdrelacionamento" type="hidden" value="<? echo $frm_cdrlcrsp; ?>" />
		<select name="cdrelacionamento" id="cdrelacionamento" class="campo">
			<option value="" selected> - </option>
		</select>
	
	</fieldset>
	
</form>	
	
<div id="divBotoesFrmResp">
			
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"   onClick="" />
	<input type="image" id="btLimpar" src="<? echo $UrlImagens; ?>botoes/limpar.gif"   onClick="" />		
	<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="" />		
				
	
</div>			