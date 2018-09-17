<?php
/*!
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Formulario de upload de arquivo para tela UPPGTO
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<center>
<div id="divRelatorio" name="divRelatorio" style="width: 800px;">
	<form id="frmRelatorio" name="frmRelatorio" class="formulario" onSubmit="return false;" target="blank" method="POST">
		<fieldset>
			<legend>Relat&oacute;rio de Agendamento de Pagamento de T&iacute;tulos</legend>
			<table width="100%" >
				<tr>
					<td>
						<label for="nrdconta">Conta:</label>
						<input type="text" id="nrdconta" name="nrdconta" alt="Informe a Conta/DV ou F7 para pesquisar e clique em OK ou ENTER para prosseguir."/>
						<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
						<a href="#" class="botao" id="btnOK1" >OK</a>
						<!--<label for="nmprimtl">Titular:</label> -->
						<input name="nmprimtl" id="nmprimtl" type="text" />						
					</td>					
				</tr>

				<tr>		
					<td>
						<label for="nmarquiv">Nome do Arquivo:</label>
						<input type="text" id="nmarquiv" name="nmarquiv" alt="Nome do arquivo"/>
					</td>
				</tr>
				
				<tr>		
					<td>

						<label for="nrremess">N&uacute;mero da Remessa:</label> 
						<input name="nrremess" id="nrremess" type="text" />											
					</td>
				</tr>
				
				<tr>
					<td>
						<label for="dtrefere"><? echo utf8ToHtml('Data de Refer&ecirc;ncia:') ?></label>
						<select id="dtrefere" name="dtrefere" >
							<option value="1" <?php echo $dtrefere == '1' ? 'selected' : '' ?>><? echo utf8ToHtml('Data da Remessa.') ?></option>
							<option value="2" <?php echo $dtrefere == '2' ? 'selected' : '' ?>><? echo utf8ToHtml('Data Vencimento.') ?></option>
							<option value="3" <?php echo $dtrefere == '3' ? 'selected' : '' ?>><? echo utf8ToHtml('Data Agendada para Pagamento.') ?></option>
						</select>					
					</td>
				</tr>
				
				<tr>
					<td>
						<label for="dtiniper"><? echo utf8ToHtml('Per&iacute;odo:') ?></label>
						<input type="text" id="dtiniper" name="dtiniper" class="data" />
						<label for="dtfimper"><? echo utf8ToHtml('&agrave;') ?></label>
						<input type="text" id="dtfimper" name="dtfimper" class="data" />
					</td>
				</tr>
				
				<tr>
					<td>
						<label for="nmbenefi"><? echo utf8ToHtml('Nome do Benefici&aacute;rio:') ?></label>
						<input type="text" id="nmbenefi" name="nmbenefi" />						
					</td>
				</tr>
				
				<tr>
					<td>
						<label for="cdbarras"><? echo utf8ToHtml('C&oacute;digo Barras:') ?></label>
						<input type="text" id="cdbarras" name="cdbarras" />						
					</td>
				</tr>
				
				<tr>
					<td>
						<label for="cdsittit"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
						<select id="cdsittit" name="cdsittit" >
							<option value="1" <?php echo $cdsittit == '1' ? 'selected' : '' ?>><? echo utf8ToHtml('Todos.') ?></option>
							<option value="2" <?php echo $cdsittit == '2' ? 'selected' : '' ?>><? echo utf8ToHtml('Liquidado.') ?></option>
							<option value="3" <?php echo $cdsittit == '3' ? 'selected' : '' ?>><? echo utf8ToHtml('Pendente de Liquida&ccedil;&atilde;o.') ?></option>
							<option value="4" <?php echo $cdsittit == '4' ? 'selected' : '' ?>><? echo utf8ToHtml('Com erro.') ?></option>
						</select>					
					</td>
				</tr>				
				
				<tr>
					<td>
						<label for="tprelato"><? echo utf8ToHtml('Extens&atilde;o do relat&oacute;rio:') ?></label>
						<select id="tprelato" name="tprelato" >
							<option value="1" <?php echo $tprelato == '1' ? 'selected' : '' ?>><? echo utf8ToHtml('PDF') ?></option>
							<option value="2" <?php echo $tprelato == '2' ? 'selected' : '' ?>><? echo utf8ToHtml('CSV') ?></option>
						</select>					
					</td>
				</tr>				
				
			</table>
		</fieldset>
		<br />
	</form>
</div>
</center>

<form name="frmImprimir" id="frmImprimir">
	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">

	<input name="nrdconta" id="nrdconta" type="hidden" value="" />
	<input name="nmarquiv" id="nmarquiv" type="hidden" value="" />
	<input name="nrremess" id="nrremess" type="hidden" value="" />
	<input name="dtrefere" id="dtrefere" type="hidden" value="" />
	<input name="dtiniper" id="dtiniper" type="hidden" value="" />
	<input name="dtfimper" id="dtfimper" type="hidden" value="" />
	<input name="nmbenefi" id="nmbenefi" type="hidden" value="" />
	<input name="cdbarras" id="cdbarras" type="hidden" value="" />
    <input name="cdsittit" id="cdsittit" type="hidden" value="" />
	<input name="tprelato" id="tprelato" type="hidden" value="" />
</form>

