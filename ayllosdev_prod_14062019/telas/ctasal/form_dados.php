<?php
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 26/02/2013
 * OBJETIVO     : Formlario manipulação de dados
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
 *
 *				  23/02/2016 - Validacao nonome do funcionario (Jean Michel). 
 *
 *				  27/07/2016 - Adicionar chamada da funcao validaDados no Titular (Lucas Ranghetti #457281)
 *				  
 *				  18/08/2016 - Adicionado maxlength no nome do funcionario 
 *							   conforme solicitado no chamado 504050. (Kelvin)
 *							   
 *				  14/05/2018 - Incluido novo campo "Tipo de Conta" (tpctatrf) na tela CTASAL
 *                             Projeto 479-Catalogo de Servicos SPB (Mateus Z - Mouts)
 *			   
 * --------------
 */ 
?>

<form id="frmDados" name="frmDados" class="formulario">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
	<input type="hidden" name="nrdconta" id="nrdconta" />
	<input type="hidden" name="flgsolic" id="flgsolic" />

	<label for="nmfuncio"><? echo utf8ToHtml('Titular:') ?></label>
	<input id="nmfuncio" maxlength="60" name="nmfuncio" type="text" value="<? echo getByTagName($registro,'nmfuncio') ?>" onBlur="retirarAcentuacao(this.value);validaDados();" />
	
	<label for="nrcpfcgc"><? echo utf8ToHtml('C.P.F.:') ?></label>
	<input id="nrcpfcgc" name="nrcpfcgc" type="text" value="<? echo getByTagName($registro,'nrcpfcgc') ?>" />
			
	<label for="cdagenca"><? echo utf8ToHtml('PA:') ?></label>
	<input id="cdagenca" name="cdagenca" type="text" onChange="buscaPac($(this).val()); return false;" value="<? echo getByTagName($registro,'cdagenci') ?>" />	
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<input id="nmresage" name="nmresage" type="text" value="<? echo getByTagName($registro,'nmresage') ?>" />
	
	<br style="clear:both" />
	
	<label for="cdempres"><? echo utf8ToHtml('Empresa:') ?></label>
	<input id="cdempres" name="cdempres" type="text" onChange="buscaEmp($(this).val()); return false;" value="<? echo getByTagName($registro,'cdempres') ?>" />	
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<input id="nmresemp" name="nmresemp" type="text" value="<? echo getByTagName($registro,'nmresemp') ?>" />
	
	<br style="clear:both" />			
	
	<label for="cdbantrf"><? echo utf8ToHtml('Transferindo para => Banco:') ?></label>
	<input id="cdbantrf" name="cdbantrf" type="text" onChange="buscaBanco($(this).val()); return false;" value="<? echo getByTagName($registro,'cdbantrf') ?>" />	
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<input id="dsbantrf" name="dsbantrf" type="text" value="<? echo getByTagName($registro,'dsbantrf') ?>" />
	
	<label for="tpctatrf"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
	<select id="tpctatrf" name="tpctatrf">
		<option value="1" <?php if (getByTagName($registro,'tpctatrf') == "1"){ echo " selected"; } ?>> CONTA CORRENTE </option>
		<option value="2" <?php if (getByTagName($registro,'tpctatrf') == "2"){ echo " selected"; } ?>> <? echo utf8ToHtml('POUPANCA') ?> </option>
		<option value="3" <?php if (getByTagName($registro,'tpctatrf') == "3"){ echo " selected"; } ?>> <? echo utf8ToHtml('CONTA DE PAGAMENTO') ?> </option>
	</select>
	
	<label for="cdagetrf"><? echo utf8ToHtml('Agencia:') ?></label>
	<input id="cdagetrf" name="cdagetrf" type="text" onChange="buscaAgencia($(this).val()); return false;" value="<? echo getByTagName($registro,'cdagetrf') ?>" />	
	<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	
	<input id="dsagetrf" name="dsagetrf" type="text" value="<? echo getByTagName($registro,'dsagetrf') ?>" />
	
	<br style="clear:both" />
	
	<label for="nrctatrf"><? echo utf8ToHtml('Conta:') ?></label>
	<input id="nrctatrf" name="nrctatrf" type="text" value="<? echo getByTagName($registro,'nrctatrf') ?>" />	
	<input id="nrdigtrf" name="nrdigtrf" type="text" value="<? echo getByTagName($registro,'nrdigtrf') ?>" />
	
	<fieldset>
		<legend><? echo utf8ToHtml('Situação') ?></legend>
		
		<label for="dtadmiss"><? echo utf8ToHtml('Data Abertura:') ?></label>
		<input id="dtadmiss" name="dtadmiss" type="text" value="<? echo getByTagName($registro,'dtadmiss') ?>" />	
		
		<label for="dtcantrf"><? echo utf8ToHtml('Data Cancelamento:') ?></label>
		<input id="dtcantrf" name="dtcantrf" type="text" value="<? echo getByTagName($registro,'dtcantrf') ?>" />	
	
		<label for="cdsitcta"><? echo utf8ToHtml('Situação:') ?></label>
		<input id="cdsitcta" name="cdsitcta" type="text" value="<? echo getByTagName($registro,'cdsitcta') ?>" />	
	
	</fieldset>	
	
</form>
