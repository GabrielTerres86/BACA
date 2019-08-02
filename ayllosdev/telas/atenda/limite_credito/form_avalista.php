<?php
/*!
 * FONTE        : form_avalista.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 04/12/2018
 * OBJETIVO     : Formulário da rotina LIMITE DE CREDITO da aba NOVO LIMITE do AVALISTA da tela de ATENDA
 *
 * ALTERACOES   : 
 *
 */	
	
?>	
<fieldset>
	<legend></legend>

    <input name="crm_inacesso" id="crm_inacesso" type="hidden" value="<? echo $glbvars["CRM_INACESSO"] ?>" />
    
	<input name="qtpromis" id="qtpromis" type="hidden" value="" />
	
	<label for="nrctaava">Conta:</label>
	<input name="nrctaava" id="nrctaava" type="text" value="" />
	<a style='padding: 3px 0 0 3px;'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>		
	<br />
		
	<label for="inpessoa">Tipo Natureza:</label>
	<select name="inpessoa" id="inpessoa" alt="Entre com 1-Fisica 2-Juridica.">
		<option value=""  > - </option> 
		<option value="1" >1 - Fisica</option>
		<option value="2" >2 - Juridica</option>
	</select>	
	<br />

	<label for="nrcpfcgc">CPF.:</label>
	<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="" />
	<br />
            
	<label for="nmdavali">Nome:</label>
	<input name="nmdavali" id="nmdavali" type="text" value="" />
	<br />


	<label for="dtnascto">Data Nasc.:</label>
	<input name="dtnascto" id="dtnascto" type="text" value="" />
	<br />
			
    <!-- Rafael Ferreira (Mouts) - Story 13447-->
	<div id="divNacionalidade">
		<label for="cdnacion">Nacionalidade:</label>
		<div id="divCdnacion">
			<input name="cdnacion" id="cdnacion" type="text" />
			<a style='padding: 3px 0 0 3px;'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		</div>
		<input name="dsnacion" id="dsnacion" type="text" value="" />
	</div>
	<select name="tpdocava" id="tpdocava">
		<option value=""  > - </option> 
		<option value="CH">CH</option>
		<option value="CI">CI</option>
		<option value="CP">CP</option>
		<option value="CT">CT</option>
	</select>
	<input name="nrdocava" id="nrdocava" type="hidden" value="" />
	<br />	

</fieldset>

<fieldset id="fsetConjugeAval">
	<legend><? echo utf8ToHtml('Informações do Cônjuge') ?></legend>

	<label for="nrctacjg">Conta:</label>
	<input name="nrctacjg" id="nrctacjg" type="text" value="" />

	<label for="nrcpfcjg">CPF:</label>
	<input name="nrcpfcjg" id="nrcpfcjg" type="text" value="" />
	<br />
					
	<label for="nmconjug"><?php echo utf8ToHtml('Cônjuge:') ?></label>
	<input name="nmconjug" id="nmconjug" type="text" value="" />

	<label for="vlrencjg">Rendimento:</label>
	<input name="vlrencjg" id="vlrencjg" type="text" value="" />
	<br />
		
	<label for="tpdoccjg">Doc.:</label>
	<select name="tpdoccjg" id="tpdoccjg">
		<option value=""  > - </option> 
		<option value="CH">CH</option>
		<option value="CI">CI</option>
		<option value="CP">CP</option>
		<option value="CT">CT</option>
	</select>
	<input name="nrdoccjg" id="nrdoccjg" type="text" value="" />
	<br />
	
</fieldset>

<fieldset>
	<legend><?php echo utf8ToHtml('Endereço') ?></legend>
	
	<label for="nrcepend">CEP:</label>
	<input name="nrcepend" id="nrcepend" type="text" value="" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	
	<label for="dsendre1"><? echo utf8ToHtml('End.:') ?></label>
	<input name="dsendre1" id="dsendre1" type="text" value="" />
	<br />
	
	<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
	<input name="nrendere" id="nrendere" type="text" value="" />
	
	<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
	<input name="complend" id="complend" type="text" value="" />
	<br />
	
	<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
	<input name="nrcxapst" id="nrcxapst" type="text" value="" />		
	
	<label for="dsendre2">Bairro:</label>
	<input name="dsendre2" id="dsendre2" type="text" value="" />
	<br />	
	
	<label for="cdufresd">UF:</label>
	<? echo selectEstado('cdufresd','', 1) ?>
			
	<label for="nmcidade">Cidade:</label>
	<input name="nmcidade" id="nmcidade" type="text" value="" />
	<br />
	
</fieldset>
	
<fieldset>
	<legend><?php echo utf8ToHtml('Contato') ?></legend>
	
	<label for="nrfonres">Telefone:</label>
	<input name="nrfonres" id="nrfonres" type="text" onKeyUp="maskTelefone(this)" value="" />

	<label for="dsdemail">E-mail:</label>
	<input name="dsdemail" id="dsdemail" type="text" value="" />

	<br />
		
</fieldset>
	
<fieldset>
	<legend><?php echo utf8ToHtml('Rendimentos') ?></legend>
	<label for="vledvmto">Endividamento:</label>
	<input name="vledvmto" id="vledvmto" type="text" value="" />
			
	<label for="vlrenmes">Rendimento Mensal:</label>
	<input name="vlrenmes" id="vlrenmes" type="text" value="" />
	<br />
		
</fieldset>

<div id="divBotoes">
	<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="<? echo $voltaAvalista; ?>">
	<input type="image" id="btLimpar" src="<? echo $UrlImagens; ?>botoes/limpar.gif" onClick="limpaFormAvalistas(true);">
	<input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuarAvalista();">
</div>

<script type="text/javascript">
	formataAvalista();
</script>