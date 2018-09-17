<? 
/*!
 * FONTE        : form_opcao_l.php
 * CRIAÇÃO      : Lucas Reinert
 * DATA CRIAÇÃO : 14/09/2016
 * OBJETIVO     : Formulario que apresenta a opcao L da tela CUSTOD
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
	<div id="divAssociadoChq" style="display: none">
		<fieldset>
			<legend> Associado </legend>	
			
			<label for="nrctarem">Conta:</label>
			<input type="text" id="nrctarem" name="nrctarem" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			
			<input type="text" id="nmttlrem" name="nmttlrem" />

			<label for="nrremret">Remessa:</label>
			<input type="text" id="nrremret" name="nrremret" />
			
			</br>
			
			<label for="nmarquiv" >Arquivo:</label>
			<input type="text" id="nmarquiv" name="nmarquiv" />
			
			<label for="insithc2" >Situa&ccedil;&atilde;o:</label>
			<select id="insithc2" name="insithc2" >
				<option value="Pendente" >Pendente</option>
				<option value="Processado" >Processado</option>
			</select>
			
			<label for="dsorigem" >Origem:</label>
			<input type="text" id="dsorigem" name="dsorigem" />
			
			<br/>
		</fieldset>		
	</div>
	<div id="divCheque" style="display: none">
		<fieldset>
			<legend> Cheque </legend>	

			<label for="dsdocmc7">CMC-7:</label>
			<input type="text" id="dsdocmc7" name="dsdocmc7" />

			<a href="#" class="botao" id="btnConchq" onclick="conciliaChequeGrid(); return false;">Ok</a>
			<label id="dsmsgcmc7" />

			<br  />

		</fieldset>	
	</div>
	<div id="divFiltros">		
	
		<fieldset>
			<legend> Filtros </legend>	

			<label for="dtinicst">Data Remessa:</label>
			<input type="text" id="dtinicst" name="dtinicst" />

			<label for="dtfimcst">At&eacute;:</label>
			<input type="text" id="dtfimcst" name="dtfimcst" />
			
      <label for="cdagenci">PA:</label>
      <input type="text" id="cdagenci" name="cdagenci" />

			<label for="insithcc">Situa&ccedil;&atilde;o:</label>
			<select id="insithcc" name="insithcc">
				<option value="0" >Todos</option>
				<option value="1" >Pendente</option>
				<option value="2" >Processado</option>
			</select>
						
			<a href="#" class="botao" id="btBscrem" onclick="btnContinuar(); return false;">Ok</a>

			<br  />

		</fieldset>	
	</div>
	<div id="divRemessa" style="display: none"/>
	<div id="divChqRemessa" style="display: none"/>
	
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir" onclick="btnContinuar(); return false;" >Prosseguir</a>
	<a href="#" class="botao" id="btConciliar" onclick="buscaChequesRemessa(); return false;" style="display:none" >Conciliar</a>
	<a href="#" class="botao" id="btConciliarT" onclick="confirmaConciliarTodos(); return false;" style="display:none" >Conciliar Todos</a>
	<a href="#" class="botao" id="btCustodiar" onclick="verificaChqConc(); return false;" style="display:none" >Custodiar</a>
	<a href="#" class="botao" id="btImprimir" onclick="validaImprimirCustodL(); return false;" style="display:none" >Imprimir</a>
	<a href="#" class="botao" id="btnExcluir" onclick="confirmaExclusao(); return false;" style="display:none" >Excluir</a>
</div>
