#Include 'Protheus.ch'
#Include "TOPCONN.ch"

/*/
/*-----------------------------------------------------------------------
  Função: L010RETNG

  L010RETNG - Alteração de dados da tela da Condição negociada, 
              Venda e Balcão.

  Esse ponto de entrada permite a alteração do dados da tela da 
  Condição Negociada, Venda Balcão.

Retorno:
  AretNg(Vetor)

--------------------------------------------------------------------------
  @history
  13/11/2024 - Desenvolvimento da Rotina.
/*/

User Function L010RETNG()
  Local aArea   := FWGetArea()
  Local aRetNeg := ParamIxB
  
  aRetNeg[1][1] := 1                         // (N) Tipo de Cálculo, sendo: 1 - Simples, 2 - Série de Pagamentos
  aRetNeg[1][2] := "0"                       // (C) String de 4 dígitos, que indica que tipo de cálculo está habilitado ou não, para seleção, sendo "0" - desabilita e "1" - habilita
  aRetNeg[2][1] := aRetNeg[2][1]             // (L) Opção "Utiliza Financiadora" está selecionada
  aRetNeg[2][2] := aRetNeg[2][2]             // "0" indica que a opção "Utiliza Financiadora" NÃO estará aberta para seleção ( enable) e "1" indica que a opção "Utiliza Financiadora" estará aberta para seleção ( enable)
  aRetNeg[3][1] := aRetNeg[3][1]             // (C) Nome da administradora financeira
  aRetNeg[3][2] := aRetNeg[3][2]             // "0" indica que o combo de seleção da "Administradora" NÃO estará aberto para seleção ( enable) e "1" indica que o combo de seleção da "Administradora" estará aberto para seleção ( enable)
  aRetNeg[4][1] := DaySum(aRetNeg[4][1],30)  // (D) Data da primeira parcela
  aRetNeg[4][2] := "0"                       // "0" indica que a linha "Primeira parcela" estará aberta para edição ( enable), "1" indica que  a linha "Primeira parcela" não estará aberta para edição ( disable) e "2" indica que a linha "Primeira parcela" não será apresentada na tela
  aRetNeg[5][1] := aRetNeg[5][1]             // (N) Valor de entrada
  aRetNeg[5][2] := "0"                       // "0" indica que a linha "Entrada" estará aberta para edição ( enable), "1" indica que a linha "Entrada" não estará aberta para edição ( disable) e "2" indica que a linha "Entrada" não será apresentada na tela
  aRetNeg[6][1] := aRetNeg[6][1]             // (N) Valor da taxa de juros
  aRetNeg[6][2] := "0"                       // "0" indica que a linha "Taxa de Juros" estará aberta para edição ( enable), "1" indica que a linha "Taxa de Juros" não estará aberta para edição ( disable) e "2" indica que a linha "Taxa de Juros" não será apresentada na tela
  aRetNeg[7][1] := aRetNeg[7][1]             // (N) Número de parcelas
  aRetNeg[7][2] := aRetNeg[7][2]             // "0" Indica que a linha "Parcelas" estará aberta para edição ( enable), "1" indica que a linha "Parcelas" não estará aberta para edição ( disable) e "2" indica que a linha "Parcelas" não será apresentada na tela
  aRetNeg[8][1] := aRetNeg[8][1]             // (N) Número de dias de intervalos entre as parcelas
  aRetNeg[8][2] := aRetNeg[8][2]             // "0" indica que a linha "Intervalo" estará aberta para edição ( enable), "1" indica que a linha "Intervalo" não estará aberta para edição ( disable) e "2" indica que a linha "Intervalo" não será apresentada na tela
  
  FWRestArea(aArea)

Return aRetNeg
