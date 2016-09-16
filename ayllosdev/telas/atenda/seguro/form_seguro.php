<?
/*!
 * FONTE        : form_seguro.php
 * CRIAÇÃO      : Michel M. Candido (GATI)
 * DATA CRIAÇÃO : 22/09/2011
 * OBJETIVO     : mostra em tela forulario de seguro
 * --------------
 * ALTERAÇÕES   :
 * 001: [30/11/2012] David (CECRED) : Validar session
 */

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	isPostMethod();	
	
	function getValue($tipo){
		switch(strtoupper($tipo)){
			case 3			:
			case 1			: return 'VIDA';   break;
			case 4  		: return 'PREST';  break;
		}
		return null;
	}

	$tipo = $_POST['tipo'];
	
?>

<form name="forSeguro" id="forSeguro" class="forulario">	
	<input type='hidden' value='<?php echo $tipo;?>' id='tipo' name='tipo'>
	<input type='hidden' value='' id='inpessoa' name='inpessoa'>
	<input type='hidden' value='<?php echo $_POST['cdsitdct'];?>' id='cdsitdct' name='cdsitdct'>
	<input type='hidden' value='<?php echo $_POST['nmprimtl'];?>' id='nmprimtl' name='nmprimtl'>
	<table width="100%">
		<tr>
			<td><label  for='tpseguro' style='float:left'>Seguro:</label></td>
			<td id='tpseguro'><?php echo getValue($tipo)?></td>
			<td ><label for='seguradora'>Seguradora:</label></td>
			<td width='200px;'>&nbsp;</td>
		</tr>
		<tr>
			<td><label for='nmresseg'>Titular:</label></td>
			<td>
				<select name='nmresseg' id='nmresseg' onchange='carregaTitular(this.value);' onkeypress='carregaTitular(this.value);'>
					<option value=""></option>
					<option value="p-titular">Primeiro Titular</option>
					<option value="conjuge">Conjuge</option>					
				</select>
			</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>			
		<tr>
			<td><label for='nmdsegur'>Segurado:</label></td>
			<td colspan='3'><input type="text" id="nmdsegur"  value=""></td>
		</tr>
		<tr>
			<td><label for='nrcpfcgc'>CPF/CNPJ:</label></td>
			<td><input type="text" id="nrcpfcgc"></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><label for='dtnascsg'>Nascimento:</label></td>
			<td><input type="text" id="dtnascsg" value=""  ></td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><label for='cdsexosg'>Sexo:</label></td>
			<td colspan='3'><input type='radio' value='1' id='cdsexosg-1' name='cdsexosg' checked><label for='cdsexosg-1'>&nbsp;Masculino</label> <input type='radio' name='cdsexosg' value='2' id='cdsexosg-2'> <label for='cdsexosg-2'>Feminino</label></td>
		</tr>
		
	</table>
</form>
<div id="divBotoes">
	<input type="image" id="btVoltar"    src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('I'); return false;"  />
	<input type="image" id="btContinuar"   src="<? echo $UrlImagens; ?>botoes/continuar.gif"   onClick="if(tpseguro==3){validaInclusaoVida();}else {controlaOperacao('TI');}"   />
</div>