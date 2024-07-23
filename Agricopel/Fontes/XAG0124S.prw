#Include "PROTHEUS.CH"
#include 'TOPConn.ch'
#include "rwmake.ch" 

//--------------------------------------------------------------
/*/{Protheus.doc} XAG0124S
Description
                                                                
@param xParam Parameter Description
@return xRet Return Description
@author Leandro Spiller
@since 28/11/2023
/*/
//--------------------------------------------------------------
User Function XAG0124S(xOpc,lBrw)

  Local   cTitulo    := "Atribuir Separador""
  Local   cOperador  := "Separador:"
  Local   nColor := 16767370

  Private oDlgSep
  Private oPedido
  Private cPedidoSep := "         "
  Private oSeparad
  Private cSeparad   := "      "
  Private oNomSep
  Private cNomSep
  Private Pedido
  Private separador
  Private oSeqPed
  Private cSeqSep := "   "
  Private cPedidoS := ""
  Private Motivo
  Private oMotivo
  Private cMotivo := ""
  Private cCpMotivo := Space(50)
  Private oAcao
  Private nAcao := 1
  Private aPedidos := {}
  Private cMsgDiv  := ""  
 

  Default lBrw := .F.
  Default xOpc := "A"//A=Atribuir Separador / B = Executar separação / C = Atribuir conferente / D = Executar Conferencia / E = Estornar Separacao / F=EStornar Conferencia  

   nColor     := 7321599//laranja

  If xOpc == "C"
    cTitulo  := "Atribuir Conferente""
    cOperador  := "Conferente:"
    nColor     := 10813348 //verde
  Elseif xOpc == "B" 
    cTitulo  := "Confirmar SEPARAÇÃO"
    cOperador  := "Separador:"
    nColor     := 7321599//laranja
  Elseif xOpc == "D"
    cTitulo  := "Confirmar CONFERENCIA"
    cOperador  := "Conferente:"
    nColor     := 10813348 //verde
  Elseif xOpc == "E" 
    cTitulo  := "ESTORNAR SEPARAÇÃO"
    cMotivo  := "Motivo:"
     nColor     := 7321599//laranja
  Elseif xOpc == "F"
    cTitulo  := "ESTORNAR CONFERENCIA"
    cMotivo  := "Motivo:"
    nColor     := 10813348 //verde
  Endif 
  
  //Se veio do Browse valida todos os pedidos marcados
  iF lBrw
        
        cMarca :=     oBrowseSC9:Mark()
        cPedidoSep := ""
        dbselectarea('XAG0124')
        XAG0124->(dbGotop())
        While XAG0124->(!eof())
            If alltrim(XAG0124->(C9_XOKSEP)) = alltrim(cMarca)
                cPedidoS +=  "'"+XAG0124->C9_PEDIDO + XAG0124->C9_XSREDI+"',"
                cPedidoSep +=  ""+XAG0124->C9_PEDIDO + XAG0124->C9_XSREDI+"/"
                AADD(aPedidos,XAG0124->C9_PEDIDO + XAG0124->C9_XSREDI)
            Endif  
            XAG0124->(dbskip())
        Enddo 

        If cPedidoS == ""
            MSGSTOP( "Nenhum pedido foi marcado!!", "ATENCAO" )
            Return

        Endif 


        cPedidoS := subst(cPedidoS,1, len(cPedidoS)-1)

        //Busca quantas Sequencias tem de pedidos disponiveis
        _cQuery := " SELECT C9_PEDIDO,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON,C9_XNOMCON, "
        _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP "
        _cQuery += "  FROM "+RetSqlName('SC9')+" (NOLOCK)"
        _cQuery += "  WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND C9_PEDIDO+C9_XSREDI in("+cPedidoS+") "
        _cQuery += "  AND D_E_L_E_T_ = '' "
        
        _cQuery += "  GROUP BY C9_PEDIDO,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON,C9_XNOMCON, "
        _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP "

        If (Select("ValidPed") <> 0)
            dbSelectArea("ValidPed")
            dbCloseArea()
        Endif

        TCQuery _cQuery NEW ALIAS "ValidPed"
        
        While ValidPed->(!eof())

            If alltrim(ValidPed->C9_XDTEDI) == ''
                MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Sem Mapa de separação. Desmarque ou imprima o mapa", "ATENCAO" )
                Return
            Endif 

            iF xOpc == "A"
                If !Empty(ValidPed->C9_XCODSEP)
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa ja esta atribuida para "+alltrim(ValidPed->C9_XNOMSEP)+" Desmarque ou realize o estorno da tarefa", "ATENCAO" )
                    Return
                Endif
            ElseIf xOpc == "B"
                If !Empty(ValidPed->C9_XDTSEP) .AND. !(ValidPed->C9_XSTSSEP $ 'G/H')
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa ja foi concluida por "+alltrim(ValidPed->C9_XNOMSEP)+" em "+dtoc(stod(ValidPed->C9_XDTSEP)) + " Desmarque ou realize o estorno da tarefa", "ATENCAO" )
                    Return
                Elseif Empty(ValidPed->C9_XCODSEP)
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa sem SEPARADOR ATRIBUÍDO, Desmarque ou realize a atribuicao da tarefa", "ATENCAO" )
                    Return
                Endif
            ElseIf  xOpc == "C"
                If !Empty(ValidPed->C9_XCODCON)
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa ja esta atribuida para "+alltrim(ValidPed->C9_XNOMCON)+" Desmarque ou realize o estorno da tarefa", "ATENCAO" )
                    Return
                ElseIF Empty(ValidPed->C9_XCODSEP)
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarfa ainda sem separador, atribua um separador primeiro.", "ATENCAO" )
                    Return
                Endif
            ElseIf  xOpc == "D"
                If !Empty(ValidPed->C9_XDTCONF) .AND. !(ValidPed->C9_XSTSSEP $ 'G/H')
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa ja foi concluida por "+alltrim(ValidPed->C9_XNOMCON)+" em "+dtoc(stod(ValidPed->C9_XDTCONF)) + " Desmarque ou realize o estorno da tarefa", "ATENCAO" )
                    Return
                Elseif Empty(ValidPed->C9_XCODCON)
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa sem CONFERENTE ATRIBUÍDO, Desmarque ou realize a atribuicao da tarefa", "ATENCAO" )
                    Return
                Endif
            ElseIf  alltrim(xOpc) == "E"
                If !Empty(ValidPed->C9_XCODCON)
                    MSGSTOP( ValidPed->C9_PEDIDO + ValidPed->C9_XSREDI +": Tarefa com CONFERENTE ATRIBUÍDO, Desmarque ou realize o estorno da conferencia", "ATENCAO" )
                    Return
                Endif 
            Endif

            ValidPed->(dbskip())
        Enddo
          
  Endif 


  DEFINE FONT oFont18 NAME "Arial"  SIZE 18,33 
  DEFINE FONT oFont9  NAME "Arial"  SIZE 6,11 
  DEFINE FONT oFont12 NAME "Arial"  SIZE 12,22 


  DEFINE MSDIALOG oDlgSep TITLE cTitulo FROM 000, 000  TO 500, 500 COLORS  0, 1675038 /*&cColor*//*0, 16777215*/ PIXEL

   If lBrw 
        @ 035, 015 SAY Pedido    PROMPT "Pedido(s)  :" SIZE 090, 014 OF oDlgSep COLORS 0, 16777215  PIXEL FONT oFont18
        @ 035, 125 MSGET oPedido VAR cPedidoSep SIZE 070, 010 OF oDlgSep COLORS 0, 16777215 ON CHANGE ValidPed(lBrw,xOpc) READONLY PIXEL FONT oFont9
        //@ 035, 315 MSGET oSeqPed VAR cSeqSep SIZE 025, 010 OF oDlgSep COLORS 0, 16777215  PIXEL FONT oFont18
   else
       @ 035, 015 SAY Pedido    PROMPT "Pedido   :" SIZE 090, 014 OF oDlgSep COLORS 0, 16777215  PIXEL FONT oFont18
       @ 035, 125 MSGET oPedido VAR cPedidoSep SIZE 070, 010 OF oDlgSep COLORS 0, 16777215 ON CHANGE ValidPed(lBrw,xOpc)  PIXEL FONT oFont18
   Endif 

    If (xOpc $ ('A/B/C/D')) //Se for estorno nao mostra Campo separador e sim Motivo
        
        @ 052, 125 MSGET oSeparad VAR cSeparad SIZE 070, 010 OF oDlgSep COLORS 0, 16777215 ON CHANGE ValidPed(lBrw,xOpc) F3 "CB1MAT" PIXEL FONT oFont18
        @ 052, 014 SAY separador PROMPT cOperador  SIZE 090, 014 OF oDlgSep COLORS 0, 16777215 PIXEL FONT oFont18
        
        If xOpc $ ('B/D')
            @ 012, 015  RADIO oAcao VAR nAcao ITEMS "Confirmar","Informar Divergencia" SIZE 090, 016 OF oDlgSep COLOR 0, 16777215 MESSAGE "Acao" PIXEL
            oAcao:NCLRPANE := nColor
        Endif
        
        //@ 087, 125 MSGET oNomSep VAR cNomSep SIZE 070, 010 OF oDlgSep COLORS 0, 16777215 ON CHANGE ValidPed(lBrw,xOpc)  READONLY PIXEL FONT oFont12
    Else 
        @ 052, 125 MSGET oMotivo VAR cCpMotivo SIZE 070, 010 OF oDlgSep COLORS 0, 16777215 ON CHANGE ValidPed(lBrw,xOpc)  PIXEL FONT oFont9
        @ 052, 014 SAY Motivo PROMPT cMotivo SIZE 090, 014 OF oDlgSep COLORS 0, 16777215 PIXEL FONT oFont18

    Endif 

     oDlgSep:NCLRPANE := nColor     

  ACTIVATE MSDIALOG oDlgSep CENTERED


