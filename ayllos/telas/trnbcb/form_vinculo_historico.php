<?
/*!
 * FONTE        : form_vinculo_historico.php
 * CRIAÇÃO      : Lucas Ranghetti         
 * DATA CRIAÇÃO : 20/01/2016
 * OBJETIVO     : Incluir/Alterar vinculos dos historicos com suas respectivas transacoes
 * PROJETO		: Projeto Melhoria 157
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
?>
<script>
 $(document).ready(function() {

	$('#tphistor', '#frmVincHis').val(<? echo $tphistor; ?>);
 });
</script>

<form id="frmVincHis" name="frmVincHis" class="formulario" onSubmit="return false;" style="display:none">
	<table width="100%">		
        <tr>		
			<td colspan="2" >
				<label for="cddtrans"><? echo utf8ToHtml('Transa&ccedil;&atilde;o:') ?></label>
				<input type="text" id="cddtrans" name="cddtrans" value="<? echo $cddtrans?>" />
				<input type="text" id="dsctrans" name="dsctrans" value="<? echo $dsctrans?>" style="margin-left:30px;"/>
			</td>
		</tr>		
		<tr>		
			<td colspan="2" >
				<label for="cdhistor">Hist&oacute;rico :</label>
				<input type="text" id="cdhistor" name="cdhistor" value="<? echo $cdhistor ?>" />
				<a href="#" onclick="controlaPesquisas(2); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
				<input type="text" id="dshistor" name="dshistor" value="<? echo $dshistor ?>" style="margin-left:10px;"/>
			</td>
		</tr>
		<tr>		
			<td colspan="2">								
				<label name="tphistor" for="tphistor">Tipo:</label>				
				<select id="tphistor" name="tphistor">
					<option value="0" >0 - Online</option>
					<option value="1" >1 - Offline</option>					
				</select>
			</td>
		</tr>
	</table>
</form>

<div id="divBotoesVincHis" style="margin-top:5px; margin-bottom :10px; text-align:center;">
		<a href="#" class="botao" id="btVoltar"   onClick="<? echo 'fechaRotina($(\'#divRotina\'));'?> return false;">Voltar</a>		
		<a href="#" class="botao" id="btConcluir"  onClick="realizaOperacao('<? echo $opcao; ?>');">Concluir</a>
</div>