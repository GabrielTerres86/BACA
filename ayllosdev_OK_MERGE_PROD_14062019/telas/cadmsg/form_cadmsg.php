<?
/*!
 * FONTE        : form_cadmsg.php
 * CRIAÇÃO      : Jorge Issamu Hamaguchi
 * DATA CRIAÇÃO : 16/07/2012
 * OBJETIVO     : Formulario para a tela CADMSG
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

?>
<div id="divOpcoes">

	<div id="divBotoes" >
		<a href="#" class="botao" id="btnNovaMsg" onclick="btnNovaMsg();return false;">Nova mensagem</a><span style="margin-left:100px;">&nbsp;</span>
		<a href="#" class="botao" id="btnMsgEnv" onclick="btnListMsg();return false;">Mensagens enviadas</a>
	</div>

</div>

<div id="divNovaMsg" style="display:none;">
	<form enctype="multipart/form-data" id="frmNovaMsg" name="frmNovaMsg">
		<br />
		<label for="dsdassun">Assunto:</label><br />
		<input type="text" id="dsdassun" name="dsdassun" alt="<? echo utf8ToHtml('Informe o assunto da mensagem.'); ?>" autocomplete="off" /><br /><br />
		
		<a id="ahref1" onclick="addTagCooperado();return false;" href="">Adicionar o nome do cooperado</a>
		<a id="ahref2" onclick="addTagCooperativa();return false;" href="">Adicionar o nome da cooperativa</a>
		<a id="ahref3" onclick="addTagLink();return false;" href="">Adicionar um link</a><br>
		
		<div id="divOutAddLink">
			<div id="divAddLink" style="display:none;">
				<label style="margin:5px;" for="nomlink" class="txtNormalBold">Adicionar Link</label><br>
				<label style="margin:5px;" class="txtNormalBold" for="nomlink">Nome:</label>
				<input id="nomlink" name="nomlink" autocomplete="off" alt="Informe o Nome do link." style="margin:5px;" class="campo" size="21"><br>
				<label style="margin:5px;" class="txtNormalBold" for="url">URL:</label>
				<input id="urllink" name="urllink" autocomplete="off" alt="<? echo utf8ToHtml('Informe o endereço URL do link.'); ?>" style="margin-left:16px;" class="campo" size="21"><br>
				<div style="text-align:right;margin:5px;">
					<a href="#" class="botao" id="btnAddLinkCanc" onclick="btnAddLinkCanc();return false;">Cancelar</a>
					<a href="#" class="botao" id="btnAddLinkOk" onclick="btnAddLinkOk();return false;">OK</a>
				</div>
			</div>
		</div>
		
		<label for="dsdmensg">Mensagem:</label>
		<br />
		<textarea name="dsdmensg" id="dsdmensg" rows="10" alt="<? echo utf8ToHtml('Descreva o conteúdo da mensagem.'); ?>" autocomplete="off" ></textarea><br /><br />

		<label for="cdidpara">Para:</label><br />
		<select name="cdidpara" id="cdidpara" onchange="mostraCamposCoop();" alt="<? echo utf8ToHtml('Selecione o tipo de destinatário.'); ?>"  autocomplete="off">
			<option value="1"><? echo utf8ToHtml('Todas os cooperados (escolher as cooperativas)'); ?></option>
			<option value="2"><? echo utf8ToHtml('Upload de arquivo com cooperativas/contas específicas'); ?></option>
		</select><br /><br />
		
		<select id="dsidpara" name="dsidpara[]" multiple="multiple" alt="<? echo utf8ToHtml('Selecione o(s) destinatário(s).'); ?>">
			<option value="0">Todas as Cooperativas</option>
		</select>
		<span id="spanInfo"><? echo utf8ToHtml('Pressione CTRL para selecionar várias Cooperativas'); ?></span>
		<br /><br />	
		
		<div id="divuploadfile">
			<input type="hidden" name="MAX_FILE_SIZE" value="1048576" />
			<input name="userfile" id="userfile" size="50" type="file" class="campo" alt="<? echo utf8ToHtml('Informe o caminho do arquivo.'); ?>" />
			<span id="SpanJTxt" style="font-size:10px;font-style:italic;">&nbsp;&nbsp;Apenas arquivos '.txt'</span>
		</div>
		
		<br style="clear:both" />	

	</form>

	<div id="divBotoesEnviar" >
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar();return false;">Voltar</a><span style="margin-left:10px;">&nbsp;</span>
		<a href="#" class="botao" id="btnEnviarMsg" onclick="btnEnviarMsg();return false;">Enviar mensagem</a>
	</div>
	
</div>

<div id="divListErr" style="display:none;">
</div>

<div id="divListMsg" style="display:block;">
</div>

<div id="divViewMsg" style="display:none;">
</div>

