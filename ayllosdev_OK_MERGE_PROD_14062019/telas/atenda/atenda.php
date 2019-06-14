<?php
/*******************************************************************************
 Fonte: atenda.php                                                
 Autor: David                                                     
 Data : Julho/2007                   Última Alteração: 23/11/2018
                                                                  
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

			 12/07/2015 - Adicionado controle de navegação por teclado(ALT/ENTER) - (Evandro - RKAM)	
			 
			 10/03/2017 - Ajuste para incluir a chamada da include alertas_genericos (Adriano - SD 603451).

			 21/03/2017 - Ajuste para incluir o controle mt_rand na chamada do atenda.css (Adriano - SD 603451).

			 28/03/2017 - Ajuste para incluir o controle mt_rand na chamada do funcoes.js (Jonata - RKAM / M294).   
			 
             26/06/2017 - Incluido mt_rand na chamada do script menu.js (Jonata - RKAM P364)
									   
             14/07/2017 - Alteração para o cancelamento manual de produtos. Projeto 364 (Reinert)

			 08/08/2017 - Implementacao da melhoria 438. Heitor (Mouts).

             23/11/2017 - Quando acessado a tela Atenda diretamente pelo CRM nao precisa apresentar produtos
                          PRJ339-CRM(Odirlei-AMcom) 

			 05/12/2017 - Adicionada div divUsoGAROPC para poder chamar a tela GAROPC.
                          Projeto 404 (Lombardi).

             30/05/2018 - Correção de "labelRot32" para "labelRot33". Cláudio (CISCorporate)

			 23/11/2018 - P442 - Inclusao de Score (Thaise-Envolti)

             11/01/2019 - Adicionada modal para selecionar impressão de Documentos quando for pessoa física (Luis Fernando - GFT)

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
        <link href="atenda.css?keyrand=<?php echo mt_rand(); ?>" rel="stylesheet" type="text/css">
        <link rel="stylesheet" href="../../css/base/jquery.ui.all.css">
        <script type="text/javascript" src="../../scripts/scripts.js"></script>
        <script type="text/javascript" src="../../scripts/dimensions.js"></script>
        <script type="text/javascript" src="../../scripts/funcoes.js?keyrand=<?php echo mt_rand(); ?>"></script>
        <script type="text/javascript" src="../../scripts/mascara.js"></script>
        <script type="text/javascript" src="../../scripts/menu.js?keyrand=<?php echo mt_rand(); ?>"></script>
        <script type="text/javascript" src="../../includes/pesquisa/pesquisa.js?keyrand=<?php echo mt_rand(); ?>"></script> <!-- prj 438 - bruno - BUG 17929 -->
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.core.js"></script>
        <script type="text/javascript" src="../../scripts/ui/jquery.ui.datepicker.js"></script>
        <script type="text/javascript" src="../../scripts/ui/i18n/jquery.ui.datepicker-pt-BR.js"></script>
        <script type="text/javascript" src="../../scripts/tooltip.js"></script>
        <script type="text/javascript" src="atenda.js?keyrand=<?php echo mt_rand(); ?>"></script>
		<script type="text/javascript" src="../../scripts/navegacao.js"></script>
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


			div.bloco_full{float:left; width:100%;}
			div.bloco_line{float:left; width:268px; height:22px; text-align:center; position:relative;top:0; overflow:hidden;}
			div.bloco_line a{width:100%;text-align:left;float:left; height:17px;padding-top:5px;padding-left:20%; position:absolute;top:0;left:0;z-index:5;}
			div.bloco_line a:focus {background: rgb(255, 180, 160) !important;}
			div.bloco_line p{width:25%;text-align:right;float:right; height:auto;padding-top:5px;position:absolute;top:0;right:0;z-index:10;background: none !important;}
			div.bloco_line p:focus {background: none !important;}
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

																				<!-- INCLUDE COM AS MENSAGENS GENERICAS -->
                                                                                <? require_once("../../includes/alertas_genericos/alertas_genericos.php"); ?>	

                                                                                <!-- INCLUDE COM AS ANOTACOES -->
                                                                                <? include('anotacoes.php') ?>

                                                                                <!-- INCLUDE COM AS MENSAGEM -->
                                                                                <? include('msg_alerta.php')?>

                                                                                <!-- ROTINA -->
                                                                                <div id="divRotina"></div>
																				<!-- TELA GAROPC -->
																				<div id="divUsoGAROPC"></div>

                                                                                <!-- INCLUDE DO CABECALHO  -->
                                                                                <? include('form_cabecalho.php') ?>							
                                                                            </td>
                                                                        </tr>
																		
                                                                        <tr>																
                                                                            <td style="padding: 3px 3px 3px 3px; border: 1px solid #E3E2DD;">
                                                                                <table width="100%" border="0" cellpadding="5" cellspacing="0">
                                                                                    <tr>
                                                                                        <td style="background-color:#E3E2DD;">
																						
																						  <div class="bloco_full"> 

																							<div class="bloco_line" onMouseOver="focoRotina(0, true);" onMouseOut="focoRotina(0, false);">
																								<a tabindex="7" name="7" class="txtNormalBold SetFocus" id="labelRot0">&nbsp;</a>
																								<p id="valueRot0" class="txtNormal">&nbsp;</p>
																							</div>
																							<div class="bloco_line" onMouseOver="focoRotina(11, true);" onMouseOut="focoRotina(11, false);">

																								<a tabindex="8" name="8" class="txtNormalBold SetFocus" id="labelRot11" >&nbsp;</a>
																								<p id="valueRot11" class="txtNormal">&nbsp;</p>
																						    </div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(1, true);" onMouseOut="focoRotina(1, false);">
																						     <a tabindex="9" name="9" class="txtNormalBold SetFocus" id="labelRot1">&nbsp;</a>
																						     <p id="valueRot1" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(12, true);" onMouseOut="focoRotina(12, false);">
																						     <a tabindex="10" name="10" class="txtNormalBold SetFocus" id="labelRot12">&nbsp;</a>
																						     <p id="valueRot12" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(2, true);" onMouseOut="focoRotina(2, false);">
																						     <a tabindex="11" name="11" class="txtNormalBold SetFocus" id="labelRot2">&nbsp;</a>
																						     <p id="valueRot2" class="txtNormal" >&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(13, true);" onMouseOut="focoRotina(13, false);">
																						     <a tabindex="12" name="12" class="txtNormalBold SetFocus" id="labelRot13">&nbsp;</a>
																						     <p id="valueRot13" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(3, true);" onMouseOut="focoRotina(3, false);">
																						     <a tabindex="13" name="13" class="txtNormalBold SetFocus" id="labelRot3">&nbsp;</a>
																						     <p id="valueRot3" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(14, true);" onMouseOut="focoRotina(14, false);">
																						     <a tabindex="14" name="14" class="txtNormalBold SetFocus" id="labelRot14">&nbsp;</a>
																						     <p id="valueRot14" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(4, true);" onMouseOut="focoRotina(4, false);">
																						     <a tabindex="15" name="15" class="txtNormalBold SetFocus" id="labelRot4">&nbsp;</a>
																						     <p id="valueRot4" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(15, true);" onMouseOut="focoRotina(15, false);">
																						     <a tabindex="16" name="16" class="txtNormalBold SetFocus" id="labelRot15">&nbsp;</a>
																						     <p id="valueRot15" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(5, true);" onMouseOut="focoRotina(5, false);">
																						     <a tabindex="17" name="17" class="txtNormalBold SetFocus" id="labelRot5">&nbsp;</a>
																						     <p id="valueRot5" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(16, true);" onMouseOut="focoRotina(16, false);">
																						     <a tabindex="18" name="18" class="txtNormalBold SetFocus" id="labelRot16">&nbsp;</a>
																						     <p id="valueRot16" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(6, true);" onMouseOut="focoRotina(6, false);">
																						     <a tabindex="19" name="19" class="txtNormalBold SetFocus" id="labelRot6">&nbsp;</a>
																						     <p id="valueRot6" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(17, true);" onMouseOut="focoRotina(17, false);">
																						     <a tabindex="20" name="20" class="txtNormalBold SetFocus" id="labelRot17">&nbsp;</a>
																						     <p id="valueRot17" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(7, true);" onMouseOut="focoRotina(7, false);">
																						     <a tabindex="21" name="21" class="txtNormalBold SetFocus" id="labelRot7">&nbsp;</a>
																						     <p id="valueRot7" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(18, true);" onMouseOut="focoRotina(18, false);">
																						     <a tabindex="22" name="22" class="txtNormalBold SetFocus" id="labelRot18">&nbsp;</a>
																						     <p id="valueRot18" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(8, true);" onMouseOut="focoRotina(8, false);">
																						     <a tabindex="23" name="23" class="txtNormalBold SetFocus" id="labelRot8">&nbsp;</a>
																						     <p id="valueRot8" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(19, true);" onMouseOut="focoRotina(19, false);">
																						     <a tabindex="24" name="24" class="txtNormalBold SetFocus" id="labelRot19">&nbsp;</a>
																						     <p id="valueRot19" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(9, true);" onMouseOut="focoRotina(9, false);">
																						     <a tabindex="25" name="25" class="txtNormalBold SetFocus" id="labelRot9">&nbsp;</a>
																						     <p id="valueRot9" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(20, true);" onMouseOut="focoRotina(20, false);">
																						     <a tabindex="26" name="26" class="txtNormalBold SetFocus" id="labelRot20">&nbsp;</a>
																						     <p id="valueRot20" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 
																						    <div class="bloco_line" onMouseOver="focoRotina(10, true);" onMouseOut="focoRotina(10, false);">

																						     <a tabindex="27" name="27" class="txtNormalBold SetFocus" id="labelRot10" onMouseOver="focoRotina(10, true);" onMouseOut="focoRotina(10, false);">&nbsp;</a>
																						     <p id="valueRot10" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(21, true);" onMouseOut="focoRotina(21, false);">
																						     <a tabindex="28" name="28" class="txtNormalBold SetFocus" id="labelRot21">&nbsp;</a>
																						     <p id="valueRot21" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(23, true);" onMouseOut="focoRotina(23, false);">
																						     <a tabindex="29" name="29" class="txtNormalBold SetFocus" id="labelRot23">&nbsp;</a>
																						     <p id="valueRot23" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(22, true);" onMouseOut="focoRotina(22, false);">
																						     <a tabindex="30" name="30" class="txtNormalBold SetFocus" id="labelRot22">&nbsp;</a>
																						     <p id="valueRot22" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(24, true);" onMouseOut="focoRotina(24, false);">
																						     <a tabindex="31" name="31" class="txtNormalBold SetFocus" id="labelRot24">&nbsp;</a>
																						     <p id="valueRot24" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(25, true);" onMouseOut="focoRotina(25, false);">
																						     <a tabindex="32" name="32" class="txtNormalBold SetFocus" id="labelRot25">&nbsp;</a>
																						     <p id="valueRot25" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full"> 

																						    <div class="bloco_line" onMouseOver="focoRotina(26, true);" onMouseOut="focoRotina(26, false);">
																						     <a tabindex="33" name="33" class="txtNormalBold SetFocus" id="labelRot26">&nbsp;</a>
																						     <p id="valueRot26" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(27, true);" onMouseOut="focoRotina(27, false);">
																						     <a tabindex="34" name="34" class="txtNormalBold SetFocus" id="labelRot27">&nbsp;</a>
																						     <p id="valueRot27" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  
																						  <div class="bloco_full">

																						    <div class="bloco_line" onMouseOver="focoRotina(28, true);" onMouseOut="focoRotina(28, false);">
																						     <a tabindex="35" name="35" class="txtNormalBold SetFocus" id="labelRot28">&nbsp;</a>
																						     <p id="valueRot28" class="txtNormal">&nbsp;</p>
																							</div>

																						    <div class="bloco_line" onMouseOver="focoRotina(29, true);" onMouseOut="focoRotina(29, false);">
																						     <a tabindex="36" name="36" class="txtNormalBold SetFocus" id="labelRot29">&nbsp;</a>
																						     <p id="valueRot29" class="txtNormal">&nbsp;</p>
																							</div>																						    
																						  </div>
																						  
																						  
																						  <div class="bloco_full">

																						    <div class="bloco_line" onMouseOver="focoRotina(30, true);" onMouseOut="focoRotina(30, false);">
																						     <a tabindex="37" name="37" class="txtNormalBold SetFocus" id="labelRot30">&nbsp;</a>
																						     <p id="valueRot30" class="txtNormal">&nbsp;</p>
																							</div>
																							
																							<div class="bloco_line" onMouseOver="focoRotina(31, true);" onMouseOut="focoRotina(31, false);">
																						     <a tabindex="38" name="38" class="txtNormalBold SetFocus" id="labelRot31">&nbsp;</a>
																						     <p id="valueRot31" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  																
																						  <div class="bloco_full">

																						    <div class="bloco_line" onMouseOver="focoRotina(32, true);" onMouseOut="focoRotina(32, false);">
																						     <a tabindex="39" name="39" class="txtNormalBold SetFocus" id="labelRot32">&nbsp;</a>
																						     <p id="valueRot32" class="txtNormal">&nbsp;</p>
																							</div>
																							
																							<div class="bloco_line" onMouseOver="focoRotina(33, true);" onMouseOut="focoRotina(33, false);">
																						     <a tabindex="40" name="40" class="txtNormalBold SetFocus" id="labelRot33">&nbsp;</a>
																						     <p id="valueRot33" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  																
																						  <div class="bloco_full">

																						    <div class="bloco_line" onMouseOver="focoRotina(34, true);" onMouseOut="focoRotina(34, false);">
																						     <a tabindex="41" name="41" class="txtNormalBold SetFocus" id="labelRot34">&nbsp;</a>
																						     <p id="valueRot34" class="txtNormal">&nbsp;</p>
																							</div>
																							
																							<div class="bloco_line" onMouseOver="focoRotina(35, true);" onMouseOut="focoRotina(35, false);">
																						     <a tabindex="42" name="42" class="txtNormalBold SetFocus" id="labelRot35">&nbsp;</a>
																						     <p id="valueRot35" class="txtNormal">&nbsp;</p>
																							</div>
																						  </div>
																						  																
																						  <div class="bloco_full">

																						    <div class="bloco_line" onMouseOver="focoRotina(36, true);" onMouseOut="focoRotina(36, false);">
																						     <a tabindex="43" name="43" class="txtNormalBold SetFocus" id="labelRot36">&nbsp;</a>
																						     <p id="valueRot36" class="txtNormal">&nbsp;</p>
																							</div>
																							
																							<div class="bloco_line" onMouseOver="focoRotina(37, true);" onMouseOut="focoRotina(37, false);">
																						     <a tabindex="44" name="44" class="txtNormalBold SetFocus" id="labelRot37">&nbsp;</a>
																						     <p id="valueRot37" class="txtNormal">&nbsp;</p>
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
				</td>
			</tr>
		</table>
        <div id="rotinaDocumentos" style="display:none">
            <input type="hidden" value="<?=$GEDServidor?>"/>
            <table cellpadding="0" cellspacing="0" border="0" width="100%" id="">
                <tr>
                    <td align="center">     
                        <table border="0" cellpadding="0" cellspacing="0" width="350">
                            <tr>
                                <td>
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                            <td id="<?php echo $labelRot; ?>" id="tdTitRotina" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">DOCUMENTOS</td>
                                            <td width="12" id="tdTitTela" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(false);return false;"><img src="<?echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                            <td width="8"><img src="<?echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                                        </tr>
                                    </table>     
                                </td> 
                            </tr>    
                            <tr>
                                <td class="tdConteudoTela" align="center" id="tdConteudoOpcoes">    
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                                <div id="divConteudoOpcao" style="height: 80px;">
                                                    <!-- Botoes Titulos e Cheque -->
                                                    
                                                    <div id="divBotoes" style="height:80px;width:435px;">
                                                        <input class="botao"  type="button" style="margin: 20px 10px 0 0;" onClick="dossieDigdoc(9); return false;" value="Cart&atilde;o de Assinatura"/>
                                                        <input class="botao"  type="button" style="margin: 20px 10px 0 0;" onClick="dadosCadastraisDigdoc();return false;" value="Documento de Identifica&ccedil;&atilde;o - PF"/>
                                                    </div>
                                                    
                                                    <!--Botoes Titulos e Cheques -->
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
        </div>
	</body>
</html>

<?
    $crm_inacesso = isset($glbvars['CRM_INACESSO']) ? $glbvars['CRM_INACESSO'] : 0;
    $crm_nmdatela = isset($glbvars['CRM_NMDATELA']) ? $glbvars['CRM_NMDATELA'] : 0;

?>

<script type="text/javascript">

	var nrdconta           = '<? echo $_POST['nrdconta']; ?>';           // Conta que vai vir caso esteja sendo incluida uma nova conta
	var flgcadas           = '<? echo $_POST['flgcadas']; ?>';           // Verificar se esta sendo feito o cadastro da nova conta 
	var executandoProdutos = '<? echo $_POST['executandoProdutos']; ?>'; // Se esta sendo rodada a rotina de Produtos
	var executandoImpedimentos = '<? echo $_POST['executandoImpedimentos']; ?>'; // Se esta sendo rodada a rotina de Impedimentos
	var nmtelant = '<? echo $_POST['nmtelant']; ?>'; 					 // Nome da tela anterior chamadora
	var produtosTelasServicos = new Array();							 // Rotinas essencias a serem chamadas via PRODUTOS
	var produtosTelasServicosAdicionais = new Array();	                 // Rotinas adicionais a serem chamadas via PRODUTOS
	var produtosCancM = new Array();	                 				 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
	var produtosCancMAtenda = new Array();	                 			 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
	var produtosCancMContas = new Array();	                 			 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
	var produtosCancMCheque = new Array();	                 			 // Rotinas adicionais a serem chamadas via CONTAS/IMPEDIMENTOS
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
	
	if (executandoImpedimentos){
		var produtos =  "<? echo $_POST['produtosCancM']; ?>";
		var produtosAtenda = "<? echo $_POST['produtosCancMAtenda']; ?>";
		var produtosContas = "<? echo $_POST['produtosCancMContas']; ?>";
		var produtosCheque = "<? echo $_POST['produtosCancMCheque']; ?>";
		var posicao = '<? echo $_POST['posicao']; ?>';
		produtosCancM = produtos.split("|");		
		produtosCancMAtenda = produtosAtenda.split("|");
		produtosCancMContas = produtosContas.split("|");
		produtosCancMCheque = produtosCheque.split("|");
	}

	var CRM_INACESSO =  <? echo $crm_inacesso; ?>;
    var CRM_NMDATELA = '<? echo $crm_nmdatela; ?>';

	if (nrdconta != '' && executandoImpedimentos == '') {
		 $("#nrdconta","#frmCabAtenda").val(nrdconta);

         // Quando acessado a tela Atenda diretamente pelo CRM nao precisa apresentar produtos
         if (CRM_INACESSO == 1 && CRM_NMDATELA.toUpperCase() == 'ATENDA'){
            flgProdutos = false;		  
         }else{
		   flgProdutos = true;		 
         }
	} else if (nrdconta != '' && executandoImpedimentos) {
		$("#nrdconta","#frmCabAtenda").val(nrdconta);		
	}
</script>
