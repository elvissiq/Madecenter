#INCLUDE "PROTHEUS.CH"

/*-------------------------------------------------------------------------------------*
 | P.E.:  LJ7016                                                                       |
 | Desc:  LJ7016 - Ponto de entrada utilizado para incluir novas opções no             | 
 |                 menu de atendimento do venda assitida.                              |
 | Link:  https://tdn.totvs.com/pages/releaseview.action?pageId=6791060                |
 *-------------------------------------------------------------------------------------*/

User Function LJ7016
    Local aFunAtt := {}
    Local nAtalho := PARAMIXB[2]

    nAtalho++
    aAtalho := Lj7Atalho(nAtalho)
    AADD( aFunAtt,{"Hist. Cliente","Hist. Cliente","RELATORIO",{|| U_MLJF01()}, .F., .T., 4, aAtalho }) //Historico do Cliente
    AADD( aFunAtt,{"Cred. Correntista","Cred. Correntista","RELATORIO",{|| U_MLJF06()}, .F., .T., 4, aAtalho }) //Crédito Correntista
    AADD( aFunAtt,{"Pesq. Reserva","Pesq. Reserva","RELATORIO",{|| MATA430()}, .F., .T., 4, aAtalho }) //Controle de Reserva

Return(aFunAtt)

