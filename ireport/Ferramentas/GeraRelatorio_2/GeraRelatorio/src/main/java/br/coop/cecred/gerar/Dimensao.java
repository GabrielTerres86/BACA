package br.coop.cecred.gerar;

/**
 * Classe para concentrar métodos para controle dimensional (altura e largura) dos caracteres e página do relatório.
 * @author Petter - Supero Tecnologia
 * @since  Março/2013
 */
public class Dimensao {    
    /**
     * Método para calcular largura dos caracteres em pixel.
     * Largura é universal para todos os relatórios pois as fontes são de largura fixa.
     * @param largPag Largura da página em pixel
     * @param coluna Número de colunas
     * @return Largura dos caracteres em pixel
     */
    protected static Float getLargura(Float largPag, int coluna){
        Float largura = largPag / new Float(coluna);
        
        return largura;
    }
    
    /**
     * Método para calcular altura dos caracteres em pixel.
     * Utiliza como padrão o layout de 132 colunas.
     * @param coluna Número de colunas do relatório
     * @param tamPagina Tamanho da página
     * @return Altura dos caracteres em pixel
     */
    protected static Float getAltura(int coluna, int tamPagina){
        Float altura = new Float(0);
        
        switch (coluna) {
            case 80:
                if(tamPagina == 950){
                    altura = new Float(10.965426);
                }else{
                    altura = new Float(11);
                }   break;
            case 234:
                if(tamPagina == 700){
                    altura = new Float(7.995254);
                }else{
                    altura = new Float(8);
                }   break;
            default:
                if(tamPagina == 670){
                    altura = new Float(7.982042654028436);
                }else{
                    altura = new Float(8);
                }   break;
        }

        return altura;
    }
}
