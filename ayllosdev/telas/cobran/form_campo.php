<?
/*!
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Rogérius Militão - DB1 Informatica
 * DATA CRIAÇÃO : 27/02/2012 
 * OBJETIVO     : Formulário para a entrada do valor da instrução que será executada 
 * ALTERACOES   : 
 *     			  03/05/2013 - Adicionado cdisntru 7, concessao de desconto. (Jorge)
 *
 *				  01/02/2018 - Alterações referente ao PRJ352 - Nova solução de protesto
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	
	$cdinstru 	= $_POST['cdinstru'];
	$nrdconta 	= $_POST['nrdconta'];
	$nrconven 	= $_POST['nrconven'];
	$nrcnvceb	= '0';
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrconven>".$nrconven."</nrconven>";
	$xml .= "   <nrcnvceb>".$nrcnvceb."</nrcnvceb>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "COBRAN", "COBRAN_CONSULTA_LIMITE_DIAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
  
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	  if ($msgErro == "") {
		  $msgErro = $xmlObj->roottag->tags[0]->cdata;
	  }
	  
	  exibirErro('error',$msgErro,'Alerta - Ayllos','fechaRotina( $(\'#divRotina\') )', false);
	  exit();
	}
	
	$qtlimmip = $xmlObj->roottag->tags[0]->tags[4]->tags[0]->cdata;
	$qtlimaxp = $xmlObj->roottag->tags[0]->tags[4]->tags[1]->cdata;
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico')); bloqueiaFundo($('#divRotina')); $('#cdinstru', '#frmConsulta').focus(); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divCampo">

										<form id="frmCampo" name="frmCampo" class="formulario" onsubmit="return false;">

											<fieldset>
												
												<?php
												if ( $cdinstru == 4 ) {
												?>
													<legend>Concessao de Abatimento</legend>
													<label for="vlabatim">Valor Abatimento:</label>
													<input name="vlabatim" id="vlabatim" type="text"  />
												<?php
												} else if ( $cdinstru == 6 ) {
												?>
													<legend>Alteracao de Vencimento</legend>
													<label for="dtvencto">Nova Data Vencto:</label>
													<input name="dtvencto" id="dtvencto" type="text"  />
												<?php
												} else if ( $cdinstru == 7 ) {
												?>
													<legend>Concessao de Desconto</legend>
													<label for="vldescto">Valor Desconto:</label>
													<input name="vldescto" id="vldescto" type="text"  />
												<?php
												} else if ( $cdinstru == 80 ) { /*Instrução automática de protesto (PRJ352)*/
												?>
													<legend><? echo utf8ToHtml('Instrução automática de Protesto') ?></legend>
													<label for="qtdiaprt"><? echo utf8ToHtml('Dias corridos (Limitado de '.$qtlimmip.' a '.$qtlimaxp.' dias):') ?></label>
													<input name="qtdiaprt" id="qtdiaprt" type="text"  />
												<?php
												}
												?>
											</fieldset>	

										</form>

										<div id="divBotoes" style="margin-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divUsoGenerico')); bloqueiaFundo($('#divRotina')); $('#cdinstru', '#frmConsulta').focus(); return false;">Cancelar</a>
											<a href="#" class="botao" onclick="manterRotina('GI')">Continuar</a>
										</div>
										
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