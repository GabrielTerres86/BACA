<?php 

	/****************************************************************
	 Fonte: principal.php                                            
	 Autor: David                                                    
	 Data : Junho/2008                   Última Alteração: 26/07/2016
	                                                                 
	 Objetivo  : Mostrar opcao Principal da rotina de Internet da    
	             tela ATENDA                                         
	                                                                  
	 Alteraçães: 03/09/2009 - Melhorias na rotina de Internet (David)
	                                                                 
	             22/04/2010 - Alterar função para acionar opção de   
	                          cancelamento (David).                  
	                                                                 
	             22/10/2010 - Alterar controle de permissão no botoes
	                          das operações (David).                 
	                                                                      
	             08/07/2011 - Atribuido um id para o botao Liberacao 
	                          e um id para o campo que mostra o      
                              valor contido em dssitsnh (Fabricio)   
	                                                                      
	             14/07/2011 - Alterado para layout padrão                 
	                          (Gabriel - DB1)                          
	                                                                  
	             01/05/2012 - Projeto TED Internet (Lucas).          
	                                                                  
	             09/07/2012 - Retirado campo "redirect" popup (Jorge)
	                                                                  
	             07/11/2012 - Permitir atualização das Letras de	 	 
			  				   Segurança juntamente com a Senha da   	 
							   Internet (Lucas).                     	 
	                                                                 
				  11/11/2012 - Incluso novos campos dtlimtrf dtlimpgo
							   dtlimted dtlimweb e alterado layout 	 
							   tela (Daniel).						 		
																	 
			      11/01/2013 - Requisitar cadastro de Letras ao      
	                          entregar cartao (Lucas).  			 
																	 
				  22/04/2013 - Incluido novos campos referente ao    
                              cadastro de limites Vr Boleto          
      						   (David Kruger)						 
	              													 
				  02/08/2013 - Alterado layout de Internet, adicionado 
							   campo "Data Bloqueio Senha". (Jorge)    
																	   
				  12/02/2015 - Alterado onclick do form divNumericaLetras
							   opcao voltar para voltar para a tela    
							   principal (Lucas R. #252985)			   
				  16/09/2015 - Projeto 217 - Reformulacao Cadastral	   
				  			   (Tiago Castro - RKAM)
	
	              01/10/2015 - Ajuste para inclusão das novas telas "Produtos"
						      (Gabriel - Rkam -> Projeto 217).

				  17/11/2015 - Implementação de nova tela para contas PJ que
							   exigem assinatura conjunta, Prj. Ass. Conjunta (Jean Michel).						  

				  26/07/2016 - Corrigi a acao do botao voltar em tela e a forma de recuperacao
							   dos dados do XML. SD 479874 (Carlos R.)

          
				  30/08/2016 - Adição dos campos de data e hora de acesso ao Mobile (Dionathan).

				  05/04/2018 - Chamada rotina "validaAdesaoProduto" para verificar se tipo de 
                               conta permite a contratação do produto. PRJ366 (Lombardi).

	*******************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
		
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}
	
	$nrdconta = $_POST["nrdconta"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisição
	$xmlGetTitulares  = "";
	$xmlGetTitulares .= "<Root>";
	$xmlGetTitulares .= "	<Cabecalho>";
	$xmlGetTitulares .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetTitulares .= "		<Proc>obtem-dados-titulares</Proc>";
	$xmlGetTitulares .= "	</Cabecalho>";
	$xmlGetTitulares .= "	<Dados>";
	$xmlGetTitulares .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetTitulares .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetTitulares .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetTitulares .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetTitulares .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetTitulares .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetTitulares .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetTitulares .= "		<idseqttl>1</idseqttl>";
	$xmlGetTitulares .= "	</Dados>";
	$xmlGetTitulares .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetTitulares);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjTitulares = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjTitulares->roottag->tags[0]->name) && strtoupper($xmlObjTitulares->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTitulares->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$inpessoa    = ( isset($xmlObjTitulares->roottag->tags[0]->attributes["INPESSOA"]) ) ? $xmlObjTitulares->roottag->tags[0]->attributes["INPESSOA"] : '';
	$idastcjt    = ( isset($xmlObjTitulares->roottag->tags[0]->attributes["IDASTCJT"]) ) ? $xmlObjTitulares->roottag->tags[0]->attributes["IDASTCJT"] : '';
	$titulares   = ( isset($xmlObjTitulares->roottag->tags[1]->tags) ) ? $xmlObjTitulares->roottag->tags[1]->tags : array();
	$qtTitulares = count($titulares);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
?>

<script type="text/javascript">var metodoBlock = "blockBackground(parseInt($('#divRotina').css('z-index')))";</script>

<div id="divInternetPrincipal">
  <div class="divRegistros">
    <table>
      <thead>
        <tr>
          <?php
						if($idastcjt == 1 && $inpessoa == 2){
					?>
          <th>CPF</th>
          <th>Respons&aacute;vel Assinatura Conjunta</th>
          <th style="width: 107px;">Tipo</th>
          <?php
						} else if(($inpessoa == 2 || $inpessoa == 3) && $idastcjt == 0){
					?>
          <th>CPF</th>
          <th>Titular</th>
          <th style="width: 107px;">Tipo</th>
		  <?php
						}else{
					?>
          <th>Sequ&ecirc;ncia</th>
          <th>Titular</th>
          <?php
						}
					?>
        </tr>
      </thead>
      <tbody>
        <?  					
					for ($i = 0; $i < $qtTitulares; $i++) { 
										
						$mtdClick = "selecionaTitularInternet('".($i + 1)."',".$qtTitulares.",'".formatar(str_pad($titulares[$i]->tags[14]->cdata,11,"0",STR_PAD_LEFT),'cpf',true)."','".$idastcjt."','".$titulares[$i]->tags[0]->cdata."', '".$titulares[$i]->tags[0]->cdata."', ".$titulares[$i]->tags[14]->cdata.");";
					?>
					<tr id="trTitInternet<?php echo ($i + 1); ?>" onFocus="<? echo $mtdClick; ?>" onClick="<? echo $mtdClick; ?>">
						<?php
							if($idastcjt == 1 || ($inpessoa == 2 || $inpessoa == 3)){
						?>
						<td><?php echo formatar(str_pad($titulares[$i]->tags[14]->cdata,11,"0",STR_PAD_LEFT),'cpf',true); ?></td>
          <?php
						}else{
					?>
					<td><?php echo $titulares[$i]->tags[0]->cdata; ?></td>
          <?php
						}
					?>
						<td><?php echo $titulares[$i]->tags[1]->cdata; ?></td>
						<?php
						if ($idastcjt == 1 || ($inpessoa == 2 || $inpessoa == 3)){
						?>							
							<td>
								<?php
									if ($titulares[$i]->tags[0]->cdata == 999){
										echo 'OPERADOR';
									}else{
										echo 'PREPOSTO';
									}
								?>
							</td>
						<?php
						}
						?>
        </tr>
        <?} // Fim do for ?>
      </tbody>
    </table>
  </div>

    <?php
		if($idastcjt == 1 || ($inpessoa == 2 || $inpessoa == 3)){
	?>
	<form class="formulario" style="width: 560px; display: block;">
		<fieldset>
			<legend><span id="preoroper">PREPOSTO</span> (CPF:<span id="spanSeqTitular"><?php echo formatar(str_pad($titulares[0]->tags[14]->cdata,11,"0",STR_PAD_LEFT),'cpf',true); ?></span>)</legend>						
			
			<?php
			
				for ($i = 0; $i < $qtTitulares; $i++) {
					
					$temp_vllimtrf = 0;
					$temp_vllimpgo = 0;
					$temp_vllimted = 0;
					$temp_vllimvrb = 0;
					$temp_vllimpgo = 0;
					
					if ($titulares[$i]->tags[0]->cdata != 999 && $idastcjt == 1){	// idseqttl diferente de 999 são preposto, carregados da tabela TBCC_LIMITE_PREPOSTO
						$xml  = "";
						$xml .= "<Root>";
						$xml .= "	<Dados>";
						$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
						$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
						$xml .= "		<nrcpf>".$titulares[$i]->tags[14]->cdata."</nrcpf>";
						$xml .= "	</Dados>";
						$xml .= "</Root>";	

						$xmlResultPreposto = mensageria($xml, "ATENDA", "BUSCA_LIMITES_PREPOSTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
						$xmlObjPreposto = simplexml_load_string($xmlResultPreposto);
						//var_dump($xmlObjPreposto->preposto['pr_vllimite_transf']);exit;
						
						//foreach ($xmlObjPreposto->preposto as $row){
							
							//print_r($row);
							
							$temp_vllimtrf = number_format(str_replace(",",".",$xmlObjPreposto->preposto->pr_vllimite_transf),2,",",".");
							$temp_vllimpgo = number_format(str_replace(",",".",$xmlObjPreposto->preposto->pr_vllimite_pagto),2,",",".");
							$temp_vllimted = number_format(str_replace(",",".",$xmlObjPreposto->preposto->pr_vllimite_ted),2,",",".");
							$temp_vllimvrb = number_format(str_replace(",",".",$xmlObjPreposto->preposto->pr_vllimite_vrboleto),2,",",".");
							$temp_vllimfol = number_format(str_replace(",",".",$xmlObjPreposto->preposto->pr_vllimite_folha),2,",",".");
						//}
					}else{ // operadores
							if(($inpessoa == 2 and $inpessoa == 3)  and $idastcjt == 0){
								$temp_vllimtrf = number_format(str_replace(",",".",$titulares[$i]->tags[12]->cdata),2,",",".");
								$temp_vllimpgo = number_format(str_replace(",",".",$titulares[$i]->tags[11]->cdata),2,",",".");
								$temp_vllimted = number_format(str_replace(",",".",$titulares[$i]->tags[15]->cdata),2,",",".");
								$temp_vllimvrb = number_format(str_replace(",",".",$titulares[$i]->tags[20]->cdata),2,",",".");
								$temp_vllimfol = number_format(str_replace(",",".",((getByTagName($titulares[$i]->tags,'VLLIMFLP')==0) ? '0,00' : getByTagName($titulares[$i]->tags,'VLLIMFLP'))),2,",",".");
							} else {
								$temp_vllimtrf = number_format(str_replace(",",".",$titulares[$i]->tags[12]->cdata),2,",",".");
								$temp_vllimfol = number_format(str_replace(",",".",((getByTagName($titulares[$i]->tags,'VLLIMFLP')==0) ? '0,00' : getByTagName($titulares[$i]->tags,'VLLIMFLP'))),2,",",".");
								$temp_vllimted = number_format(str_replace(",",".",$titulares[$i]->tags[15]->cdata),2,",",".");
								$temp_vllimvrb = number_format(str_replace(",",".",$titulares[$i]->tags[20]->cdata),2,",",".");
								$temp_vllimpgo = number_format(str_replace(",",".",$titulares[$i]->tags[11]->cdata),2,",",".");
							}
					}
			?>
				<div id="divTitInternetOpe<?php echo ($i + 1); ?>" style="display: none;" >
					<label style="width: 130px;" for="vllimtrf"><? echo utf8ToHtml('Vlr.Limite/Dia Transf:')?></label>
					<input class="campoTelaSemBorda" style="width: 130px;" readonly type="text" id="vllimtrf" value="<?php echo $temp_vllimtrf; ?>" />
					<label style="width: 130px;" for="vllimpgo"><? echo utf8ToHtml('Vlr.Limite/Dia Pagto:') ?></label>
					<input class="campoTelaSemBorda" style="width: 130px;" readonly type="text" id="vllimpgo" value="<?php echo $temp_vllimpgo; ?>" />
					<br />
					<br />
					<label style="width: 130px;" for="vllimted"><? echo utf8ToHtml('Vlr.Limite/Dia TED:') ?></label>
					<input class="campoTelaSemBorda" style="width: 130px;" readonly type="text" id="vllimted" value="<?php echo $temp_vllimted; ?>" />
					<label style="width: 130px;" for="vllimvrb"><? echo utf8ToHtml('Vlr.Limite VR Boleto:') ?></label>
					<input class="campoTelaSemBorda" style="width: 130px;" readonly type="text" id="vllimvrb" value="<?php echo $temp_vllimvrb; ?>" />
					<br />
					<br />
					<label style="width: 130px;" for="vllimfol"><? echo utf8ToHtml('Vlr.Limite Folha Pagto:') ?></label>
					<input class="campoTelaSemBorda" style="width: 130px;" readonly type="text" id="vllimfol" value="<?php echo $temp_vllimfol; ?>" />
				</div>
			<?php
				}
			?>
		</fieldset>
	</form>
	<?php
		}
	?>

	<form action="" method="post" name="frmDadosTitInternet" id="frmDadosTitInternet">
    <fieldset>
      <?php
				if($idastcjt == 1){
			?>
					<legend>Acesso &agrave; Conta Corrente Via Internet <!--(CPF:<span id="spanSeqTitular"><?php echo formatar(str_pad($titulares[0]->tags[14]->cdata,11,"0",STR_PAD_LEFT),'cpf',true); ?></span>)--></legend>						
      <?php
				}else{
			?>
					<legend>Acesso &agrave; Conta Corrente Via Internet (<span id="spanSeqTitular">1</span> Titular)</legend>
      <?php
			
				}			
			
				for ($i = 0; $i < $qtTitulares; $i++) { ?>


				<div id="divTitInternet<?php echo ($i + 1); ?>" style="display: <?php echo (($i==0) ?'block':'none'); ?>;" >						

					<label id="dssitsnh" for="dssitsnh<?php echo ($i + 1);?>"><? echo utf8ToHtml('Situação:') ?></label>
					<input id="dssitsnh<?php echo ($i + 1);?>" name="dssitsnh" type="text" value="<?php echo $titulares[$i]->tags[3]->cdata; ?>" />

        <? if ($inpessoa == "2") { 
							if($idastcjt != "1"){?>
								<br />
								<label for="nmprepos"><? echo utf8ToHtml('Preposto:') ?></label>
        <input type="text" id="nmprepos" value="<?php echo $titulares[$i]->tags[2]->cdata; ?>" />
        <? 		}
						} ?>
					
					<? if ($inpessoa == "1") { ?>
					
						<br />
						<label for="vllimweb"><? echo utf8ToHtml('Valor Limite/Dia:') ?></label>
        <input type="text" id="vllimweb" value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[11]->cdata),2,",","."); ?>" />

						<label for="dtlimweb"><? echo utf8ToHtml('Dt.Alter.Limite/Dia:') ?></label>
        <input type="text" id="dtlimweb" value="<?php echo $titulares[$i]->tags[16]->cdata; ?>" />

						<label for="vllimted"><? echo utf8ToHtml('Vlr.Limite/Dia TED:') ?></label>
        <input type="text" id="vllimted" value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[15]->cdata),2,",","."); ?>" />

						<label for="dtlimted"><? echo utf8ToHtml('Dt.Alter.Limite/Dia TED:') ?></label>
        <input type="text" id="dtlimted" value="<?php echo $titulares[$i]->tags[17]->cdata; ?>" />

						<label for="vllimvrb"><? echo utf8ToHtml('Limite VR Boleto:') ?></label>
        <input type="text" id="vllimvrb" value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[20]->cdata),2,",","."); ?>" />

						<label for="dtlimvrb"><? echo utf8ToHtml('Dt.Alter.Limite Vr Boleto:') ?></label>
        <input type="text" id="dtlimvrb" value="<?php echo $titulares[$i]->tags[21]->cdata; ?>" />

        <? } ?>
																	
					<? if ($inpessoa == "2") { ?>
					
						<br />
        <br />

						<label for="vllimtrf"><? echo utf8ToHtml('Vlr.Limite/Dia Transf:') ?></label>
        <input type="text" id="vllimtrf" readonly value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[12]->cdata),2,",","."); ?>" />

						<label for="dtlimtrf"><? echo utf8ToHtml('Dt.Alter.Limite/Dia Transf:') ?></label>
        <input type="text" id="dtlimtrf" readonly value="<?php echo $titulares[$i]->tags[19]->cdata; ?>" />

						<label for="vllimpgo"><? echo utf8ToHtml('Vlr.Limite/Dia Pagto:') ?></label>
        <input type="text" id="vllimpgo" readonly value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[13]->cdata),2,",","."); ?>" />

						<label for="dtlimpgo"><? echo utf8ToHtml('Dt.Alter.Limite/Dia Pagto:') ?></label>
        <input type="text" id="dtlimpgo" readonly value="<?php echo $titulares[$i]->tags[18]->cdata; ?>" />

						<label for="vllimted"><? echo utf8ToHtml('Vlr.Limite/Dia TED:') ?></label>
        <input type="text" id="vllimted" readonly value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[15]->cdata),2,",","."); ?>" />

						<label for="dtlimted"><? echo utf8ToHtml('Dt.Alter.Limite/Dia TED:') ?></label>
        <input type="text" id="dtlimted" readonly value="<?php echo $titulares[$i]->tags[17]->cdata; ?>" />

						<label for="vllimvrb"><? echo utf8ToHtml('Vlr.Limite VR Boleto:') ?></label>
        <input type="text" id="vllimvrb" readonly value="<?php echo number_format(str_replace(",",".",$titulares[$i]->tags[20]->cdata),2,",","."); ?>" />

						<label for="dtlimvrb"><? echo utf8ToHtml('Dt.Alter.Limite Vr Boleto:') ?></label>
        <input type="text" id="dtlimvrb" readonly value="<?php echo $titulares[$i]->tags[21]->cdata; ?>" />
        <br />

        <? } ?>
					
        <br />

					<label for="dtlibera"><? echo utf8ToHtml('Data Liberação:') ?></label>
					<input type="text" id="dtlibera" value="<?php echo $titulares[$i]->tags[4]->cdata.' '.$titulares[$i]->tags[5]->cdata; ?>" />

					<label for="dtblutsh"><? echo utf8ToHtml('Data Bloqueio Senha:') ?></label>
					<input type="text" id="dtblutsh" value="<?php echo $titulares[$i]->tags[22]->cdata; ?>" />
        <br />

					<label for="dtaltsit"><? echo utf8ToHtml('Data Alteração Situação:') ?></label>
        <input type="text" id="dtaltsit" value="<?php echo $titulares[$i]->tags[7]->cdata; ?>" />

					<label for="dtaltsnh"><? echo utf8ToHtml('Data Alteração Senha:') ?></label>
        <input type="text" id="dtaltsnh" value="<?php echo $titulares[$i]->tags[6]->cdata; ?>" />
					<br style="clear: both;"/>
					
					<fieldset>
					<legend align="left" style="font-weight: bold;"><? echo utf8ToHtml('Data do Último Acesso:') ?></legend>
						<label for="dtultace"><? echo utf8ToHtml('Conta Online:') ?></label>
						<input type="text" id="dtultace" value="<?php echo trim($titulares[$i]->tags[8]->cdata) == "" ? null : $titulares[$i]->tags[8]->cdata.' '.$titulares[$i]->tags[9]->cdata; ?>" />

						<label for="dtacemob"><? echo utf8ToHtml('Ailos Mobile:') ?></label>
						<input type="text" id="dtacemob" value="<?php echo trim($titulares[$i]->tags[23]->cdata) == "" ? null : $titulares[$i]->tags[23]->cdata.' '.$titulares[$i]->tags[24]->cdata; ?>" />
					</fieldset>

        <!--
					<label for="nmoperad"><? /*echo utf8ToHtml('Operador:') */?></label>
					<input type="text" id="nmoperad" value="<? /*php echo $titulares[$i]->tags[10]->cdata; */?>" />
					<br />
					--->
      </div>
      <? } ?>
			
    </fieldset>
  </form>
  <div id="divBotoes">
		<!-- JMD --><input type="image" id="btnVoltarOpcao" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"  >
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/bloqueio.gif" <?php if (in_array("B",$glbvars["opcoesTela"])) { ?>onClick="showConfirmacao('Deseja bloquear a senha de acesso &agrave; internet?','Confirma&ccedil;&atilde;o - Aimaro','bloqueiaSenhaAcesso()',metodoBlock,'sim.gif','nao.gif');return false;"<?php } else { ?>style="cursor: default;" onClick="return false;"<?php } ?> />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelamento.gif" <?php if (in_array("X",$glbvars["opcoesTela"])) { ?>onClick="cancelaSenhaAcesso(1);return false;"<?php } else { ?>style="cursor: default;" onClick="return false;"<?php } ?> />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/impressao.gif" <?php if (in_array("M",$glbvars["opcoesTela"])) { ?>onClick="carregarContrato('','yes');return false;"<?php } else { ?>style="cursor: default;" onClick="return false;"<?php } ?> />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/senha.gif" <?php if (in_array("S",$glbvars["opcoesTela"])) { ?>onClick="mostraDivAlteraSenha();return false;"<?php } else {?>style="cursor: default;" onClick="return false;"<?php } ?> />
    <input id="liberacao"   type="image" src="<?php echo $UrlImagens; ?>botoes/liberacao.gif" <?php if (in_array("L",$glbvars["opcoesTela"])) { ?>onClick="validaAdesaoProduto(<?php echo $nrdconta ?>, 1, 'mostraDivLiberaSenha();');return false;"<?php } else { ?>style="cursor: default;" onClick="return false;"<?php } ?> />
    <input id="habilitacao" type="image" src="<?php echo $UrlImagens; ?>botoes/habilitacao.gif" <?php if (in_array("H",$glbvars["opcoesTela"])) { ?>onClick="carregaHabilitacao();return false;"<?php } else { ?>style="cursor: default;" onClick="return false;"<?php } ?> />
  </div>
