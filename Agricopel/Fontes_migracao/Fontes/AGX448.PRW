#INCLUDE "rwmake.ch" 
//#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "colors.ch"
#INCLUDE "protheus.ch"                 
                       



User Function AGX448()
	Private	cPerg:= "AGX448"
	aRegistros:= {}                                                                                                                  

	AADD(aRegistros,{cPerg,"01","Analise         ?","mv_ch1","N",01,0,0,"C","","MV_PAR01","Crédito","","","CréditoS","","","","","","","","","","",""})	 
	AADD(aRegistros,{cPerg,"02","CPF/CNPJ        ?","mv_ch2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})      
	AADD(aRegistros,{cPerg,"03","Valor Compra    ?","mv_ch3","N",09,2,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})      

    U_CriaPer(cPerg,aRegistros)
	Pergunte(cPerg,.T.)

	IF MsgYesNo("Deseja Continuar ? ")               
	   cTipo := "" 

	    
	   Processa({|| fGestorCred()})
       ApMsgInfo("Dados processados com sucesso !")
   Else
      Alert("Operação Cancelada!")
   EndIf
Return()  
                    

Static Function fGestorCred()
Local oWS     := WSwsgestordecisao():New()
Local cResult := ""    
//oWS := WsClassNew( "WSwsgestordecisao" )

//csCNPJ,csUsrGC,csPassGC,csUsrSer,csPassSer,csDoc,nVrCompra,csScore,lbSerasa,lbAtualizar,csOnLine 
//If oWS:AnalisarCredito("81632093000179","86020488","81632093","86014056","5674",MV_PAR02,MV_PAR03,"    ",.F.,.F.,"VALORPEDIDO@1000|DATADOPEDIDO@14/06/2011")
If oWS:AnalisarCredito("81632093000179","RODRIGO","mime","86020488","mime",ALLTRIM(MV_PAR02),MV_PAR03,"    ",.F.,.F.,"VALORPEDIDO@1000|DATADOPEDIDO@14/06/2011")
   cResult:= oWS:cAnalisarCreditoResult
   alert(cResult)
   alert("server ok")
Else
   alert('Erro de Execução : '+GetWSCError())
Endif



/*If oWS:BuscaPolParametro("rodrigo","mime","86020488","mime")
   cResult:= oWS:cBuscaPolParametroResult
   alert(cResult)
   alert("server ok")
Else
   alert('Erro de Execução : '+GetWSCError())
Endif*/                  




//oSaldo:SetText(nSaldo)
//oSaldo:Refresh()

Return .T.




