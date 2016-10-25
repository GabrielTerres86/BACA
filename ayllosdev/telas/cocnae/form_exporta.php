<?
/*!
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : Setembro/2016
 * OBJETIVO     : Formulario de exportacao de arquivo para tela COCNAE
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
?>
<center>
<div id="divExporta" name="divExporta" style="width: 705px;">
	<form id="frmExporta" name="frmExporta" class="formulario" enctype="multipart/form-data" style="display:none" target="blank" method="POST" width="100%">
		<fieldset>
			<legend>Exportar Arquivo de CNAEs Restritos ou Bloqueados</legend>
			<table width="100%" >
				<tr>		
					<td>
						<div id="divdownloadfile" style="height: 30px; width:100%">							
 							<center> <div id="spMensagem" name="spMensagem" style="margin:auto;"> <b> <? echo utf8ToHtml('Clique em exportar para realizar download do arquivo de CNAEs bloqueados.'); ?> </b> </div> </center>
						</div>	
					</td>
				</tr>
			</table>
		</fieldset>
		<br />
	</form>
</div>
</center>