</div>

<div id="divAlterarSenha" style="display: none;">

  <form action="" method="post" name="frmAlterarSenha" id="frmAlterarSenha" style = "padding-top:20px;">

		<label for="cddsenha"><? echo utf8ToHtml('Senha Atual:') ?></label>
    <input name="cddsenha" type="password" id="cddsenha" onkeypress="return enterTab(this,event);" />
    <br />

		<label for="cdsnhnew"><? echo utf8ToHtml('Nova Senha:') ?></label>
    <input name="cdsnhnew" type="password" id="cdsnhnew" onkeypress="return enterTab(this,event);" />
    <br />

		<label for="cdsnhrep"><? echo utf8ToHtml('Confirma Senha:') ?></label>
    <input name="cdsnhrep" type="password" id="cdsnhrep" />

  </form>
  <div id="divBotoes1">
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="mostraDivAlteraSenha();return false;" />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="showConfirmacao('Deseja alterar a senha de acesso &agrave; internet?','Confirma&ccedil;&atilde;o - Aimaro','alteraSenhaAcesso()',metodoBlock,'sim.gif','nao.gif');return false;" />
  </div>
</div>

<div id="divNumericaLetras" style="display: none;">

  <br />
	<input type="image" id="btnVoltarOpcao" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"  >
	<input type="image" id="btnNumerico" src="<?php echo $UrlImagens; ?>botoes/numerica.gif" onClick="mostraDivAlteraSenhaNum();return false;">
  <input type="image" id="btnLetrasSolicitar" src="<?php echo $UrlImagens; ?>botoes/letras_seguranca.gif" onClick=" mostraDivAlteraSenhaLetras();return false;" >
  <br />

