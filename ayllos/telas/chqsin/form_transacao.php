<?php
/*!
 * FONTE        : form_transacao.php
 * CRIAÇÃO      : Rodrigo Bertelli (RKAM)
 * DATA CRIAÇÃO : 26/06/2014
 * OBJETIVO     : Formulario transacao
 * 
 * Alteração    : 16/10/2015 - (Lucas Ranghetti #326872) - Alteração referente ao projeto melhoria 217, cheques sinistrados fora.
 */ 
?>
<div id="divTransacao">
	<div id="" style="margin-top: 10px;">
	<form id="frmInclusao" name="frmInclusao" >
		<table>
			<tr>
				<td style="text-align: right;"><label for="datinicial">Data Inicial:</label></td>
				<td><input type="text" class="campo clsData" style="text-align:right" id="datinicial" name="datinicial" maxlength="10" onchange="validaDataInput(this)" value="" alt="Data Inicial." /></td>
				<td style="text-align: right; width:155px;"><label for="datfinal">Data Final:</label></td>
				<td><input type="text" class="campo clsData" style="text-align:right"style="text-align:right"  id="datfinal" name="datfinal" maxlength="10" onchange="validaDataInput(this)" value="" alt="Data Final." /></td>
			</tr>
			<tr height="5px"> 
			</tr>
			<tr>											
				<td style="text-align: right; width:130px;"><label for="codbancopesq">Banco do Sinistro:</label></td>
				<td><input class="campo somenteNumeros" type="text" style="text-align:right" id="codbancopesq" name="codbancopesq" maxlength="10" value="" alt="Código do Banco." /></td>
				<td style="text-align: right; width:155px;"><label for="codagenciapesq">Ag&ecirc;ncia:</label></td>
				<td><input class="campo somenteNumeros" type="text" style="text-align:right"  id="codagenciapesq" name="codagenciapesq" maxlength="10" value="" alt="Código do Agência." /></td>
			</tr>
			<tr height="5px"> 
			</tr>
			<tr>
				<td style="text-align: right; width:130px;"><label for="nrcontapesq">N&uacute;mero da Conta:</label></td>
				<td><input class="campo somenteNumeros" type="text"  style="text-align:right" id="nrcontapesq" name="nrcontapesq" maxlength="10" value="" alt="Nr. Conta." /></td>
				<td style="text-align: right; width:155px;"><label for="nrcheqpesq" id="nrchqlbl">N&uacute;mero do Cheque:</label></td>
				<td><input class="campo somenteNumeros" type="text"  style="text-align:right" id="nrcheqpesq" name="nrcheqpesq" maxlength="10" value="" alt="Nr. Cheque." /></td>				
				<td style="text-align: right;"><a href="#" class="botao" id="btBuscar" name="btBuscar" onClick = "buscaChequesSinistrados( 1, 30 );" style = "text-align:right;">Buscar</a></td>
			</tr>
			<tr height="10px" >
			</tr>
		</table>
	</form>
	<div id="divTabelaCheques">
		<?php include 'tabela_chqsin.php'?>
	</div>
	</div>
</div>
								