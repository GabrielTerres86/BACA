<?
/*!
 * FONTE        : form_resp_assinatura.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 11/01/2018
 * OBJETIVO     : Tela de exibição dos responsaveis pela assinatura para escolha
 * --------------
 * ALTERAÇÕES   :
 */		

session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../../includes/config.php");
require_once("../../../../includes/funcoes.php");
require_once("../../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../../class/xmlfile.php");	

// Guardo os parâmetos do POST em variáveis	
$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

// Montar o xml de Requisicao
$xml  = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA", "BUSCA_RESP_ASSINATURA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);		
//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------

if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	$msgErro = $xmlObj->roottag->tags[0]->cdata;
	if($msgErro == null || $msgErro == ''){
		$msgErro = utf8_encode($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	exit();
}

?>
<div class="divRegistros" id="divResponsaveis">	
	<table class="tituloRegistros" id="divResponsaveis">
		<thead>
			<tr>
				<th>Nome</th>
			</tr>
		</thead>
		<tbody>
			<?
			if(strtoupper($xmlObj->roottag->tags[0]->name == 'RESPONSAVEIS')){	
				foreach($xmlObj->roottag->tags[0]->tags as $responsavel){
					?>
					<tr>
						<td id="nmprimtl" >
							<? echo $responsavel->tags[0]->cdata; ?>
							<input type="hidden" value="<? echo $responsavel->tags[1]->cdata; ?>" />
						</td>
					</tr>
					<?
				}		
			}
			?>
		</tbody>
	</table>
</div>