</div>

<div id="divLiberarSenha" style="display: none;">

  <form action="" method="post" name="frmLiberarSenha" id="frmLiberarSenha" style = "padding-top:15px;">


		<label for="cdsnhnew"><? echo utf8ToHtml('Senha:') ?></label>
    <input name="cdsnhnew" type="password" id="cdsnhnew" onkeypress="return enterTab(this,event);" />
    <br />

		<label for="cdsnhrep"><? echo utf8ToHtml('Confirma Senha:') ?></label>
    <input name="cdsnhrep" type="password" id="cdsnhrep" />

  </form>
  <div id="divBotoes2">
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="mostraOpcaoPrincipal();return false;" />
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/liberar.gif" onClick="showConfirmacao('Deseja liberar a senha de acesso &agrave; internet?','Confirma&ccedil;&atilde;o - Aimaro','liberaSenhaAcesso()',metodoBlock,'sim.gif','nao.gif');return false;" />
  </div>
</div>

<form action="" method="post" name="frmSenhaLetras" id="frmSenhaLetras" class="formulario" style="display: none;">

  <fieldset>
    <legend>Letras de Seguran&ccedil;a</legend>

    <br />

    <label for="dssennov">Letras de Seguran&ccedil;a:</label>
    <input name="dssennov" type="password" id="dssennov" maxlength="3" onkeypress="return enterTab(this,event);" />
    <br />

    <label for="dssencon">Confirme suas letras:</label>
    <input name="dssencon" type="password" id="dssencon" maxlength="3" onkeypress="if(event.keyCode == 13){alterarSenhaLetrasCartao();return false; return false;};"/>

    <input name="cddopcao" id="cddopcao" type="hidden" />

  </fieldset>

  <div id="divBotoes">
    <input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="mostraDivAlteraSenha();return false;">
    <input type="image" id="btnAlterar" name="btnAlterar" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="alterarSenhaLetrasCartao();return false;">

  </div>

