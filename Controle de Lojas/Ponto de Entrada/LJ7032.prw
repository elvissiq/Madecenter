#Include "TOTVS.ch"

/*------------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  LJ7032                                                                                                                |
 | Desc:  Ponto-de-Entrada: LJ7032 - Valida o acesso à tela de atendimento                                                      |
 |                                                                                                                              |
 | Link:  https://centraldeatendimento.totvs.com/hc/pt-br/articles/115011816767-MP-LJ7032-Valida-o-acesso-à-tela-de-atendimento |
 *-----------------------------------------------------------------------------------------------------------------------------*/

User Function LJ7032()
  Local nOpc := PARAMIXB[1] //Opção escolhida no menu da rotina
  Local lRet := .T.
  
  If nOpc != 4
    Return lRet
  ElseIF !(Empty(SL1->L1_DOC) .AND. !Empty(SL1->L1_RESERVA) .AND. Empty(SL1->L1_DOCPED) .AND. SL1->L1_STATUS <> "D" .AND. !Empty(SL1->L1_ORCRES))
    Return lRet
  EndIF  

  dbSelectArea("SL2")
  SL2->(MSSeek( xFilial("SL2") + SL1->L1_NUM ))

  While !SL2->(Eof()) .AND. SL2->L2_FILIAL + SL2->L2_NUM == xFilial("SL2") + SL1->L1_NUM
    If !SL2->L2_XOK
      lRet := .F.
    EndIF 
    SL2->(DbSkip())
  EndDo

  If !lRet
    FWAlertWarning('Existem itens que ainda não foram entregues ao cliente.','Retira')
  EndIF 

Return lRet
