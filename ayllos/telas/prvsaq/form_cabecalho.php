<?php
	/*!
	* FONTE        : form_cabecalho.php
	* CRIAÇÃO      : Antonio R. Junior (Mouts)
	* DATA CRIAÇÃO : 14/08/2013
	* OBJETIVO     : Cabeçalho para a tela PRVSAQ
	* --------------
	* ALTERAÇÕES   : 
	* --------------
	*/

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	// Monta o xml de requisição
	$xmlCooperativas  = "";
	$xmlCooperativas .= "<Root>";
	$xmlCooperativas .= "	<Cabecalho>";
	$xmlCooperativas .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlCooperativas .= "		<Proc>busca_cooperativas</Proc>";
	$xmlCooperativas .= "	</Cabecalho>";
	$xmlCooperativas .= "	<Dados>";
	$xmlCooperativas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCooperativas .= "	</Dados>";
	$xmlCooperativas .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCooperativas);
		
				
	// Cria objeto para classe de tratamento de XML
	$xmlObjCooperativas = getObjectXML($xmlResult);
		
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCooperativas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCooperativas->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$cooperativas   = $xmlObjCooperativas->roottag->tags[0]->tags;	
	$qtCooperativas = count($cooperativas);
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none" >
	<input type="hidden" id="glbcoope" name="glbcoope" value="<? echo $glbvars['cdcooper'] ?>" />
	<input type="hidden" id="glbdtmvt" name="glbdtmvt" value="<? echo $glbvars["dtmvtolt"] ?>" />	
	<input type="hidden" id="sidlogin" name="sidlogin" value="<? echo $glbvars["sidlogin"] ?>" />
	<table width="100%">
		<tr>		
			<td>
				<label for="cddopcao">Op&ccedil;&atilde;o:</label>
				<select id="cddopcao" name="cddopcao" style="width: 200px;" onchange="checkOptionSelected(this.value);">
					<?
						if ($glbvars["cdcooper"] != 3){
					?>
							<option value="I">I - Inclus&atilde;o de provis&atilde;o</option>
					<?
						}
					?>					
					<option value="C">C - Consulta de provis&atilde;o</option>
					<option value="E">E - Exclus&atilde;o de provis&atilde;o</option> 
					<option value="A">A - Altera&ccedil;&atilde;o de provis&atilde;o</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="liberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<?
			if ($glbvars["cdcooper"] == 3){
		?>
		<tr>
			<td>
				<label for="cdcooper" style="width: 88px;">Cooperativa:</label>
				<select id="cdcooper" name="cdcooper" style="width: 423px;">
					<?
						if ($qtCooperativas > 0){
							echo '<option value="3">TODAS</option>';
						}
						for ($i = 0; $i < $qtCooperativas; $i++){
							$cdcooper = getByTagName($cooperativas[$i]->tags,"CODCOOPE");
							$nmrescop = getByTagName($cooperativas[$i]->tags,"NMRESCOP");
							
							echo '<option value="'.$cdcooper.'">'.$nmrescop.'</option>';
						}
					?>
				</select>
			</td>
		</tr>
		<?
			}
		?>
	</table>
</form>