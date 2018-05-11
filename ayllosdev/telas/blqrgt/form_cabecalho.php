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
					<option value="C"> C - Consultar aplica&ccedil;&atilde;o </option> 
					<option value="B"> B - Bloquear op&ccedil;&atilde;o de resgate de aplicacao </option>
					<option value="L"> L - Liberar aplica&ccedil;&atilde;o para resgate </option>
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
			</td>
		</tr>
		<tr>
			<td>
				<label for="tpaplica">Tp.Apl.:</label>
				<select id="tpaplica" name="tpaplica" style="width: 79px;">
					<?php 
						foreach($nmaplicas as $nmaplica){
				
							$cdprodut = $nmaplica->tags[0]->cdata;
							$nmprodut = $nmaplica->tags[1]->cdata;
							$tpprodut = $nmaplica->tags[2]->cdata;
						
					?>
						<option value="<?php echo $cdprodut.",".$tpprodut.",".$nmprodut; ?>"><?php echo $nmprodut; ?></option>
					<?php 
						}
					?>			
				</select>
				
				<label for="nraplica">Nr.Apl.:</label>
				<input type="text" id="nraplica" name="nraplica" />
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisaNrApl();return false;"><img id="NrAplic" name = "NrAplic" src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			</td>
		</tr>
	</table>
</form>