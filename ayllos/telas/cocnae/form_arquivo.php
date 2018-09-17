<?
/*!
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : Setembro/2016
 * OBJETIVO     : Formulario de upload de arquivo para tela COCNAE
 * --------------
 * ALTERAÇÕES   : 
 * --------------

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	 */
?>
<center>
<div id="divArquivos" name="divArquivos" style="width: 705px;">
	<form id="frmArquivo" name="frmArquivo" class="formulario" enctype="multipart/form-data" style="display:none" target="blank" method="POST">
		<fieldset>
			<legend>Enviar Arquivo de CNAEs Restritos ou Bloqueados</legend>
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

<!--
<div id="divListErr" style="display:none;">
</div>

<div id="divListMsg" style="display:block;">
</div>

<div id="divViewMsg" style="display:none;">
	<br>
	<fieldset id="resumoarquivo" name="resumoarquivo" style="width:500px;display:none;">
	
		<legend>Resumo da Leitura</legend>
		<center>
		<table style="">
			<tr>
				<td width="140px" class="txtNormalBold" style="">
				</td>
				<td width="140px" class="txtNormalBold" style="text-align:right;">
					Sucesso:
				</td>
				<td width="140px" class="txtNormalBold" style="text-align:right;">
					Erro:
				</td>
				<td width="140px" class="txtNormalBold" style="text-align:right;">
					Total:
				</td>
			</tr>
			<tr>
				<td class="txtNormalBold" style="text-align:right;">
					Qtde Registros:
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtdregok" type="text"  id="qtdregok" class='campoTelaSemBorda' size="8" value="" style="text-align:right;" readOnly />
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtregerr" type="text"  id="qtregerr" class='campoTelaSemBorda' size="8" value="" style="text-align:right;" readOnly />
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtregtot" type="text"  id="qtregtot" class='campoTelaSemBorda' size="12" value="" style="text-align:right;" readOnly />
				</td>
			</tr>
			<tr>
				<td class="txtNormalBold" style="text-align:right;">
					Valor L&iacute;quido:
				</td>
				<td class="txtNormalBold" style="text-align:right;"></td>
				<td class="txtNormalBold" style="text-align:right;"></td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="vltotpag" type="text"  id="vltotpag" class='campoTelaSemBorda' size="12" value="" style="text-align:right;" readOnly />
				</td>
			</tr>
		</table>
		</center>
		</fieldset>	
		
		<fieldset id="resumocomprovante" name="resumocomprovante" style="width:500px;display:none;">
	
		<legend>Resumo da Leitura</legend>
		<center>
		<table style="">
			<tr>
				<td width="140px" class="txtNormalBold" style="">
				</td>
				<td width="140px" class="txtNormalBold" style="text-align:right;">
					Sucesso:
				</td>
				<td width="140px" class="txtNormalBold" style="text-align:right;">
					Erro:
				</td>
				<td width="140px" class="txtNormalBold" style="text-align:right;">
					Total:
				</td>
			</tr>
			<tr>
				<td class="txtNormalBold" style="text-align:right;">
					Qtde Comprovantes:
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtdcmpok" type="text"  id="qtdcmpok" class='campoTelaSemBorda' size="8" value="" style="text-align:right;" readOnly />
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtcmperr" type="text"  id="qtcmperr" class='campoTelaSemBorda' size="8" value="" style="text-align:right;" readOnly />
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtcmptot" type="text"  id="qtcmptot" class='campoTelaSemBorda' size="12" value="" style="text-align:right;" readOnly />
				</td>
			</tr>
			<tr>
				<td class="txtNormalBold" style="text-align:right;">
					Qtde Linhas:
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtdlinok" type="text"  id="qtdlinok" class='campoTelaSemBorda' size="8" value="" style="text-align:right;" readOnly />
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtlinerr" type="text"  id="qtlinerr" class='campoTelaSemBorda' size="8" value="" style="text-align:right;" readOnly />
				</td>
				<td class="txtNormalBold" style="text-align:right;">
					<input name="qtlintot" type="text"  id="qtlintot" class='campoTelaSemBorda' size="12" value="" style="text-align:right;" readOnly />
				</td>
			</tr>
		</table>
		</center>
		</fieldset>	
</div> -->
</center>