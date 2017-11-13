<?php 

/*************************************************************************
	Fonte: principal.php
	Autor: Gabriel						Ultima atualizacao: 13/11/2017
	Data : Janeiro/2011
	
	Objetivo: Listar os telefones.
	
	Alteracoes: 13/07/2011 - Alterado para layout padrão (Gabriel Capoia - DB1)
	
	            16/10/2017 - Alterado para que fosse possivel copiar o numero do 
				             telefone atraves de um botao posicionado na grid
							 (Tiago #755346)
							 
				13/11/2017 - Retirado icone ao lado do numero do telefone 
				             (Tiago #755346)
*************************************************************************/

session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	
		
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");


if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
	exibeErro($msgError);		
}
			
	
// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}	
	
$nrdconta = $_POST["nrdconta"];

// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Monta o xml para a requisicao
$xmlGetDadosTelefone = "";
$xmlGetDadosTelefone .= "<Root>";
$xmlGetDadosTelefone .= " <Cabecalho>";
$xmlGetDadosTelefone .= "   <Bo>b1wgen0070.p</Bo>";
$xmlGetDadosTelefone .= "   <Proc>obtem-telefone-titulares</Proc>";
$xmlGetDadosTelefone .= " </Cabecalho>";
$xmlGetDadosTelefone .= " <Dados>";
$xmlGetDadosTelefone .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
$xmlGetDadosTelefone .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlGetDadosTelefone .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlGetDadosTelefone .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; 
$xmlGetDadosTelefone .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlGetDadosTelefone .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";           
$xmlGetDadosTelefone .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlGetDadosTelefone .= "   <idseqttl>1</idseqttl>";         
$xmlGetDadosTelefone .= " </Dados>";      
$xmlGetDadosTelefone .= "</Root>"; 

// Executa script para envio do XML
$xmlResult = getDataXML($xmlGetDadosTelefone);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosTelefone = getObjectXML($xmlResult);


// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosTelefone->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosTelefone->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

// Seta a tag de telefones para a variavel
$telefones = $xmlObjDadosTelefone->roottag->tags[0]->tags;

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	echo '</script>';
	exit();
}

?>

<div id="divResultado">
    <input type="text" id="nrfonres" value="" />
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th>Operadora</th>
					<th>DDD</th>
					<th>Telefone</th>
					<th>Ramal</th>
					<th>Identifica&ccedil;&atilde;o</th>
					<th>Pessoa de Contato</th>
				</tr>			
			</thead>
			<tbody>
				<?  $cont = 0;
				    foreach($telefones as $telefone) {
						
						$cont++;
						$nmopetfn = getByTagName($telefone->tags,'nmopetfn'); // $telefone->tags[0]->cdata;
						$nrdddtfc = getByTagName($telefone->tags,'nrdddtfc'); //$telefone->tags[1]->cdata;
						$nrfonres = getByTagName($telefone->tags,'nrfonres');
						$nrdramal = getByTagName($telefone->tags,'nrdramal');
						$destptfc = getByTagName($telefone->tags,'destptfc');
						$nmpescto = getByTagName($telefone->tags,'nmpescto'); 
						
					?>					
					
					<tr onClick="copier('<?php echo $nrfonres; ?>')">
					
						<td> <?php echo $nmopetfn; ?> </td>
						
					    <td><span><? echo $nrdddtfc; ?></span>
							<?php echo formataNumericos("999",$nrdddtfc); ?>  </td>
						
						<td title="copiar telefone para a area de transfer&ecirc;ncia"><?php echo $nrfonres; ?></td>
						
					    <td><span><? echo $nrdramal; ?></span>
							<?php echo formataNumericos("zzzz",$nrdramal); ?> </td>
						 
				     	<td> <?php echo $destptfc; ?> </td>
						
				     	<td> <?php echo $nmpescto; ?> </td>
					
					</tr>							
				<?} // Fim do for ?>			
			</tbody>
		</table>
	</div>
</div>

<script type="text/javascript">

controlaLayout();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

</script>