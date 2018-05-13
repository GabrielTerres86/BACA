<?php 

	/************************************************************************
	 Fonte: titulos_bordero_consultar_visualizatitulos.php                                       
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                Última Alteração: 03/12/2014
	                                                                  
	 Objetivo  : Visualizar os títulos de um Bordero de descontos de títulos        
	                                                                  	 
	 Alterações: 12/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	 
				 29/08/2012 - Separação por Cob. Reg e Sem Registro (Lucas)

				 03/12/2014 - De acordo com a circula 3.656 do Banco Central,
				 		      substituir nomenclaturas Cedente por Beneficiário e  
							  Sacado por Pagador. Chamado 229313 (Jean Reddiga - RKAM)

				 02/04/2018 - Padronização da tabela, retirada das restrições e adição do saldo devedor (Leonardo Oliveira -GFT)
							  
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	
	// Verifica se prâmetros necessários foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	

	$xml =  "<Root>";
	$xml .= " <Dados>";
	$xml .= "		<nrborder>".$nrborder."</nrborder>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";


	$xmlResult = mensageria($xml, "TELA_ATENDA_DESCTO", "BUSCAR_TIT_BORDERO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjTits = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjTits->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjTits->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$titulos      = $xmlObjTits->roottag->tags[0]->tags;
	
	//TOTAL
	$qtTitulos    = count($titulos);
	$vlrtotal = 0;
	$vltotliq = 0;
	$vlmedtit = 0;
	
	//TOTAL REGISTRADA
	$qtTitulos_cr = 0;
	$vlrtotal_cr = 0;
	$vltotliq_cr = 0;
	$vlmedtit_cr = 0;
		
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	
?>


<div id="divTitulosBorderos">

	<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo $nrdconta; ?>" />

	<fieldset>
		<legend>Tipo de Cobran&ccedil;a: REGISTRADA</legend>
			
		<div id="divcr" class="divRegistros" >
				<table  class="tituloRegistros">
					<thead>
						<tr>
							<th>Vencto</th>
							<th>Nosso n&uacute;mero</th>
							<th>Valor</th>
							<th>Valor L&iacute;quido</th>
							<th>Prz</th>
							<th>Pagador</th>
							<th>CPF/CNPJ</th>
							<th>Situa&ccedil;&atilde;o</th>
							<th>Saldo Devedor</th>
						</tr>
					</thead>
					<tbody>
					<?php
							$vlrtotal_cr = 0;
							$vltotliq_cr = 0;
									
							for ($i = 0; $i < $qtTitulos; $i++) {

								$t = $titulos[$i];
											
								if ($t->tags[13]->cdata == "no"){
									continue;
								}
								
								$vlrtotal += doubleval(str_replace(",",".",$t->tags[8]->cdata));
								$vltotliq += doubleval(str_replace(",",".",$t->tags[9]->cdata));
								
								$vlrtotal_cr += doubleval(str_replace(",",".",$t->tags[8]->cdata));
								$vltotliq_cr += doubleval(str_replace(",",".",$t->tags[9]->cdata));
								$qtTitulos_cr += 1;
								
								$mtdClick = "selecionarTituloDeBordero('"
									.($i + 1)."','"
									.$qtBorderos."','"
									.getByTagName($t->tags,'nossonum')."');";
						?>
						<tr 
							id="trTitBordero<?echo $i + 1; ?>" 
							onFocus="<? echo $mtdClick; ?>"
							onClick="<? echo $mtdClick; ?>"
							>

							<td><?php echo $t->tags[3]->cdata;?></td> 
							<td><?php echo $t->tags[10]->cdata; ?></td> 
							<td><?php echo number_format(str_replace(",",".",$t->tags[8]->cdata),2,",",".");?></td> 
							<td><?php echo number_format(str_replace(",",".",$t->tags[9]->cdata),2,",","."); ?></td> 
							<td><?php 
									if (trim($t->tags[4]->cdata) != ""){ 
										echo diffData($t->tags[3]->cdata,$t->tags[4]->cdata); 
										
									}else{
										echo diffData($t->tags[3]->cdata,$glbvars["dtmvtolt"]);
										
									}
							?></td>
							<td><?php echo $t->tags[11]->cdata;
							?></td> 
							<td><?php 
								if (strlen($t->tags[5]->cdata) > 11){ 
									echo formataNumericos('99.999.999/9999-99',$t->tags[5]->cdata,'./-');
								}else{ 
									echo formataNumericos('999.999.999-99',$t->tags[5]->cdata,'.-');
								} 
							?></td>
							
							<td><?php 
								switch ($t->tags[12]->cdata){
									case 0: echo "Pendente";break; 
									case 1: echo "Resgatado";break; 
									case 2: echo "Pago";break; 
									case 3: echo "Vencido";break; 
									case 4: echo "Liberado";break; 
									default: "------";break; }
							?></td>
							<td><?php echo number_format(str_replace(",",".",$t->tags[8]->cdata),2,",",".");?></td> 
						</tr>							
					<?php 
						}
					?>
					</tbody>
				</table>	
			</div>
	</fieldset>
</div>

<?php
	$vlmedtit_cr = doubleval($vlrtotal_cr / $qtTitulos_cr);
?>
<table width="860px" border="0" cellpadding="1" cellspacing="2">
		<tbody>
		<tr>
				<td width="120" align="center" class="txtNormal">TOTAL(REGIST) ==></td>
				<td width="130" align="left"   class="txtNormal"><?php if($qtTitulos_cr <= 1){ echo $qtTitulos_cr." T&Iacute;TULO";}else{ echo $qtTitulos_cr." T&Iacute;TULOS";};?></td>
				<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vlrtotal_cr),2,",","."); ?></td>
				<td width="80"  align="right"  class="txtNormal"><?php echo number_format(str_replace(",",".",$vltotliq_cr),2,",","."); ?></td>
				<td 			align="right"  class="txtNormal"></td>
				<td width="100" align="right"  class="txtNormal">VAL. M&Eacute;DIO: <?php echo number_format(str_replace(",",".",$vlmedtit_cr),2,",","."); ?></td>			
			</tr>
		</tbody>
</table>


<div id="divBotoes">
	<a
	href="#"
	class="botao" 
	name="btnvoltar"
	id="btnvoltar"
	onClick="voltaDiv(4,3,4,'CONSULTA DE BORDER&Ocirc;');return false;" >
		Voltar
	</a>

	<a
	href="#"
	class="botao" 
	name="btnvoltar"
	id="btnvoltar"
	onClick="visualizarTituloDeBordero();return false;" >
		Ver detalhes
	</a>

</div>

<script type="text/javascript">
	dscShowHideDiv("divOpcoesDaOpcao4","divOpcoesDaOpcao3");

	// Muda o título da tela
	$("#tdTitRotina").html("CONSULTA DE T&Iacute;TULOS DO BORDER&Ocirc;");
	formataLayout('divTitulosBorderos');
	    
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>