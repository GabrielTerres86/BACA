<? 
 /*!
 * FONTE        : form_dados_aval.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 * 
 * ALTERACOES   : 000: [05/09/2012] Mudar para layout padrao (Gabriel) 
 *                001: [15/07/2014] Incluso novos campos inpessoa e dtnascto (Daniel).
 *                002: [09/09/2014] Projeto Automatização de Consultas em Propostas de Crédito(Jonata-RKAM).
 *                003: [01/03/2016] PRJ Esteira de Credito. (Jaison/Oscar)
 *                004: [12/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 *                005: [24/10/2017] Ajustes ao carregar dados do avalista e controle de alteração. PRJ339 CRM (Odirlei-AMcom)                      
 *                006: [18/10/2018] Alterado layout da tela Avalista. PRJ438 (Mateus Z / Mouts)
 *                007: [24/06/2019] Criado divNacionalidade para ocultar campo na tela. Story 13447 (Rafael Ferreira / Mouts)
 */	
 ?>

	<fieldset class="fsAvalista">
		<legend>Dados dos Avalistas/Fiadores 1</legend>

	    <input name="crm_inacesso" id="crm_inacesso" type="hidden" value="<? echo $glbvars["CRM_INACESSO"] ?>" />

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
		<label for="nrcpfcgc">CPF:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="" />
		<br />
                
		<label for="nmdavali">Nome:</label>
		<input name="nmdavali" id="nmdavali" type="text" value="" />
		<br />			
		
		<label for="dtnascto">Data Nasc.:</label>
		<input name="dtnascto" id="dtnascto" type="text" value="" />
		<br />

		<div id="divNacionalidade"> 		
			<label for="cdnacion">Nacionalidade:</label>
			<div id="divCdnacion">
				<input name="cdnacion" id="cdnacion" type="text" />
				<a style='padding: 3px 0 0 3px;'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a> 
			</div>
			<input name="dsnacion" id="dsnacion" type="text" value="" />
		</div>
				
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
			
	</fieldset>
	
	<fieldset>
		<legend><?php echo utf8ToHtml('Endereço') ?></legend>

		<label for="nrcepend">CEP:</label>
		<input name="nrcepend" id="nrcepend" type="text" value="" />
		<a style='padding: 3px 0 0 3px;'><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
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
				
		<label for="vlrenmes">Rendimento Mensal:</label>
		<input name="vlrenmes" id="vlrenmes" type="text" value="" />
		<br />

	</fieldset>

</div>

<script>
	
	$(document).ready(function() {
		operacao = '<? echo $cddopcao ?>';
		formataAvalista();
		highlightObjFocus($('#frmDadosAval'));
		if (operacao == "C") {
			$('#nrctaava','#divDscTit_Avalistas').prop( "disabled", true );
			$('#nrctaava','#divDscTit_Avalistas').addClass( "campoTelaSemBorda" );
		}
	});
	
</script>	