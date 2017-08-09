<?php

	/*******************************************************************
	Fonte: tab096.php                                                		
	Autor: Lucas Reinert                                             		
	Data : Julho/2015                 �ltima Altera��o: 06/03/2017
	                                                                 		
	Objetivo  : Mostrar tela TAB096.                                    
	                                                                    
	Altera��es: 06/03/2017 - Buscar somente as cooperativas ativas. (P210.2 - Jaison/Daniel)
	*******************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");
	require_once('../../class/xmlfile.php');
	
	
	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();
	
	// Carrega permiss�es do operador
	include("../../includes/carrega_permissoes.php");	

    $xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <cdcooper>0</cdcooper>";
    $xml .= "   <flgativo>1</flgativo>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "CADA0001", "LISTA_COOPERATIVAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);

    if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
        $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
        if ($msgErro == "") {
            $msgErro = $xmlObject->roottag->tags[0]->cdata;
        }
        exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
    }

    $registros = $xmlObject->roottag->tags[0]->tags;
    $slcooper  = '<option value="0">TODAS</option>';

    foreach ($registros as $r) {
        if (getByTagName($r->tags, 'cdcooper') <> '' && 
            getByTagName($r->tags, 'cdcooper') <> 3) {
            $slcooper .= '<option value="'.getByTagName($r->tags, 'cdcooper').'">'.strtoupper(getByTagName($r->tags, 'nmrescop')).'</option>';
        }
    }
?>

<script>

	var slcooper = '<?php echo $slcooper ?>';

</script>

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
   <script type="text/javascript" src="tab096.js"></script>	
	
	
  </head>

  <body>
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">TAB096 - Par&acirc;metros Cobran&ccedil;a de Empr&eacute;stimos </td>
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
																<table width="660" border="0" cellpadding="0" cellspacing="0" style="backgroung-color: #F4F3F0;">
																	<tr>
																		<td>
																			<div id="divTela">
																				
																				<? include('form_cabecalho.php'); ?>
																				
																				<div id="divFormulario" > </div>
																				
																				<div id="divMsgAjuda"  style="margin-top:5px; margin-bottom :10px; display:none; text-align: center;" >
																					<span></span>
																					<a href="#" class="botao" id="btVoltar"  onClick="btnVoltar();return false;" style="text-align: right;">Voltar</a>
																					<a href="#" class="botao" id="btAlterar" onClick="alterarDados();" style="text-align: right;">Alterar</a>
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
