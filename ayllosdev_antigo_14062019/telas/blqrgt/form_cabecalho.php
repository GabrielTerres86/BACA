<?php
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 17/01/2013
 * OBJETIVO     : Cabeçalho para a tela BLQRGT
 * --------------
 * ALTERAÇÕES   : 28/10/2014 - Alteracao de leitura de produtos de aplicacao (Jean Michel).
	*				 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                11/04/2017 - Permitir acessar o Ayllos mesmo vindo do CRM. (Jaison/Andrino)
 *				  16/11/2017 - Tela remodelada para o projeto 404 (Lombardi).
 * --------------
 */
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Monta o xml de requisição
	$xmlConsulta  = "";
	$xmlConsulta .= "<Root>";
	$xmlConsulta .= "  <Cabecalho>";
	$xmlConsulta .= "    <Bo>b1wgen0148.p</Bo>";
	$xmlConsulta .= "    <Proc>carrega-apl-blqrgt</Proc>";
	$xmlConsulta .= "  </Cabecalho>";
	$xmlConsulta .= "  <Dados>";
	$xmlConsulta .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsulta .= "  </Dados>";
	$xmlConsulta .= "</Root>";		
				
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsulta);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCon = getObjectXML($xmlResult);
	$nmaplicas = $xmlObjCon->roottag->tags[0]->tags;
		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<input type="hidden" name="crm_inacesso" id="crm_inacesso" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_INACESSO']; ?>" />
	<input type="hidden" name="crm_nrdconta" id="crm_nrdconta" value="<?php echo $_SESSION["glbvars"][$glbvars["sidlogin"]]['CRM_NRDCONTA']; ?>" />
	<table width = "100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
					<option value="C"> C - Consultar Bloqueio Aplica&ccedil;&atilde;o ou Cobertura para Resgate </option> 
					<option value="L"> L - Liberar Bloqueio Aplica&ccedil;&atilde;o ou Cobertura para resgate </option>
				</select>
				
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
				
			</td>
		</tr>
		<tr>
			<td>
				<label for="nrdconta">Conta:</label>
				<input type="text" id="nrdconta" name="nrdconta" value="<? echo $nrdconta == 0 ? '' : $nrdconta ?>" alt="Informe o numero da conta do cooperado." />
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaConta();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				<input name="nmprimtl" id="nmprimtl" type="text" />				
				<a href="#" class="botao" id="btSalvar"  onClick="btnContinuar(); return false;">Continuar</a>
			</td>
		</tr>
	</table>
</form>