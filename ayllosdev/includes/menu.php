<?php 

	//************************************************************************//
	//*** Fonte: menu.php                                                  ***//
	//*** Autor: David                                                     ***//
	//*** Data : Julho/2007                   Última Alteração:20/02/2018  ***//
	//***                                                                  ***//
	//*** Objetivo  : Montar menu de serviços                              ***//
	//***                                                                  ***//	 
	//*** Alterações: 15/01/2010 - Deixar tela que foi acessada com a cor  ***//
	//***                          de foco no menu (David).                ***//
	//***                                                                  ***//
	//***             22/10/2010 - Incluir novo parametro para a funcao    ***//
	/***                           getDataXML (David).                     
				
					  26/11/2010 - Incluir campo de acesso direto as telas
								   do sistema (Gabriel).
								   
					  18/07/2011 - Incluir tratamento de alteracao de senha
								   (Gabriel).
					  
					  27/05/2013 - Adicionado verificacao se o arquivo PHP
								   da tela existe antes de por na sessao.
								   (Jorge)
								   
					  03/08/2015 - Reformulacao cadastral (Gabriel-RKAM)	

					  13/08/2015 - Remover o caminho fixo. (James)

					  14/07/2017 - Alteração para o cancelamento manual de produtos. Projeto 364 (Reinert)
                      
                      20/02/2018 - Ajuste para que os nós do menu Permaneçam fechados 
                                   quando acessao via CRM. PRJ399 - CRM(Odirlei-AMcom)
	 ************************************************************************/
	 
	if (isset($glbvars["menu"])) { // Se os itens do menu estão armazenados na sessão, atribui a variável menu
		$menu = $glbvars["menu"];
	} else { // Senão carrega os itens através de BO
		// Monta o xml de requisição
		$xmlGetMenu  = "";
		$xmlGetMenu .= "<Root>";
		$xmlGetMenu .= "	<Cabecalho>";
		$xmlGetMenu .= "		<Bo>b1wgen0000.p</Bo>";
		$xmlGetMenu .= "		<Proc>carrega_menu</Proc>";
		$xmlGetMenu .= "	</Cabecalho>";
		$xmlGetMenu .= "	<Dados>";
		$xmlGetMenu .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlGetMenu .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlGetMenu .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlGetMenu .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
		$xmlGetMenu .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
		$xmlGetMenu .= "		<idsistem>".$glbvars["idsistem"]."</idsistem>";
		$xmlGetMenu .= "	</Dados>";
		$xmlGetMenu .= "</Root>";
            		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlGetMenu,false);
                
                
		
		// Cria objeto para classe de tratamento de XML
		$xmlMenu = getObjectXML($xmlResult);
		
		// Se BO retornou algum erro, atribui crítica a variável $msg
		if (strtoupper($xmlMenu->roottag->tags[0]->name) == "ERRO") {
			redirecionaErro($glbvars["redirect"],$UrlLogin,"_parent",$xmlMenu->roottag->tags[0]->tags[0]->tags[4]->cdata);						
			exit();
		} else {	
			$itensMenu = $xmlMenu->roottag->tags[0]->tags;			
			
			$count = 0;
			for ($i = 0; $i < count($itensMenu); $i++) {
				
				$nmdirfile = dirname(dirname(__FILE__)) . "/telas/".strtolower($itensMenu[$i]->tags[0]->cdata)."/".strtolower($itensMenu[$i]->tags[0]->cdata).".php";
				if(!file_exists($nmdirfile)){
					continue;
				}
				$menu[$count]["NMDATELA"] = $itensMenu[$i]->tags[0]->cdata;
				$menu[$count]["NRMODULO"] = $itensMenu[$i]->tags[1]->cdata;			
				
				$count++;
			}
			
			// Armazenar os itens do menu em variável de sessão			
			setVarSession("menu",$menu);			
		}		
	}	
	
?>	

<form name="frmAcesso" id="frmAcesso">

   <input type="hidden" name="telas" id="telas" value= " <? for ($i = 0; $i < count($menu); $i++) { echo $menu[$i]["NMDATELA"] . ","; }  ?> " >	
   <input type="hidden" name="flgdsenh" id="flgdsenh" value="<? echo $glbvars["flgdsenh"]; ?>" >
   <input type="hidden" name="telatual" id="telatual" value="<? echo $glbvars["nmdatela"]; ?>" >
   <input type="hidden" name="inproces" id="inproces" value="<? echo $glbvars["inproces"]; ?>" >
	 
   <table width="100%" style= "border: 1px solid #ccc;">
	  <tr >
	      <td name="txtNormal">Acesso Tela: </td>
		  <td> <input type="text" class="campoTelaSemBorda" name="tela" id="tela" style= "width:60px;" maxlength="6" disabled /> </td>
		  <td width="4"> </td>
	      <td><input type="image" name="btnAcessoTela" id="btnAcessoTela" src="<?php echo $UrlImagens; ?>/botoes/ok.gif" onClick='carregaTela();return false;' disabled /> </td>																							
      </tr>	 
  </table>
  