</form>

<div id="divPrincipalPJ" style="display: none; padding-top:15px;">
  <input type="image" src="<?php echo $UrlImagens; ?>botoes/responsaveis_assinatura_conjunta.gif" onClick="controlaLayout('divResponsaveisAss');return false;" />
  <input type="image" src="<?php echo $UrlImagens; ?>botoes/acesso_internet_responsaveis.gif" id="btnAceIntResp" onClick="exibeLayout(<?php echo($idastcjt); ?>,<?php echo($qtTitulares); ?>);"/>
</div>

<div id="divResponsaveisAss" style="display: none; padding-top: 10px;">
  <form id="frmResponsaveisAss" class="formulario">
    <?php 
	    if($idastcjt == 1){
	      include('responsaveis_assinatura_conjunta.php'); 
	    }
	  ?>
  </form>

  <div id="divBotoes">
		<!-- JMD --> <input type="image" id="btnVoltarOpcao" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"  >
		<input type="image" id="btConfirmar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaResponsaveis(); return false;" />
  </div>
</div>

<form action="<?php echo $UrlSite; ?>telas/atenda/internet/impressao.php" name="frmImpressaoInternet" id="frmImpressaoInternet" method="post">
  <input type="hidden" name="nrdconta" id="nrdconta" value="">
    <input type="hidden" name="idseqttl" id="idseqttl" value="">
      <input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
    </form>
