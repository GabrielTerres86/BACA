<?
/*!
 * FONTE        : form_replica_parametro.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Tela de exibição parametro por cooperativa.
 * --------------
 * ALTERAÇÕES   :
 */		
?>

<form id="frmReplicaCoop" name="frmReplicaCoop" class="formulario cabecalho" onSubmit="return false;" >
<div class="divRegistros" style="height: 300px; padding-bottom: 2px; border-right:0px">
	<table width="100%" border="1" valign="center">
		<tr>		
			<td style="border-right:none;padding:0;" width="30" align="center" valign="center"> 	
				<input type="checkbox" name="flgcheckall" id="flgcheckall" value="no" style="float:none; height:16;"/>
			</td>
			<td style="border-right:none;padding:0;" valign="center">
				<label for="dsconteu"><? echo utf8ToHtml('Cooperativa') ?></label>
			</td>
			<td style="border-right:none;padding:0;" valign="center">
				<label for="dsconteu2"><? echo utf8ToHtml('Cooperativa') ?></label>
			</td>
		</tr>
	
		<tr>		
			<td style="border-right:none;padding:0;" width="30" align="center" valign="center"> 	
				<input class="flgcheck" type="checkbox" name="flgcheck" id="flgcheck" value="no" style="float:none; height:16;"/>
			</td>
			<td style="border-right:none;padding:0;" valign="center">
				<input type="hidden" id="cdcooper" name="cdcooper" value="<? echo $cdcooper == 0 ? '' : $cdcooper ?>" />	
				<label for="dsconteu"><? echo utf8ToHtml('Acredicoop') ?></label>
			</td>
			<td style="border-right:none;padding:0;" valign="center">
				<input type="hidden" id="nmrescop" name="nmrescop" value="<? echo $nmrescop == '' ? '' : $nmrescop ?>" />	
				<input class="dsconteu" type="text" id="dsconteu" name="dsconteu" value="<? echo $dsconteu == '' ? '' : $dsconteu ?>" />	
			</td>
		</tr>
	</table>
	</div>
</form>

<div id="divBotoesReplicaCoop" style="margin-top:5px; margin-bottom :10px; text-align:center;">
		<a href="#" class="botao" id="btVoltar"   onClick="<? echo 'fechaRotina($(\'#divRotina\'));'?> return false;">&nbsp;Voltar&nbsp;</a>
		<a href="#" class="botao" id="btAlterar"   onClick="">Concluir</a>
</div>
