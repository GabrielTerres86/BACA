<?
/*!
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : Setembro/2016
 * OBJETIVO     : Formulario de upload de arquivo para tela COCNPJ
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<center>
<div id="divArquivos" name="divArquivos" style="width: 705px;">
	<form id="frmArquivo" name="frmArquivo" class="formulario" enctype="multipart/form-data" style="display:none" target="blank" method="POST">
		<fieldset>
			<legend>Enviar Arquivo de CNPJs Bloqueados</legend>
			<table width="100%" >
				<tr>		
					<td>
						<div id="divuploadfile" style="height: 30px;" center>
							<input type="hidden" name="MAX_FILE_SIZE" value="8388608" />
 							<input name="userfile" id="userfile" size="106" type="file" class="campo" style="height: 25px;" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
						</div>	
					</td>
				</tr>
			</table>
		</fieldset>
		<br />
	</form>
</div>
</center>