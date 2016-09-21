<?php
/*******************************************************************************
 Fonte: atenda.php                                                
 Autor: David                                                     
 Data : Julho/2007                   Última Alteração: 24/08/2015 
                                                                  
 Objetivo  : Mostrar tela ATENDA                                  
                                                                  
 Alterações: 15/07/2009 - Mudar label para Tipo de Salário Fixo   
                          (Guilherme).                            
						 - Incluir mais uma linha na table da     
						   das rotinas(Guilherme).				  
                                                                  
             12/01/2010 - Retirar html para pesquisar associados. 
                          Utilizar fonte (HTML) genérico (David). 
                                                                  
             28/10/2010 - Utilizar include para pesquisas de uso  
                          genérico (David).                       
																  
			 14/01/2011 - Incluir rotina de COBRANCA (Gabriel)   
																  
			 29/06/2011 - Tableless (Rogerius - DB1)    		  
				                                                  
			 05/08/2011 - Incluir rotina Ficha Cadastral (Gabriel)	
                                                                  			  
       	     05/03/2012 - Incluido javascript jquery ui (Tiago)   
                                                                  
             31/05/2012 - Incluido javascript tooltip e css       
                          tooltip (Tiago).	                      
																  
			 04/09/2012 - Incluir estilo2.css para layout padrao 
					     (Gabriel)							  	
							   									  		
			 21/11/2012 - Incluido a include msg_grupo_economico.php
				   	     (Adriano).							   
							   									   
			 24/07/2013 - Incluir Rotina Consorcio (Lucas R.)     
																   
			 23/09/2014 - Incluido opção Pagto de Titulos	       
						  (André Santos - SUPERO)	    		   
																   
			 20/07/2015 - Incluir Rotina Limite Saque TAA.(James) 
																   
			 21/08/2015 - Ajuste para inclusão das novas telas "Atendimento,
						  Produtos"
				          (Gabriel - Rkam -> Projeto 217).					   
										    					   
			 24/08/2015 - Projeto Reformulacao cadastral		   
						  (Tiago Castro - RKAM)		
						  
			07/06/2016 - M195 Melhoria de folha de pagamento (Tiago/Thiago)			   
//**************************************************************************/
session_start();
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Carrega permissões do operador
include("../../includes/carrega_permissoes.php");

setVarSession("rotinasTela", $rotinasTela);