<script type="text/javascript">

  idastcjt = <?php echo $idastcjt; ?>;

  <?php
		if($idastcjt == 1){
	?>
  if(!exibePJ){
  controlaLayout('divPrincipalPJ');
  $("#divConteudoOpcao").css("height","50");
  $("#divConteudoOpcao").css("width","395");
  confPJ = true;
  }else{
  confPJ = false;
  }
  exibePJ = true;
  <?php
		}
	?>

  // Esconde mensagem de aguardo
  hideMsgAguardo();

  // Bloqueia conteúdo que está átras do div da rotina
  blockBackground(parseInt($("#divRotina").css("z-index")));

  //JMD
  if(!confPJ){
  exibeLayout(<?php echo $idastcjt; ?>,qtdTitular);
  }


  function exibeLayout(pr_idastcjt,qtdTitular){

  qtdTitular = qtdTitular;

  if(qtdTitular <= 1 && pr_idastcjt ==1 ){
  showError("error","Selecione no minimo 2 responsaveis pela assinatura conjunta.","Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
  return false;
  }

  controlaLayout('divInternetPrincipal');
	tamanhoDiv = '<?php if ($inpessoa == "1" || $inpessoa == "3") { echo "365"; } else { echo "500"; } ?>px';

  // Aumenta tamanho do div onde o conteúdo da opção será visualizado
  $("#divConteudoOpcao").css("height",tamanhoDiv);

  // Muda a posição do campo de exibição da Sit. da Senha para Pes. Física
  //$('#dssitsnh','#divInternetPrincipal').css("width","<?php if ($inpessoa == "1") { echo "133"; } else { echo "86"; } ?>px");
  $('#dssitsnh','#divInternetPrincipal').css("width","133px");

  $("#cddsenha","#frmAlterarSenha").setMask("INTEGER","zzzzzzzz","","");
  $("#cdsnhnew","#frmAlterarSenha").setMask("INTEGER","zzzzzzzz","","");
  $("#cdsnhrep","#frmAlterarSenha").setMask("INTEGER","zzzzzzzz","","");

  $("#cdsnhnew","#frmLiberarSenha").setMask("INTEGER","zzzzzzzz","","");
  $("#cdsnhrep","#frmLiberarSenha").setMask("INTEGER","zzzzzzzz","","");

  //Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto 217
  if (executandoProdutos && pr_idastcjt == 0) {
  if (cdproduto == 1) {
  mostraDivLiberaSenha();
  }
  else if (cdproduto == 14) {
  obtemDadosLimites();
  }
  }
  ajustarCentralizacao();
  }
</script>