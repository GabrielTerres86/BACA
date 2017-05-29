<? 
/*!
 * FONTE        : form_opcao_x.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 09/09/2016
 * OBJETIVO     : Formulario que apresenta a opcao X da tela CUSTOD
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

?>

<form id="frmOpcao" name="frmOpcao" class="formulario"  >

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
	<div id="divCustch">
		<fieldset>
			<legend> Cheque </legend>			
			<label for="dtchqbom">Data Boa:</label>
			<input type="text" id="dtchqbom" name="dtchqbom"/>
		
			<label for="dtemissa">Data de Emiss&atilde;o:</label>
			<input type="text" id="dtemissa" name="dtemissa"/>
		
			<label for="vlcheque">Valor:</label>
			<input type="text" id="vlcheque" name="vlcheque"/>
		
			<label for="dsdocmc7">CMC-7:</label>
			<input type="text" id="dsdocmc7" name="dsdocmc7"/>
		
			<a href="#" class="botao" id="btnAdd">OK</a>
			<br style="clear:both;" />	
		</fieldset>
		<div id="tabCustch">
			<div class="divRegistros">
				<table class="tituloRegistros" id="tbCheques">
					<thead>
						<tr>
							<th>Data Boa</th>
							<th>Data Emiss&atilde;o</th>
							<th>Valor</th>
							<th>Banco</th>
							<th>Ag&ecirc;ncia</th>
							<th>N&uacute;mero do Cheque</th>
							<th>N&uacute;mero da Conta</th>
							<th>CMC-7</th>
							<th></th>
							<th>Cr&iacute;tica</th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
			</div> 
		</div>	
		<div id="divPesquisaRodape" class="divPesquisaRodape">
			<table>	
				<tr>
					<td id="qtdChequeCustodiar">
						<span style="font-size: 12px">
						Exibindo 0 cheques para custodiar. Valor Total R$ 0,00
						</span>
					</td>
				</tr>
			</table>
		</div>
	</div>		
	<div id="divEmiten" style="display: none">
		<div class="divRegistros">
			<table class="tituloRegistros" id="tabEmiten">
				<thead>
					<tr>
						<th>Banco</th>
						<th>Ag&ecirc;ncia</th>
						<th>N&uacute;mero da Conta</th>
						<th>CPF/CNPJ</th>
						<th>Emitente</th>						
						<th>Cr&iacute;tica</th>						
					</tr>
				</thead>
				<tbody>
				</tbody>
			</table>
		</div> 
	</div>
</form>
<script type="text/javascript">
	aux_dtmvtolt = "<?php echo $glbvars["dtmvtolt"]; ?>";
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>

<div id="divBotoes" style='padding-bottom:10px'>
	<a href="#" class="botao" id="btVoltar" 	onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onclick="btnContinuar(); return false;" >Prosseguir</a>
	<a href="#" class="botao" id="btNovo"       onClick="novoCheque(); return false;" style="display: none">Novo Cheque</a>
	<a href="#" class="botao" id="btValidar" 	onClick="validaCustodiaCheque(); return false;" style="display: none">Validar Cust&oacute;dia</a>
	<a href="#" class="botao" id="btFinalizar" 	onClick="finalizaCustodiaCheque(); return false;" style="display: none">Finalizar</a>
</div>	

