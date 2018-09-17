<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Outubro/2014
 * OBJETIVO     : Cabeçalho para a tela REAFOR
 * --------------
 * ALTERAÇÕES   : 06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	        		       10 Digitos - Campos usados apenas para visualização
 *			      			   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				  			   (Kelvin - SD 233714)
 * --------------
 */
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
 
?>
<script>
	// Criando variavel DTMVTOLT para exibir a data cadastrada no sistema
	aux_dtmvtolt = "<? echo $glbvars['dtmvtolt'] ; ?>"; 
</script>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">

	<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
	<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (C ou I).">
		<option value="C"> <? echo utf8ToHtml('C - Consulta reabilita&ccedil;&atilde;o') ?> </option>
		<option value="I"> <? echo utf8ToHtml('I - Incluir reabilita&ccedil;&atilde;o')  ?> </option>
	</select>
	<a href="#" class="botao" id="btnOK" >OK</a>
	<br />

	<div id="divConsulta" style="display:none">
		<label for="dtmvtolt">Data:</label>
		<input name="dtmvtolt" id="dtmvtolt" type="text" value="<? echo $glbvars['dtmvtolt'] ; ?>" autocomplete="off" />
		<a href="#" class="botao" id="btnOK2" >OK</a>
	</div>

	<div id="divIncluir" style="display:none">
		<label for="nrcpfcgc">CPF/CNPJ:</label>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="" />
		<a href="#" class="botao" id="btnOK3" >OK</a>

		<label for="nmprimtl">Associado:</label>
		<input name="nmprimtl" id="nmprimtl" type="text" value="" />

		<label for="nrdconta"><? echo utf8ToHtml('Conta/DV:') ?></label>
		<select id="nrdconta" name="nrdconta" onChange="consultaContratoAssocido();return false;">
		</select>

		<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
		<select id="nrctremp" name="nrctremp" value="<? echo mascara($nrctremp,'#.###.###.###') ?>"> 
		</select>
	</div>

    <br style="clear:both" />
</form>