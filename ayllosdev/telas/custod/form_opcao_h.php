<? 
/*!
 * FONTE        : form_opcao_h.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 09/09/2016
 * OBJETIVO     : Formulario que apresenta a opcao H da tela CUSTOD
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');
	
	$nrdconta = (isset($nrdconta)) ? formataContaDV($nrdconta) : 0;
	$nmprimtl = (isset($nmprimtl)) ? $nmprimtl : '';
	$dsdocmc7 = (isset($dsdocmc7)) ? $dsdocmc7 : '';
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<div id="divAssociado">
	<fieldset>
		<legend> Associado </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdconta ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
		
		<br/>
	</fieldset>		
	</div>
	<div id="divCheques">
		<fieldset>
			<legend> Cheque </legend>	

			<label for="dsdocmc7">CMC-7:</label>
			<input type="text" id="dsdocmc7" name="dsdocmc7" value="<?php echo $dsdocmc7 ?>" />

			<a href="#" class="botao" id="btnAdd" onclick="adicionaChequeGrid(); return false;">Ok</a>

			<br  />

		</fieldset>	
		<div class="divRegistros">	
			<table class="tituloRegistros" id="tbCheques">
				<thead>
					<tr>
						<th>Comp</th>
						<th>Banco</th>
						<th>Ag&ecirc;ncia</th>
						<th>Conta</th>
						<th>Cheque</th>
						<th>Data Boa</th>
						<th>Valor</th>
						<th>CMC-7</th>
						<th><? echo '&nbsp;' ?></th>
						<th>Cr&iacute;tica</th>
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div>		
	</div>
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onclick="btnContinuar(); return false;" >Prosseguir</a>
	<a href="#" class="botao" id="btResgatar" onclick="validarResgate(); return false;" style="display:none" >Resgatar</a>
</div>