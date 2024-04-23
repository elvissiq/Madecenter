#Include 'Protheus.ch'
/*/
  @param
  @return Não retorna nada
  @author Totvs Nordeste (Elvis Siqueira)
  @owner Totvs S/A
  @version Protheus 10, Protheus 11,Protheus 12
  @since 22/04/2024 
  @sample
        Ponto de Entrada utilizado para realizar a Reserva dos produtos da venda sem a exibicao da interface para o usuario.
        Este ponto de entrada eh utilizado apenas para selecionar as opcoes que o sistema passa como parametro, ou seja,
        utiliza o mesmo conceito como se estivesse utilizando a interface (tela) para o ususario fazer a selecao das opcoes,
        porem a selecao eh feita por este PE sem a exibicao da interface.			
  @obs
  @project
  @menu 
  @history
  22/04/2024 - Desenvolvimento da Rotina.
/*/

User Function LJRESERV()
  Local aArea     := FWGetArea()
  Local aRet      := {} //Retorno da funcao
  Local cOperacao := PARAMIXB[1] //Tipo de Operação em execução (1=Momento; 2=Momento)
  Local aLojas    := PARAMIXB[2] //Lojas disponiveis para efetuar a Reserva
  Local aProdutos := PARAMIXB[3] //Produtos da venda que a serem reservados
  Local aEstoque  := PARAMIXB[4] //Saldos dos Estoques nas lojas/armazem
  //Local aEstoqBKP := aClone(aEstoque)
  Local lConfirma := .F.
  Local nY
  
  Do Case 
    Case cOperacao == "1"
      
      For nY := 1 To Len(aLojas)
        aLojas[nY][1] := .T.
      Next 
      
      For nY := 1 To Len(aProdutos)
        aProdutos[nY][1] := .T.
      Next  

      aRet := { lConfirma, aLojas, aProdutos, aEstoque }

    Case cOperacao == "3"
      
      aRet := { lConfirma, aLojas, aProdutos, aEstoque }

  End Case 

  FWRestArea(aArea)
  
Return aRet
