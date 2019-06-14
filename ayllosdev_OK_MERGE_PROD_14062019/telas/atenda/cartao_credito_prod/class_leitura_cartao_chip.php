<?
/*!
 * FONTE        : class_leitura_emv_cartao.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Classe responsavel por ler o padrao EMV e retornar a informacao decodificada
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
class LeituraCartaoChip{

	private $portador;
	private $numeroCartao;
	private $dataValidade;
	
	private function hex2bin($sTexto){
		if (!is_string($sTexto))
			return null;
		
		$sRetorno = '';
		for ($a = 0; $a < strlen($sTexto); $a += 2) { 
			$sRetorno .= chr(hexdec($sTexto{$a}.$sTexto{($a + 1)})); 
		}
		return $sRetorno;
	}
	
	public function setNumeroCartao($numero){
		$this->numeroCartao = $numero;	
	}
	
	public function getNumeroCartao(){
		return formataNumericos("9999.9999.9999.9999",substr($this->numeroCartao,4,16),".");		
	}
	
	public function getNumeroCartaoFormatado(){
		$sNumeroCartao = substr($this->numeroCartao,4,16);
		return substr($sNumeroCartao,0,4).'.'.substr($sNumeroCartao,4,2).'**.****.'.substr($sNumeroCartao,12,4);
	}
	
	public function setPortador($portador){
		$this->portador = $portador;	
	}
	
	public function getPortador(){
		return $this->hex2bin(substr($this->portador,6,80));
	}
	
	public function setDataValidade($data){
		$this->dataValidade = $data;	
	}
	
	public function getDataValidade(){
		return substr($this->dataValidade,8,2).'/'.substr(date('Y'),0,2).substr($this->dataValidade,6,2);
	}
}
?>