Return


Static Function ValidPed(lBrw,xOpc)

    local aSeparad := {}
    Local cMsg     := ""
    Local   _I         := 0 

    //Se preencheu operador 
    if alltrim(cSeparad) <> '' .and. alltrim(cPedidoSep) <> ''
        aSeparad := GetOperado(cSeparad)

        cSeparad := aSeparad[1]
        cNomSep  := alltrim(aSeparad[2])

        If alltrim(cSeparad) == ""
            MSGSTOP( "Matricula nao encontrada, verificar cadastro do operador", "ATENCAO" )
            Return           
        Endif 

    Endif 

    If alltrim(cPedidoSep) <> ''
        cPedidoSep := UPPER(cPedidoSep)
    Endif 

    //Se for estorno precisa informar o motivo 
    If xOpc $ ('E/F') 
        If alltrim(cCpMotivo) == '' 
          MSGSTOP( "É Obrigatorio o preenchimento do Motivo!", "ATENCAO" )
          Return
        Endif  
    Endif 

    If xOpc $ ('B/D') .and. alltrim(cSeparad) <> '' .and. alltrim(cPedidoSep) <> ''
        If nAcao == 2
            aInfDiv := InfDiverg('Informar Divergencia',  .T.) //InfDiverg(xTitulo,xMsg,xlYesNo)
            If aInfDiv[1] == .F.
                MSGSTOP( "Operação não concluida - pois não foi confirmada a tela de informar a Divergencia!", "ATENCAO" )
                Return
            Elseif aInfDiv[1] == .T.
                If alltrim(aInfDiv[2]) == ''
                    MSGSTOP( "É Obrigatorio informar a Divergencia!", "ATENCAO" )
                    Return
                Else
                    cMsgDiv := aInfDiv[2]
                Endif  
            Endif
        /*Else
            If xOpc $ ('D')
               
                _cQuery := " SELECT C9_PEDIDO,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON,C9_XNOMCON, "
                _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP "
                _cQuery += "  FROM "+RetSqlName('SC9')+" (NOLOCK)"
                _cQuery += "  WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND C9_PEDIDO+C9_XSREDI in("+cPedidoSep+") "
                _cQuery += "  AND D_E_L_E_T_ = '' "      
                _cQuery += "  GROUP BY C9_PEDIDO,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON,C9_XNOMCON, "
                _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP "

                If (Select("ValSep") <> 0)
                    dbSelectArea("ValSep")
                    dbCloseArea()
                Endif

                TCQuery _cQuery NEW ALIAS "ValSep"

                If alltrim(ValSep->C9_XCODSEP) == alltrim(cSeparad)
                    If (Select("ValSep") <> 0)
                        dbSelectArea("ValSep")
                        dbCloseArea()
                    Endif
                    MSGSTOP( "Não e permitido que o mesmo operador separe e confira o mesmo pedido! ", "ATENCAO" )
                    Return
                Endif 
           
             Endif */
            
        Endif 
    /*ElseIf xOpc $ ('C') .and. alltrim(cSeparad) <> '' .and. alltrim(cPedidoSep) <> ''
           
        _cQuery := " SELECT C9_PEDIDO,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON,C9_XNOMCON, "
        _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP "
        _cQuery += "  FROM "+RetSqlName('SC9')+" (NOLOCK)"
        _cQuery += "  WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND C9_PEDIDO+C9_XSREDI in("+cPedidoSep+") "
        _cQuery += "  AND D_E_L_E_T_ = '' "      
        _cQuery += "  GROUP BY C9_PEDIDO,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON,C9_XNOMCON, "
        _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP "

        If (Select("ValSep") <> 0)
            dbSelectArea("ValSep")
            dbCloseArea()
        Endif

        TCQuery _cQuery NEW ALIAS "ValSep"

        If alltrim(ValSep->C9_XCODSEP) == alltrim(cSeparad)
            If (Select("ValSep") <> 0)
                dbSelectArea("ValSep")
                dbCloseArea()
            Endif
            MSGSTOP( "Não e permitido que o mesmo operador separe e confira o mesmo pedido! ", "ATENCAO" )
            Return
        Endif */
    Endif 
    //Se pedido e Separador estiverem preenchido Valida
    If alltrim(cPedidoSep) <> '' .and. (alltrim(cSeparad) <> '' .or. alltrim(cMotivo) <> '' )

        If lBrw 

            dDate := ddatabase
            cDate := dtos(dDate)
            ctime := substr(time(), 1, 5)

            _cQuery := " UPDATE "+RetSqlName('SC9')+" "
   
            If xOPc == "A"
                _cQuery += " SET C9_XCODSEP  = '" +cSeparad+ "' "
                _cQuery += " ,C9_XNOMSEP  = '" +cNomSep+"' "
                _cQuery += " ,C9_XSTSSEP = 'A' "
            Elseif xOPc == "B" //Executar separacao
                If nAcao == 1 
                    _cQuery += " SET C9_XDTSEP  = '" +cDate+ "' "
                    _cQuery += " ,C9_XHRSEP = '" +ctime+"' "
                    _cQuery += " ,C9_XSTSSEP = 'B' "
                Else //Executar Divergencia
                    _cQuery += " SET C9_XDTSEP  = '" +cDate+ "' "
                    _cQuery += " ,C9_XHRSEP = '" +ctime+"' "
                    _cQuery += " ,C9_XSTSSEP = 'G' "
                    xOpc := "G"
                Endif 
            Elseif xOPc == "C"
                _cQuery += " SET C9_XCODCON  = '" +cSeparad+ "' "
                _cQuery += " ,C9_XNOMCON  = '" +cNomSep+"' "
                _cQuery += " ,C9_XSTSSEP = 'C' "
            Elseif xOPc == "D" //Executar conferencia
                If nAcao == 1
                    _cQuery += " SET C9_XDTCONF  = '" +cDate+ "' "
                    _cQuery += " ,C9_XHRCONF  = '" +ctime+"' "
                    _cQuery += " ,C9_XSTSSEP = 'D' "
                Else //Executar Divergencia
                    _cQuery += " SET C9_XDTCONF  = '" +cDate+ "' "
                    _cQuery += " ,C9_XHRCONF  = '" +ctime+"' "
                    _cQuery += " ,C9_XSTSSEP = 'H' "
                     xOpc := "H"
                Endif 
             Elseif xOPc == "E" //Estorno Separacao
                _cQuery += " SET C9_XDTSEP  = '' "
                _cQuery += " ,C9_XHRSEP  = '' "
                _cQuery += " ,C9_XCODSEP  = '' "
                _cQuery += " ,C9_XNOMSEP  = '' " 
            Elseif xOPc == "F" //Estorno conferencia
                _cQuery += " SET C9_XDTCONF  = '' "
                _cQuery += " ,C9_XHRCONF  = '' "
                _cQuery += " ,C9_XCODCON  = '' "
                _cQuery += " ,C9_XNOMCON  = '' "
            Endif
   
            _cQuery += "  WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND C9_PEDIDO+C9_XSREDI in("+cPedidoS+") "
           
            If xOPc == "A"
                _cQuery += "  AND D_E_L_E_T_ = '' "//AND C9_XCODSEP = '' " 
            ElseIf xOPc == "B"
                _cQuery += "  AND D_E_L_E_T_ = '' "//AND C9_XDTSEP  = '' "
            Elseif xOPc == "C"
                _cQuery += "  AND D_E_L_E_T_ = '' "//AND C9_XCODCON = '' "
            ElseIf xOPc == "D"
                _cQuery += "  AND D_E_L_E_T_ = '' "//AND C9_XDTCONF  = '' "
            Elseif xOPc == "E"
                _cQuery += "  AND D_E_L_E_T_ = '' "//AND C9_XDTSEP <> '' "
            ElseIf xOPc == "F"
                _cQuery += "  AND D_E_L_E_T_ = '' "//AND C9_XDTCONF  <> '' "
            Endif 
           
            If (TCSQLExec(_cQuery) < 0)
                Return MsgStop("TCSQLError() " + TCSQLError())
            Elseif xOPc $ "A"
                MSGINFO( "Pedido(s): "+cPedidoSep+" atribuidos com sucesso, operador: "+cNomSep)
                cMsg := " Separacao atribuida para: "+cSeparad+' - '+cNomSep
            Elseif xOPc $ "B"
                if nAcao == 1
                    MSGINFO( "Pedido(s): "+cPedidoSep+" executados com sucesso, operador: "+cNomSep)
                    cMsg := " Separacao realizada por: "+cSeparad+' - '+cNomSep
                Else
                    MSGINFO( "Pedido(s) DIVERGENTES: "+cPedidoSep+" executados com sucesso, operador: "+cNomSep)
                    cMsg := " Divergencia de Separacao Informada por: "+cSeparad+' - '+alltrim(cNomSep)+' - '+cMsgDiv
                Endif 
            Elseif xOPc $ "C"
                MSGINFO( "Pedido(s): "+cPedidoSep+" atribuidos com sucesso, operador: "+cNomSep)
                cMsg := " Conferencia atribuida para: "+cSeparad+' - '+cNomSep
            Elseif xOPc $ "D"
                If nAcao == 1
                    MSGINFO( "Pedido(s): "+cPedidoSep+" atualizados com sucesso, operador: "+cNomSep)
                    cMsg := " Conferencia realizada por: "+cSeparad+' - '+alltrim(cNomSep)
                Else
                    MSGINFO( "Pedido(s): "+cPedidoSep+" atualizados com sucesso, operador: "+cNomSep)
                    cMsg := " Divergencia de conferencia informada por: "+cSeparad+' - '+alltrim(cNomSep)+' - '+alltrim(cMsgDiv)
                Endif 
            Elseif xOPc $ "E"
                MSGINFO( "Pedido(s): "+cPedidoSep+" Separação ESTORNADA com sucesso!")
                cMsg := " Separacao ESTORNADA por: "+cUsername+' - '+cCpMotivo
            Elseif xOPc $ "F"
                MSGINFO( "Pedido(s): "+cPedidoSep+" Conferencia ESTORNADA com sucesso!")
                cMsg := " Conferencia ESTORNADA por: "+cUsername+' - '+cCpMotivo
             Elseif xOPc $ "G"
                MSGINFO( "Pedido(s): "+cPedidoSep+" Informado divergencia de separacao com sucesso!")
                cMsg := " Divergencia de Separacao por: "+cSeparad+' - '+cNomSep+' - '+alltrim(cMsgDiv)
            Elseif xOPc $ "H"
                MSGINFO( "Pedido(s): "+cPedidoSep+" Informado divergencia de Conferencia com sucesso!")
                cMsg := " Divergencia de Conferencia por: "+cSeparad+' - '+cNomSep+' - '+alltrim(cMsgDiv)
            Endif 

            U_XAG0124E(aPedidos,cMsg,xOpc, lBrw,ddate,cTime  )//(xPedidos,xMsg,xOpc, lBrw)

            //Se for conferencia do pedido, gera Nota Fiscal / Boleto e etiqueta
            If alltrim(xOpc) == 'D'
                If nAcao == 1
                    If MSGYESNO('Deseja Gerar Nota/Etiqueta e Boleto? ')
                        For _I := 1 to len(aPedidos)
                            u_XAG0109C(substr(aPedidos[_I],1,6),substr(aPedidos[_I],7,3) )
                         Next _I
                    Endif 
                Endif 
            Endif 
        
            Close(oDlgSep)
            //msAguarde( { || U_XAG0124D() }, "Atualizando, Aguarde...") 
            //oDlgSep:Close()

        Else

            dDate := ddatabase
            cDate := dtos(dDate)
            ctime := substr(time(), 1, 5)

            //Busca quantas Sequencias tem de pedidos disponiveis
            _cQuery := " SELECT C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON, "
            _cQuery += " C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP,C9_XNOMCON "
            _cQuery += "  FROM "+RetSqlName('SC9')+" (NOLOCK)"
            _cQuery += "  WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND C9_PEDIDO = '"+substr(cPedidoSep,1,6)+"' "
            _cQuery += "  AND D_E_L_E_T_ = '' AND C9_XSREDI ='"+substr(cPedidoSep,7,3)+ "' "
            _cQuery += "  GROUP BY C9_XSREDI,C9_XSREDI,C9_XDTEDI,C9_XHREDI,C9_XCODSEP,C9_XNOMSEP,C9_XCODCON, "
            _cQuery += "  C9_XDTSEP,C9_XHRSEP,C9_XDTCONF,C9_XHRCONF,C9_XSTSSEP,C9_XNOMCON "

            If (Select("ValidPed") <> 0)
                dbSelectArea("ValidPed")
                dbCloseArea()
            Endif

            TCQuery _cQuery NEW ALIAS "ValidPed"
          
            If ValidPed->(!eof())
                If xOPc == "A"
                    If !Empty(ValidPed->C9_XCODSEP)
                        MSGSTOP( "Tarefa ja atribuida para "+ValidPed->C9_XNOMSEP, "ATENCAO" )
                        //Limpa campos de Tela
                        LimpaCampo()
                        Return
                    else
                        _cQuery := " UPDATE "+RetSqlName('SC9')+" "
                        _cQuery += " SET C9_XCODSEP  = '" +cSeparad+ "' "
                        _cQuery += " ,C9_XNOMSEP  = '" +cNomSep+"' "
                        _cQuery += " ,C9_XSTSSEP = 'A' "
                        _cQuery += " WHERE C9_PEDIDO = '"+ substr(cPedidoSep,1,6) + "'
                        _cQuery += " and C9_XSREDI   = '" + substr(cPedidoSep,7,3) +  "' "

                        If (TCSQLExec(_cQuery) < 0)
                            Return MsgStop("TCSQLError() " + TCSQLError())
                        else
                            MSGINFO( " Tarefa atribuida com sucesso para "+alltrim(cNomSep))
                            cMsg := " Tarefa Atribuida para Separador "+alltrim(cNomSep)
                            //Limpa campos de Tela
                            LimpaCampo()
                            Return
                        Endif    
                    EndIf 
                ElseIf xOPc == "B"
                    If !Empty(ValidPed->C9_XDTSEP) .AND. !(ValidPed->C9_XSTSSEP $ 'G/H')
                        MSGSTOP( "Tarefa ja concluida por "+ValidPed->C9_XNOMSEP+" em "+dtoc(stod(ValidPed->C9_XDTSEP)), "ATENCAO" )
                        //Limpa campos de Tela
                        LimpaCampo()
                        Return
                    ElseIf Empty(ValidPed->C9_XCODSEP)
                        MSGSTOP( "Tarefa não foi atribuida a ninguém, solicite que atribua a seu operador!", "ATENCAO" )
                        LimpaCampo()
                        Return
                    ElseIf !Empty(ValidPed->C9_XCODSEP) .AND. alltrim(ValidPed->C9_XCODSEP) <>  alltrim(cSeparad)
                            If !(MSGYESNO( "Tarefa está atribuída para:"+cNomSep+", deseja mesmo assim confirmar? ", "ATENCAO" ))
                                LimpaCampo()
                                Return
                            Endif  
                    else
                        _cQuery := " UPDATE "+RetSqlName('SC9')+" "
                        _cQuery += " SET C9_XDTSEP  = '" +dtos(ddatabase)+ "' "
                        _cQuery += " ,C9_XHRSEP = '" +substr(time(), 1, 5)+"' "
                        If nAcao == 1
                            _cQuery += " ,C9_XSTSSEP = 'B' "
                        Else
                            _cQuery += " ,C9_XSTSSEP = 'G' "
                            xOpc := "G"
                        Endif
                        _cQuery += " WHERE C9_PEDIDO = '"+ substr(cPedidoSep,1,6) + "'
                        _cQuery += " and C9_XSREDI   = '" + substr(cPedidoSep,7,3) +  "' "

                        If (TCSQLExec(_cQuery) < 0)
                            Return MsgStop("TCSQLError() " + TCSQLError())
                        else
                            If nAcao == 1
                                MSGINFO( " Tarefa concluida com sucesso por "+cNomSep)
                                cMsg := " Separacao concluida por: "+alltrim(cNomSep)
                                //Limpa campos de Tela
                                LimpaCampo()
                            Else
                                MSGINFO( " Divergencia informada por: "+cNomSep)
                                cMsg := " Divergencia de Separacao informada por:"+alltrim(cNomSep)+ ' - '+cMsgDiv
                                //Limpa campos de Tela
                                LimpaCampo()
                            Endif
                        Endif    
                    EndIf 
                Elseif xOPc == "C"
                    If !Empty(ValidPed->C9_XCODCON)
                        MSGSTOP( "Tarefa ja atribuida para "+ValidPed->C9_XNOMCON, "ATENCAO" )
                        //Limpa campos de Tela
                        LimpaCampo()
                        Return
                    ElseIf ValidPed->C9_XCODSEP == cSeparad
                        MSGSTOP( "Nao é permitido Atribuir o mesmo usuario para SEPARACAO e CONFERENCIA!", "ATENCAO" )
                        //Limpa campos de Tela
                        LimpaCampo()
                        Return
                    else
                        _cQuery := " UPDATE "+RetSqlName('SC9')+" "
                        _cQuery += " SET C9_XCODCON  = '" +cSeparad+ "' "
                        _cQuery += " ,C9_XNOMCON  = '" +cNomSep+"' "
                        _cQuery += " ,C9_XSTSSEP = 'C' "
                        _cQuery += " WHERE C9_PEDIDO = '"+ substr(cPedidoSep,1,6) + "'
                        _cQuery += " and C9_XSREDI   = '" + substr(cPedidoSep,7,3) +  "' "

                        If (TCSQLExec(_cQuery) < 0)
                            Return MsgStop("TCSQLError() " + TCSQLError())
                        else
                            MSGINFO( " Tarefa atribuida com sucesso para "+cNomSep)
                            cMsg := "Tarefa Atribuida para Conferente: "+cNomSep
                            //Limpa campos de Tela
                            LimpaCampo()
                        Endif    
                    EndIf 
                ElseIf xOPc == "D"
                    If !Empty(ValidPed->C9_XDTCONF) .AND. !(ValidPed->C9_XSTSSEP $ 'G/H')
                        MSGSTOP( "Tarefa ja concluida por "+ValidPed->C9_XNOMSEP+" em "+dtoc(stod(ValidPed->C9_XDTCONF)), "ATENCAO" )
                        //Limpa campos de Tela
                        LimpaCampo()
                        Return
                    ElseIf Empty(ValidPed->C9_XCODCON)
                        MSGSTOP( "Tarefa não foi atribuida a ninguém, solicite que atribua a seu operador!", "ATENCAO" )
                        LimpaCampo()
                        Return
                    ElseIf !Empty(ValidPed->C9_XCODCON)
                        If alltrim(ValidPed->C9_XCODCON) <>  alltrim(cSeparad)
                            If !(MSGYESNO( "Tarefa está atribuída para:"+cNomSep+", deseja mesmo assim confirmar? ", "ATENCAO" ))
                                Return
                            Endif 
                        Endif 
                    else
                        _cQuery := " UPDATE "+RetSqlName('SC9')+" "
                        _cQuery += " SET C9_XDTCONF  = '" +dtos(ddatabase)+ "' "
                        _cQuery += " ,C9_XHRCONF = '" +substr(time(), 1, 5)+"' "
                        If nAcao == 1
                            _cQuery += " ,C9_XSTSSEP = 'D' "
                        Else
                            _cQuery += " ,C9_XSTSSEP = 'H' "
                            xOpc := "H"
                        Endif 
                        _cQuery += " WHERE C9_FILIAL = '"+xFilial('SC9')+"' AND C9_PEDIDO = '"+ substr(cPedidoSep,1,6) + "'
                        _cQuery += " and C9_XSREDI   = '" + substr(cPedidoSep,7,3) +  "' "

                        If (TCSQLExec(_cQuery) < 0)
                            Return MsgStop("TCSQLError() " + TCSQLError())
                        else
                            If nAcao == 1
                                MSGINFO( " Tarefa realizada com sucesso por: "+cNomSep)
                                cMsg := " Conferencia concluida por: "+cNomSep
                                //Limpa campos de Tela
                                LimpaCampo()
                            Else
                                MSGINFO( " Tarefa atribuida com sucesso para "+cNomSep)
                                cMsg := " Divergencia de conferencia informada por: "+cNomSep+ ' - '+cMsgDiv
                                //Limpa campos de Tela
                                LimpaCampo()
                            Endif 
                        Endif    
                    EndIf 
                Endif

                U_XAG0124E(cPedidoSep,cMsg,xOpc, lBrw,dDate, cTime )//(xPedidos,xMsg,xOpc, lBrw)  
             
                //Se for conferencia do pedido, gera Nota Fiscal / Boleto e etiqueta
                If alltrim(xOpc) == 'D'
                    If nAcao == 1
                        If MSGYESNO('Deseja Gerar Nota/Etiqueta e Boleto? ')
                            u_XAG0109C(substr(cPedidoSep,1,6),substr(cPedidoSep,7,3))
                        Endif    
                    Endif 
                Endif
            Else
                MSGSTOP( " Pedido: "+cPedidoSep+" não encontrado! ", "ATENÇÃO")
            Endif 
             
            //Limpa campos de Tela
            LimpaCampo()

        Endif 
    Endif 
    
