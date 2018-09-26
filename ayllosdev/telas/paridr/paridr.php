<?php
/*******************************************************************
Fonte: paridr.php                                                		
Autor: Lucas Reinert                                             		
Data : Fevereiro/2016                 Última Alteração: --/--/----   		
																		
Objetivo  : Mostrar tela PARIDR
																	
Alterações: 															
*******************************************************************/

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

// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0131.p</Bo>';
$xml .= '		<Proc>Busca_Cooperativas</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
$xml .= '		<nmrescop>'.$glbvars['nmcooper'].'</nmrescop>';	
$xml .= '	</Dados>';
$xml .= '</Root>';


// Executa script para envio do XML e cria objeto para classe de tratamento de XML
$xmlResult 		= getDataXML($xml);
$xmlObjeto 		= getObjectXML($xmlResult);

// Recebe as cooperativas
$nmcooper		= $xmlObjeto->roottag->tags[0]->attributes['NMCOOPER'];
	
// Faz o tratamento para criar o select
$nmcooperArray	= explode(',', $nmcooper);

$qtcooper		= count($nmcooperArray);

if ($glbvars['cdcooper'] == 3){
	for ( $j = 0; $j < $qtcooper; $j +=2 ) {
		
		if($j > 0){
			$slcooper = $slcooper . '<option value="'.$nmcooperArray[$j+1].'">'.$nmcooperArray[$j].'</option>';
		}
	}			
}
else{
	$slcooper = '<option value="'.$glbvars['cdcooper'].'" selected>'.strtoupper($glbvars['nmcooper']).'</option>';
}
?>

<script>

	var slcooper = '<?php echo $slcooper ?>';
	var cdcooper = <?php echo $glbvars['cdcooper'] ?>;

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
   <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
   <script type="text/javascript" src="paridr.js"></script>
	
	
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
											<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PARIDR - Parametriza&ccedil;&atilde;o da Reciprocidade por Cooperativa</td>
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
												<td style="border: 1px solid #F4F3F0;" align="center">
													<table width="550"  border= "0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
														<tr>
															<td align="center">
															<?php include('form_cabecalho.php'); ?>
																<!-- INCLUDE DA TELA DE PESQUISA -->
																			<? require_once("../../includes/pesquisa/pesquisa.php"); ?>
																<table width="900" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
																	<tr>													
																		<td>								
																			<table border="0" cellspacing="0" cellpadding="0">
																			<tr>
																				<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
																				<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="voltarTabela();acessaOpcaoAba(0);return false;">Indicadores</a></td>
																				<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
																				<td width="1"></td>

																				<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
																				<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="voltarTabela();acessaOpcaoAba(1);return false;">Vincula&ccedil;&otilde;es</a></td>
																				<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
																				<td width="1"></td>
																			</tr>
																			</table>																		
																		</td>
																	</tr>
																	<tr>
																		<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
																			<div id="divAba0" class="clsAbas">
																				<div id="divTela">
																					<div id="divFormulario" > </div>
																					
																					<?php include('form_paridr.php'); ?>
																					
																					<div id="divBotoes"  style="display: none; margin-top:5px; margin-bottom :10px; text-align: center;" >
																						<span></span>
																						<a href="#" class="botao" id="btAlterar" onClick="verificaAcesso('A');" style="text-align: right;">Alterar</a>
																						<a href="#" class="botao" id="btIncluir" onClick="verificaAcesso('I');" style="text-align: right;">Incluir</a>
																						<a href="#" class="botao" id="btExcluir" onClick="selecionaLinha('E');" style="text-align: right;">Excluir</a>
																						<a href="#" class="botao" id="btVoltar"  style="text-align: right;">Voltar</a>
																						<a href="#" class="botao" id="btProsseguir" style="display: none; text-align: right;">Prosseguir</a>
																					</div>																				
																				</div>
																			</div>
																			<div id="divAba1" class="clsAbas">
																				<div id="divTela">
																					<div id="divFormulario" > </div>
																					
																					<?php include('form_vinculacao.php'); ?>
																					
																					<div id="divBotoes"  style="display: none; margin-top:5px; margin-bottom :10px; text-align: center;" >
																						<span></span>
																						<a href="#" class="botao" id="btAlterar" onClick="verificaAcesso('A');" style="text-align: right;">Alterar</a>
																						<a href="#" class="botao" id="btIncluir" onClick="verificaAcesso('I');" style="text-align: right;">Incluir</a>
																						<a href="#" class="botao" id="btExcluir" onClick="selecionaLinha('E');" style="text-align: right;">Excluir</a>
																						<a href="#" class="botao" id="btVoltar"  style="text-align: right;">Voltar</a>
																						<a href="#" class="botao" id="btProsseguir" style="display: none; text-align: right;">Prosseguir</a>
																					</div>																				
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
