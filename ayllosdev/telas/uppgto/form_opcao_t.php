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
<div id="divArquivos" name="divArquivos" style="width: 620px;">
	<form id="frmArquivo" name="frmArquivo" class="formulario" enctype="multipart/form-data"  target="blank" method="POST">
		<fieldset>
			<legend>Enviar Remessa de Agendamento de Pagamento</legend>
			<table width="100%" >
				<tr>
					<td>
						<label for="nrdconta">Conta:</label>
						<input type="text" id="nrdconta" name="nrdconta" alt="Informe a Conta/DV ou F7 para pesquisar e clique em OK ou ENTER para prosseguir."/>
						<a style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
						<a href="#" class="botao" id="btnOK1" >OK</a>						
						<input name="nmprimtl" id="nmprimtl" type="text" />	
						<input name="nrcpfcgc" id="nrcpfcgc" type="hidden" />	
						<input name="inpessoa" id="inpessoa" type="hidden" />	
						<input name="cdagectl" id="cdagectl" type="hidden" />	
						<input name="flghomol" id="flghomol" type="hidden" />	
						
					</td>					
				</tr>

				<tr>		
					<td>
						<div id="divuploadfile" style="height: 30px;" center>
							<input type="hidden" name="MAX_FILE_SIZE" value="8388608" />							
 							<input name="userfile" id="userfile" size="88" type="file" class="campo" style="height: 25px;" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
						</div>	
					</td>
				</tr>
				
				<tr>		
					<td>
						<div id="divtbcriticas" class="divRegistros" center>
						</div>	
					</td>
				</tr>
				
			</table>
		</fieldset>
		<br />
	</form>
</div>
</center>