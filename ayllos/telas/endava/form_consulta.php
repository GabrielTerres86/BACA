<?php
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 30/10/2013
 * OBJETIVO     : Formulario de Listagem dos endereços da Tela ENDAVA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmConsulta" name="frmConsulta" class="formulario">
		<div id="divConsulta" >
		
		<label for="pro_cpfcgc"><? echo utf8ToHtml('CPF:') ?></label>
		<input id="pro_cpfcgc" name="pro_cpfcgc" type="text"/>
		<a style="padding: 3px 0 0 3px;" href="#" onClick="GerenciaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>	
	
		<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
		<input id="nrctremp" name="nrctremp" type="text"/>
								
		<label for="nrdconta"><? echo utf8ToHtml('Conta/DV:') ?></label>
		<input id="nrdconta" name="nrdconta" type="text"/>
				
		<label for="tpctrato"><? echo utf8ToHtml('Tipo:') ?></label>
		<select id="tpctrato" name="tpctrato">
			<option selected></option>
			<option value="1" ><? echo utf8ToHtml('EP - Emprestimo')?> </option>
			<option value="2" ><? echo utf8ToHtml('DC - Desconto Cheque')?> </option>
			<option value="3" ><? echo utf8ToHtml('LM - Limite')?> </option>
			<option value="4" ><? echo utf8ToHtml('CR - Cartão')?> </option>
		</select>
		
		<br style="clear:both" />
		<br style="clear:both" />
						
		<label for="nmdaval"><? echo utf8ToHtml('Nome:') ?></label>
		<input id="nmdaval" name="nmdaval" type="text"/>
		
		<label for="tpdocav"><? echo utf8ToHtml('Documento:') ?></label>
		<input id="tpdocav" name="tpdocav" type="text"/>
		<input id="dscpfav" name="dscpfav" type="text"/>
		
		<label for="nmcjgav"><? echo utf8ToHtml('Conjuge:') ?></label>
		<input id="nmcjgav" name="nmcjgav" type="text"/>
		
		<label for="cpfccg"><? echo utf8ToHtml('CPF:') ?></label>
		<input id="cpfccg" name="cpfccg" type="text"/>
		
		<label for="tpdoccj"><? echo utf8ToHtml('Documento:') ?></label>
		<input id="tpdoccj" name="tpdoccj" type="text"/>
		<input id="dscfcav" name="dscfcav" type="text"/>
		
		<br style="clear:both" />
		<br style="clear:both" />
		
		<label for="nrfonres"><? echo utf8ToHtml('Telefone:') ?></label>
		<input id="nrfonres" name="nrfonres" type="text"/>
		
		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input id="nrcepend" name="nrcepend" type="text"/>
		<a id="ImgLupa" style="padding: 3px 0 0 3px;" href="#" onClick="GerenciaPesquisa(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
		
		<label for="dsendav1"><? echo utf8ToHtml('Endereço:') ?></label>
		<input id="dsendav1" name="dsendav1" type="text"/>
		
		<label for="nrendere"><? echo utf8ToHtml('Nro:') ?></label>
		<input id="nrendere" name="nrendere" type="text"/>
		
		<label for="complend"><? echo utf8ToHtml('Complemento:') ?></label>
		<input id="complend" name="complend" type="text"/>
		
		<label for="nrcxapst"><? echo utf8ToHtml('Caixa Postal:') ?></label>
		<input id="nrcxapst" name="nrcxapst" type="text"/>
		
		<label for="dsendav2"><? echo utf8ToHtml('Bairro:') ?></label>
		<input id="dsendav2" name="dsendav2" type="text"/>
		
		<label for="dsdemail"><? echo utf8ToHtml('E-mail:') ?></label>
		<input id="dsdemail" name="dsdemail" type="text"/>
		
		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input id="nmcidade" name="nmcidade" type="text"/>
		
		<label for="cdufresd"><? echo utf8ToHtml('UF:') ?></label>
		<input id="cdufresd" name="cdufresd" type="text"/>
		
					
		<br style="clear:both" />
		
		</div>
</form>