Return

Static Function GetOperado(xMatri)

    Local aRet := {}

    //Busca quantas Sequencias tem de pedidos disponiveis
    _cQuery := " SELECT CB1_CODOPE, CB1_NOME, CB1_XMATRI "
    _cQuery += "  FROM "+RetSqlName('CB1')+" (NOLOCK)"
    _cQuery += "  WHERE CB1_FILIAL = '"+xFilial('CB1')+"' "
    _cQuery += "  AND CB1_XMATRI = '"+xMatri+"' AND D_E_L_E_T_ = '' 
            
    If (Select("GetOperado") <> 0)
        dbSelectArea("GetOperado")
        dbCloseArea()
    Endif

    TCQuery _cQuery NEW ALIAS "GetOperado"

    AADD(aRet,GetOperado->CB1_CODOPE)
    AADD(aRet,GetOperado->CB1_NOME)
    //AADD(aRet,GetOperado->CB1_XMATRI)

Return aRet



User Function XAG0124E(xPedidos,xMsg,xOpc,lBrw, xData , xHora)

   // Local _cQuery := ""
   Local Ilog := 0 

    Default  xMsg := ""
    Default  xOpc := ""


    If !lBrw
        Dbselectarea('ZC9')
        Reclock('ZC9',.T.)
            ZC9_FILIAL := XFilial('ZC9')     
            ZC9_NUM    := substr(xPedidos,1,6)
            ZC9_SEQ    := substr(xPedidos,7,3)
            ZC9_OBS    := xMsg
            ZC9_ACAO   := xOpc
            ZC9_DATA   := xData
            ZC9_HORA   := xHora
        ZC9->(MsUnlock())
    Else
        Dbselectarea('ZC9')
        For Ilog := 1 to len(xPedidos)
        Reclock('ZC9',.T.)
            ZC9_FILIAL := XFilial('ZC9')     
            ZC9_NUM    := substr(xPedidos[Ilog],1,6)
            ZC9_SEQ    := substr(xPedidos[Ilog],7,3)
            ZC9_OBS    := xMsg
            ZC9_ACAO   := xOpc
            ZC9_DATA   := xData
            ZC9_HORA   := xHora
        ZC9->(MsUnlock())
        Next Ilog 
    Endif 


