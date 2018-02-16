


<?php 

	/************************************************************************
	 Fonte: titulos_limite_detalhes_proposta.php                          
	 Autor: Leonardo Oliveira                                                 
	 Data : Fevereiro/2018               
	                                                                  
	 Objetivo  : 
	                              
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
	
//##Validações
	/*
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["nrctrlim"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	*/

	//## Requisição Mensageria
	/*
	// Monta o xml de requisição
	$xmlGetDados = "";
	$xmlGetDados .= "<Root>";
	$xmlGetDados .= "	<Cabecalho>";
	$xmlGetDados .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetDados .= "		<Proc>busca_dados_limite_consulta</Proc>";
	$xmlGetDados .= "	</Cabecalho>";
	$xmlGetDados .= "	<Dados>";
	$xmlGetDados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDados .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDados .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDados .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetDados .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDados .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDados .= "		<idseqttl>1</idseqttl>";
	$xmlGetDados .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDados .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDados .= "	</Dados>";
	$xmlGetDados .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDados);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML(retiraAcentos(removeCaracteresInvalidos($xmlResult)));
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		exibeErro(str_replace('"',"'",$xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata));
	} 
	
	$dados = $xmlObjDados->roottag->tags[0]->tags[0]->tags;
	$registros = $xmlObjDados->roottag->tags[1]->tags;
	

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
	*/

	
?>

		<table>
			<fieldset id='tabConteudo'>
            <legend><b>Detalhes Proposta</b></legend>
            <div class='divRegistros'>
                <table>
                <thead>
                    <tr>
                        <th>Acionamento</th>
                        <th>PA</th>
                        <th>Operador</th>
                        <th>Opera&ccedil;&atilde;o</th>
                        <th>Data e Hora</th>
                        <th>Retorno</th>
                    </tr>
                </thead>
                <tbody>
                
				<?php
                	foreach ($registros as $r) {
                    ?>
                    <tr>
                        <td><?= getByTagName($r->tags, 'acionamento'); ?></td>
                        <td><?= getByTagName($r->tags, 'nmagenci'); ?></td>
                        <td><?= getByTagName($r->tags, 'cdoperad'); ?></td>
                        <td><?= $dsoperacao; ?></td>
                        <td><?= getByTagName($r->tags, 'dtmvtolt'); ?></td>
                        <td><?= wordwrap(getByTagName($r->tags, 'retorno'),40, "<br />\n"); ?></td>
                    </tr>
                    <?php
                }
                ?>

                </tbody>
                </table>
            </div>
        </fieldset>
		</table>


<script type="text/javascript">

$("#divOpcoesDaOpcao2").css("display","none");
$("#divOpcoesDaOpcao3").css("display","block");

hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>