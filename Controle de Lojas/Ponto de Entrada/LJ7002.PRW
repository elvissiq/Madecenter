#Include 'Protheus.ch'
/*/
  @param
  @return Não retorna nada
  @author Totvs Nordeste (Elvis Siqueira)
  @owner Totvs S/A
  @version Protheus 10, Protheus 11,Protheus 12
  @since 31/01/2024
  @sample
  			Ponto de Entrada chamado depois da gravação de todos os dados 
        e da impressão do cupom fiscal na Venda Assistida e após o processamento do Job LjGrvBatch
  @obs
  @project
  @menu 
  @history
  31/01/2024 - Desenvolvimento da Rotina.
/*/

User Function LJ7002()
Local nOpcao    := ParamIxB[1]
Local lGrvBatch := IIF(ParamIxB[3]==2,.T.,.F.)

  If nOpcao <> 1
     Return
  ElseIF FWAlertNoYes("Imprimir orçamento ?","Impressão")
    u_zROrcVen() //Funcao para reprocessamento Fiscal
  EndIf
  
Return