?>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
        <meta http-equiv="Pragma" content="no-cache">
        <title><?php echo $TituloSistema; ?></title>
        <link href="../../css/estilo2.css" rel="stylesheet" type="text/css">
        <link href="../../css/estilo.css" rel="stylesheet" type="text/css">
        <link href="../../css/tooltip.css" rel="stylesheet" type="text/css">
        <link href="atenda.css" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
        <script type="text/javascript" src="../../scripts/scripts.js"></script>
        <script type="text/javascript" src="../../scripts/dimensions.js"></script>
        <script type="text/javascript" src="../../scripts/funcoes.js"></script>
        <script type="text/javascript" src="../../scripts/mascara.js"></script>
        <script type="text/javascript" src="../../scripts/menu.js"></script>
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
        <script type="text/javascript" src="../../scripts/tooltip.js"></script>
        <script type="text/javascript" src="atenda.js?keyrand=<?php echo mt_rand(); ?>"></script>
        <style>
            td.tbord{
                border: 1px solid;
                border-color: black;
            }
            @media print {
                .print {display:block;}
                .table {display:block;}
                .td    {display:block;}
            }
        </style>
    </head>
    <body>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td><?php include("../../includes/topo.php"); ?></td>
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
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ATENDA - Atendimento Geral</td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif" align="right"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold">F2 = AJUDA</a>&nbsp;&nbsp;</td>
                                                    <td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick='mostraAjudaF2()' class="txtNormalBold"><img src="<?php echo $UrlImagens; ?>geral/ico_help.jpg" width="15" height="15" border="0"></a></td>
                                                    <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td id="tdConteudoTela" class="tdConteudoTela" align="center">								
                                            <table width="100%" border="0" cellpadding="3" cellspacing="0">
                                                <tr>
                                                    <td style="border: 1px solid #F4F3F0;">
                                                        <table width="100%" border="0" cellpadding="10" cellspacing="0" style="background-color: #F4F3F0;">
                                                            <tr>
                                                                <td align="center">
                                                                    <table width="545" border="0" cellpadding="0" cellspacing="0" style="background-color: #F4F3F0;">
                                                                        <tr>
                                                                            <td>
                                                                                <!-- INCLUDE DA TELA DE PESQUISA ENDERECO -->
                                                                                <? require_once("../../includes/pesquisa/pesquisa_endereco.php"); ?>

                                                                                <!-- INCLUDE DA TELA DE INCLUSAO ENDERECO -->
                                                                                <? require_once("../../includes/pesquisa/formulario_endereco.php"); ?>

                                                                                <!-- INCLUDE DA TELA DE PESQUISA -->
                                                                                <? require_once("../../includes/pesquisa/pesquisa.php"); ?>

                                                                                <!-- INCLUDE DA TELA DE PESQUISA ASSOCIADO -->
                                                                                <? require_once("../../includes/pesquisa/pesquisa_associados.php"); ?>	

                                                                                <!-- INCLUDE COM AS MENSAGEM GE -->
                                                                                <? require_once("../../includes/grupo_economico/msg_grupo_economico.php"); ?>	

                                                                                <!-- INCLUDE COM AS ANOTACOES -->
                                                                                <? include('anotacoes.php') ?>

                                                                                <!-- INCLUDE COM AS MENSAGEM -->
                                                                                <? include('msg_alerta.php')?>

                                                                                <!-- ROTINA -->
                                                                                <div id="divRotina"></div>

                                                                                <!-- INCLUDE DO CABECALHO  -->
                                                                                <? include('form_cabecalho.php') ?>							
                                                                            </td>
                                                                        </tr>
                                                                        <tr>																
                                                                            <td style="padding: 3px 3px 3px 3px; border: 1px solid #E3E2DD;">
                                                                                <table width="100%" border="0" cellpadding="5" cellspacing="0">
                                                                                    <tr>
                                                                                        <td style="background-color: #E3E2DD;">
                                                                                            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(0, true);" onMouseOut="focoRotina(0, false);" width="140" height="22" align="right" id="labelRot0" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(0, true);" onMouseOut="focoRotina(0, false);" width="95" height="22" align="right" id="valueRot0" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(11, true);" onMouseOut="focoRotina(11, false);" width="140" height="22" align="right" id="labelRot11" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(11, true);" onMouseOut="focoRotina(11, false);" width="95" height="22" align="right" id="valueRot11" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(1, true);" onMouseOut="focoRotina(1, false);" width="140" height="22" align="right" id="labelRot1" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(1, true);" onMouseOut="focoRotina(1, false);" width="95" height="22" align="right" id="valueRot1" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(12, true);" onMouseOut="focoRotina(12, false);" width="140" height="22" align="right" id="labelRot12" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(12, true);" onMouseOut="focoRotina(12, false);" width="95" height="22" align="right" id="valueRot12" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(2, true);" onMouseOut="focoRotina(2, false);" width="140" height="22" align="right" id="labelRot2" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(2, true);" onMouseOut="focoRotina(2, false);" width="95" height="22" align="right" id="valueRot2" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(13, true);" onMouseOut="focoRotina(13, false);" width="140" height="22" align="right" id="labelRot13" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(13, true);" onMouseOut="focoRotina(13, false);" width="95" height="22" align="right" id="valueRot13" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(3, true);" onMouseOut="focoRotina(3, false);" width="140" height="22" align="right" id="labelRot3" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(3, true);" onMouseOut="focoRotina(3, false);" width="95" height="22" align="right" id="valueRot3" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(14, true);" onMouseOut="focoRotina(14, false);" width="140" height="22" align="right" id="labelRot14" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(14, true);" onMouseOut="focoRotina(14, false);" width="95" height="22" align="right" id="valueRot14" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(4, true);" onMouseOut="focoRotina(4, false);" width="140" height="22" align="right" id="labelRot4" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(4, true);" onMouseOut="focoRotina(4, false);" width="95" height="22" align="right" id="valueRot4" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(15, true);" onMouseOut="focoRotina(15, false);" width="140" height="22" align="right" id="labelRot15" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(15, true);" onMouseOut="focoRotina(15, false);" width="95" height="22" align="right" id="valueRot15" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(5, true);" onMouseOut="focoRotina(5, false);" width="140" height="22" align="right" id="labelRot5" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(5, true);" onMouseOut="focoRotina(5, false);" width="95" height="22" align="right" id="valueRot5" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(16, true);" onMouseOut="focoRotina(16, false);" width="140" height="22" align="right" id="labelRot16" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(16, true);" onMouseOut="focoRotina(16, false);" width="95" height="22" align="right" id="valueRot16" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(6, true);" onMouseOut="focoRotina(6, false);" width="140" height="22" align="right" id="labelRot6" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(6, true);" onMouseOut="focoRotina(6, false);" width="95" height="22" align="right" id="valueRot6" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(17, true);" onMouseOut="focoRotina(17, false);" width="140" height="22" align="right" id="labelRot17" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(17, true);" onMouseOut="focoRotina(17, false);" width="95" height="22" align="right" id="valueRot17" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(7, true);" onMouseOut="focoRotina(7, false);" width="140" height="22" align="right" id="labelRot7" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(7, true);" onMouseOut="focoRotina(7, false);" width="95" height="22" align="right" id="valueRot7" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(18, true);" onMouseOut="focoRotina(18, false);" width="140" height="22" align="right" id="labelRot18" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(18, true);" onMouseOut="focoRotina(18, false);" width="95" height="22" align="right" id="valueRot18" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(8, true);" onMouseOut="focoRotina(8, false);" width="140" height="22" align="right" id="labelRot8" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(8, true);" onMouseOut="focoRotina(8, false);" width="95" height="22" align="right" id="valueRot8" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(19, true);" onMouseOut="focoRotina(19, false);" width="140" height="22" align="right" id="labelRot19" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(19, true);" onMouseOut="focoRotina(19, false);" width="95" height="22" align="right" id="valueRot19" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(9, true);" onMouseOut="focoRotina(9, false);" width="140" height="22" align="right" id="labelRot9" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(9, true);" onMouseOut="focoRotina(9, false);" width="95" height="22" align="right" id="valueRot9" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(20, true);" onMouseOut="focoRotina(20, false);" width="140" height="22" align="right" id="labelRot20" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(20, true);" onMouseOut="focoRotina(20, false);" width="95" height="22" align="right" id="valueRot20" class="txtNormal">&nbsp;</td>
                                                                                                </tr>																						
                                                                                                <tr>
                                                                                                    <td onMouseOver="focoRotina(10, true);" onMouseOut="focoRotina(10, false);" width="140" height="22" align="right" id="labelRot10" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(10, true);" onMouseOut="focoRotina(10, false);" width="95" height="22" align="right" id="valueRot10" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(21, true);" onMouseOut="focoRotina(21, false);" width="140" height="22" align="right" id="labelRot21" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(21, true);" onMouseOut="focoRotina(21, false);" width="95" height="22" align="right" id="valueRot21" class="txtNormal">&nbsp;</td>
                                                                                                </tr>																						
                                                                                                <tr>																								
																									<td onMouseOver="focoRotina(23, true);" onMouseOut="focoRotina(23, false);" width="140" height="22" align="right" id="labelRot23" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(23, true);" onMouseOut="focoRotina(23, false);" width="95" height="22" align="right" id="valueRot23" class="txtNormal">&nbsp;</td>	
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(22, true);" onMouseOut="focoRotina(22, false);" width="140" height="22" align="right" id="labelRot22" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(22, true);" onMouseOut="focoRotina(22, false);" width="95" height="22" align="right" id="valueRot22" class="txtNormal">&nbsp;</td>
                                                                                                </tr>				
																								<tr>
                                                                                                    <td onMouseOver="focoRotina(24, true);" onMouseOut="focoRotina(24, false);" width="140" height="22" align="right" id="labelRot24" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(24, true);" onMouseOut="focoRotina(24, false);" width="95" height="22" align="right" id="valueRot24" class="txtNormal">&nbsp;</td>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(25, true);" onMouseOut="focoRotina(25, false);" width="140" height="22" align="right" id="labelRot25" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(25, true);" onMouseOut="focoRotina(25, false);" width="95" height="22" align="right" id="valueRot25" class="txtNormal">&nbsp;</td>
                                                                                                </tr>																								
																								<tr>
                                                                                                    <td onMouseOver="focoRotina(26, true);" onMouseOut="focoRotina(26, false);" width="140" height="22" align="right" id="labelRot26" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(26, true);" onMouseOut="focoRotina(26, false);" width="95" height="22" align="right" id="valueRot26" class="txtNormal">&nbsp;</td>
																									<td>&nbsp;</td>
																									<td onMouseOver="focoRotina(27, true);" onMouseOut="focoRotina(27, false);" width="140" height="22" align="right" id="labelRot27" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(27, true);" onMouseOut="focoRotina(27, false);" width="95" height="22" align="right" id="valueRot27" class="txtNormal">&nbsp;</td>
                                                                                                </tr>																								
																								<tr>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td>&nbsp;</td>	
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(28, true);" onMouseOut="focoRotina(28, false);" width="140" height="22" align="right" id="labelRot28" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(28, true);" onMouseOut="focoRotina(28, false);" width="95" height="22" align="right" id="valueRot28" class="txtNormal">&nbsp;</td>
                                                                                                </tr>
																								<tr>
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td>&nbsp;</td>	
                                                                                                    <td>&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(29, true);" onMouseOut="focoRotina(29, false);" width="140" height="22" align="right" id="labelRot29" class="txtNormalBold">&nbsp;</td>
                                                                                                    <td onMouseOver="focoRotina(29, true);" onMouseOut="focoRotina(29, false);" width="95" height="22" align="right" id="valueRot29" class="txtNormal">&nbsp;</td>
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
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</body>
</html>
<script type="text/javascript">

	var nrdconta           = '<? echo $_POST['nrdconta']; ?>';           // Conta que vai vir caso esteja sendo incluida uma nova conta
	var flgcadas           = '<? echo $_POST['flgcadas']; ?>';           // Verificar se esta sendo feito o cadastro da nova conta 
	var executandoProdutos = '<? echo $_POST['executandoProdutos']; ?>'; // Se esta sendo rodada a rotina de Produtos
	var produtosTelasServicos = new Array();							 // Rotinas essencias a serem chamadas via PRODUTOS
	var produtosTelasServicosAdicionais = new Array();	                 // Rotinas adicionais a serem chamadas via PRODUTOS
	var atualizarServicos = [];											 // Lista de produtos a atualizar	
	var flgProdutos        = false; 									 // Verificar se ja entrou na rotina PRODUTOS apos vir da MATRIC/CONTAS
	

	// Variaveis de controle para uso da rotina Produtos	
	if (executandoProdutos == '') {
		var executandoProdutosServicos = false;
		var executandoProdutosServicosAdicionais = false;
		var posicao = 0;	
		executandoProdutos = false;
	} else {
		var essenciais = "<? echo $_POST['produtosTelasServicos']; ?>";
		var adicionais = "<? echo $_POST['produtosTelasServicosAdicionais']; ?>";
		var servicos   = "<? echo $_POST['atualizarServicos']; ?>";	
		
		produtosTelasServicos = essenciais.split("|");
		produtosTelasServicosAdicionais = adicionais.split("|");
		servicos = servicos.split("|");
		
		for (var i= 0; i < servicos.length; i++) {
			
			var servico = servicos[i].split(";");
			
			atualizarServicos.push(
			  {cdproduto       : servico[0],
			   inofertado      : servico[1],
			   inaderido       : servico[2],
			   inadesao_externa: servico[3],
			   dtvencimento    : servico[4]		   
			});
			
		}
			
		var executandoProdutosServicos = (produtosTelasServicos.length > 0);
		var executandoProdutosServicosAdicionais = (produtosTelasServicosAdicionais.length > 0);
		var posicao = '<? echo $_POST['posicao']; ?>';
		executandoProdutos = true;
	}
	
	if (nrdconta != '') {
		 $("#nrdconta","#frmCabAtenda").val(nrdconta);
		 flgProdutos = true;		 
	}

</script>