</form>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
		
	<tr>
		<td height="23" align="center" nowrap id="tdTitMenu" background="<?php echo $UrlImagens; ?>background/bg_gradiente_dialogo.jpg">&nbsp;Menu Principal&nbsp;</td>
	</tr>
	<tr>
		<td>	
			<div id="divMenu">
			<?php 
				$nrmodulo = 0;
					
				for ($i = 0; $i < count($menu); $i++) { 
					if (in_array($glbvars["nmdatela"],$menu[$i])) {
						$nrModFoco = $menu[$i]["NRMODULO"];
					}
					
					if ($nrmodulo <> $menu[$i]["NRMODULO"]) {
						if ($nrmodulo > 0) {
							echo '</dl></div>';
						}
						
						$nrmodulo = $menu[$i]["NRMODULO"];
						
						switch ($nrmodulo) {
							case  1: $nmmodulo = "Dep&oacute;sitos &agrave; Vista";       break;
							case  2: $nmmodulo = "Capital";                 break;
							case  3: $nmmodulo = "Empr&eacute;stimos";             break;
							case  4: $nmmodulo = "M&oacute;dulo Digita&ccedil;&atilde;o";        break;
							case  5: $nmmodulo = "Cadastros/Consultas";     break;
							case  6: $nmmodulo = "Processos";               break;
							case  7: $nmmodulo = "Par. Conta Corrente";     break;
							case  8: $nmmodulo = "Par. Opera&ccedil;&otilde;es Cr&eacute;dito";  break;
							case  9: $nmmodulo = "Par. Capta&ccedil;&otilde;es";          break;
							case 10: $nmmodulo = "Par. Cobran&ccedil;a";           break;
							case 11: $nmmodulo = "Par. Cart&atilde;o Cr&eacute;d/Seguro"; break;
							case 12: $nmmodulo = "Par. Outros";             break;
							case 13: $nmmodulo = "Solicita&ccedil;&otilde;es/Impress&otilde;es"; break;
							case 14: $nmmodulo = "M&oacute;dulo Gen&eacute;rico";         break;
							case 15: $nmmodulo = "Tarifas"; break;
						}
		
						echo '<span id="spanModMenu'.$nrmodulo.'"><img src="'.$UrlImagens.'geral/open.gif"> <a href="#" onClick="return false;" class="txtNormalBold">'.$nmmodulo,'</a></span>';
						echo '<div id="divModMenu'.$nrmodulo.'"><dl>';
					}
				?>							
				<dt <?php if ($glbvars["nmdatela"] == $menu[$i]["NMDATELA"]) { echo ' style="background-color: #CED0C3;"'; } ?>><img src="<?php echo $UrlImagens; ?>geral/seta.gif" width="9" height="9"> <a href="#" onClick="return false;" class="txtNormalBold"><?php echo $menu[$i]["NMDATELA"]; ?></a></dt>
				<?php
				}
				?>
					</dl>
				</div>		
			</div>
			<?php             
            
                $crm_inacesso = isset($glbvars['CRM_INACESSO']) ? $glbvars['CRM_INACESSO'] : 0;
                $crm_nmdatela = isset($glbvars['CRM_NMDATELA']) ? $glbvars['CRM_NMDATELA'] : 0;
                
            if (isset($nrModFoco) && $crm_inacesso != 1 ) { ?>
			<script type="text/javascript">
			$(document).ready(function() {
				$("#spanModMenu<?php echo $nrModFoco; ?>").css("background-color","#CED0C3");
				$("#spanModMenu<?php echo $nrModFoco; ?>").trigger("click");							
			});
			</script>
			<?php } ?>
			<form action="" method="post" name="frmMenu" id="frmMenu">	
				<input type="hidden" name="nmtelant" id="nmtelant" value="">			
				<input type="hidden" name="nmdatela" id="nmdatela" value="">
				<input type="hidden" name="nmrotina" id="nmrotina" value="">
				<input type="hidden" name="nrdconta" id="nrdconta" value="">
				<input type="hidden" name="redirect" id="redirect" value="html">
				<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; # Variável alimentada no script config.php ?>">
			
				<!-- Variaveis para o cadastro de nova conta (MATRIC , CONTAS , ATENDA) -->
				<input type="hidden" name="flgcadas"                        id="flgcadas" value="C" > 		
				<input type="hidden" name="executandoProdutos"              id="executandoProdutos" value="" > 
				<input type="hidden" name="executandoImpedimentos"          id="executandoImpedimentos" value="" > 
				<input type="hidden" name="produtosCancM"           		id="produtosCancM" value="" > 
				<input type="hidden" name="produtosCancMAtenda"           	id="produtosCancMAtenda" value="" > 
				<input type="hidden" name="produtosCancMContas"           	id="produtosCancMContas" value="" > 
				<input type="hidden" name="produtosCancMCheque"           	id="produtosCancMCheque" value="" > 
				<input type="hidden" name="produtosTelasServicos"           id="produtosTelasServicos" value="" > 
				<input type="hidden" name="produtosTelasServicosAdicionais" id="produtosTelasServicosAdicionais" value="" > 
				<input type="hidden" name="atualizarServicos" 				id="atualizarServicos" value="" > 
				<input type="hidden" name="posicao" 						id="posicao" value="" > 

			</form>
		</td>
	</tr>
</table>

									


