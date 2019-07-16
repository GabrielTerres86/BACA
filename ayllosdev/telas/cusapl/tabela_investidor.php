<?
/*!
 * FONTE        : tabela_investidor.php
 * CRIAÇÃO      : Christian Grauppe - Envolti
 * DATA CRIAÇÃO : 10/04/2019
 * OBJETIVO     : Tabela que apresenta os detalhes dos investimentos
 */

	session_start();
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<cdmodulo>".'LISTATABINV'."</cdmodulo>";
	$xml .= "		<cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml ,"TELA_CUSAPL" ,"TELA_CUSAPL_LIS_FRN_TAB_INV" ,$glbvars["cdcooper"] ,$glbvars["cdagenci"] ,$glbvars["nrdcaixa"] ,$glbvars["idorigem"] ,$glbvars["cdoperad"] ,"</Root>");

	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro);
	}

	$detalhesInv = $xmlObjeto->roottag->tags[0]->tags;//->roottag->tags;
	$qtregist = count($detalhesInv);
	$vlrAnt = '0,00';

?>
<script type="text/javascript" src="../../scripts/funcoes.js"></script>

<script type="text/javascript" src="../../scripts/jquery.mask.min.js"></script>
<script type="text/javascript" src="../../scripts/jquery.maskMoney.js"></script>

<table id="tbdetgra" cellpadding="0" cellspacing="0" border="0" width="800">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TABELA DE INVESTIDOR</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),unblockBackground());"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0" /></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0" /></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">
										<? include("tabela_investidor_tab.php"); ?>
									</div>
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>