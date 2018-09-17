<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 26/12/2011
 * OBJETIVO     : Cabeçalho para a tela VALPRO
 * --------------
 * ALTERAÇÕES   : 18/12/2012 - Alteracao layout tela, alterado botoes
 *							   tag tipo input para tag tipo a (Daniel).
 
				  06/10/2015 - Incluindo validacao de protocolo MD5 - Sicredi
                               (Andre Santos - SUPERO)

				  19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
							   pelo InternetBanking (Projeto 338 - Lucas Lunelli)

 * --------------
 */

?>


<form id="frmCab" name="frmCab" class="formulario cabecalho" style="display:none;">

	<label for="nrdconta">Conta:</label>
	<input type="text" id="nrdconta" name="nrdconta" alt="Informe a Conta/DV ou F7 para pesquisar."/>
	<a style="margin-top:5px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

	<label for="nrdocmto"><? echo utf8ToHtml('Nr. Documento:') ?></label>
	<input name="nrdocmto" id="nrdocmto" type="text" alt="Informe o numero documento do comprovante."  autocomplete="off" />

	<label for="nrseqaut"><? echo utf8ToHtml('Seq. Autenticacao:') ?></label>
	<input name="nrseqaut" id="nrseqaut" type="text" alt="Informe a sequencia da autenticacao."  autocomplete="off" />
	<br />

	<label for="dtmvtolt">Data:</label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" alt="Informe a data do comprovante."/>

	<label for="horproto"><? echo utf8ToHtml('Hora:') ?></label>
	<input name="horproto" id="horproto" type="text" alt="Informe a(s) hora(s) do comprovante."  autocomplete="off" />

	<label for="minproto"><? echo utf8ToHtml(':') ?></label>
	<input name="minproto" id="minproto" type="text" alt="Informe o(s) minuto(s) do comprovante."  autocomplete="off" />
	
	<label for="segproto"><? echo utf8ToHtml(':') ?></label>
	<input name="segproto" id="segproto" type="text" alt="Informe o(s) segundo(s) do comprovante."  autocomplete="off" />
	
	<label for="vlprotoc"><? echo utf8ToHtml('Valor:') ?></label>
	<input name="vlprotoc" id="vlprotoc" type="text" alt="Informe o valor do comprovante."  autocomplete="off" />
	<br />
	

	<label for="dsprotoc"><? echo utf8ToHtml('Protocolo:') ?></label>
	<input name="dsprotoc" id="dsprotoc" type="text" alt="Informe o protocolo do comprovante."  autocomplete="off" />
	
	<label for="flvalgps"><? echo utf8ToHtml('Valida Informa&ccedil;&atilde;s do GPS, DARF ou DAS? :') ?></label>
	<select id="flvalgps" name="flvalgps" class="campo" >
	    <option value="1" ><? echo utf8ToHtml('Sim') ?></option>
		<option value="0" selected><? echo utf8ToHtml('N&atilde;o') ?></option>		
	</select>
	
	<br style="clear:both" />	

</form>

<div id="divBotoes" style="display:none;margin-bottom :10px">
		<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>

																		

