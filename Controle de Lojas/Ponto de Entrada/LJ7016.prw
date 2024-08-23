#INCLUDE "PROTHEUS.CH"

/*-------------------------------------------------------------------------------------*
 | P.E.:  LJ7016                                                                       |
 | Desc:  LJ7016 - Ponto de entrada utilizado para incluir novas op��es no             | 
 |                 menu de atendimento do venda assitida.                              |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6791060                |
 *-------------------------------------------------------------------------------------*/

User Function LJ7016

Local aFunAtt := {}
Local nAtalho := PARAMIXB[2]

nAtalho++
aAtalho := Lj7Atalho(nAtalho)
AADD( aFunAtt,{"Hist. Cliente","Hist. Cliente","RELATORIO",{|| U_MLJF01()}, .F., .T., 4, aAtalho }) //Historico do Cliente

Return(aFunAtt)
