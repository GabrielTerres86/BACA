<?php
/*
 * FONTE          : imprimir_relatorio.php
 * CRIAÇÃO        : André Clemer (Supero)
 * DATA CRIAÇÃO   : 13/02/2018
 * OBJETIVO       : Faz a impressão do relatório de títulos cancelados
 * --------------
 * ALTERAÇÕES     : 
 * -------------- 
 */
session_cache_limiter("private");
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo método POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
    ?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
    exit();	
}	

// Recebe as variaveis
$dsiduser 	= session_id();
$nrdconta	= str_ireplace(array('.', '-'), '',$_POST['nrdconta']);	
$nmprimtl	= $_POST['nmprimtl'];
$cdagencx	= $_POST['cdagenci'];

// Monta o xml de requisição
$xml  = '';
$xml .= '<Root>';
$xml .= '	<Cabecalho>';
$xml .= '		<Bo>b1wgen0010.p</Bo>';
$xml .= '		<Proc>gera_relatorio</Proc>';
$xml .= '	</Cabecalho>';
$xml .= '	<Dados>';
$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';
$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';                // Nome para Impressao (Ex.: RAMOS CAR SERVICE MECANICA AUTOMOTIVA LTDA ME)
$xml .= '		<tprelato>8</tprelato>';
$xml .= '		<inidtper>'.$glbvars['dtmvtolt'].'</inidtper>';
$xml .= '		<fimdtper>'.$glbvars['dtmvtolt'].'</fimdtper>';
$xml .= '		<cdstatus>1</cdstatus>';                            // 1 = Em Aberto / 2 = Baixado / 3 = Liquidado / 4 = Rejeitado / 5 = Cartorária
$xml .= '		<cdagencx>'.$cdagencx.'</cdagencx>';                // PA
$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
$xml .= '		<inserasa></inserasa>';                             // "" = Todos
$xml .= '		<cddemail>0</cddemail>';
$xml .= '	</Dados>';                                  
$xml .= '</Root>';

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

// Cria objeto para classe de tratamento de XML
$xmlObjDados = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
    $msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
    ?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
    exit();
} 

// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];

// Chama função para mostrar PDF do impresso gerado no browser
visualizaPDF($nmarqpdf);