Return 

Static Function InfDiverg(xTitulo,xlYesNo)

	Local lretMemo 		:= .F.
	Local oDlgDiv
	Local oButton1
	Local oButton2
	Local oMultiGet1
	Local cMsgDiv 	:= SPACE(150)
    Local cRetMsg  := ""

	//cMsgDiv := xMsg

	DEFINE MSDIALOG oDlgDiv TITLE xTitulo FROM 000, 000  TO 110, 350 COLORS 0, 16777215 PIXEL

	   // @ 005, 005 GET oMultiGet1 VAR cMsgDiv OF oDlgDiv MULTILINE SIZE 193, 150 COLORS 0, 16777215 /*READONLY*/ HSCROLL PIXEL
       @ 010, 010 MSGET oMultiGet1 VAR cMsgDiv SIZE 0160, 010 OF oDlgDiv COLORS 0, 16777215 PIXEL// FONT oFont9
    
		if xlYesNo
			//@ 030, 125 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlgDiv PIXEL Action(lRetMemo := .F., oDlgDiv:End() )
	   		//@ 030, 070 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlgDiv PIXEL Action(lRetMemo := .T. , oDlgDiv:End() )
            DEFINE SBUTTON oButton1 FROM 030, 140 TYPE 02 OF oDlgDiv ENABLE Action(lRetMemo := .F., oDlgDiv:End() )
            DEFINE SBUTTON oButton2 FROM 030, 090 TYPE 01 OF oDlgDiv ENABLE Action(lRetMemo := .T. , oDlgDiv:End() )
        else
	   		@ 040, 083 BUTTON oButton2 PROMPT "OK" SIZE 037, 012 OF oDlgDiv PIXEL Action(lRetMemo := .T. , oDlgDiv:End() )
	    endif

	ACTIVATE MSDIALOG oDlgDiv CENTERED

    If lRetMemo == .T. 
        cRetMsg := cMsgDiv
    Endif 

Return {lRetMemo,cRetMsg}

//Limpa Campos de Tela
Static Function LimpaCampo()
   
    cCpMotivo  := Space(50)
    cSeparad   := Space(6)
    cPedidoSep := Space(9)
    //oSeparad:Refresh()
    //oPedido:Refresh()
    //oDlgSep:Refresh(.T.)
    //oPedido:Setfocus()
    //Close(oDlgSep)
    //U_XAG0124S('B',.F.)

Return 
