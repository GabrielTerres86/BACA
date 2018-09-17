<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Agosto/2013
 * OBJETIVO     : Cabeçalho para a tela CADCYB
 * --------------
 * ALTERAÇÕES   : 06/01/2015 - Padronizando a mascara do campo nrctremp.
 *	   	                       10 Digitos - Campos usados apenas para visualização
 *			                   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *				               (Kelvin - SD 233714)
 *
 *                31/08/2015 - Adicionado os campos de Assessoria e Motivo CIN (Douglas - Melhoria 12) 
 *				  21/06/2018 - Inserção de bordero e titulo [Vitor Shimada Assanuma (GFT)]
 * --------------
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	
	<!-- <form id="frmCab" name="frmCab" class="formulario cabecalho"> -->
	
	<label for="cddopcao"><? echo utf8ToHtml("Op&ccedil;&atilde;o:") ?></label>
	<select id="cddopcao" name="cddopcao" alt="Informe a opcao desejada (I, A, E ou C).">
		<option value="I"> <? echo utf8ToHtml("I - Incluir contas para o CYBER.") ?> </option>
		<option value="A"> <? echo utf8ToHtml("A - Alterar contas para o CYBER.") ?> </option>
		<option value="E"> <? echo utf8ToHtml("E - Excluir contas para o CYBER.") ?> </option>
		<option value="C"> <? echo utf8ToHtml("C - Consultar contas CYBER.") ?> </option>
		<option value="F"> <? echo utf8ToHtml("F - Importar arquivo CSV de contas para o CYBER.") ?> </option>
	</select>
	<a href="#" class="botao" id="btnOK" >OK</a>
	<br />	
	
	<div id="divOpcoes" style="display:none">
		<label for="cdorigem">Origem:</label>
		<select id="cdorigem" name="cdorigem" >
			<option value="1"> <? echo utf8ToHtml("1 - Conta") ?> </option>
			<option value="3"> <? echo utf8ToHtml("3 - Empr&eacute;stimos") ?> </option>
			<option value="4"> <? echo utf8ToHtml("4 - Desconto de T&iacute;tulos") ?> </option>
		</select>

		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta ?>" />
		
		<label for="nrctremp">Contrato:</label>
		<input type="text" id="nrctremp" name="nrctremp" value="<? echo $nrctremp ?>" />
		
		<br style="clear:both" />
		
		
		<label for="nrborder">Borderô:</label>
		<input type="text" id="nrborder" name="nrborder" value="" />

		<label for="nrtitulo">T&iacute;tulo:</label>
		<input readonly type="text" id="nrdocmto" name="nrdocmto" />
		<input type="hidden" id="nrtitulo" name="nrtitulo" />

		

		<a id="pesqtitulo" name="pesqtitulo" href="#" onClick="mostrarPesquisaBorderoPorTitulo();" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		

		<br style="clear:both" />
		
		<label for="flgjudic">Judicial:</label>
		<input id="flgjudic" name="flgjudic" type="checkbox"  />

		<label for="flextjud">Extra Judicial:</label>
		<input id="flextjud" name="flextjud" type="checkbox"  />

		<label for="flgehvip">CIN:</label>
		<input id="flgehvip" name="flgehvip" type="checkbox"  />

		<br style="clear:both" />

		<label for="cdmotivocin">Motivo CIN:</label>
		<input id="cdmotivocin" name="cdmotivocin" type="text" class="campo alphanum"/>
		<a id="pesqmotcin" name="pesqmotcin" href="#" onClick="mostrarPesquisaMotivoCin();" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<input name="dsmotivocin" type="text"  id="dsmotivocin" class="campo"/>

		<br style="clear:both" />
		
		<label for="cdassessoria">Assessoria:</label>
		<input id="cdassessoria" name="cdassessoria" type="text" class="campo alphanum"/>
		<a id="pesqassess" name="pesqassess" href="#" onClick="mostrarPesquisaAssessoria();" ><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0"></a>
		<input name="nmassessoria" type="text"  id="nmassessoria" class="campo"/>

		<br style="clear:both" />
		
		<label for="dtenvcbr">Data Envio Contrato Assessoria Cobrança:</label>
		<input type="text" id="dtenvcbr" name="dtenvcbr" value="" />
	</div>
	
	<div id="divOpcoes2" style="display:none">
		<label for="nmdarqui">Arquivo:</label>
		<input type="text" id="nmdarqui" name="nmdarqui" value='<? echo "/micros/".$glbvars["dsdircop"]."/cadcyb/".$glbvars["dsdircop"].".csv" ?>' />
		
		<br style="clear:both" />		
		<br style="clear:both" />		
		
		<fieldset>
		<div id="exemplo" style="height:120px">
		<label style="text-align:left">
			&nbsp;&nbsp;Formato do arquivo CSV exemplo:</br>
			&nbsp;&nbsp;Nº Coop;Cooperativa;Origem;Nº Conta;Nº Contrato;Judicial;Extra Judicial;CIN;Data Assessoria Cobrança;Nº Assessoria;Nº Motivo CIN;Nº Bordero;Nº Titulo</br>
			&nbsp;&nbsp;<? echo $glbvars["cdcooper"] ?>;<? echo $glbvars["dsdircop"] ?>;3;952168;158582;N;S;S;31/03/2015;7;3;2084;1
		</label>
		</div>
		</fieldset>
	</div>
			
    <br style="clear:both" />				
</form>
<script type="text/javascript">
	var nrctremp = $('#nrctremp','#frmCab');
	nrctremp.addClass('contrato3')
	layoutPadrao();
</script>