<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011
 * OBJETIVO     : Cabeçalho para a tela EXTRAT
 * --------------
 * ALTERAÇÕES   : 31/07/2013 - Implementada opcao A da tela EXTRAT (Lucas).
 * -------------- 19/09/2013 - Implementada opcao AC da tela EXTRAT (Tiago).
 *				  14/06/2016 - No form frmOpcao trocar display para block (Lucas Ranghetti #463356)
 *                10/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 */
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:block;">

	<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" style="width: 477px;">
		<option value="T"> T - Consultar consultar extrato de conta-corrente </option> 
		<option value="A"> A - Exportar extrato de conta-corrente para arquivo </option> 
	</select>
	<a href="#" class="botao" id="btnOKCab" name="btnOKCab" onClick="if ($('#cddopcao','#frmCab').prop('disabled') == false) { exibeFormularios($('#cddopcao','#frmCab').val()) }; return false;" style = "text-align:right;">OK</a>
	<br style="clear:both" />	
</form>

<form id="frmOpcao" name="frmOpcao" class="formulario" onSubmit="return false;" style="display:block;">	
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<div id="divOpcao" name="divOpcao" style="display:block;">	
		<fieldset>
			<legend><? echo utf8ToHtml('Pesquisa de Extrato') ?></legend>
			<label for="nrdconta">Conta:</label>
			<input type="text" id="nrdconta" name="nrdconta" value="<? echo getByTagName($dados,'nrdconta'); ?>" />
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

			<label for="dtinimov"><? echo utf8ToHtml('Periodo:') ?></label>
			<input name="dtinimov" id="dtinimov" type="text" value="<? echo $dtinimov ?>" autocomplete="off" />
			<label for="dtfimmov"><? echo utf8ToHtml('a') ?></label>
			<input name="dtfimmov" id="dtfimmov" type="text" value="<? echo $dtfimmov ?>" autocomplete="off" />
			<a href="#" class="botao" id="btnOK">OK</a>

			<br style="clear:both" />		
				
		</fieldset>				
	</div>
</form>	

<form id="frmArquivo" name="frmArquivo" class="formulario" onSubmit="return false;" style="display:none;">	
	<div id="divArquivo" name="divArquivo" style="display:block;">	
		<fieldset>		
			<legend><? echo utf8ToHtml('Opcoes de exportacao') ?></legend>
			<label for="nmarquiv"><? echo utf8ToHtml('Listar cheques?') ?></label>
			<select name="listachq"id="listachq">
				<option value="S">Sim</option>
				<option value="N">Nao</option>
			</select>		
			<br />
			<label for="nmarquiv"><? echo utf8ToHtml('Tipo impressão?') ?></label>
			<select name="tipoarqv"id="tipoarqv">
				<option value=".txt">Txt</option>
				<option value=".pdf">Pdf</option>
			</select>		
			<br style="clear:both" />	
		
		</fieldset>			
		<fieldset>		
			<legend><? echo utf8ToHtml('Exportar para Arquivo') ?></legend>
			<label for="nmarquiv"><? echo utf8ToHtml('Diretorio:    /micros/' . $glbvars["dsdircop"] . '/') ?></label>
			<input type="text" id="nmarquiv" name="nmarquiv" value="" />
			<label for="nmtpoarq" style="margin-left:5px"><? echo utf8ToHtml('.txt') ?></label>
			<br style="clear:both" />	
		
		</fieldset>		
		
	</div>
</form>	
