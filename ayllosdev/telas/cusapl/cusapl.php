<?php
//*********************************************************************************************//
//*** Fonte: cusapl.php                                    						                      ***//
//*** Autor: Rafael B. Arins - Envolti                                           						***//
//*** Data : Abril/2018                  Última Alteração: --/--/----  					            ***//
//***                                                                  						          ***//
//*** Objetivo  : Mostra tela CUSAPL                   						                          ***//
//***                                                                  						          ***//
//*** Alterações: 																			                                    ***//
//*********************************************************************************************//

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');


	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Carrega permissões do operador
	include("../../includes/carrega_permissoes.php");
?>

<html>
  <head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <meta http-equiv="Pragma" content="no-cache">
   <title><?php echo $TituloSistema; ?></title>
   <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
   <script type="text/javascript" src="../../scripts/scripts.js"></script>
   <script type="text/javascript" src="../../scripts/dimensions.js"></script>
   <script type="text/javascript" src="../../scripts/funcoes.js"></script>
   <script type="text/javascript" src="../../scripts/mascara.js"></script>
   <script type="text/javascript" src="../../scripts/menu.js"></script>
	 <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   <script type="text/javascript" src="cusapl.js<?php echo '?'.date("YmdHis"); ?>"></script>
   <script type="text/javascript" src="cusapl_o.js"></script>
  </head>

  <body><?
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>0</cdcooper>";
	$xml .= "   <flgativo>1</flgativo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PAREST", "PAREST_LISTA_COOPER", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	    if ($msgErro == "") {
	        $msgErro = $xmlObj->roottag->tags[0]->cdata;
	    }

	    exibeErroNew($msgErro);
	    exit();
	}

	$registros = $xmlObj->roottag->tags[0]->tags;
	$scriptCoops =  '<script>var arrayCoops=\'';
	foreach ($registros as $r) {

		if ( getByTagName($r->tags, 'cdcooper') <> '' && getByTagName($r->tags, 'cdcooper') <> 3 ) {
			$coopLabel=getByTagName($r->tags, 'nmrescop');
			$coopVal=getByTagName($r->tags, 'cdcooper');
		  $scriptCoops.= '<option value="'.$coopVal.'">'.$coopLabel.'</option>';
		}
	}
	$scriptCoops .= '\';</script>';
	echo $scriptCoops;
	function exibeErroNew($msgErro) {
	    echo 'hideMsgAguardo();';
	    echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
	    exit();
	}
	?>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
		   <td><?php  include("../../includes/topo.php"); ?></td>
	    </tr>
		<tr>
			<td id="tdConteudo" valign="top">
				<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
					<tr>
						<td width="175" valign="top">
						<table width="100%" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td id="tdMenu"><?php include("../../includes/menu.php"); ?></td>
							</tr>
						</table>
						</td>
						<td id="tdTela" valign="top">
						   	<table width="100%" border="0" cellpadding="0" cellspacing="0">
								<tr>
									<td>
									   <table width="100%"  border="0" cellspacing="0" cellpadding="0">
										  <tr>
											<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('CUSAPL – Custódia das Aplicações na B3') ?></td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
										 	<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
									      </tr>
									   </table>
     							    </td>
								</tr>
								<tr>
									<td id="tdConteudoTela" class="tdConteudoTela" align="center">
										<table width="100%"  border= "0" cellpadding="3" cellspacing="0">
											<tr>
												<td style="border: 1px solid #F4F3F0;">
													<table width="100%"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
																<table width="960" border="0" cellpadding="0" cellspacing="0" style="backgroung-color: #F4F3F0;">
																	<tr>
																		<td>
                                      <!-- INCLUDE DA TELA DE PESQUISA -->
                                      <? require_once("../../includes/pesquisa/pesquisa.php"); ?>

																			<!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
																			<? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>

																			<div id="divTela" style="margin: 10px 0;">

																				<? include('form_cabecalho.php'); ?>

																				<div id="divFormulario">

																				</div>


																				<?php //div id="divBotoes" style="margin-top:5px; margin-bottom :10px;display:none"></div ?>

                                        <div id="divRotina"></div>

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
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
  </body>

</html>
